import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ResetCatalogEntry {
  final String id;
  final String title;
  final String progress;

  const ResetCatalogEntry({
    required this.id,
    required this.title,
    required this.progress,
  });
}

class ResetCatalogGroup {
  final String title;
  final String subtitle;
  final List<ResetCatalogEntry> entries;

  const ResetCatalogGroup({
    required this.title,
    required this.subtitle,
    required this.entries,
  });
}

class ProgressResetSheet extends StatefulWidget {
  final String title;
  final String description;
  final String allDescription;
  final String confirmMessage;
  final List<ResetCatalogGroup> groups;
  final Future<bool> Function(List<String> catalogIds) onConfirm;

  const ProgressResetSheet({
    super.key,
    required this.title,
    required this.description,
    required this.allDescription,
    required this.confirmMessage,
    required this.groups,
    required this.onConfirm,
  });

  @override
  State<ProgressResetSheet> createState() => _ProgressResetSheetState();
}

class _ProgressResetSheetState extends State<ProgressResetSheet> {
  late final Set<String> _selectedIds;
  bool _submitting = false;

  List<String> get _allIds => widget.groups
      .expand((group) => group.entries)
      .map((entry) => entry.id)
      .toSet()
      .toList();

  bool get _allChecked =>
      _selectedIds.length == _allIds.length && _allIds.isNotEmpty;
  bool get _allPartial => _selectedIds.isNotEmpty && !_allChecked;

  @override
  void initState() {
    super.initState();
    _selectedIds = _allIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close,
                        size: 20, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAllRow(),
                    const SizedBox(height: 12),
                    ...widget.groups.map(_buildGroup),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitting || _selectedIds.isEmpty
                          ? null
                          : _confirmReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_submitting ? '重置中' : '确认重置'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRow() {
    return GestureDetector(
      onTap: _toggleAll,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '全部目录',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.allDescription,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            _CheckMark(checked: _allChecked, partial: _allPartial),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(ResetCatalogGroup group) {
    final ids = group.entries.map((entry) => entry.id).toSet();
    final selectedCount = ids.intersection(_selectedIds).length;
    final checked = ids.isNotEmpty && selectedCount == ids.length;
    final partial = selectedCount > 0 && !checked;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _toggleGroup(ids),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          group.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        group.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                _CheckMark(checked: checked, partial: partial),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in group.entries) _buildEntry(entry),
        ],
      ),
    );
  }

  Widget _buildEntry(ResetCatalogEntry entry) {
    final checked = _selectedIds.contains(entry.id);
    return GestureDetector(
      onTap: () => _toggleEntry(entry.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34,
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              entry.progress,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            _CheckMark(checked: checked),
          ],
        ),
      ),
    );
  }

  void _toggleAll() {
    setState(() {
      if (_allChecked) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(_allIds);
      }
    });
  }

  void _toggleGroup(Set<String> ids) {
    setState(() {
      final checked = ids.every(_selectedIds.contains);
      if (checked) {
        _selectedIds.removeAll(ids);
      } else {
        _selectedIds.addAll(ids);
      }
    });
  }

  void _toggleEntry(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认重置进度？'),
        content: Text(widget.confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('返回修改'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    setState(() => _submitting = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await widget.onConfirm(_selectedIds.toList());
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? '进度已重置' : '重置失败，请稍后重试')),
    );
    if (ok) navigator.pop();
    if (mounted) setState(() => _submitting = false);
  }
}

class _CheckMark extends StatelessWidget {
  final bool checked;
  final bool partial;

  const _CheckMark({required this.checked, this.partial = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: DecoratedBox(
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
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
      ),
    );
  }
}
