import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<String> sendMessage(String message, List<ChatMessage> history);
}