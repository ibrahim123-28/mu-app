import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';

// 1. Message Model: Har message store karne ke liye structure
class ChatMessage {
  final String text;
  final bool isUser; // True matlab User ka message, False matlab Nexus AI ka message

  ChatMessage({required this.text, required this.isUser});
}

// 2. Chat State: Messages ki list aur loading indicator ki state
class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  AiChatState({required this.messages, this.isLoading = false});

  AiChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 3. Service Provider: Service class ka instance create karne ke liye
final aiServiceProvider = Provider((ref) => AiService());

// 4. Notifier: Modern Riverpod 2.0 approach jo UI ko update karega
class AiChatNotifier extends Notifier<AiChatState> {
  
  // build() method initial state set karta hai
  @override
  AiChatState build() {
    return AiChatState(messages: [
      ChatMessage(
        text: "System Initialized. I am Nexus, your B.Sc Computer Science Tutor. What is your query today?", 
        isUser: false
      )
    ]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Step A: User ka message add karo aur loading true kardo
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(text: text, isUser: true)],
      isLoading: true,
    );

    // Modern Riverpod me hum provider ke andar hi ref.read use kar sakte hain
    final aiService = ref.read(aiServiceProvider);

    // Step B: Gemini API ko call karo
    final response = await aiService.sendMessage(text);

    // Step C: AI ka reply add karo aur loading false kardo
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(text: response, isUser: false)],
      isLoading: false,
    );
  }
}

// 5. Main Chat Provider jisko hum apni UI screen me ref.watch karenge
final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(() {
  return AiChatNotifier();
});