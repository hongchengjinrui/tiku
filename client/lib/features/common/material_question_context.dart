import 'package:flutter/material.dart';

import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import 'question_media_image.dart';

class MaterialQuestionContext extends StatelessWidget {
  final Question question;
  final List<Question> groupQuestions;
  final List<int> groupIndexes;
  final int currentIndex;
  final bool collapsed;
  final VoidCallback? onToggle;
  final ValueChanged<int> onSelectQuestion;
  final Future<bool> Function(String url) onReportImageFailure;

  const MaterialQuestionContext({
    super.key,
    required this.question,
    required this.groupQuestions,
    required this.groupIndexes,
    required this.currentIndex,
    required this.collapsed,
    this.onToggle,
    required this.onSelectQuestion,
    required this.onReportImageFailure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '公共材料题干',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (onToggle != null)
                TextButton(
                  onPressed: onToggle,
                  child: Text(collapsed ? '展开材料' : '收起材料'),
                ),
            ],
          ),
          if (!collapsed) ...[
            if (question.materialStem.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                _cleanDisplayText(question.materialStem),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.65,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (question.materialImageUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...question.materialImageUrls.map(
                (url) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QuestionMediaImage(
                    url: url,
                    onReportFailure: () => onReportImageFailure(url),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(groupQuestions.length, (index) {
              final selected = groupIndexes[index] == currentIndex;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelectQuestion(groupIndexes[index]),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '子题${index + 1} ${groupQuestions[index].type.label}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _cleanDisplayText(String value) {
    return value
        .replaceAll(RegExp(r'<img\b[^>]*>', caseSensitive: false), '')
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
