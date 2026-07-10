import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/data/repositories/mock_tiku_repository.dart';
import 'package:tiku_muban/features/practice/p07_favorite_practice_page.dart';
import 'package:tiku_muban/features/practice/p05_question_practice_page.dart';
import 'package:tiku_muban/main.dart';
import 'package:tiku_muban/routes/app_router.dart';

void main() {
  tearDown(() {
    mockStore.practiceSession = null;
    mockStore.favoriteQuestions = const [];
    mockStore.wrongQuestions = const [];
    mockStore.wrongCorrectCounts = const {};
    mockStore.feedbackSubmissions = const [];
  });

  testWidgets('practice multiple choice supports draft selection before reveal',
      (tester) async {
    final previousRepository = mockStore.repository;
    mockStore.repository = MockTikuRepository();
    addTearDown(() => mockStore.repository = previousRepository);

    const question = Question(
      id: 'practice_multi_q1',
      type: QuestionType.multiple,
      stem: '请选择所有正确选项',
      options: ['选项A', '选项B', '选项C'],
      answerIndexes: {0, 1},
      analysis: 'A 和 B 正确。',
    );
    mockStore.practiceSession = PracticeSession(
      title: '多选练习',
      mode: '章节练习',
      questions: const [question],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const MaterialApp(home: P05QuestionPracticePage()));
    await tester.pump();

    await tester.tap(find.text('选项A'));
    await tester.pump();
    await tester.tap(find.text('选项B'));
    await tester.pump();

    expect(mockStore.practiceSession?.answers[question.id], {0, 1});
    expect(mockStore.practiceSession?.answerResults[question.id], isNull);
    expect(find.text('解析结果：A 和 B 正确。'), findsNothing);

    await tester.tap(find.text('确认答案'));
    await tester.pump();

    expect(mockStore.practiceSession?.answerResults[question.id]?.isCorrect,
        isTrue);
    expect(find.text('回答正确'), findsOneWidget);
    expect(find.text('解析结果：A 和 B 正确。'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('wrong practice starts from filtered question type',
      (tester) async {
    mockStore.remoteReady = false;
    mockStore.repository = MockTikuRepository();
    mockStore.wrongQuestions = const [
      Question(
        id: 'wrong_single_filter',
        type: QuestionType.single,
        stem: '单选错题',
        options: ['A', 'B'],
        answerIndexes: {0},
        analysis: '解析',
        wrongCount: 1,
      ),
      Question(
        id: 'wrong_fill_filter',
        type: QuestionType.fillBlank,
        stem: '填空错题',
        options: [],
        answerIndexes: {},
        answerText: '答案',
        analysis: '解析',
        wrongCount: 1,
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());
    appRouter.go('/practice/wrong');
    await tester.pumpAndSettle();

    await tester.tap(find.text('填空'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始错题练习（1题）'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.mode, '错题练习');
    expect(mockStore.practiceSession?.questions.map((item) => item.id),
        ['wrong_fill_filter']);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('practice answer card jumps to selected question',
      (tester) async {
    mockStore.practiceSession = PracticeSession(
      title: '答题卡练习',
      mode: '章节练习',
      currentIndex: 0,
      questions: const [
        Question(
          id: 'practice_card_q1',
          type: QuestionType.single,
          stem: '练习答题卡第一题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析1',
        ),
        Question(
          id: 'practice_card_q2',
          type: QuestionType.single,
          stem: '练习答题卡第二题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析2',
        ),
        Question(
          id: 'practice_card_q3',
          type: QuestionType.trueFalse,
          stem: '练习答题卡第三题',
          options: ['正确', '错误'],
          answerIndexes: {0},
          analysis: '解析3',
        ),
      ],
      answers: const {
        'practice_card_q1': {0},
      },
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());
    appRouter.go('/practice/quiz');
    await tester.pumpAndSettle();

    expect(find.text('练习答题卡第一题'), findsOneWidget);

    await tester.tap(find.text('答题卡').first);
    await tester.pumpAndSettle();

    expect(find.text('已答 1'), findsOneWidget);
    expect(find.text('未答 2'), findsOneWidget);
    expect(find.text('当前 1'), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.currentIndex, 2);
    expect(find.text('练习答题卡第三题'), findsOneWidget);

    await tester.tap(find.text('答题卡').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('返回答题'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.currentIndex, 2);
    expect(find.text('练习答题卡第三题'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('practice quiz favorite action toggles local favorite state',
      (tester) async {
    mockStore.remoteReady = false;
    mockStore.repository = MockTikuRepository();
    const question = Question(
      id: 'practice_favorite_toggle_q1',
      type: QuestionType.single,
      stem: '收藏切换测试题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    mockStore.practiceSession = PracticeSession(
      title: '收藏按钮练习',
      mode: '章节练习',
      questions: const [question],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());
    appRouter.go('/practice/quiz');
    await tester.pumpAndSettle();

    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();

    expect(mockStore.favoriteQuestions.map((item) => item.id),
        ['practice_favorite_toggle_q1']);
    expect(find.text('已收藏'), findsWidgets);

    await tester.tap(find.text('已收藏').first);
    await tester.pumpAndSettle();

    expect(mockStore.favoriteQuestions, isEmpty);
    expect(find.text('收藏'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('favorite practice returns to favorite page after last removal',
      (tester) async {
    mockStore.remoteReady = false;
    mockStore.repository = MockTikuRepository();
    const question = Question(
      id: 'favorite_session_last_q1',
      type: QuestionType.single,
      stem: '收藏练习最后一题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    mockStore.favoriteQuestions = const [question];
    mockStore.practiceSession = PracticeSession(
      title: '收藏练习',
      mode: '收藏练习',
      questions: const [question],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());
    appRouter.go('/practice/quiz');
    await tester.pumpAndSettle();

    await tester.tap(find.text('已收藏'));
    await tester.pumpAndSettle();

    expect(mockStore.favoriteQuestions, isEmpty);
    expect(mockStore.practiceSession, isNull);
    expect(find.text('暂无收藏题目'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('practice quiz question feedback submits a local correction',
      (tester) async {
    mockStore.remoteReady = false;
    mockStore.repository = MockTikuRepository();
    const question = Question(
      id: 'practice_feedback_q1',
      type: QuestionType.single,
      stem: '题目纠错测试题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    mockStore.practiceSession = PracticeSession(
      title: '纠错练习',
      mode: '章节练习',
      questions: const [question],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());
    appRouter.go('/practice/quiz');
    await tester.pumpAndSettle();

    await tester.tap(find.text('纠错'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('答案有误'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField).last,
      '这道题的标准答案需要复核',
    );
    await tester.tap(find.text('提交纠错'));
    await tester.pumpAndSettle();

    expect(find.text('纠错已提交'), findsOneWidget);
    expect(mockStore.feedbackSubmissions, hasLength(1));
    expect(mockStore.feedbackSubmissions.single.type, 'answer_error');
    expect(mockStore.feedbackSubmissions.single.content, '这道题的标准答案需要复核');
    expect(
      mockStore.feedbackSubmissions.single.payload['questionId'],
      'practice_feedback_q1',
    );

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('wrong practice remove action updates session and empty route',
      (tester) async {
    mockStore.remoteReady = false;
    mockStore.repository = MockTikuRepository();
    const firstQuestion = Question(
      id: 'wrong_remove_q1',
      type: QuestionType.single,
      stem: '第一道待移出错题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析1',
      wrongCount: 1,
    );
    const secondQuestion = Question(
      id: 'wrong_remove_q2',
      type: QuestionType.single,
      stem: '第二道待移出错题',
      options: ['A', 'B'],
      answerIndexes: {1},
      analysis: '解析2',
      wrongCount: 1,
    );
    mockStore.wrongQuestions = const [firstQuestion, secondQuestion];
    mockStore.wrongCorrectCounts = const {
      'wrong_remove_q1': 1,
      'wrong_remove_q2': 1,
    };
    mockStore.practiceSession = PracticeSession(
      title: '错题练习',
      mode: '错题练习',
      questions: const [firstQuestion, secondQuestion],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());
    appRouter.go('/practice/quiz');
    await tester.pumpAndSettle();

    expect(find.text('第一道待移出错题'), findsOneWidget);

    await tester.tap(find.text('移出错题'));
    await tester.pumpAndSettle();

    expect(
        mockStore.wrongQuestions.map((item) => item.id), ['wrong_remove_q2']);
    expect(
        mockStore.wrongCorrectCounts.containsKey('wrong_remove_q1'), isFalse);
    expect(mockStore.practiceSession?.currentQuestion.id, 'wrong_remove_q2');
    expect(find.text('第二道待移出错题'), findsOneWidget);

    await tester.tap(find.text('移出错题'));
    await tester.pumpAndSettle();

    expect(mockStore.wrongQuestions, isEmpty);
    expect(mockStore.practiceSession, isNull);
    expect(find.text('暂无错题。完成练习并出现答错题目后，可从这里进入错题练习。'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('favorite page filter and removal update local favorites',
      (tester) async {
    mockStore.remoteReady = false;
    mockStore.repository = MockTikuRepository();
    mockStore.favoriteQuestions = const [
      Question(
        id: 'favorite_single_filter',
        type: QuestionType.single,
        stem: '单选收藏题',
        options: ['A', 'B'],
        answerIndexes: {0},
        analysis: '解析',
      ),
      Question(
        id: 'favorite_fill_filter',
        type: QuestionType.fillBlank,
        stem: '填空收藏题',
        options: [],
        answerIndexes: {},
        answerText: '答案',
        analysis: '解析',
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const MaterialApp(home: P07FavoritePracticePage()));
    await tester.pump();

    await tester.tap(find.text('单选').first);
    await tester.pump();

    expect(find.text('单选收藏题'), findsOneWidget);
    expect(find.text('填空收藏题'), findsNothing);

    await tester.tap(find.byIcon(Icons.star).first);
    await tester.pump();

    expect(mockStore.favoriteQuestions.map((item) => item.id),
        ['favorite_fill_filter']);
    expect(find.text('当前题型暂无收藏题目'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('favorite empty states can reset filter or return to practice',
      (tester) async {
    final previousFavorites = mockStore.favoriteQuestions;
    final previousSession = mockStore.practiceSession;
    addTearDown(() {
      mockStore.favoriteQuestions = previousFavorites;
      mockStore.practiceSession = previousSession;
    });
    mockStore.favoriteQuestions = const [
      Question(
        id: 'favorite_empty_single',
        type: QuestionType.single,
        stem: '单选收藏题',
        options: ['A', 'B'],
        answerIndexes: {0},
        analysis: '解析',
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/favorite');
    await tester.pumpAndSettle();
    await tester.tap(find.text('填空').first);
    await tester.pumpAndSettle();

    expect(find.text('当前题型暂无收藏题目'), findsOneWidget);

    await tester.tap(find.text('查看全部'));
    await tester.pumpAndSettle();

    expect(find.text('单选收藏题'), findsOneWidget);

    mockStore.favoriteQuestions = const [];
    mockStore.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('暂无收藏题目'), findsOneWidget);

    await tester.tap(find.text('去练习'));
    await tester.pumpAndSettle();

    expect(find.text('练习入口'), findsOneWidget);
  });

  testWidgets('practice question back returns to the source flow',
      (tester) async {
    const question = Question(
      id: 'exit_route_q1',
      type: QuestionType.single,
      stem: '退出路由测试题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    final cases = [
      (mode: '章节练习', title: '章节来源', expectedText: '章节练习/'),
      (mode: '真题练习', title: '真题来源', expectedText: '真题试卷'),
      (mode: '随机练习', title: '随机来源', expectedText: '抽题范围'),
      (mode: '收藏练习', title: '收藏来源', expectedText: '收藏练习'),
      (mode: '错题练习', title: '错题来源', expectedText: '条件筛选'),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    for (final item in cases) {
      mockStore.practiceSession = PracticeSession(
        title: item.title,
        mode: item.mode,
        questions: const [question],
      );
      appRouter.go('/practice/quiz');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pumpAndSettle();

      expect(find.textContaining(item.expectedText), findsWidgets);
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('finishing practice returns to the source flow', (tester) async {
    const question = Question(
      id: 'finish_route_q1',
      type: QuestionType.single,
      stem: '完成路由测试题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    mockStore.favoriteQuestions = const [question];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    mockStore.practiceSession = PracticeSession(
      title: '收藏来源',
      mode: '收藏练习',
      questions: const [question],
    );
    appRouter.go('/practice/quiz');
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成练习'));
    await tester.pumpAndSettle();

    expect(find.text('收藏练习'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('material questions keep shared context and switch child items',
      (tester) async {
    mockStore.practiceSession = PracticeSession(
      title: '材料题练习',
      mode: '章节练习',
      questions: const [
        Question(
          id: 'material_child_1',
          type: QuestionType.single,
          stem: '材料子题一',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析一',
          materialGroupId: 'material_group_1',
          materialStem: '这是两道子题共用的材料。',
        ),
        Question(
          id: 'material_child_2',
          type: QuestionType.multiple,
          stem: '材料子题二',
          options: ['A', 'B', 'C'],
          answerIndexes: {0, 1},
          analysis: '解析二',
          materialGroupId: 'material_group_1',
          materialStem: '这是两道子题共用的材料。',
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const MaterialApp(home: P05QuestionPracticePage()));
    await tester.pump();

    expect(find.text('公共材料题干'), findsOneWidget);
    expect(find.text('第 1-2 / 2 题'), findsOneWidget);
    expect(find.text('子题1 单选题'), findsOneWidget);
    expect(find.text('子题2 多选题'), findsOneWidget);

    await tester.tap(find.text('子题2 多选题'));
    await tester.pump();
    expect(mockStore.practiceSession?.currentIndex, 1);
    expect(find.text('材料子题二'), findsOneWidget);

    await tester.tap(find.text('收起材料'));
    await tester.pump();
    expect(find.text('这是两道子题共用的材料。'), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('failed question image can be reported once', (tester) async {
    mockStore.practiceSession = PracticeSession(
      title: '图片题练习',
      mode: '章节练习',
      questions: const [
        Question(
          id: 'broken_image_question',
          type: QuestionType.single,
          stem: '包含失效图片的题目',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析',
          imageUrls: ['invalid://broken-image'],
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const MaterialApp(home: P05QuestionPracticePage()));
    await tester.pump();

    expect(find.text('图片加载失败，'), findsOneWidget);
    await tester.tap(find.text('点击反馈'));
    await tester.pumpAndSettle();

    expect(find.text('已静默提交：本题图片未能加载'), findsOneWidget);
    expect(mockStore.feedbackSubmissions.single.type, 'image_error');

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('empty practice quiz state returns to practice home',
      (tester) async {
    const question = Question(
      id: 'empty_practice_state_q1',
      type: QuestionType.single,
      stem: '兜底练习题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    mockStore.practiceSession = PracticeSession(
      title: '兜底练习',
      mode: '章节练习',
      questions: const [question],
    );
    final router = GoRouter(
      initialLocation: '/practice/quiz',
      routes: [
        GoRoute(
          path: '/practice/quiz',
          builder: (_, __) => const P05QuestionPracticePage(),
        ),
        GoRoute(
          path: '/practice',
          builder: (_, __) => const _PracticeHomeMarker(),
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    mockStore.practiceSession = null;
    mockStore.notifyListeners();
    await tester.pump();

    expect(find.text('暂无练习内容'), findsOneWidget);

    await tester.tap(find.text('返回练习入口'));
    await tester.pumpAndSettle();

    expect(find.text('practice home route'), findsOneWidget);
  });
}

class _PracticeHomeMarker extends StatelessWidget {
  const _PracticeHomeMarker();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('practice home route'),
    );
  }
}
