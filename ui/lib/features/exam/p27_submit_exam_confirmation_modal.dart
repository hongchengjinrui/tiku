import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// P27 交卷确认弹窗 - Submit exam confirmation dialog (with unanswered questions)
class P27SubmitExamConfirmationModal extends StatelessWidget {
  final int unansweredCount;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const P27SubmitExamConfirmationModal({
    super.key,
    this.unansweredCount = 12,
    this.onCancel,
    this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, {int unansweredCount = 12}) {
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0x800F172A),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: P27SubmitExamConfirmationModal(
          unansweredCount: unansweredCount,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 326,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline,
                      size: 24, color: AppColors.error),
                ),
                const SizedBox(height: 18),
                const Text('确认交卷？',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 18),
                Text(
                  '当前还有 $unansweredCount 题未作答，交卷后无法修改答案。',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onCancel,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: const Center(
                            child: Text('等会儿继续考',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('确认交卷',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Close button
        Positioned(
          right: 40,
          top: MediaQuery.of(context).size.height * 0.32,
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}
