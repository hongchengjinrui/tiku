import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// P01A 切换科目弹窗
class P01ASwitchSubjectSheet extends StatefulWidget {
  final String? currentSubject;
  final ValueChanged<String>? onSubjectSelected;

  const P01ASwitchSubjectSheet({
    super.key,
    this.currentSubject,
    this.onSubjectSelected,
  });

  @override
  State<P01ASwitchSubjectSheet> createState() => _P01ASwitchSubjectSheetState();
}

class _P01ASwitchSubjectSheetState extends State<P01ASwitchSubjectSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSubject ?? '小学教师';
  }

  final _subjects = [
    '小学教师',
    '幼儿教师',
    '中学教师',
    '教师招聘',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x800F172A),
      body: Stack(
        children: [
          // 背景层（点击关闭）
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
          // 底部弹窗面板
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: 18, right: 18, top: 18, bottom: 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('切换科目',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close,
                            size: 20, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('选择后将切换首页统计与练习目录。',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  // 科目胶囊 - 第一行
                  Row(
                    children: _subjects.sublist(0, 2).map((subject) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildSubjectChip(subject),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // 科目胶囊 - 第二行
                  Row(
                    children: _subjects.sublist(2, 4).map((subject) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildSubjectChip(subject),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChip(String subject) {
    final isSelected = subject == _selected;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = subject);
        widget.onSubjectSelected?.call(subject);
        Navigator.of(context).pop();
      },
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 14, color: Colors.white),
              ),
            Text(subject,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: isSelected ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// P02A 重置进度弹窗
class P02AResetProgressSheet extends StatefulWidget {
  final VoidCallback? onConfirm;

  const P02AResetProgressSheet({super.key, this.onConfirm});

  @override
  State<P02AResetProgressSheet> createState() => _P02AResetProgressSheetState();
}

class _P02AResetProgressSheetState extends State<P02AResetProgressSheet> {
  bool _selectAll = false;
  final _selectedChapters = <String>{};

  final _sections = {
    '章节练习': ['第一章：职业基础', '第二章：安全规范', '第三章：实操常识'],
    '模拟真题': ['模拟卷一', '模拟卷二'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x800F172A),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.92,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    left: 18, right: 18, top: 18, bottom: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('重置进度',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close,
                                size: 20, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('选择需要重置的章节，重置后将清空对应章节的练习记录。',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      // 全部目录重置
                      _buildSelectAllCard(),
                      const SizedBox(height: 12),
                      // 二级目录列表
                      ..._sections.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSectionCard(e.key, e.value),
                          )),
                      // 底部操作区
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 126,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text('取消',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      color: AppColors.textPrimary)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onConfirm?.call();
                              },
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('确认重置',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllCard() {
    return Container(
      width: double.infinity,
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('全部目录',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                SizedBox(height: 2),
                Text('清空当前学科下所有练习进度',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() {
              _selectAll = !_selectAll;
              if (_selectAll) {
                _selectedChapters.clear();
                for (final chapters in _sections.values) {
                  _selectedChapters.addAll(chapters);
                }
              } else {
                _selectedChapters.clear();
              }
            }),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectAll ? AppColors.primary : Colors.white,
                border: Border.all(color: AppColors.primary),
              ),
              child: _selectAll
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<String> chapters) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (chapters.every((c) => _selectedChapters.contains(c))) {
                      _selectedChapters.removeAll(chapters);
                    } else {
                      _selectedChapters.addAll(chapters);
                    }
                  });
                },
                child: Text(
                    chapters.every((c) => _selectedChapters.contains(c))
                        ? '取消全选'
                        : '全选',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...chapters.map((chapter) => _buildChapterItem(chapter)),
        ],
      ),
    );
  }

  Widget _buildChapterItem(String chapter) {
    final isSelected = _selectedChapters.contains(chapter);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedChapters.remove(chapter);
          } else {
            _selectedChapters.add(chapter);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(chapter,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

/// P02E 重置进度-二次确认弹窗
class P02EConfirmResetDialog extends StatelessWidget {
  final VoidCallback? onConfirm;

  const P02EConfirmResetDialog({super.key, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x660F172A),
      child: Center(
        child: Container(
          width: 314,
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.restore, size: 20, color: AppColors.error),
              ),
              const SizedBox(height: 14),
              const Text('确认重置进度？',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              const Text('将清空已选目录的练习记录、正确率与错题统计，此操作不可撤销。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text('再想想',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: AppColors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm?.call();
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('确认重置',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
