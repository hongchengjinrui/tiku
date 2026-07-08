import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/main.dart';
import 'package:tiku_muban/routes/app_router.dart';

void main() {
  const previews = {
    '/practice': 'previews/01_practice_home.png',
    '/practice/catalog': 'previews/02_practice_catalog.png',
    '/practice/sections': 'previews/03_practice_sections.png',
    '/exam': 'previews/04_exam_home.png',
    '/exam/assemble': 'previews/05_exam_assemble.png',
    '/resources': 'previews/06_resources_home.png',
    '/resources/paid': 'previews/07_resource_paid_preview.png',
    '/profile': 'previews/08_profile_home.png',
  };

  for (final entry in previews.entries) {
    testWidgets('preview ${entry.key}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(const TikuApp());
      appRouter.go(entry.key);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(find.byType(TikuApp), matchesGoldenFile(entry.value));
      await tester.binding.setSurfaceSize(null);
    });
  }
}
