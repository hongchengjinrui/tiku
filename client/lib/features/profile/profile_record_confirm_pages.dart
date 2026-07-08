import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../common/static_overlay_page.dart';

class P51ADeletePracticeRecordConfirmPage extends StatelessWidget {
  const P51ADeletePracticeRecordConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticDialogPage(
      backgroundColor: Color(0x990F172A),
      child: StaticConfirmDialog(
        icon: Icons.delete_outline,
        iconColor: AppColors.error,
        iconBg: AppColors.errorBg,
        title: '删除这条练习记录？',
        message: '删除后仅移除本条记录展示，不会影响对应章节的题目进度。',
        cancelText: '取消',
        confirmText: '删除',
      ),
    );
  }
}

class P51BDeleteAllPracticeRecordsConfirmPage extends StatelessWidget {
  const P51BDeleteAllPracticeRecordsConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticDialogPage(
      backgroundColor: Color(0x990F172A),
      child: StaticConfirmDialog(
        icon: Icons.delete_sweep_outlined,
        iconColor: AppColors.error,
        iconBg: AppColors.errorBg,
        title: '删除全部练习记录？',
        message: '将清空当前科目下的全部练习记录列表，此操作不可撤销。',
        cancelText: '再想想',
        confirmText: '全部删除',
      ),
    );
  }
}

class P52ADeleteExamRecordConfirmPage extends StatelessWidget {
  const P52ADeleteExamRecordConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticDialogPage(
      backgroundColor: Color(0x990F172A),
      child: StaticConfirmDialog(
        icon: Icons.delete_outline,
        iconColor: AppColors.error,
        iconBg: AppColors.errorBg,
        title: '删除这条考试记录？',
        message: '删除后将不再展示本次考试成绩和解析入口，不影响题库内容。',
        cancelText: '取消',
        confirmText: '删除',
      ),
    );
  }
}

class P52BDeleteAllExamRecordsConfirmPage extends StatelessWidget {
  const P52BDeleteAllExamRecordsConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticDialogPage(
      backgroundColor: Color(0x990F172A),
      child: StaticConfirmDialog(
        icon: Icons.delete_sweep_outlined,
        iconColor: AppColors.error,
        iconBg: AppColors.errorBg,
        title: '删除全部考试记录？',
        message: '将清空当前科目下的全部考试记录列表，此操作不可撤销。',
        cancelText: '再想想',
        confirmText: '全部删除',
      ),
    );
  }
}
