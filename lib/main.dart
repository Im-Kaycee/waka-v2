import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_service.dart';
import 'models/landmark.dart';
import 'models/correction.dart';
import 'models/route_result.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(
    const ProviderScope(
      child: WakaApp(),
    ),
  );
}

class WakaApp extends StatelessWidget {
  const WakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Waka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF283618),
        brightness: Brightness.light,
      ),
      fontFamily: 'SpaceGrotesk',
      useMaterial3: false, // kill Material 3 — it fights neobrutalism
    ),
      routerConfig: appRouter,
    );
  }
}