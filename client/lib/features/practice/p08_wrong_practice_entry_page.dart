import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';

/// P08 错题练习入口页
class P08WrongPracticeEntryPage extends StatefulWidget {
  const P08WrongPracticeEntryPage({super.key});

  @override
  State<P08WrongPracticeEntryPage> createState() =>
      _P08WrongPracticeEntryPageState();
}

class _P08WrongPracticeEntryPageState extends State<P08WrongPracticeEntryPage> {
  int _selectedFilter = 0;
  final _filters = ['全部', '近7日', '多次错误', '未掌握'];
  final _questionTypes = ['单选', '多选', '判断', '填空', '简答', '材料'];
  final _selectedTypes = <int>{};
  int _removeRule = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: mockStore,
        builder: (context, _) {
          return SizedBox(
            width: 390,
            child: Column(
              children: [
                const StatusBar(),
                const NavBar(title: '错题练习'),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _buildRangeCard(_filteredWrongQuestions()),
                        const SizedBox(height: 14),
                        const Text('条件筛选',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildFilterChips(),
                        const SizedBox(height: 14),
                        const Text('题型筛选',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildQuestionTypeChips(),
                        const SizedBox(height: 14),
                        _buildRemoveRuleSection(),
                        const SizedBox(height: 14),
                        _buildEmptyHint(_filteredWrongQuestions()),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(_filteredWrongQuestions()),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 错题练习范围卡 - 渐变面板
  Widget _buildRangeCard(List<Question> filteredQuestions) {
    final todayAdded = mockStore.wrongQuestions.where((question) {
      final lastWrongAt = question.lastWrongAt;
      if (lastWrongAt == null) return false;
      final now = DateTime.now();
      return lastWrongAt.year == now.year &&
          lastWrongAt.month == now.month &&
          lastWrongAt.day == now.day;
    }).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error_outline,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text('错题范围：全部章节',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('错题总数 ${mockStore.wrongPracticeCount}题',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('今日新增 $todayAdded题',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textBlueHint)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text('当前筛选 ${filteredQuestions.length}题',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textBlueHint)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 6,
        children: List.generate(_filters.length, (i) {
          final selected = i == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Text(_filters[i],
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: selected ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionTypeChips() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 4,
        children: List.generate(_questionTypes.length, (i) {
          final selected = _selectedTypes.contains(i);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedTypes.remove(i);
                } else {
                  _selectedTypes.add(i);
                }
              });
            },
            child: Container(
              width: (390 - 40 - 5 * 4) / 6,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBg : AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Text(_questionTypes[i],
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRemoveRuleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('错题练习设置',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 4),
            const Text('（做对 N 次后移出错题本）',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
              const Text('选择移出规则，默认使用做对 2 次移除。',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textMuted)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [1, 2, 3, 5].map((n) {
                  final selected = n == _removeRule;
                  return GestureDetector(
                    onTap: () => setState(() => _removeRule = n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Text('做对$n次',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyHint(List<Question> filteredQuestions) {
    final hasWrongQuestions = mockStore.wrongPracticeCount > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                hasWrongQuestions
                    ? filteredQuestions.isEmpty
                        ? '当前筛选条件下暂无错题，可调整条件或题型后再开始练习。'
                        : '做对题目达到设定次数后，将自动从错题练习中移出。'
                    : '暂无错题。完成练习并出现答错题目后，可从这里进入错题练习。',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(List<Question> filteredQuestions) {
    final canStart = filteredQuestions.isNotEmpty;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // 清空错题入口
          GestureDetector(
            onTap: canStart
                ? () => _showClearWrongDialog(filteredQuestions)
                : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: canStart ? AppColors.primaryBg : AppColors.border,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: canStart ? AppColors.primary : AppColors.border),
              ),
              child: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          // 开始按钮
          Expanded(
            child: GestureDetector(
              onTap: canStart
                  ? () {
                      mockStore.startWrongPractice(
                        count: filteredQuestions.length,
                        questions: filteredQuestions,
                      );
                      context.go('/practice/quiz');
                    }
                  : null,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: canStart ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('开始错题练习（${filteredQuestions.length}题）',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward,
                        size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Question> _filteredWrongQuestions() {
    final now = DateTime.now();
    return mockStore.wrongQuestions.where((question) {
      final filterMatched = switch (_filters[_selectedFilter]) {
        '近7日' => question.lastWrongAt != null &&
            now.difference(question.lastWrongAt!).inDays <= 7,
        '多次错误' => question.wrongCount >= 2,
        '未掌握' => question.wrongCount > 0,
        _ => true,
      };
      final typeMatched = _selectedTypes.isEmpty ||
          _selectedTypes.any(
            (index) => _typeShortLabel(question.type) == _questionTypes[index],
          );
      return filterMatched && typeMatched;
    }).toList();
  }

  String _typeShortLabel(QuestionType type) {
    return switch (type) {
      QuestionType.single => '单选',
      QuestionType.multiple => '多选',
      QuestionType.trueFalse => '判断',
      QuestionType.fillBlank => '填空',
      QuestionType.shortAnswer => '简答',
      QuestionType.material => '材料',
    };
  }

  Future<void> _showClearWrongDialog(List<Question> questions) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => P08AClearWrongDialog(
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await mockStore.clearWrongQuestions(questions: questions);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '已移出当前筛选错题' : '移出失败，请稍后重试')),
    );
  }
}

/// P08A 清空错题确认弹窗
class P08AClearWrongDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const P08AClearWrongDialog({super.key, this.onConfirm, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x990F172A),
      child: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.delete_outline,
                    size: 24, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              const Text('确认清空错题？',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              const Text('该操作将清除当前范围下的所有错题，清空后不可直接恢复，是否确认清空？',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onCancel ?? () => Navigator.of(context).pop(),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text('取消',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: AppColors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('确认清空',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
