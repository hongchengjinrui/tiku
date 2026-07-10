import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';
import '../resources/p40_resource_center_page.dart';

/// P54 题目纠错页
class P54FeedbackPage extends StatefulWidget {
  const P54FeedbackPage({super.key});

  @override
  State<P54FeedbackPage> createState() => _P54FeedbackPageState();
}

class _P54FeedbackPageState extends State<P54FeedbackPage> {
  int _selectedType = 0;
  final _types = ['题干有误', '选项有误', '答案有误', '解析有误', '整题逻辑有误'];
  final _typeValues = [
    'stem_error',
    'option_error',
    'answer_error',
    'analysis_error',
    'logic_error',
  ];
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '题目纠错'),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    const Text('反馈类型',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_types.length, (i) {
                        final selected = i == _selectedType;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  selected ? AppColors.primary : AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border),
                            ),
                            child: Text(_types[i],
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('反馈内容',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          const Text(
                            '请说明具体错误位置和你认为正确的内容，便于核对修正。',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: '请描述题干、选项、答案或解析中的具体问题...',
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '提交后会进入题目纠错队列，处理结果将在后续版本中同步。',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _submitting ? null : _submitCorrection,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _submitting
                              ? null
                              : const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.primaryDark,
                                  ],
                                ),
                          color: _submitting ? AppColors.border : null,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: Text(_submitting ? '提交中...' : '提交纠错',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCorrection() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写具体问题')),
      );
      return;
    }
    setState(() => _submitting = true);
    final ok = await mockStore.submitFeedback(
      content: content,
      type: _typeValues[_selectedType],
      payload: {
        'source': 'profile_correction',
        'label': _types[_selectedType],
      },
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '纠错已提交' : '提交失败，请稍后重试')),
    );
  }
}

/// P55 题库维护说明页
class P55UploadBankPage extends StatelessWidget {
  const P55UploadBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '题库维护'),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // 上传概览卡
                    Container(
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
                        children: const [
                          Text('题库维护入口',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          SizedBox(height: 10),
                          Text('题库内容统一在中台维护，客户端仅展示与反馈',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textBlueHint)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('题库增删改请在中台维护')),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.admin_panel_settings_outlined,
                                size: 48, color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('当前 APP 不直接上传题库',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 6),
                            Text('如需新增题库、章节或题目，请通过中台处理',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 导入规则卡
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('维护规则',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 10),
                          Text(
                              '1. 目录树、题目、答案解析由中台统一管理\n2. 用户端发现题目问题后，可通过题目纠错反馈\n3. 资料与封面上传也在中台维护',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  height: 1.8,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 上传记录卡
                    Container(
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
                          const Text('维护反馈',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.feedback_outlined,
                                size: 20, color: AppColors.primary),
                            title: const Text('提交题库维护建议',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textPrimary)),
                            subtitle: const Text('错别字、题目缺失、章节异常等都可以反馈',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.textMuted)),
                            trailing: const Icon(Icons.chevron_right,
                                size: 18, color: AppColors.textMuted),
                            contentPadding: EdgeInsets.zero,
                            onTap: () => context.push('/profile/feedback'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P56 意见反馈页
class P56FeedbackPage extends StatefulWidget {
  const P56FeedbackPage({super.key});

  @override
  State<P56FeedbackPage> createState() => _P56FeedbackPageState();
}

class _P56FeedbackPageState extends State<P56FeedbackPage> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '意见反馈'),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    const Text('反馈内容',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      height: 180,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: '请输入您的意见或建议...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _submitting ? null : _submitFeedback,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _submitting
                              ? null
                              : const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryLight,
                                    AppColors.primaryDark,
                                  ],
                                ),
                          color: _submitting ? AppColors.border : null,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send,
                                size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(_submitting ? '提交中...' : '提交反馈',
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写反馈内容')),
      );
      return;
    }
    setState(() => _submitting = true);
    final ok = await mockStore.submitFeedback(
      content: content,
      type: 'app_feedback',
      payload: const {'source': 'profile_feedback'},
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '反馈已提交' : '提交失败，请稍后重试')),
    );
  }
}

/// P56A 反馈记录页
class P56AFeedbackRecordsPage extends StatelessWidget {
  const P56AFeedbackRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '反馈记录'),
            Expanded(
              child: AnimatedBuilder(
                animation: mockStore,
                builder: (context, _) {
                  final feedbacks = mockStore.feedbackSubmissions;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(context, feedbacks.length),
                        const SizedBox(height: 14),
                        if (feedbacks.isEmpty)
                          _buildEmptyState(context)
                        else
                          _buildFeedbackList(context, feedbacks),
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

  Widget _buildSummaryCard(BuildContext context, int count) {
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
              Icons.rate_review_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count 条待同步反馈',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('联网并同步缓存后，会自动尝试提交到服务端。',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 10),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _confirmClearFeedback(context),
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('清空',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
              ),
            ),
          ],
        ],
      ),
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
          const Icon(Icons.mark_email_read_outlined,
              size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('暂无待同步反馈',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('题目纠错和意见反馈提交后，会在离线或服务端不可用时暂存在这里。',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textMuted)),
          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/profile/feedback'),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('去反馈',
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

  Widget _buildFeedbackList(
    BuildContext context,
    List<FeedbackSubmission> feedbacks,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedbacks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildFeedbackCard(context, feedbacks[index]),
    );
  }

  Widget _buildFeedbackCard(
    BuildContext context,
    FeedbackSubmission feedback,
  ) {
    final label = _feedbackTypeLabel(feedback);
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_formatTime(feedback.createdAt),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(feedback.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textPrimary)),
          if (_payloadText(feedback).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_payloadText(feedback),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted)),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _confirmRemoveFeedback(context, feedback),
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 15, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text('移除',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveFeedback(
    BuildContext context,
    FeedbackSubmission feedback,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('移除这条反馈？'),
        content: const Text('移除后仅从本机待同步列表中删除，不会影响已经提交到服务端的内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await mockStore.removeFeedbackSubmission(feedback);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '反馈记录已移除' : '移除失败，请稍后重试')),
    );
  }

  Future<void> _confirmClearFeedback(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清空待同步反馈？'),
        content: const Text('将清空当前本机保存的全部待同步反馈记录，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('再想想'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await mockStore.clearFeedbackSubmissions();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '待同步反馈已清空' : '清空失败，请稍后重试')),
    );
  }

  String _feedbackTypeLabel(FeedbackSubmission feedback) {
    final label = feedback.payload['label']?.toString();
    if (label != null && label.trim().isNotEmpty) return label.trim();
    return switch (feedback.type) {
      'stem_error' => '题干有误',
      'option_error' => '选项有误',
      'answer_error' => '答案有误',
      'analysis_error' => '解析有误',
      'logic_error' => '整题逻辑有误',
      'image_error' => '图片问题',
      'app_feedback' => '意见反馈',
      'question_feedback' => '题目纠错',
      _ => '其他反馈',
    };
  }

  String _payloadText(FeedbackSubmission feedback) {
    final questionId = feedback.payload['questionId']?.toString();
    if (questionId != null && questionId.isNotEmpty) {
      return '关联题目：$questionId';
    }
    final source = feedback.payload['source']?.toString();
    if (source != null && source.isNotEmpty) return '来源：$source';
    return '';
  }

  String _formatTime(DateTime time) {
    if (time.millisecondsSinceEpoch <= 0) return '待同步';
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

/// P57 关于页面
class P57AboutPage extends StatelessWidget {
  const P57AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '关于我们'),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    // App Icon
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryLight, AppColors.primary],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.menu_book,
                          size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 22),
                    const Text('题库母版',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('版本号 V1.0.0',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    const Text('专注章节练习、模拟考试与错题复习的轻量题库工具。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    // 菜单卡片
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            dense: true,
                            title: const Text('用户协议',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: AppColors.textPrimary)),
                            trailing: const Icon(Icons.chevron_right,
                                size: 18, color: AppColors.textMuted),
                            onTap: () => context.push('/agreement/user'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            dense: true,
                            title: const Text('隐私协议',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: AppColors.textPrimary)),
                            trailing: const Icon(Icons.chevron_right,
                                size: 18, color: AppColors.textMuted),
                            onTap: () => context.push('/agreement/privacy'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            dense: true,
                            title: const Text('检查更新',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: AppColors.textPrimary)),
                            trailing: const Text('V1.0.0',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textMuted)),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('当前已是最新版本')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Copyright © 2026 题库母版',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P58 登录页
class P58LoginPage extends StatelessWidget {
  const P58LoginPage({super.key});

  static const _placeholderMessage = '登录能力将在上架前接入，当前使用本地游客模式';

  void _showLoginPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(_placeholderMessage)),
    );
  }

  void _closeToProfile(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go('/profile');
  }

  void _continueAsGuest(BuildContext context) {
    _showLoginPlaceholder(context);
    context.go('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            // Nav with close
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _closeToProfile(context),
                child: const Icon(Icons.close,
                    size: 24, color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // 品牌
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.menu_book,
                          size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text('题库母版',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 32),
                    // 手机号输入
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '请输入手机号',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 验证码输入
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '验证码',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _showLoginPlaceholder(context),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('获取验证码',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: AppColors.primary)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 登录按钮
                    GestureDetector(
                      onTap: () => _continueAsGuest(context),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('登录 / 注册',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 第三方登录
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _showLoginPlaceholder(context),
                          child: const Icon(Icons.wechat,
                              size: 40, color: AppColors.success),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _showLoginPlaceholder(context),
                          child: const Icon(Icons.account_balance_wallet,
                              size: 40, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _continueAsGuest(context),
                      child: const Text('游客登录',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P58A 一键登录页
class P58AQuickLoginPage extends StatelessWidget {
  const P58AQuickLoginPage({super.key});

  static const _placeholderMessage = '登录能力将在上架前接入，当前使用本地游客模式';

  void _showLoginPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(_placeholderMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.menu_book,
                          size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text('一键登录',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('138****8888',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => _showLoginPlaceholder(context),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('一键绑定登录',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text('其他方式登录',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P59 VIP开通页 (别名)
class P59VipPage extends P41AVipPage {
  const P59VipPage({super.key});
}

/// P60 会员服务协议页 / P61 用户协议页 / P62 隐私协议页 - 共用模板
class P60AgreementPage extends StatelessWidget {
  final String title;
  final List<String> sections;

  const P60AgreementPage({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            NavBar(title: title),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    // 摘要卡
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$title - 摘要',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          Text('本协议描述了应用的使用条款、权利义务、隐私保护等内容，请仔细阅读。',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  height: 1.6,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 条款列表
                    ...sections.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final section = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
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
                              Text('第${idx}条 $section',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              const Text('详细条款内容将在实际使用中替换为完整的法律文本描述...',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      height: 1.6,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 记录删除确认弹窗 (P51A/P51B/P52A/P52B)
class RecordDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const RecordDeleteDialog({
    super.key,
    this.title = '确认删除？',
    this.message = '删除后不可恢复，是否确认？',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700)),
      content: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary)),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: const Text('确认', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}
