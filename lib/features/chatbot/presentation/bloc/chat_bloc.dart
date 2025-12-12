import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final List<ChatMessage> _messages = [];

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);

    _messages.add(
      ChatMessage(
        id: 'init',
        text:
            "Hello! I'm your SmartVitals assistant. How can I help you today?",
        role: MessageRole.model,
        timestamp: DateTime.now(),
      ),
    );

    emit(ChatLoaded(messages: List.from(_messages)));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: event.message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    emit(ChatLoaded(messages: List.from(_messages), isTyping: true));

    try {
      final responseText = await repository.sendMessage(
        event.message,
        _messages.sublist(0, _messages.length - 1),
      );

      final aiMsg = ChatMessage(
        id: const Uuid().v4(),
        text: responseText,
        role: MessageRole.model,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMsg);

      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    } catch (e) {
      emit(ChatError("Failed to get response: $e"));
      emit(ChatLoaded(messages: List.from(_messages), isTyping: false));
    }
  }
}
