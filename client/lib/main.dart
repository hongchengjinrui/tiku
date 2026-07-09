import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/mock/mock_app_store.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  unawaited(appStore.hydrateRemote());
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
