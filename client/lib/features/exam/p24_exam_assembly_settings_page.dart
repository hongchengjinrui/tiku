import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P24 组卷设置页 - Exam assembly settings
class P24ExamAssemblySettingsPage extends StatefulWidget {
  const P24ExamAssemblySettingsPage({super.key});

  @override
  State<P24ExamAssemblySettingsPage> createState() =>
      _P24ExamAssemblySettingsPageState();
}

class _P24ExamAssemblySettingsPageState
    extends State<P24ExamAssemblySettingsPage> {
  String _scope = 'custom';
  int _questionCount = 100;
  int _duration = 120;
  final Set<String> _expandedChapterIds = {};
  final Set<String> _selectedSectionIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '组卷设置'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Scope Section
                            const Text('组卷范围',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _scopeOption('all', '全部章节'),
                                const SizedBox(width: 10),
                                _scopeOption('custom', '自定义选择'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_scope == 'custom') ...[
                              _buildChapterSelector(),
                              const SizedBox(height: 16),
                            ],
                            // Exam settings
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('考试设置',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    )),
                                Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.tune,
                                          size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text('标准考试组卷',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _settingRow('题目数量', '$_questionCount 题'),
                            const SizedBox(height: 10),
                            _settingRow('考试时长', '$_duration 分钟'),
                            const SizedBox(height: 10),
                            _settingRow('及格分数', '60 分'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Start exam button
                    GestureDetector(
                      onTap: () {
                        if (_scope == 'custom' && _selectedSectionIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请选择至少一个章节')),
                          );
                          return;
                        }
                        mockStore.startAssemblyExam(
                          scope: _scope == 'all' ? 'all' : 'custom',
                          questionCount: _questionCount,
                          duration: _duration,
                          catalogIds: _scope == 'custom'
                              ? _selectedSectionIds.toList()
                              : const [],
                        );
                        context.go('/exam/answer');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('开始考试',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scopeOption(String value, String label) {
    final selected = _scope == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _scope = value;
            if (_scope == 'custom' && _selectedSectionIds.isEmpty) {
              _selectFirstChapter();
            }
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBg : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 16,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterSelector() {
    final chapters = mockStore.examChapters;
    if (chapters.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Text(
          '暂无可选章节',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    if (_expandedChapterIds.isEmpty) {
      _expandedChapterIds.add(chapters.first.id);
      _selectedSectionIds.addAll(
        chapters.first.sections.map((section) => section.id),
      );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          for (var index = 0; index < chapters.length; index++) ...[
            _chapterSelectRow(chapters[index]),
            if (_expandedChapterIds.contains(chapters[index].id))
              ...chapters[index].sections.map(_sectionSelectRow),
            if (index != chapters.length - 1)
              const Divider(height: 1, color: AppColors.borderLight),
          ],
        ],
      ),
    );
  }

  Widget _chapterSelectRow(Chapter chapter) {
    final sectionIds = chapter.sections.map((section) => section.id).toSet();
    final selectedCount = sectionIds.where(_selectedSectionIds.contains).length;
    final allSelected =
        sectionIds.isNotEmpty && selectedCount == sectionIds.length;
    final partialSelected = selectedCount > 0 && !allSelected;
    final expanded = _expandedChapterIds.contains(chapter.id);
    return InkWell(
      onTap: () {
        setState(() {
          if (expanded) {
            _expandedChapterIds.remove(chapter.id);
          } else {
            _expandedChapterIds.add(chapter.id);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Row(
          children: [
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${chapter.sections.length}节 · ${chapter.total}题',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _selectionIcon(
              checked: allSelected,
              partial: partialSelected,
              onTap: () => _toggleChapter(chapter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionSelectRow(Section section) {
    final selected = _selectedSectionIds.contains(section.id);
    return InkWell(
      onTap: () => _toggleSection(section.id),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 9, 12, 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                section.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${section.total}题',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            _selectionIcon(
              checked: selected,
              partial: false,
              onTap: () => _toggleSection(section.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionIcon({
    required bool checked,
    required bool partial,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          checked
              ? Icons.check_circle
              : partial
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
          size: 20,
          color: checked || partial ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }

  void _toggleChapter(Chapter chapter) {
    setState(() {
      final ids = chapter.sections.map((section) => section.id);
      final allSelected = ids.every(_selectedSectionIds.contains);
      if (allSelected) {
        _selectedSectionIds.removeAll(ids);
      } else {
        _selectedSectionIds.addAll(ids);
        _expandedChapterIds.add(chapter.id);
      }
    });
  }

  void _toggleSection(String sectionId) {
    setState(() {
      if (_selectedSectionIds.contains(sectionId)) {
        _selectedSectionIds.remove(sectionId);
      } else {
        _selectedSectionIds.add(sectionId);
      }
    });
  }

  void _selectFirstChapter() {
    final chapters = mockStore.examChapters;
    if (chapters.isEmpty) return;
    _expandedChapterIds.add(chapters.first.id);
    _selectedSectionIds.addAll(
      chapters.first.sections.map((section) => section.id),
    );
  }

  Widget _settingRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textPrimary,
              )),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  )),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}
