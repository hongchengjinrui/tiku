import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/data/repositories/mock_tiku_repository.dart';

void main() {
  test('practice session records answers and updates section progress', () {
    final store = AppStore(repository: MockTikuRepository());
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
    final store = AppStore(repository: MockTikuRepository());
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

  test('practice session supports text answers', () {
    final store = AppStore(repository: MockTikuRepository());
    const question = Question(
      id: 'fill_q1',
      type: QuestionType.fillBlank,
      stem: '安全电压不高于多少伏？',
      options: [],
      answerIndexes: {},
      answerText: '36',
      analysis: '常见安全电压等级包含 36V。',
    );
    store.practiceSession = PracticeSession(
      title: '填空练习',
      mode: '章节练习',
      questions: [question],
    );

    store.answerPracticeText('36');
    final session = store.practiceSession!;

    expect(session.answeredCount, 1);
    expect(session.correctCount, 1);
    expect(session.textAnswers[question.id], '36');
    expect(session.answerResults[question.id]?.isCorrect, isTrue);
  });

  test('practice answer card can jump to a valid question only', () {
    final store = AppStore(repository: MockTikuRepository());
    final section = store.chapters.first.sections.first;

    store.startPracticeFromSection(section.id);
    final session = store.practiceSession!;

    store.jumpPracticeQuestion(3);
    expect(session.currentIndex, 3);

    store.jumpPracticeQuestion(-1);
    expect(session.currentIndex, 3);

    store.jumpPracticeQuestion(session.questions.length);
    expect(session.currentIndex, 3);
  });

  test('practice record actions restart or continue from progress', () {
    final store = AppStore(repository: MockTikuRepository());
    final section = store.chapters.first.sections.first;
    final record = StudyRecord(
      title: section.title,
      mode: '章节练习',
      metric: '3/${section.total}题 · 正确率 67%',
      time: '刚刚',
    );

    store.startPracticeFromRecord(record, restart: false);
    expect(store.practiceSession?.sectionId, section.id);
    expect(store.practiceSession?.currentIndex, 3);

    store.startPracticeFromRecord(record, restart: true);
    expect(store.practiceSession?.sectionId, section.id);
    expect(store.practiceSession?.currentIndex, 0);
  });

  test('custom catalog ids create scoped random practice and assembly exam',
      () {
    final store = AppStore(repository: MockTikuRepository());
    final practiceSectionIds =
        store.chapters.first.sections.map((section) => section.id).toList();
    final examSectionIds =
        store.examChapters.first.sections.map((section) => section.id).toList();

    store.startRandomPractice(count: 20, catalogIds: practiceSectionIds);
    expect(store.practiceSession?.title, '自选章节随机练习');
    expect(store.practiceSession?.mode, '随机练习');

    store.startAssemblyExam(
      scope: 'custom',
      questionCount: 30,
      duration: 90,
      catalogIds: examSectionIds,
    );
    expect(store.examSession?.title, '自选章节组卷');
    expect(store.examSession?.mode, '组卷考试');
    expect(store.examSession?.durationMinutes, 90);
  });

  test('exam record analysis opens a submitted session without adding records',
      () {
    final store = AppStore(repository: MockTikuRepository());
    final section = store.examChapters.first.sections.first;
    final beforeRecords = store.examRecords.length;
    final record = StudyRecord(
      title: section.title,
      mode: '章节考试',
      metric: '80分 · 正确率 80%',
      time: '刚刚',
    );

    store.openExamRecordAnalysis(record);
    final session = store.examSession!;

    expect(session.sectionId, section.id);
    expect(session.submitted, isTrue);
    expect(session.answeredCount, session.questions.length);
    expect(session.accuracy, closeTo(80, 5));
    expect(store.examRecords.length, beforeRecords);
  });

  test('exam session supports fill blank text answers', () {
    final store = AppStore(repository: MockTikuRepository());
    const question = Question(
      id: 'exam_fill_q1',
      type: QuestionType.fillBlank,
      stem: '安全电压不高于多少伏？',
      options: [],
      answerIndexes: {},
      answerText: '36',
      analysis: '常见安全电压等级包含 36V。',
    );
    store.examSession = ExamSession(
      title: '填空考试',
      mode: '章节考试',
      questions: [question],
      durationMinutes: 45,
    );

    store.answerExamText('36');
    final session = store.examSession!;

    expect(session.answeredCount, 1);
    expect(store.examAnsweredStatus(), [true]);
    store.submitExam();
    expect(session.submitted, isTrue);
    expect(session.correctCount, 1);
    expect(session.score, 100);
  });

  test('fill blank local comparison accepts json-array answer text', () {
    final store = AppStore(repository: MockTikuRepository());
    const question = Question(
      id: 'fill_q_json',
      type: QuestionType.fillBlank,
      stem: '第22届汉语桥巴西赛区比赛在哪里落幕？',
      options: [],
      answerIndexes: {},
      answerText: '["巴西利亚大学"]',
      analysis: '赛事承办落地单位为巴西利亚大学。',
    );
    store.practiceSession = PracticeSession(
      title: '填空练习',
      mode: '章节练习',
      questions: [question],
    );

    store.answerPracticeText('巴西利亚大学');

    final result = store.practiceSession!.answerResults[question.id];
    expect(result?.isCorrect, isTrue);
    expect(result?.correctAnswerText, '巴西利亚大学');
  });

  test('wrong question removal updates list and active session', () async {
    final store = AppStore(repository: MockTikuRepository());
    final now = DateTime.now();
    final questions = [
      Question(
        id: 'wrong_q1',
        type: QuestionType.single,
        stem: '第一道错题',
        options: const ['A', 'B'],
        answerIndexes: const {0},
        analysis: '解析',
        wrongCount: 3,
        lastWrongAt: now,
      ),
      Question(
        id: 'wrong_q2',
        type: QuestionType.multiple,
        stem: '第二道错题',
        options: const ['A', 'B', 'C'],
        answerIndexes: const {0, 1},
        analysis: '解析',
        wrongCount: 1,
        lastWrongAt: now,
      ),
    ];
    store.wrongQuestions = questions;

    store.startWrongPractice(count: 2, questions: questions, notify: false);
    expect(store.practiceSession?.questions.length, 2);

    final removed = await store.removeWrongQuestion(questions.first);
    expect(removed, isTrue);
    expect(store.wrongQuestions.map((question) => question.id), ['wrong_q2']);
    expect(store.practiceSession?.questions.map((question) => question.id),
        ['wrong_q2']);

    final cleared =
        await store.clearWrongQuestions(questions: [questions.last]);
    expect(cleared, isTrue);
    expect(store.wrongQuestions, isEmpty);
    expect(store.practiceSession, isNull);
  });

  test('favorite practice can start from a filtered question list', () {
    final store = AppStore(repository: MockTikuRepository());
    const singleQuestion = Question(
      id: 'fav_single',
      type: QuestionType.single,
      stem: '单选收藏题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    const fillQuestion = Question(
      id: 'fav_fill',
      type: QuestionType.fillBlank,
      stem: '填空收藏题',
      options: [],
      answerIndexes: {},
      answerText: '答案',
      analysis: '解析',
    );
    store.favoriteQuestions = const [singleQuestion, fillQuestion];

    store.startFavoritePractice(
      count: 1,
      questions: const [fillQuestion],
      notify: false,
    );

    expect(store.practiceSession?.mode, '收藏练习');
    expect(store.practiceSession?.questions.map((question) => question.id),
        ['fav_fill']);
  });
}
