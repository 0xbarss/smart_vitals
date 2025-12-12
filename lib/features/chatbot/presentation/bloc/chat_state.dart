import '../../domain/entities/chat_message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatLoaded({required this.messages, this.isTyping = false});
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
