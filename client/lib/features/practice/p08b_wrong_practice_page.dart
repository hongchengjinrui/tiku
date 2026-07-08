import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';

/// P08B 错题练习页（错题作答态，带解析）
class P08BWrongPracticePage extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const P08BWrongPracticePage({
    super.key,
    this.currentQuestion = 6,
    this.totalQuestions = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '错题练习'),
            // 题目进度区
            _buildProgressArea(),
            // 题目主体
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWrongMeta(),
                    const SizedBox(height: 14),
                    const Text(
                        '电气设备运行中发现异常发热时，以下处理方式正确的是？',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 14),
                    _buildOptions(),
                    const SizedBox(height: 14),
                    _buildActions(),
                    const SizedBox(height: 14),
                    _buildAnalysis(),
                  ],
                ),
              ),
            ),
            // 底部导航
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('第 $currentQuestion / $totalQuestions 题',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('单选',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: currentQuestion / totalQuestions,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrongMeta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('错误次数：3 次',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error)),
          SizedBox(width: 8),
          Text('最近错误：2026-05-27',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF991B1B))),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final options = [
      {'label': 'A', 'text': '继续运行，观察是否自行降温', 'correct': false},
      {'label': 'B', 'text': '立即停止运行，切断电源后检查', 'correct': true},
      {'label': 'C', 'text': '用水冷却发热部位', 'correct': false},
      {'label': 'D', 'text': '加大通风散热即可', 'correct': false},
    ];

    return Column(
      children: options.map((opt) {
        final isCorrect = opt['correct'] == true;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.successBg : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isCorrect ? AppColors.success : AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect
                        ? AppColors.success
                        : AppColors.surface,
                    border: Border.all(
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(opt['label'] as String,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isCorrect
                              ? Colors.white
                              : AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(opt['text'] as String,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: isCorrect
                              ? AppColors.textPrimary
                              : AppColors.textSecondary)),
                ),
                if (isCorrect)
                  const Icon(Icons.check_circle,
                      size: 20, color: AppColors.success),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    final actions = [
      {'icon': Icons.remove_circle_outline, 'label': '移出错题', 'color': AppColors.error, 'border': AppColors.error},
      {'icon': Icons.star_border, 'label': '收藏', 'color': AppColors.textSecondary, 'border': AppColors.border},
      {'icon': Icons.feedback_outlined, 'label': '纠错', 'color': AppColors.textSecondary, 'border': AppColors.border},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions.map((a) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: a['border'] as Color),
            ),
            child: Row(
              children: [
                Icon(a['icon'] as IconData, size: 16, color: a['color'] as Color),
                const SizedBox(width: 6),
                Text(a['label'] as String,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: a['color'] as Color)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalysis() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('回答正确',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success)),
          SizedBox(height: 10),
          Text('正确答案：B',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          SizedBox(height: 10),
          Text(
              '异常发热可能意味着过载、接触不良或绝缘问题，应先停止运行并切断相关电源，再进行检查处理。',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.chevron_left,
                    size: 18, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('上一题',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Text('下一题',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 18, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
