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
  late List<Paper> previousExamPapers;
  late List<StudyRecord> previousPracticeRecords;
  late List<StudyRecord> previousExamRecords;
  late PracticeSession? previousPracticeSession;
  late ExamSession? previousExamSession;

  setUp(() {
    final repository = MockTikuRepository();
    previousRepository = mockStore.repository;
    previousRemoteReady = mockStore.remoteReady;
    previousPracticeChapters = mockStore.chapters;
    previousExamChapters = mockStore.examChapters;
    previousExamPapers = mockStore.examPapers;
    previousPracticeRecords = mockStore.practiceRecords;
    previousExamRecords = mockStore.examRecords;
    previousPracticeSession = mockStore.practiceSession;
    previousExamSession = mockStore.examSession;

    mockStore
      ..repository = repository
      ..remoteReady = false
      ..chapters = repository.loadPracticeChapters()
      ..examChapters = repository.loadExamChapters()
      ..examPapers = repository.loadExamPapers()
      ..practiceRecords = const [
        StudyRecord(
          id: 'practice_record_flow_1',
          title: '第一节：教育理论',
          mode: '章节练习',
          metric: '18/28题 · 正确率 83%',
          time: '今天',
        ),
      ]
      ..examRecords = const [
        StudyRecord(
          id: 'exam_record_flow_unsubmitted',
          title: '第一节：教育理论',
          mode: '章节考试',
          metric: '未交卷',
          time: '今天',
        ),
        StudyRecord(
          id: 'exam_record_flow_submitted',
          title: '第二节：教育心理',
          mode: '章节考试',
          metric: '正确率 80%',
          time: '昨天',
        ),
      ]
      ..practiceSession = null
      ..examSession = null;
  });

  tearDown(() {
    mockStore
      ..repository = previousRepository
      ..remoteReady = previousRemoteReady
      ..chapters = previousPracticeChapters
      ..examChapters = previousExamChapters
      ..examPapers = previousExamPapers
      ..practiceRecords = previousPracticeRecords
      ..examRecords = previousExamRecords
      ..practiceSession = previousPracticeSession
      ..examSession = previousExamSession;
  });

  testWidgets('record list actions restore practice and exam flows',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/practice-records');
    await tester.pumpAndSettle();
    await tester.tap(find.text('重新练习'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.mode, '章节练习');
    expect(mockStore.practiceSession?.title, '第一节：教育理论');
    expect(find.text('第一节：教育理论'), findsWidgets);

    appRouter.go('/profile/exam-records');
    await tester.pumpAndSettle();
    await tester.tap(find.text('继续考试'));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.mode, '章节考试');
    expect(mockStore.examSession?.submitted, isFalse);
    expect(mockStore.examSession?.title, '第一节：教育理论');
    expect(find.text('剩余 45:00'), findsOneWidget);

    appRouter.go('/profile/exam-records');
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看解析'));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.mode, '章节考试');
    expect(mockStore.examSession?.submitted, isTrue);
    expect(find.text('查看解析'), findsWidgets);
  });

  testWidgets('record list delete actions update local lists and counters',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/practice-records');
    await tester.pumpAndSettle();
    expect(find.text('记录 1条'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('删除这条练习记录？'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '删除'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceRecords, isEmpty);
    expect(find.text('记录 0条'), findsOneWidget);
    expect(find.text('暂无练习记录'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.text('全部练习记录'))).clearSnackBars();
    await tester.pumpAndSettle();

    appRouter.go('/profile/exam-records');
    await tester.pumpAndSettle();
    expect(find.text('考试 2次'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('删除这条考试记录？'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '删除'));
    await tester.pumpAndSettle();

    expect(mockStore.examRecords.length, 1);
    expect(find.text('考试 1次'), findsOneWidget);
    expect(find.text('第一节：教育理论'), findsNothing);
    expect(find.text('第二节：教育心理'), findsOneWidget);
  });
}
