import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';

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
  late String _selectedRange;
  int _selectedCount = 20;
  final List<String> _rangeOptions = ['全部章节', '已练习章节', '未练习章节', '自选章节'];
  final List<int> _countOptions = [10, 20, 30, 50];
  final Set<String> _expandedChapterIds = {};
  final Set<String> _selectedSectionIds = {};

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
    if (_selectedRange == '自选章节') {
      _selectFirstChapter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '随机练习'),
            // 内容区
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    // 抽题范围
                    _buildSectionTitle('抽题范围'),
                    const SizedBox(height: 12),
                    _buildRangeOptions(),
                    const SizedBox(height: 18),
                    // 题目数量
                    _buildSectionTitle('题目数量'),
                    const SizedBox(height: 12),
                    _buildCountOptions(),
                    if (_selectedRange == '自选章节') ...[
                      const SizedBox(height: 18),
                      _buildSectionTitle('选择章节'),
                      const SizedBox(height: 12),
                      _buildCustomChapterSelector(),
                    ],
                    const SizedBox(height: 18),
                    // 开始按钮
                    _buildStartButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }

  Widget _buildRangeOptions() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _rangeOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _rangeOptions[i] == _selectedRange;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRange = _rangeOptions[i];
                if (_selectedRange == '自选章节' && _selectedSectionIds.isEmpty) {
                  _selectFirstChapter();
                }
              });
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Text(_rangeOptions[i],
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textPrimary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountOptions() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _countOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final count = _countOptions[i];
          final selected = count == _selectedCount;
          return GestureDetector(
            onTap: () => setState(() => _selectedCount = count),
            child: Container(
              width: 72,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Text('$count 题',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textPrimary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        if (_selectedRange == '自选章节' && _selectedSectionIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择至少一个章节')),
          );
          return;
        }
        mockStore.startRandomPractice(
          count: _selectedCount,
          catalogIds: _selectedRange == '自选章节'
              ? _selectedSectionIds.toList()
              : const [],
        );
        context.go('/practice/quiz');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shuffle, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text('开始随机练习',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomChapterSelector() {
    final chapters = mockStore.chapters;
    if (chapters.isEmpty) {
      return _emptySelector('暂无可选章节');
    }
    if (_expandedChapterIds.isEmpty) {
      _expandedChapterIds.add(chapters.first.id);
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < chapters.length; index++) ...[
            _chapterSelectRow(chapters[index]),
            if (_expandedChapterIds.contains(chapters[index].id))
              ..._sectionRows(chapters[index].sections, depth: 0),
            if (index != chapters.length - 1)
              const Divider(height: 1, color: AppColors.borderLight),
          ],
        ],
      ),
    );
  }

  Widget _emptySelector(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _chapterSelectRow(Chapter chapter) {
    final sectionIds = _leafSectionIds(chapter.sections).toSet();
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
                    '${sectionIds.length}节 · ${chapter.total}题',
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

  List<Widget> _sectionRows(List<Section> sections, {required int depth}) {
    return [
      for (final section in sections) ...[
        _sectionSelectRow(section, depth: depth),
        if (section.children.isNotEmpty &&
            _expandedChapterIds.contains(section.id))
          ..._sectionRows(section.children, depth: depth + 1),
      ],
    ];
  }

  Widget _sectionSelectRow(Section section, {required int depth}) {
    final leafIds = _leafSectionIds([section]).toSet();
    final selectedCount = leafIds.where(_selectedSectionIds.contains).length;
    final selected = leafIds.isNotEmpty && selectedCount == leafIds.length;
    final partial = selectedCount > 0 && !selected;
    final expandable = section.children.isNotEmpty;
    final expanded = _expandedChapterIds.contains(section.id);
    return InkWell(
      onTap: () {
        if (expandable) {
          setState(() {
            if (expanded) {
              _expandedChapterIds.remove(section.id);
            } else {
              _expandedChapterIds.add(section.id);
            }
          });
        } else {
          _toggleSection(section);
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(40 + depth * 18, 9, 12, 9),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: expandable
                  ? Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: AppColors.textMuted,
                    )
                  : null,
            ),
            const SizedBox(width: 4),
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
              partial: partial,
              onTap: () => _toggleSection(section),
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
      final ids = _leafSectionIds(chapter.sections);
      final allSelected = ids.every(_selectedSectionIds.contains);
      if (allSelected) {
        _selectedSectionIds.removeAll(ids);
      } else {
        _selectedSectionIds.addAll(ids);
        _expandedChapterIds.add(chapter.id);
      }
    });
  }

  void _toggleSection(Section section) {
    setState(() {
      final ids = _leafSectionIds([section]);
      final allSelected = ids.every(_selectedSectionIds.contains);
      if (allSelected) {
        _selectedSectionIds.removeAll(ids);
      } else {
        _selectedSectionIds.addAll(ids);
        if (section.children.isNotEmpty) {
          _expandedChapterIds.add(section.id);
        }
      }
    });
  }

  void _selectFirstChapter() {
    final chapters = mockStore.chapters;
    if (chapters.isEmpty) return;
    _expandedChapterIds.add(chapters.first.id);
    _selectedSectionIds.addAll(_leafSectionIds(chapters.first.sections));
  }

  List<String> _leafSectionIds(List<Section> sections) {
    return sections
        .expand((section) => section.children.isEmpty
            ? [section.id]
            : _leafSectionIds(section.children))
        .toList();
  }
}

/// P06A 随机练习-自选章节展开态
class P06ARandomPracticeExpandedPage extends StatefulWidget {
  const P06ARandomPracticeExpandedPage({super.key});

  @override
  State<P06ARandomPracticeExpandedPage> createState() =>
      _P06ARandomPracticeExpandedPageState();
}

class _P06ARandomPracticeExpandedPageState
    extends State<P06ARandomPracticeExpandedPage> {
  final _expandedChapters = <String, bool>{
    '基础知识': true,
    '教育教学知识': false,
  };
  final _selectedChapters = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '随机练习'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    const Text('抽题范围',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _buildRangeChip('自选章节', selected: true),
                    const SizedBox(height: 18),
                    const Text('题目数量',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _buildQuickCountRow(),
                    const SizedBox(height: 18),
                    const Text('选择章节',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _buildChapterSelector(),
                    const SizedBox(height: 4),
                    _buildStartButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(String label, {bool selected = false}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border:
            Border.all(color: selected ? AppColors.primary : AppColors.border),
      ),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: selected ? Colors.white : AppColors.textPrimary)),
    );
  }

  Widget _buildQuickCountRow() {
    return Row(
      children: [10, 20, 30, 50]
          .map((c) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 72,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c == 20 ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                        color: c == 20 ? AppColors.primary : AppColors.border),
                  ),
                  child: Text('$c 题',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color:
                              c == 20 ? Colors.white : AppColors.textPrimary)),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildChapterSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _expandedChapters.keys.map((chapter) {
          final expanded = _expandedChapters[chapter]!;
          return Column(
            children: [
              GestureDetector(
                onTap: () =>
                    setState(() => _expandedChapters[chapter] = !expanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(expanded ? Icons.expand_less : Icons.expand_more,
                          size: 20, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(chapter,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 28, top: 4, bottom: 8),
                  child: Column(
                    children: ['第一章', '第二章', '第三章'].map((sub) {
                      final isSelected = _selectedChapters.contains(sub);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedChapters.remove(sub);
                            } else {
                              _selectedChapters.add(sub);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 16,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(sub,
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        mockStore.startRandomPractice(count: 20);
        context.go('/practice/quiz');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shuffle, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text('开始随机练习',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
