import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../common/catalog_selection_tree.dart';

/// P24 组卷设置页
class P24ExamAssemblySettingsPage extends StatefulWidget {
  final String initialScope;

  const P24ExamAssemblySettingsPage({
    super.key,
    this.initialScope = 'custom',
  });

  @override
  State<P24ExamAssemblySettingsPage> createState() =>
      _P24ExamAssemblySettingsPageState();
}

class _P24ExamAssemblySettingsPageState
    extends State<P24ExamAssemblySettingsPage> {
  late String _scope;
  Set<String> _expandedIds = {};
  Set<String> _selectedSectionIds = {};

  @override
  void initState() {
    super.initState();
    _scope = widget.initialScope == 'all' ? 'all' : 'custom';
    if (_scope == 'custom') _selectFirstChapter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '组卷设置'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('组卷范围'),
                    const SizedBox(height: 12),
                    _scopeSelector(),
                    const SizedBox(height: 18),
                    if (_scope == 'custom') ...[
                      _sectionTitle('选择章节'),
                      const SizedBox(height: 12),
                      CatalogSelectionTree(
                        chapters: mockStore.examChapters,
                        selectedLeafIds: _selectedSectionIds,
                        expandedIds: _expandedIds,
                        onSelectionChanged: (value) =>
                            setState(() => _selectedSectionIds = value),
                        onExpansionChanged: (value) =>
                            setState(() => _expandedIds = value),
                      ),
                      const SizedBox(height: 18),
                    ] else ...[
                      _allChapterSummary(),
                      const SizedBox(height: 18),
                    ],
                    _sectionTitle('组卷设置'),
                    const SizedBox(height: 12),
                    _standardPreset(),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: _startButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _scopeSelector() {
    return Row(
      children: [
        Expanded(child: _scopeOption('all', '全部章节')),
        const SizedBox(width: 10),
        Expanded(child: _scopeOption('custom', '自选章节')),
      ],
    );
  }

  Widget _scopeOption(String value, String label) {
    final selected = _scope == value;
    return InkWell(
      onTap: () {
        setState(() {
          _scope = value;
          if (value == 'custom' && _selectedSectionIds.isEmpty) {
            _selectFirstChapter();
          }
        });
      },
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _allChapterSummary() {
    final chapters = mockStore.examChapters;
    final leaves = _leafSections(
      chapters.expand((chapter) => chapter.sections).toList(),
    );
    final totalQuestions =
        leaves.fold<int>(0, (sum, section) => sum + section.total);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                '已选择全部章节',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '覆盖 ${chapters.length} 章 ${leaves.length} 节，共 $totalQuestions 道题',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '系统将从当前科目全部章节中进行标准考试组卷。',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _standardPreset() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tune, size: 17, color: Colors.white),
          SizedBox(width: 7),
          Text(
            '标准考试组卷',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _startButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _startExam,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: const Text(
          '开始考试',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _selectFirstChapter() {
    final chapters = mockStore.examChapters;
    if (chapters.isEmpty) return;
    _expandedIds = {chapters.first.id};
    _selectedSectionIds = _leafSectionIds(chapters.first.sections).toSet();
  }

  List<String> _leafSectionIds(List<Section> sections) {
    return sections
        .expand((section) => section.children.isEmpty
            ? [section.id]
            : _leafSectionIds(section.children))
        .toList();
  }

  List<Section> _leafSections(List<Section> sections) {
    return sections
        .expand((section) => section.children.isEmpty
            ? [section]
            : _leafSections(section.children))
        .toList();
  }

  void _startExam() {
    if (_scope == 'custom' && _selectedSectionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择至少一个小节')),
      );
      return;
    }
    mockStore.startAssemblyExam(
      scope: _scope,
      questionCount: 100,
      duration: 120,
      catalogIds: _scope == 'custom' ? _selectedSectionIds.toList() : const [],
    );
    context.go('/exam/answer');
  }
}
