import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P28 考试解析页 - Exam analysis page
class P28ExamAnalysisPage extends StatelessWidget {
  const P28ExamAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '查看解析'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Overview panel
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('解析来源',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              )),
                          const SizedBox(height: 4),
                          const Text('模拟考试一 · 高频模拟卷二',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              )),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _statBox('100', '总题量', AppColors.surface),
                              const SizedBox(width: 8),
                              _statBox('78%', '正确率', const Color(0xFFECFDF5)),
                              const SizedBox(width: 8),
                              _statBox('72分', '耗时', const Color(0xFFEFF6FF)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Unanswered section
                    _buildNumberSection(
                      title: '未作答',
                      titleColor: AppColors.textSecondary,
                      count: '12题',
                      bgColor: AppColors.card,
                      strokeColor: AppColors.border,
                      numbers: [3, 7, 15, 28, 44, 67],
                      cellColor: const Color(0xFFF1F5F9),
                      textColor: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    // Wrong section
                    _buildNumberSection(
                      title: '答错题',
                      titleColor: AppColors.error,
                      count: '8题',
                      bgColor: AppColors.card,
                      strokeColor: const Color(0xFFFECACA),
                      numbers: [5, 12, 23, 36, 41, 55],
                      cellColor: const Color(0xFFFEE2E2),
                      textColor: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    // Correct section
                    _buildNumberSection(
                      title: '已答对',
                      titleColor: AppColors.success,
                      count: '80题',
                      bgColor: AppColors.card,
                      strokeColor: const Color(0xFFBBF7D0),
                      numbers: [1, 2, 4, 6, 7, 8, 9, 10, 11, 13],
                      cellColor: const Color(0xFFD1FAE5),
                      textColor: AppColors.success,
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

  Widget _statBox(String value, String label, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textMuted,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSection({
    required String title,
    required Color titleColor,
    required String count,
    required Color bgColor,
    required Color strokeColor,
    required List<int> numbers,
    required Color cellColor,
    required Color textColor,
  }) {
    // Build rows of numbers (6 per row)
    List<Widget> rows = [];
    for (int i = 0; i < numbers.length; i += 6) {
      List<Widget> cells = [];
      for (int j = i; j < i + 6 && j < numbers.length; j++) {
        cells.add(_numberCell(numbers[j], cellColor, textColor));
      }
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: cells
              .expand((cell) => [Expanded(child: cell), const SizedBox(width: 8)])
              .toList()
            ..removeLast(),
        ),
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: strokeColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text('${numbers.length}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      )),
                  const SizedBox(width: 6),
                  Text(count,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textMuted,
                      )),
                ],
              ),
              const Row(
                children: [
                  Text('查看全部',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.primary,
                      )),
                  Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _numberCell(int num, Color bgColor, Color textColor) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text('$num',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            )),
      ),
    );
  }
}
