import 'package:flutter/material.dart';

import 'p24_exam_assembly_settings_page.dart';

/// P24A 组卷设置-全部章节状态
class P24AAssemblyAllChaptersPage extends StatelessWidget {
  const P24AAssemblyAllChaptersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const P24ExamAssemblySettingsPage(initialScope: 'all');
  }
}
