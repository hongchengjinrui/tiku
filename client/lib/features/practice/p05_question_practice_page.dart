import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P05 刷题页 - 含状态栏、导航栏、题目进度区、选项区、操作区、解析区和底部操作栏
class P05QuestionPracticePage extends StatelessWidget {
  const P05QuestionPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // 状态栏
          const StatusBar(),

          // 导航栏
          SizedBox(
            height: 48,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 返回按钮
                Positioned(
                  left: 16,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // 标题
                Text(
                  '基础知识',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ===== 题目进度区 =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // 进度信息行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 题目编号
                    Text(
                      '第 12 / 80 题',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // 题型标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '单选题',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 12 / 80,
                    minHeight: 4,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // ===== 主体内容区 =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 题目文本
                  Text(
                    '电气设备发生火灾时，应首先采取的措施是什么？',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== 选项列表 =====
                  Column(
                    children: [
                      // 选项A - 错误选项（选中且答错）
                      _buildOption(
                        label: 'A.',
                        text: '立即用水灭火',
                        state: OptionState.wrong,
                      ),
                      const SizedBox(height: 10),

                      // 选项B - 正确选项
                      _buildOption(
                        label: 'B.',
                        text: '切断电源',
                        state: OptionState.correct,
                      ),
                      const SizedBox(height: 10),

                      // 选项C - 未选中
                      _buildOption(
                        label: 'C.',
                        text: '用灭火器灭火',
                        state: OptionState.unselected,
                      ),
                      const SizedBox(height: 10),

                      // 选项D - 未选中
                      _buildOption(
                        label: 'D.',
                        text: '拨打火警电话',
                        state: OptionState.unselected,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== 操作行 - 收藏 / 纠错 =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 收藏按钮
                      _buildActionChip(
                        icon: Icons.star,
                        text: '收藏',
                      ),
                      const SizedBox(width: 16),
                      // 纠错按钮
                      _buildActionChip(
                        icon: Icons.report_problem_outlined,
                        text: '纠错',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== 解析区 =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 结果标签
                        Text(
                          '回答错误',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 答案行
                        Row(
                          children: [
                            Text(
                              '正确答案：B',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '你的答案：A',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // 解析文本
                        Text(
                          '电气设备火灾应首先切断电源，防止触电和火势蔓延。切忌用水扑灭带电设备火灾，应使用干粉灭火器或二氧化碳灭火器。',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== 底部操作栏 =====
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 上一题按钮
                _buildBottomButton(
                  icon: Icons.chevron_left,
                  text: '上一题',
                  bgColor: Colors.transparent,
                  fgColor: AppColors.textSecondary,
                  borderColor: AppColors.border,
                ),
                // 答题卡按钮
                _buildBottomButton(
                  icon: Icons.grid_view_outlined,
                  text: '答题卡',
                  bgColor: Colors.transparent,
                  fgColor: AppColors.textSecondary,
                  borderColor: AppColors.border,
                ),
                // 下一题按钮
                _buildBottomButton(
                  icon: Icons.chevron_right,
                  text: '下一题',
                  bgColor: AppColors.primary,
                  fgColor: Colors.white,
                  borderColor: null,
                  iconAfter: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 选项状态枚举
  /// 构建单个选项
  Widget _buildOption({
    required String label,
    required String text,
    required OptionState state,
  }) {
    Color bgColor;
    Color borderColor;
    Color labelColor;
    Color textColor;
    Widget? leading;

    switch (state) {
      case OptionState.wrong:
        // 错误选项 - 红色背景，红色边框，红色叉号图标
        bgColor = const Color(0xFFFEE2E2);
        borderColor = AppColors.error;
        labelColor = const Color(0xFF991B1B);
        textColor = const Color(0xFF991B1B);
        leading = _buildIconCircle(
          Icons.close,
          AppColors.error,
        );
        break;
      case OptionState.correct:
        // 正确选项 - 绿色背景，绿色边框，绿色对号图标
        bgColor = const Color(0xFFD1FAE5);
        borderColor = AppColors.success;
        labelColor = const Color(0xFF065F46);
        textColor = const Color(0xFF065F46);
        leading = _buildIconCircle(
          Icons.check,
          AppColors.success,
        );
        break;
      case OptionState.unselected:
        // 未选中 - 白色背景，灰色边框，空心圆圈
        bgColor = AppColors.card;
        borderColor = AppColors.border;
        labelColor = AppColors.textPrimary;
        textColor = AppColors.textPrimary;
        leading = _buildCircle();
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // 前导图标
          leading,
          const SizedBox(width: 12),
          // 选项标签 (A. B. C. D.)
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          const SizedBox(width: 4),
          // 选项文本
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图标圆圈 - 用于正确/错误标记
  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  /// 构建空心圆圈 - 用于未选中状态
  Widget _buildCircle() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textMuted, width: 1.5),
      ),
    );
  }

  /// 收藏/纠错操作芯片
  Widget _buildActionChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 底部操作按钮
  Widget _buildBottomButton({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color fgColor,
    Color? borderColor,
    bool iconAfter = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Row(
        children: [
          if (!iconAfter) ...[
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: iconAfter ? FontWeight.w600 : FontWeight.w400,
              color: fgColor,
            ),
          ),
          if (iconAfter) ...[
            const SizedBox(width: 6),
            Icon(icon, size: 18, color: fgColor),
          ],
        ],
      ),
    );
  }
}

/// 选项状态枚举
enum OptionState {
  /// 正确选项
  correct,
  /// 错误选项
  wrong,
  /// 未选中
  unselected,
}
