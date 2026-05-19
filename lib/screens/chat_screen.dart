import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationService.instance.meetingUrlStream.listen((url) {
      ref.read(chatProvider.notifier).receiveMeetingLink(url);
      _openMeeting(url);
    });
  }

  Future<void> _openMeeting(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    ref.read(chatProvider.notifier).send(t);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) => _bubble(messages[i]),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage m) {
    final mine = m.from == SenderKind.user;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: m.isMeetingLink ? () => _openMeeting(m.meetingUrl!) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: mine
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.black12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (m.isMeetingLink) ...[
                const Icon(Icons.videocam, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
              ],
              Flexible(child: Text(m.body)),
            ],
          ),
        ),
      ),
    );
  }
}
