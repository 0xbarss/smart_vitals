enum MessageRole { user, model }

class ChatMessage {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
  });
}