import 'package:go_router/go_router.dart';

import '../features/common/static_overlay_page.dart';

// Practice flow
import '../features/practice/p00_splash_page.dart';
import '../features/practice/p01_practice_home_page.dart';
import '../features/practice/p01a_switch_subject_dialog.dart';
import '../features/practice/p02_reset_state_pages.dart';
import '../features/practice/p02_practice_catalog_page.dart';
import '../features/practice/p03_chapter_section_list_page.dart';
import '../features/practice/p04_real_exam_paper_list_page.dart';
import '../features/practice/p05_question_practice_page.dart';
import '../features/practice/p06_random_practice_page.dart';
import '../features/practice/p07_favorite_practice_page.dart';
import '../features/practice/p08_wrong_practice_entry_page.dart';
import '../features/practice/p08b_wrong_practice_page.dart';

// Exam flow
import '../features/exam/exam_pages.dart';

// Resources
import '../features/resources/p40_resource_center_page.dart';

// Profile
import '../features/profile/p50_profile_page.dart';
import '../features/profile/p60_cache_management_page.dart';
import '../features/profile/profile_pages.dart';
import '../features/profile/profile_record_confirm_pages.dart';

// Question types
import '../features/question_types/question_type_pages.dart';

// Empty states
import '../features/empty_states/empty_state_pages.dart';

// GoRouter 配置
final GoRouter appRouter = GoRouter(
  initialLocation: '/practice',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const P00SplashPage(),
    ),

    // ===== 练习链路 =====
    GoRoute(
      path: '/practice',
      builder: (context, state) => const P01PracticeHomePage(),
    ),
    GoRoute(
      path: '/practice/switch-subject',
      builder: (context, state) => const P01ASwitchSubjectSheet(),
    ),
    GoRoute(
      path: '/practice/catalog',
      builder: (context, state) => const P02PracticeCatalogPage(),
    ),
    GoRoute(
      path: '/practice/reset',
      builder: (context, state) => const P02AResetProgressSheet(),
    ),
    GoRoute(
      path: '/practice/reset/all',
      builder: (context, state) => const P02BResetAllSelectedPage(),
    ),
    GoRoute(
      path: '/practice/reset/level2',
      builder: (context, state) => const P02CResetLevel2SelectedPage(),
    ),
    GoRoute(
      path: '/practice/reset/custom',
      builder: (context, state) => const P02DResetCustomSelectedPage(),
    ),
    GoRoute(
      path: '/practice/reset/confirm',
      builder: (context, state) => const P02EConfirmResetDialog(),
    ),
    GoRoute(
      path: '/practice/sections',
      builder: (context, state) => const P03ChapterSectionListPage(),
    ),
    GoRoute(
      path: '/practice/sections/reset-confirm',
      builder: (context, state) => const StaticDialogPage(
        child: P03ASectionResetConfirmationModal(),
      ),
    ),
    GoRoute(
      path: '/practice/papers',
      builder: (context, state) => const P04RealExamPaperListPage(),
    ),
    GoRoute(
      path: '/practice/papers/reset-confirm',
      builder: (context, state) => const StaticDialogPage(
        child: P04APaperResetConfirmationModal(),
      ),
    ),
    GoRoute(
      path: '/practice/quiz',
      builder: (context, state) => const P05QuestionPracticePage(),
    ),
    GoRoute(
      path: '/practice/random',
      builder: (context, state) => const P06RandomPracticePage(),
    ),
    GoRoute(
      path: '/practice/random/custom',
      builder: (context, state) =>
          const P06RandomPracticePage(initialRange: '自选章节'),
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
      path: '/practice/wrong/clear-confirm',
      builder: (context, state) => const P08AClearWrongDialog(),
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
      path: '/exam/rules',
      builder: (context, state) => const StaticDialogPage(
        child: P20AExamRulesModal(),
      ),
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
      path: '/exam/retake-confirm',
      builder: (context, state) => const StaticDialogPage(
        child: P21BRetakeConfirmationModal(),
      ),
    ),
    GoRoute(
      path: '/exam/papers',
      builder: (context, state) => const P22RealExamPaperListPage(),
    ),
    GoRoute(
      path: '/exam/reset',
      builder: (context, state) => const StaticBottomSheetPage(
        child: P23ExamResetModal(),
      ),
    ),
    GoRoute(
      path: '/exam/reset/all',
      builder: (context, state) => const P23AResetAllSelectedPage(),
    ),
    GoRoute(
      path: '/exam/reset/level2',
      builder: (context, state) => const P23BResetLevel2SelectedPage(),
    ),
    GoRoute(
      path: '/exam/reset/custom',
      builder: (context, state) => const P23CResetCustomSelectedPage(),
    ),
    GoRoute(
      path: '/exam/reset/confirm',
      builder: (context, state) => const P23DResetSecondaryConfirmationPage(),
    ),
    GoRoute(
      path: '/exam/assemble',
      builder: (context, state) => const P24ExamAssemblySettingsPage(),
    ),
    GoRoute(
      path: '/exam/assemble/all',
      builder: (context, state) => const P24AAssemblyAllChaptersPage(),
    ),
    GoRoute(
      path: '/exam/answer',
      builder: (context, state) => const P25ExamAnsweringPage(),
    ),
    GoRoute(
      path: '/exam/card',
      builder: (context, state) => const P26AnswerCardPage(),
    ),
    GoRoute(
      path: '/exam/submit-confirm',
      builder: (context, state) => const StaticDialogPage(
        child: P27SubmitExamConfirmationModal(),
      ),
    ),
    GoRoute(
      path: '/exam/submit-confirm/all-answered',
      builder: (context, state) => const StaticDialogPage(
        child: P27ASubmitAllAnsweredModal(),
      ),
    ),
    GoRoute(
      path: '/exam/analysis',
      builder: (context, state) => const P28ExamAnalysisPage(),
    ),
    GoRoute(
      path: '/exam/analysis/unanswered',
      builder: (context, state) => const P28AAnalysisUnansweredPage(),
    ),
    GoRoute(
      path: '/exam/analysis/wrong',
      builder: (context, state) => const P28BAnalysisWrongPage(),
    ),
    GoRoute(
      path: '/exam/analysis/correct',
      builder: (context, state) => const P28CAnalysisCorrectPage(),
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
      path: '/resources/free/toast',
      builder: (context, state) => const P40BLinkCopiedToastPage(),
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
      path: '/profile/practice-records/delete',
      builder: (context, state) => const P51ADeletePracticeRecordConfirmPage(),
    ),
    GoRoute(
      path: '/profile/practice-records/delete-all',
      builder: (context, state) =>
          const P51BDeleteAllPracticeRecordsConfirmPage(),
    ),
    GoRoute(
      path: '/profile/exam-records',
      builder: (context, state) => const P52ExamRecordsPage(),
    ),
    GoRoute(
      path: '/profile/exam-records/delete',
      builder: (context, state) => const P52ADeleteExamRecordConfirmPage(),
    ),
    GoRoute(
      path: '/profile/exam-records/delete-all',
      builder: (context, state) => const P52BDeleteAllExamRecordsConfirmPage(),
    ),
    GoRoute(
      path: '/profile/resource-claims',
      builder: (context, state) => const P53ResourceClaimsPage(),
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
      path: '/profile/feedback-records',
      builder: (context, state) => const P56AFeedbackRecordsPage(),
    ),
    GoRoute(
      path: '/profile/cache',
      builder: (context, state) => const P60CacheManagementPage(),
    ),
    GoRoute(
      path: '/profile/about',
      builder: (context, state) => const P57AboutPage(),
    ),
    GoRoute(
      path: '/profile/vip',
      builder: (context, state) => const P59VipPage(),
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
    GoRoute(
      path: '/qt/image-error',
      builder: (context, state) => const QT08ImageLoadFailedPage(),
    ),
    GoRoute(
      path: '/qt/single/result',
      builder: (context, state) => const QT09SingleChoiceResultPage(),
    ),
    GoRoute(
      path: '/qt/multiple/result',
      builder: (context, state) => const QT10MultipleChoiceResultPage(),
    ),
    GoRoute(
      path: '/qt/truefalse/result',
      builder: (context, state) => const QT11TrueFalseResultPage(),
    ),
    GoRoute(
      path: '/qt/fillblank/result',
      builder: (context, state) => const QT12FillBlankResultPage(),
    ),
    GoRoute(
      path: '/qt/short/result',
      builder: (context, state) => const QT13ShortAnswerScoredResultPage(),
    ),
    GoRoute(
      path: '/qt/material/result',
      builder: (context, state) => const QT14MaterialResultPage(),
    ),
    GoRoute(
      path: '/qt/image/result',
      builder: (context, state) => const QT15ImageResultPage(),
    ),
    GoRoute(
      path: '/qt/multi-image/result',
      builder: (context, state) => const QT16MultiImageResultPage(),
    ),
    GoRoute(
      path: '/qt/analysis-images/result',
      builder: (context, state) => const QT17AnalysisMultiImageResultPage(),
    ),
  ],
);
