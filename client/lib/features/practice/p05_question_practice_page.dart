import 'dart:async';

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
  final _textControllers = <String, TextEditingController>{};

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
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
          final result = session.answerResults[question.id];
          final textAnswer = session.textAnswers[question.id] ?? '';
          final submitting =
              session.submittingQuestionIds.contains(question.id);
          final answered = session.hasAnswered(question.id);
          final isLast = session.currentIndex == session.questions.length - 1;
          final isFavorite = mockStore.isQuestionFavorite(question.id);

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
                      _buildQuestionStem(question),
                      const SizedBox(height: 16),
                      _buildAnswerArea(
                        question: question,
                        selected: selected,
                        textAnswer: textAnswer,
                        submitting: submitting,
                        answered: answered,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (session.mode == '错题练习') ...[
                            _buildActionChip(
                              icon: Icons.remove_circle_outline,
                              text: '移出错题',
                              danger: true,
                              onTap: () => _removeWrongQuestion(question),
                            ),
                            const SizedBox(width: 12),
                          ],
                          _buildActionChip(
                            icon: isFavorite ? Icons.star : Icons.star_border,
                            text: isFavorite ? '已收藏' : '收藏',
                            selected: isFavorite,
                            onTap: () =>
                                unawaited(mockStore.toggleFavorite(question)),
                          ),
                          const SizedBox(width: 16),
                          _buildActionChip(
                            icon: Icons.report_problem_outlined,
                            text: '纠错',
                            onTap: () => _showQuestionFeedbackSheet(question),
                          ),
                        ],
                      ),
                      if (answered) ...[
                        const SizedBox(height: 16),
                        _buildAnalysis(
                          question: question,
                          selected: selected,
                          textAnswer: textAnswer,
                          result: result,
                          submitting: submitting,
                        ),
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

  Widget _buildQuestionStem(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _cleanDisplayText(question.stem),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            height: 1.6,
            color: AppColors.textPrimary,
          ),
        ),
        if (question.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...question.imageUrls.map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildQuestionImage(url),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionImage(String url) {
    final canLoad = url.startsWith('http://') || url.startsWith('https://');
    if (!canLoad) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.image_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '图片：$url',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildQuestionImageFallback(url),
      ),
    );
  }

  Widget _buildQuestionImageFallback(String url) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '图片加载失败：$url',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildAnswerArea({
    required Question question,
    required Set<int>? selected,
    required String textAnswer,
    required bool submitting,
    required bool answered,
  }) {
    if (question.type == QuestionType.fillBlank ||
        question.type == QuestionType.shortAnswer ||
        question.type == QuestionType.material) {
      return _buildTextAnswerArea(
        question: question,
        textAnswer: textAnswer,
        submitting: submitting,
        answered: answered,
      );
    }
    if (question.options.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: List.generate(question.options.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildOption(
            label: '${_letter(index)}.',
            text: question.options[index],
            state: _optionState(question, selected, index),
            onTap: answered || submitting
                ? null
                : () => _answerQuestion(question, selected, index),
          ),
        );
      }),
    );
  }

  Widget _buildTextAnswerArea({
    required Question question,
    required String textAnswer,
    required bool submitting,
    required bool answered,
  }) {
    final controller = _textControllerFor(question.id, textAnswer);
    final isLongText = question.type == QuestionType.shortAnswer ||
        question.type == QuestionType.material;
    final canSubmit = !submitting && !answered;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: canSubmit,
            minLines: isLongText ? 5 : 1,
            maxLines: isLongText ? 8 : 2,
            textInputAction:
                isLongText ? TextInputAction.newline : TextInputAction.done,
            decoration: InputDecoration(
              hintText: question.type == QuestionType.material
                  ? '阅读材料后输入你的作答'
                  : isLongText
                      ? '请输入你的简答题答案'
                      : '请输入答案',
              border: InputBorder.none,
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: canSubmit
                  ? () => mockStore.answerPracticeText(controller.text)
                  : null,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: canSubmit ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  submitting
                      ? '提交中'
                      : answered
                          ? '已提交'
                          : '提交答案',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
    VoidCallback? onTap,
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

  Widget _buildAnalysis({
    required Question question,
    required Set<int>? selected,
    required String textAnswer,
    required PracticeAnswerResult? result,
    required bool submitting,
  }) {
    final correct =
        result?.isCorrect ?? sameAnswer(selected, question.answerIndexes);
    final title = submitting
        ? '正在判分'
        : result?.isCorrect == null
            ? '已提交'
            : correct
                ? '回答正确'
                : '回答错误';
    final correctAnswer = result?.correctAnswerText.isNotEmpty == true
        ? result!.correctAnswerText
        : question.answerText;
    final myAnswer = result?.myAnswerText.isNotEmpty == true
        ? result!.myAnswerText
        : (textAnswer.isNotEmpty
            ? textAnswer
            : _answerText(selected ?? const {}));
    final analysis = result?.analysisText.isNotEmpty == true
        ? result!.analysisText
        : question.analysis;
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
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: submitting || result?.isCorrect == null
                      ? AppColors.primary
                      : correct
                          ? AppColors.success
                          : AppColors.error,
                ),
              ),
              if (result?.scoreText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: correct ? AppColors.successBg : AppColors.errorBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    result!.scoreText!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: correct ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _buildAnswerLine(
            '正确答案',
            correctAnswer.isEmpty
                ? _answerText(question.answerIndexes)
                : correctAnswer,
            AppColors.success,
          ),
          const SizedBox(height: 6),
          _buildAnswerLine(
            '我的答案',
            myAnswer,
            correct ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            '解析结果：${_cleanDisplayText(analysis)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          if (result?.matchedPoints.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              '命中要点：${result!.matchedPoints.join('、')}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.5,
                color: AppColors.success,
              ),
            ),
          ],
          if (result?.reviewReason?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              result!.reviewReason!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerLine(String label, String value, Color color) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          height: 1.5,
          color: color,
        ),
        children: [
          TextSpan(
            text: '$label：',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value.isEmpty ? '未作答' : _cleanDisplayText(value)),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String text,
    bool selected = false,
    bool danger = false,
    VoidCallback? onTap,
  }) {
    final color = danger
        ? AppColors.error
        : selected
            ? AppColors.primary
            : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBg : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: danger
                  ? AppColors.error
                  : selected
                      ? AppColors.primary
                      : AppColors.border,
              width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
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
            onTap: () => _showAnswerCard(context, session),
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

  Future<void> _removeWrongQuestion(Question question) async {
    final ok = await mockStore.removeWrongQuestion(question);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '已移出错题本' : '移出失败，请稍后重试')),
    );
    if (mockStore.practiceSession == null && mounted) {
      context.go('/practice/wrong');
    }
  }

  void _showQuestionFeedbackSheet(Question question) {
    final controller = TextEditingController();
    final labels = ['题目有误', '答案有误', '解析有误', '图片问题', '其他'];
    final values = [
      'stem_error',
      'answer_error',
      'analysis_error',
      'image_error',
      'other',
    ];
    var selectedIndex = 0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '题目纠错',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(labels.length, (index) {
                          final selected = index == selectedIndex;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryBg
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: controller,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: '补充说明具体问题，方便中台核查',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final content = controller.text.trim().isEmpty
                                ? labels[selectedIndex]
                                : controller.text.trim();
                            final ok = await mockStore.submitQuestionFeedback(
                              question,
                              content: content,
                              type: values[selectedIndex],
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? '纠错已提交' : '提交失败，请稍后重试'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('提交纠错'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showAnswerCard(BuildContext context, PracticeSession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return AnimatedBuilder(
          animation: mockStore,
          builder: (context, _) {
            final currentSession = mockStore.practiceSession ?? session;
            final unanswered =
                currentSession.questions.length - currentSession.answeredCount;
            return FractionallySizedBox(
              heightFactor: 0.78,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '答题卡',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${currentSession.answeredCount}/${currentSession.questions.length} 已答',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _answerCardStat(
                            color: AppColors.primary,
                            label: '已答 ${currentSession.answeredCount}',
                          ),
                          const SizedBox(width: 22),
                          _answerCardStat(
                            color: AppColors.textMuted,
                            label: '未答 $unanswered',
                            outlined: true,
                          ),
                          const SizedBox(width: 22),
                          _answerCardStat(
                            color: AppColors.success,
                            label: '当前 ${currentSession.currentIndex + 1}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: currentSession.questions.length,
                        itemBuilder: (context, index) {
                          final question = currentSession.questions[index];
                          return _answerCardCell(
                            index: index,
                            answered: currentSession.hasAnswered(question.id),
                            current: index == currentSession.currentIndex,
                            onTap: () {
                              mockStore.jumpPracticeQuestion(index);
                              Navigator.of(bottomSheetContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(bottomSheetContext).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              backgroundColor: AppColors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: const Text(
                              '返回答题',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _answerCardStat({
    required Color color,
    required String label,
    bool outlined = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(99),
            border: outlined ? Border.all(color: color, width: 1.2) : null,
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

  Widget _answerCardCell({
    required int index,
    required bool answered,
    required bool current,
    required VoidCallback onTap,
  }) {
    final bgColor = current
        ? AppColors.successBg
        : answered
            ? AppColors.primary
            : AppColors.card;
    final borderColor = current
        ? AppColors.success
        : answered
            ? AppColors.primary
            : AppColors.border;
    final textColor = current
        ? AppColors.success
        : answered
            ? Colors.white
            : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: current ? 1.5 : 1),
        ),
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
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

  TextEditingController _textControllerFor(String questionId, String value) {
    final controller = _textControllers.putIfAbsent(
      questionId,
      () => TextEditingController(text: value),
    );
    if (value.isNotEmpty && controller.text.isEmpty) {
      controller.text = value;
    }
    return controller;
  }

  String _cleanDisplayText(String value) {
    return value
        .replaceAll(RegExp(r'<img\b[^>]*>', caseSensitive: false), ' [图片] ')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll(r'$', '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }
}

enum OptionState {
  correct,
  wrong,
  unselected,
}
