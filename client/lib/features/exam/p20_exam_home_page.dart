import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';
import '../../core/widgets.dart';
import '../common/progress_reset_sheet.dart';

/// P20 考试模式首页 - Exam mode home page
class P20ExamHomePage extends StatefulWidget {
  const P20ExamHomePage({super.key});

  @override
  State<P20ExamHomePage> createState() => _P20ExamHomePageState();
}

class _P20ExamHomePageState extends State<P20ExamHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: CacheStatusBanner(store: mockStore),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ExamProgressPanel(store: mockStore),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _ExamEntrySection(),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('考试记录',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  )),
                              GestureDetector(
                                onTap: () =>
                                    context.push('/profile/exam-records'),
                                child: const Text('全部考试记录',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:
                              _HistoryCardList(records: mockStore.examRecords),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const BottomTabBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _ExamProgressPanel extends StatelessWidget {
  final MockAppStore store;

  const _ExamProgressPanel({required this.store});

  @override
  Widget build(BuildContext context) {
    final stat = store.examStat;
    final todayExamCount =
        store.examRecords.where((record) => _isTodayRecord(record.time)).length;
    final activeDays = _activeDayCount(store.examRecords);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(store.selectedSubject.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
              GestureDetector(
                onTap: () => context.push('/practice/switch-subject'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('切换科目',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('今日新增考核：$todayExamCount次      已累计考核：$activeDays天',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textBlueHint,
              )),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _ruleItem('${stat.total}', '题目覆盖')),
              Expanded(child: _ruleItem('${store.examRecords.length}', '考试次数')),
              Expanded(child: _ruleItem('1', '通过次数')),
              Expanded(child: _ruleItem('${stat.accuracy}%', '总正确率')),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stat.progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            )),
      ],
    );
  }

  int _activeDayCount(List<StudyRecord> records) {
    if (records.isEmpty) return 0;
    return records.map((record) => _dayKey(record.time)).toSet().length;
  }

  bool _isTodayRecord(String time) {
    return time == '刚刚' ||
        time.contains('分钟前') ||
        time.contains('小时前') ||
        time.startsWith('今天');
  }

  String _dayKey(String time) {
    if (time == '刚刚' || time.contains('分钟前') || time.contains('小时前')) {
      return '今天';
    }
    return time.split(' ').first;
  }
}

class _ExamEntrySection extends StatelessWidget {
  const _ExamEntrySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('考试入口',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
            GestureDetector(
              onTap: () => _showResetSheet(context),
              child: const Text('重置',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.primary,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _entryCard(
              Icons.book_outlined,
              AppColors.primary,
              '章节考试',
              () => context.push('/exam/catalog'),
            ),
            const SizedBox(width: 10),
            _entryCard(
              Icons.edit_note,
              AppColors.primaryDark,
              '模拟考试',
              () => context.push('/exam/assemble'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _entryCard(
              Icons.description_outlined,
              AppColors.primary,
              '真题考试',
              () => context.push('/exam/papers'),
            ),
            const SizedBox(width: 10),
            _entryCard(
              Icons.assignment,
              AppColors.primaryDark,
              '组卷考试',
              () => context.push('/exam/assemble'),
            ),
          ],
        ),
      ],
    );
  }

  void _showResetSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProgressResetSheet(
        title: '重置进度',
        description: '选择需要重置的考试目录，重置后将清空对应目录的考试记录。',
        allDescription: '章节考试与模拟考试全部重置',
        confirmMessage: '将清空已选目录的考试记录、正确率与错题统计，此操作不可撤销。',
        groups: [
          ResetCatalogGroup(
            title: '章节考试（共${mockStore.examChapters.length}章）',
            subtitle:
                '${mockStore.examChapterStat.done}/${mockStore.examChapterStat.total}',
            entries: mockStore.examChapters
                .map(
                  (chapter) => ResetCatalogEntry(
                    id: chapter.id,
                    title: chapter.title,
                    progress: '${chapter.done}/${chapter.total}',
                  ),
                )
                .toList(),
          ),
          ResetCatalogGroup(
            title: '模拟考试（共${mockStore.examPapers.length}套）',
            subtitle:
                '${mockStore.examPaperStat.done}/${mockStore.examPaperStat.total}',
            entries: mockStore.examPapers
                .map(
                  (paper) => ResetCatalogEntry(
                    id: paper.id,
                    title: paper.title,
                    progress: '${paper.done}/${paper.total}',
                  ),
                )
                .toList(),
          ),
        ],
        onConfirm: (catalogIds) =>
            mockStore.resetExamProgress(catalogIds: catalogIds),
      ),
    );
  }

  Widget _entryCard(
    IconData icon,
    Color iconColor,
    String title,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCardList extends StatelessWidget {
  final List<StudyRecord> records;

  const _HistoryCardList({required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: records.take(3).expand((record) {
        return [
          _historyCard(context, record),
          const SizedBox(height: 10),
        ];
      }).toList(),
    );
  }

  Widget _historyCard(BuildContext context, StudyRecord record) {
    void openAnalysis() {
      mockStore.openExamRecordAnalysis(record);
      context.go('/exam/analysis');
    }

    return GestureDetector(
      onTap: openAnalysis,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(record.mode,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(record.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            )),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${record.metric} · ${record.time}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textMuted,
                      )),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('查看解析',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
