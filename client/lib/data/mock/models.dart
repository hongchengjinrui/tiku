enum QuestionType {
  single('单选题'),
  multiple('多选题'),
  trueFalse('判断题'),
  fillBlank('填空题'),
  shortAnswer('简答题');

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

  const Section({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.done,
    required this.total,
    required this.correct,
    required this.wrong,
  });

  int get accuracy => done == 0 ? 0 : (correct * 100 / done).round();
  double get progress => total == 0 ? 0 : done / total;

  Section copyWith({int? done, int? correct, int? wrong}) {
    return Section(
      id: id,
      chapterId: chapterId,
      title: title,
      done: done ?? this.done,
      total: total,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
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
  });
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
    Map<String, Set<int>>? answers,
    Map<String, String>? textAnswers,
  })  : answers = answers ?? {},
        textAnswers = textAnswers ?? {};

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
  int get wrongCount => submitted ? questions.length - correctCount : 0;
  int get score =>
      questions.isEmpty ? 0 : (correctCount * 100 / questions.length).round();
  int get accuracy => score;

  bool isCorrect(Question question) {
    if (question.type == QuestionType.fillBlank) {
      final text = textAnswers[question.id]?.trim() ?? '';
      final expected = _cleanAnswerText(question.answerText);
      return text.isNotEmpty &&
          expected.isNotEmpty &&
          _normalizeAnswer(text) == _normalizeAnswer(expected);
    }
    return sameAnswer(answers[question.id], question.answerIndexes);
  }
}

String _normalizeAnswer(String value) =>
    _cleanAnswerText(value).replaceAll(RegExp(r'\s+'), '').toLowerCase();

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
  final String title;
  final String mode;
  final String metric;
  final String time;

  const StudyRecord({
    required this.title,
    required this.mode,
    required this.metric,
    required this.time,
  });
}
