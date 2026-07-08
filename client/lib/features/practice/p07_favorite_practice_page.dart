import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
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
      body: SizedBox(
        width: 390,
        height: 844,
        child: Stack(
          children: [
            Column(
              children: [
                // 状态栏
                Container(
                  height: 62,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('9:41',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text('●●● ■',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                // 导航栏
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
                // 筛选行
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
                              borderRadius: BorderRadius.circular(AppRadius.sm),
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
                // 题目列表
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 16, bottom: 110),
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => _buildFavCard(i),
                  ),
                ),
              ],
            ),
            // 底部浮动开始按钮
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 92,
                color: AppColors.surface,
                padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                child: GestureDetector(
                  onTap: () {
                    mockStore.startFavoritePractice(
                        count: mockStore.favoritePracticeCount);
                    context.go('/practice/quiz');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryLight, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('开始收藏练习（${mockStore.favoritePracticeCount}题）',
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
      ),
    );
  }

  Widget _buildFavCard(int index) {
    final questions = [
      '电气设备火灾时，应首先采取的措施是？',
      '以下哪种灭火器适用于电气火灾？',
      '安全电压的额定值不包括以下哪个？',
      '关于漏电保护器的安装，以下说法正确的有？',
      '触电急救的基本原则是什么？',
    ];
    final types = ['单选', '单选', '判断', '多选', '单选'];

    return Container(
      width: double.infinity,
      height: 84,
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
                child: Text(types[index],
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.primary)),
              ),
              const Icon(Icons.star, size: 16, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 8),
          Text(questions[index],
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
}
