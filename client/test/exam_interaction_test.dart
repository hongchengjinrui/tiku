import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/features/exam/p25_exam_answering_page.dart';
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
