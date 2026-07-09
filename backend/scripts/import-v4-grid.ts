import { readFile } from 'node:fs/promises';
import path from 'node:path';
import {
  AppPlatform,
  CatalogNodeType,
  MaterialAccessType,
  Prisma,
  PrismaClient,
  QuestionType,
} from '@prisma/client';

process.env.DATABASE_URL ??=
  'postgresql://tiku:tiku_dev_password@localhost:5432/tiku_dev?schema=public';

const prisma = new PrismaClient();

const datasetRoot =
  process.env.V4_DATA_ROOT ??
  path.resolve(process.cwd(), '..', 'V4版题库_简答拆解');
const bankDir = process.env.V4_BANK_DIR ?? '电网刷题真题库';
const manifestPath = path.join(datasetRoot, bankDir, 'manifest.json');
const bankSlug = process.env.BANK_SLUG ?? defaultBankSlug(bankDir);
const appKeyPrefix = process.env.APP_KEY_PREFIX ?? bankSlug;
const appPackageSlug = bankSlug.replace(/[^a-zA-Z0-9_]/g, '_');
const defaultSubjectOverride =
  process.env.DEFAULT_SUBJECT ?? defaultSubjectName(bankDir);
const shouldResetBank = process.env.RESET_BANK !== 'false';

type Manifest = {
  system_title: string;
  sections: ManifestSection[];
};

type ManifestSection = {
  section_id?: string;
  section_name?: string;
  section_type?: string;
  question_count: number;
  path: string[];
  source_file: string;
};

type LeafFile = {
  section?: {
    bank?: string;
    subject?: string;
    category?: string;
    group?: string;
    leaf?: string;
    relative_file?: string;
  };
  items: RawQuestion[];
};

type RawQuestion = {
  id?: string;
  type?: string;
  legacy_type?: string;
  choice_mode?: string;
  stem?: unknown;
  options?: unknown;
  answer?: unknown;
  analysis?: unknown;
  source_ref?: unknown;
  scoring_rubric?: unknown;
  children?: RawQuestion[];
};

type ImportStats = {
  imported: number;
  typeCounts: Map<QuestionType, number>;
  sourceTypeCounts: Map<string, number>;
  legacyTypeCounts: Map<string, number>;
  unknownTypeHints: Map<string, number>;
};

async function main() {
  console.log(`Reading manifest: ${manifestPath}`);
  const manifest = JSON.parse(await readFile(manifestPath, 'utf8')) as Manifest;

  if (shouldResetBank) {
    console.log(`Resetting existing bank data: ${bankSlug}`);
    await prisma.questionBank.deleteMany({ where: { slug: bankSlug } });
  }

  const bank = await prisma.questionBank.create({
    data: {
      name: manifest.system_title,
      slug: bankSlug,
      version: 'v4-question-bank-v2.0',
      sourceRoot: datasetRoot,
      sourceManifest: manifestPath,
      questionCount: manifest.sections.reduce(
        (sum, item) => sum + item.question_count,
        0,
      ),
    },
  });

  const subjectNames = unique(manifest.sections.map((item) => item.path[0]));
  const subjectIdByName = new Map<string, string>();
  for (const [index, name] of subjectNames.entries()) {
    const subject = await prisma.subject.create({
      data: {
        bankId: bank.id,
        name,
        sortOrder: index,
        isDefault:
          name === defaultSubjectOverride ||
          (!defaultSubjectOverride && index === 0),
      },
    });
    subjectIdByName.set(name, subject.id);
  }

  const aggregateCounts = aggregateQuestionCounts(manifest.sections);
  const nodeIdByPath = new Map<string, string>();

  console.log(`Creating catalog tree for ${manifest.sections.length} leaves...`);
  for (const [index, section] of manifest.sections.entries()) {
    const [subjectName, categoryName, chapterName, leafName] = section.path;
    const subjectId = subjectIdByName.get(subjectName);
    if (!subjectId) throw new Error(`Unknown subject: ${subjectName}`);

    const categoryId = await ensureCatalogNode({
      subjectId,
      nodeIdByPath,
      pathParts: [subjectName, categoryName],
      parentId: null,
      type: CatalogNodeType.category,
      level: 2,
      name: categoryName,
      sortOrder: index,
      questionCount: aggregateCounts.get(pathKey([subjectName, categoryName])) ?? 0,
    });

    const chapterId = await ensureCatalogNode({
      subjectId,
      nodeIdByPath,
      pathParts: [subjectName, categoryName, chapterName],
      parentId: categoryId,
      type: CatalogNodeType.chapter,
      level: 3,
      name: chapterName,
      sortOrder: index,
      questionCount:
        aggregateCounts.get(pathKey([subjectName, categoryName, chapterName])) ?? 0,
    });

    await ensureCatalogNode({
      subjectId,
      nodeIdByPath,
      pathParts: section.path,
      parentId: chapterId,
      type:
        categoryName === '模拟真题'
          ? CatalogNodeType.paper
          : CatalogNodeType.section,
      level: 4,
      name: leafName,
      sortOrder: index,
      questionCount: section.question_count,
      sourceFile: section.source_file,
      sourceSectionId: section.section_id,
      sourcePath: section.path.join('/'),
    });
  }

  console.log('Importing questions...');
  const stats: ImportStats = {
    imported: 0,
    typeCounts: new Map(),
    sourceTypeCounts: new Map(),
    legacyTypeCounts: new Map(),
    unknownTypeHints: new Map(),
  };
  const questionBatch: Prisma.QuestionCreateManyInput[] = [];
  for (const section of manifest.sections) {
    const catalogId = nodeIdByPath.get(pathKey(section.path));
    if (!catalogId) throw new Error(`Missing catalog for ${section.path.join('/')}`);

    const filePath = path.join(datasetRoot, section.source_file);
    const leaf = JSON.parse(await readFile(filePath, 'utf8')) as LeafFile;
    for (const question of flattenQuestions(leaf.items)) {
      questionBatch.push(toQuestionCreateInput(question, catalogId, stats));
      stats.imported += 1;
      if (questionBatch.length >= 1000) {
        await flushQuestions(questionBatch);
      }
    }
  }
  await flushQuestions(questionBatch);

  await seedRuntimeData(bank.id, manifest.system_title);
  await printImportReport(bank.id, manifest.system_title, stats);
}

async function ensureCatalogNode(input: {
  subjectId: string;
  nodeIdByPath: Map<string, string>;
  pathParts: string[];
  parentId: string | null;
  type: CatalogNodeType;
  level: number;
  name: string;
  sortOrder: number;
  questionCount: number;
  sourceFile?: string;
  sourceSectionId?: string;
  sourcePath?: string;
}) {
  const key = pathKey(input.pathParts);
  const existing = input.nodeIdByPath.get(key);
  if (existing) return existing;

  const node = await prisma.catalogNode.create({
    data: {
      subjectId: input.subjectId,
      parentId: input.parentId,
      type: input.type,
      level: input.level,
      name: input.name,
      sortOrder: input.sortOrder,
      questionCount: input.questionCount,
      sourceFile: input.sourceFile,
      sourceSectionId: input.sourceSectionId,
      sourcePath: input.sourcePath ?? input.pathParts.join('/'),
    },
  });
  input.nodeIdByPath.set(key, node.id);
  return node.id;
}

function flattenQuestions(items: RawQuestion[]) {
  const output: RawQuestion[] = [];
  for (const item of items) {
    if (item.type === 'material') {
      const materialStem = item.stem;
      const children = item.children ?? [];
      children.forEach((child, childIndex) => {
        output.push({
          ...child,
          id: child.id ?? `${item.id ?? 'material'}_child_${childIndex + 1}`,
          stem: mergeMaterialStem(materialStem, child.stem),
          source_ref: {
            material_id: item.id,
            child_index: childIndex,
            child_source_ref: child.source_ref,
          },
        });
      });
    } else {
      output.push(item);
    }
  }
  return output;
}

function toQuestionCreateInput(
  question: RawQuestion,
  catalogId: string,
  stats: ImportStats,
): Prisma.QuestionCreateManyInput {
  const sourceQuestionId = question.id ?? `generated_${catalogId}_${stats.imported}`;
  const type = toQuestionType(question, stats);
  return {
    id: `${bankSlug}:${sourceQuestionId}`,
    catalogId,
    type,
    legacyType: question.legacy_type,
    choiceMode: question.choice_mode,
    stem: (question.stem ?? { html: '', text: '' }) as Prisma.InputJsonValue,
    options: (question.options ?? []) as Prisma.InputJsonValue,
    answer: (question.answer ?? {}) as Prisma.InputJsonValue,
    analysis: (question.analysis ?? {}) as Prisma.InputJsonValue,
    scoringRubric: question.scoring_rubric as Prisma.InputJsonValue | undefined,
    sourceRef: {
      ...(asRecord(question.source_ref) as Record<string, unknown>),
      source_question_id: sourceQuestionId,
      bank_slug: bankSlug,
    } as Prisma.InputJsonValue,
    rawPayload: question as Prisma.InputJsonValue,
    sortOrder: stats.imported,
  };
}

function toQuestionType(question: RawQuestion, stats: ImportStats): QuestionType {
  const type = question.type;
  increment(stats.sourceTypeCounts, type ?? '(missing)');
  increment(stats.legacyTypeCounts, question.legacy_type ?? '(missing)');

  if (type && Object.values(QuestionType).includes(type as QuestionType)) {
    const resolved = type as QuestionType;
    increment(stats.typeCounts, resolved);
    return resolved;
  }

  const legacyType = question.legacy_type ?? '';
  const choiceMode = question.choice_mode ?? '';
  const resolved =
    resolveQuestionTypeByLegacy(legacyType) ??
    resolveQuestionTypeByChoiceMode(choiceMode) ??
    QuestionType.single_choice;
  increment(
    stats.unknownTypeHints,
    `type=${type ?? '(missing)'} legacy=${legacyType || '(missing)'} choice=${
      choiceMode || '(missing)'
    } -> ${resolved}`,
  );
  increment(stats.typeCounts, resolved);
  return resolved;
}

function resolveQuestionTypeByLegacy(legacyType: string): QuestionType | null {
  if (legacyType.includes('多选') || legacyType.includes('不定项')) {
    return QuestionType.multiple_choice;
  }
  if (legacyType.includes('判断')) return QuestionType.true_false;
  if (legacyType.includes('填空')) return QuestionType.fill_blank;
  if (
    legacyType.includes('问答') ||
    legacyType.includes('简答') ||
    legacyType.includes('主观')
  ) {
    return QuestionType.short_answer;
  }
  if (legacyType.includes('材料')) return QuestionType.material;
  if (legacyType.includes('单选')) return QuestionType.single_choice;
  return null;
}

function resolveQuestionTypeByChoiceMode(choiceMode: string): QuestionType | null {
  if (choiceMode === 'multiple' || choiceMode === 'indefinite') {
    return QuestionType.multiple_choice;
  }
  if (choiceMode === 'true_false') return QuestionType.true_false;
  if (choiceMode === 'single') return QuestionType.single_choice;
  return null;
}

function mergeMaterialStem(materialStem: unknown, childStem: unknown) {
  const material = asRecord(materialStem);
  const child = asRecord(childStem);
  const materialHtml = String(material.html ?? '');
  const childHtml = String(child.html ?? '');
  const materialText = String(material.text ?? '');
  const childText = String(child.text ?? '');
  return {
    html: materialHtml
      ? `<div class="material-stem">${materialHtml}</div><hr/>${childHtml}`
      : childHtml,
    text: materialText ? `${materialText}\n${childText}` : childText,
    images: [
      ...toArray(material.images),
      ...toArray(child.images),
    ],
  };
}

async function flushQuestions(batch: Prisma.QuestionCreateManyInput[]) {
  if (batch.length === 0) return;
  await prisma.question.createMany({
    data: batch.splice(0, batch.length),
    skipDuplicates: true,
  });
}

async function seedRuntimeData(bankId: string, bankName: string) {
  const androidPackage =
    process.env.APP_PACKAGE_ANDROID ?? 'com.example.tiku_muban';
  await prisma.app.createMany({
    data: [
      {
        appKey: `${appKeyPrefix}-android`,
        name: `${bankName} Android`,
        platform: AppPlatform.android,
        packageName: androidPackage,
        bankId,
        config: { login: 'mock', payment: 'mock' },
      },
      {
        appKey: `${appKeyPrefix}-ios`,
        name: `${bankName} iOS`,
        platform: AppPlatform.ios,
        packageName:
          process.env.APP_PACKAGE_IOS ??
          `com.hongchengjinrui.tiku.${appPackageSlug}`,
        bankId,
        config: { login: 'mock', payment: 'mock' },
      },
      {
        appKey: `${appKeyPrefix}-harmonyos`,
        name: `${bankName} HarmonyOS`,
        platform: AppPlatform.harmonyos,
        packageName:
          process.env.APP_PACKAGE_HARMONYOS ??
          `com.hongchengjinrui.tiku.${appPackageSlug}`,
        bankId,
        config: { login: 'mock', payment: 'mock' },
      },
    ],
    skipDuplicates: true,
  });

  await prisma.user.upsert({
    where: { id: 'dev-user-001' },
    update: {},
    create: {
      id: 'dev-user-001',
      nickname: '本地测试用户',
      isDev: true,
    },
  });

  await prisma.materialResource.createMany({
    data: seedMaterials(bankId, bankName),
  });

  await seedAiModelConfig();

  const apps = await prisma.app.findMany({ where: { bankId } });
  const today = new Date();
  for (const app of apps) {
    for (let index = 0; index < 7; index += 1) {
      const day = new Date(today);
      day.setDate(today.getDate() - index);
      day.setHours(0, 0, 0, 0);
      await prisma.appDailyMetric.create({
        data: {
          appId: app.id,
          day,
          visits: 40 + index * 6,
          activeUsers: 12 + index * 2,
          practiceCount: 90 + index * 8,
          examCount: 8 + index,
        },
      });
      await prisma.salesDailyMetric.create({
        data: {
          appId: app.id,
          day,
          orders: index % 3,
          amountFen: (index % 3) * 990,
          refunds: 0,
        },
      });
    }
  }

  await prisma.userFeedback.create({
    data: {
      userId: 'dev-user-001',
      appKey: `${appKeyPrefix}-android`,
      type: 'question_error',
      content: '样例反馈：这道题解析中的年份可能需要复核。',
      contact: 'local-dev',
      payload: {},
    },
  });
}

function seedMaterials(
  bankId: string,
  bankName: string,
): Prisma.MaterialResourceCreateManyInput[] {
  const genericSubject = defaultSubjectOverride ?? '默认科目';
  return [
    material(bankId, `${bankName}备考导学资料`, genericSubject, 'free', 0),
    material(bankId, `${genericSubject}高频考点手册`, genericSubject, 'vip', 1),
    material(bankId, `${genericSubject}核心知识速记`, genericSubject, 'vip', 2),
    material(bankId, `${bankName}模拟冲刺讲义`, genericSubject, 'vip', 3),
    material(bankId, `${bankName}公式与易错点`, genericSubject, 'vip', 4),
    material(bankId, `${bankName}重点章节讲义`, genericSubject, 'vip', 5),
  ];
}

async function seedAiModelConfig() {
  await createAiModelConfigIfMissing({
    name: 'OpenAI 主模型',
    provider: 'openai',
    model: 'gpt-5',
    endpoint: 'https://api.openai.com/v1',
    apiKeyAlias: 'OPENAI_API_KEY',
    status: 'disabled',
    config: { usage: ['题目纠错', '题目生成', '解析优化'] },
  });
  await createAiModelConfigIfMissing({
    name: '国产模型备用入口',
    provider: 'custom-compatible',
    model: 'compatible-chat-model',
    endpoint: '',
    apiKeyAlias: 'CUSTOM_LLM_API_KEY',
    status: 'disabled',
    config: { usage: ['批量纠错', '简答题语义评分后续增强'] },
  });
}

async function createAiModelConfigIfMissing(
  data: Prisma.AiModelConfigCreateInput,
) {
  const existing = await prisma.aiModelConfig.findFirst({
    where: {
      name: data.name,
      provider: data.provider,
      model: data.model,
    },
  });
  if (!existing) await prisma.aiModelConfig.create({ data });
}

function material(
  bankId: string,
  title: string,
  subjectName: string,
  accessType: 'free' | 'vip',
  sortOrder: number,
): Prisma.MaterialResourceCreateManyInput {
  return {
    bankId,
    title,
    subjectName,
    description:
      accessType === 'free'
        ? '免费领取资料，本地开发阶段开放完整预览。'
        : 'VIP 备考资料，未接登录前本地开发阶段开放完整预览。',
    accessType:
      accessType === 'free' ? MaterialAccessType.free : MaterialAccessType.vip,
    coverUrl: '',
    fileUrl: `local://${title}`,
    fileType: 'pdf',
    sortOrder,
    previewMeta: {
      totalPages: 3,
      pages: [
        `${title} 第 1 页：核心知识导览。`,
        `${title} 第 2 页：高频考点整理。`,
        `${title} 第 3 页：练前复盘清单。`,
      ],
    },
  };
}

function aggregateQuestionCounts(sections: ManifestSection[]) {
  const output = new Map<string, number>();
  for (const section of sections) {
    for (let size = 2; size <= 4; size += 1) {
      const key = pathKey(section.path.slice(0, size));
      output.set(key, (output.get(key) ?? 0) + section.question_count);
    }
  }
  return output;
}

function pathKey(parts: string[]) {
  return parts.join('\u0000');
}

function unique(values: string[]) {
  return [...new Set(values)];
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : {};
}

function toArray(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

async function printImportReport(
  bankId: string,
  bankName: string,
  stats: ImportStats,
) {
  const dbCounts = await prisma.question.groupBy({
    by: ['type'],
    where: { catalog: { subject: { bankId } } },
    _count: { _all: true },
    orderBy: { type: 'asc' },
  });
  const subjectCounts = await prisma.subject.findMany({
    where: { bankId },
    select: {
      name: true,
      isDefault: true,
      catalogs: {
        where: {
          OR: [
            { type: CatalogNodeType.section },
            { type: CatalogNodeType.paper },
          ],
        },
        select: { questionCount: true },
      },
    },
    orderBy: { sortOrder: 'asc' },
  });

  console.log(`Imported ${stats.imported} questions into ${bankName}.`);
  console.log('Question type counts:', formatEntries(dbCounts.map((item) => [
    item.type,
    item._count._all,
  ])));
  console.log('Source type counts:', formatMap(stats.sourceTypeCounts));
  console.log('Legacy type counts:', formatMap(stats.legacyTypeCounts));
  if (stats.unknownTypeHints.size > 0) {
    console.warn('Unknown type fallbacks:', formatMap(stats.unknownTypeHints));
  }
  console.log(
    'Subject totals:',
    subjectCounts
      .map((subject) => {
        const total = subject.catalogs.reduce(
          (sum, catalog) => sum + catalog.questionCount,
          0,
        );
        return `${subject.name}${subject.isDefault ? '(default)' : ''}:${total}`;
      })
      .join(', '),
  );
}

function increment<T>(map: Map<T, number>, key: T) {
  map.set(key, (map.get(key) ?? 0) + 1);
}

function formatMap<T>(map: Map<T, number>) {
  return formatEntries([...map.entries()]);
}

function formatEntries<T>(entries: Array<[T, number]>) {
  return entries.map(([key, count]) => `${String(key)}=${count}`).join(', ');
}

function defaultBankSlug(value: string) {
  const known: Record<string, string> = {
    电网刷题真题库: 'grid-exam',
    南方电网真题库: 'south-grid',
  };
  return known[value] ?? `bank-${hashString(value)}`;
}

function defaultSubjectName(value: string) {
  const known: Record<string, string> = {
    电网刷题真题库: '电气工程类',
    南方电网真题库: '综合类',
  };
  return known[value];
}

function hashString(value: string) {
  let hash = 0;
  for (const character of value) {
    hash = (Math.imul(31, hash) + character.charCodeAt(0)) | 0;
  }
  return Math.abs(hash).toString(36);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
