import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/data/repositories/mock_tiku_repository.dart';
import 'package:tiku_muban/data/repositories/tiku_repository.dart';
import 'package:tiku_muban/main.dart';
import 'package:tiku_muban/routes/app_router.dart';

void main() {
  late TikuRepository previousRepository;
  late bool previousRemoteReady;
  late List<Chapter> previousPracticeChapters;
  late List<Chapter> previousExamChapters;
  late PracticeSession? previousPracticeSession;
  late ExamSession? previousExamSession;

  setUp(() {
    final repository = MockTikuRepository();
    previousRepository = mockStore.repository;
    previousRemoteReady = mockStore.remoteReady;
    previousPracticeChapters = mockStore.chapters;
    previousExamChapters = mockStore.examChapters;
    previousPracticeSession = mockStore.practiceSession;
    previousExamSession = mockStore.examSession;

    mockStore
      ..repository = repository
      ..remoteReady = false
      ..chapters = repository.loadPracticeChapters()
      ..examChapters = repository.loadExamChapters()
      ..practiceSession = null
      ..examSession = null;
  });

  tearDown(() {
    mockStore
      ..repository = previousRepository
      ..remoteReady = previousRemoteReady
      ..chapters = previousPracticeChapters
      ..examChapters = previousExamChapters
      ..practiceSession = previousPracticeSession
      ..examSession = previousExamSession;
  });

  testWidgets('custom random practice requires and uses selected sections',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/random/custom');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check_circle).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始随机练习'));
    await tester.pump();

    expect(find.text('请选择至少一个章节'), findsOneWidget);
    expect(mockStore.practiceSession, isNull);

    ScaffoldMessenger.of(tester.element(find.text('随机练习'))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('第一节：教育理论'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始随机练习'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.mode, '随机练习');
    expect(mockStore.practiceSession?.title, '自选章节随机练习');
    expect(mockStore.practiceSession?.questions.length, greaterThan(0));
    expect(find.text('自选章节随机练习'), findsOneWidget);
  });

  testWidgets('custom exam assembly requires and uses selected sections',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/exam/assemble');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check_circle).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始考试'));
    await tester.pump();

    expect(find.text('请选择至少一个章节'), findsOneWidget);
    expect(mockStore.examSession, isNull);

    ScaffoldMessenger.of(tester.element(find.text('组卷设置'))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('第一节：教育理论'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始考试'));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.mode, '组卷考试');
    expect(mockStore.examSession?.title, '自选章节组卷');
    expect(mockStore.examSession?.questions.length, greaterThan(0));
    expect(find.text('组卷考试'), findsOneWidget);
  });
}
