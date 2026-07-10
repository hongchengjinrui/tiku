import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import 'p21b_retake_confirmation_modal.dart';

/// P21A 章节考试小节列表 - Chapter exam section list
class P21AChapterExamSectionListPage extends StatelessWidget {
  const P21AChapterExamSectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            NavBar(title: mockStore.selectedSubject.name),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final chapter = mockStore.selectedExamChapter;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildBreadcrumbPanel(chapter),
                        const SizedBox(height: 14),
                        const Text(
                          '章节目录',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
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
      ),
    );
  }

  Widget _buildBreadcrumbPanel(Chapter chapter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '章节考试/${chapter.title}',
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
                  child: Text('考试进度 ${chapter.done}/${chapter.total}',
                      style: _panelStatStyle),
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
    final canResume = mockStore.canResumeExamSection(section.id);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '已考 ${section.done}/${section.total} · 已用时 ${section.minutes}分',
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
                child: _actionButton(
                  icon: Icons.refresh,
                  label: '重考',
                  bgColor: AppColors.surface,
                  fgColor: AppColors.textSecondary,
                  borderColor: AppColors.border,
                  onTap: () => _retakeSection(context, section),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  icon: Icons.play_arrow,
                  label: canResume ? '继续考试' : '开始考试',
                  bgColor: AppColors.primary,
                  fgColor: Colors.white,
                  onTap: () {
                    if (!canResume) {
                      mockStore.startExamFromSection(section.id);
                    }
                    context.go('/exam/answer');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _retakeSection(BuildContext context, Section section) async {
    final confirmed = await P21BRetakeConfirmationModal.show(
      context,
      message: '将重新开始该小节考试，本次作答会覆盖当前进度记录。',
    );
    if (confirmed != true || !context.mounted) return;
    mockStore.startExamFromSection(section.id);
    context.go('/exam/answer');
  }

  List<Section> _leafSections(List<Section> sections) {
    return sections
        .expand((section) => section.children.isEmpty
            ? [section]
            : _leafSections(section.children))
        .toList();
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: fgColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
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
