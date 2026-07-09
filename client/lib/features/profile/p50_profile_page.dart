import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';

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
                    const SizedBox(height: 16),
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
        'title': '学习记录',
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
            'label': '错题入口',
            'route': '/profile/wrong'
          },
        ],
      },
      {
        'title': '学习工具',
        'items': [
          {
            'icon': Icons.upload_file,
            'label': '上传题库',
            'route': '/profile/upload'
          },
          {
            'icon': Icons.feedback_outlined,
            'label': '意见反馈',
            'route': '/profile/feedback'
          },
        ],
      },
      {
        'title': '关于',
        'items': [
          {
            'icon': Icons.info_outline,
            'label': '关于我们',
            'route': '/profile/about'
          },
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
                        onTap: () => context.go(item['route'] as String),
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
            NavBar(
              title: '全部练习记录',
              trailing: GestureDetector(
                onTap: () => context.go('/profile/practice-records/delete-all'),
                child: const Text(
                  '删除全部记录',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
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
                        const Text('练习记录',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        records.isEmpty
                            ? _buildEmptyRecordHint('暂无练习记录')
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
    final stat = mockStore.practiceStat;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(mockStore.selectedSubject.name,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('累计练习 ${stat.done}题',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('正确率 ${stat.accuracy}%',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('记录 ${mockStore.practiceRecords.length}条',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList(List<StudyRecord> records) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final record = records[i];
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
                  Text(record.metric,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyRecordHint(String text) {
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
          Text(text,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textMuted)),
        ],
      ),
    );
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
            NavBar(
              title: '全部考试记录',
              trailing: GestureDetector(
                onTap: () => context.go('/profile/exam-records/delete-all'),
                child: const Text(
                  '删除全部记录',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final records = mockStore.examRecords;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildExamStatsCard(),
                        const SizedBox(height: 14),
                        records.isEmpty
                            ? _buildEmptyRecordHint('暂无考试记录')
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: records.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) =>
                                    _buildExamRecordCard(records[i]),
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
    final stat = mockStore.examStat;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(mockStore.selectedSubject.name,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('考试 ${mockStore.examRecords.length}次',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('已考 ${stat.done}题',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('正确率 ${stat.accuracy}%',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamRecordCard(StudyRecord record) {
    final submitted = !record.metric.contains('未交卷');
    final parts = record.metric.split(' · ');
    final scoreText = parts.isNotEmpty ? parts.first : record.metric;
    final badgeText =
        submitted ? (parts.length > 1 ? parts.last : record.metric) : '未交卷';
    return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        ],
      ),
    );
  }

  Widget _buildEmptyRecordHint(String text) {
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
          Text(text,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// P53 错题练习入口页-我的入口态
class P53WrongEntryPage extends StatelessWidget {
  const P53WrongEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '错题'),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final count = mockStore.wrongPracticeCount;
                  final canStart = count > 0;
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(Icons.error_outline,
                              size: 40, color: AppColors.error),
                        ),
                        const SizedBox(height: 16),
                        Text('当前有 $count 道错题',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text(canStart ? '快来消灭它们吧！' : '暂无错题，继续练习即可积累错题本。',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textMuted)),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: canStart
                              ? () {
                                  mockStore.startWrongPractice(count: count);
                                  context.go('/practice/quiz');
                                }
                              : () => context.go('/practice/catalog'),
                          child: Container(
                            width: 200,
                            height: 44,
                            decoration: BoxDecoration(
                              color: canStart
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: Text(canStart ? '开始错题练习' : '去练习',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ),
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
}
