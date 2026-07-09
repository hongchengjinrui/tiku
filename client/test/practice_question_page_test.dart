import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('暂无收藏题目'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
