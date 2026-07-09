import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P24A 组卷设置-全部章节 - Assembly settings with all chapters selected
class P24AAssemblyAllChaptersPage extends StatelessWidget {
  const P24AAssemblyAllChaptersPage({super.key});

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
                                _scopeOption('全部章节', true),
                                const SizedBox(width: 10),
                                _scopeOption(
                                  '自定义选择',
                                  false,
                                  onTap: () => context.go('/exam/assemble'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // All chapters summary card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.border, width: 1),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.check_box,
                                          size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text('全部章节（共5章）',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            )),
                                      ),
                                      const Text('1200题',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('已选全部章节，将从中随机抽题组卷',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            _settingRow('题目数量', '100 题'),
                            const SizedBox(height: 10),
                            _settingRow('考试时长', '120 分钟'),
                            const SizedBox(height: 10),
                            _settingRow('及格分数', '60 分'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        mockStore.startAssemblyExam(
                          scope: 'all',
                          questionCount: 100,
                          duration: 120,
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

  Widget _scopeOption(
    String label,
    bool selected, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
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
