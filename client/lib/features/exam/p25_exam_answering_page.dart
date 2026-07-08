import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';

/// P25 考试答题页 - Exam answering page
class P25ExamAnsweringPage extends StatefulWidget {
  const P25ExamAnsweringPage({super.key});

  @override
  State<P25ExamAnsweringPage> createState() => _P25ExamAnsweringPageState();
}

class _P25ExamAnsweringPageState extends State<P25ExamAnsweringPage> {
  @override
  void initState() {
    super.initState();
    if (mockStore.examSession == null) {
      mockStore.startAssemblyExam(
        scope: 'custom',
        questionCount: 20,
        duration: 120,
        notify: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mockStore,
        builder: (context, _) {
          final session = mockStore.examSession;
          if (session == null) {
            return const Center(child: Text('暂无考试内容'));
          }
          final question = session.currentQuestion;
          final selected = session.answers[question.id];
          final isLast = session.currentIndex == session.questions.length - 1;

          return Container(
            color: AppColors.surface,
            width: 390,
            child: Column(
              children: [
                _buildNavBar(context, session),
                _buildProgressArea(session, question),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.stem,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(question.options.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildOption(
                              _letter(index),
                              question.options[index],
                              selected?.contains(index) ?? false,
                              () => _answerQuestion(question, selected, index),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context, session, isLast),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, ExamSession session) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              session.mode,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 8,
            child: GestureDetector(
              onTap: () => _submitExam(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 58,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: const Center(
                  child: Text(
                    '交卷',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressArea(ExamSession session, Question question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '第 ${session.currentIndex + 1} / ${session.questions.length} 题',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                width: 64,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    question.type.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (session.currentIndex + 1) / session.questions.length,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '剩余 ${session.durationMinutes}:00',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _answerQuestion(Question question, Set<int>? selected, int index) {
    if (question.type == QuestionType.multiple) {
      final next = <int>{...?selected};
      if (next.contains(index)) {
        next.remove(index);
      } else {
        next.add(index);
      }
      mockStore.answerExam(next);
      return;
    }
    mockStore.answerExam({index});
  }

  Widget _buildOption(
    String label,
    String text,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBg : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              '$label.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ExamSession session,
    bool isLast,
  ) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomButton(
            icon: Icons.chevron_left,
            text: '上一题',
            fgColor: session.currentIndex == 0
                ? AppColors.textMuted
                : AppColors.textSecondary,
            border: true,
            onTap: session.currentIndex == 0
                ? null
                : mockStore.previousExamQuestion,
          ),
          _bottomButton(
            icon: Icons.grid_view,
            text: '答题卡',
            fgColor: AppColors.textSecondary,
            border: true,
            onTap: () => context.go('/exam/card'),
          ),
          _bottomButton(
            icon: isLast ? Icons.check : Icons.chevron_right,
            text: isLast ? '交卷' : '下一题',
            fgColor: Colors.white,
            bgColor: AppColors.primary,
            iconAfter: true,
            onTap: isLast
                ? () => _submitExam(context)
                : mockStore.nextExamQuestion,
          ),
        ],
      ),
    );
  }

  Widget _bottomButton({
    required IconData icon,
    required String text,
    required Color fgColor,
    Color bgColor = Colors.transparent,
    bool border = false,
    bool iconAfter = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border ? Border.all(color: AppColors.border, width: 1) : null,
        ),
        child: Row(
          children: [
            if (!iconAfter) ...[
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: iconAfter ? FontWeight.w600 : FontWeight.w400,
                color: fgColor,
              ),
            ),
            if (iconAfter) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18, color: fgColor),
            ],
          ],
        ),
      ),
    );
  }

  void _submitExam(BuildContext context) {
    mockStore.submitExam();
    context.go('/exam/analysis');
  }

  String _letter(int index) => String.fromCharCode(65 + index);
}
