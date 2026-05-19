import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'router.dart';
import 'providers/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase config absent in template; runs without push in dev.
  }
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: SupportChatApp()));
}

class SupportChatApp extends StatelessWidget {
  const SupportChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
