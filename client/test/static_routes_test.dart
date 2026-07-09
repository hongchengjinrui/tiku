import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/data/mock/models.dart';
import 'package:tiku_muban/data/mock/mock_app_store.dart';
import 'package:tiku_muban/main.dart';
import 'package:tiku_muban/routes/app_router.dart';

void main() {
  const staticRoutes = [
    '/splash',
    '/practice',
    '/practice/switch-subject',
    '/practice/catalog',
    '/practice/reset',
    '/practice/reset/all',
    '/practice/reset/level2',
    '/practice/reset/custom',
    '/practice/reset/confirm',
    '/practice/sections',
    '/practice/sections/reset-confirm',
    '/practice/papers',
    '/practice/papers/reset-confirm',
    '/practice/quiz',
    '/practice/random',
    '/practice/random/custom',
    '/practice/favorite',
    '/practice/wrong',
    '/practice/wrong/clear-confirm',
    '/practice/wrong/quiz',
    '/exam',
    '/exam/rules',
    '/exam/catalog',
    '/exam/sections',
    '/exam/retake-confirm',
    '/exam/papers',
    '/exam/reset',
    '/exam/reset/all',
    '/exam/reset/level2',
    '/exam/reset/custom',
    '/exam/reset/confirm',
    '/exam/assemble',
    '/exam/assemble/all',
    '/exam/answer',
    '/exam/card',
    '/exam/submit-confirm',
    '/exam/submit-confirm/all-answered',
    '/exam/analysis',
    '/exam/analysis/unanswered',
    '/exam/analysis/wrong',
    '/exam/analysis/correct',
    '/resources',
    '/resources/free',
    '/resources/free/toast',
    '/resources/paid',
    '/resources/unlocked',
    '/vip',
    '/vip/success',
    '/profile',
    '/profile/practice-records',
    '/profile/practice-records/delete',
    '/profile/practice-records/delete-all',
    '/profile/exam-records',
    '/profile/exam-records/delete',
    '/profile/exam-records/delete-all',
    '/profile/resource-claims',
    '/profile/wrong',
    '/profile/upload',
    '/profile/correction',
    '/profile/feedback',
    '/profile/cache',
    '/profile/about',
    '/profile/vip',
    '/login',
    '/login/quick',
    '/agreement/member',
    '/agreement/user',
    '/agreement/privacy',
    '/empty/practice',
    '/empty/wrong',
    '/empty/favorite',
    '/empty/exam',
    '/qt/single',
    '/qt/multiple',
    '/qt/truefalse',
    '/qt/fillblank',
    '/qt/short',
    '/qt/material',
    '/qt/image',
    '/qt/image-error',
    '/qt/single/result',
    '/qt/multiple/result',
    '/qt/truefalse/result',
    '/qt/fillblank/result',
    '/qt/short/result',
    '/qt/material/result',
    '/qt/image/result',
    '/qt/multi-image/result',
    '/qt/analysis-images/result',
  ];

  testWidgets('all static routes build', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    for (final route in staticRoutes) {
      appRouter.go(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final exception = tester.takeException();
      if (exception is FlutterError) {
        fail('$route\n${exception.toStringDeep()}');
      }
      expect(exception, isNull, reason: route);
      expect(find.byType(MaterialApp), findsOneWidget, reason: route);
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('bottom tab bar switches between main roots', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice');
    await tester.pumpAndSettle();
    expect(find.text('练习入口'), findsOneWidget);

    await tester.tap(find.text('考试').last);
    await tester.pumpAndSettle();
    expect(find.text('考试入口'), findsOneWidget);

    await tester.tap(find.text('资料').last);
    await tester.pumpAndSettle();
    expect(find.text('免费资料 · VIP专享资料'), findsOneWidget);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(find.text('本地体验用户'), findsOneWidget);

    await tester.tap(find.text('练习').last);
    await tester.pumpAndSettle();
    expect(find.text('练习入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile opens resource claim records', (tester) async {
    final previousClaims = mockStore.resourceClaims;
    addTearDown(() => mockStore.resourceClaims = previousClaims);
    mockStore.resourceClaims = [
      ResourceClaim(
        resourceId: 'claim_test_1',
        title: '资料领取测试',
        link: 'local://claim-test',
        subjectName: '小学教师',
        isFree: true,
        count: 2,
        lastClaimedAt: DateTime(2026, 7, 9, 9, 30),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile');
    await tester.pumpAndSettle();
    await tester.tap(find.text('资料领取'));
    await tester.pumpAndSettle();

    expect(find.text('资料领取记录'), findsOneWidget);
    expect(find.text('资料领取测试'), findsOneWidget);
    expect(find.text('已领取2次'), findsOneWidget);
    expect(find.text('复制链接'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('home record sections show empty states after records cleared',
      (tester) async {
    final previousPracticeRecords = mockStore.practiceRecords;
    final previousExamRecords = mockStore.examRecords;
    addTearDown(() {
      mockStore.practiceRecords = previousPracticeRecords;
      mockStore.examRecords = previousExamRecords;
    });

    mockStore.practiceRecords = const [];
    mockStore.examRecords = const [];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice');
    await tester.pumpAndSettle();
    expect(find.text('暂无练习记录'), findsOneWidget);

    appRouter.go('/exam');
    await tester.pumpAndSettle();
    expect(find.text('暂无考试记录'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
