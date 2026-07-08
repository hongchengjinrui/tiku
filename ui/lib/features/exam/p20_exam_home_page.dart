import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _ExamProgressPanel(),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _ExamEntrySection(),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('考试记录',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              )),
                          Text('全部考试记录',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _HistoryCardList(),
                    ),
                  ],
                ),
              ),
            ),
            const _ExamTabBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _ExamProgressPanel extends StatelessWidget {
  const _ExamProgressPanel();

  @override
  Widget build(BuildContext context) {
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
              const Text('小学教师',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
              Container(
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
            ],
          ),
          const SizedBox(height: 10),
          const Text('今日新增进度：3题      已累计考核：12天',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textBlueHint,
              )),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _ruleItem('1200', '总题数')),
              Expanded(child: _ruleItem('120分', '考试时间')),
              Expanded(child: _ruleItem('72', '及格分')),
              Expanded(child: _ruleItem('78%', '总正确率')),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.27,
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
              child: const Text('考试规则',
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
            _entryCard(Icons.book_outlined, AppColors.primary, '章节考试', '按章节逐步考核'),
            const SizedBox(width: 10),
            _entryCard(Icons.edit_note, AppColors.primaryDark, '模拟考试', '模拟真实考试'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _entryCard(Icons.description_outlined, AppColors.primary, '真题考试', '历年真题练习'),
            const SizedBox(width: 10),
            _entryCard(Icons.assignment, AppColors.primaryDark, '组卷考试', '自定义组卷'),
          ],
        ),
      ],
    );
  }

  Widget _entryCard(IconData icon, Color iconColor, String title, String desc) {
    return Expanded(
      child: Container(
        height: 104,
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
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 2),
            Text(desc,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}

class _HistoryCardList extends StatelessWidget {
  const _HistoryCardList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _historyCard('组卷12', '组卷考试', '88/100题', '正确率 88%', '查看解析'),
        const SizedBox(height: 10),
        _historyCard('模拟卷一', '模拟考试', '72/100题', '正确率 75%', '查看解析'),
        const SizedBox(height: 10),
        _historyCard('2024真题卷', '真题考试', '100/100题', '正确率 82%', '查看解析'),
      ],
    );
  }

  Widget _historyCard(String title, String type, String progress, String accuracy, String action) {
    return Container(
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(type,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        )),
                  ),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                ],
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$progress · $accuracy',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  )),
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(action,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamTabBar extends StatelessWidget {
  final int currentIndex;
  const _ExamTabBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(icon: Icons.menu_book_outlined, label: '练习'),
      _TabItem(icon: Icons.description_outlined, label: '考试'),
      _TabItem(icon: Icons.folder_open_outlined, label: '资料'),
      _TabItem(icon: Icons.person_outline, label: '我的'),
    ];

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final t = tabs[i];
          final selected = i == currentIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(t.icon,
                    size: 22,
                    color: selected ? AppColors.primary : AppColors.textMuted),
                const SizedBox(height: 2),
                Text(t.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: selected ? AppColors.primary : AppColors.textMuted,
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  _TabItem({required this.icon, required this.label});
}
