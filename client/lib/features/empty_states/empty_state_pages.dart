import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// 空状态通用组件
class EmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle = '',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textMuted)),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(actionLabel!,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// E01 无练习记录空状态
class E01NoPracticeRecordPage extends StatelessWidget {
  const E01NoPracticeRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '练习记录'),
            Expanded(
              child: EmptyState(
                icon: Icons.history,
                iconColor: AppColors.primary,
                title: '暂无练习记录',
                subtitle: '开始你的第一次练习吧',
                actionLabel: '去练习',
                onAction: () => context.go('/practice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// E02 无错题空状态
class E02NoWrongQuestionPage extends StatelessWidget {
  const E02NoWrongQuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '错题练习'),
            Expanded(
              child: EmptyState(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                title: '暂无错题',
                subtitle: '全部题目都已掌握，太棒了！',
                actionLabel: '去练习',
                onAction: () => context.go('/practice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// E03 无收藏题空状态
class E03NoFavoritePage extends StatelessWidget {
  const E03NoFavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '收藏练习'),
            Expanded(
              child: EmptyState(
                icon: Icons.star_border,
                iconColor: AppColors.warning,
                title: '暂无收藏题目',
                subtitle: '在练习中点击星标即可收藏题目',
                actionLabel: '去练习',
                onAction: () => context.go('/practice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// E04 无考试记录空状态
class E04NoExamRecordPage extends StatelessWidget {
  const E04NoExamRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '考试记录'),
            Expanded(
              child: EmptyState(
                icon: Icons.assignment_outlined,
                iconColor: AppColors.primary,
                title: '暂无考试记录',
                subtitle: '完成一次考试后记录将显示在这里',
                actionLabel: '去考试',
                onAction: () => context.go('/exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
