import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P03 章节练习小节列表 - 含状态栏、导航栏、章节数据面板、各小节卡片
class P03ChapterSectionListPage extends StatelessWidget {
  const P03ChapterSectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // 状态栏
          const StatusBar(),

          // 导航栏 - 标题为学科名
          const NavBar(title: '小学教师'),

          // 内容区
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  // ===== 章节练习数据面板 - 渐变背景 =====
                  _buildChapterStatsPanel(),

                  const SizedBox(height: 14),

                  // ===== 第一节：教育理论 =====
                  _buildSectionCard(
                    context,
                    title: '第一节：教育理论',
                    info: '已练 18/28 · 正确率 83% · 错题 2',
                    progress: 18 / 28,
                  ),

                  const SizedBox(height: 14),

                  // ===== 第二节：教育心理 =====
                  _buildSectionCard(
                    context,
                    title: '第二节：教育心理',
                    info: '已练 12/32 · 正确率 78% · 错题 3',
                    progress: 12 / 32,
                  ),

                  const SizedBox(height: 14),

                  // ===== 第三节：教学设计 =====
                  _buildSectionCard(
                    context,
                    title: '第三节：教学设计',
                    info: '已练 12/24 · 正确率 86% · 错题 0',
                    progress: 12 / 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 章节练习数据面板 - 渐变背景，含标题、统计和进度条
  Widget _buildChapterStatsPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 章节标题
          Text(
            '章节练习/第一章：教育基础',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // 统计行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已练题 42/84',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '正确率 82%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '错题量 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 42 / 84,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 小节卡片 - 含标题、信息行、四个操作按钮
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String info,
    required double progress,
  }) {
    return GestureDetector(
      onTap: () => context.go('/practice/quiz'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            // 标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 信息行
            Text(
              info,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            // 操作按钮行 - 重置 / 错题 / 背题 / 继续
            Row(
              children: [
                // 重置按钮
                Expanded(
                  child: _buildActionButton(
                    text: '重置',
                    icon: Icons.refresh,
                    bgColor: AppColors.surface,
                    fgColor: AppColors.textSecondary,
                    borderColor: AppColors.border,
                  ),
                ),
                const SizedBox(width: 8),
                // 错题按钮
                Expanded(
                  child: _buildActionButton(
                    text: '错题',
                    bgColor: const Color(0xFFFEF2F2),
                    fgColor: AppColors.error,
                  ),
                ),
                const SizedBox(width: 8),
                // 背题按钮
                Expanded(
                  child: _buildActionButton(
                    text: '背题',
                    bgColor: AppColors.successBg,
                    fgColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                // 继续按钮
                Expanded(
                  child: _buildActionButton(
                    text: '继续',
                    bgColor: AppColors.primary,
                    fgColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButton({
    required String text,
    IconData? icon,
    required Color bgColor,
    required Color fgColor,
    Color? borderColor,
  }) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
