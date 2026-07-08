import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// P23 考试重置弹窗 - Exam reset modal (bottom sheet style)
/// This widget supports the states shown in P23, P23A, P23B, P23C, P23D.
class P23ExamResetModal extends StatefulWidget {
  final VoidCallback? onClose;

  const P23ExamResetModal({super.key, this.onClose});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height,
        color: const Color(0x800F172A),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [P23ExamResetModal()],
        ),
      ),
    );
  }

  @override
  State<P23ExamResetModal> createState() => _P23ExamResetModalState();
}

class _P23ExamResetModalState extends State<P23ExamResetModal> {
  bool _allSelected = false;
  bool _practiceSelected = false;
  bool _mockSelected = false;
  final List<bool> _practiceItems = [false, false, false, false];
  final List<bool> _mockItems = [false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('重置进度',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              GestureDetector(
                onTap: widget.onClose ?? () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('选择需要重置的考试目录，重置后将清空对应目录的考试记录。',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              )),
          const SizedBox(height: 12),
          // All directory toggle
          _buildAllDirectoryCard(),
          const SizedBox(height: 12),
          // Chapter exam section
          _buildChapterExamSection(),
          const SizedBox(height: 12),
          // Mock exam section
          _buildMockExamSection(),
          const SizedBox(height: 12),
          // Bottom actions
          Row(
            children: [
              GestureDetector(
                onTap: widget.onClose ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 126,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Center(
                    child: Text('取消',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSecondaryConfirmation(),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('确认重置',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
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

  Widget _buildAllDirectoryCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _allSelected = !_allSelected;
          _practiceSelected = _allSelected;
          _mockSelected = _allSelected;
          for (int i = 0; i < _practiceItems.length; i++) {
            _practiceItems[i] = _allSelected;
          }
          for (int i = 0; i < _mockItems.length; i++) {
            _mockItems[i] = _allSelected;
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _allSelected ? AppColors.primaryBg : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('全部目录',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                const Text('章节考试与模拟考试全部重置',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    )),
              ],
            ),
            _buildCheckbox(_allSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterExamSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _practiceSelected = !_practiceSelected;
                for (int i = 0; i < _practiceItems.length; i++) {
                  _practiceItems[i] = _practiceSelected;
                }
                _updateAllState();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('章节考试（共5章）',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(width: 6),
                    const Text('328/1200',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        )),
                  ],
                ),
                _buildCheckbox(_practiceSelected),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Sub items
          ...List.generate(_practiceItems.length, (i) {
            final names = ['第一章：教育基础', '第二章：安全规范', '第三章：实操常识', '第四章：应急处置'];
            return _buildSubRow(names[i], _practiceItems[i], () {
              setState(() {
                _practiceItems[i] = !_practiceItems[i];
                _practiceSelected = _practiceItems.every((e) => e);
                _updateAllState();
              });
            });
          }),
        ],
      ),
    );
  }

  Widget _buildMockExamSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _mockSelected = !_mockSelected;
                for (int i = 0; i < _mockItems.length; i++) {
                  _mockItems[i] = _mockSelected;
                }
                _updateAllState();
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('模拟考试（共7套）',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(width: 6),
                    const Text('46/300',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        )),
                  ],
                ),
                _buildCheckbox(_mockSelected),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_mockItems.length, (i) {
            final names = ['模拟卷一', '模拟卷二'];
            return _buildSubRow(names[i], _mockItems[i], () {
              setState(() {
                _mockItems[i] = !_mockItems[i];
                _mockSelected = _mockItems.every((e) => e);
                _updateAllState();
              });
            });
          }),
        ],
      ),
    );
  }

  Widget _buildSubRow(String name, bool checked, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: checked ? AppColors.surface : AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                )),
            _buildCheckbox(checked),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool checked) {
    if (checked) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    } else {
      // Check for partial selection (some items checked)
      final someChecked = _practiceItems.any((e) => e) || _mockItems.any((e) => e);
      final allInGroup = _practiceSelected || _mockSelected;
      if (someChecked && !allInGroup) {
        // Show half-selected state with dot
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        ),
      );
    }
  }

  void _updateAllState() {
    _allSelected = _practiceSelected && _mockSelected;
  }

  void _showSecondaryConfirmation() {
    showDialog(
      context: context,
      barrierColor: const Color(0x660F172A),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: _SecondaryConfirmDialog(
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }
}

/// P23D 二次确认弹窗 - Secondary confirmation dialog for exam reset
class _SecondaryConfirmDialog extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const _SecondaryConfirmDialog({this.onCancel, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, size: 20, color: AppColors.error),
            ),
            const SizedBox(height: 14),
            const Text('确认重置进度？',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
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
                  flex: 128,
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Center(
                        child: Text('返回修改',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 136,
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('确认重置',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
