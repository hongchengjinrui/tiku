import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/data/local/app_state_storage.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/data/repositories/mock_tiku_repository.dart';
import 'package:tiku_muban/data/repositories/remote_tiku_repository.dart';

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

  test('material question records text answer without forced grading', () {
    final store = AppStore(repository: MockTikuRepository());
    const question = Question(
      id: 'material_q1',
      type: QuestionType.material,
      stem: '阅读材料后回答教育评价应注意什么？',
      options: [],
      answerIndexes: {},
      answerText: '',
      analysis: '',
    );
    store.practiceSession = PracticeSession(
      title: '材料题练习',
      mode: '章节练习',
      questions: [question],
    );

    store.answerPracticeText('应结合过程性评价和结果性评价。');
    final result = store.practiceSession!.answerResults[question.id];

    expect(store.practiceSession!.answeredCount, 1);
    expect(store.practiceSession!.wrongCount, 0);
    expect(result?.isCorrect, isNull);
    expect(result?.reviewReason, contains('缺少标准答案'));
  });

  test('short answer local grading uses matched answer points', () {
    final store = AppStore(repository: MockTikuRepository());
    const question = Question(
      id: 'short_q1',
      type: QuestionType.shortAnswer,
      stem: '简述教学评价的功能。',
      options: [],
      answerIndexes: {},
      answerText: '诊断功能、激励功能、调控功能',
      analysis: '教学评价通常具有诊断、激励和调控等功能。',
    );
    store.practiceSession = PracticeSession(
      title: '简答练习',
      mode: '章节练习',
      questions: [question],
    );

    store.answerPracticeText('教学评价可以诊断学习情况，也能起到激励作用。');
    final result = store.practiceSession!.answerResults[question.id];

    expect(result?.score, 67);
    expect(result?.isCorrect, isTrue);
    expect(result?.scoreText, '67/100');
    expect(result?.matchedPoints, ['诊断功能', '激励功能']);
  });

  test('exam session records material text answers', () {
    final store = AppStore(repository: MockTikuRepository());
    const question = Question(
      id: 'exam_material_q1',
      type: QuestionType.material,
      stem: '阅读材料后分析处理思路。',
      options: [],
      answerIndexes: {},
      answerText: '',
      analysis: '',
    );
    store.examSession = ExamSession(
      title: '材料题考试',
      mode: '章节考试',
      questions: [question],
      durationMinutes: 45,
    );

    store.answerExamText('先识别问题，再结合规范提出处理措施。');

    expect(store.examAnsweredStatus(), [true]);
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
    expect(
      store.practiceSession?.questions.first.id,
      startsWith('${practiceSectionIds.first}_'),
    );

    store.startAssemblyExam(
      scope: 'custom',
      questionCount: 30,
      duration: 90,
      catalogIds: examSectionIds,
    );
    expect(store.examSession?.title, '自选章节组卷');
    expect(store.examSession?.mode, '组卷考试');
    expect(store.examSession?.durationMinutes, 90);
    expect(
      store.examSession?.questions.first.id,
      startsWith('${examSectionIds.first}_'),
    );
  });

  test('practice range helpers return practiced and unpracticed leaf catalogs',
      () {
    final store = AppStore(repository: MockTikuRepository());
    store.chapters = const [
      Chapter(
        id: 'range_chapter',
        title: '范围章节',
        done: 3,
        total: 8,
        correct: 3,
        wrong: 0,
        sections: [
          Section(
            id: 'range_done',
            chapterId: 'range_chapter',
            title: '已练小节',
            done: 3,
            total: 4,
            correct: 3,
            wrong: 0,
          ),
          Section(
            id: 'range_empty',
            chapterId: 'range_chapter',
            title: '未练小节',
            done: 0,
            total: 4,
            correct: 0,
            wrong: 0,
          ),
        ],
      ),
    ];

    expect(store.practiceCatalogIdsForRange('已练习章节'), ['range_done']);
    expect(store.practiceCatalogIdsForRange('未练习章节'), ['range_empty']);
    expect(store.practiceCatalogIdsForRange('全部章节'), isEmpty);
  });

  test('nested catalog sections can start, roll up, and reset progress',
      () async {
    final store = AppStore(repository: MockTikuRepository());
    const leaf = Section(
      id: 'nested_leaf',
      chapterId: 'nested_chapter',
      title: '第一节：末级小节',
      done: 0,
      total: 8,
      correct: 0,
      wrong: 0,
    );
    const parent = Section(
      id: 'nested_parent',
      chapterId: 'nested_chapter',
      title: '第一章：父级目录',
      done: 0,
      total: 8,
      correct: 0,
      wrong: 0,
      children: [leaf],
    );
    store.chapters = const [
      Chapter(
        id: 'nested_chapter',
        title: '嵌套章节',
        done: 0,
        total: 8,
        correct: 0,
        wrong: 0,
        sections: [parent],
      ),
    ];
    store.selectedChapterId = 'nested_chapter';

    store.startPracticeFromSection('nested_leaf');
    final session = store.practiceSession!;
    store.answerPractice(session.currentQuestion.answerIndexes);
    store.finishPracticeSession();

    var updatedParent = store.chapters.first.sections.first;
    expect(store.practiceSession?.sectionId, 'nested_leaf');
    expect(updatedParent.done, 1);
    expect(updatedParent.children.first.done, 1);

    final reset = await store.resetPracticeProgress(
      catalogIds: const ['nested_parent'],
    );
    updatedParent = store.chapters.first.sections.first;
    expect(reset, isTrue);
    expect(updatedParent.done, 0);
    expect(updatedParent.children.first.done, 0);
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

  test('unfinished exam record resumes an answer session at saved progress',
      () {
    final store = AppStore(repository: MockTikuRepository());
    final section = store.examChapters.first.sections.first;
    final record = StudyRecord(
      title: section.title,
      mode: '章节考试',
      metric: '5/${section.total}题 · 未交卷',
      time: '刚刚',
    );

    store.startExamFromRecord(record, restart: false);

    expect(store.examSession?.sectionId, section.id);
    expect(store.examSession?.submitted, isFalse);
    expect(store.examSession?.currentIndex, 5);
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

  test('exam short answer grading affects score and wrong count', () {
    final store = AppStore(repository: MockTikuRepository());
    const shortQuestion = Question(
      id: 'exam_short_q1',
      type: QuestionType.shortAnswer,
      stem: '简述教学评价的功能。',
      options: [],
      answerIndexes: {},
      answerText: '诊断功能、激励功能、调控功能',
      analysis: '教学评价通常具有诊断、激励和调控等功能。',
    );
    const unansweredQuestion = Question(
      id: 'exam_single_q2',
      type: QuestionType.single,
      stem: '未作答题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    store.examSession = ExamSession(
      title: '简答考试',
      mode: '章节考试',
      questions: [shortQuestion, unansweredQuestion],
      durationMinutes: 45,
    );

    store.answerExamText('教学评价具有诊断功能，也能激励学生继续改进。');
    store.submitExam();
    final session = store.examSession!;

    expect(session.submitted, isTrue);
    expect(session.correctCount, 1);
    expect(session.wrongCount, 0);
    expect(session.score, 34);
    expect(session.isWrong(unansweredQuestion), isFalse);
  });

  test('exam countdown auto submits once when time is over', () {
    final store = AppStore(repository: MockTikuRepository());
    store.startAssemblyExam(
      scope: 'all',
      questionCount: 8,
      duration: 1,
      notify: false,
    );
    final session = store.examSession!;
    final beforeRecords = store.examRecords.length;

    store.tickExamSecond(seconds: 30);
    expect(session.remainingSeconds, 30);
    expect(session.submitted, isFalse);

    store.tickExamSecond(seconds: 30);
    expect(session.remainingSeconds, 0);
    expect(session.submitted, isTrue);
    expect(store.examRecords.length, beforeRecords + 1);

    store.tickExamSecond(seconds: 30);
    expect(store.examRecords.length, beforeRecords + 1);
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

  test('wrong practice remove rule counts correct answers in local cache',
      () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    const question = Question(
      id: 'wrong_rule_q1',
      type: QuestionType.single,
      stem: '错题规则题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
      wrongCount: 2,
    );
    store.wrongQuestions = const [question];

    store.startWrongPractice(
      questions: const [question],
      removeAfterCorrect: 2,
      notify: false,
    );
    store.answerPractice(question.answerIndexes);
    await store.flushLocalState();

    expect(store.wrongQuestions.map((item) => item.id), ['wrong_rule_q1']);
    expect(store.wrongCorrectCounts['wrong_rule_q1'], 1);
    expect(storage.snapshot?.wrongCorrectCounts['wrong_rule_q1'], 1);
  });

  test('wrong practice auto removes after reaching correct threshold', () {
    final store = AppStore(repository: MockTikuRepository());
    const question = Question(
      id: 'wrong_rule_q2',
      type: QuestionType.single,
      stem: '错题自动移出题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
      wrongCount: 3,
    );
    store.wrongQuestions = const [question];
    store.wrongCorrectCounts = const {'wrong_rule_q2': 1};

    store.startWrongPractice(
      questions: const [question],
      removeAfterCorrect: 2,
      notify: false,
    );
    store.answerPractice(question.answerIndexes);

    expect(store.wrongQuestions, isEmpty);
    expect(store.wrongCorrectCounts.containsKey('wrong_rule_q2'), isFalse);
    expect(store.practiceSession?.questions.map((item) => item.id),
        ['wrong_rule_q2']);
    expect(store.practiceSession?.answerResults['wrong_rule_q2']?.isCorrect,
        isTrue);
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

  test('favorite removal updates active favorite practice session', () async {
    final store = AppStore(repository: MockTikuRepository());
    const firstQuestion = Question(
      id: 'fav_remove_q1',
      type: QuestionType.single,
      stem: '第一道收藏题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    const secondQuestion = Question(
      id: 'fav_remove_q2',
      type: QuestionType.trueFalse,
      stem: '第二道收藏题',
      options: ['正确', '错误'],
      answerIndexes: {1},
      analysis: '解析',
    );
    store.favoriteQuestions = const [firstQuestion, secondQuestion];

    store.startFavoritePractice(
      count: 2,
      questions: const [firstQuestion, secondQuestion],
      notify: false,
    );

    await store.toggleFavorite(firstQuestion);
    expect(store.favoriteQuestions.map((question) => question.id),
        ['fav_remove_q2']);
    expect(store.practiceSession?.questions.map((question) => question.id),
        ['fav_remove_q2']);
    expect(store.practiceSession?.currentQuestion.id, 'fav_remove_q2');

    await store.toggleFavorite(secondQuestion);
    expect(store.favoriteQuestions, isEmpty);
    expect(store.practiceSession, isNull);
  });

  test('remote repository falls back to local interactions before warm up',
      () async {
    final store = AppStore(
      repository: RemoteTikuRepository(baseUrl: 'http://127.0.0.1:1/api'),
    );

    expect(store.remoteReady, isFalse);
    expect(store.favoritePracticeCount, 0);
    expect(store.wrongPracticeCount, greaterThan(0));

    const favorite = Question(
      id: 'offline_favorite_q1',
      type: QuestionType.single,
      stem: '离线收藏题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    await store.toggleFavorite(favorite);
    expect(store.favoriteQuestions.map((item) => item.id),
        ['offline_favorite_q1']);
    await store.toggleFavorite(favorite);
    expect(store.favoriteQuestions, isEmpty);

    final wrong = store.wrongQuestions.first;
    final removedWrong = await store.removeWrongQuestion(wrong);
    expect(removedWrong, isTrue);
    expect(store.wrongQuestions.any((item) => item.id == wrong.id), isFalse);

    final clearedWrong = await store.clearWrongQuestions();
    expect(clearedWrong, isTrue);
    expect(store.wrongPracticeCount, 0);

    store.startWrongPractice(notify: false);
    expect(store.practiceSession, isNull);

    final deletedPracticeRecords = await store.deletePracticeRecords();
    final deletedExamRecords = await store.deleteExamRecords();
    expect(deletedPracticeRecords, isTrue);
    expect(deletedExamRecords, isTrue);
    expect(store.practiceRecords, isEmpty);
    expect(store.examRecords, isEmpty);
  });

  test('local subject switching keeps per-subject interaction state', () async {
    final store = AppStore(repository: MockTikuRepository());
    const primaryFavorite = Question(
      id: 'primary_subject_favorite',
      type: QuestionType.single,
      stem: '小学教师收藏题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    const middleFavorite = Question(
      id: 'middle_subject_favorite',
      type: QuestionType.single,
      stem: '中学教师收藏题',
      options: ['A', 'B'],
      answerIndexes: {1},
      analysis: '解析',
    );

    final primaryDone = store.practiceStat.done;
    await store.toggleFavorite(primaryFavorite);
    store.selectChapter('chapter_3');

    await store.selectSubject('middle_teacher');

    expect(store.selectedSubjectId, 'middle_teacher');
    expect(store.selectedChapterId, 'chapter_1');
    expect(store.favoriteQuestions, isEmpty);
    expect(store.practiceStat.done, isNot(primaryDone));

    await store.toggleFavorite(middleFavorite);

    await store.selectSubject('primary_teacher');

    expect(store.selectedChapterId, 'chapter_3');
    expect(store.favoriteQuestions.map((item) => item.id),
        ['primary_subject_favorite']);

    await store.selectSubject('middle_teacher');

    expect(store.favoriteQuestions.map((item) => item.id),
        ['middle_subject_favorite']);
  });

  test('local subject states survive app state restore', () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    const primaryFavorite = Question(
      id: 'restore_primary_favorite',
      type: QuestionType.single,
      stem: '恢复小学收藏题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    const middleFavorite = Question(
      id: 'restore_middle_favorite',
      type: QuestionType.single,
      stem: '恢复中学收藏题',
      options: ['A', 'B'],
      answerIndexes: {1},
      analysis: '解析',
    );

    await store.toggleFavorite(primaryFavorite);
    store.selectChapter('chapter_3');
    await store.selectSubject('middle_teacher');
    await store.toggleFavorite(middleFavorite);
    store.selectChapter('chapter_2');
    await store.flushLocalState();

    expect(storage.snapshot?.localSubjectStates.keys,
        containsAll(['primary_teacher', 'middle_teacher']));

    final restored = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    await restored.restoreLocalState();

    expect(restored.selectedSubjectId, 'middle_teacher');
    expect(restored.selectedChapterId, 'chapter_2');
    expect(restored.favoriteQuestions.map((item) => item.id),
        ['restore_middle_favorite']);

    await restored.selectSubject('primary_teacher');

    expect(restored.selectedChapterId, 'chapter_3');
    expect(restored.favoriteQuestions.map((item) => item.id),
        ['restore_primary_favorite']);
  });

  test('local feedback submissions are queued and restored', () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    const question = Question(
      id: 'feedback_question_q1',
      type: QuestionType.single,
      stem: '反馈题干',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );

    final generalOk = await store.submitFeedback(
      content: '希望增加夜间模式',
      type: 'app_feedback',
      payload: const {'source': 'profile_feedback'},
    );
    final questionOk = await store.submitQuestionFeedback(
      question,
      content: '这道题解析有误',
      type: 'analysis_error',
    );

    expect(generalOk, isTrue);
    expect(questionOk, isTrue);
    expect(store.feedbackSubmissions.length, 2);
    expect(store.feedbackSubmissions.first.type, 'analysis_error');
    expect(store.feedbackSubmissions.first.payload['questionId'],
        'feedback_question_q1');

    await store.flushLocalState();

    final restored = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    await restored.restoreLocalState();

    expect(restored.feedbackSubmissions.map((item) => item.content), [
      '这道题解析有误',
      '希望增加夜间模式',
    ]);
  });

  test('local feedback submissions can be removed and cleared', () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );

    await store.submitFeedback(
      content: '第一条反馈',
      type: 'app_feedback',
      payload: const {'source': 'profile_feedback'},
    );
    await store.submitFeedback(
      content: '第二条反馈',
      type: 'analysis_error',
      payload: const {'label': '解析有误'},
    );

    final removed = await store.removeFeedbackSubmission(
      store.feedbackSubmissions.first,
    );
    await store.flushLocalState();

    expect(removed, isTrue);
    expect(store.feedbackSubmissions.map((item) => item.content), ['第一条反馈']);
    expect(storage.snapshot?.feedbackSubmissions.single.content, '第一条反馈');

    final cleared = await store.clearFeedbackSubmissions();
    await store.flushLocalState();

    expect(cleared, isTrue);
    expect(store.feedbackSubmissions, isEmpty);
    expect(storage.snapshot?.feedbackSubmissions, isEmpty);
  });

  test('single record deletion keeps other records', () async {
    final store = AppStore(repository: MockTikuRepository());
    final practiceTarget = store.practiceRecords.first;
    final practiceRemain = store.practiceRecords.last;
    final examTarget = store.examRecords.first;
    final examRemain = store.examRecords.last;

    final practiceDeleted = await store.deletePracticeRecord(practiceTarget);
    final examDeleted = await store.deleteExamRecord(examTarget);

    expect(practiceDeleted, isTrue);
    expect(examDeleted, isTrue);
    expect(store.practiceRecords, [practiceRemain]);
    expect(store.examRecords, [examRemain]);
  });

  test('local app state storage restores user progress and selections',
      () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    await store.selectSubject('middle_teacher');
    store.selectChapter('chapter_2');
    store.selectExamChapter('chapter_2');

    final section = store.chapters.first.sections.first;
    final beforeDone = section.done;
    store.startPracticeFromSection(section.id, notify: false);
    store.answerPractice(store.practiceSession!.currentQuestion.answerIndexes);
    store.finishPracticeSession();

    const favorite = Question(
      id: 'cached_favorite_q1',
      type: QuestionType.single,
      stem: '收藏题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    final wrong = favorite.copyWith(wrongCount: 2, lastWrongAt: DateTime(2026));
    await store.toggleFavorite(favorite);
    store.wrongQuestions = [wrong];
    await store.flushLocalState();

    final restored = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    await restored.restoreLocalState();
    final restoredSection = restored.chapters
        .expand((chapter) => chapter.sections)
        .firstWhere((item) => item.id == section.id);

    expect(restored.selectedSubjectId, 'middle_teacher');
    expect(restored.selectedChapterId, 'chapter_2');
    expect(restored.selectedExamChapterId, 'chapter_2');
    expect(restoredSection.done, beforeDone + 1);
    expect(restored.practiceRecords.first.mode, '章节练习');
    expect(restored.favoriteQuestions.map((item) => item.id),
        ['cached_favorite_q1']);
    expect(restored.wrongQuestions.single.wrongCount, 2);
  });

  test('local snapshot restores remote catalog question cache', () async {
    final storage = MemoryAppStateStorage();
    final repository = RemoteTikuRepository(baseUrl: 'http://127.0.0.1:1/api');
    final section = repository.loadPracticeChapters().first.sections.first;
    const cachedQuestion = Question(
      id: 'cached_catalog_q1',
      type: QuestionType.single,
      stem: '缓存章节题',
      options: ['A', 'B'],
      answerIndexes: {1},
      analysis: '缓存解析',
    );
    storage.snapshot = AppStateSnapshot(
      savedAt: DateTime(2026),
      selectedSubjectId: 'primary_teacher',
      selectedChapterId: 'chapter_1',
      selectedExamChapterId: 'chapter_1',
      practiceChapters: repository.loadPracticeChapters(),
      examChapters: repository.loadExamChapters(),
      practicePapers: repository.loadPracticePapers(),
      examPapers: repository.loadExamPapers(),
      practiceRecords: const [],
      examRecords: const [],
      favoriteQuestions: const [],
      wrongQuestions: const [],
      catalogQuestionCache: {
        section.id: const [cachedQuestion],
      },
    );

    final store = AppStore(repository: repository, stateStorage: storage);
    await store.restoreLocalState();
    store.startPracticeFromSection(section.id, notify: false);

    expect(store.practiceSession?.questions.map((item) => item.id),
        ['cached_catalog_q1']);
    expect(store.practiceSession?.currentQuestion.stem, '缓存章节题');
  });

  test('local app state can be flushed and cleared without wiping memory',
      () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );

    await store.selectSubject('middle_teacher');
    await store.flushLocalState();

    expect(storage.snapshot?.selectedSubjectId, 'middle_teacher');

    await store.clearLocalState();

    expect(storage.snapshot, isNull);
    expect(store.selectedSubjectId, 'middle_teacher');
    expect(store.practiceRecords, isNotEmpty);
  });

  test('resource download link claims persist in local snapshot', () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );

    store.claimResourceDownloadLink(
      resourceId: 'resource_free_1',
      title: '入门备考规划清单',
      link: 'local://free',
      subjectName: '小学教师',
      isFree: true,
    );
    store.claimResourceDownloadLink(
      resourceId: 'resource_free_1',
      title: '入门备考规划清单',
      link: 'local://free-updated',
      subjectName: '小学教师',
      isFree: true,
    );
    await store.flushLocalState();

    expect(store.claimedResourceCount, 1);
    expect(store.resourceClaimTotalCount, 2);
    expect(storage.snapshot?.resourceClaims.single.count, 2);
    expect(
        storage.snapshot?.resourceClaims.single.link, 'local://free-updated');

    final restored = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    await restored.restoreLocalState();

    expect(restored.resourceClaimCount('resource_free_1'), 2);
    expect(restored.resourceClaimFor('resource_free_1')?.subjectName, '小学教师');
  });

  test('active practice and exam sessions survive app state restore', () async {
    final storage = MemoryAppStateStorage();
    final store = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    final practiceSection = store.chapters.first.sections.first;
    final examSection = store.examChapters.first.sections.first;

    store.startPracticeFromSection(practiceSection.id, notify: false);
    final practiceQuestion = store.practiceSession!.currentQuestion;
    store.answerPractice(practiceQuestion.answerIndexes);
    store.nextPracticeQuestion();

    store.startExamFromSection(examSection.id, notify: false);
    final examQuestion = store.examSession!.currentQuestion;
    store.answerExam(examQuestion.answerIndexes);
    store.nextExamQuestion();
    store.tickExamSecond(seconds: 45);
    await store.flushLocalState();

    final restored = AppStore(
      repository: MockTikuRepository(),
      stateStorage: storage,
    );
    await restored.restoreLocalState();

    final restoredPractice = restored.practiceSession!;
    expect(restoredPractice.sectionId, practiceSection.id);
    expect(restoredPractice.currentIndex, 1);
    expect(restoredPractice.answers[practiceQuestion.id],
        practiceQuestion.answerIndexes);
    expect(
        restoredPractice.answerResults[practiceQuestion.id]?.isCorrect, isTrue);

    final restoredExam = restored.examSession!;
    expect(restoredExam.sectionId, examSection.id);
    expect(restoredExam.currentIndex, 1);
    expect(restoredExam.answers[examQuestion.id], examQuestion.answerIndexes);
    expect(restoredExam.remainingSeconds, 45 * 60 - 45);
    expect(restored.examAnsweredStatus().first, isTrue);
  });
}
