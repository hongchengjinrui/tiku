enum QuestionType {
  single('单选题'),
  multiple('多选题'),
  trueFalse('判断题'),
  fillBlank('填空题'),
  shortAnswer('简答题'),
  material('材料题');

  final String label;
  const QuestionType(this.label);
}

bool sameAnswer(Set<int>? selected, Set<int> answer) {
  return selected != null &&
      selected.length == answer.length &&
      selected.containsAll(answer);
}

class Subject {
  final String id;
  final String name;
  final bool isDefault;

  const Subject({
    required this.id,
    required this.name,
    this.isDefault = false,
  });
}

class PracticeStat {
  final int done;
  final int total;
  final int correct;
  final int wrong;

  const PracticeStat({
    required this.done,
    required this.total,
    required this.correct,
    required this.wrong,
  });

  int get accuracy => done == 0 ? 0 : (correct * 100 / done).round();
  double get progress => total == 0 ? 0 : done / total;
}

class FeedbackSubmission {
  final String id;
  final String type;
  final String content;
  final Map<String, Object?> payload;
  final DateTime createdAt;

  const FeedbackSubmission({
    required this.id,
    required this.type,
    required this.content,
    this.payload = const {},
    required this.createdAt,
  });
}

class Chapter {
  final String id;
  final String title;
  final int done;
  final int total;
  final int correct;
  final int wrong;
  final List<Section> sections;

  const Chapter({
    required this.id,
    required this.title,
    required this.done,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.sections,
  });

  int get accuracy => done == 0 ? 0 : (correct * 100 / done).round();
  double get progress => total == 0 ? 0 : done / total;

  Chapter copyWith({
    int? done,
    int? correct,
    int? wrong,
    List<Section>? sections,
  }) {
    return Chapter(
      id: id,
      title: title,
      done: done ?? this.done,
      total: total,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      sections: sections ?? this.sections,
    );
  }
}

class Section {
  final String id;
  final String chapterId;
  final String title;
  final int done;
  final int total;
  final int correct;
  final int wrong;
  final List<Section> children;

  const Section({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.done,
    required this.total,
    required this.correct,
    required this.wrong,
    this.children = const [],
  });

  int get accuracy => done == 0 ? 0 : (correct * 100 / done).round();
  double get progress => total == 0 ? 0 : done / total;
  bool get hasChildren => children.isNotEmpty;

  Section copyWith({
    int? done,
    int? correct,
    int? wrong,
    List<Section>? children,
  }) {
    return Section(
      id: id,
      chapterId: chapterId,
      title: title,
      done: done ?? this.done,
      total: total,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      children: children ?? this.children,
    );
  }
}

class Paper {
  final String id;
  final String title;
  final int done;
  final int total;
  final int correct;
  final int wrong;
  final int minutes;

  const Paper({
    required this.id,
    required this.title,
    required this.done,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.minutes,
  });

  int get accuracy => done == 0 ? 0 : (correct * 100 / done).round();
  double get progress => total == 0 ? 0 : done / total;

  Paper copyWith({int? done, int? correct, int? wrong, int? minutes}) {
    return Paper(
      id: id,
      title: title,
      done: done ?? this.done,
      total: total,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      minutes: minutes ?? this.minutes,
    );
  }
}

class Question {
  final String id;
  final QuestionType type;
  final String stem;
  final String stemHtml;
  final List<String> options;
  final Set<int> answerIndexes;
  final String answerText;
  final String analysis;
  final String analysisHtml;
  final List<String> imageUrls;
  final int wrongCount;
  final DateTime? lastWrongAt;

  const Question({
    required this.id,
    required this.type,
    required this.stem,
    required this.options,
    required this.answerIndexes,
    this.stemHtml = '',
    this.answerText = '',
    required this.analysis,
    this.analysisHtml = '',
    this.imageUrls = const [],
    this.wrongCount = 0,
    this.lastWrongAt,
  });

  Question copyWith({
    int? wrongCount,
    DateTime? lastWrongAt,
  }) {
    return Question(
      id: id,
      type: type,
      stem: stem,
      stemHtml: stemHtml,
      options: options,
      answerIndexes: answerIndexes,
      answerText: answerText,
      analysis: analysis,
      analysisHtml: analysisHtml,
      imageUrls: imageUrls,
      wrongCount: wrongCount ?? this.wrongCount,
      lastWrongAt: lastWrongAt ?? this.lastWrongAt,
    );
  }
}

class PracticeAnswerResult {
  final bool? isCorrect;
  final num? score;
  final String correctAnswerText;
  final String myAnswerText;
  final String analysisText;
  final String? scoreText;
  final List<String> matchedPoints;
  final String? reviewReason;

  const PracticeAnswerResult({
    required this.isCorrect,
    this.score,
    required this.correctAnswerText,
    required this.myAnswerText,
    required this.analysisText,
    this.scoreText,
    this.matchedPoints = const [],
    this.reviewReason,
  });
}

class TextAnswerEvaluation {
  final bool? isCorrect;
  final int? score;
  final String correctAnswerText;
  final List<String> matchedPoints;
  final String? reviewReason;

  const TextAnswerEvaluation({
    required this.isCorrect,
    required this.score,
    required this.correctAnswerText,
    this.matchedPoints = const [],
    this.reviewReason,
  });

  String? get scoreText => score == null ? null : '$score/100';
}

TextAnswerEvaluation evaluateTextAnswer(Question question, String text) {
  final submitted = text.trim();
  final expected = _cleanAnswerText(question.answerText);
  if (submitted.isEmpty) {
    return TextAnswerEvaluation(
      isCorrect: null,
      score: null,
      correctAnswerText: expected,
      reviewReason: '未提交答案。',
    );
  }

  if (question.type == QuestionType.fillBlank) {
    if (expected.isEmpty) {
      return TextAnswerEvaluation(
        isCorrect: null,
        score: null,
        correctAnswerText: expected,
        reviewReason: '当前题目缺少标准答案，已记录作答，待中台补充判分规则。',
      );
    }
    final correct = _normalizeAnswer(submitted) == _normalizeAnswer(expected);
    return TextAnswerEvaluation(
      isCorrect: correct,
      score: correct ? 100 : 0,
      correctAnswerText: expected,
    );
  }

  if (question.type == QuestionType.shortAnswer ||
      question.type == QuestionType.material) {
    final points = _extractAnswerPoints(expected);
    if (points.isEmpty) {
      return TextAnswerEvaluation(
        isCorrect: null,
        score: null,
        correctAnswerText: expected,
        reviewReason: '当前题目缺少标准答案，已记录作答，待中台补充判分规则。',
      );
    }

    final normalizedAnswer = _normalizeAnswer(submitted);
    final matched = points
        .where((point) => _matchesAnswerPoint(normalizedAnswer, point))
        .toList();
    final score = (matched.length * 100 / points.length).round();
    return TextAnswerEvaluation(
      isCorrect: score >= 60,
      score: score,
      correctAnswerText: expected,
      matchedPoints: matched,
      reviewReason: score >= 60 ? null : '待补充：未命中的要点可继续对照标准答案复盘。',
    );
  }

  return TextAnswerEvaluation(
    isCorrect: sameAnswer(null, question.answerIndexes),
    score: null,
    correctAnswerText: expected,
  );
}

class PracticeSession {
  final String title;
  final String mode;
  final String? sectionId;
  final String? paperId;
  final List<Question> questions;
  int currentIndex;
  bool finished;
  final Map<String, Set<int>> answers;
  final Map<String, String> textAnswers;
  final Map<String, PracticeAnswerResult> answerResults;
  final Set<String> submittingQuestionIds;
  final int wrongRemovalThreshold;

  PracticeSession({
    required this.title,
    required this.mode,
    required this.questions,
    this.sectionId,
    this.paperId,
    this.currentIndex = 0,
    this.finished = false,
    Map<String, Set<int>>? answers,
    Map<String, String>? textAnswers,
    Map<String, PracticeAnswerResult>? answerResults,
    Set<String>? submittingQuestionIds,
    this.wrongRemovalThreshold = 0,
  })  : answers = answers ?? {},
        textAnswers = textAnswers ?? {},
        answerResults = answerResults ?? {},
        submittingQuestionIds = submittingQuestionIds ?? {};

  Question get currentQuestion => questions[currentIndex];
  bool hasAnswered(String questionId) =>
      answers.containsKey(questionId) ||
      (textAnswers[questionId]?.trim().isNotEmpty ?? false);
  int get answeredCount => questions
      .where((question) => hasAnswered(question.id))
      .map((question) => question.id)
      .toSet()
      .length;
  int get correctCount => questions.where((question) {
        final result = answerResults[question.id];
        if (result?.isCorrect != null) return result!.isCorrect == true;
        return sameAnswer(answers[question.id], question.answerIndexes);
      }).length;
  int get wrongCount => questions.where((question) {
        if (!hasAnswered(question.id)) return false;
        final result = answerResults[question.id];
        if (result?.isCorrect != null) return result!.isCorrect == false;
        if (textAnswers.containsKey(question.id)) return false;
        return !sameAnswer(answers[question.id], question.answerIndexes);
      }).length;
  int get accuracy =>
      answeredCount == 0 ? 0 : (correctCount * 100 / answeredCount).round();
}

class ExamSession {
  final String title;
  final String mode;
  final String? sectionId;
  final String? paperId;
  final List<Question> questions;
  final int durationMinutes;
  int currentIndex;
  bool submitted;
  int remainingSeconds;
  final Map<String, Set<int>> answers;
  final Map<String, String> textAnswers;

  ExamSession({
    required this.title,
    required this.mode,
    required this.questions,
    required this.durationMinutes,
    this.sectionId,
    this.paperId,
    this.currentIndex = 0,
    this.submitted = false,
    int? remainingSeconds,
    Map<String, Set<int>>? answers,
    Map<String, String>? textAnswers,
  })  : answers = answers ?? {},
        textAnswers = textAnswers ?? {},
        remainingSeconds = remainingSeconds ?? durationMinutes * 60;

  Question get currentQuestion => questions[currentIndex];
  bool hasAnswered(String questionId) =>
      answers.containsKey(questionId) ||
      (textAnswers[questionId]?.trim().isNotEmpty ?? false);
  int get answeredCount => questions
      .where((question) => hasAnswered(question.id))
      .map((question) => question.id)
      .toSet()
      .length;
  int get correctCount => questions.where(isCorrect).length;
  int get wrongCount => submitted ? questions.where(isWrong).length : 0;
  int get earnedScore =>
      questions.fold<int>(0, (sum, question) => sum + questionScore(question));
  int get score =>
      questions.isEmpty ? 0 : (earnedScore / questions.length).round();
  int get accuracy => score;

  bool isCorrect(Question question) {
    if (_isTextQuestion(question)) {
      final text = textAnswers[question.id]?.trim() ?? '';
      if (text.isEmpty) return false;
      return evaluateTextAnswer(question, text).isCorrect ?? false;
    }
    return sameAnswer(answers[question.id], question.answerIndexes);
  }

  bool isWrong(Question question) {
    if (!hasAnswered(question.id)) return false;
    if (_isTextQuestion(question)) {
      final evaluation =
          evaluateTextAnswer(question, textAnswers[question.id] ?? '');
      return evaluation.isCorrect == false;
    }
    return !sameAnswer(answers[question.id], question.answerIndexes);
  }

  int questionScore(Question question) {
    if (!hasAnswered(question.id)) return 0;
    if (_isTextQuestion(question)) {
      return evaluateTextAnswer(question, textAnswers[question.id] ?? '')
              .score ??
          0;
    }
    return sameAnswer(answers[question.id], question.answerIndexes) ? 100 : 0;
  }
}

String _normalizeAnswer(String value) =>
    _cleanAnswerText(value).replaceAll(RegExp(r'\s+'), '').toLowerCase();

bool _isTextQuestion(Question question) =>
    question.type == QuestionType.fillBlank ||
    question.type == QuestionType.shortAnswer ||
    question.type == QuestionType.material;

List<String> _extractAnswerPoints(String value) {
  final cleaned = _cleanAnswerText(value);
  if (cleaned.isEmpty) return const [];
  final chunks = cleaned
      .replaceAll(RegExp(r'[（(]?\d+[）).、]'), '\n')
      .split(RegExp(r'[\n。；;]+'));
  final points = <String>[];
  for (final chunk in chunks) {
    final parts = chunk.split(RegExp(r'[，,、]|和|及|与'));
    for (final part in parts) {
      final point =
          part.replaceAll(RegExp(r'^(应|需|需要|包括|主要|可以|通过|结合|坚持)'), '').trim();
      if (_normalizeAnswer(point).length >= 2 && !points.contains(point)) {
        points.add(point);
      }
    }
  }
  return points.isEmpty ? [cleaned] : points;
}

bool _matchesAnswerPoint(String normalizedAnswer, String point) {
  final normalizedPoint = _normalizeAnswer(point);
  if (normalizedPoint.isEmpty) return false;
  if (normalizedAnswer.contains(normalizedPoint)) return true;
  final compactPoint =
      normalizedPoint.replaceFirst(RegExp(r'(功能|作用|原则|方法|措施|要求)$'), '');
  if (compactPoint.length >= 2 && normalizedAnswer.contains(compactPoint)) {
    return true;
  }
  return normalizedAnswer.length >= 4 &&
      normalizedPoint.contains(normalizedAnswer);
}

String _cleanAnswerText(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
    final inner = trimmed
        .substring(1, trimmed.length - 1)
        .split(',')
        .map((item) => _stripWrappingQuotes(item.trim()))
        .where((item) => item.isNotEmpty)
        .join('；');
    if (inner.isNotEmpty) return inner;
  }
  return trimmed;
}

String _stripWrappingQuotes(String value) {
  if (value.length < 2) return value;
  final first = value[0];
  final last = value[value.length - 1];
  if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
    return value.substring(1, value.length - 1);
  }
  return value;
}

class StudyRecord {
  final String id;
  final String title;
  final String mode;
  final String metric;
  final String time;

  const StudyRecord({
    this.id = '',
    required this.title,
    required this.mode,
    required this.metric,
    required this.time,
  });
}
