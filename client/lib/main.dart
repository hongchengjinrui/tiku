import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TikuApp()));
}

class TikuApp extends StatelessWidget {
  const TikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '题库',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
