import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// White safe-area spacer for the native system status bar.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final style = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white,
      systemStatusBarContrastEnforced: false,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.paddingOf(context).top,
        ),
      ),
    );
  }
}

/// Standard navigation bar with back button and centered title.
class NavBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const NavBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            top: 12,
            child: GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (trailing != null)
            Positioned(
              right: 16,
              top: 12,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

/// Bottom tab bar used across main screens.
class BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomTabBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(icon: Icons.menu_book_outlined, label: '练习'),
      _TabItem(icon: Icons.description_outlined, label: '考试'),
      _TabItem(icon: Icons.folder_copy_outlined, label: '资料'),
      _TabItem(icon: Icons.person_outline, label: '我的'),
    ];

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final t = tabs[i];
          final selected = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(context, i),
              behavior: HitTestBehavior.opaque,
              child: Semantics(
                button: true,
                selected: selected,
                label: t.label,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      t.icon,
                      size: 22,
                      color: selected ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color:
                            selected ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    final routes = ['/practice', '/exam', '/resources', '/profile'];
    context.go(routes[index]);
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  _TabItem({required this.icon, required this.label});
}

/// A reusable status bar + nav bar combo.
class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StatusBar(),
        NavBar(title: title, onBack: onBack),
      ],
    );
  }
}

/// Centered empty state for routes that need a clear way back to a safe page.
class AppRouteEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color iconColor;
  final Color iconBgColor;

  const AppRouteEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.iconColor = AppColors.primary,
    this.iconBgColor = AppColors.primaryBg,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
