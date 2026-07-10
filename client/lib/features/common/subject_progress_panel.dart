import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_app_store.dart';
import '../../data/mock/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class PracticeProgressPanel extends StatelessWidget {
  final MockAppStore store;
  final EdgeInsetsGeometry? margin;

  const PracticeProgressPanel({
    super.key,
    required this.store,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final stat = store.practiceStat;
    final todayDone = store.practiceRecords
        .where((record) => _isTodayRecord(record.time))
        .fold<int>(0, (sum, record) => sum + _practiceQuestionCount(record));
    final activeDays = _activeDayCount(store.practiceRecords);
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _subjectRow(context, store.selectedSubject.name),
          const SizedBox(height: 8),
          Text(
            '今日新增进度：$todayDone题      已累计练习：$activeDays天',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textBlueHint,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _inlineStat(
                  '练习进度 ${stat.done}/${stat.total}', Alignment.centerLeft),
              _inlineStat('正确率 ${stat.accuracy}%', Alignment.center),
              _inlineStat('错题量 ${stat.wrong}', Alignment.centerRight),
            ],
          ),
          const SizedBox(height: 12),
          _progress(stat.progress),
        ],
      ),
    );
  }
}

class ExamProgressPanel extends StatelessWidget {
  final MockAppStore store;
  final EdgeInsetsGeometry? margin;

  const ExamProgressPanel({
    super.key,
    required this.store,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final stat = store.examStat;
    final todayDone = store.examRecords
        .where((record) => _isTodayRecord(record.time))
        .fold<int>(0, (sum, record) => sum + _examQuestionCount(record));
    final activeDays = _activeDayCount(store.examRecords);
    final passedCount = store.examRecords.where(_isPassedRecord).length;
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _subjectRow(context, store.selectedSubject.name),
          const SizedBox(height: 10),
          Text(
            '今日新增进度：$todayDone题      已累计考核：$activeDays天',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textBlueHint,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _stackedStat('${stat.done}/${stat.total}', '题目覆盖')),
              Expanded(
                  child: _stackedStat('${store.examRecords.length}次', '考试次数')),
              Expanded(child: _stackedStat('$passedCount次', '通过次数')),
              Expanded(child: _stackedStat('${stat.accuracy}%', '总正确率')),
            ],
          ),
          const SizedBox(height: 10),
          _progress(stat.progress),
        ],
      ),
    );
  }
}

Widget _subjectRow(BuildContext context, String subjectName) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          subjectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => context.push('/practice/switch-subject'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                '切换科目',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _inlineStat(String text, Alignment alignment) {
  return Expanded(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget _stackedStat(String value, String label) {
  return Column(
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.72),
        ),
      ),
    ],
  );
}

Widget _progress(double value) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: 8,
      backgroundColor: Colors.white.withValues(alpha: 0.25),
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
    ),
  );
}

bool _isTodayRecord(String time) {
  return time == '刚刚' ||
      time.contains('分钟前') ||
      time.contains('小时前') ||
      time.startsWith('今天');
}

int _activeDayCount(List<StudyRecord> records) {
  if (records.isEmpty) return 0;
  return records
      .map((record) {
        final time = record.time;
        if (time == '刚刚' || time.contains('分钟前') || time.contains('小时前')) {
          return '今天';
        }
        return time.split(' ').first;
      })
      .toSet()
      .length;
}

int _practiceQuestionCount(StudyRecord record) {
  final match = RegExp(r'(\d+)/(\d+)题').firstMatch(record.metric);
  return int.tryParse(match?.group(1) ?? '') ??
      record.practiceDetail?.answers.length ??
      0;
}

int _examQuestionCount(StudyRecord record) {
  final detail = record.examDetail;
  if (detail != null) {
    return {...detail.answers.keys, ...detail.textAnswers.keys}.length;
  }
  final match = RegExp(r'(\d+)/(\d+)题').firstMatch(record.metric);
  return int.tryParse(match?.group(1) ?? '') ??
      (record.metric.contains('未交卷') ? 0 : 1);
}

bool _isPassedRecord(StudyRecord record) {
  if (record.metric.contains('未交卷')) return false;
  final score = RegExp(r'(\d+)分').firstMatch(record.metric);
  final accuracy = RegExp(r'正确率\s*(\d+)%').firstMatch(record.metric);
  final value = int.tryParse(score?.group(1) ?? accuracy?.group(1) ?? '');
  return value != null && value >= 60;
}
