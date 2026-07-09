import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../core/app_scaffold.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// P07 收藏练习页
class P07FavoritePracticePage extends StatefulWidget {
  const P07FavoritePracticePage({super.key});

  @override
  State<P07FavoritePracticePage> createState() =>
      _P07FavoritePracticePageState();
}

class _P07FavoritePracticePageState extends State<P07FavoritePracticePage> {
  int _selectedFilter = 0;
  final _filters = ['全部', '单选', '多选', '判断', '填空', '简答', '材料'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mockStore,
        builder: (context, _) {
          final questions = _filteredQuestions();
          final totalCount = mockStore.favoriteQuestions.length;
          final canStart = totalCount > 0;
          return SizedBox(
            width: 390,
            height: 844,
            child: Stack(
              children: [
                Column(
                  children: [
                    const StatusBar(),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 16,
                            top: 12,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.chevron_left,
                                  size: 24, color: AppColors.textPrimary),
                            ),
                          ),
                          const Text('收藏练习',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: List.generate(
                          _filters.length,
                          (i) => Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = i),
                              child: Container(
                                height: 26,
                                margin: const EdgeInsets.only(right: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: i == _selectedFilter
                                      ? AppColors.primary
                                      : AppColors.card,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                      color: i == _selectedFilter
                                          ? AppColors.primary
                                          : AppColors.border),
                                ),
                                child: Text(_filters[i],
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: i == _selectedFilter
                                            ? Colors.white
                                            : AppColors.textSecondary)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: questions.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 16, bottom: 110),
                              itemCount: questions.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, i) =>
                                  _buildFavCard(questions[i]),
                            ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 92,
                    color: AppColors.surface,
                    padding:
                        const EdgeInsets.only(top: 12, left: 20, right: 20),
                    child: GestureDetector(
                      onTap: canStart
                          ? () {
                              mockStore.startFavoritePractice(
                                  count: totalCount);
                              context.go('/practice/quiz');
                            }
                          : null,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: canStart
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.primaryDark
                                  ],
                                )
                              : null,
                          color: canStart ? null : AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('开始收藏练习（$totalCount题）',
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavCard(Question question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_typeShortLabel(question.type),
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.primary)),
              ),
              const Icon(Icons.star, size: 16, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 8),
          Text(question.stem,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 64, color: AppColors.warning),
            SizedBox(height: 14),
            Text('暂无收藏题目',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('在刷题页点击收藏后，可从这里集中练习。',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  List<Question> _filteredQuestions() {
    final questions = mockStore.favoriteQuestions;
    if (_selectedFilter == 0) return questions;
    final filter = _filters[_selectedFilter];
    return questions
        .where((question) => _typeShortLabel(question.type) == filter)
        .toList();
  }

  String _typeShortLabel(QuestionType type) {
    return switch (type) {
      QuestionType.single => '单选',
      QuestionType.multiple => '多选',
      QuestionType.trueFalse => '判断',
      QuestionType.fillBlank => '填空',
      QuestionType.shortAnswer => '简答',
    };
  }
}
