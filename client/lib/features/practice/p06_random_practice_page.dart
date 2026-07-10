import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../common/catalog_selection_tree.dart';

/// P06 随机练习设置页
class P06RandomPracticePage extends StatefulWidget {
  final String initialRange;

  const P06RandomPracticePage({
    super.key,
    this.initialRange = '全部章节',
  });

  @override
  State<P06RandomPracticePage> createState() => _P06RandomPracticePageState();
}

class _P06RandomPracticePageState extends State<P06RandomPracticePage> {
  static const _rangeOptions = ['全部章节', '自选章节'];
  static const _countOptions = [10, 30, 50];

  late String _selectedRange;
  int _selectedCount = 30;
  Set<String> _expandedIds = {};
  Set<String> _selectedSectionIds = {};

  @override
  void initState() {
    super.initState();
    _selectedRange = _rangeOptions.contains(widget.initialRange)
        ? widget.initialRange
        : _rangeOptions.first;
    if (_selectedRange == '自选章节') _selectFirstChapter();
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
            const NavBar(title: '随机练习'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('抽题范围'),
                    const SizedBox(height: 12),
                    _rangeSelector(),
                    const SizedBox(height: 18),
                    _sectionTitle('题目数量'),
                    const SizedBox(height: 12),
                    _countSelector(),
                    if (_selectedRange == '自选章节') ...[
                      const SizedBox(height: 18),
                      _sectionTitle('选择章节'),
                      const SizedBox(height: 12),
                      CatalogSelectionTree(
                        chapters: mockStore.chapters,
                        selectedLeafIds: _selectedSectionIds,
                        expandedIds: _expandedIds,
                        onSelectionChanged: (value) =>
                            setState(() => _selectedSectionIds = value),
                        onExpansionChanged: (value) =>
                            setState(() => _expandedIds = value),
                      ),
                    ],
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

  Widget _rangeSelector() {
    return Row(
      children: [
        for (var index = 0; index < _rangeOptions.length; index++) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(child: _optionTile(_rangeOptions[index])),
        ],
      ],
    );
  }

  Widget _countSelector() {
    return Row(
      children: [
        for (var index = 0; index < _countOptions.length; index++) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(
            child: _optionTile(
              '${_countOptions[index]}题',
              selected: _selectedCount == _countOptions[index],
              onTap: () =>
                  setState(() => _selectedCount = _countOptions[index]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _optionTile(
    String label, {
    bool? selected,
    VoidCallback? onTap,
  }) {
    final isSelected = selected ?? _selectedRange == label;
    return InkWell(
      onTap: onTap ?? () => _setRange(label),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _startButton() {
    return InkWell(
      onTap: _startPractice,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Ink(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shuffle, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              '开始随机练习',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setRange(String range) {
    setState(() {
      _selectedRange = range;
      if (range == '自选章节' && _selectedSectionIds.isEmpty) {
        _selectFirstChapter();
      }
    });
  }

  void _selectFirstChapter() {
    final chapters = mockStore.chapters;
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

  void _startPractice() {
    final catalogIds = _selectedRange == '自选章节'
        ? _selectedSectionIds.toList()
        : const <String>[];
    if (_selectedRange == '自选章节' && catalogIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择至少一个小节')),
      );
      return;
    }
    mockStore.startRandomPractice(
      count: _selectedCount,
      catalogIds: catalogIds,
      title: _selectedRange == '全部章节' ? '随机练习' : '自选章节随机练习',
    );
    context.go('/practice/quiz');
  }
}

/// P06A 保留为自选章节状态入口。
class P06ARandomPracticeExpandedPage extends StatelessWidget {
  const P06ARandomPracticeExpandedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const P06RandomPracticePage(initialRange: '自选章节');
  }
}
