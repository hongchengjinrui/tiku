import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/features/exam/p25_exam_answering_page.dart';
import 'package:tiku_muban/features/exam/p26_answer_card_page.dart';
import 'package:tiku_muban/features/exam/p28_exam_analysis_page.dart';
import 'package:tiku_muban/features/exam/p28a_analysis_unanswered_page.dart';

void main() {
  tearDown(() {
    mockStore.examSession = null;
  });

  testWidgets('exam answering routes to analysis when countdown reaches zero',
      (tester) async {
    mockStore.examSession = ExamSession(
      title: '倒计时考试',
      mode: '组卷考试',
      durationMinutes: 1,
      remainingSeconds: 1,
      questions: const [
        Question(
          id: 'exam_timer_q1',
          type: QuestionType.single,
          stem: '倒计时题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析',
        ),
      ],
    );
    final router = GoRouter(
      initialLocation: '/exam/answer',
      routes: [
        GoRoute(
          path: '/exam/answer',
          builder: (_, __) => const P25ExamAnsweringPage(),
        ),
        GoRoute(
          path: '/exam/analysis',
          builder: (_, __) => const _AnalysisMarker(),
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text('剩余 0:01'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.submitted, isTrue);
    expect(find.text('analysis route'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'exam answer card jumps to selected question and returns to answer',
      (tester) async {
    mockStore.examSession = ExamSession(
      title: '答题卡考试',
      mode: '章节考试',
      durationMinutes: 45,
      currentIndex: 1,
      questions: const [
        Question(
          id: 'card_q1',
          type: QuestionType.single,
          stem: '第一题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析1',
        ),
        Question(
          id: 'card_q2',
          type: QuestionType.multiple,
          stem: '第二题',
          options: ['A', 'B', 'C'],
          answerIndexes: {0, 1},
          analysis: '解析2',
        ),
        Question(
          id: 'card_q3',
          type: QuestionType.trueFalse,
          stem: '第三题',
          options: ['正确', '错误'],
          answerIndexes: {0},
          analysis: '解析3',
        ),
      ],
      answers: const {
        'card_q1': {0},
      },
    );
    final router = _examCardRouter();

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text('答题卡'), findsOneWidget);
    expect(find.text('已答 1'), findsOneWidget);
    expect(find.text('未答 2'), findsOneWidget);

    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.currentIndex, 2);
    expect(find.text('第三题'), findsOneWidget);

    router.go('/exam/card');
    await tester.pumpAndSettle();

    await tester.tap(find.text('返回答题'));
    await tester.pumpAndSettle();

    expect(find.text('第三题'), findsOneWidget);
  });

  testWidgets('exam answer card submit confirmation submits unanswered exam',
      (tester) async {
    mockStore.examSession = ExamSession(
      title: '未答交卷考试',
      mode: '章节考试',
      durationMinutes: 45,
      questions: const [
        Question(
          id: 'submit_q1',
          type: QuestionType.single,
          stem: '已答题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析1',
        ),
        Question(
          id: 'submit_q2',
          type: QuestionType.single,
          stem: '未答题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析2',
        ),
      ],
      answers: const {
        'submit_q1': {0},
      },
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester
        .pumpWidget(MaterialApp.router(routerConfig: _examCardRouter()));
    await tester.pump();

    await tester.tap(find.text('确认交卷'));
    await tester.pumpAndSettle();

    expect(find.text('当前还有 1 题未作答，交卷后无法修改答案。'), findsOneWidget);

    await tester.tap(find.text('确认交卷').last);
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.submitted, isTrue);
    expect(find.text('analysis route'), findsOneWidget);
  });

  testWidgets('wrong analysis navigation stays inside wrong question category',
      (tester) async {
    const questions = [
      Question(
        id: 'analysis_wrong_q1',
        type: QuestionType.single,
        stem: '第一道错题',
        options: ['A', 'B'],
        answerIndexes: {0},
        analysis: '解析1',
      ),
      Question(
        id: 'analysis_right_q2',
        type: QuestionType.single,
        stem: '中间答对题',
        options: ['A', 'B'],
        answerIndexes: {0},
        analysis: '解析2',
      ),
      Question(
        id: 'analysis_wrong_q3',
        type: QuestionType.single,
        stem: '第二道错题',
        options: ['A', 'B'],
        answerIndexes: {0},
        analysis: '解析3',
      ),
    ];
    mockStore.examSession = ExamSession(
      title: '解析分类考试',
      mode: '章节考试',
      durationMinutes: 45,
      submitted: true,
      questions: questions,
      answers: const {
        'analysis_wrong_q1': {1},
        'analysis_right_q2': {0},
        'analysis_wrong_q3': {1},
      },
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const MaterialApp(home: P28BAnalysisWrongPage()));
    await tester.pump();

    expect(find.text('第 1 / 3 题'), findsOneWidget);

    await tester.tap(find.text('下一题'));
    await tester.pump();

    expect(mockStore.examSession?.currentIndex, 2);
    expect(find.text('第 3 / 3 题'), findsOneWidget);
    expect(find.text('中间答对题'), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('analysis overview routes category cards to detail pages',
      (tester) async {
    final router = _analysisRouter();
    mockStore.examSession = ExamSession(
      title: '解析分类考试',
      mode: '章节考试',
      durationMinutes: 45,
      submitted: true,
      questions: const [
        Question(
          id: 'overview_unanswered_q1',
          type: QuestionType.single,
          stem: '未作答题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析1',
        ),
        Question(
          id: 'overview_wrong_q2',
          type: QuestionType.single,
          stem: '错题详情题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析2',
        ),
        Question(
          id: 'overview_correct_q3',
          type: QuestionType.single,
          stem: '对题详情题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析3',
        ),
      ],
      answers: const {
        'overview_wrong_q2': {1},
        'overview_correct_q3': {0},
      },
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pump();

    await tester.tap(find.text('查看全部').at(0));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.currentIndex, 0);
    expect(find.text('未作答题'), findsOneWidget);

    router.go('/exam/analysis');
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看全部').at(1));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.currentIndex, 1);
    expect(find.text('错题详情题'), findsOneWidget);

    router.go('/exam/analysis');
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看全部').at(2));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.currentIndex, 2);
    expect(find.text('对题详情题'), findsOneWidget);
  });

  testWidgets('analysis overview displays elapsed exam minutes',
      (tester) async {
    mockStore.examSession = ExamSession(
      title: '用时展示考试',
      mode: '章节考试',
      durationMinutes: 45,
      remainingSeconds: 45 * 60 - 125,
      submitted: true,
      questions: const [
        Question(
          id: 'elapsed_q1',
          type: QuestionType.single,
          stem: '用时展示题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析',
        ),
      ],
      answers: const {
        'elapsed_q1': {0},
      },
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: P28ExamAnalysisPage()));
    await tester.pump();

    expect(find.text('3分钟'), findsOneWidget);
    expect(find.text('耗时'), findsOneWidget);
  });

  testWidgets('analysis overview number cells open matching category detail',
      (tester) async {
    final router = _analysisRouter();
    mockStore.examSession = ExamSession(
      title: '解析题号考试',
      mode: '章节考试',
      durationMinutes: 45,
      submitted: true,
      questions: const [
        Question(
          id: 'number_unanswered_q1',
          type: QuestionType.single,
          stem: '未作答题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析1',
        ),
        Question(
          id: 'number_wrong_q2',
          type: QuestionType.single,
          stem: '答错题号题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析2',
        ),
        Question(
          id: 'number_correct_q3',
          type: QuestionType.single,
          stem: '答对题号题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析3',
        ),
      ],
      answers: const {
        'number_wrong_q2': {1},
        'number_correct_q3': {0},
      },
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.currentIndex, 1);
    expect(find.text('答错题号题'), findsOneWidget);
  });

  testWidgets('empty analysis category can return to analysis overview',
      (tester) async {
    final router =
        _analysisRouter(initialLocation: '/exam/analysis/unanswered');
    mockStore.examSession = ExamSession(
      title: '空分类考试',
      mode: '章节考试',
      durationMinutes: 45,
      submitted: true,
      questions: const [
        Question(
          id: 'empty_analysis_q1',
          type: QuestionType.single,
          stem: '已答对题',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析1',
        ),
      ],
      answers: const {
        'empty_analysis_q1': {0},
      },
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text('当前分类暂无题目'), findsOneWidget);
    expect(find.text('返回解析总览'), findsOneWidget);

    await tester.tap(find.text('返回解析总览'));
    await tester.pumpAndSettle();

    expect(find.text('查看解析'), findsOneWidget);
    expect(find.text('已答对'), findsOneWidget);
  });

  testWidgets('exam empty standalone pages return to exam home',
      (tester) async {
    mockStore.examSession = null;
    final cardRouter = _examCardRouter();

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: cardRouter));
    await tester.pump();

    expect(find.text('暂无考试答题卡'), findsOneWidget);
    await tester.tap(find.text('返回考试入口'));
    await tester.pumpAndSettle();
    expect(find.text('exam home route'), findsOneWidget);

    final analysisRouter = _analysisRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: analysisRouter));
    await tester.pump();

    expect(find.text('暂无考试解析'), findsOneWidget);
    await tester.tap(find.text('返回考试入口'));
    await tester.pumpAndSettle();
    expect(find.text('exam home route'), findsOneWidget);

    final detailRouter =
        _analysisRouter(initialLocation: '/exam/analysis/wrong');
    await tester.pumpWidget(MaterialApp.router(routerConfig: detailRouter));
    await tester.pump();

    expect(find.text('暂无考试解析'), findsOneWidget);
    await tester.tap(find.text('返回考试入口'));
    await tester.pumpAndSettle();
    expect(find.text('exam home route'), findsOneWidget);
  });

  testWidgets('empty exam answering state returns to exam home',
      (tester) async {
    const question = Question(
      id: 'empty_exam_answer_q1',
      type: QuestionType.single,
      stem: '兜底考试题',
      options: ['A', 'B'],
      answerIndexes: {0},
      analysis: '解析',
    );
    mockStore.examSession = ExamSession(
      title: '兜底考试',
      mode: '章节考试',
      durationMinutes: 45,
      questions: const [question],
    );
    final router = _examAnswerRouter();

    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    mockStore.examSession = null;
    mockStore.notifyListeners();
    await tester.pump();

    expect(find.text('暂无考试内容'), findsOneWidget);

    await tester.tap(find.text('返回考试入口'));
    await tester.pumpAndSettle();

    expect(find.text('exam home route'), findsOneWidget);
  });
}

class _AnalysisMarker extends StatelessWidget {
  const _AnalysisMarker();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('analysis route'),
    );
  }
}

GoRouter _examCardRouter() {
  return GoRouter(
    initialLocation: '/exam/card',
    routes: [
      GoRoute(
        path: '/exam/card',
        builder: (_, __) => const P26AnswerCardPage(),
      ),
      GoRoute(
        path: '/exam/answer',
        builder: (_, __) => const P25ExamAnsweringPage(),
      ),
      GoRoute(
        path: '/exam/analysis',
        builder: (_, __) => const _AnalysisMarker(),
      ),
      GoRoute(
        path: '/exam',
        builder: (_, __) => const _ExamHomeMarker(),
      ),
    ],
  );
}

GoRouter _examAnswerRouter() {
  return GoRouter(
    initialLocation: '/exam/answer',
    routes: [
      GoRoute(
        path: '/exam/answer',
        builder: (_, __) => const P25ExamAnsweringPage(),
      ),
      GoRoute(
        path: '/exam',
        builder: (_, __) => const _ExamHomeMarker(),
      ),
    ],
  );
}

GoRouter _analysisRouter({String initialLocation = '/exam/analysis'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/exam/analysis',
        builder: (_, __) => const P28ExamAnalysisPage(),
      ),
      GoRoute(
        path: '/exam/analysis/unanswered',
        builder: (_, __) => const P28AAnalysisUnansweredPage(),
      ),
      GoRoute(
        path: '/exam/analysis/wrong',
        builder: (_, __) => const P28BAnalysisWrongPage(),
      ),
      GoRoute(
        path: '/exam/analysis/correct',
        builder: (_, __) => const P28CAnalysisCorrectPage(),
      ),
      GoRoute(
        path: '/exam',
        builder: (_, __) => const _ExamHomeMarker(),
      ),
    ],
  );
}

class _ExamHomeMarker extends StatelessWidget {
  const _ExamHomeMarker();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('exam home route'),
    );
  }
}
