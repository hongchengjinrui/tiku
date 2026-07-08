import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Standard status bar widget mimicking iOS status bar at top of screens.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '●●● ■',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
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
          return GestureDetector(
            onTap: () => _handleTap(context, i),
            behavior: HitTestBehavior.opaque,
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
                    color: selected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
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
