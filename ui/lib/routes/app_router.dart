import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Theme
import '../theme/app_theme.dart';

// Practice flow
import '../features/practice/p06_random_practice_page.dart';
import '../features/practice/p07_favorite_practice_page.dart';
import '../features/practice/p08_wrong_practice_entry_page.dart';
import '../features/practice/p08b_wrong_practice_page.dart';
import '../features/practice/p01a_switch_subject_dialog.dart';

// Exam flow
import '../features/exam/exam_pages.dart';

// Resources
import '../features/resources/p40_resource_center_page.dart';

// Profile
import '../features/profile/p50_profile_page.dart';
import '../features/profile/profile_pages.dart';

// Question types
import '../features/question_types/question_type_pages.dart';

// Empty states
import '../features/empty_states/empty_state_pages.dart';

// GoRouter 配置
final GoRouter appRouter = GoRouter(
  initialLocation: '/practice',
  routes: [
    // ===== 练习链路 =====
    GoRoute(
      path: '/practice',
      builder: (context, state) => const _PlaceholderPage(title: 'P01 练习模式首页'),
    ),
    GoRoute(
      path: '/practice/catalog',
      builder: (context, state) => const _PlaceholderPage(title: 'P02 练习目录页'),
    ),
    GoRoute(
      path: '/practice/sections',
      builder: (context, state) => const _PlaceholderPage(title: 'P03 章节练习小节列表'),
    ),
    GoRoute(
      path: '/practice/papers',
      builder: (context, state) => const _PlaceholderPage(title: 'P04 真题练习试卷列表'),
    ),
    GoRoute(
      path: '/practice/quiz',
      builder: (context, state) => const _PlaceholderPage(title: 'P05 刷题页'),
    ),
    GoRoute(
      path: '/practice/random',
      builder: (context, state) => const P06RandomPracticePage(),
    ),
    GoRoute(
      path: '/practice/favorite',
      builder: (context, state) => const P07FavoritePracticePage(),
    ),
    GoRoute(
      path: '/practice/wrong',
      builder: (context, state) => const P08WrongPracticeEntryPage(),
    ),
    GoRoute(
      path: '/practice/wrong/quiz',
      builder: (context, state) => const P08BWrongPracticePage(),
    ),

    // ===== 考试链路 =====
    GoRoute(
      path: '/exam',
      builder: (context, state) => const P20ExamHomePage(),
    ),
    GoRoute(
      path: '/exam/catalog',
      builder: (context, state) => const P21ChapterExamCatalogPage(),
    ),
    GoRoute(
      path: '/exam/sections',
      builder: (context, state) => const P21AChapterExamSectionListPage(),
    ),
    GoRoute(
      path: '/exam/papers',
      builder: (context, state) => const P22RealExamPaperListPage(),
    ),
    GoRoute(
      path: '/exam/assemble',
      builder: (context, state) => const P24ExamAssemblySettingsPage(),
    ),
    GoRoute(
      path: '/exam/answer',
      builder: (context, state) => const P25ExamAnswerPage(),
    ),
    GoRoute(
      path: '/exam/card',
      builder: (context, state) => const P26AnswerCardPage(),
    ),
    GoRoute(
      path: '/exam/analysis',
      builder: (context, state) => const P28ExamAnalysisPage(),
    ),

    // ===== 资料链路 =====
    GoRoute(
      path: '/resources',
      builder: (context, state) => const P40ResourceCenterPage(),
    ),
    GoRoute(
      path: '/resources/free',
      builder: (context, state) => const P40AFreeResourceDetailPage(),
    ),
    GoRoute(
      path: '/resources/paid',
      builder: (context, state) => const P41PaidResourcePreviewPage(),
    ),
    GoRoute(
      path: '/resources/unlocked',
      builder: (context, state) => const P42UnlockedResourceDetailPage(),
    ),
    GoRoute(
      path: '/vip',
      builder: (context, state) => const P41AVipPage(),
    ),
    GoRoute(
      path: '/vip/success',
      builder: (context, state) => const P59APaymentSuccessPage(),
    ),

    // ===== 我的与会员 =====
    GoRoute(
      path: '/profile',
      builder: (context, state) => const P50ProfilePage(),
    ),
    GoRoute(
      path: '/profile/practice-records',
      builder: (context, state) => const P51PracticeRecordsPage(),
    ),
    GoRoute(
      path: '/profile/exam-records',
      builder: (context, state) => const P52ExamRecordsPage(),
    ),
    GoRoute(
      path: '/profile/wrong',
      builder: (context, state) => const P53WrongEntryPage(),
    ),
    GoRoute(
      path: '/profile/upload',
      builder: (context, state) => const P55UploadBankPage(),
    ),
    GoRoute(
      path: '/profile/correction',
      builder: (context, state) => const P54FeedbackPage(),
    ),
    GoRoute(
      path: '/profile/feedback',
      builder: (context, state) => const P56FeedbackPage(),
    ),
    GoRoute(
      path: '/profile/about',
      builder: (context, state) => const P57AboutPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const P58LoginPage(),
    ),
    GoRoute(
      path: '/login/quick',
      builder: (context, state) => const P58AQuickLoginPage(),
    ),
    GoRoute(
      path: '/agreement/member',
      builder: (context, state) => const P60AgreementPage(
        title: '会员服务协议',
        sections: ['服务内容', '费用与退款', '自动续费', '使用规则', '争议解决'],
      ),
    ),
    GoRoute(
      path: '/agreement/user',
      builder: (context, state) => const P60AgreementPage(
        title: '用户协议',
        sections: ['服务条款', '用户权利', '用户义务', '知识产权', '免责声明'],
      ),
    ),
    GoRoute(
      path: '/agreement/privacy',
      builder: (context, state) => const P60AgreementPage(
        title: '隐私协议',
        sections: ['信息收集', '信息使用', '信息保护', 'Cookie使用', '第三方共享'],
      ),
    ),

    // ===== 空状态 =====
    GoRoute(
      path: '/empty/practice',
      builder: (context, state) => const E01NoPracticeRecordPage(),
    ),
    GoRoute(
      path: '/empty/wrong',
      builder: (context, state) => const E02NoWrongQuestionPage(),
    ),
    GoRoute(
      path: '/empty/favorite',
      builder: (context, state) => const E03NoFavoritePage(),
    ),
    GoRoute(
      path: '/empty/exam',
      builder: (context, state) => const E04NoExamRecordPage(),
    ),

    // ===== 题型组件 =====
    GoRoute(
      path: '/qt/single',
      builder: (context, state) => const QT01SingleChoicePage(),
    ),
    GoRoute(
      path: '/qt/multiple',
      builder: (context, state) => const QT02MultipleChoicePage(),
    ),
    GoRoute(
      path: '/qt/truefalse',
      builder: (context, state) => const QT03TrueFalsePage(),
    ),
    GoRoute(
      path: '/qt/fillblank',
      builder: (context, state) => const QT04FillBlankPage(),
    ),
    GoRoute(
      path: '/qt/short',
      builder: (context, state) => const QT05ShortAnswerPage(),
    ),
    GoRoute(
      path: '/qt/material',
      builder: (context, state) => const QT06MaterialPage(),
    ),
    GoRoute(
      path: '/qt/image',
      builder: (context, state) => const QT07ImageQuestionPage(),
    ),
  ],
);

/// 临时占位页面（用于尚未由agent生成的页面）
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('该页面代码由后台agent生成中...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/// App 根 Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '题库母版',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}

void main() {
  runApp(const MyApp());
}
