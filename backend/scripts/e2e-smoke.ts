import { PrismaClient } from "@prisma/client";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

loadEnv();
const prisma = new PrismaClient();

const baseUrl = process.env.API_BASE_URL ?? "http://localhost:3000/api";
const appKey = process.env.APP_KEY ?? "south-grid-android";
const userId = process.env.SMOKE_USER_ID ?? `codex-e2e-${Date.now()}`;

type AnyRecord = Record<string, any>;

async function main() {
  const report: AnyRecord = { userId, appKey };
  try {
    const bootstrap = await request<AnyRecord>(
      `/client/bootstrap?appKey=${appKey}&userId=${userId}`,
    );
    const subjectId = bootstrap.defaultSubjectId;
    if (!subjectId) throw new Error("No default subject returned by bootstrap");
    report.subject = bootstrap.subjects?.find(
      (item: AnyRecord) => item.id === subjectId,
    )?.name;

    const catalog = await request<AnyRecord>(
      `/client/subjects/${subjectId}/catalog?userId=${userId}&mode=practice`,
    );
    const leaf = firstQuestionLeaf(catalog.nodes ?? []);
    if (!leaf) throw new Error("No practice catalog leaf with questions found");
    report.catalog = leaf.name;

    const questionResponse = await request<AnyRecord>(
      `/client/catalogs/${leaf.id}/questions?limit=20`,
    );
    const questions = questionResponse.questions ?? [];
    const question = questions[0];
    if (!question) throw new Error("No question returned from selected leaf");
    report.questionId = question.id;

    await request("/client/answers", {
      method: "POST",
      body: JSON.stringify({
        userId,
        appKey,
        questionId: question.id,
        mode: "practice",
        ...answerPayload(question),
      }),
    });

    const wrongCandidate = questions.find(
      (item: AnyRecord) => wrongAnswerPayload(item) !== null,
    );
    if (wrongCandidate) {
      await request("/client/answers", {
        method: "POST",
        body: JSON.stringify({
          userId,
          appKey,
          questionId: wrongCandidate.id,
          mode: "practice",
          ...wrongAnswerPayload(wrongCandidate),
        }),
      });
      const wrongAfterError = await request<AnyRecord[]>(
        `/client/wrong-questions?userId=${userId}&subjectId=${subjectId}`,
      );
      if (!hasWrongQuestion(wrongAfterError, wrongCandidate.id)) {
        throw new Error(
          "Wrong answer was not added to the wrong-question list",
        );
      }

      for (var attempt = 1; attempt <= 2; attempt += 1) {
        await request("/client/answers", {
          method: "POST",
          body: JSON.stringify({
            userId,
            appKey,
            questionId: wrongCandidate.id,
            mode: "practice",
            wrongRemovalThreshold: 2,
            ...answerPayload(wrongCandidate),
          }),
        });
        const rows = await request<AnyRecord[]>(
          `/client/wrong-questions?userId=${userId}&subjectId=${subjectId}`,
        );
        const stillActive = hasWrongQuestion(rows, wrongCandidate.id);
        if (attempt === 1 && !stillActive) {
          throw new Error(
            "Wrong question was removed before reaching its threshold",
          );
        }
        if (attempt === 2 && stillActive) {
          throw new Error(
            "Wrong question remained after reaching its threshold",
          );
        }
      }
      report.wrongRemovalFlow = "wrong -> correct 1/2 -> removed 2/2";
    }

    const refreshedPracticeCatalog = await request<AnyRecord>(
      `/client/subjects/${subjectId}/catalog?userId=${userId}&mode=practice`,
    );
    const refreshedLeaf = findNodeById(
      refreshedPracticeCatalog.nodes ?? [],
      leaf.id,
    );
    const expectedPracticed = new Set(
      [question.id, wrongCandidate?.id].filter(Boolean),
    ).size;
    if (Number(refreshedLeaf?.progress?.done) !== expectedPracticed) {
      throw new Error(
        "Practice progress counted attempts instead of unique questions",
      );
    }
    if (Number(refreshedLeaf?.progress?.correct) !== expectedPracticed) {
      throw new Error(
        "Practice progress did not keep the latest answer result",
      );
    }
    report.uniqueQuestionProgress = `${expectedPracticed} unique questions`;

    const otherSubjectId = bootstrap.subjects?.find(
      (item: AnyRecord) => item.id !== subjectId,
    )?.id;
    const currentPracticeRecords = await request<AnyRecord[]>(
      `/client/records?mode=practice&userId=${userId}&appKey=${appKey}&subjectId=${subjectId}`,
    );
    if (currentPracticeRecords.length === 0) {
      throw new Error("Current subject did not return its practice records");
    }
    if (otherSubjectId) {
      const otherPracticeRecords = await request<AnyRecord[]>(
        `/client/records?mode=practice&userId=${userId}&appKey=${appKey}&subjectId=${otherSubjectId}`,
      );
      if (otherPracticeRecords.length > 0) {
        throw new Error("Practice records leaked into another subject");
      }
    }

    const examQuestionIds = questions
      .slice(0, Math.min(2, questions.length))
      .map((item: AnyRecord) => item.id);
    await request("/client/exams/submit", {
      method: "POST",
      body: JSON.stringify({
        userId,
        appKey,
        subjectId,
        title: leaf.name,
        mode: "章节考试",
        durationMinutes: 45,
        remainingSeconds: 1800,
        sectionId: leaf.id,
        questionIds: examQuestionIds,
        answers: [
          {
            questionId: question.id,
            ...answerPayload(question),
          },
        ],
      }),
    });
    const currentExamRecords = await request<AnyRecord[]>(
      `/client/records?mode=exam&userId=${userId}&appKey=${appKey}&subjectId=${subjectId}`,
    );
    if (currentExamRecords.length !== 1) {
      throw new Error("Current subject did not return its exam record");
    }
    const expectedExamScore = Math.round(100 / examQuestionIds.length);
    if (Number(currentExamRecords[0].score) !== expectedExamScore) {
      throw new Error("Exam score did not use the full question count");
    }
    if (
      !Array.isArray(currentExamRecords[0].payload?.questions) ||
      currentExamRecords[0].payload.questions.length !== examQuestionIds.length
    ) {
      throw new Error("Exam record did not preserve its question snapshot");
    }
    if (otherSubjectId) {
      const otherExamRecords = await request<AnyRecord[]>(
        `/client/records?mode=exam&userId=${userId}&appKey=${appKey}&subjectId=${otherSubjectId}`,
      );
      if (otherExamRecords.length > 0) {
        throw new Error("Exam records leaked into another subject");
      }
    }
    report.subjectRecordIsolation = "practice and exam records scoped";

    const feedback = await request<AnyRecord>("/client/feedback", {
      method: "POST",
      body: JSON.stringify({
        userId,
        appKey,
        questionId: question.id,
        type: "smoke_question_error",
        content: "端到端冒烟：客户端提交题目纠错",
      }),
    });
    report.feedbackId = feedback.id;

    const users = await request<AnyRecord[]>("/admin/users");
    const adminUser = users.find((item) => item.id === userId);
    if (!adminUser)
      throw new Error("Admin users API did not return smoke user");
    report.adminUserCounts = adminUser._count;

    const detail = await request<AnyRecord>(`/admin/users/${userId}`);
    if ((detail.practiceRecords ?? []).length === 0) {
      throw new Error("Admin user detail did not include practice records");
    }
    report.practiceRecordVisible = true;

    const feedbackRows = await request<AnyRecord[]>("/admin/feedback");
    const adminFeedback = feedbackRows.find((item) => item.id === feedback.id);
    if (!adminFeedback)
      throw new Error("Admin feedback API did not return smoke feedback");
    if (!adminFeedback.question?.stemText) {
      throw new Error("Admin feedback did not include question context");
    }
    report.feedbackQuestionVisible = true;

    await request(`/admin/feedback/${feedback.id}`, {
      method: "PATCH",
      body: JSON.stringify({ status: "processing" }),
    });
    await request(`/admin/feedback/${feedback.id}`, {
      method: "PATCH",
      body: JSON.stringify({ status: "resolved" }),
    });
    report.feedbackStatusFlow = "open -> processing -> resolved";

    const deleteResponse = await request<AnyRecord>(
      `/client/records?mode=practice&userId=${userId}&appKey=${appKey}&subjectId=${subjectId}`,
      { method: "DELETE" },
    );
    report.deletedPracticeRecords = deleteResponse.deleted;
    const deleteExamResponse = await request<AnyRecord>(
      `/client/records?mode=exam&userId=${userId}&appKey=${appKey}&subjectId=${subjectId}`,
      { method: "DELETE" },
    );
    report.deletedExamRecords = deleteExamResponse.deleted;

    console.log(JSON.stringify({ ok: true, report }, null, 2));
  } finally {
    await cleanup();
    await prisma.$disconnect();
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${baseUrl}${path}`, {
    headers: { "content-type": "application/json" },
    ...init,
  });
  const text = await response.text();
  const data = text ? JSON.parse(text) : {};
  if (!response.ok) {
    throw new Error(
      `${init?.method ?? "GET"} ${path} failed: ${response.status} ${text}`,
    );
  }
  return data as T;
}

function firstQuestionLeaf(nodes: AnyRecord[]): AnyRecord | null {
  for (const node of nodes) {
    if (
      (node.children ?? []).length === 0 &&
      Number(node.questionCount ?? 0) > 0
    ) {
      return node;
    }
    const child = firstQuestionLeaf(node.children ?? []);
    if (child) return child;
  }
  return null;
}

function findNodeById(nodes: AnyRecord[], nodeId: string): AnyRecord | null {
  for (const node of nodes) {
    if (node.id === nodeId) return node;
    const child = findNodeById(node.children ?? [], nodeId);
    if (child) return child;
  }
  return null;
}

function answerPayload(question: AnyRecord) {
  const values = question.answer?.values;
  if (Array.isArray(values) && values.length > 0) {
    return { values: values.map(String) };
  }
  return { text: "codex smoke answer" };
}

function wrongAnswerPayload(question: AnyRecord) {
  const values = question.answer?.values;
  const options = Array.isArray(question.options) ? question.options : [];
  if (!Array.isArray(values) || values.length === 0 || options.length < 2) {
    return null;
  }
  const correct = new Set(
    values.map((item: unknown) => String(item).toUpperCase()),
  );
  for (let index = 0; index < options.length; index += 1) {
    const key = String.fromCharCode(65 + index);
    if (!correct.has(key)) return { values: [key] };
  }
  return null;
}

function hasWrongQuestion(rows: AnyRecord[], questionId: string) {
  return rows.some((item) => (item.question?.id ?? item.id) === questionId);
}

async function cleanup() {
  await prisma.userFeedback.deleteMany({ where: { userId } });
  await prisma.user.deleteMany({ where: { id: userId } });
}

function loadEnv() {
  const envPath = join(process.cwd(), ".env");
  if (!existsSync(envPath)) return;
  const lines = readFileSync(envPath, "utf8").split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const index = trimmed.indexOf("=");
    if (index === -1) continue;
    const key = trimmed.slice(0, index).trim();
    const value = trimmed
      .slice(index + 1)
      .trim()
      .replace(/^['"]|['"]$/g, "");
    process.env[key] ??= value;
  }
}

main().catch(async (error) => {
  console.error(error);
  await cleanup().catch(() => undefined);
  await prisma.$disconnect();
  process.exit(1);
});
