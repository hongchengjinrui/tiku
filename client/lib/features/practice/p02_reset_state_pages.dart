import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum _PracticeResetState { allSelected, level2Selected, customSelected }

class P02BResetAllSelectedPage extends StatelessWidget {
  const P02BResetAllSelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PracticeResetStatePage(
        state: _PracticeResetState.allSelected);
  }
}

class P02CResetLevel2SelectedPage extends StatelessWidget {
  const P02CResetLevel2SelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PracticeResetStatePage(
      state: _PracticeResetState.level2Selected,
    );
  }
}

class P02DResetCustomSelectedPage extends StatelessWidget {
  const P02DResetCustomSelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PracticeResetStatePage(
      state: _PracticeResetState.customSelected,
    );
  }
}

class _PracticeResetStatePage extends StatelessWidget {
  final _PracticeResetState state;

  const _PracticeResetStatePage({required this.state});

  bool get _allSelected => state == _PracticeResetState.allSelected;
  bool get _chapterSelected =>
      _allSelected || state == _PracticeResetState.level2Selected;
  bool get _chapterPartial => state == _PracticeResetState.customSelected;
  bool get _allPartial => state != _PracticeResetState.allSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x800F172A),
      child: SizedBox(
        width: 390,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '重置进度',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '选择需要重置的目录，重置后将清空对应目录的练习记录。',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAllRow(),
                  const SizedBox(height: 12),
                  _buildGroup(
                    title: '章节练习（共5章）',
                    subtitle: '328/700',
                    checked: _chapterSelected,
                    partial: _chapterPartial,
                    rows: const [
                      _ResetRowData('第一章：教育基础', '46/120'),
                      _ResetRowData('第二章：学生指导', '72/160'),
                      _ResetRowData('第三章：班级管理', '35/90'),
                      _ResetRowData('第四章：打分考评', '80/80'),
                    ],
                    rowSelected: (index) {
                      if (_allSelected || _chapterSelected) return true;
                      return index == 0 || index == 2;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildGroup(
                    title: '模拟真题（共7套）',
                    subtitle: '46/300',
                    checked: _allSelected,
                    partial: false,
                    rows: const [
                      _ResetRowData('2025年上半年真题卷', '24/100'),
                      _ResetRowData('2024年下半年真题卷', '22/100'),
                    ],
                    rowSelected: (_) => _allSelected,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 126,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '确认重置',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
    return Container(
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
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '全部目录',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '章节练习与模拟真题全部重置',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          _CheckMark(checked: _allSelected, partial: _allPartial),
        ],
      ),
    );
  }

  Widget _buildGroup({
    required String title,
    required String subtitle,
    required bool checked,
    required bool partial,
    required List<_ResetRowData> rows,
    required bool Function(int index) rowSelected,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
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
                      subtitle,
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
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++)
            _ResetItem(row: rows[i], checked: rowSelected(i)),
        ],
      ),
    );
  }
}

class _ResetItem extends StatelessWidget {
  final _ResetRowData row;
  final bool checked;

  const _ResetItem({required this.row, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.only(left: 8, right: 0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            row.progress,
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
    );
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

class _ResetRowData {
  final String title;
  final String progress;

  const _ResetRowData(this.title, this.progress);
}
