import 'package:flutter/material.dart';
import '../../core/app_scaffold.dart';
import '../../theme/app_colors.dart';

/// P28A 考试解析详情-未作答 - Exam analysis detail: unanswered
class P28AAnalysisUnansweredPage extends StatelessWidget {
  const P28AAnalysisUnansweredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnalysisDetailBase(
      title: '模拟考试一',
      questionNum: 5,
      totalQuestions: 100,
      progress: 5 / 100,
      statusText: '未作答',
      statusColor: AppColors.textSecondary,
      statusBg: const Color(0xFFF1F5F9),
      questionText: '电气设备火灾时，应首先采取的措施是？',
      options: const [
        _OptionData(label: 'A', text: '直接用水灭火', state: _OptionState.normal),
        _OptionData(label: 'B', text: '立即切断电源', state: _OptionState.correct),
        _OptionData(label: 'C', text: '立即撤离不处理', state: _OptionState.normal),
        _OptionData(label: 'D', text: '等待设备自动断电', state: _OptionState.normal),
      ],
      resultLabel: '未作答',
      resultColor: AppColors.textSecondary,
      correctAnswer: 'B',
      userAnswer: '未作答',
      userAnswerColor: AppColors.textMuted,
      analysisText: '电气设备火灾首先应切断电源，避免带电灭火导致触电或扩大事故，再使用适用灭火器材处理。',
    );
  }
}

/// P28B 考试解析详情-答错题 - Exam analysis detail: wrong answer
class P28BAnalysisWrongPage extends StatelessWidget {
  const P28BAnalysisWrongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnalysisDetailBase(
      title: '模拟考试一',
      questionNum: 1,
      totalQuestions: 100,
      progress: 1 / 100,
      statusText: '答错题',
      statusColor: AppColors.error,
      statusBg: const Color(0xFFFEE2E2),
      questionText: '电气设备火灾时，应首先采取的措施是？',
      options: const [
        _OptionData(label: 'A', text: '直接用水灭火', state: _OptionState.wrong),
        _OptionData(label: 'B', text: '立即切断电源', state: _OptionState.correct),
        _OptionData(label: 'C', text: '立即撤离不处理', state: _OptionState.normal),
        _OptionData(label: 'D', text: '等待设备自动断电', state: _OptionState.normal),
      ],
      resultLabel: '回答错误',
      resultColor: AppColors.error,
      correctAnswer: 'B',
      userAnswer: 'A',
      userAnswerColor: AppColors.error,
      analysisText: '电气设备火灾首先应切断电源，避免带电灭火导致触电或扩大事故，再使用适用灭火器材处理。',
    );
  }
}

/// P28C 考试解析详情-已答对 - Exam analysis detail: correct answer
class P28CAnalysisCorrectPage extends StatelessWidget {
  const P28CAnalysisCorrectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _AnalysisDetailBase(
      title: '模拟考试一',
      questionNum: 2,
      totalQuestions: 100,
      progress: 2 / 100,
      statusText: '已答对',
      statusColor: AppColors.success,
      statusBg: const Color(0xFFD1FAE5),
      questionText: '以下哪种灭火器适用于电气火灾？',
      options: const [
        _OptionData(label: 'A', text: '清水灭火器', state: _OptionState.normal),
        _OptionData(label: 'B', text: '二氧化碳灭火器', state: _OptionState.correct),
        _OptionData(label: 'C', text: '泡沫灭火器', state: _OptionState.normal),
        _OptionData(label: 'D', text: '酸碱灭火器', state: _OptionState.normal),
      ],
      resultLabel: '回答正确',
      resultColor: AppColors.success,
      correctAnswer: 'B',
      userAnswer: 'B',
      userAnswerColor: AppColors.success,
      analysisText: '二氧化碳灭火器适用于电气火灾，可避免导电风险；使用前仍应优先确认现场断电条件。',
    );
  }
}

enum _OptionState { normal, correct, wrong }

class _OptionData {
  final String label;
  final String text;
  final _OptionState state;
  const _OptionData(
      {required this.label, required this.text, required this.state});
}

class _AnalysisDetailBase extends StatelessWidget {
  final String title;
  final int questionNum;
  final int totalQuestions;
  final double progress;
  final String statusText;
  final Color statusColor;
  final Color statusBg;
  final String questionText;
  final List<_OptionData> options;
  final String resultLabel;
  final Color resultColor;
  final String correctAnswer;
  final String userAnswer;
  final Color userAnswerColor;
  final String analysisText;

  const _AnalysisDetailBase({
    required this.title,
    required this.questionNum,
    required this.totalQuestions,
    required this.progress,
    required this.statusText,
    required this.statusColor,
    required this.statusBg,
    required this.questionText,
    required this.options,
    required this.resultLabel,
    required this.resultColor,
    required this.correctAnswer,
    required this.userAnswer,
    required this.userAnswerColor,
    required this.analysisText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            _buildStatusBar(),
            _buildNavBar(),
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(questionText,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 14),
                    ...options.map((o) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildOption(o),
                        )),
                    const SizedBox(height: 14),
                    _buildAnalysisCard(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return const StatusBar();
  }

  Widget _buildNavBar() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 12,
            child: const Icon(Icons.chevron_left,
                size: 24, color: AppColors.textPrimary),
          ),
          Center(
            child: Text(title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text('第 $questionNum / $totalQuestions 题',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    )),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('单选题',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
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

  Widget _buildOption(_OptionData opt) {
    Color bgColor = AppColors.card;
    Color strokeColor = AppColors.border;
    Color labelColor = AppColors.textSecondary;
    Color textColor = AppColors.textPrimary;
    Widget? trailing;

    if (opt.state == _OptionState.correct) {
      bgColor = const Color(0xFFD1FAE5);
      strokeColor = AppColors.success;
      labelColor = AppColors.success;
      textColor = const Color(0xFF065F46);
      trailing = const Icon(Icons.check, size: 18, color: AppColors.success);
    } else if (opt.state == _OptionState.wrong) {
      bgColor = const Color(0xFFFEE2E2);
      strokeColor = AppColors.error;
      labelColor = AppColors.error;
      textColor = const Color(0xFF991B1B);
    }

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
          Text(opt.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: labelColor,
              )),
          const SizedBox(width: 12),
          Expanded(
            child: Text(opt.text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: opt.state != _OptionState.normal
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: textColor,
                )),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildAnalysisCard() {
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
          Text(resultLabel,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: resultColor,
              )),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('正确答案：$correctAnswer',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.success,
                  )),
              const SizedBox(width: 16),
              Text('你的答案：$userAnswer',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: userAnswerColor,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Text(analysisText,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              )),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Text('上一题',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  )),
            ),
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('下一题',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
