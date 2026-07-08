import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// P25 考试答题页 - Exam answering page
class P25ExamAnsweringPage extends StatefulWidget {
  const P25ExamAnsweringPage({super.key});

  @override
  State<P25ExamAnsweringPage> createState() => _P25ExamAnsweringPageState();
}

class _P25ExamAnsweringPageState extends State<P25ExamAnsweringPage> {
  int _selectedOption = 1; // B selected
  int _currentQuestion = 18;
  final int _totalQuestions = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        width: 390,
        child: Column(
          children: [
            _buildNavBar(),
            _buildProgressArea(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '在电气设备运行中，以下哪种情况不需要立即切断电源？',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOption(0, 'A', '设备发出异常声响'),
                    const SizedBox(height: 10),
                    _buildOption(1, 'B', '设备外壳温度略有升高'),
                    const SizedBox(height: 10),
                    _buildOption(2, 'C', '闻到焦糊气味'),
                    const SizedBox(height: 10),
                    _buildOption(3, 'D', '设备冒烟'),
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

  Widget _buildNavBar() {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text('组卷考试',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ),
          Positioned(
            left: 16,
            top: 8,
            child: GestureDetector(
              child: Container(
                width: 58,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: const Center(
                  child: Text('交卷',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text('第 $_currentQuestion / $_totalQuestions 题',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              const Spacer(),
              Container(
                width: 64,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text('单选题',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _currentQuestion / _totalQuestions,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text('剩余 72:36',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String label, String text) {
    final selected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBg : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Center(child: Icon(Icons.check, size: 12, color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 12),
            Text('$label.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                )),
            const SizedBox(width: 4),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.chevron_left, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text('上一题',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.grid_view, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text('答题卡',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text('下一题',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
