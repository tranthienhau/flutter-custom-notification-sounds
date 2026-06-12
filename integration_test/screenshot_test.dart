import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_custom_notification_sounds/models/chat_message.dart';
import 'package:flutter_custom_notification_sounds/providers/chat_provider.dart';
import 'package:flutter_custom_notification_sounds/screens/login_screen.dart';
import 'package:flutter_custom_notification_sounds/screens/chat_screen.dart';

// A seeded conversation so the chat screen shows real-looking content,
// including a tappable meeting link bubble (loud-ringtone notification demo).
class _SeededChatNotifier extends ChatNotifier {
  _SeededChatNotifier() {
    state = [
      ChatMessage(
        id: 's1',
        from: SenderKind.support,
        body: 'Hi, how can we help you today?',
        ts: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: 'u1',
        from: SenderKind.user,
        body: 'My payment did not go through.',
        ts: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
      ChatMessage(
        id: 's2',
        from: SenderKind.support,
        body: 'Thanks, I can see the failed charge. Let me start a quick call.',
        ts: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      ChatMessage(
        id: 's3',
        from: SenderKind.support,
        body: 'Tap to join: https://meet.example.com/abc',
        ts: DateTime.now().subtract(const Duration(minutes: 5)),
        meetingUrl: 'https://meet.example.com/abc',
      ),
      ChatMessage(
        id: 'u2',
        from: SenderKind.user,
        body: 'Joining now, thanks!',
        ts: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  Widget wrap(Widget child) => ProviderScope(
        overrides: [
          chatProvider.overrideWith((ref) => _SeededChatNotifier()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
            useMaterial3: true,
          ),
          home: child,
        ),
      );

  testWidgets('capture support chat flow', (tester) async {
    // 01 - login screen
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    await shoot(tester, '01-login');

    // 02 - seeded support conversation with meeting-link bubble
    await tester.pumpWidget(wrap(const ChatScreen()));
    await tester.pumpAndSettle();
    await shoot(tester, '02-chat');

    // 03 - user types a new message into the composer
    await tester.enterText(
      find.byType(TextField),
      'Can you resend the invoice?',
    );
    await tester.pumpAndSettle();
    await shoot(tester, '03-compose');
  });
}
