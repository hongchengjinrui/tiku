import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import 'p27_submit_exam_confirmation_modal.dart';
import 'p27a_submit_all_answered_modal.dart';

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
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final session = mockStore.examSession;
                  if (session == null) {
                    return const Center(child: Text('暂无考试答题卡'));
                  }
                  final statuses = mockStore.examAnsweredStatus();
                  final unanswered =
                      session.questions.length - session.answeredCount;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _statDot(AppColors.primary,
                                '已答 ${session.answeredCount}'),
                            const SizedBox(width: 32),
                            _statDot(AppColors.textMuted, '未答 $unanswered'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._buildTypeSections(context, session, statuses),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _legendDot(AppColors.primary, '已答'),
                            const SizedBox(width: 28),
                            _legendDot(
                              AppColors.textMuted,
                              '未答',
                              outlined: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _bottomAction(
                                label: '返回答题',
                                bgColor: AppColors.card,
                                fgColor: AppColors.textPrimary,
                                border: true,
                                onTap: () => context.go('/exam/answer'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _bottomAction(
                                label: '确认交卷',
                                bgColor: AppColors.error,
                                fgColor: Colors.white,
                                onTap: () => _submitExam(context),
                              ),
                            ),
                          ],
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

  Future<void> _submitExam(BuildContext context) async {
    final session = mockStore.examSession;
    if (session == null) return;
    final unanswered = session.questions.length - session.answeredCount;
    final router = GoRouter.of(context);
    final bool? confirmed;
    if (unanswered > 0) {
      confirmed = await P27SubmitExamConfirmationModal.show(
        context,
        unansweredCount: unanswered,
      );
    } else {
      confirmed = await P27ASubmitAllAnsweredModal.show(context);
    }
    if (confirmed != true || !context.mounted) return;
    mockStore.submitExam();
    router.go('/exam/analysis');
  }

  List<Widget> _buildTypeSections(
    BuildContext context,
    ExamSession session,
    List<bool> statuses,
  ) {
    final sections = <QuestionType, List<int>>{};
    for (var i = 0; i < session.questions.length; i++) {
      sections.putIfAbsent(session.questions[i].type, () => []).add(i);
    }

    final colors = [
      (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      (const Color(0xFFE0E7FF), const Color(0xFF3730A3)),
      (const Color(0xFFD1FAE5), const Color(0xFF047857)),
      (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      (const Color(0xFFEDE9FE), const Color(0xFF6D28D9)),
    ];

    var colorIndex = 0;
    return sections.entries.map((entry) {
      final color = colors[colorIndex++ % colors.length];
      return _buildSection(
        context,
        session,
        entry.key.label,
        color.$1,
        color.$2,
        entry.value,
        statuses,
      );
    }).toList();
  }

  Widget _buildSection(
    BuildContext context,
    ExamSession session,
    String title,
    Color bgColor,
    Color textColor,
    List<int> indexes,
    List<bool> statuses,
  ) {
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
            child: Text(
              '$title  ${indexes.first + 1}-${indexes.last + 1}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ..._buildRows(context, session, indexes, statuses),
      ],
    );
  }

  List<Widget> _buildRows(
    BuildContext context,
    ExamSession session,
    List<int> indexes,
    List<bool> statuses,
  ) {
    final rows = <Widget>[];
    for (var i = 0; i < indexes.length; i += 5) {
      final rowIndexes = indexes.skip(i).take(5).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowIndexes
                .map(
                  (index) => _buildCell(
                    context,
                    index,
                    statuses[index],
                    index == session.currentIndex,
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildCell(
    BuildContext context,
    int index,
    bool answered,
    bool isCurrent,
  ) {
    return GestureDetector(
      onTap: () {
        mockStore.jumpExamQuestion(index);
        context.go('/exam/answer');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
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
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCurrent
                  ? AppColors.primary
                  : answered
                      ? Colors.white
                      : AppColors.textSecondary,
            ),
          ),
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
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
            border:
                outlined ? Border.all(color: AppColors.border, width: 1) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _bottomAction({
    required String label,
    required Color bgColor,
    required Color fgColor,
    bool border = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: border ? Border.all(color: AppColors.border, width: 1) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ),
      ),
    );
  }
}
