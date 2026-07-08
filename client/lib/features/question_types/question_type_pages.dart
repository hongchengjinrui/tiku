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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('在教师资格证考试中，教育观的核心内容是什么？',
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('以下哪些属于新课程改革的具体目标？（多选）',
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
                selected ? Icons.check_box : Icons.check_box_outline_blank,
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
          border: Border(top: BorderSide(color: AppColors.border, width: 1))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
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
              color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
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
                    const Text('教育目的的社会本位论认为，教育目的应根据个人发展需要来确定。',
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
                          child: _buildJudgeButton(false, '错误', Icons.close)),
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
                    color:
                        selected ? AppColors.primary : AppColors.textPrimary)),
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
          border: Border(top: BorderSide(color: AppColors.border, width: 1))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('第 10 / 80 题',
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary)),
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
                border:
                    Border(top: BorderSide(color: AppColors.border, width: 1))),
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
                    ...[
                      '讲授法',
                      '演示法',
                      '讨论法',
                      '实验法'
                    ].asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: AppColors.border)),
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

/// QT08 图片加载失败态
class QT08ImageLoadFailedPage extends StatelessWidget {
  const QT08ImageLoadFailedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '图片题',
      questionIndex: '第 16 / 80 题',
      progress: 16 / 80,
      leadContent: const _QTImagePlaceholder(
        icon: Icons.broken_image_outlined,
        label: '图片加载失败',
        hint: '点击重试',
        tone: _ImageTone.error,
      ),
      question: '根据题干图片判断该课堂组织方式的主要特点。',
      choices: const [
        _QTChoiceData('A', '教师单向讲授', _QTChoiceState.normal),
        _QTChoiceData('B', '学生合作探究', _QTChoiceState.selected),
        _QTChoiceData('C', '独立完成测验', _QTChoiceState.normal),
        _QTChoiceData('D', '课后自主复习', _QTChoiceState.normal),
      ],
      resultCard: null,
    );
  }
}

/// QT09 单选题-结果态
class QT09SingleChoiceResultPage extends StatelessWidget {
  const QT09SingleChoiceResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '单选',
      questionIndex: '第 3 / 80 题',
      progress: 3 / 80,
      question: '在教师资格证考试中，教育观的核心内容是什么？',
      choices: const [
        _QTChoiceData('A', '以人为本', _QTChoiceState.correct),
        _QTChoiceData('B', '以分数为本', _QTChoiceState.normal),
        _QTChoiceData('C', '以教材为本', _QTChoiceState.normal),
        _QTChoiceData('D', '以考试为本', _QTChoiceState.normal),
      ],
      resultCard: const _QTAnalysisCard(
        correct: true,
        correctAnswer: 'A',
        userAnswer: 'A',
        analysis: '教育观强调以学生发展为中心，尊重学生主体地位，促进学生全面发展。',
      ),
    );
  }
}

/// QT10 多选题-结果态
class QT10MultipleChoiceResultPage extends StatelessWidget {
  const QT10MultipleChoiceResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '多选',
      questionIndex: '第 5 / 80 题',
      progress: 5 / 80,
      multiple: true,
      question: '以下哪些属于新课程改革的具体目标？（多选）',
      choices: const [
        _QTChoiceData('A', '实现课程功能的转变', _QTChoiceState.correct),
        _QTChoiceData('B', '密切课程内容与生活和时代的联系', _QTChoiceState.correct),
        _QTChoiceData('C', '实行三级课程管理制度', _QTChoiceState.missed),
        _QTChoiceData('D', '取消所有考试评价制度', _QTChoiceState.wrong),
      ],
      resultCard: const _QTAnalysisCard(
        correct: false,
        correctAnswer: 'A、B、C',
        userAnswer: 'A、B、D',
        analysis: '新课程改革强调课程功能、内容关联和课程管理机制改革，不是取消评价制度。',
      ),
    );
  }
}

/// QT11 判断题-结果态
class QT11TrueFalseResultPage extends StatelessWidget {
  const QT11TrueFalseResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '判断',
      questionIndex: '第 8 / 80 题',
      progress: 8 / 80,
      question: '教育目的的社会本位论认为，教育目的应根据个人发展需要来确定。',
      choices: const [
        _QTChoiceData('A', '正确', _QTChoiceState.wrong),
        _QTChoiceData('B', '错误', _QTChoiceState.correct),
      ],
      resultCard: const _QTAnalysisCard(
        correct: false,
        correctAnswer: '错误',
        userAnswer: '正确',
        analysis: '社会本位论强调教育目的由社会需要决定，个人本位论才强调个人发展需要。',
      ),
    );
  }
}

/// QT12 填空题-结果态
class QT12FillBlankResultPage extends StatelessWidget {
  const QT12FillBlankResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '填空',
      questionIndex: '第 10 / 80 题',
      progress: 10 / 80,
      question: '皮亚杰将儿童认知发展分为四个阶段，第一个阶段是＿＿＿＿＿。',
      answerContent: const _QTAnswerBox(text: '感知运动阶段', correct: true),
      resultCard: const _QTAnalysisCard(
        correct: true,
        correctAnswer: '感知运动阶段',
        userAnswer: '感知运动阶段',
        analysis: '皮亚杰认知发展阶段依次为感知运动、前运算、具体运算和形式运算阶段。',
      ),
    );
  }
}

/// QT13 简答题-评分结果态
class QT13ShortAnswerScoredResultPage extends StatelessWidget {
  const QT13ShortAnswerScoredResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '简答',
      questionIndex: '第 12 / 80 题',
      progress: 12 / 80,
      question: '简述建构主义学习理论的基本观点。',
      answerContent: const _QTLongAnswerBox(
        text: '建构主义认为学习是学生主动建构知识意义的过程，教师应创设真实情境，引导学生协作、探究并完成知识建构。',
      ),
      resultCard: const _QTShortAnswerScoreCard(
        score: '8/10',
        correct: true,
        correctAnswer: '学习不是被动接受知识，而是在已有经验基础上主动建构意义；教师需要创设情境、促进协作学习并提供支架。',
        userAnswer: '建构主义认为学习是学生主动建构知识意义的过程，教师应创设真实情境，引导学生协作、探究并完成知识建构。',
        analysis: '命中“主动建构”“已有经验”“情境创设”“协作探究”等核心要点。',
        supplement: '可补充教师支架作用和学习共同体等关键词。',
      ),
    );
  }
}

/// QT14 材料题-结果态
class QT14MaterialResultPage extends StatelessWidget {
  const QT14MaterialResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '材料',
      questionIndex: '第 18 / 80 题',
      progress: 18 / 80,
      leadContent: const _QTMaterialBlock(),
      question: '第1题：该教师采用的教学方法属于？',
      choices: const [
        _QTChoiceData('A', '探究式教学', _QTChoiceState.normal),
        _QTChoiceData('B', '讲授式教学', _QTChoiceState.normal),
        _QTChoiceData('C', '讨论式教学', _QTChoiceState.correct),
        _QTChoiceData('D', '练习式教学', _QTChoiceState.normal),
      ],
      resultCard: const _QTAnalysisCard(
        correct: true,
        correctAnswer: 'C',
        userAnswer: 'C',
        analysis: '材料中教师组织学生分组讨论并评价小组表现，核心活动是讨论交流。',
      ),
    );
  }
}

/// QT15 题干图片题-结果态
class QT15ImageResultPage extends StatelessWidget {
  const QT15ImageResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '图片题',
      questionIndex: '第 20 / 80 题',
      progress: 20 / 80,
      leadContent: const _QTImagePlaceholder(
        icon: Icons.image_outlined,
        label: '课堂活动图片',
        hint: '点击可预览大图',
        tone: _ImageTone.primary,
      ),
      question: '图中展示的是哪种教学方法？',
      choices: const [
        _QTChoiceData('A', '讲授法', _QTChoiceState.normal),
        _QTChoiceData('B', '演示法', _QTChoiceState.correct),
        _QTChoiceData('C', '讨论法', _QTChoiceState.normal),
        _QTChoiceData('D', '实验法', _QTChoiceState.normal),
      ],
      resultCard: const _QTAnalysisCard(
        correct: true,
        correctAnswer: 'B',
        userAnswer: 'B',
        analysis: '图片中教师通过直观展示帮助学生理解知识，符合演示法的典型特征。',
      ),
    );
  }
}

/// QT16 题干多图题-结果态
class QT16MultiImageResultPage extends StatelessWidget {
  const QT16MultiImageResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '多图题',
      questionIndex: '第 22 / 80 题',
      progress: 22 / 80,
      leadContent: const _QTMultiImageGrid(labels: ['情境图 1', '情境图 2', '情境图 3']),
      question: '结合三张课堂情境图，判断最适合采用的评价方式。',
      choices: const [
        _QTChoiceData('A', '终结性评价', _QTChoiceState.normal),
        _QTChoiceData('B', '过程性评价', _QTChoiceState.correct),
        _QTChoiceData('C', '选拔性评价', _QTChoiceState.normal),
        _QTChoiceData('D', '常模参照评价', _QTChoiceState.normal),
      ],
      resultCard: const _QTAnalysisCard(
        correct: true,
        correctAnswer: 'B',
        userAnswer: 'B',
        analysis: '多张情境图连续展示学习过程，更适合使用过程性评价关注学生阶段表现。',
      ),
    );
  }
}

/// QT17 解析多图题-结果态
class QT17AnalysisMultiImageResultPage extends StatelessWidget {
  const QT17AnalysisMultiImageResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _QTStaticResultPage(
      typeLabel: '解析图',
      questionIndex: '第 24 / 80 题',
      progress: 24 / 80,
      question: '依据课堂观察记录，教师应优先优化哪一项教学设计？',
      choices: const [
        _QTChoiceData('A', '导入环节', _QTChoiceState.normal),
        _QTChoiceData('B', '板书布局', _QTChoiceState.correct),
        _QTChoiceData('C', '作业数量', _QTChoiceState.normal),
        _QTChoiceData('D', '座位排序', _QTChoiceState.normal),
      ],
      resultCard: const _QTAnalysisCard(
        correct: true,
        correctAnswer: 'B',
        userAnswer: 'B',
        analysis: '解析图显示板书区域信息层级混乱，优先调整板书布局能提升课堂信息组织效率。',
        extra: _QTMultiImageGrid(labels: ['解析图 1', '解析图 2']),
      ),
    );
  }
}

class _QTStaticResultPage extends StatelessWidget {
  final String typeLabel;
  final String questionIndex;
  final double progress;
  final String question;
  final List<_QTChoiceData> choices;
  final Widget? leadContent;
  final Widget? answerContent;
  final Widget? resultCard;
  final bool multiple;

  const _QTStaticResultPage({
    required this.typeLabel,
    required this.questionIndex,
    required this.progress,
    required this.question,
    this.choices = const [],
    this.leadContent,
    this.answerContent,
    this.resultCard,
    this.multiple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '章节练习'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QTProgressHeader(
                      questionIndex: questionIndex,
                      typeLabel: typeLabel,
                      progress: progress,
                    ),
                    const SizedBox(height: 16),
                    if (leadContent != null) ...[
                      leadContent!,
                      const SizedBox(height: 16),
                    ],
                    Text(
                      question,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (choices.isNotEmpty)
                      ...choices.map(
                        (choice) => _QTChoiceRow(
                          data: choice,
                          multiple: multiple,
                        ),
                      ),
                    if (answerContent != null) answerContent!,
                    if (resultCard != null) ...[
                      const SizedBox(height: 16),
                      resultCard!,
                    ],
                  ],
                ),
              ),
            ),
            const _QTBottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _QTProgressHeader extends StatelessWidget {
  final String questionIndex;
  final String typeLabel;
  final double progress;

  const _QTProgressHeader({
    required this.questionIndex,
    required this.typeLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              questionIndex,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _QTChoiceRow extends StatelessWidget {
  final _QTChoiceData data;
  final bool multiple;

  const _QTChoiceRow({required this.data, required this.multiple});

  @override
  Widget build(BuildContext context) {
    final color = data.state.color;
    final bg = data.state.background;
    final border = data.state.border;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: multiple ? BoxShape.rectangle : BoxShape.circle,
              color: data.state == _QTChoiceState.normal
                  ? AppColors.surface
                  : color,
              borderRadius: multiple ? BorderRadius.circular(6) : null,
              border: Border.all(
                color: data.state == _QTChoiceState.normal
                    ? AppColors.border
                    : color,
              ),
            ),
            child: data.state == _QTChoiceState.normal
                ? Text(
                    data.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  )
                : Icon(
                    data.state == _QTChoiceState.wrong
                        ? Icons.close
                        : Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${data.label}. ${data.text}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: data.state == _QTChoiceState.normal
                    ? AppColors.textPrimary
                    : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QTAnalysisCard extends StatelessWidget {
  final bool correct;
  final String correctAnswer;
  final String userAnswer;
  final String analysis;
  final Widget? extra;

  const _QTAnalysisCard({
    required this.correct,
    required this.correctAnswer,
    required this.userAnswer,
    required this.analysis,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.error;
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
          Text(
            correct ? '回答正确' : '回答错误',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          _AnalysisLine(label: '正确答案', value: correctAnswer),
          const SizedBox(height: 8),
          _AnalysisLine(label: '我的答案', value: userAnswer),
          const SizedBox(height: 8),
          Text(
            '解析结果：$analysis',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          if (extra != null) ...[
            const SizedBox(height: 12),
            extra!,
          ],
        ],
      ),
    );
  }
}

class _QTShortAnswerScoreCard extends StatelessWidget {
  final String score;
  final bool correct;
  final String correctAnswer;
  final String userAnswer;
  final String analysis;
  final String supplement;

  const _QTShortAnswerScoreCard({
    required this.score,
    required this.correct,
    required this.correctAnswer,
    required this.userAnswer,
    required this.analysis,
    required this.supplement,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.error;
    final bg = correct ? AppColors.successBg : AppColors.errorBg;
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
          Row(
            children: [
              Text(
                correct ? '回答正确' : '回答错误',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  score,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AnalysisLine(label: '正确答案', value: correctAnswer),
          const SizedBox(height: 8),
          _AnalysisLine(label: '我的答案', value: userAnswer),
          const SizedBox(height: 8),
          Text(
            '解析结果：$analysis',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '待补充：$supplement',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisLine extends StatelessWidget {
  final String label;
  final String value;

  const _AnalysisLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label：$value',
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.6,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _QTAnswerBox extends StatelessWidget {
  final String text;
  final bool correct;

  const _QTAnswerBox({required this.text, required this.correct});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: correct ? AppColors.successBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: correct ? AppColors.success : AppColors.error,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: correct ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

class _QTLongAnswerBox extends StatelessWidget {
  final String text;

  const _QTLongAnswerBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.6,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _QTMaterialBlock extends StatelessWidget {
  const _QTMaterialBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: const Text(
        '阅读以下材料，回答1-3题：\n某小学教师在课堂上采用小组合作学习方式，让学生分组讨论问题，并在讨论结束后评价各组表现。',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.8,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _QTImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final _ImageTone tone;

  const _QTImagePlaceholder({
    required this.icon,
    required this.label,
    required this.hint,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        tone == _ImageTone.error ? AppColors.error : AppColors.primary;
    final bg =
        tone == _ImageTone.error ? AppColors.errorBg : AppColors.primaryBg;
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QTMultiImageGrid extends StatelessWidget {
  final List<String> labels;

  const _QTMultiImageGrid({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels
          .map(
            (label) => Container(
              width: (350 - 8) / 2,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 30,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QTBottomNavBar extends StatelessWidget {
  const _QTBottomNavBar();

  @override
  Widget build(BuildContext context) {
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
          _bottomButton('上一题', Icons.chevron_left, false),
          _bottomButton('下一题', Icons.chevron_right, true),
        ],
      ),
    );
  }

  Widget _bottomButton(String label, IconData icon, bool primary) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: primary ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: primary ? null : Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (!primary) Icon(icon, size: 18, color: AppColors.textSecondary),
          if (!primary) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: primary ? FontWeight.w600 : FontWeight.w400,
              color: primary ? Colors.white : AppColors.textSecondary,
            ),
          ),
          if (primary) const SizedBox(width: 4),
          if (primary) Icon(icon, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}

enum _QTChoiceState { normal, selected, correct, wrong, missed }

extension _QTChoiceStateStyle on _QTChoiceState {
  Color get color {
    switch (this) {
      case _QTChoiceState.correct:
      case _QTChoiceState.missed:
        return AppColors.success;
      case _QTChoiceState.wrong:
        return AppColors.error;
      case _QTChoiceState.selected:
        return AppColors.primary;
      case _QTChoiceState.normal:
        return AppColors.textSecondary;
    }
  }

  Color get background {
    switch (this) {
      case _QTChoiceState.correct:
      case _QTChoiceState.missed:
        return AppColors.successBg;
      case _QTChoiceState.wrong:
        return AppColors.errorBg;
      case _QTChoiceState.selected:
        return AppColors.primaryBg;
      case _QTChoiceState.normal:
        return AppColors.card;
    }
  }

  Color get border {
    switch (this) {
      case _QTChoiceState.correct:
      case _QTChoiceState.missed:
        return AppColors.success;
      case _QTChoiceState.wrong:
        return AppColors.error;
      case _QTChoiceState.selected:
        return AppColors.primary;
      case _QTChoiceState.normal:
        return AppColors.border;
    }
  }
}

class _QTChoiceData {
  final String label;
  final String text;
  final _QTChoiceState state;

  const _QTChoiceData(this.label, this.text, this.state);
}

enum _ImageTone { primary, error }
