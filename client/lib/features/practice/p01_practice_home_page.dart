import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../core/widgets.dart';
import '../../core/app_scaffold.dart';
import '../common/subject_progress_panel.dart';

/// P01 练习模式首页 - 含状态栏、渐变数据面板、四类练习入口、最近练习列表、底部TabBar
class P01PracticeHomePage extends StatelessWidget {
  const P01PracticeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // 状态栏
          const StatusBar(),

          // 可滚动内容区
          Expanded(
            child: AnimatedBuilder(
              animation: mockStore,
              builder: (context, _) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CacheStatusBanner(
                        store: mockStore,
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      ),

                      // ===== 练习进度面板 - 渐变背景 =====
                      PracticeProgressPanel(
                        store: mockStore,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),

                      if (_hasActivePracticeSession(mockStore)) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildActivePracticeCard(
                            context,
                            mockStore.practiceSession!,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ===== 练习入口 标题 =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '练习入口',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===== 四类练习入口 (2x2 网格) =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // 第一行: 开始练习 / 错题练习
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEntryCard(
                                    icon: Icons.menu_book,
                                    iconColor: AppColors.primary,
                                    title: '开始练习',
                                    onTap: () =>
                                        context.push('/practice/catalog'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildEntryCard(
                                    icon: Icons.error_outline,
                                    iconColor: AppColors.error,
                                    title: '错题练习',
                                    onTap: () =>
                                        context.push('/practice/wrong'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // 第二行: 收藏练习 / 随机练习
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEntryCard(
                                    icon: Icons.star,
                                    iconColor: AppColors.warning,
                                    title: '收藏练习',
                                    onTap: () =>
                                        context.push('/practice/favorite'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildEntryCard(
                                    icon: Icons.shuffle,
                                    iconColor: const Color(0xFF8B5CF6),
                                    title: '随机练习',
                                    onTap: () =>
                                        context.push('/practice/random'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== 最近练习 标题行 =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '最近练习',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.push('/profile/practice-records'),
                              child: Text(
                                '全部练习记录',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===== 最近3次练习卡片 =====
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 24),
                        child: Column(
                          children: mockStore.practiceRecords.isEmpty
                              ? [_buildRecentEmptyCard(context)]
                              : [
                                  ...mockStore.practiceRecords.take(3).expand(
                                        (record) => [
                                          _buildRecentRecordCard(
                                              context, record),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ===== 底部 TabBar =====
          const BottomTabBar(currentIndex: 0),
        ],
      ),
    );
  }

  bool _hasActivePracticeSession(MockAppStore store) {
    final session = store.practiceSession;
    return session != null && !session.finished && session.questions.isNotEmpty;
  }

  Widget _buildActivePracticeCard(
    BuildContext context,
    PracticeSession session,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go('/practice/quiz'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '继续上次练习',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.mode} · ${session.title} · 已作答 ${session.answeredCount}/${session.questions.length}题',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text(
                '继续',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 练习入口卡片
  Widget _buildEntryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecordCard(BuildContext context, StudyRecord record) {
    final canReview = record.practiceDetail != null;
    return _buildRecentCard(
      title: record.title,
      accuracy: _accuracyText(record.metric),
      accuracyColor: _recordStatusColor(record.metric),
      info: '${record.mode} · ${record.metric} · ${record.time}',
      action1Text: '重新练习',
      action1Bg: AppColors.primaryBg,
      action1Fg: AppColors.primary,
      action2Text: canReview ? '查看解析' : '继续练习',
      action2Bg: AppColors.primaryBg,
      action2Fg: AppColors.primary,
      progress: _recordProgress(record.metric),
      onRestart: () {
        mockStore.startPracticeFromRecord(record, restart: true);
        context.go('/practice/quiz');
      },
      onContinue: () {
        if (canReview) {
          mockStore.openPracticeRecordAnalysis(record);
        } else {
          mockStore.startPracticeFromRecord(record, restart: false);
        }
        context.go('/practice/quiz');
      },
    );
  }

  Widget _buildRecentEmptyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.history, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 10),
          const Text(
            '暂无练习记录',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '完成章节练习、随机练习或错题练习后会显示在这里。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/practice/catalog'),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text(
                '开始练习',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _accuracyText(String metric) {
    final match = RegExp(r'正确率\s?\d+%').firstMatch(metric);
    if (match != null) return match.group(0)!;
    if (metric.contains('回答正确')) return '回答正确';
    if (metric.contains('回答错误')) return '回答错误';
    if (metric.contains('未交卷')) return '未交卷';
    return '暂无统计';
  }

  Color _recordStatusColor(String metric) {
    if (metric.contains('回答错误') || metric.contains('未交卷')) {
      return AppColors.error;
    }
    final match = RegExp(r'正确率\s?(\d+)%').firstMatch(metric);
    final accuracy = int.tryParse(match?.group(1) ?? '');
    if (accuracy != null && accuracy < 70) return AppColors.error;
    return AppColors.success;
  }

  double _recordProgress(String metric) {
    final match = RegExp(r'(\d+)/(\d+)题').firstMatch(metric);
    if (match == null) return 1;
    final done = int.tryParse(match.group(1) ?? '') ?? 0;
    final total = int.tryParse(match.group(2) ?? '') ?? 1;
    return total == 0 ? 0 : done / total;
  }

  /// 最近练习卡片
  Widget _buildRecentCard({
    required String title,
    required String accuracy,
    required Color accuracyColor,
    required String info,
    required String action1Text,
    required Color action1Bg,
    required Color action1Fg,
    required String action2Text,
    required Color action2Bg,
    required Color action2Fg,
    required double progress,
    required VoidCallback onRestart,
    required VoidCallback onContinue,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                accuracy,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accuracyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 进度/操作行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  info,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    // 操作按钮1
                    GestureDetector(
                      onTap: onRestart,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 25,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: action1Bg,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          action1Text,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: action1Fg,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 操作按钮2
                    GestureDetector(
                      onTap: onContinue,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 25,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: action2Bg,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          action2Text,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: action2Fg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 进度条
          ProgressBar(progress: progress),
        ],
      ),
    );
  }
}
