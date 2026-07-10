import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scaffold.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../common/material_question_context.dart';
import '../common/question_media_image.dart';

enum _AnalysisKind { unanswered, wrong, correct }

class P28AAnalysisUnansweredPage extends StatelessWidget {
  const P28AAnalysisUnansweredPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _AnalysisDetailPage(kind: _AnalysisKind.unanswered);
}

class P28BAnalysisWrongPage extends StatelessWidget {
  const P28BAnalysisWrongPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _AnalysisDetailPage(kind: _AnalysisKind.wrong);
}

class P28CAnalysisCorrectPage extends StatelessWidget {
  const P28CAnalysisCorrectPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _AnalysisDetailPage(kind: _AnalysisKind.correct);
}

class _AnalysisDetailPage extends StatelessWidget {
  final _AnalysisKind kind;

  const _AnalysisDetailPage({required this.kind});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mockStore,
        builder: (context, _) {
          final session = mockStore.examSession;
          if (session == null) {
            return Container(
              color: AppColors.surface,
              width: 390,
              child: Column(
                children: [
                  const StatusBar(),
                  const NavBar(title: '查看解析'),
                  Expanded(
                    child: AppRouteEmptyState(
                      icon: Icons.analytics_outlined,
                      title: '暂无考试解析',
                      message: '交卷后会生成考试成绩与解析，可返回考试入口开始考试。',
                      actionLabel: '返回考试入口',
                      onAction: () => context.go('/exam'),
                    ),
                  ),
                ],
              ),
            );
          }
          final targetIndex = _targetIndex(session);
          if (targetIndex == null) {
            return _emptyState(context, session);
          }
          final question = session.questions[targetIndex];
          final status = _status(question, session);
          final materialIndexes = _materialGroupIndexes(session, question);
          return Container(
            color: AppColors.surface,
            width: 390,
            child: Column(
              children: [
                const StatusBar(),
                NavBar(title: session.title),
                _buildProgress(session, targetIndex, status),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (materialIndexes.isNotEmpty) ...[
                          MaterialQuestionContext(
                            question: question,
                            groupQuestions: materialIndexes
                                .map((index) => session.questions[index])
                                .toList(),
                            groupIndexes: materialIndexes,
                            currentIndex: targetIndex,
                            collapsed: false,
                            onSelectQuestion: mockStore.jumpExamQuestion,
                            onReportImageFailure: (url) => _reportImageFailure(
                              question,
                              url,
                              '公共材料',
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
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
                              child: QuestionMediaImage(
                                url: url,
                                onReportFailure: () => _reportImageFailure(
                                  question,
                                  url,
                                  '题干',
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (question.options.isEmpty)
                          _textAnswerBlock(question, session)
                        else
                          ...List.generate(
                            question.options.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _option(question, session, index),
                            ),
                          ),
                        const SizedBox(height: 14),
                        _analysisCard(question, session, status),
                      ],
                    ),
                  ),
                ),
                _bottomBar(session, targetIndex),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context, ExamSession session) {
    return Container(
      color: AppColors.surface,
      width: 390,
      child: Column(
        children: [
          const StatusBar(),
          NavBar(title: session.title),
          Expanded(
            child: Center(
              child: AppRouteEmptyState(
                icon: Icons.fact_check_outlined,
                title: '当前分类暂无题目',
                message: '可返回解析总览查看其它分类。',
                actionLabel: '返回解析总览',
                onAction: () => context.go('/exam/analysis'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(
    ExamSession session,
    int index,
    _QuestionStatus status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '第 ${index + 1} / ${session.questions.length} 题',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _pill(status.label, status.color, status.bgColor),
              const SizedBox(width: 6),
              _pill(session.questions[index].type.label, AppColors.primary,
                  AppColors.primaryBg),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (index + 1) / session.questions.length,
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

  Widget _pill(String text, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _option(Question question, ExamSession session, int index) {
    final selected = session.answers[question.id]?.contains(index) ?? false;
    final correct = question.answerIndexes.contains(index);
    final wrong = selected && !correct;
    final bgColor = correct
        ? const Color(0xFFD1FAE5)
        : wrong
            ? const Color(0xFFFEE2E2)
            : AppColors.card;
    final strokeColor = correct
        ? AppColors.success
        : wrong
            ? AppColors.error
            : AppColors.border;
    final color = correct
        ? AppColors.success
        : wrong
            ? AppColors.error
            : AppColors.textSecondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: strokeColor, width: 1),
      ),
      child: Row(
        children: [
          Text(
            _letter(index),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question.options[index],
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight:
                    correct || wrong ? FontWeight.w600 : FontWeight.w400,
                color: correct || wrong ? color : AppColors.textPrimary,
              ),
            ),
          ),
          if (correct)
            const Icon(Icons.check, size: 18, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _textAnswerBlock(Question question, ExamSession session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _myAnswer(question, session),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _analysisCard(
    Question question,
    ExamSession session,
    _QuestionStatus status,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.resultLabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
          const SizedBox(height: 10),
          _answerLine('正确答案', _correctAnswer(question), AppColors.success),
          const SizedBox(height: 6),
          _answerLine('我的答案', _myAnswer(question, session), status.color),
          const SizedBox(height: 10),
          Text(
            _cleanDisplayText(question.analysis.isEmpty
                ? '暂无解析，后续可在中台补充。'
                : question.analysis),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          if (question.analysisImageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...question.analysisImageUrls.map(
              (url) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: QuestionMediaImage(
                  url: url,
                  onReportFailure: () =>
                      _reportImageFailure(question, url, '解析'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerLine(String label, String value, Color color) {
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

  Widget _bottomBar(ExamSession session, int index) {
    final indexes = _matchingIndexes(session);
    final position = indexes.indexOf(index);
    final previousIndex = position > 0 ? indexes[position - 1] : null;
    final nextIndex = position >= 0 && position < indexes.length - 1
        ? indexes[position + 1]
        : null;
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
            '上一题',
            enabled: previousIndex != null,
            onTap: previousIndex == null
                ? null
                : () => mockStore.jumpExamQuestion(previousIndex),
          ),
          _bottomButton(
            '下一题',
            primary: true,
            enabled: nextIndex != null,
            onTap: nextIndex == null
                ? null
                : () => mockStore.jumpExamQuestion(nextIndex),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton(
    String text, {
    required bool enabled,
    bool primary = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primary && enabled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              primary ? null : Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: primary ? FontWeight.w600 : FontWeight.w400,
            color: enabled
                ? (primary ? Colors.white : AppColors.textSecondary)
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  int? _targetIndex(ExamSession session) {
    final current = session.currentIndex;
    if (_matches(session, current)) return current;
    final indexes = _matchingIndexes(session);
    return indexes.isEmpty ? null : indexes.first;
  }

  List<int> _matchingIndexes(ExamSession session) {
    return List.generate(session.questions.length, (index) => index)
        .where((index) => _matches(session, index))
        .toList();
  }

  bool _matches(ExamSession session, int index) {
    final question = session.questions[index];
    return switch (kind) {
      _AnalysisKind.unanswered => !session.hasAnswered(question.id),
      _AnalysisKind.wrong => session.isWrong(question),
      _AnalysisKind.correct => session.isCorrect(question),
    };
  }

  _QuestionStatus _status(Question question, ExamSession session) {
    if (!session.hasAnswered(question.id)) {
      return const _QuestionStatus(
        label: '未作答',
        resultLabel: '未作答',
        color: AppColors.textSecondary,
        bgColor: Color(0xFFF1F5F9),
      );
    }
    if (session.isCorrect(question)) {
      final scoreText = _textScoreText(question, session);
      return _QuestionStatus(
        label: '已答对',
        resultLabel: scoreText == null ? '回答正确' : '回答正确 · $scoreText',
        color: AppColors.success,
        bgColor: const Color(0xFFD1FAE5),
      );
    }
    if (!session.isWrong(question)) {
      return const _QuestionStatus(
        label: '待核查',
        resultLabel: '已作答 · 待核查',
        color: AppColors.primary,
        bgColor: AppColors.primaryBg,
      );
    }
    final scoreText = _textScoreText(question, session);
    return const _QuestionStatus(
      label: '答错题',
      resultLabel: '回答错误',
      color: AppColors.error,
      bgColor: Color(0xFFFEE2E2),
    ).copyWith(resultLabel: scoreText == null ? null : '回答错误 · $scoreText');
  }

  String? _textScoreText(Question question, ExamSession session) {
    final remoteScore = session.answerResults[question.id]?.scoreText;
    if (remoteScore != null && remoteScore.isNotEmpty) return remoteScore;
    final text = session.textAnswers[question.id]?.trim();
    if (text == null || text.isEmpty) return null;
    return evaluateTextAnswer(question, text).scoreText;
  }

  Future<bool> _reportImageFailure(
    Question question,
    String url,
    String location,
  ) {
    return mockStore.submitFeedback(
      type: 'image_error',
      content: '本题图片未能加载',
      payload: {
        'source': 'exam_analysis_image',
        'questionId': question.id,
        'location': location,
        'url': url,
        'label': '图片问题',
      },
    );
  }

  List<int> _materialGroupIndexes(
    ExamSession session,
    Question question,
  ) {
    final groupId = question.materialGroupId;
    if (groupId == null || groupId.isEmpty) return const [];
    return [
      for (var index = 0; index < session.questions.length; index++)
        if (session.questions[index].materialGroupId == groupId &&
            _matches(session, index))
          index,
    ];
  }

  String _correctAnswer(Question question) {
    if (question.answerText.trim().isNotEmpty) return question.answerText;
    return _answerText(question.answerIndexes);
  }

  String _myAnswer(Question question, ExamSession session) {
    final text = session.textAnswers[question.id]?.trim();
    if (text != null && text.isNotEmpty) return text;
    return _answerText(session.answers[question.id] ?? const {});
  }

  String _answerText(Set<int> answers) {
    if (answers.isEmpty) return '未作答';
    final sorted = answers.toList()..sort();
    return sorted.map(_letter).join('、');
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
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }
}

class _QuestionStatus {
  final String label;
  final String resultLabel;
  final Color color;
  final Color bgColor;

  const _QuestionStatus({
    required this.label,
    required this.resultLabel,
    required this.color,
    required this.bgColor,
  });

  _QuestionStatus copyWith({String? resultLabel}) {
    return _QuestionStatus(
      label: label,
      resultLabel: resultLabel ?? this.resultLabel,
      color: color,
      bgColor: bgColor,
    );
  }
}
