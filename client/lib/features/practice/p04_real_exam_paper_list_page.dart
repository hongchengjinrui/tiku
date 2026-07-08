import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P04 真题练习试卷列表 - 含状态栏、导航栏、总览数据面板、真题试卷列表
class P04RealExamPaperListPage extends StatelessWidget {
  const P04RealExamPaperListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // 状态栏
          const StatusBar(),

          // 导航栏
          const NavBar(title: '真题练习'),

          // 内容区
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  // ===== 面包屑总览数据面板 - 渐变背景 =====
                  _buildOverviewPanel(),

                  const SizedBox(height: 14),

                  // ===== 真题试卷 标题 =====
                  Text(
                    '真题试卷',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ===== 2025真题卷 =====
                  _buildPaperCard(
                    context,
                    title: '2025真题卷',
                    info: '已练 68/100 · 正确率 80% · 错题 8',
                    actionText: '继续',
                  ),

                  const SizedBox(height: 14),

                  // ===== 2024真题卷 =====
                  _buildPaperCard(
                    context,
                    title: '2024真题卷',
                    info: '未开始 · 100题 · 支持六类题型',
                    actionText: '开始',
                  ),

                  const SizedBox(height: 14),

                  // ===== 2023真题卷 =====
                  _buildPaperCard(
                    context,
                    title: '2023真题卷',
                    info: '已练 32/100 · 正确率 74% · 错题 12',
                    actionText: '继续',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 总览数据面板 - 渐变背景
  Widget _buildOverviewPanel() {
    return Container(
      width: double.infinity,
      height: 106,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总览标题
          Text(
            '真题练习总览',
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
                '已练题 188/600',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '正确率 76%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '错题量 42',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 188 / 600,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 试卷卡片 - 含标题、信息、四个操作按钮
  Widget _buildPaperCard(
    BuildContext context, {
    required String title,
    required String info,
    required String actionText,
  }) {
    return GestureDetector(
      onTap: () => context.go('/practice/quiz'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
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
            // 操作按钮行 - 重置 / 错题 / 背题 / 继续(开始)
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
                // 继续/开始按钮
                Expanded(
                  child: _buildActionButton(
                    text: actionText,
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
