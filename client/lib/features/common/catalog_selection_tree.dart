import 'package:flutter/material.dart';

import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class CatalogSelectionTree extends StatelessWidget {
  final List<Chapter> chapters;
  final Set<String> selectedLeafIds;
  final Set<String> expandedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final ValueChanged<Set<String>> onExpansionChanged;

  const CatalogSelectionTree({
    super.key,
    required this.chapters,
    required this.selectedLeafIds,
    required this.expandedIds,
    required this.onSelectionChanged,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (chapters.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
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

    final allLeaves = _leafSections(chapters.expand((item) => item.sections));
    final selectedLeaves =
        allLeaves.where((item) => selectedLeafIds.contains(item.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '已选择 ${selectedLeaves.length} 个小节',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '（覆盖 ${selectedLeaves.fold<int>(0, (sum, item) => sum + item.total)} 道题）',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _rootRow(allLeaves),
              const Divider(height: 1, color: AppColors.borderLight),
              for (var index = 0; index < chapters.length; index++) ...[
                _chapterRow(chapters[index]),
                if (expandedIds.contains(chapters[index].id))
                  ..._sectionRows(chapters[index].sections, depth: 0),
                if (index != chapters.length - 1)
                  const Divider(height: 1, color: AppColors.borderLight),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _rootRow(List<Section> allLeaves) {
    final selectedCount =
        allLeaves.where((item) => selectedLeafIds.contains(item.id)).length;
    final checked = allLeaves.isNotEmpty && selectedCount == allLeaves.length;
    final partial = selectedCount > 0 && !checked;
    return InkWell(
      onTap: () => _toggleLeaves(allLeaves),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '章节练习（共${chapters.length}章）',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '已选 $selectedCount/${allLeaves.length} 节',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 10),
            _SelectionMark(checked: checked, partial: partial),
          ],
        ),
      ),
    );
  }

  Widget _chapterRow(Chapter chapter) {
    final leaves = _leafSections(chapter.sections);
    final selectedCount =
        leaves.where((item) => selectedLeafIds.contains(item.id)).length;
    final checked = leaves.isNotEmpty && selectedCount == leaves.length;
    final partial = selectedCount > 0 && !checked;
    final expanded = expandedIds.contains(chapter.id);
    return InkWell(
      onTap: () => _toggleExpanded(chapter.id),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Icon(
              expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 18,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$selectedCount/${leaves.length}节',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleLeaves(leaves),
              child: _SelectionMark(checked: checked, partial: partial),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sectionRows(List<Section> sections, {required int depth}) {
    return [
      for (final section in sections) ...[
        _sectionRow(section, depth: depth),
        if (section.children.isNotEmpty && expandedIds.contains(section.id))
          ..._sectionRows(section.children, depth: depth + 1),
      ],
    ];
  }

  Widget _sectionRow(Section section, {required int depth}) {
    final leaves = _leafSections([section]);
    final selectedCount =
        leaves.where((item) => selectedLeafIds.contains(item.id)).length;
    final checked = leaves.isNotEmpty && selectedCount == leaves.length;
    final partial = selectedCount > 0 && !checked;
    final expandable = section.children.isNotEmpty;
    final expanded = expandedIds.contains(section.id);

    return InkWell(
      onTap: () =>
          expandable ? _toggleExpanded(section.id) : _toggleLeaves(leaves),
      child: Padding(
        padding: EdgeInsets.fromLTRB(36 + depth * 16, 8, 12, 8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: expandable
                  ? Icon(
                      expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 17,
                      color: AppColors.textMuted,
                    )
                  : null,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                section.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Text(
              '${section.total}题',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleLeaves(leaves),
              child: _SelectionMark(checked: checked, partial: partial),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleExpanded(String id) {
    final next = Set<String>.of(expandedIds);
    if (!next.add(id)) next.remove(id);
    onExpansionChanged(next);
  }

  void _toggleLeaves(Iterable<Section> leaves) {
    final ids = leaves.map((item) => item.id).toSet();
    final next = Set<String>.of(selectedLeafIds);
    if (ids.isNotEmpty && ids.every(next.contains)) {
      next.removeAll(ids);
    } else {
      next.addAll(ids);
    }
    onSelectionChanged(next);
  }

  List<Section> _leafSections(Iterable<Section> sections) {
    return sections
        .expand((section) => section.children.isEmpty
            ? [section]
            : _leafSections(section.children))
        .toList();
  }
}

class _SelectionMark extends StatelessWidget {
  final bool checked;
  final bool partial;

  const _SelectionMark({required this.checked, this.partial = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: checked ? AppColors.primary : AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(
              color: checked || partial
                  ? AppColors.primary
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: checked
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : partial
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}
