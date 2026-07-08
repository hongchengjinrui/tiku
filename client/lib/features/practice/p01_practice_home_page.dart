import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../core/widgets.dart';
import '../../core/app_scaffold.dart';

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
                      // ===== 练习进度面板 - 渐变背景 =====
                      _buildProgressPanel(context, mockStore),

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
                                        context.go('/practice/catalog'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildEntryCard(
                                    icon: Icons.error_outline,
                                    iconColor: AppColors.error,
                                    title: '错题练习',
                                    onTap: () => context.go('/practice/wrong'),
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
                                        context.go('/practice/favorite'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildEntryCard(
                                    icon: Icons.shuffle,
                                    iconColor: const Color(0xFF8B5CF6),
                                    title: '随机练习',
                                    onTap: () => context.go('/practice/random'),
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
                                  context.go('/profile/practice-records'),
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
                          children: [
                            ...mockStore.practiceRecords.take(3).expand(
                                  (record) => [
                                    _buildRecentRecordCard(record),
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

  /// 练习进度面板 - 渐变背景
  Widget _buildProgressPanel(BuildContext context, MockAppStore store) {
    final stat = store.practiceStat;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行 - 学科名称 + 切换科目
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 学科名称
              Text(
                store.selectedSubject.name,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              // 今日进度提示
              Text(
                '',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textBlueHint,
                ),
              ),
              // 切换科目入口
              GestureDetector(
                onTap: () => context.go('/practice/switch-subject'),
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '切换科目',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 14,
                        color: AppColors.textBlueHint,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 今日新增进度描述
          Text(
            '今日新增进度：24题      已累计练习：14天',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textBlueHint,
            ),
          ),
          const SizedBox(height: 12),
          // 总进度统计行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '练习进度 ${stat.done}/${stat.total}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '正确率 ${stat.accuracy}%',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '错题量 ${stat.wrong}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 总进度条背景
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

  Widget _buildRecentRecordCard(StudyRecord record) {
    final isLowAccuracy =
        record.metric.contains('正确率 5') || record.metric.contains('正确率 6');
    return _buildRecentCard(
      title: record.title,
      accuracy: _accuracyText(record.metric),
      accuracyColor: isLowAccuracy ? AppColors.error : AppColors.success,
      info: '${record.mode} · ${record.metric} · ${record.time}',
      action1Text: '重新练习',
      action1Bg: AppColors.primaryBg,
      action1Fg: AppColors.primary,
      action2Text: '继续练习',
      action2Bg: AppColors.primaryBg,
      action2Fg: AppColors.primary,
      progress: _recordProgress(record.metric),
    );
  }

  String _accuracyText(String metric) {
    final match = RegExp(r'正确率\s?\d+%').firstMatch(metric);
    return match?.group(0) ?? '正确率 --';
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
                    Container(
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
                    const SizedBox(width: 6),
                    // 操作按钮2
                    Container(
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
