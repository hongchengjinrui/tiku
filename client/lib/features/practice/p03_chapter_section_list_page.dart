import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../features/exam/p03a_section_reset_confirmation_modal.dart';
import '../../theme/app_colors.dart';

/// P03 章节练习小节列表 - 含状态栏、导航栏、章节数据面板、各小节卡片
class P03ChapterSectionListPage extends StatelessWidget {
  const P03ChapterSectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const StatusBar(),
          NavBar(title: mockStore.selectedSubject.name),
          Expanded(
            child: AnimatedBuilder(
              animation: mockStore,
              builder: (context, _) {
                final chapter = mockStore.selectedChapter;
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      _buildChapterStatsPanel(chapter),
                      const SizedBox(height: 14),
                      ..._leafSections(chapter.sections).expand(
                        (section) => [
                          _buildSectionCard(context, section),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterStatsPanel(Chapter chapter) {
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
          Text(
            '章节练习/${chapter.title}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '练习进度 ${chapter.done}/${chapter.total}',
                    style: _panelStatStyle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child:
                      Text('正确率 ${chapter.accuracy}%', style: _panelStatStyle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text('错题量 ${chapter.wrong}', style: _panelStatStyle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: chapter.progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, Section section) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '已练 ${section.done}/${section.total} · 正确率 ${section.accuracy}% · 错题 ${section.wrong}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  text: '重置',
                  icon: Icons.refresh,
                  bgColor: AppColors.surface,
                  fgColor: AppColors.textSecondary,
                  borderColor: AppColors.border,
                  onTap: () => _resetSection(context, section),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  text: '错题',
                  bgColor: const Color(0xFFFEF2F2),
                  fgColor: AppColors.error,
                  onTap: () => context.go('/practice/wrong'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  text: '背题',
                  bgColor: AppColors.successBg,
                  fgColor: AppColors.success,
                  onTap: () {
                    mockStore.startPracticeFromSection(section.id);
                    context.go('/practice/quiz');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  text: section.done == 0 ? '开始' : '继续',
                  bgColor: AppColors.primary,
                  fgColor: Colors.white,
                  onTap: () {
                    mockStore.startPracticeFromSection(section.id);
                    context.go('/practice/quiz');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _resetSection(BuildContext context, Section section) async {
    final confirmed = await P03ASectionResetConfirmationModal.show(context);
    if (confirmed != true || !context.mounted) return;
    final ok = await mockStore.resetPracticeProgress(
      catalogIds: [section.id],
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '小节进度已重置' : '重置失败，请稍后重试')),
    );
  }

  List<Section> _leafSections(List<Section> sections) {
    return sections
        .expand((section) => section.children.isEmpty
            ? [section]
            : _leafSections(section.children))
        .toList();
  }

  Widget _buildActionButton({
    required String text,
    IconData? icon,
    required Color bgColor,
    required Color fgColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
      ),
    );
  }

  static const _panelStatStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
