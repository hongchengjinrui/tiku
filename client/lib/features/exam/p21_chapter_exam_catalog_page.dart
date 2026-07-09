import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../common/progress_reset_sheet.dart';

/// P21 章节考试目录页 - Chapter exam catalog page
class P21ChapterExamCatalogPage extends StatefulWidget {
  const P21ChapterExamCatalogPage({super.key});

  @override
  State<P21ChapterExamCatalogPage> createState() =>
      _P21ChapterExamCatalogPageState();
}

class _P21ChapterExamCatalogPageState extends State<P21ChapterExamCatalogPage> {
  bool _chapterExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '考试模式'),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildSubjectPanel(mockStore),
                        const SizedBox(height: 12),
                        _buildChapterList(context, mockStore),
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

  Widget _buildSubjectPanel(MockAppStore store) {
    final stat = store.examStat;
    return Container(
      width: double.infinity,
      height: 109,
      padding: const EdgeInsets.all(18),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                store.selectedSubject.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => _showResetSheet(store),
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Center(
                    child: Text(
                      '重置',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('考试进度 ${stat.done}/${stat.total}',
                      style: _panelStatStyle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('正确率 ${stat.accuracy}%', style: _panelStatStyle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text('错题量 ${stat.wrong}', style: _panelStatStyle),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stat.progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList(BuildContext context, MockAppStore store) {
    final chapterStat = store.examChapterStat;
    final paperStat = store.examPaperStat;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () =>
                    setState(() => _chapterExpanded = !_chapterExpanded),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '章节考试（共${store.examChapters.length}章）',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${chapterStat.done}/${chapterStat.total} · 正确率 ${chapterStat.accuracy}%',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _chapterExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              if (_chapterExpanded) ...[
                const SizedBox(height: 10),
                ...store.examChapters
                    .map((chapter) => _buildSubItem(context, chapter)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => context.push('/exam/papers'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '模拟考试',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${store.examPapers.length}套模拟卷 · 含全真模拟',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${paperStat.done}/${paperStat.total}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubItem(BuildContext context, Chapter chapter) {
    return GestureDetector(
      onTap: () {
        mockStore.selectExamChapter(chapter.id);
        context.push('/exam/sections');
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                chapter.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${chapter.done}/${chapter.total}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textMuted),
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

  void _showResetSheet(MockAppStore store) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProgressResetSheet(
        title: '重置进度',
        description: '选择需要重置的考试目录，重置后将清空对应目录的考试记录。',
        allDescription: '章节考试与模拟考试全部重置',
        confirmMessage: '将清空已选目录的考试记录、正确率与错题统计，此操作不可撤销。',
        groups: [
          ResetCatalogGroup(
            title: '章节考试（共${store.examChapters.length}章）',
            subtitle:
                '${store.examChapterStat.done}/${store.examChapterStat.total}',
            entries: store.examChapters
                .map(
                  (chapter) => ResetCatalogEntry(
                    id: chapter.id,
                    title: chapter.title,
                    progress: '${chapter.done}/${chapter.total}',
                  ),
                )
                .toList(),
          ),
          ResetCatalogGroup(
            title: '模拟考试（共${store.examPapers.length}套）',
            subtitle:
                '${store.examPaperStat.done}/${store.examPaperStat.total}',
            entries: store.examPapers
                .map(
                  (paper) => ResetCatalogEntry(
                    id: paper.id,
                    title: paper.title,
                    progress: '${paper.done}/${paper.total}',
                  ),
                )
                .toList(),
          ),
        ],
        onConfirm: (catalogIds) =>
            mockStore.resetExamProgress(catalogIds: catalogIds),
      ),
    );
  }
}
