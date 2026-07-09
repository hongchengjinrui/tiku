import type { QuestionType } from '@prisma/client';

type UnknownRecord = Record<string, unknown>;

export type ClientOption = {
  key: string;
  text: string;
};

export type ClientQuestion = {
  id: string;
  type: QuestionType;
  legacyType?: string | null;
  choiceMode?: string | null;
  stemHtml: string;
  stemText: string;
  options: ClientOption[];
  answer: unknown;
  analysisHtml: string;
  analysisText: string;
  scoringRubric?: unknown;
};

export function asRecord(value: unknown): UnknownRecord {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as UnknownRecord)
    : {};
}

export function stripHtml(value: string): string {
  return value
    .replace(/<img\b[^>]*>/gi, ' [图片] ')
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/p>/gi, '\n')
    .replace(/<[^>]+>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
    .trim();
}

export function normalizeText(value: unknown): string {
  return String(value ?? '')
    .replace(/<[^>]+>/g, '')
    .replace(/\s+/g, '')
    .toLowerCase()
    .trim();
}

export function clientQuestionFromDb(question: {
  id: string;
  type: QuestionType;
  legacyType: string | null;
  choiceMode: string | null;
  stem: unknown;
  options: unknown;
  answer: unknown;
  analysis: unknown;
  scoringRubric?: unknown;
}): ClientQuestion {
  const stem = asRecord(question.stem);
  const analysis = asRecord(question.analysis);
  const options = Array.isArray(question.options) ? question.options : [];

  return {
    id: question.id,
    type: question.type,
    legacyType: question.legacyType,
    choiceMode: question.choiceMode,
    stemHtml: String(stem.html ?? ''),
    stemText: String(stem.text ?? stripHtml(String(stem.html ?? ''))),
    options: options.map((item) => {
      const option = asRecord(item);
      return {
        key: String(option.key ?? ''),
        text: String(option.text ?? ''),
      };
    }),
    answer: question.answer,
    analysisHtml: String(analysis.html ?? ''),
    analysisText: String(analysis.text ?? stripHtml(String(analysis.html ?? ''))),
    scoringRubric: question.scoringRubric,
  };
}

export function evaluateChoiceAnswer(
  answer: unknown,
  submittedValues: string[],
): boolean {
  const answerRecord = asRecord(answer);
  const values = Array.isArray(answerRecord.values)
    ? answerRecord.values.map(String)
    : [];
  return (
    values.length === submittedValues.length &&
    values.every((value) => submittedValues.includes(value))
  );
}

export function evaluateFillBlank(answer: unknown, submittedText: string): boolean {
  const answerRecord = asRecord(answer);
  const blanks = Array.isArray(answerRecord.blanks) ? answerRecord.blanks : [];
  const submittedParts = splitSubmittedBlanks(submittedText);
  if (blanks.length === 0) {
    const rawTerms = collectTerms(answerRecord.raw);
    const normalizedSubmitted = normalizeText(submittedText);
    return rawTerms.some((term) => normalizedSubmitted === term);
  }

  const normalizedSubmitted = normalizeText(submittedText);
  return blanks.every((item, index) => {
    const blank = asRecord(item);
    const accepted = collectTerms(blank.accepted);
    const submittedForBlank = submittedParts[index];
    return accepted.some((value) => {
      if (submittedForBlank) return value === submittedForBlank;
      return normalizedSubmitted === value;
    });
  });
}

export function evaluateShortAnswer(
  scoringRubric: unknown,
  answer: unknown,
  submittedText: string,
  actualScore = 100,
) {
  const rubric = asRecord(scoringRubric);
  const points = Array.isArray(rubric.points) ? rubric.points : [];
  const normalizedSubmitted = normalizeText(submittedText);

  if (normalizedSubmitted.length === 0) {
    return {
      baseScoreHit: 0,
      actualScore: 0,
      questionActualScore: actualScore,
      matchedPoints: [],
      reviewRequired: false,
      reviewReason: '',
    };
  }

  if (rubric.can_score !== true || points.length === 0) {
    const expected = normalizeText(asRecord(answer).expected ?? asRecord(answer).raw);
    const hit = expected.length > 0 && normalizedSubmitted.includes(expected);
    return {
      baseScoreHit: hit ? 100 : 0,
      actualScore: hit ? actualScore : 0,
      questionActualScore: actualScore,
      matchedPoints: [],
      reviewRequired: true,
      reviewReason: '缺少可用评分细则，已使用标准答案精确包含作为临时判定。',
    };
  }

  const matchedPoints = points.map((item) => {
    const point = asRecord(item);
    const keywords = collectTerms(point.keywords, point.acceptable_aliases);
    const mustHave = collectTerms(point.must_have);
    const mustHaveHit =
      mustHave.length === 0 ||
      mustHave.some((term) => normalizedSubmitted.includes(term));
    const evidence = [...keywords, ...mustHave].find((term) =>
      normalizedSubmitted.includes(term),
    );
    const hit = mustHaveHit && Boolean(evidence);
    return {
      id: String(point.id ?? ''),
      title: String(point.title ?? ''),
      weight: Number(point.weight ?? 0),
      hit,
      evidence: evidence ?? '',
      confidence: hit ? 0.9 : 0.2,
    };
  });

  const baseScoreHit = matchedPoints
    .filter((point) => point.hit)
    .reduce((sum, point) => sum + point.weight, 0);
  const scaled = Math.max(0, Math.min(actualScore, baseScoreHit * actualScore / 100));

  return {
    baseScoreHit: Math.round(baseScoreHit * 10) / 10,
    actualScore: Math.round(scaled * 10) / 10,
    questionActualScore: actualScore,
    matchedPoints,
    reviewRequired: false,
    reviewReason: '',
  };
}

function collectTerms(...groups: unknown[]): string[] {
  return groups
    .flatMap(expandTermGroup)
    .map(normalizeText)
    .filter((term) => term.length > 0);
}

function splitSubmittedBlanks(value: string): string[] {
  return value
    .split(/[;；,，、|｜\n]/)
    .map(normalizeText)
    .filter((item) => item.length > 0);
}

function expandTermGroup(group: unknown): unknown[] {
  if (Array.isArray(group)) return group.flatMap(expandTermGroup);
  if (typeof group !== 'string') return [group];

  const trimmed = group.trim();
  if (!looksLikeJsonArray(trimmed)) return [group];

  try {
    const parsed = JSON.parse(trimmed) as unknown;
    return Array.isArray(parsed) ? parsed.flatMap(expandTermGroup) : [group];
  } catch {
    return [group];
  }
}

function looksLikeJsonArray(value: string) {
  return value.startsWith('[') && value.endsWith(']');
}
