import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import 'p27_submit_exam_confirmation_modal.dart';
import 'p27a_submit_all_answered_modal.dart';

/// P25 考试答题页 - Exam answering page
class P25ExamAnsweringPage extends StatefulWidget {
  const P25ExamAnsweringPage({super.key});

  @override
  State<P25ExamAnsweringPage> createState() => _P25ExamAnsweringPageState();
}

class _P25ExamAnsweringPageState extends State<P25ExamAnsweringPage> {
  final _textControllers = <String, TextEditingController>{};
  Timer? _examTimer;

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
    _startExamTimer();
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startExamTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = mockStore.examSession;
      if (!mounted || session == null || session.submitted) {
        _examTimer?.cancel();
        return;
      }
      final wasSubmitted = session.submitted;
      mockStore.tickExamSecond();
      final latestSession = mockStore.examSession;
      if (!wasSubmitted && mounted && latestSession?.submitted == true) {
        _examTimer?.cancel();
        GoRouter.of(context).go('/exam/analysis');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mockStore,
        builder: (context, _) {
          final session = mockStore.examSession;
          if (session == null) {
            return AppRouteEmptyState(
              icon: Icons.description_outlined,
              title: '暂无考试内容',
              message: '当前没有进行中的考试，可返回考试入口重新开始。',
              actionLabel: '返回考试入口',
              onAction: () => context.go('/exam'),
            );
          }
          final question = session.currentQuestion;
          final selected = session.answers[question.id];
          final textAnswer = session.textAnswers[question.id] ?? '';
          final isLast = session.currentIndex == session.questions.length - 1;

          return Container(
            color: AppColors.surface,
            width: 390,
            child: Column(
              children: [
                const StatusBar(),
                _buildNavBar(context, session),
                _buildProgressArea(session, question),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionStem(question),
                        const SizedBox(height: 16),
                        _buildAnswerArea(
                          question: question,
                          selected: selected,
                          textAnswer: textAnswer,
                          submitted: session.submitted,
                        ),
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
            session.submitted
                ? '已交卷'
                : '剩余 ${_formatRemaining(session.remainingSeconds)}',
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

  Widget _buildAnswerArea({
    required Question question,
    required Set<int>? selected,
    required String textAnswer,
    required bool submitted,
  }) {
    if (question.type == QuestionType.fillBlank ||
        question.type == QuestionType.shortAnswer ||
        question.type == QuestionType.material) {
      return _buildTextAnswerArea(
        question: question,
        textAnswer: textAnswer,
        submitted: submitted,
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
            _letter(index),
            question.options[index],
            selected?.contains(index) ?? false,
            submitted ? null : () => _answerQuestion(question, selected, index),
          ),
        );
      }),
    );
  }

  Widget _buildTextAnswerArea({
    required Question question,
    required String textAnswer,
    required bool submitted,
  }) {
    final controller = _textControllerFor(question.id, textAnswer);
    final isLongText = question.type == QuestionType.shortAnswer ||
        question.type == QuestionType.material;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        enabled: !submitted,
        minLines: isLongText ? 6 : 1,
        maxLines: isLongText ? 10 : 3,
        textInputAction:
            isLongText ? TextInputAction.newline : TextInputAction.done,
        onChanged: mockStore.answerExamText,
        decoration: InputDecoration(
          hintText: question.type == QuestionType.material
              ? '阅读材料后输入你的作答'
              : isLongText
                  ? '请输入简答题答案'
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
    );
  }

  Widget _buildOption(
    String label,
    String text,
    bool selected,
    VoidCallback? onTap,
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

  String _formatRemaining(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final restSeconds = safeSeconds % 60;
    return '$minutes:${restSeconds.toString().padLeft(2, '0')}';
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
    if (confirmed != true || !mounted) return;
    unawaited(mockStore.submitExam());
    router.go('/exam/analysis');
  }

  TextEditingController _textControllerFor(String questionId, String value) {
    final controller = _textControllers.putIfAbsent(
      questionId,
      () => TextEditingController(text: value),
    );
    if (value != controller.text) {
      controller.text = value;
      controller.selection = TextSelection.collapsed(offset: value.length);
    }
    return controller;
  }

  String _letter(int index) => String.fromCharCode(65 + index);

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
