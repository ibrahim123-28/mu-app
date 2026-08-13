import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // TODO: Google AI Studio se free API key nikal kar yahan daal dena
  // Pro Tip: Production me isko .env file me hide karke rakhna
  static String _apiKey = 'AQ.Ab8RN6KPuUneIqn6Q7u-AyGkpcqZsBd5UJPEB77BQWNpaXFyhw';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AiService() {
    // Nexus framework initialization
    _model = GenerativeModel(
      model: 'gemini-3.6-flash', // Flash model fast aur chat ke liye best hai
      apiKey: _apiKey,
      systemInstruction: Content.system('''
        You are 'Nexus', an elite, highly strict, and professional B.Sc Computer Science Tutor. 
        Your ONLY purpose is to help students with their university syllabus, programming, mathematics, and tech-related queries.

        STRICT RULES:
        1. NEVER answer questions unrelated to Computer Science, IT, Mathematics, or academics (e.g., no politics, no movies, no recipes, no general chit-chat).
        2. If a user asks an off-topic question, you MUST reply strictly with: "I am your Nexus Study Assistant. I can only assist you with your academic and computer science queries."
        3. Keep answers concise, highly accurate, and formatted using markdown. 
        4. Provide code snippets where necessary, but don't write entire assignments for them—guide them to the solution.
        5. Mirror a professional, slightly strict, but encouraging professor's tone.
      '''),
    );
    
    // startChat() automatically maintains the history of the conversation!
    _chat = _model.startChat();
  }

  // Function to send message and receive answer
  Future<String> sendMessage(String text) async {
    try {
      final response = await _chat.sendMessage(Content.text(text));
      return response.text ?? "Nexus Core Error: Empty response received.";
    } catch (e) {
      return "Nexus System Offline: Unable to connect to servers. Check your internet or API Key. ($e)";
    }
  }
}