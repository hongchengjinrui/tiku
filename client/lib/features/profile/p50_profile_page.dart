import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';
import '../../core/widgets.dart';
import '../common/subject_progress_panel.dart';
import '../practice/p08_wrong_practice_entry_page.dart';

/// P50 我的页面
class P50ProfilePage extends StatelessWidget {
  const P50ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildAccountCard(),
                    CacheStatusBanner(
                      store: mockStore,
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                    ),
                    _buildOpenExperienceBanner(context),
                    const SizedBox(height: 16),
                    _buildQuickFunctions(context),
                  ],
                ),
              ),
            ),
            const BottomTabBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return AnimatedBuilder(
      animation: mockStore,
      builder: (context, _) {
        final stat = mockStore.practiceStat;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.person, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('本地体验用户',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                        '当前科目：${mockStore.selectedSubject.name} · 累计练习 ${stat.done}题',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpenExperienceBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 82,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF3B2106)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('开放体验模式',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD6A84A))),
              SizedBox(height: 4),
              Text('登录、支付、VIP 上架前统一接入',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFFD6A84A))),
            ],
          ),
          GestureDetector(
            onTap: () => context.go('/resources'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD6A84A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('看资料',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B2106))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFunctions(BuildContext context) {
    final groups = [
      {
        'title': '学习功能',
        'items': [
          {
            'icon': Icons.history,
            'label': '练习记录',
            'route': '/profile/practice-records'
          },
          {
            'icon': Icons.assignment,
            'label': '考试记录',
            'route': '/profile/exam-records'
          },
          {
            'icon': Icons.error_outline,
            'label': '错题练习',
            'route': '/profile/wrong'
          },
          {
            'icon': Icons.upload_file,
            'label': '上传题库',
            'route': '/profile/upload'
          },
        ],
      },
      {
        'title': '本地记录',
        'items': [
          {
            'icon': Icons.folder_copy_outlined,
            'label': '资料领取',
            'route': '/profile/resource-claims'
          },
          {
            'icon': Icons.rate_review_outlined,
            'label': '反馈记录',
            'route': '/profile/feedback-records'
          },
          {
            'icon': Icons.storage_outlined,
            'label': '缓存管理',
            'route': '/profile/cache'
          },
        ],
      },
      {
        'title': '关于我们',
        'items': [
          {
            'icon': Icons.description,
            'label': '用户协议',
            'route': '/agreement/user'
          },
          {
            'icon': Icons.privacy_tip,
            'label': '隐私协议',
            'route': '/agreement/privacy'
          },
          {
            'icon': Icons.feedback_outlined,
            'label': '意见反馈',
            'route': '/profile/feedback'
          },
          {
            'icon': Icons.info_outline,
            'label': '关于我们',
            'route': '/profile/about'
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(group['title'] as String,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: (group['items'] as List).map((item) {
                    final items = group['items'] as List;
                    final isLast = items.indexOf(item) == items.length - 1;
                    return Container(
                      decoration: isLast
                          ? null
                          : const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: AppColors.border, width: 0.5),
                              ),
                            ),
                      child: ListTile(
                        leading: Icon(item['icon'] as IconData,
                            size: 20, color: AppColors.primary),
                        title: Text(item['label'] as String,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: AppColors.textPrimary)),
                        trailing: const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.textMuted),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        dense: true,
                        onTap: () => context.push(item['route'] as String),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// P51 全部练习记录
class P51PracticeRecordsPage extends StatelessWidget {
  const P51PracticeRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '练习记录'),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final records = mockStore.practiceRecords;
                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        _buildStatsCard(),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('全部练习记录',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            GestureDetector(
                              onTap: () => context
                                  .go('/profile/practice-records/delete-all'),
                              child: const Text('删除全部记录',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.error)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        records.isEmpty
                            ? _buildEmptyRecordHint(context)
                            : _buildRecordList(records),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return PracticeProgressPanel(store: mockStore);
  }

  Widget _buildRecordList(List<StudyRecord> records) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final record = records[i];
            final canReview = record.practiceDetail != null;
            return Dismissible(
              key: ValueKey(
                  'practice-${record.id}-${record.title}-${record.time}-$i'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) =>
                  _confirmDeletePracticeRecord(context, record),
              onDismissed: (_) => _deletePracticeRecord(context, record),
              background: _deleteBackground(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(record.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 10),
                        Text(record.time,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(record.mode,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        Flexible(
                          child: Text(record.metric,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _recordAction(
                          '重新练习',
                          Icons.replay,
                          () {
                            mockStore.startPracticeFromRecord(record,
                                restart: true);
                            context.go('/practice/quiz');
                          },
                        ),
                        const SizedBox(width: 8),
                        _recordAction(
                          canReview ? '查看解析' : '继续练习',
                          canReview
                              ? Icons.visibility_outlined
                              : Icons.play_arrow,
                          () {
                            if (canReview) {
                              mockStore.openPracticeRecordAnalysis(record);
                            } else {
                              mockStore.startPracticeFromRecord(
                                record,
                                restart: false,
                              );
                            }
                            context.go('/practice/quiz');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text(
          '向左滑动卡片可删除记录',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF991B1B),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '删除',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _recordAction(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(text,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDeletePracticeRecord(
    BuildContext context,
    StudyRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除这条练习记录？'),
        content: const Text('删除后仅移除本条记录展示，不会影响题目进度。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _deletePracticeRecord(
    BuildContext context,
    StudyRecord record,
  ) async {
    final ok = await mockStore.deletePracticeRecord(record);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '练习记录已删除' : '删除失败，请稍后重试')),
    );
  }

  Widget _buildEmptyRecordHint(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.history, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 10),
          const Text('暂无练习记录',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textMuted)),
          const SizedBox(height: 14),
          _emptyActionButton(
            label: '去练习',
            icon: Icons.menu_book_outlined,
            onTap: () => context.go('/practice'),
          ),
        ],
      ),
    );
  }

  Widget _emptyActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// P53 资料领取记录
class P53ResourceClaimsPage extends StatelessWidget {
  const P53ResourceClaimsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '资料领取记录'),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final claims = mockStore.resourceClaims;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(),
                        const SizedBox(height: 14),
                        if (claims.isEmpty)
                          _buildEmptyState(context)
                        else
                          _buildClaimList(context, claims),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mockStore.selectedSubject.name,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryMetric('已领取', '${mockStore.claimedResourceCount}份'),
              _summaryMetric('获取链接', '${mockStore.resourceClaimTotalCount}次'),
              _summaryMetric('开放状态', '完整预览'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textBlueHint)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.folder_copy_outlined,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text('暂无资料领取记录',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('在资料页获取下载链接后，会在这里保留记录。',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textMuted)),
          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.go('/resources'),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text('去资料中心',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimList(BuildContext context, List<ResourceClaim> claims) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: claims.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildClaimCard(context, claims[index]),
    );
  }

  Widget _buildClaimCard(BuildContext context, ResourceClaim claim) {
    final tagColor = claim.isFree ? AppColors.success : const Color(0xFF8A5B16);
    final tagBg = claim.isFree ? AppColors.successBg : const Color(0xFFFFF9DF);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined,
                    size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claim.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 5),
                    Text(
                      '${claim.subjectName ?? mockStore.selectedSubject.name} · ${_formatClaimTime(claim.lastClaimedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(claim.isFree ? '免费' : 'VIP',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tagColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('已领取${claim.count}次',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary)),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _copyClaimLink(context, claim),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link, size: 15, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('复制链接',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyClaimLink(BuildContext context, ResourceClaim claim) async {
    await Clipboard.setData(ClipboardData(text: claim.link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('资料链接已经复制')),
    );
  }

  String _formatClaimTime(DateTime time) {
    if (time.millisecondsSinceEpoch <= 0) return '已领取';
    final now = DateTime.now();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return '今天 $hour:$minute';
    }
    return '${time.month}月${time.day}日 $hour:$minute';
  }
}

/// P52 全部考试记录
class P52ExamRecordsPage extends StatelessWidget {
  const P52ExamRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '考试记录'),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final records = mockStore.examRecords;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildExamStatsCard(),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('全部考试记录',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            GestureDetector(
                              onTap: () => context
                                  .go('/profile/exam-records/delete-all'),
                              child: const Text('删除全部记录',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.error)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        records.isEmpty
                            ? _buildEmptyRecordHint(context)
                            : Column(
                                children: [
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: records.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, i) =>
                                        _buildExamRecordCard(
                                            context, records[i], i),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    '向左滑动卡片可删除记录',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamStatsCard() {
    return ExamProgressPanel(store: mockStore);
  }

  Widget _buildExamRecordCard(
      BuildContext context, StudyRecord record, int index) {
    final submitted = !record.metric.contains('未交卷');
    final parts = record.metric.split(' · ');
    final scoreText = parts.isNotEmpty ? parts.first : record.metric;
    final badgeText =
        submitted ? (parts.length > 1 ? parts.last : record.metric) : '未交卷';
    return Dismissible(
      key: ValueKey('exam-${record.id}-${record.title}-${record.time}-$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDeleteExamRecord(context, record),
      onDismissed: (_) => _deleteExamRecord(context, record),
      background: _deleteBackground(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: submitted ? AppColors.successBg : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badgeText,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: submitted
                              ? AppColors.success
                              : AppColors.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(submitted ? scoreText : '答题中',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            submitted ? AppColors.success : AppColors.primary)),
                Text(record.time,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _examRecordAction(
                  '重新考试',
                  Icons.replay,
                  () {
                    mockStore.startExamFromRecord(record, restart: true);
                    context.go('/exam/answer');
                  },
                ),
                const SizedBox(width: 8),
                _examRecordAction(
                  submitted ? '查看解析' : '继续考试',
                  submitted ? Icons.visibility_outlined : Icons.play_arrow,
                  () {
                    if (submitted) {
                      mockStore.openExamRecordAnalysis(record);
                      context.go('/exam/analysis');
                    } else {
                      mockStore.startExamFromRecord(record, restart: false);
                      context.go('/exam/answer');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '删除',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _examRecordAction(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(text,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteExamRecord(
    BuildContext context,
    StudyRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除这条考试记录？'),
        content: const Text('删除后将不再展示本次考试成绩和解析入口。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _deleteExamRecord(
    BuildContext context,
    StudyRecord record,
  ) async {
    final ok = await mockStore.deleteExamRecord(record);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '考试记录已删除' : '删除失败，请稍后重试')),
    );
  }

  Widget _buildEmptyRecordHint(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.assignment_outlined,
              size: 36, color: AppColors.textMuted),
          const SizedBox(height: 10),
          const Text('暂无考试记录',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textMuted)),
          const SizedBox(height: 14),
          _emptyActionButton(
            label: '去考试',
            icon: Icons.description_outlined,
            onTap: () => context.go('/exam'),
          ),
        ],
      ),
    );
  }

  Widget _emptyActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// P53 错题练习入口页-我的入口态
class P53WrongEntryPage extends StatelessWidget {
  const P53WrongEntryPage({super.key});

  @override
  Widget build(BuildContext context) => const P08WrongPracticeEntryPage();
}
