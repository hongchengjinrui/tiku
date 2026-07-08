import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';

/// QT01 单选题-作答态
class QT01SingleChoicePage extends StatefulWidget {
  const QT01SingleChoicePage({super.key});

  @override
  State<QT01SingleChoicePage> createState() => _QT01SingleChoicePageState();
}

class _QT01SingleChoicePageState extends State<QT01SingleChoicePage> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '章节练习'),
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        '在教师资格证考试中，教育观的核心内容是什么？',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    ..._buildOptions(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('第 3 / 80 题',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('单选',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 3 / 80,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions() {
    final options = ['A. 以人为本', 'B. 以分数为本', 'C. 以教材为本', 'D. 以考试为本'];
    return options.asMap().entries.map((entry) {
      final i = entry.key;
      final selected = i == _selected;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => setState(() => _selected = i),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryBg : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(['A', 'B', 'C', 'D'][i],
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(options[i].substring(3),
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBottomBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: const [
              Icon(Icons.chevron_left, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text('上一题',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textSecondary)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: const [
              Text('下一题',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 18, color: Colors.white),
            ]),
          ),
        ],
      ),
    );
  }
}

/// QT02 多选题-作答态
class QT02MultipleChoicePage extends StatefulWidget {
  const QT02MultipleChoicePage({super.key});

  @override
  State<QT02MultipleChoicePage> createState() => _QT02MultipleChoicePageState();
}

class _QT02MultipleChoicePageState extends State<QT02MultipleChoicePage> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '章节练习'),
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        '以下哪些属于新课程改革的具体目标？（多选）',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    ..._buildOptions(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('第 5 / 80 题',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(4)),
            child: const Text('多选',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
              value: 5 / 80,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary)),
        ),
      ]),
    );
  }

  List<Widget> _buildOptions() {
    final options = [
      '实现课程功能的转变',
      '密切课程内容与生活和时代的联系',
      '实行三级课程管理制度',
      '取消所有考试评价制度',
    ];
    return options.asMap().entries.map((entry) {
      final i = entry.key;
      final selected = _selected.contains(i);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _selected.remove(i);
            } else {
              _selected.add(i);
            }
          }),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryBg : AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Row(children: [
              Icon(
                selected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(options[i],
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ),
            ]),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBottomBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
          color: AppColors.card,
          border:
              Border(top: BorderSide(color: AppColors.border, width: 1))),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: Row(children: const [
                Icon(Icons.chevron_left,
                    size: 18, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('上一题',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textSecondary)),
              ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: const [
                Text('下一题',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 18, color: Colors.white),
              ]),
            ),
          ]),
    );
  }
}

/// QT03 判断题-作答态
class QT03TrueFalsePage extends StatefulWidget {
  const QT03TrueFalsePage({super.key});

  @override
  State<QT03TrueFalsePage> createState() => _QT03TrueFalsePageState();
}

class _QT03TrueFalsePageState extends State<QT03TrueFalsePage> {
  bool? _selected; // true=对, false=错

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(children: [
          const StatusBar(),
          const NavBar(title: '章节练习'),
          _buildProgress(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        '教育目的的社会本位论认为，教育目的应根据个人发展需要来确定。',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: _buildJudgeButton(true, '正确', Icons.check)),
                      const SizedBox(width: 16),
                      Expanded(
                          child:
                              _buildJudgeButton(false, '错误', Icons.close)),
                    ]),
                  ]),
            ),
          ),
          _buildBottomBar(),
        ]),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('第 8 / 80 题',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(4)),
            child: const Text('判断',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
              value: 8 / 80,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _buildJudgeButton(bool value, String label, IconData icon) {
    final selected = _selected == value;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBg : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 32,
                color: selected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
          color: AppColors.card,
          border:
              Border(top: BorderSide(color: AppColors.border, width: 1))),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: const Text('上一题',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textSecondary)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('下一题',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ]),
    );
  }
}

/// QT04 填空题-作答态
class QT04FillBlankPage extends StatelessWidget {
  const QT04FillBlankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(children: [
          const StatusBar(),
          const NavBar(title: '章节练习'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('第 10 / 80 题',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('填空',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.primary)),
                    ),
                  ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                    value: 10 / 80,
                    minHeight: 4,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary)),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '皮亚杰将儿童认知发展分为四个阶段，第一个阶段是'),
                          TextSpan(
                              text: '＿＿＿＿＿',
                              style: TextStyle(color: AppColors.primary)),
                          TextSpan(text: '。'),
                        ],
                      ),
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          height: 1.6,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: '请输入答案',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(
                    top: BorderSide(color: AppColors.border, width: 1))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border)),
                    child: const Text('上一题',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textSecondary)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('下一题',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ]),
          ),
        ]),
      ),
    );
  }
}

/// QT05 简答题-作答态 / QT11~QT17 结果态 - 复用简化的作答框架
class QT05ShortAnswerPage extends StatelessWidget {
  final String title;
  final String question;
  final String typeLabel;
  final Widget? analysisWidget;
  final int? correctAnswer;
  final int? userAnswer;

  const QT05ShortAnswerPage({
    super.key,
    this.title = '章节练习',
    this.question = '简述建构主义学习理论的基本观点。',
    this.typeLabel = '简答',
    this.analysisWidget,
    this.correctAnswer,
    this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(children: [
          const StatusBar(),
          NavBar(title: title),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('第 12 / 80 题',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: AppColors.primaryBg,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(typeLabel,
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.primary)),
                          ),
                        ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                          value: 12 / 80,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary)),
                    ),
                    const SizedBox(height: 16),
                    Text(question,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const TextField(
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: '请输入答案...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (analysisWidget != null) ...[
                      const SizedBox(height: 16),
                      analysisWidget!,
                    ],
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// QT09 单选题-页内结果态（共用结果组件）
class QTResultWidget extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final String analysis;

  const QTResultWidget({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isCorrect ? '回答正确' : '回答错误',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCorrect ? AppColors.success : AppColors.error)),
          const SizedBox(height: 10),
          Text('正确答案：$correctAnswer',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(analysis,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// QT06 材料题-混合子题作答态
class QT06MaterialPage extends StatelessWidget {
  const QT06MaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(children: [
          const StatusBar(),
          const NavBar(title: '章节练习'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: const Text(
                          '阅读以下材料，回答1-3题：\n\n某小学教师在课堂上采用小组合作学习的方式，让学生分组讨论问题。讨论结束后，教师对每个小组的表现进行了评价...',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              height: 1.8,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 16),
                    const Text('第1题（单选）：该教师采用的教学方法属于？',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ...['探究式教学', '讲授式教学', '讨论式教学', '练习式教学']
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: e.key == 2
                                      ? AppColors.primaryBg
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: e.key == 2
                                          ? AppColors.primary
                                          : AppColors.border),
                                ),
                                child: Text(e.value,
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: e.key == 2
                                            ? AppColors.primary
                                            : AppColors.textPrimary)),
                              ),
                            )),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// QT07 题干图片题-作答态
class QT07ImageQuestionPage extends StatelessWidget {
  const QT07ImageQuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(children: [
          const StatusBar(),
          const NavBar(title: '章节练习'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('根据下方图片回答问题：',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.image_outlined,
                          size: 64, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text('图中展示的是哪种教学方法？',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    ...['讲授法', '演示法', '讨论法', '实验法']
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.border)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(e.value,
                                      style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                ]),
                              ),
                            )),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
