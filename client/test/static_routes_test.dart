import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/core/app_scaffold.dart';
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
    '/profile/feedback-records',
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
    expect(find.text('2份VIP备考资料+1份免费备考资料'), findsOneWidget);

    await tester.tap(find.text('我的').last);
    await tester.pumpAndSettle();
    expect(find.text('本地体验用户'), findsOneWidget);

    await tester.tap(find.text('练习').last);
    await tester.pumpAndSettle();
    expect(find.text('练习入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('bottom tab bar accepts taps across equal hit areas',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice');
    await tester.pumpAndSettle();

    Future<void> tapTabCenter(int index) async {
      final barRect = tester.getRect(find.byType(BottomTabBar));
      final center = Offset(
        barRect.left + barRect.width * (index + 0.5) / 4,
        barRect.center.dy,
      );
      await tester.tapAt(center);
      await tester.pumpAndSettle();
    }

    await tapTabCenter(1);
    expect(find.text('考试入口'), findsOneWidget);

    await tapTabCenter(2);
    expect(find.text('2份VIP备考资料+1份免费备考资料'), findsOneWidget);

    await tapTabCenter(3);
    expect(find.text('本地体验用户'), findsOneWidget);

    await tapTabCenter(0);
    expect(find.text('练习入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('subject switch sheet updates the active subject in UI',
      (tester) async {
    final previousSubjectId = mockStore.selectedSubjectId;
    final previousPracticeSession = mockStore.practiceSession;
    final previousExamSession = mockStore.examSession;
    addTearDown(() async {
      await mockStore.selectSubject(previousSubjectId);
      mockStore.practiceSession = previousPracticeSession;
      mockStore.examSession = previousExamSession;
    });

    await mockStore.selectSubject('primary_teacher');
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/switch-subject');
    await tester.pumpAndSettle();
    await tester.tap(find.text('中学教师'));
    await tester.pumpAndSettle();

    expect(mockStore.selectedSubjectId, 'middle_teacher');

    appRouter.go('/practice');
    await tester.pumpAndSettle();
    expect(find.text('中学教师'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('exam and resource subject switches return to source pages',
      (tester) async {
    final previousSubjectId = mockStore.selectedSubjectId;
    final previousPracticeSession = mockStore.practiceSession;
    final previousExamSession = mockStore.examSession;
    addTearDown(() async {
      await mockStore.selectSubject(previousSubjectId);
      mockStore.practiceSession = previousPracticeSession;
      mockStore.examSession = previousExamSession;
    });

    await mockStore.selectSubject('primary_teacher');
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/exam');
    await tester.pumpAndSettle();
    await tester.tap(find.text('切换科目'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('中学教师'));
    await tester.pumpAndSettle();

    expect(mockStore.selectedSubjectId, 'middle_teacher');
    expect(find.text('考试入口'), findsOneWidget);
    expect(find.text('中学教师'), findsOneWidget);

    appRouter.go('/resources');
    await tester.pumpAndSettle();
    await tester.tap(find.text('切换科目'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('教师招聘'));
    await tester.pumpAndSettle();

    expect(mockStore.selectedSubjectId, 'teacher_recruit');
    expect(find.text('2份VIP备考资料+1份免费备考资料'), findsOneWidget);
    expect(find.text('教师招聘'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile opens resource claim records', (tester) async {
    final previousClaims = mockStore.resourceClaims;
    addTearDown(() => mockStore.resourceClaims = previousClaims);
    final copiedLinks = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        final args = Map<String, Object?>.from(call.arguments as Map);
        copiedLinks.add(args['text']?.toString() ?? '');
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
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

    await tester.tap(find.text('复制链接'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(copiedLinks, ['local://claim-test']);
    expect(find.text('资料链接已经复制'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('empty resource claim records return to resources',
      (tester) async {
    final previousClaims = mockStore.resourceClaims;
    addTearDown(() => mockStore.resourceClaims = previousClaims);
    mockStore.resourceClaims = const [];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/resource-claims');
    await tester.pumpAndSettle();

    expect(find.text('暂无资料领取记录'), findsOneWidget);

    await tester.tap(find.text('去资料中心'));
    await tester.pumpAndSettle();

    expect(find.text('2份VIP备考资料+1份免费备考资料'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile maintenance entry opens guidance and feedback handoff',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile');
    await tester.pumpAndSettle();
    await tester.tap(find.text('上传题库'));
    await tester.pumpAndSettle();

    expect(find.text('题库维护'), findsOneWidget);
    expect(find.text('当前 APP 不直接上传题库'), findsOneWidget);

    await tester.tap(find.text('提交题库维护建议'));
    await tester.pumpAndSettle();
    expect(find.text('意见反馈'), findsOneWidget);
    expect(find.text('反馈内容'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('unlocked resource download creates a claim record',
      (tester) async {
    final previousClaims = mockStore.resourceClaims;
    addTearDown(() => mockStore.resourceClaims = previousClaims);
    mockStore.resourceClaims = const [];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/resources/unlocked');
    await tester.pumpAndSettle();
    await tester.tap(find.text('下载资料'));
    await tester.pumpAndSettle();

    expect(mockStore.resourceClaimFor('fallback_vip_1')?.count, 1);

    appRouter.go('/profile/resource-claims');
    await tester.pumpAndSettle();
    expect(find.text('教育基础高频考点速记'), findsOneWidget);
    expect(find.text('已领取1次'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('resource detail routes keep free and vip defaults separated',
      (tester) async {
    final previousClaims = mockStore.resourceClaims;
    addTearDown(() => mockStore.resourceClaims = previousClaims);
    mockStore.resourceClaims = const [];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/resources/free');
    await tester.pumpAndSettle();
    expect(find.text('入门备考规划清单'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('教育基础高频考点速记'), findsNothing);

    appRouter.go('/resources/paid');
    await tester.pumpAndSettle();
    expect(find.text('教育基础高频考点速记'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('入门备考规划清单'), findsNothing);

    await tester.tap(find.text('获取下载链接'));
    await tester.pump();
    expect(mockStore.resourceClaimFor('fallback_vip_1')?.count, 1);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('vip placeholder stays in open-experience mode', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/vip');
    await tester.pumpAndSettle();

    expect(find.text('开放体验模式'), findsOneWidget);
    expect(find.text('开放体验'), findsOneWidget);
    expect(find.text('后续接入范围'), findsOneWidget);
    expect(find.text('开通VIP'), findsNothing);
    expect(find.text('选择套餐'), findsNothing);
    expect(find.text('¥18'), findsNothing);
    expect(find.text('支付方式'), findsNothing);

    await tester.tap(find.text('返回资料中心'));
    await tester.pumpAndSettle();

    expect(find.text('2份VIP备考资料+1份免费备考资料'), findsOneWidget);

    appRouter.go('/vip/success');
    await tester.pumpAndSettle();

    expect(find.text('当前为开放体验模式'), findsOneWidget);
    expect(find.text('支付成功'), findsNothing);

    await tester.tap(find.text('继续刷题'));
    await tester.pumpAndSettle();

    expect(find.text('练习入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('login routes stay in local guest placeholder mode',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/login');
    await tester.pumpAndSettle();

    await tester.tap(find.text('获取验证码'));
    await tester.pump();
    expect(find.text('登录能力将在上架前接入，当前使用本地游客模式'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.wechat));
    await tester.pump();
    expect(find.text('登录能力将在上架前接入，当前使用本地游客模式'), findsOneWidget);

    await tester.tap(find.text('登录 / 注册'));
    await tester.pumpAndSettle();
    expect(find.text('本地体验用户'), findsOneWidget);

    appRouter.go('/login/quick');
    await tester.pumpAndSettle();
    await tester.tap(find.text('一键绑定登录'));
    await tester.pump();
    expect(find.text('登录能力将在上架前接入，当前使用本地游客模式'), findsOneWidget);

    await tester.tap(find.text('其他方式登录'));
    await tester.pumpAndSettle();
    expect(find.text('题库母版'), findsOneWidget);
    expect(find.text('登录 / 注册'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('本地体验用户'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile opens pending feedback records', (tester) async {
    final previousFeedbacks = mockStore.feedbackSubmissions;
    addTearDown(() => mockStore.feedbackSubmissions = previousFeedbacks);
    mockStore.feedbackSubmissions = [
      FeedbackSubmission(
        id: 'feedback_test_1',
        type: 'analysis_error',
        content: '这道题解析需要补充关键步骤',
        payload: const {
          'label': '解析有误',
          'questionId': 'question_001',
        },
        createdAt: DateTime(2026, 7, 9, 10, 20),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile');
    await tester.pumpAndSettle();
    await tester.tap(find.text('反馈记录'));
    await tester.pumpAndSettle();

    expect(find.text('反馈记录'), findsOneWidget);
    expect(find.text('1 条待同步反馈'), findsOneWidget);
    expect(find.text('解析有误'), findsOneWidget);
    expect(find.text('这道题解析需要补充关键步骤'), findsOneWidget);
    expect(find.text('关联题目：question_001'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile feedback forms queue local pending submissions',
      (tester) async {
    final previousFeedbacks = mockStore.feedbackSubmissions;
    addTearDown(() => mockStore.feedbackSubmissions = previousFeedbacks);
    mockStore.feedbackSubmissions = const [];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/feedback');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '希望增加章节错题导出能力');
    await tester.ensureVisible(find.text('提交反馈'));
    await tester.tap(find.text('提交反馈'));
    await tester.pump();
    expect(find.text('反馈已提交'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    appRouter.go('/profile/correction');
    await tester.pumpAndSettle();
    await tester.tap(find.text('答案有误'));
    await tester.enterText(find.byType(TextField), '第12题答案应为B');
    await tester.ensureVisible(find.text('提交纠错'));
    await tester.tap(find.text('提交纠错'));
    await tester.pumpAndSettle();

    appRouter.go('/profile/feedback-records');
    await tester.pumpAndSettle();
    expect(find.text('2 条待同步反馈'), findsOneWidget);
    expect(find.text('希望增加章节错题导出能力'), findsOneWidget);
    expect(find.text('第12题答案应为B'), findsOneWidget);
    expect(find.text('答案有误'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('feedback records can remove a pending item', (tester) async {
    final previousFeedbacks = mockStore.feedbackSubmissions;
    addTearDown(() => mockStore.feedbackSubmissions = previousFeedbacks);
    mockStore.feedbackSubmissions = [
      FeedbackSubmission(
        id: 'feedback_remove_1',
        type: 'app_feedback',
        content: '这条反馈准备移除',
        payload: const {'source': 'remove_test'},
        createdAt: DateTime(2026, 7, 9, 12, 10),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/feedback-records');
    await tester.pumpAndSettle();
    await tester.tap(find.text('移除').first);
    await tester.pumpAndSettle();
    expect(find.text('移除这条反馈？'), findsOneWidget);

    await tester.tap(find.text('移除').last);
    await tester.pumpAndSettle();

    expect(find.text('暂无待同步反馈'), findsOneWidget);
    expect(mockStore.feedbackSubmissions, isEmpty);

    appRouter.go('/profile/cache');
    await tester.pumpAndSettle();
    expect(find.text('0条'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('feedback records can clear all and return to feedback form',
      (tester) async {
    final previousFeedbacks = mockStore.feedbackSubmissions;
    addTearDown(() => mockStore.feedbackSubmissions = previousFeedbacks);
    mockStore.feedbackSubmissions = [
      FeedbackSubmission(
        id: 'feedback_clear_1',
        type: 'app_feedback',
        content: '准备批量清空的反馈一',
        payload: const {'source': 'clear_test'},
        createdAt: DateTime(2026, 7, 9, 12, 10),
      ),
      FeedbackSubmission(
        id: 'feedback_clear_2',
        type: 'analysis_error',
        content: '准备批量清空的反馈二',
        payload: const {
          'label': '解析有误',
          'questionId': 'question_clear_2',
        },
        createdAt: DateTime(2026, 7, 9, 12, 20),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/feedback-records');
    await tester.pumpAndSettle();

    expect(find.text('2 条待同步反馈'), findsOneWidget);

    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();
    expect(find.text('清空待同步反馈？'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '清空'));
    await tester.pumpAndSettle();

    expect(mockStore.feedbackSubmissions, isEmpty);
    expect(find.text('暂无待同步反馈'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.text('反馈记录'))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('去反馈'));
    await tester.pumpAndSettle();

    expect(find.text('意见反馈'), findsOneWidget);
    expect(find.text('反馈内容'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('cache pending feedback count opens feedback records',
      (tester) async {
    final previousFeedbacks = mockStore.feedbackSubmissions;
    addTearDown(() => mockStore.feedbackSubmissions = previousFeedbacks);
    mockStore.feedbackSubmissions = [
      FeedbackSubmission(
        id: 'feedback_cache_1',
        type: 'app_feedback',
        content: '缓存页跳转反馈记录',
        payload: const {'source': 'cache_test'},
        createdAt: DateTime(2026, 7, 9, 11, 10),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/cache');
    await tester.pumpAndSettle();
    await tester.tap(find.text('待同步反馈'));
    await tester.pumpAndSettle();

    expect(find.text('反馈记录'), findsOneWidget);
    expect(find.text('缓存页跳转反馈记录'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('cache management routes and actions are interactive',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/cache');
    await tester.pumpAndSettle();
    await tester.tap(find.text('练习记录'));
    await tester.pumpAndSettle();
    expect(find.text('全部练习记录'), findsOneWidget);

    appRouter.go('/profile/cache');
    await tester.pumpAndSettle();
    await tester.tap(find.text('章节目录'));
    await tester.pumpAndSettle();
    expect(find.text('练习模式'), findsOneWidget);

    appRouter.go('/profile/cache');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('同步缓存'));
    await tester.tap(find.text('同步缓存'));
    await tester.pump();
    expect(find.text('本地缓存已同步'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('清除本地缓存'));
    await tester.tap(find.text('清除本地缓存'));
    await tester.pumpAndSettle();
    expect(find.text('清除本地缓存？'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '清除').last);
    await tester.pumpAndSettle();
    expect(find.text('清除本地缓存？'), findsNothing);
    expect(find.text('缓存管理'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('about page links agreements and update check', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('关于我们').last);
    await tester.tap(find.text('关于我们').last);
    await tester.pumpAndSettle();

    expect(find.text('题库母版'), findsOneWidget);
    expect(find.text('版本号 V1.0.0'), findsOneWidget);

    await tester.tap(find.text('检查更新'));
    await tester.pump();
    expect(find.text('当前已是最新版本'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.text('关于我们'))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('用户协议'));
    await tester.pumpAndSettle();
    expect(find.text('第1条 服务条款'), findsOneWidget);

    appRouter.go('/profile/about');
    await tester.pumpAndSettle();
    await tester.tap(find.text('隐私协议'));
    await tester.pumpAndSettle();
    expect(find.text('第1条 信息收集'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile wrong entry opens the full wrong practice settings',
      (tester) async {
    final previousWrongQuestions = mockStore.wrongQuestions;
    final previousSession = mockStore.practiceSession;
    addTearDown(() {
      mockStore.wrongQuestions = previousWrongQuestions;
      mockStore.practiceSession = previousSession;
    });
    mockStore.wrongQuestions = [
      Question(
        id: 'profile_wrong_entry_q1',
        type: QuestionType.single,
        stem: '我的页错题入口测试题',
        options: const ['A', 'B'],
        answerIndexes: const {0},
        analysis: '解析',
        wrongCount: 2,
        lastWrongAt: DateTime(2026, 7, 9, 12),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/wrong');
    await tester.pumpAndSettle();
    expect(find.text('条件筛选'), findsOneWidget);
    expect(find.text('错题练习设置'), findsOneWidget);
    expect(mockStore.practiceSession, previousSession);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile wrong empty entry returns to practice home',
      (tester) async {
    final previousWrongQuestions = mockStore.wrongQuestions;
    final previousSession = mockStore.practiceSession;
    addTearDown(() {
      mockStore.wrongQuestions = previousWrongQuestions;
      mockStore.practiceSession = previousSession;
    });
    mockStore.wrongQuestions = const [];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/wrong');
    await tester.pumpAndSettle();

    expect(find.textContaining('暂无错题。'), findsOneWidget);

    await tester.tap(find.text('去练习'));
    await tester.pumpAndSettle();

    expect(find.text('练习入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('favorite practice starts from the selected type filter',
      (tester) async {
    final previousFavorites = mockStore.favoriteQuestions;
    final previousSession = mockStore.practiceSession;
    addTearDown(() {
      mockStore.favoriteQuestions = previousFavorites;
      mockStore.practiceSession = previousSession;
    });
    mockStore.favoriteQuestions = const [
      Question(
        id: 'favorite_filter_single',
        type: QuestionType.single,
        stem: '单选收藏题',
        options: ['A', 'B'],
        answerIndexes: {0},
        analysis: '解析',
      ),
      Question(
        id: 'favorite_filter_fill',
        type: QuestionType.fillBlank,
        stem: '填空收藏题',
        options: [],
        answerIndexes: {},
        answerText: '答案',
        analysis: '解析',
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/favorite');
    await tester.pumpAndSettle();
    await tester.tap(find.text('填空').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始收藏练习（1题）'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.mode, '收藏练习');
    expect(mockStore.practiceSession?.questions.map((item) => item.id),
        ['favorite_filter_fill']);
    expect(find.text('填空收藏题'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('wrong practice applies filters and removal rule',
      (tester) async {
    final previousWrongQuestions = mockStore.wrongQuestions;
    final previousCorrectCounts = mockStore.wrongCorrectCounts;
    final previousSession = mockStore.practiceSession;
    addTearDown(() {
      mockStore.wrongQuestions = previousWrongQuestions;
      mockStore.wrongCorrectCounts = previousCorrectCounts;
      mockStore.practiceSession = previousSession;
    });
    mockStore.wrongQuestions = [
      Question(
        id: 'wrong_filter_single',
        type: QuestionType.single,
        stem: '多次错误单选题',
        options: const ['A', 'B'],
        answerIndexes: const {0},
        analysis: '解析',
        wrongCount: 3,
        lastWrongAt: DateTime(2026, 7, 9, 12),
      ),
      Question(
        id: 'wrong_filter_fill',
        type: QuestionType.fillBlank,
        stem: '一次错误填空题',
        options: const [],
        answerIndexes: const {},
        answerText: '答案',
        analysis: '解析',
        wrongCount: 1,
        lastWrongAt: DateTime(2026, 6, 20, 12),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/wrong');
    await tester.pumpAndSettle();
    await tester.tap(find.text('多次错误'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('做对3次移除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始错题练习（1题）'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.mode, '错题练习');
    expect(mockStore.practiceSession?.wrongRemovalThreshold, 3);
    expect(mockStore.practiceSession?.questions.map((item) => item.id),
        ['wrong_filter_single']);
    expect(find.text('多次错误单选题'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('wrong practice clear action only removes current filtered items',
      (tester) async {
    final previousWrongQuestions = mockStore.wrongQuestions;
    final previousCorrectCounts = mockStore.wrongCorrectCounts;
    final previousSession = mockStore.practiceSession;
    addTearDown(() {
      mockStore.wrongQuestions = previousWrongQuestions;
      mockStore.wrongCorrectCounts = previousCorrectCounts;
      mockStore.practiceSession = previousSession;
    });
    mockStore.wrongQuestions = [
      Question(
        id: 'wrong_clear_multi',
        type: QuestionType.single,
        stem: '待清空的多次错题',
        options: const ['A', 'B'],
        answerIndexes: const {0},
        analysis: '解析',
        wrongCount: 3,
        lastWrongAt: DateTime(2026, 7, 9, 12),
      ),
      Question(
        id: 'wrong_clear_keep',
        type: QuestionType.fillBlank,
        stem: '应保留的一次错题',
        options: const [],
        answerIndexes: const {},
        answerText: '答案',
        analysis: '解析',
        wrongCount: 1,
        lastWrongAt: DateTime(2026, 7, 8, 12),
      ),
    ];
    mockStore.wrongCorrectCounts = const {
      'wrong_clear_multi': 1,
      'wrong_clear_keep': 1,
    };

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/wrong');
    await tester.pumpAndSettle();
    await tester.tap(find.text('多次错误'));
    await tester.pumpAndSettle();

    expect(find.text('多次错误 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('确认清空错题？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(mockStore.wrongQuestions.map((item) => item.id), [
      'wrong_clear_multi',
      'wrong_clear_keep',
    ]);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认清空'));
    await tester.pumpAndSettle();

    expect(
        mockStore.wrongQuestions.map((item) => item.id), ['wrong_clear_keep']);
    expect(
        mockStore.wrongCorrectCounts.containsKey('wrong_clear_multi'), isFalse);
    expect(mockStore.wrongCorrectCounts['wrong_clear_keep'], 1);
    expect(find.text('已移出当前筛选错题'), findsOneWidget);
    expect(find.text('当前筛选条件下暂无错题，可调整条件或题型后再开始练习。'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('wrong practice empty states reset filters or return to practice',
      (tester) async {
    final previousWrongQuestions = mockStore.wrongQuestions;
    final previousSession = mockStore.practiceSession;
    addTearDown(() {
      mockStore.wrongQuestions = previousWrongQuestions;
      mockStore.practiceSession = previousSession;
    });
    mockStore.wrongQuestions = [
      Question(
        id: 'wrong_empty_filter_fill',
        type: QuestionType.fillBlank,
        stem: '筛选恢复填空题',
        options: const [],
        answerIndexes: const {},
        answerText: '答案',
        analysis: '解析',
        wrongCount: 1,
        lastWrongAt: DateTime(2026, 7, 9, 12),
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/wrong');
    await tester.pumpAndSettle();
    await tester.tap(find.text('多次错误'));
    await tester.pumpAndSettle();

    expect(find.text('当前筛选条件下暂无错题，可调整条件或题型后再开始练习。'), findsOneWidget);

    await tester.tap(find.text('重置筛选'));
    await tester.pumpAndSettle();

    expect(find.text('开始错题练习（1题）'), findsOneWidget);

    mockStore.wrongQuestions = const [];
    mockStore.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('暂无错题。完成练习并出现答错题目后，可从这里进入错题练习。'), findsOneWidget);

    await tester.tap(find.text('去练习'));
    await tester.pumpAndSettle();

    expect(find.text('练习入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('practice list wrong entries open wrong practice settings',
      (tester) async {
    final previousSession = mockStore.practiceSession;
    addTearDown(() => mockStore.practiceSession = previousSession);

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    mockStore.practiceSession = null;
    appRouter.go('/practice/sections');
    await tester.pumpAndSettle();
    await tester.tap(find.text('错题').first);
    await tester.pumpAndSettle();
    expect(find.text('条件筛选'), findsOneWidget);
    expect(mockStore.practiceSession, isNull);

    appRouter.go('/practice/papers');
    await tester.pumpAndSettle();
    await tester.tap(find.text('错题').first);
    await tester.pumpAndSettle();
    expect(find.text('条件筛选'), findsOneWidget);
    expect(mockStore.practiceSession, isNull);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('all chapter assembly starts an exam session', (tester) async {
    final previousExamSession = mockStore.examSession;
    addTearDown(() => mockStore.examSession = previousExamSession);

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/exam/assemble/all');
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始考试'));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.mode, '组卷考试');
    expect(mockStore.examSession?.questions.length, greaterThan(0));
    expect(find.text('组卷考试'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('custom random practice starts a scoped practice session',
      (tester) async {
    final previousPracticeSession = mockStore.practiceSession;
    addTearDown(() => mockStore.practiceSession = previousPracticeSession);

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice/random/custom');
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始随机练习'));
    await tester.pumpAndSettle();

    expect(mockStore.practiceSession?.title, '自选章节随机练习');
    expect(mockStore.practiceSession?.mode, '随机练习');
    expect(mockStore.practiceSession?.questions.length, greaterThan(0));
    expect(find.text('自选章节随机练习'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('custom assembly starts a scoped exam session', (tester) async {
    final previousExamSession = mockStore.examSession;
    addTearDown(() => mockStore.examSession = previousExamSession);

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/exam/assemble');
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始考试'));
    await tester.pumpAndSettle();

    expect(mockStore.examSession?.title, '自选章节组卷');
    expect(mockStore.examSession?.mode, '组卷考试');
    expect(mockStore.examSession?.questions.length, greaterThan(0));
    expect(find.text('组卷考试'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('standalone overlay routes provide safe actions', (tester) async {
    final previousExamSession = mockStore.examSession;
    addTearDown(() => mockStore.examSession = previousExamSession);

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/exam/rules');
    await tester.pumpAndSettle();
    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();
    expect(find.text('考试入口'), findsOneWidget);

    appRouter.go('/practice/sections/reset-confirm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('返回修改'));
    await tester.pumpAndSettle();
    expect(find.textContaining('章节练习/'), findsOneWidget);

    appRouter.go('/practice/papers/reset-confirm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认重置'));
    await tester.pumpAndSettle();
    expect(find.text('真题练习'), findsOneWidget);

    mockStore.examSession = ExamSession(
      title: '独立交卷测试',
      mode: '章节考试',
      durationMinutes: 45,
      questions: const [
        Question(
          id: 'standalone_submit_q1',
          type: QuestionType.single,
          stem: '独立交卷题干',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析',
        ),
      ],
      answers: const {
        'standalone_submit_q1': {0},
      },
    );
    appRouter.go('/exam/submit-confirm/all-answered');
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认交卷'));
    await tester.pumpAndSettle();
    expect(mockStore.examSession?.submitted, isTrue);
    expect(find.text('查看解析'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('empty state actions return to study roots', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/empty/practice');
    await tester.pumpAndSettle();
    await tester.tap(find.text('去练习'));
    await tester.pumpAndSettle();
    expect(find.text('练习入口'), findsOneWidget);

    appRouter.go('/empty/wrong');
    await tester.pumpAndSettle();
    await tester.tap(find.text('去练习'));
    await tester.pumpAndSettle();
    expect(find.text('练习入口'), findsOneWidget);

    appRouter.go('/empty/favorite');
    await tester.pumpAndSettle();
    await tester.tap(find.text('去练习'));
    await tester.pumpAndSettle();
    expect(find.text('练习入口'), findsOneWidget);

    appRouter.go('/empty/exam');
    await tester.pumpAndSettle();
    await tester.tap(find.text('去考试'));
    await tester.pumpAndSettle();
    expect(find.text('考试入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('question type demo pages navigate through answer states',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/qt/single');
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.text('以下哪些属于新课程改革的具体目标？（多选）'), findsOneWidget);

    await tester.tap(find.text('上一题'));
    await tester.pumpAndSettle();
    expect(find.text('在教师资格证考试中，教育观的核心内容是什么？'), findsOneWidget);

    appRouter.go('/qt/truefalse');
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.textContaining('皮亚杰将儿童认知发展分为四个阶段'), findsOneWidget);

    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.text('简述建构主义学习理论的基本观点。'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('advanced question type answer pages keep navigation chain',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/qt/short');
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.text('第1题（单选）：该教师采用的教学方法属于？'), findsOneWidget);

    await tester.tap(find.text('上一题'));
    await tester.pumpAndSettle();
    expect(find.text('简述建构主义学习理论的基本观点。'), findsOneWidget);

    appRouter.go('/qt/material');
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.text('根据下方图片回答问题：'), findsOneWidget);

    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.text('图片加载失败'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('question type answer pages can open their result states',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    final cases = <String, String>{
      '/qt/single': '教育观强调以学生发展为中心',
      '/qt/multiple': '新课程改革强调课程功能',
      '/qt/truefalse': '社会本位论强调教育目的',
      '/qt/fillblank': '皮亚杰认知发展阶段依次为',
      '/qt/short': '8/10',
      '/qt/material': '材料中教师组织学生分组讨论',
      '/qt/image': '图片中教师通过直观展示',
      '/qt/image-error': '图片中教师通过直观展示',
    };

    for (final entry in cases.entries) {
      appRouter.go(entry.key);
      await tester.pumpAndSettle();
      await tester.tap(find.text('查看解析'));
      await tester.pumpAndSettle();
      expect(find.textContaining(entry.value), findsOneWidget);
    }

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('question type result pages navigate through review states',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/qt/single/result');
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.text('以下哪些属于新课程改革的具体目标？（多选）'), findsOneWidget);

    await tester.tap(find.text('上一题'));
    await tester.pumpAndSettle();
    expect(find.text('在教师资格证考试中，教育观的核心内容是什么？'), findsOneWidget);

    appRouter.go('/qt/analysis-images/result');
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    expect(find.text('在教师资格证考试中，教育观的核心内容是什么？'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('home pages resume active practice and exam sessions',
      (tester) async {
    final previousPracticeSession = mockStore.practiceSession;
    final previousExamSession = mockStore.examSession;
    addTearDown(() {
      mockStore.practiceSession = previousPracticeSession;
      mockStore.examSession = previousExamSession;
    });

    mockStore.practiceSession = PracticeSession(
      title: '恢复练习小节',
      mode: '章节练习',
      questions: const [
        Question(
          id: 'resume_practice_q1',
          type: QuestionType.single,
          stem: '恢复练习题干',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析',
        ),
      ],
    );
    mockStore.examSession = ExamSession(
      title: '恢复考试小节',
      mode: '章节考试',
      durationMinutes: 45,
      remainingSeconds: 120,
      questions: const [
        Question(
          id: 'resume_exam_q1',
          type: QuestionType.single,
          stem: '恢复考试题干',
          options: ['A', 'B'],
          answerIndexes: {0},
          analysis: '解析',
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice');
    await tester.pumpAndSettle();
    expect(find.text('继续上次练习'), findsOneWidget);
    await tester.tap(find.text('继续上次练习'));
    await tester.pumpAndSettle();
    expect(find.text('恢复练习题干'), findsOneWidget);

    appRouter.go('/exam');
    await tester.pumpAndSettle();
    expect(find.text('继续未交卷考试'), findsOneWidget);
    await tester.tap(find.text('继续未交卷考试'));
    await tester.pumpAndSettle();
    expect(find.text('恢复考试题干'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('home dashboard panels reflect aggregate store statistics',
      (tester) async {
    final previousChapters = mockStore.chapters;
    final previousPracticePapers = mockStore.practicePapers;
    final previousExamChapters = mockStore.examChapters;
    final previousExamPapers = mockStore.examPapers;
    final previousPracticeRecords = mockStore.practiceRecords;
    final previousExamRecords = mockStore.examRecords;
    final previousPracticeSession = mockStore.practiceSession;
    final previousExamSession = mockStore.examSession;
    addTearDown(() {
      mockStore.chapters = previousChapters;
      mockStore.practicePapers = previousPracticePapers;
      mockStore.examChapters = previousExamChapters;
      mockStore.examPapers = previousExamPapers;
      mockStore.practiceRecords = previousPracticeRecords;
      mockStore.examRecords = previousExamRecords;
      mockStore.practiceSession = previousPracticeSession;
      mockStore.examSession = previousExamSession;
    });

    mockStore.practiceSession = null;
    mockStore.examSession = null;
    mockStore.chapters = const [
      Chapter(
        id: 'home_practice_chapter',
        title: '首页练习章节',
        done: 8,
        total: 20,
        correct: 6,
        wrong: 2,
        sections: [],
      ),
    ];
    mockStore.practicePapers = const [
      Paper(
        id: 'home_practice_paper',
        title: '首页练习真题',
        done: 3,
        total: 10,
        correct: 2,
        wrong: 1,
        minutes: 30,
      ),
    ];
    mockStore.practiceRecords = const [
      StudyRecord(
        title: '今日练习',
        mode: '章节练习',
        metric: '5/10题 · 正确率 80%',
        time: '刚刚',
      ),
      StudyRecord(
        title: '昨日练习',
        mode: '章节练习',
        metric: '4/10题 · 正确率 75%',
        time: '2026-07-09 09:00',
      ),
    ];
    mockStore.examChapters = const [
      Chapter(
        id: 'home_exam_chapter',
        title: '首页考试章节',
        done: 7,
        total: 10,
        correct: 5,
        wrong: 2,
        sections: [],
      ),
    ];
    mockStore.examPapers = const [
      Paper(
        id: 'home_exam_paper',
        title: '首页考试真题',
        done: 3,
        total: 10,
        correct: 2,
        wrong: 1,
        minutes: 60,
      ),
    ];
    mockStore.examRecords = const [
      StudyRecord(
        title: '今日考试',
        mode: '章节考试',
        metric: '70分 · 正确率 70%',
        time: '刚刚',
      ),
      StudyRecord(
        title: '昨日考试',
        mode: '模拟考试',
        metric: '80分 · 正确率 80%',
        time: '2026-07-09 09:00',
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/practice');
    await tester.pumpAndSettle();
    expect(find.text('今日新增进度：5题      已累计练习：2天'), findsOneWidget);
    expect(find.text('练习进度 11/30'), findsOneWidget);
    expect(find.text('正确率 73%'), findsOneWidget);
    expect(find.text('错题量 3'), findsOneWidget);

    appRouter.go('/exam');
    await tester.pumpAndSettle();
    expect(find.text('今日新增进度：1题      已累计考核：2天'), findsOneWidget);
    expect(find.text('题目覆盖'), findsOneWidget);
    expect(find.text('考试次数'), findsOneWidget);
    expect(find.text('总正确率'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('record delete-all confirmations clear local record lists',
      (tester) async {
    final previousPracticeRecords = mockStore.practiceRecords;
    final previousExamRecords = mockStore.examRecords;
    addTearDown(() {
      mockStore.practiceRecords = previousPracticeRecords;
      mockStore.examRecords = previousExamRecords;
    });

    mockStore.practiceRecords = const [
      StudyRecord(title: '第一节', mode: '章节练习', metric: '正确率 80%', time: '今天'),
      StudyRecord(title: '第二节', mode: '章节练习', metric: '正确率 90%', time: '昨天'),
    ];
    mockStore.examRecords = const [
      StudyRecord(title: '模拟卷一', mode: '模拟考试', metric: '正确率 70%', time: '今天'),
      StudyRecord(title: '模拟卷二', mode: '模拟考试', metric: '未交卷', time: '昨天'),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/practice-records/delete-all');
    await tester.pumpAndSettle();
    await tester.tap(find.text('全部删除'));
    await tester.pumpAndSettle();
    expect(mockStore.practiceRecords, isEmpty);
    expect(find.text('暂无练习记录'), findsOneWidget);
    await tester.tap(find.text('去练习'));
    await tester.pumpAndSettle();
    expect(find.text('练习入口'), findsOneWidget);

    appRouter.go('/profile/exam-records/delete-all');
    await tester.pumpAndSettle();
    await tester.tap(find.text('全部删除'));
    await tester.pumpAndSettle();
    expect(mockStore.examRecords, isEmpty);
    expect(find.text('暂无考试记录'), findsOneWidget);
    await tester.tap(find.text('去考试'));
    await tester.pumpAndSettle();
    expect(find.text('考试入口'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('standalone single-record delete confirmations return to lists',
      (tester) async {
    final previousPracticeRecords = mockStore.practiceRecords;
    final previousExamRecords = mockStore.examRecords;
    addTearDown(() {
      mockStore.practiceRecords = previousPracticeRecords;
      mockStore.examRecords = previousExamRecords;
    });

    mockStore.practiceRecords = const [
      StudyRecord(title: '第一节', mode: '章节练习', metric: '正确率 80%', time: '今天'),
    ];
    mockStore.examRecords = const [
      StudyRecord(title: '模拟卷一', mode: '模拟考试', metric: '正确率 70%', time: '今天'),
    ];

    await tester.binding.setSurfaceSize(const Size(390, 900));
    await tester.pumpWidget(const TikuApp());

    appRouter.go('/profile/practice-records/delete');
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('全部练习记录'), findsOneWidget);
    expect(find.text('第一节'), findsOneWidget);
    expect(mockStore.practiceRecords.length, 1);

    appRouter.go('/profile/exam-records/delete');
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('全部考试记录'), findsOneWidget);
    expect(find.text('模拟卷一'), findsOneWidget);
    expect(mockStore.examRecords.length, 1);

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
