import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier()
      : super([
          ChatMessage(
            id: 's1',
            from: SenderKind.support,
            body: 'Hi, how can we help you today?',
            ts: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ]);

  void send(String body) {
    state = [
      ...state,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: SenderKind.user,
        body: body,
        ts: DateTime.now(),
      ),
    ];
  }

  void receiveMeetingLink(String url) {
    state = [
      ...state,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: SenderKind.support,
        body: 'Tap to join: $url',
        ts: DateTime.now(),
        meetingUrl: url,
      ),
    ];
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) => ChatNotifier());
