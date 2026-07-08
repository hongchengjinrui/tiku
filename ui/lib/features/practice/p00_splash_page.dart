import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// P00 启动页/闪屏 - 带390x844渐变背景的启动闪屏页
///
/// 包含Logo图标、应用名称、标语、加载进度条和版本号
class P00SplashPage extends StatefulWidget {
  const P00SplashPage({super.key});

  @override
  State<P00SplashPage> createState() => _P00SplashPageState();
}

class _P00SplashPageState extends State<P00SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 390,
        height: 844,
        // 渐变背景 - primaryLight -> primary -> primaryDark, 135度
        decoration: const BoxDecoration(
          gradient: AppGradients.splashGradient,
        ),
        child: Stack(
          children: [
            // Logo 图标 - 104x104 半透明白色圆角容器内放置graduation-cap图标
            Positioned(
              top: 278,
              left: 143,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.school,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            // 应用名称 - "题库母版"
            Positioned(
              top: 404,
              left: 0,
              right: 0,
              child: Text(
                '题库母版',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            // 标语 - "章节练习 · 模拟考试 · 错题复习"
            Positioned(
              top: 448,
              left: 0,
              right: 0,
              child: Text(
                '章节练习 · 模拟考试 · 错题复习',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textBlueHint,
                ),
              ),
            ),

            // 加载进度条 - 宽200, 高4, 圆角2
            Positioned(
              top: 732,
              left: 95,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 版本号 - "V1.0"
            Positioned(
              top: 760,
              left: 0,
              right: 0,
              child: Text(
                'V1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFBFDBFE),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
