import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';

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
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final session = mockStore.examSession;
                  if (session == null) {
                    return const Center(child: Text('暂无考试解析'));
                  }
                  final unanswered = _unansweredIndexes(session);
                  final wrong = _wrongIndexes(session);
                  final correct = _correctIndexes(session);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildOverviewPanel(session),
                        const SizedBox(height: 16),
                        _buildNumberSection(
                          context: context,
                          title: '未作答',
                          route: '/exam/analysis/unanswered',
                          titleColor: AppColors.textSecondary,
                          count: '${unanswered.length}题',
                          bgColor: AppColors.card,
                          strokeColor: AppColors.border,
                          numbers: unanswered,
                          cellColor: const Color(0xFFF1F5F9),
                          textColor: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        _buildNumberSection(
                          context: context,
                          title: '答错题',
                          route: '/exam/analysis/wrong',
                          titleColor: AppColors.error,
                          count: '${wrong.length}题',
                          bgColor: AppColors.card,
                          strokeColor: const Color(0xFFFECACA),
                          numbers: wrong,
                          cellColor: const Color(0xFFFEE2E2),
                          textColor: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        _buildNumberSection(
                          context: context,
                          title: '已答对',
                          route: '/exam/analysis/correct',
                          titleColor: AppColors.success,
                          count: '${correct.length}题',
                          bgColor: AppColors.card,
                          strokeColor: const Color(0xFFBBF7D0),
                          numbers: correct,
                          cellColor: const Color(0xFFD1FAE5),
                          textColor: AppColors.success,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewPanel(ExamSession session) {
    return Container(
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
          const Text(
            '解析来源',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.mode} · ${session.title}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statBox('${session.questions.length}', '总题量', AppColors.surface),
              const SizedBox(width: 8),
              _statBox(
                '${session.accuracy}%',
                '正确率',
                const Color(0xFFECFDF5),
              ),
              const SizedBox(width: 8),
              _statBox('${session.score}分', '成绩', const Color(0xFFEFF6FF)),
            ],
          ),
        ],
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
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSection({
    required BuildContext context,
    required String title,
    required String route,
    required Color titleColor,
    required String count,
    required Color bgColor,
    required Color strokeColor,
    required List<int> numbers,
    required Color cellColor,
    required Color textColor,
  }) {
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
                      child: Text(
                        '${numbers.length}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    count,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: numbers.isEmpty
                    ? null
                    : () {
                        mockStore.jumpExamQuestion(numbers.first - 1);
                        context.go(route);
                      },
                child: const Row(
                  children: [
                    Text(
                      '查看全部',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (numbers.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '暂无',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            ..._numberRows(context, numbers, cellColor, textColor, route),
        ],
      ),
    );
  }

  List<Widget> _numberRows(
    BuildContext context,
    List<int> numbers,
    Color cellColor,
    Color textColor,
    String route,
  ) {
    final rows = <Widget>[];
    for (var i = 0; i < numbers.length; i += 6) {
      final cells = numbers.skip(i).take(6).map((number) {
        return Expanded(
          child: _numberCell(context, number, cellColor, textColor, route),
        );
      }).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: cells
                .expand((cell) => [cell, const SizedBox(width: 8)])
                .toList()
              ..removeLast(),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _numberCell(
    BuildContext context,
    int num,
    Color bgColor,
    Color textColor,
    String route,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        mockStore.jumpExamQuestion(num - 1);
        context.go(route);
      },
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$num',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  List<int> _unansweredIndexes(ExamSession session) {
    return List.generate(session.questions.length, (index) => index)
        .where((index) => !session.hasAnswered(session.questions[index].id))
        .map((index) => index + 1)
        .toList();
  }

  List<int> _wrongIndexes(ExamSession session) {
    return List.generate(session.questions.length, (index) => index)
        .where((index) {
          final question = session.questions[index];
          return session.isWrong(question);
        })
        .map((index) => index + 1)
        .toList();
  }

  List<int> _correctIndexes(ExamSession session) {
    return List.generate(session.questions.length, (index) => index)
        .where((index) {
          final question = session.questions[index];
          return session.isCorrect(question);
        })
        .map((index) => index + 1)
        .toList();
  }
}
