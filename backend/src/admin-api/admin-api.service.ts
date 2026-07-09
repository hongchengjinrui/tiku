import { Injectable, NotFoundException } from '@nestjs/common';
import {
  AiProviderStatus,
  AppPlatform,
  CatalogNodeType,
  MaterialAccessType,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { clientQuestionFromDb } from '../shared/question-utils';

@Injectable()
export class AdminApiService {
  constructor(private readonly prisma: PrismaService) {}

  async dashboard() {
    const [
      bankCount,
      subjectCount,
      catalogCount,
      questionCount,
      userCount,
      feedbackOpenCount,
      materialsCount,
      appMetrics,
      salesMetrics,
    ] = await Promise.all([
      this.prisma.questionBank.count(),
      this.prisma.subject.count(),
      this.prisma.catalogNode.count(),
      this.prisma.question.count(),
      this.prisma.user.count(),
      this.prisma.userFeedback.count({ where: { status: 'open' } }),
      this.prisma.materialResource.count(),
      this.prisma.appDailyMetric.findMany({
        orderBy: { day: 'desc' },
        take: 14,
        include: { app: true },
      }),
      this.prisma.salesDailyMetric.findMany({
        orderBy: { day: 'desc' },
        take: 14,
        include: { app: true },
      }),
    ]);

    return {
      totals: {
        bankCount,
        subjectCount,
        catalogCount,
        questionCount,
        userCount,
        feedbackOpenCount,
        materialsCount,
      },
      appMetrics,
      salesMetrics,
    };
  }

  async listBanks() {
    return this.prisma.questionBank.findMany({
      orderBy: { createdAt: 'asc' },
      include: {
        subjects: {
          orderBy: { sortOrder: 'asc' },
          select: { id: true, name: true, sortOrder: true, isDefault: true },
        },
        apps: true,
        _count: {
          select: { materials: true },
        },
      },
    });
  }

  async getBank(bankId: string) {
    const bank = await this.prisma.questionBank.findUnique({
      where: { id: bankId },
      include: {
        subjects: {
          orderBy: { sortOrder: 'asc' },
        },
        apps: true,
        materials: {
          orderBy: { sortOrder: 'asc' },
        },
      },
    });
    if (!bank) throw new NotFoundException('Bank not found');
    return bank;
  }

  async catalogTree(bankId: string, subjectId?: string) {
    const subjects = await this.prisma.subject.findMany({
      where: { bankId, id: subjectId },
      orderBy: { sortOrder: 'asc' },
      include: {
        catalogs: {
          where: { parentId: null },
          orderBy: { sortOrder: 'asc' },
          include: {
            children: {
              orderBy: { sortOrder: 'asc' },
              include: {
                children: {
                  orderBy: { sortOrder: 'asc' },
                  include: { children: { orderBy: { sortOrder: 'asc' } } },
                },
              },
            },
          },
        },
      },
    });
    return subjects;
  }

  async listQuestions(query: {
    bankId?: string;
    subjectId?: string;
    catalogId?: string;
    type?: string;
    keyword?: string;
    page?: number;
    pageSize?: number;
  }) {
    const page = Math.max(1, query.page ?? 1);
    const pageSize = Math.max(1, Math.min(query.pageSize ?? 20, 100));
    const where: Prisma.QuestionWhereInput = {
      catalogId: query.catalogId,
      type: query.type as never,
      catalog: {
        subjectId: query.subjectId,
        subject: {
          bankId: query.bankId,
        },
      },
    };
    const [total, questions] = await Promise.all([
      this.prisma.question.count({ where }),
      this.prisma.question.findMany({
        where,
        orderBy: [{ catalogId: 'asc' }, { sortOrder: 'asc' }],
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          catalog: {
            include: {
              parent: {
                include: { parent: true },
              },
              subject: {
                include: { bank: true },
              },
            },
          },
        },
      }),
    ]);

    const keyword = query.keyword?.trim();
    const items = questions
      .map((question) => ({
        ...clientQuestionFromDb(question),
        catalog: question.catalog,
        catalogPath: this.catalogPath(question.catalog),
      }))
      .filter((question) =>
        keyword ? question.stemText.includes(keyword) : true,
      );

    return {
      page,
      pageSize,
      total,
      items,
    };
  }

  async updateQuestion(
    questionId: string,
    data: {
      stemText?: string;
      stemHtml?: string;
      analysisText?: string;
      analysisHtml?: string;
      answer?: unknown;
      options?: unknown;
    },
  ) {
    const existing = await this.prisma.question.findUnique({
      where: { id: questionId },
    });
    if (!existing) throw new NotFoundException('Question not found');
    return this.prisma.question.update({
      where: { id: questionId },
      data: {
        stem: data.stemHtml || data.stemText
          ? {
              ...(existing.stem as object),
              ...(data.stemHtml ? { html: data.stemHtml } : {}),
              ...(data.stemText ? { text: data.stemText } : {}),
            }
          : undefined,
        analysis: data.analysisHtml || data.analysisText
          ? {
              ...((existing.analysis as object) ?? {}),
              ...(data.analysisHtml ? { html: data.analysisHtml } : {}),
              ...(data.analysisText ? { text: data.analysisText } : {}),
            }
          : undefined,
        answer: data.answer as Prisma.InputJsonValue | undefined,
        options: data.options as Prisma.InputJsonValue | undefined,
      },
    });
  }

  async listUsers() {
    const users = await this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      take: 200,
      include: {
        _count: {
          select: {
            practiceRecords: true,
            examRecords: true,
            favorites: true,
            wrongQuestions: true,
          },
        },
      },
    });
    const subjectIds = users
      .map((user) => user.defaultSubjectId)
      .filter((id): id is string => Boolean(id));
    const subjects = subjectIds.length
      ? await this.prisma.subject.findMany({
          where: { id: { in: subjectIds } },
          select: { id: true, name: true },
        })
      : [];
    const subjectById = new Map(subjects.map((item) => [item.id, item.name]));
    return users.map((user) => ({
      ...user,
      defaultSubjectName: user.defaultSubjectId
        ? subjectById.get(user.defaultSubjectId) ?? null
        : null,
    }));
  }

  async getUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        _count: {
          select: {
            practiceRecords: true,
            examRecords: true,
            favorites: true,
            wrongQuestions: true,
            feedbacks: true,
          },
        },
      },
    });
    if (!user) throw new NotFoundException('User not found');
    const [practiceRecords, examRecords, feedbacks] = await Promise.all([
      this.prisma.practiceRecord.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 20,
      }),
      this.prisma.examRecord.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 20,
      }),
      this.prisma.userFeedback.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 20,
      }),
    ]);
    const questionIds = [
      ...practiceRecords.map((item) => item.questionId),
      ...feedbacks.map((item) => item.questionId).filter(Boolean),
    ].filter((id): id is string => Boolean(id));
    const questionById = await this.questionMap(questionIds);
    return {
      user,
      practiceRecords: practiceRecords.map((record) => ({
        ...record,
        question: questionById.get(record.questionId) ?? null,
      })),
      examRecords,
      feedbacks: feedbacks.map((record) => ({
        ...record,
        question: record.questionId
          ? questionById.get(record.questionId) ?? null
          : null,
      })),
    };
  }

  async listMaterials(bankId?: string) {
    return this.prisma.materialResource.findMany({
      where: { bankId },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
      include: { bank: true },
    });
  }

  async createMaterial(data: {
    bankId: string;
    title: string;
    subjectName?: string;
    description?: string;
    accessType?: MaterialAccessType;
    coverUrl?: string;
    fileUrl?: string;
    fileType?: string;
    previewMeta?: unknown;
    sortOrder?: number;
  }) {
    return this.prisma.materialResource.create({
      data: {
        bankId: data.bankId,
        title: data.title,
        subjectName: data.subjectName,
        description: data.description,
        accessType: data.accessType ?? MaterialAccessType.free,
        coverUrl: data.coverUrl,
        fileUrl: data.fileUrl,
        fileType: data.fileType,
        sortOrder: data.sortOrder ?? 0,
        previewMeta: (data.previewMeta ?? {
          pages: [
            '资料正文第一页：本地开发阶段用于在线预览。',
            '资料正文第二页：后续可接入 PDF/Word 解析与对象存储。',
          ],
        }) as Prisma.InputJsonValue,
      },
    });
  }

  async updateMaterial(
    id: string,
    data: Partial<{
      title: string;
      subjectName: string;
      description: string;
      accessType: MaterialAccessType;
      coverUrl: string;
      fileUrl: string;
      fileType: string;
      previewMeta: unknown;
      sortOrder: number;
    }>,
  ) {
    return this.prisma.materialResource.update({
      where: { id },
      data: {
        ...data,
        previewMeta: data.previewMeta as Prisma.InputJsonValue | undefined,
      },
    });
  }

  async deleteMaterial(id: string) {
    await this.prisma.materialResource.delete({ where: { id } });
    return { deleted: true };
  }

  async listFeedback(status?: string) {
    const rows = await this.prisma.userFeedback.findMany({
      where: { status: status as never },
      orderBy: { createdAt: 'desc' },
      take: 200,
      include: { user: true },
    });
    const questionIds = rows
      .map((item) => item.questionId)
      .filter((id): id is string => Boolean(id));
    const questionById = await this.questionMap(questionIds);
    return rows.map((item) => ({
      ...item,
      question: item.questionId
        ? questionById.get(item.questionId) ?? null
        : null,
    }));
  }

  async updateFeedback(id: string, status: string) {
    return this.prisma.userFeedback.update({
      where: { id },
      data: { status: status as never },
    });
  }

  async listAiModels() {
    return this.prisma.aiModelConfig.findMany({
      orderBy: [{ status: 'asc' }, { createdAt: 'desc' }],
    });
  }

  async createAiModel(data: {
    name: string;
    provider: string;
    model: string;
    endpoint?: string;
    apiKeyAlias?: string;
    status?: AiProviderStatus;
    config?: unknown;
  }) {
    return this.prisma.aiModelConfig.create({
      data: {
        name: data.name,
        provider: data.provider,
        model: data.model,
        endpoint: data.endpoint,
        apiKeyAlias: data.apiKeyAlias,
        status: data.status ?? AiProviderStatus.disabled,
        config: (data.config ?? {}) as Prisma.InputJsonValue,
      },
    });
  }

  async updateAiModel(
    id: string,
    data: Partial<{
      name: string;
      provider: string;
      model: string;
      endpoint: string;
      apiKeyAlias: string;
      status: AiProviderStatus;
      config: unknown;
    }>,
  ) {
    return this.prisma.aiModelConfig.update({
      where: { id },
      data: {
        ...data,
        config: data.config as Prisma.InputJsonValue | undefined,
      },
    });
  }

  async deleteAiModel(id: string) {
    await this.prisma.aiModelConfig.delete({ where: { id } });
    return { deleted: true };
  }

  async upsertApp(data: {
    appKey: string;
    name: string;
    platform: AppPlatform;
    packageName?: string;
    bankId: string;
  }) {
    return this.prisma.app.upsert({
      where: { appKey: data.appKey },
      update: data,
      create: data,
    });
  }

  async listApps() {
    return this.prisma.app.findMany({
      include: { bank: true },
      orderBy: { createdAt: 'asc' },
    });
  }

  async createFeedback(data: {
    userId?: string;
    appKey?: string;
    questionId?: string;
    type: string;
    content: string;
    contact?: string;
  }) {
    return this.prisma.userFeedback.create({
      data: {
        ...data,
        payload: {},
      },
    });
  }

  async catalogSummary(bankId: string) {
    const rows = await this.prisma.catalogNode.groupBy({
      by: ['type'],
      where: { subject: { bankId } },
      _count: { _all: true },
      _sum: { questionCount: true },
    });
    const byType = Object.fromEntries(
      rows.map((item) => [
        item.type,
        {
          count: item._count._all,
          questionCount: item._sum.questionCount ?? 0,
        },
      ]),
    );
    return {
      category: byType[CatalogNodeType.category] ?? { count: 0, questionCount: 0 },
      chapter: byType[CatalogNodeType.chapter] ?? { count: 0, questionCount: 0 },
      section: byType[CatalogNodeType.section] ?? { count: 0, questionCount: 0 },
      paper: byType[CatalogNodeType.paper] ?? { count: 0, questionCount: 0 },
    };
  }

  private async questionMap(questionIds: string[]) {
    const uniqueIds = [...new Set(questionIds)];
    if (uniqueIds.length === 0) return new Map<string, unknown>();
    const rows = await this.prisma.question.findMany({
      where: { id: { in: uniqueIds } },
      include: {
        catalog: {
          include: {
            parent: {
              include: { parent: true },
            },
            subject: {
              include: { bank: true },
            },
          },
        },
      },
    });
    return new Map(
      rows.map((question) => [
        question.id,
        {
          ...clientQuestionFromDb(question),
          catalog: question.catalog,
          catalogPath: this.catalogPath(question.catalog),
        },
      ]),
    );
  }

  private catalogPath(
    catalog: {
      name: string;
      subject?: { name: string; bank?: { name: string } } | null;
      parent?: {
        name: string;
        parent?: { name: string } | null;
      } | null;
    },
  ) {
    return [
      catalog.subject?.bank?.name,
      catalog.subject?.name,
      catalog.parent?.parent?.name,
      catalog.parent?.name,
      catalog.name,
    ]
      .filter(Boolean)
      .join(' / ');
  }
}
