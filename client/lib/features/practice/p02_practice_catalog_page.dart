import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../core/app_scaffold.dart';

/// P02 练习目录页 - 含状态栏、导航栏、学科数据面板、展开/收起的二级目录列表
class P02PracticeCatalogPage extends StatefulWidget {
  const P02PracticeCatalogPage({super.key});

  @override
  State<P02PracticeCatalogPage> createState() => _P02PracticeCatalogPageState();
}

class _P02PracticeCatalogPageState extends State<P02PracticeCatalogPage> {
  // 章节练习是否展开
  bool _chapterExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // 状态栏
          const StatusBar(),

          // 导航栏
          const NavBar(title: '练习模式'),

          // 内容区
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ===== 选中学科数据面板 - 渐变背景 =====
                  _buildSubjectPanel(),

                  const SizedBox(height: 12),

                  // ===== 二级目录独立列表 =====
                  Column(
                    children: [
                      // 章节练习 - 可展开/收起
                      _buildChapterCard(),

                      const SizedBox(height: 10),

                      // 模拟真题 - 独立收起状态
                      _buildMockExamRow(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== 跳转说明 =====
                  _buildHintBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 选中学科数据面板 - 渐变背景，含标题、统计和进度条
  Widget _buildSubjectPanel() {
    return Container(
      width: double.infinity,
      height: 109,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        children: [
          // 数据卡标题行
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 学科名称
                Text(
                  '小学教师',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                // 重置进度入口
                Container(
                  width: 61,
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '重置',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 统计数据行
          Positioned(
            top: 36,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '练习进度 328/1200',
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
                      '正确率 78%',
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
                      '错题量 88',
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
          ),

          // 进度条
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 328 / 1200,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 章节练习卡片 - 可展开/收起，含三级目录列表
  Widget _buildChapterCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Column(
        children: [
          // 二级标题行
          GestureDetector(
            onTap: () {
              setState(() {
                _chapterExpanded = !_chapterExpanded;
              });
            },
            child: Row(
              children: [
                // 图标
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.layers,
                    size: 16,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 10),
                // 标题
                Expanded(
                  child: Text(
                    '章节练习（共5章）',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // 练题进度标签
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '328/1200',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // 展开/收起箭头
                Icon(
                  _chapterExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // 三级目录列表（展开时显示）
          if (_chapterExpanded) ...[
            const SizedBox(height: 10),
            ..._buildChapterItems(),
          ],
        ],
      ),
    );
  }

  /// 构建三级章节目录列表
  List<Widget> _buildChapterItems() {
    final chapters = [
      {
        'name': '第一章：教育基础',
        'progress': '42/84',
        'fillWidth': 154.0,
        'fillColor': const Color(0xFFEAF3FF),
        'textColor': AppColors.textPrimary,
        'progressColor': AppColors.textSecondary,
        'isCompleted': false
      },
      {
        'name': '第二章：班级管理',
        'progress': '24/72',
        'fillWidth': 96.0,
        'fillColor': const Color(0xFFEAF3FF),
        'textColor': AppColors.textPrimary,
        'progressColor': AppColors.textSecondary,
        'isCompleted': false
      },
      {
        'name': '第三章：学生发展',
        'progress': '60/96',
        'fillWidth': 188.0,
        'fillColor': const Color(0xFFEAF3FF),
        'textColor': AppColors.textPrimary,
        'progressColor': AppColors.textSecondary,
        'isCompleted': false
      },
      {
        'name': '第四章：打分考评',
        'progress': '80/80',
        'fillWidth': 0.0,
        'fillColor': const Color(0xFFECFDF5),
        'textColor': const Color(0xFF064E3B),
        'progressColor': const Color(0xFF047857),
        'isCompleted': true
      },
    ];

    return chapters.map((ch) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: _buildChapterItem(
          name: ch['name'] as String,
          progress: ch['progress'] as String,
          fillColor: ch['fillColor'] as Color,
          textColor: ch['textColor'] as Color,
          progressColor: ch['progressColor'] as Color,
          isCompleted: ch['isCompleted'] as bool,
        ),
      );
    }).toList();
  }

  /// 单个三级章节项
  Widget _buildChapterItem({
    required String name,
    required String progress,
    required Color fillColor,
    required Color textColor,
    required Color progressColor,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () => context.go('/practice/sections'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isCompleted ? fillColor : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isCompleted ? const Color(0xFFA7F3D0) : AppColors.border,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // 进度底色（仅未完成时显示）
            if (!isCompleted)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: _getProgressWidth(progress),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      bottomLeft: Radius.circular(9),
                    ),
                  ),
                ),
              ),
            // 内容行
            Positioned(
              left: 9,
              top: 10,
              right: 9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight:
                          isCompleted ? FontWeight.w700 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        progress,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight:
                              isCompleted ? FontWeight.w700 : FontWeight.w600,
                          color: progressColor,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据进度文字计算宽度
  double _getProgressWidth(String progress) {
    final parts = progress.split('/');
    final current = int.tryParse(parts[0]) ?? 0;
    final total = int.tryParse(parts[1]) ?? 1;
    // 卡片内宽约322，减去padding后约296
    return (296 * current / total).clamp(0, 296).toDouble();
  }

  /// 模拟真题行 - 独立收起状态
  Widget _buildMockExamRow() {
    return GestureDetector(
      onTap: () => context.go('/practice/papers'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Icon(
                Icons.file_copy_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            // 文本区
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '模拟真题',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '5套试卷 · 600题',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // 真题进度标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '188/600',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// 跳转说明
  Widget _buildHintBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '点击任一三级目录进入 P04 四级目录页。',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
