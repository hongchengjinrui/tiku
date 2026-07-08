import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StaticDialogPage extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const StaticDialogPage({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0x990F172A),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: SizedBox(width: 390, child: child),
    );
  }
}

class StaticBottomSheetPage extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const StaticBottomSheetPage({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0x800F172A),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: SizedBox(
        width: 390,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [child],
        ),
      ),
    );
  }
}

class StaticConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;

  const StaticConfirmDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.message,
    this.cancelText = '取消',
    this.confirmText = '确认',
    this.confirmColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 314,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: confirmColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
