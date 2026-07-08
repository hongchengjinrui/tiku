import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';

void main() {
  test('practice session records answers and updates section progress', () {
    final store = MockAppStore();
    final section = store.chapters.first.sections.first;
    final beforeDone = section.done;
    final beforeRecords = store.practiceRecords.length;

    store.startPracticeFromSection(section.id);
    final session = store.practiceSession!;

    store.answerPractice(session.currentQuestion.answerIndexes);
    store.finishPracticeSession();

    final updatedSection = store.chapters
        .expand((chapter) => chapter.sections)
        .firstWhere((item) => item.id == section.id);

    expect(session.finished, isTrue);
    expect(session.correctCount, 1);
    expect(updatedSection.done, beforeDone + 1);
    expect(store.practiceRecords.length, beforeRecords + 1);
    expect(store.practiceRecords.first.mode, '章节练习');
  });

  test('exam session supports answer card state and submit result', () {
    final store = MockAppStore();
    final section = store.examChapters.first.sections.first;
    final beforeDone = section.done;
    final beforeRecords = store.examRecords.length;

    store.startExamFromSection(section.id);
    final session = store.examSession!;

    store.answerExam(session.currentQuestion.answerIndexes);
    store.nextExamQuestion();
    store.answerExam({3});
    store.submitExam();

    final updatedSection = store.examChapters
        .expand((chapter) => chapter.sections)
        .firstWhere((item) => item.id == section.id);

    expect(session.submitted, isTrue);
    expect(store.examAnsweredStatus().take(2), [true, true]);
    expect(session.correctCount, 1);
    expect(updatedSection.done, beforeDone + 2);
    expect(store.examRecords.length, beforeRecords + 1);
    expect(store.examRecords.first.mode, '章节考试');
  });

  test('sameAnswer compares answer sets by contents', () {
    expect(sameAnswer({2, 0, 1}, {0, 1, 2}), isTrue);
    expect(sameAnswer({0, 1}, {0, 1, 2}), isFalse);
    expect(sameAnswer(null, {0}), isFalse);
  });
}
