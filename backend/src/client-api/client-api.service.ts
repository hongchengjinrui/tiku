import { Injectable, NotFoundException } from '@nestjs/common';
import {
  CatalogNode,
  CatalogNodeType,
  Prisma,
  QuestionType,
  StudyMode,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  asRecord,
  clientQuestionFromDb,
  evaluateChoiceAnswer,
  evaluateFillBlank,
  evaluateShortAnswer,
  stripHtml,
} from '../shared/question-utils';

const DEFAULT_DEV_USER_ID = 'dev-user-001';
const DEFAULT_APP_KEY = 'grid-exam-android';

type CatalogNodeWithChildren = CatalogNode & {
  children: CatalogNodeWithChildren[];
};

export type CatalogTreeItem = {
  id: string;
  type: CatalogNodeType;
  name: string;
  level: number;
  questionCount: number;
  sourcePath: string | null;
  progress: {
    done: number;
    correct: number;
    wrong: number;
    total: number;
    accuracy: number;
  };
  children: CatalogTreeItem[];
};

@Injectable()
export class ClientApiService {
  constructor(private readonly prisma: PrismaService) {}

  async bootstrap(appKey = DEFAULT_APP_KEY, userId = DEFAULT_DEV_USER_ID) {
    const app = await this.getApp(appKey);
    const user = await this.ensureDevUser(userId);
    const subjects = await this.prisma.subject.findMany({
      where: { bankId: app.bankId },
      orderBy: { sortOrder: 'asc' },
    });
    const defaultSubject =
      subjects.find((item) => item.id === user.defaultSubjectId) ??
      subjects.find((item) => item.isDefault) ??
      subjects[0];

    return {
      app: {
        appKey: app.appKey,
        name: app.name,
        platform: app.platform,
      },
      bank: app.bank,
      user: {
        id: user.id,
        nickname: user.nickname,
        defaultSubjectId: defaultSubject?.id ?? null,
      },
      subjects,
      defaultSubjectId: defaultSubject?.id ?? null,
      resources: await this.listResources(app.bankId),
      stats: defaultSubject
        ? await this.subjectStats(defaultSubject.id, user.id)
        : null,
    };
  }

  async listSubjects(appKey = DEFAULT_APP_KEY) {
    const app = await this.getApp(appKey);
    return this.prisma.subject.findMany({
      where: { bankId: app.bankId },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async setDefaultSubject(subjectId: string, userId = DEFAULT_DEV_USER_ID) {
    await this.ensureDevUser(userId);
    const subject = await this.prisma.subject.findUnique({
      where: { id: subjectId },
    });
    if (!subject) throw new NotFoundException('Subject not found');
    return this.prisma.user.update({
      where: { id: userId },
      data: { defaultSubjectId: subjectId },
    });
  }

  async subjectStats(subjectId: string, userId = DEFAULT_DEV_USER_ID) {
    await this.ensureDevUser(userId);
    const subject = await this.prisma.subject.findUnique({
      where: { id: subjectId },
      include: { bank: true },
    });
    if (!subject) throw new NotFoundException('Subject not found');

    const totals = await this.catalogTotals(subjectId);
    const progress = await this.prisma.userProgress.groupBy({
      by: ['mode'],
      where: {
        userId,
        catalog: { subjectId },
      },
      _sum: {
        done: true,
        correct: true,
        wrong: true,
        minutes: true,
      },
    });
    const wrongCount = await this.prisma.userWrongQuestion.count({
      where: {
        userId,
        active: true,
        question: { catalog: { subjectId } },
      },
    });

    const practice = progress.find((item) => item.mode === StudyMode.practice);
    const exam = progress.find((item) => item.mode === StudyMode.exam);

    return {
      subject: {
        id: subject.id,
        name: subject.name,
        isDefault: subject.isDefault,
      },
      practice: {
        done: practice?._sum.done ?? 0,
        total: totals.totalQuestions,
        correct: practice?._sum.correct ?? 0,
        wrong: wrongCount,
        accuracy: rate(practice?._sum.correct ?? 0, practice?._sum.done ?? 0),
        todayAdded: practice?._sum.done ?? 0,
        accumulatedDays: practice?._sum.done ? 1 : 0,
      },
      exam: {
        done: exam?._sum.done ?? 0,
        total: totals.totalQuestions,
        correct: exam?._sum.correct ?? 0,
        wrong: exam?._sum.wrong ?? 0,
        accuracy: rate(exam?._sum.correct ?? 0, exam?._sum.done ?? 0),
        todayAdded: exam?._sum.done ?? 0,
        accumulatedDays: exam?._sum.done ? 1 : 0,
        examCount: await this.prisma.examRecord.count({ where: { userId } }),
      },
      catalog: totals,
    };
  }

  async catalogTree(
    subjectId: string,
    userId = DEFAULT_DEV_USER_ID,
    mode: StudyMode = StudyMode.practice,
  ) {
    await this.ensureDevUser(userId);
    const subject = await this.prisma.subject.findUnique({
      where: { id: subjectId },
    });
    if (!subject) throw new NotFoundException('Subject not found');

    const roots = await this.prisma.catalogNode.findMany({
      where: { subjectId, parentId: null },
      orderBy: { sortOrder: 'asc' },
      include: {
        children: {
          orderBy: { sortOrder: 'asc' },
          include: {
            children: {
              orderBy: { sortOrder: 'asc' },
              include: {
                children: { orderBy: { sortOrder: 'asc' } },
              },
            },
          },
        },
      },
    });
    const progressRows = await this.prisma.userProgress.findMany({
      where: {
        userId,
        mode,
        catalog: { subjectId },
      },
    });
    const progressByCatalog = new Map(
      progressRows.map((item) => [item.catalogId, item]),
    );

    return {
      subject,
      mode,
      nodes: roots.map((node) =>
        this.catalogNodeToTree(node as CatalogNodeWithChildren, progressByCatalog),
      ),
    };
  }

  async listQuestions(catalogId: string, limit = 20, offset = 0) {
    const catalog = await this.prisma.catalogNode.findUnique({
      where: { id: catalogId },
    });
    if (!catalog) throw new NotFoundException('Catalog not found');

    const [total, questions] = await Promise.all([
      this.prisma.question.count({ where: { catalogId } }),
      this.prisma.question.findMany({
        where: { catalogId },
        orderBy: { sortOrder: 'asc' },
        take: Math.min(limit, 500),
        skip: offset,
      }),
    ]);

    return {
      catalog,
      total,
      questions: questions.map(clientQuestionFromDb),
    };
  }

  async startPractice(input: {
    catalogId?: string;
    questionIds?: string[];
    count?: number;
    mode?: 'practice' | 'exam';
  }) {
    const take = Math.max(1, Math.min(input.count ?? 20, 100));
    const where: Prisma.QuestionWhereInput = input.catalogId
      ? { catalogId: input.catalogId }
      : input.questionIds?.length
        ? { id: { in: input.questionIds } }
        : {};
    const questions = await this.prisma.question.findMany({
      where,
      orderBy: { sortOrder: 'asc' },
      take,
    });

    return {
      sessionId: `local-${Date.now()}`,
      mode: input.mode ?? 'practice',
      questions: questions.map(clientQuestionFromDb),
      total: questions.length,
    };
  }

  async startRandomPractice(input: {
    subjectId: string;
    catalogIds?: string[];
    count?: number;
  }) {
    const take = Math.max(1, Math.min(input.count ?? 20, 100));
    const where: Prisma.QuestionWhereInput = input.catalogIds?.length
      ? { catalogId: { in: input.catalogIds } }
      : { catalog: { subjectId: input.subjectId } };
    const pool = await this.prisma.question.findMany({
      where,
      select: { id: true },
      take: 500,
    });
    const ids = shuffle(pool.map((item) => item.id)).slice(0, take);
    return this.startPractice({ questionIds: ids, count: take });
  }

  async submitAnswer(input: {
    userId?: string;
    appKey?: string;
    questionId: string;
    catalogId?: string;
    mode?: StudyMode;
    values?: string[];
    text?: string;
    actualScore?: number;
  }) {
    const userId = input.userId ?? DEFAULT_DEV_USER_ID;
    const mode = input.mode ?? StudyMode.practice;
    await this.ensureDevUser(userId);

    const question = await this.prisma.question.findUnique({
      where: { id: input.questionId },
      include: { catalog: true },
    });
    if (!question) throw new NotFoundException('Question not found');

    const evaluation = this.evaluateQuestion(question, input);
    const isCorrect = evaluation.isCorrect;

    await this.prisma.userAnswer.create({
      data: {
        userId,
        questionId: question.id,
        mode,
        answer: {
          values: input.values ?? [],
          text: input.text ?? '',
        },
        isCorrect,
        score: evaluation.score,
        payload: evaluation as Prisma.InputJsonValue,
      },
    });

    await this.bumpProgress({
      userId,
      catalogId: question.catalogId,
      mode,
      done: 1,
      correct: isCorrect ? 1 : 0,
      wrong: isCorrect === false ? 1 : 0,
    });

    if (mode === StudyMode.practice) {
      await this.prisma.practiceRecord.create({
        data: {
          userId,
          appKey: input.appKey ?? DEFAULT_APP_KEY,
          questionId: question.id,
          questionTitle: stripHtml(String(asRecord(question.stem).text ?? '')),
          mode: question.catalog.name,
          correct: isCorrect,
          payload: evaluation as Prisma.InputJsonValue,
        },
      });
    }

    if (isCorrect === false) {
      await this.prisma.userWrongQuestion.upsert({
        where: {
          userId_questionId: {
            userId,
            questionId: question.id,
          },
        },
        update: {
          wrongCount: { increment: 1 },
          active: true,
          lastWrongAt: new Date(),
        },
        create: {
          userId,
          questionId: question.id,
          wrongCount: 1,
          active: true,
        },
      });
    }

    return {
      question: clientQuestionFromDb(question),
      ...evaluation,
    };
  }

  async submitExam(input: {
    userId?: string;
    appKey?: string;
    title: string;
    mode: string;
    answers: Array<{
      questionId: string;
      values?: string[];
      text?: string;
    }>;
    durationMinutes?: number;
  }) {
    const userId = input.userId ?? DEFAULT_DEV_USER_ID;
    await this.ensureDevUser(userId);
    const results = [];
    for (const answer of input.answers) {
      results.push(
        await this.submitAnswer({
          userId,
          appKey: input.appKey,
          questionId: answer.questionId,
          values: answer.values,
          text: answer.text,
          mode: StudyMode.exam,
        }),
      );
    }
    const correct = results.filter((item) => item.isCorrect).length;
    const score = input.answers.length === 0
      ? 0
      : Math.round((correct * 100) / input.answers.length);
    const record = await this.prisma.examRecord.create({
      data: {
        userId,
        appKey: input.appKey ?? DEFAULT_APP_KEY,
        title: input.title,
        mode: input.mode,
        score,
        accuracy: score,
        submitted: true,
        payload: {
          answers: input.answers,
          results,
          durationMinutes: input.durationMinutes ?? null,
        } as Prisma.InputJsonValue,
      },
    });

    return {
      record,
      score,
      accuracy: score,
      correct,
      total: input.answers.length,
      results,
    };
  }

  async listRecords(
    userId = DEFAULT_DEV_USER_ID,
    mode: 'practice' | 'exam',
    appKey = DEFAULT_APP_KEY,
  ) {
    await this.ensureDevUser(userId);
    if (mode === 'practice') {
      return this.prisma.practiceRecord.findMany({
        where: { userId, appKey },
        orderBy: { createdAt: 'desc' },
        take: 100,
      });
    }
    return this.prisma.examRecord.findMany({
      where: { userId, appKey },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  async deleteRecords(input: {
    userId?: string;
    appKey?: string;
    mode: 'practice' | 'exam';
    recordId?: string;
  }) {
    const userId = input.userId ?? DEFAULT_DEV_USER_ID;
    const appKey = input.appKey ?? DEFAULT_APP_KEY;
    await this.ensureDevUser(userId);
    if (input.mode === 'practice') {
      const result = await this.prisma.practiceRecord.deleteMany({
        where: { userId, appKey, ...(input.recordId ? { id: input.recordId } : {}) },
      });
      return { deleted: result.count };
    }
    const result = await this.prisma.examRecord.deleteMany({
      where: { userId, appKey, ...(input.recordId ? { id: input.recordId } : {}) },
    });
    return { deleted: result.count };
  }

  async toggleFavorite(userId = DEFAULT_DEV_USER_ID, questionId: string) {
    await this.ensureDevUser(userId);
    const existing = await this.prisma.userFavorite.findUnique({
      where: { userId_questionId: { userId, questionId } },
    });
    if (existing) {
      await this.prisma.userFavorite.delete({ where: { id: existing.id } });
      return { favorited: false };
    }
    await this.prisma.userFavorite.create({ data: { userId, questionId } });
    return { favorited: true };
  }

  async listFavorites(userId = DEFAULT_DEV_USER_ID, limit = 50, subjectId?: string) {
    await this.ensureDevUser(userId);
    const rows = await this.prisma.userFavorite.findMany({
      where: {
        userId,
        ...(subjectId ? { question: { catalog: { subjectId } } } : {}),
      },
      include: { question: true },
      orderBy: { createdAt: 'desc' },
      take: Math.min(limit, 100),
    });
    return rows.map((item) => clientQuestionFromDb(item.question));
  }

  async listWrongQuestions(userId = DEFAULT_DEV_USER_ID, limit = 50, subjectId?: string) {
    await this.ensureDevUser(userId);
    const rows = await this.prisma.userWrongQuestion.findMany({
      where: {
        userId,
        active: true,
        ...(subjectId ? { question: { catalog: { subjectId } } } : {}),
      },
      include: { question: true },
      orderBy: { lastWrongAt: 'desc' },
      take: Math.min(limit, 100),
    });
    return rows.map((item) => ({
      wrongCount: item.wrongCount,
      lastWrongAt: item.lastWrongAt,
      question: clientQuestionFromDb(item.question),
    }));
  }

  async removeWrongQuestion(userId = DEFAULT_DEV_USER_ID, questionId: string) {
    await this.ensureDevUser(userId);
    const result = await this.prisma.userWrongQuestion.updateMany({
      where: {
        userId,
        questionId,
        active: true,
      },
      data: {
        active: false,
      },
    });
    return { removed: result.count };
  }

  async clearWrongQuestions(input: {
    userId?: string;
    questionIds?: string[];
    subjectId?: string;
  }) {
    const userId = input.userId ?? DEFAULT_DEV_USER_ID;
    await this.ensureDevUser(userId);
    const questionIds = [...new Set(input.questionIds ?? [])].filter(Boolean);
    const result = await this.prisma.userWrongQuestion.updateMany({
      where: {
        userId,
        active: true,
        ...(questionIds.length > 0 ? { questionId: { in: questionIds } } : {}),
        ...(questionIds.length === 0 && input.subjectId
          ? { question: { catalog: { subjectId: input.subjectId } } }
          : {}),
      },
      data: {
        active: false,
      },
    });
    return { removed: result.count };
  }

  async resetProgress(input: {
    userId?: string;
    appKey?: string;
    mode?: StudyMode;
    catalogIds: string[];
  }) {
    const userId = input.userId ?? DEFAULT_DEV_USER_ID;
    const appKey = input.appKey ?? DEFAULT_APP_KEY;
    const mode = input.mode ?? StudyMode.practice;
    await this.ensureDevUser(userId);
    const descendantIds = await this.collectDescendantCatalogIds(input.catalogIds);
    const ids = [...new Set([...input.catalogIds, ...descendantIds])];
    const questionIds = (
      await this.prisma.question.findMany({
        where: { catalogId: { in: ids } },
        select: { id: true },
      })
    ).map((item) => item.id);

    const [progress, answers, wrongQuestions, practiceRecords] = await this.prisma.$transaction([
      this.prisma.userProgress.deleteMany({
        where: {
          userId,
          catalogId: { in: ids },
          mode,
        },
      }),
      this.prisma.userAnswer.deleteMany({
        where: {
          userId,
          mode,
          questionId: { in: questionIds },
        },
      }),
      mode === StudyMode.practice
        ? this.prisma.userWrongQuestion.updateMany({
            where: {
              userId,
              active: true,
              questionId: { in: questionIds },
            },
            data: { active: false },
          })
        : this.prisma.userWrongQuestion.updateMany({
            where: { id: { in: [] } },
            data: { active: false },
          }),
      mode === StudyMode.practice
        ? this.prisma.practiceRecord.deleteMany({
            where: {
              userId,
              appKey,
              questionId: { in: questionIds },
            },
          })
        : this.prisma.practiceRecord.deleteMany({
            where: { id: { in: [] } },
          }),
    ]);

    return {
      resetCatalogIds: ids,
      resetQuestionCount: questionIds.length,
      deletedProgressCount: progress.count,
      deletedAnswerCount: answers.count,
      closedWrongQuestionCount: wrongQuestions.count,
      deletedPracticeRecordCount: practiceRecords.count,
    };
  }

  async submitFeedback(input: {
    userId?: string;
    appKey?: string;
    questionId?: string;
    type?: string;
    content: string;
    contact?: string;
    payload?: unknown;
  }) {
    const userId = input.userId ?? DEFAULT_DEV_USER_ID;
    await this.ensureDevUser(userId);
    return this.prisma.userFeedback.create({
      data: {
        userId,
        appKey: input.appKey ?? DEFAULT_APP_KEY,
        questionId: input.questionId,
        type: input.type ?? 'question_error',
        content: input.content.trim() || '用户提交了题目纠错',
        contact: input.contact,
        payload: (input.payload ?? {}) as Prisma.InputJsonValue,
      },
    });
  }

  async listResources(input?: string | { bankId?: string; appKey?: string }) {
    let bankId = typeof input === 'string' ? input : input?.bankId;
    if (!bankId && typeof input !== 'string' && input?.appKey) {
      const app = await this.getApp(input.appKey);
      bankId = app.bankId;
    }
    const where = bankId ? { bankId } : {};
    const rows = await this.prisma.materialResource.findMany({
      where,
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    return rows.map((item) => ({
      ...item,
      unlocked: true,
      pages: asRecord(item.previewMeta).pages ?? [],
    }));
  }

  private async getApp(appKey: string) {
    const app = await this.prisma.app.findUnique({
      where: { appKey },
      include: { bank: true },
    });
    if (app) return app;

    const fallback = await this.prisma.app.findFirst({
      where: { isActive: true },
      include: { bank: true },
      orderBy: { createdAt: 'asc' },
    });
    if (!fallback) throw new NotFoundException('App not seeded');
    return fallback;
  }

  private async ensureDevUser(userId: string) {
    return this.prisma.user.upsert({
      where: { id: userId },
      update: {},
      create: {
        id: userId,
        nickname: '本地测试用户',
        isDev: true,
      },
    });
  }

  private async catalogTotals(subjectId: string) {
    const nodes = await this.prisma.catalogNode.findMany({
      where: { subjectId },
      select: { id: true, type: true, questionCount: true, parentId: true, name: true },
    });
    const leafNodes = nodes.filter(
      (item) =>
        item.type === CatalogNodeType.section ||
        item.type === CatalogNodeType.paper,
    );
    return {
      totalQuestions: leafNodes.reduce((sum, item) => sum + item.questionCount, 0),
      categoryCount: nodes.filter((item) => item.parentId === null).length,
      chapterCount: nodes.filter((item) => item.type === CatalogNodeType.chapter).length,
      leafCount: leafNodes.length,
      practiceQuestions: leafNodes
        .filter((item) => !item.name.includes('试卷'))
        .reduce((sum, item) => sum + item.questionCount, 0),
    };
  }

  private catalogNodeToTree(
    node: CatalogNodeWithChildren,
    progressByCatalog: Map<string, { done: number; correct: number; wrong: number }>,
  ): CatalogTreeItem {
    const children = node.children ?? [];
    const childTrees: CatalogTreeItem[] = children.map((child) =>
      this.catalogNodeToTree(child, progressByCatalog),
    );
    const childDone = childTrees.reduce((sum, child) => sum + child.progress.done, 0);
    const childCorrect = childTrees.reduce(
      (sum, child) => sum + child.progress.correct,
      0,
    );
    const childWrong = childTrees.reduce((sum, child) => sum + child.progress.wrong, 0);
    const self = progressByCatalog.get(node.id);
    const done = self?.done ?? childDone;
    const correct = self?.correct ?? childCorrect;
    const wrong = self?.wrong ?? childWrong;

    return {
      id: node.id,
      type: node.type,
      name: node.name,
      level: node.level,
      questionCount: node.questionCount,
      sourcePath: node.sourcePath,
      progress: {
        done,
        correct,
        wrong,
        total: node.questionCount,
        accuracy: rate(correct, done),
      },
      children: childTrees,
    };
  }

  private evaluateQuestion(
    question: {
      type: QuestionType;
      answer: unknown;
      scoringRubric: unknown;
    },
    input: { values?: string[]; text?: string; actualScore?: number },
  ) {
    if (
      question.type === QuestionType.single_choice ||
      question.type === QuestionType.multiple_choice ||
      question.type === QuestionType.true_false
    ) {
      const isCorrect = evaluateChoiceAnswer(question.answer, input.values ?? []);
      return {
        isCorrect,
        score: isCorrect ? 100 : 0,
        shortAnswer: null,
      };
    }
    if (question.type === QuestionType.fill_blank) {
      const isCorrect = evaluateFillBlank(question.answer, input.text ?? '');
      return {
        isCorrect,
        score: isCorrect ? 100 : 0,
        shortAnswer: null,
      };
    }
    if (question.type === QuestionType.short_answer) {
      const result = evaluateShortAnswer(
        question.scoringRubric,
        question.answer,
        input.text ?? '',
        input.actualScore ?? this.shortAnswerActualScore(question.scoringRubric),
      );
      return {
        isCorrect: result.actualScore / result.questionActualScore >= 0.6,
        score: result.actualScore,
        shortAnswer: result,
      };
    }
    return {
      isCorrect: null,
      score: null,
      shortAnswer: null,
    };
  }

  private async bumpProgress(input: {
    userId: string;
    catalogId: string;
    mode: StudyMode;
    done: number;
    correct: number;
    wrong: number;
  }) {
    await this.prisma.userProgress.upsert({
      where: {
        userId_catalogId_mode: {
          userId: input.userId,
          catalogId: input.catalogId,
          mode: input.mode,
        },
      },
      update: {
        done: { increment: input.done },
        correct: { increment: input.correct },
        wrong: { increment: input.wrong },
        lastStudiedAt: new Date(),
      },
      create: {
        userId: input.userId,
        catalogId: input.catalogId,
        mode: input.mode,
        done: input.done,
        correct: input.correct,
        wrong: input.wrong,
        lastStudiedAt: new Date(),
      },
    });
  }

  private shortAnswerActualScore(scoringRubric: unknown) {
    const rubric = asRecord(scoringRubric);
    const maxPoints = Number(rubric.max_points ?? rubric.base_score);
    return Number.isFinite(maxPoints) && maxPoints > 0 ? maxPoints : 100;
  }

  private async collectDescendantCatalogIds(catalogIds: string[]) {
    const all: string[] = [];
    let current = catalogIds;
    while (current.length > 0) {
      const children = await this.prisma.catalogNode.findMany({
        where: { parentId: { in: current } },
        select: { id: true },
      });
      current = children.map((item) => item.id);
      all.push(...current);
    }
    return all;
  }
}

function rate(correct: number, total: number) {
  return total === 0 ? 0 : Math.round((correct * 100) / total);
}

function shuffle<T>(items: T[]) {
  const output = [...items];
  for (let index = output.length - 1; index > 0; index -= 1) {
    const target = Math.floor(Math.random() * (index + 1));
    [output[index], output[target]] = [output[target], output[index]];
  }
  return output;
}
