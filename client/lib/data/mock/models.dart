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
  final List<String> options;
  final Set<int> answerIndexes;
  final String analysis;

  const Question({
    required this.id,
    required this.type,
    required this.stem,
    required this.options,
    required this.answerIndexes,
    required this.analysis,
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

  PracticeSession({
    required this.title,
    required this.mode,
    required this.questions,
    this.sectionId,
    this.paperId,
    this.currentIndex = 0,
    this.finished = false,
    Map<String, Set<int>>? answers,
  }) : answers = answers ?? {};

  Question get currentQuestion => questions[currentIndex];
  int get answeredCount => answers.length;
  int get correctCount => questions
      .where((question) =>
          sameAnswer(answers[question.id], question.answerIndexes))
      .length;
  int get wrongCount => answeredCount - correctCount;
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
  }) : answers = answers ?? {};

  Question get currentQuestion => questions[currentIndex];
  int get answeredCount => answers.length;
  int get correctCount => questions
      .where((question) =>
          sameAnswer(answers[question.id], question.answerIndexes))
      .length;
  int get wrongCount => submitted ? questions.length - correctCount : 0;
  int get score => (correctCount * 100 / questions.length).round();
  int get accuracy => score;
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
