import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class QuestionMediaImage extends StatefulWidget {
  final String url;
  final Future<bool> Function()? onReportFailure;

  const QuestionMediaImage({
    super.key,
    required this.url,
    this.onReportFailure,
  });

  @override
  State<QuestionMediaImage> createState() => _QuestionMediaImageState();
}

class _QuestionMediaImageState extends State<QuestionMediaImage> {
  bool _reporting = false;
  bool _reported = false;

  bool get _canLoad {
    final uri = Uri.tryParse(widget.url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    if (!_canLoad) return _failureView();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showPreview(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          height: 220,
          color: AppColors.card,
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              final total = progress.expectedTotalBytes;
              return Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: total == null
                        ? null
                        : progress.cumulativeBytesLoaded / total,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _failureView(),
          ),
        ),
      ),
    );
  }

  Widget _failureView() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '图片加载失败，',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed:
                    _reported || _reporting || widget.onReportFailure == null
                        ? null
                        : _reportFailure,
                child: Text(_reporting ? '提交中' : '点击反馈'),
              ),
            ],
          ),
          if (_reported)
            const Text(
              '已静默提交：本题图片未能加载',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _reportFailure() async {
    final callback = widget.onReportFailure;
    if (callback == null) return;
    setState(() => _reporting = true);
    final ok = await callback();
    if (!mounted) return;
    setState(() {
      _reporting = false;
      _reported = ok;
    });
  }

  void _showPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => Material(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      widget.url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        '图片加载失败',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: '关闭预览',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
