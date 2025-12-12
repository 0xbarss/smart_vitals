import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/entities/chat_message.dart';

abstract class ChatRemoteDataSource {
  Future<String> generateResponse(String prompt, List<ChatMessage> history);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  late final GenerativeModel _model;

  ChatRemoteDataSourceImpl() {
    const apiKey = 'AIzaSyBiMk6Rapc0fLO_5khK9Eh6E8BE18LrpoI';

    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  @override
  Future<String> generateResponse(
    String prompt,
    List<ChatMessage> history,
  ) async {
    final chatHistory = history.map((msg) {
      if (msg.role == MessageRole.user) {
        return Content.text(msg.text);
      } else {
        return Content.model([TextPart(msg.text)]);
      }
    }).toList();

    final chat = _model.startChat(history: chatHistory);

    final contextPrompt =
        "You are a helpful AI health assistant named SmartVitals Bot. "
        "Keep answers concise, supportive, and related to health/fitness. "
        "If asked about medical emergencies, tell them to call 112 immediately. "
        "User query: $prompt";

    final response = await chat.sendMessage(Content.text(contextPrompt));
    return response.text ?? "I'm having trouble understanding right now.";
  }
}
