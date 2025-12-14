import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../injection_container.dart' as di;
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../domain/entities/chat_message.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final bool isHighContrast = settings.highContrast;

        final Color bgColor = isHighContrast ? Colors.black : Colors.white;
        final Color appBarColor = isHighContrast
            ? Colors.grey[900]!
            : Colors.white;
        final Color appBarText = isHighContrast
            ? Colors.yellowAccent
            : Colors.black;

        return BlocProvider(
          create: (context) => di.sl<ChatBloc>(),
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: const Text("Health Assistant"),
              backgroundColor: appBarColor,
              foregroundColor: appBarText,
              elevation: 1,
              iconTheme: IconThemeData(color: appBarText),
            ),
            body: ChatView(isHighContrast: isHighContrast),
          ),
        );
      },
    );
  }
}

class ChatView extends StatefulWidget {
  final bool isHighContrast;

  const ChatView({super.key, required this.isHighContrast});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(_controller.text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHC = widget.isHighContrast;

    return Column(
      children: [
        Expanded(
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded) {
                Future.delayed(
                  const Duration(milliseconds: 100),
                  _scrollToBottom,
                );
              }
            },
            builder: (context, state) {
              if (state is ChatInitial) {
                return Center(
                  child: CircularProgressIndicator(
                    color: isHC ? Colors.yellowAccent : null,
                  ),
                );
              }
              if (state is ChatLoaded) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length && state.isTyping) {
                      return _buildTypingIndicator(isHC);
                    }
                    return _buildMessageBubble(state.messages[index], isHC);
                  },
                );
              }
              if (state is ChatError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Error: ${state.message}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isHC ? Colors.grey[800] : null,
                            foregroundColor: isHC ? Colors.white : null,
                          ),
                          onPressed: () {
                            context.read<ChatBloc>().add(
                              SendMessageEvent("Hello"),
                            );
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: Text("Something went wrong."));
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHC ? Colors.grey[900] : Colors.white,
            border: isHC
                ? const Border(top: BorderSide(color: Colors.white24))
                : null,
            boxShadow: isHC
                ? null
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: isHC ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Ask about your vitals...",
                    hintStyle: TextStyle(
                      color: isHC ? Colors.white54 : Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: isHC
                          ? const BorderSide(color: Colors.white)
                          : BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isHC ? Colors.black : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: isHC
                    ? Colors.yellowAccent
                    : const Color(0xFF2563EB),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: isHC ? Colors.black : Colors.white,
                  ),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator(bool isHC) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isHC ? Colors.grey[800] : Colors.grey.shade200,
          border: isHC ? Border.all(color: Colors.white24) : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.zero,
          ),
        ),
        child: TypingDots(isHighContrast: isHC),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isHC) {
    final isUser = message.role == MessageRole.user;

    final userBg = isHC ? Colors.black : const Color(0xFF2563EB);
    final botBg = isHC ? Colors.grey[900] : Colors.grey.shade200;

    final border = isHC
        ? Border.all(color: isUser ? Colors.yellowAccent : Colors.white54)
        : null;

    final userText = isHC ? Colors.yellowAccent : Colors.white;
    final botText = isHC ? Colors.white : Colors.black;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? userBg : botBg,
          border: border,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: isUser
            ? Text(message.text, style: TextStyle(color: userText))
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: botText),
                  listBullet: TextStyle(color: botText),
                  strong: TextStyle(
                    color: botText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}

class TypingDots extends StatefulWidget {
  final bool isHighContrast;

  const TypingDots({super.key, this.isHighContrast = false});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 4),
        _buildDot(0.2),
        const SizedBox(width: 4),
        _buildDot(0.4),
      ],
    );
  }

  Widget _buildDot(double delay) {
    final dotColor = widget.isHighContrast ? Colors.white : Colors.grey;

    return FadeTransition(
      opacity:
          TweenSequence([
            TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
            TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
          ]).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(delay, 1.0, curve: Curves.easeInOut),
            ),
          ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
    );
  }
}
