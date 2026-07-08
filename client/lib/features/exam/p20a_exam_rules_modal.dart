import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// P20A 考试规则弹窗 - Exam rules modal dialog
class P20AExamRulesModal extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;

  const P20AExamRulesModal({
    super.key,
    this.onClose,
    this.onConfirm,
  });

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x990F172A),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: const P20AExamRulesModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 330,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('考试规则',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                GestureDetector(
                  onTap: onClose ?? () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('1. 考试模式只记录答案，不在答题中展示解析。',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 6),
            const Text('2. 可通过答题卡快速跳题、检查未答题。',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 6),
            const Text('3. 交卷后无法修改答案，可查看成绩和详细解析。',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 6),
            const Text('4. 组卷考试优先使用本地缓存中的组卷设置。',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onConfirm ?? () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('知道了',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
