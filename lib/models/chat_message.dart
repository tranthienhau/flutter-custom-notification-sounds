enum SenderKind { user, support, system }

class ChatMessage {
  final String id;
  final SenderKind from;
  final String body;
  final DateTime ts;
  final String? meetingUrl;

  const ChatMessage({
    required this.id,
    required this.from,
    required this.body,
    required this.ts,
    this.meetingUrl,
  });

  bool get isMeetingLink => meetingUrl != null;
}
