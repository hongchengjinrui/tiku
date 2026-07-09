import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/data/repositories/mock_tiku_repository.dart';
import 'package:tiku_muban/features/practice/p05_question_practice_page.dart';

void main() {
  tearDown(() {
    mockStore.practiceSession = null;
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
}
