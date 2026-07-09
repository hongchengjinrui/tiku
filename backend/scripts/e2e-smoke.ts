import { PrismaClient } from '@prisma/client';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

loadEnv();
const prisma = new PrismaClient();

const baseUrl = process.env.API_BASE_URL ?? 'http://localhost:3000/api';
const appKey = process.env.APP_KEY ?? 'south-grid-android';
const userId = process.env.SMOKE_USER_ID ?? `codex-e2e-${Date.now()}`;

type AnyRecord = Record<string, any>;

async function main() {
  const report: AnyRecord = { userId, appKey };
  try {
    const bootstrap = await request<AnyRecord>(
      `/client/bootstrap?appKey=${appKey}&userId=${userId}`,
    );
    const subjectId = bootstrap.defaultSubjectId;
    if (!subjectId) throw new Error('No default subject returned by bootstrap');
    report.subject = bootstrap.subjects?.find((item: AnyRecord) => item.id === subjectId)?.name;

    const catalog = await request<AnyRecord>(
      `/client/subjects/${subjectId}/catalog?userId=${userId}&mode=practice`,
    );
    const leaf = firstQuestionLeaf(catalog.nodes ?? []);
    if (!leaf) throw new Error('No practice catalog leaf with questions found');
    report.catalog = leaf.name;

    const questionResponse = await request<AnyRecord>(
      `/client/catalogs/${leaf.id}/questions?limit=1`,
    );
    const question = questionResponse.questions?.[0];
    if (!question) throw new Error('No question returned from selected leaf');
    report.questionId = question.id;

    await request('/client/answers', {
      method: 'POST',
      body: JSON.stringify({
        userId,
        appKey,
        questionId: question.id,
        mode: 'practice',
        ...answerPayload(question),
      }),
    });

    const feedback = await request<AnyRecord>('/client/feedback', {
      method: 'POST',
      body: JSON.stringify({
        userId,
        appKey,
        questionId: question.id,
        type: 'smoke_question_error',
        content: '端到端冒烟：客户端提交题目纠错',
      }),
    });
    report.feedbackId = feedback.id;

    const users = await request<AnyRecord[]>('/admin/users');
    const adminUser = users.find((item) => item.id === userId);
    if (!adminUser) throw new Error('Admin users API did not return smoke user');
    report.adminUserCounts = adminUser._count;

    const detail = await request<AnyRecord>(`/admin/users/${userId}`);
    if ((detail.practiceRecords ?? []).length === 0) {
      throw new Error('Admin user detail did not include practice records');
    }
    report.practiceRecordVisible = true;

    const feedbackRows = await request<AnyRecord[]>('/admin/feedback');
    const adminFeedback = feedbackRows.find((item) => item.id === feedback.id);
    if (!adminFeedback) throw new Error('Admin feedback API did not return smoke feedback');
    if (!adminFeedback.question?.stemText) {
      throw new Error('Admin feedback did not include question context');
    }
    report.feedbackQuestionVisible = true;

    await request(`/admin/feedback/${feedback.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ status: 'processing' }),
    });
    await request(`/admin/feedback/${feedback.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ status: 'resolved' }),
    });
    report.feedbackStatusFlow = 'open -> processing -> resolved';

    const deleteResponse = await request<AnyRecord>(
      `/client/records?mode=practice&userId=${userId}&appKey=${appKey}`,
      { method: 'DELETE' },
    );
    report.deletedPracticeRecords = deleteResponse.deleted;

    console.log(JSON.stringify({ ok: true, report }, null, 2));
  } finally {
    await cleanup();
    await prisma.$disconnect();
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${baseUrl}${path}`, {
    headers: { 'content-type': 'application/json' },
    ...init,
  });
  const text = await response.text();
  const data = text ? JSON.parse(text) : {};
  if (!response.ok) {
    throw new Error(`${init?.method ?? 'GET'} ${path} failed: ${response.status} ${text}`);
  }
  return data as T;
}

function firstQuestionLeaf(nodes: AnyRecord[]): AnyRecord | null {
  for (const node of nodes) {
    if ((node.children ?? []).length === 0 && Number(node.questionCount ?? 0) > 0) {
      return node;
    }
    const child = firstQuestionLeaf(node.children ?? []);
    if (child) return child;
  }
  return null;
}

function answerPayload(question: AnyRecord) {
  const values = question.answer?.values;
  if (Array.isArray(values) && values.length > 0) {
    return { values: values.map(String) };
  }
  return { text: 'codex smoke answer' };
}

async function cleanup() {
  await prisma.userFeedback.deleteMany({ where: { userId } });
  await prisma.user.deleteMany({ where: { id: userId } });
}

function loadEnv() {
  const envPath = join(process.cwd(), '.env');
  if (!existsSync(envPath)) return;
  const lines = readFileSync(envPath, 'utf8').split(/\r?\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const index = trimmed.indexOf('=');
    if (index === -1) continue;
    const key = trimmed.slice(0, index).trim();
    const value = trimmed.slice(index + 1).trim().replace(/^['"]|['"]$/g, '');
    process.env[key] ??= value;
  }
}

main().catch(async (error) => {
  console.error(error);
  await cleanup().catch(() => undefined);
  await prisma.$disconnect();
  process.exit(1);
});
