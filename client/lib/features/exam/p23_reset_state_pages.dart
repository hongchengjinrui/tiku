import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum _ExamResetState { allSelected, level2Selected, customSelected, confirm }

class P23AResetAllSelectedPage extends StatelessWidget {
  const P23AResetAllSelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExamResetStatePage(state: _ExamResetState.allSelected);
  }
}

class P23BResetLevel2SelectedPage extends StatelessWidget {
  const P23BResetLevel2SelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExamResetStatePage(state: _ExamResetState.level2Selected);
  }
}

class P23CResetCustomSelectedPage extends StatelessWidget {
  const P23CResetCustomSelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExamResetStatePage(state: _ExamResetState.customSelected);
  }
}

class P23DResetSecondaryConfirmationPage extends StatelessWidget {
  const P23DResetSecondaryConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExamResetStatePage(state: _ExamResetState.confirm);
  }
}

class _ExamResetStatePage extends StatelessWidget {
  final _ExamResetState state;

  const _ExamResetStatePage({required this.state});

  bool get _allSelected => state == _ExamResetState.allSelected;
  bool get _chapterSelected =>
      _allSelected || state == _ExamResetState.level2Selected;
  bool get _chapterPartial => state == _ExamResetState.customSelected;
  bool get _allPartial =>
      state == _ExamResetState.level2Selected ||
      state == _ExamResetState.customSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x800F172A),
      child: SizedBox(
        width: 390,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildSheet(),
            ),
            if (state == _ExamResetState.confirm)
              const Center(
                child: _ExamResetConfirmDialog(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheet() {
    return Container(
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
            '选择需要重置的考试目录，重置后将清空对应目录的考试记录。',
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
            title: '章节考试（共5章）',
            subtitle: '328/1200',
            checked: _chapterSelected,
            partial: _chapterPartial,
            rows: const [
              _ExamResetRowData('第一章：教育基础', '46/120'),
              _ExamResetRowData('第二章：学生指导', '72/160'),
              _ExamResetRowData('第三章：班级管理', '35/90'),
              _ExamResetRowData('第四章：学科知识', '60/140'),
            ],
            rowSelected: (index) {
              if (_allSelected || _chapterSelected) return true;
              return index == 0 || index == 2;
            },
          ),
          const SizedBox(height: 12),
          _buildGroup(
            title: '模拟考试（共7套）',
            subtitle: '46/300',
            checked: _allSelected,
            partial: false,
            rows: const [
              _ExamResetRowData('模拟卷一', '24/100'),
              _ExamResetRowData('模拟卷二', '22/100'),
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
                  '章节考试与模拟考试全部重置',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          _ExamCheckMark(checked: _allSelected, partial: _allPartial),
        ],
      ),
    );
  }

  Widget _buildGroup({
    required String title,
    required String subtitle,
    required bool checked,
    required bool partial,
    required List<_ExamResetRowData> rows,
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
              _ExamCheckMark(checked: checked, partial: partial),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++)
            _ExamResetItem(row: rows[i], checked: rowSelected(i)),
        ],
      ),
    );
  }
}

class _ExamResetItem extends StatelessWidget {
  final _ExamResetRowData row;
  final bool checked;

  const _ExamResetItem({required this.row, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.only(left: 8),
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
          _ExamCheckMark(checked: checked),
        ],
      ),
    );
  }
}

class _ExamCheckMark extends StatelessWidget {
  final bool checked;
  final bool partial;

  const _ExamCheckMark({required this.checked, this.partial = false});

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

class _ExamResetConfirmDialog extends StatelessWidget {
  const _ExamResetConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 314,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.errorBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.refresh, size: 20, color: AppColors.error),
          ),
          const SizedBox(height: 14),
          const Text(
            '确认重置进度？',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '将清空已选目录的考试记录、正确率与错题统计，此操作不可撤销。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    '返回修改',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '确认重置',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamResetRowData {
  final String title;
  final String progress;

  const _ExamResetRowData(this.title, this.progress);
}
