import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/chat_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
  ],
);
