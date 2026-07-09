import 'package:flutter/material.dart';

import '../../core/app_scaffold.dart';
import '../../core/widgets.dart';
import '../../data/local/resource_cache_storage.dart';
import '../../data/mock/mock_app_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class P60CacheManagementPage extends StatefulWidget {
  const P60CacheManagementPage({super.key});

  @override
  State<P60CacheManagementPage> createState() => _P60CacheManagementPageState();
}

class _P60CacheManagementPageState extends State<P60CacheManagementPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '缓存管理'),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CacheStatusBanner(store: mockStore),
                        const SizedBox(height: 12),
                        _buildSubjectCard(),
                        const SizedBox(height: 12),
                        _buildCountGrid(),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          icon: Icons.sync,
                          text: _busy ? '处理中...' : '同步缓存',
                          primary: true,
                          onTap: _busy ? null : _flushCache,
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          text: '清除本地缓存',
                          primary: false,
                          onTap: _busy ? null : _confirmClearCache,
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

  Widget _buildSubjectCard() {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mockStore.selectedSubject.name,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  mockStore.remoteReady ? '服务端数据已同步' : '离线时优先读取本地快照',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountGrid() {
    final items = [
      _CacheCount('练习记录', '${mockStore.practiceRecords.length}条'),
      _CacheCount('考试记录', '${mockStore.examRecords.length}条'),
      _CacheCount('收藏题目', '${mockStore.favoriteQuestions.length}题'),
      _CacheCount('错题缓存', '${mockStore.wrongQuestions.length}题'),
      _CacheCount('章节目录', '${mockStore.chapters.length}章'),
      _CacheCount('考试目录', '${mockStore.examChapters.length}章'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.95,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.value,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(item.label,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textMuted)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required bool primary,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: primary ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 19,
                color: primary ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primary ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Future<void> _flushCache() async {
    setState(() => _busy = true);
    await mockStore.flushLocalState();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('本地缓存已同步')),
    );
  }

  Future<void> _confirmClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清除本地缓存？'),
        content: const Text('将删除本机保存的学习快照和资料列表缓存，当前页面中的数据会保留到下次刷新。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    await mockStore.clearLocalState();
    await clearResourceCache();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('本地缓存已清除')),
    );
  }
}

class _CacheCount {
  final String label;
  final String value;

  const _CacheCount(this.label, this.value);
}
