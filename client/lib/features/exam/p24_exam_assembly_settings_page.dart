import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
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
                            // Custom scope tree
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.border, width: 1),
                              ),
                              child: Column(
                                children: [
                                  _scopeTreeItem('第一章：教育基础', true),
                                  _scopeTreeItem('第二章：安全规范', true),
                                  _scopeTreeItem('第三章：实操常识', false),
                                  _scopeTreeItem('第四章：应急处置', true),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
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
                        mockStore.startAssemblyExam(
                          scope: _scope == 'all' ? 'all' : 'custom',
                          questionCount: _questionCount,
                          duration: _duration,
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
        onTap: () => setState(() => _scope = value),
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

  Widget _scopeTreeItem(String title, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
            color: checked ? AppColors.primary : AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                )),
          ),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
        ],
      ),
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
