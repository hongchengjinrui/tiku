import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P26 答题卡页 - Answer card page
class P26AnswerCardPage extends StatelessWidget {
  const P26AnswerCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '答题卡'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statDot(AppColors.primary, '已答 68'),
                        const SizedBox(width: 32),
                        _statDot(AppColors.textMuted, '未答 32'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Grid sections
                    _buildSection('单选题  1-40', const Color(0xFFDBEAFE), const Color(0xFF1D4ED8), 1, 40, _answeredStatus()),
                    _buildSection('多选题  41-60', const Color(0xFFE0E7FF), const Color(0xFF3730A3), 41, 60, _answeredStatus2()),
                    _buildSection('判断题  61-75', const Color(0xFFD1FAE5), const Color(0xFF047857), 61, 75, _answeredStatus3()),
                    _buildSection('填空题  76-85', const Color(0xFFFEF3C7), const Color(0xFF92400E), 76, 85, _answeredStatus4()),
                    _buildSection('简答题  86-95', const Color(0xFFEDE9FE), const Color(0xFF6D28D9), 86, 95, _answeredStatus5()),
                    _buildSection('材料题  96-100', const Color(0xFFE0F2FE), const Color(0xFF0369A1), 96, 100, _answeredStatus6()),
                    const SizedBox(height: 16),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendDot(AppColors.primary, '已答'),
                        const SizedBox(width: 28),
                        _legendDot(AppColors.textMuted, '未答', outlined: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bottom buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: const Center(
                                child: Text('返回答题',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    )),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('确认交卷',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _statDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            )),
      ],
    );
  }

  Widget _legendDot(Color color, String label, {bool outlined = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(4),
            border: outlined ? Border.all(color: AppColors.border, width: 1) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            )),
      ],
    );
  }

  // Returns a map of question number -> answered status
  List<bool> _answeredStatus() => List.generate(40, (i) => ![12, 16, 22].contains(i + 1));
  List<bool> _answeredStatus2() => List.generate(20, (i) => ![6, 13].contains(i + 41));
  List<bool> _answeredStatus3() => List.generate(15, (i) => ![5].contains(i + 61));
  List<bool> _answeredStatus4() => List.generate(10, (i) => ![3].contains(i + 76));
  List<bool> _answeredStatus5() => List.generate(10, (i) => ![5].contains(i + 86));
  List<bool> _answeredStatus6() => List.generate(5, (i) => false);

  Widget _buildSection(String title, Color bgColor, Color textColor, int start, int end, List<bool> answered) {
    final currentQuestion = 18; // current highlighted
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                )),
          ),
        ),
        const SizedBox(height: 10),
        ..._buildRows(start, end, answered, currentQuestion),
      ],
    );
  }

  List<Widget> _buildRows(int start, int end, List<bool> answered, int current) {
    List<Widget> rows = [];
    for (int i = start; i <= end; i += 5) {
      List<Widget> cells = [];
      for (int j = i; j < i + 5 && j <= end; j++) {
        final idx = j - start;
        final isAnswered = idx < answered.length ? answered[idx] : false;
        final isCurrent = j == current;
        cells.add(_buildCell(j, isAnswered, isCurrent));
      }
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cells,
        ),
      ));
    }
    return rows;
  }

  Widget _buildCell(int num, bool answered, bool isCurrent) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.card
            : answered
                ? AppColors.primary
                : AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: isCurrent
            ? Border.all(color: AppColors.primary, width: 2)
            : !answered
                ? Border.all(color: AppColors.border, width: 1)
                : null,
      ),
      child: Center(
        child: Text('$num',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCurrent
                  ? AppColors.primary
                  : answered
                      ? Colors.white
                      : AppColors.textSecondary,
            )),
      ),
    );
  }
}
