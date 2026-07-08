import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';

/// P05 刷题页 - 含状态栏、导航栏、题目进度区、选项区、操作区、解析区和底部操作栏
class P05QuestionPracticePage extends StatefulWidget {
  const P05QuestionPracticePage({super.key});

  @override
  State<P05QuestionPracticePage> createState() =>
      _P05QuestionPracticePageState();
}

class _P05QuestionPracticePageState extends State<P05QuestionPracticePage> {
  @override
  void initState() {
    super.initState();
    if (mockStore.practiceSession == null) {
      mockStore.startPracticeFromSection(
        mockStore.selectedChapter.sections.first.id,
        notify: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AnimatedBuilder(
        animation: mockStore,
        builder: (context, _) {
          final session = mockStore.practiceSession;
          if (session == null) {
            return const Center(child: Text('暂无练习内容'));
          }

          final question = session.currentQuestion;
          final selected = session.answers[question.id];
          final answered = selected != null && selected.isNotEmpty;
          final isLast = session.currentIndex == session.questions.length - 1;

          return Column(
            children: [
              const StatusBar(),
              NavBar(
                title: session.title,
                onBack: () => context.go('/practice/catalog'),
              ),
              _buildProgressArea(session, question),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 20,
                  ),
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
                      Column(
                        children:
                            List.generate(question.options.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildOption(
                              label: '${_letter(index)}.',
                              text: question.options[index],
                              state: _optionState(question, selected, index),
                              onTap: () =>
                                  _answerQuestion(question, selected, index),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionChip(icon: Icons.star, text: '收藏'),
                          const SizedBox(width: 16),
                          _buildActionChip(
                            icon: Icons.report_problem_outlined,
                            text: '纠错',
                          ),
                        ],
                      ),
                      if (answered) ...[
                        const SizedBox(height: 16),
                        _buildAnalysis(question, selected),
                      ],
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, session, isLast),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressArea(PracticeSession session, Question question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 ${session.currentIndex + 1} / ${session.questions.length} 题',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  question.type.label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
      mockStore.answerPractice(next);
      return;
    }
    mockStore.answerPractice({index});
  }

  OptionState _optionState(Question question, Set<int>? selected, int index) {
    if (selected == null || selected.isEmpty) {
      return OptionState.unselected;
    }
    if (question.answerIndexes.contains(index)) {
      return OptionState.correct;
    }
    if (selected.contains(index)) {
      return OptionState.wrong;
    }
    return OptionState.unselected;
  }

  Widget _buildOption({
    required String label,
    required String text,
    required OptionState state,
    required VoidCallback onTap,
  }) {
    Color bgColor;
    Color borderColor;
    Color labelColor;
    Color textColor;
    Widget leading;

    switch (state) {
      case OptionState.wrong:
        bgColor = const Color(0xFFFEE2E2);
        borderColor = AppColors.error;
        labelColor = const Color(0xFF991B1B);
        textColor = const Color(0xFF991B1B);
        leading = _buildIconCircle(Icons.close, AppColors.error);
        break;
      case OptionState.correct:
        bgColor = const Color(0xFFD1FAE5);
        borderColor = AppColors.success;
        labelColor = const Color(0xFF065F46);
        textColor = const Color(0xFF065F46);
        leading = _buildIconCircle(Icons.check, AppColors.success);
        break;
      case OptionState.unselected:
        bgColor = AppColors.card;
        borderColor = AppColors.border;
        labelColor = AppColors.textPrimary;
        textColor = AppColors.textPrimary;
        leading = _buildCircle();
        break;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysis(Question question, Set<int>? selected) {
    final correct = sameAnswer(selected, question.answerIndexes);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? '回答正确' : '回答错误',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: correct ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                '正确答案：${_answerText(question.answerIndexes)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.success,
                ),
              ),
              Text(
                '你的答案：${_answerText(selected ?? const {})}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: correct ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.analysis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    PracticeSession session,
    bool isLast,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomButton(
            icon: Icons.chevron_left,
            text: '上一题',
            bgColor: Colors.transparent,
            fgColor: session.currentIndex == 0
                ? AppColors.textMuted
                : AppColors.textSecondary,
            borderColor: AppColors.border,
            onTap: session.currentIndex == 0
                ? null
                : mockStore.previousPracticeQuestion,
          ),
          _buildBottomButton(
            icon: Icons.grid_view_outlined,
            text: '答题卡',
            bgColor: Colors.transparent,
            fgColor: AppColors.textSecondary,
            borderColor: AppColors.border,
          ),
          _buildBottomButton(
            icon: isLast ? Icons.check : Icons.chevron_right,
            text: isLast ? '完成练习' : '下一题',
            bgColor: AppColors.primary,
            fgColor: Colors.white,
            iconAfter: true,
            onTap: () {
              if (isLast) {
                mockStore.finishPracticeSession();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('练习记录已生成')),
                );
                context.go('/practice/catalog');
              } else {
                mockStore.nextPracticeQuestion();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color fgColor,
    Color? borderColor,
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
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1)
              : null,
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

  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _buildCircle() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textMuted, width: 1.5),
      ),
    );
  }

  String _letter(int index) => String.fromCharCode(65 + index);

  String _answerText(Set<int> answers) {
    if (answers.isEmpty) return '未作答';
    final letters = answers.toList()..sort();
    return letters.map(_letter).join('、');
  }
}

enum OptionState {
  correct,
  wrong,
  unselected,
}
