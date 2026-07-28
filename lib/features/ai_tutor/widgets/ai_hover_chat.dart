import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // 🚀 YE IMPORT ADD KIYA HAI
import '../providers/ai_provider.dart';

class AiHoverChat extends ConsumerStatefulWidget {
  const AiHoverChat({super.key});

  @override
  ConsumerState<AiHoverChat> createState() => _AiHoverChatState();
}

class _AiHoverChatState extends ConsumerState<AiHoverChat> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _openChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0E15).withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(
                      color: const Color(0xFF00F0FF).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header Handle
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      
                      // AI Status Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00F0FF).withOpacity(0.2),
                                border: Border.all(color: const Color(0xFF00F0FF)),
                              ),
                              child: const Icon(Icons.psychology, color: Color(0xFF00F0FF), size: 20),
                            ),
                            const SizedBox(width: 10),
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "NEXUS ASSISTANT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  "Strict Academic Tutor Active",
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white10),

                      // Chat History List
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final chatState = ref.watch(aiChatProvider);
                            
                            // Scroll to bottom on new message
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: chatState.messages.length,
                              itemBuilder: (context, index) {
                                final msg = chatState.messages[index];
                                return _buildChatBubble(msg);
                              },
                            );
                          },
                        ),
                      ),

                      // Loading Indicator
                      Consumer(
                        builder: (context, ref, child) {
                          final chatState = ref.watch(aiChatProvider);
                          if (!chatState.isLoading) return const SizedBox.shrink();
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF00F0FF),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Nexus is analyzing query...",
                                  style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Input Bar
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                          left: 12,
                          right: 12,
                          top: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: TextField(
                                  controller: _textController,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: "Ask doubt from PDF/Notes...",
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                final text = _textController.text;
                                if (text.trim().isNotEmpty) {
                                  ref.read(aiChatProvider.notifier).sendMessage(text);
                                  _textController.clear();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00F0FF), Color(0xFF7000FF)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00F0FF).withOpacity(0.4),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

 Widget _buildChatBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4), 
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85, // Thoda bada kiya taaki text achhe se aaye
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isUser
              ? const Color(0xFF7000FF).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
            bottomRight: Radius.circular(msg.isUser ? 0 : 16),
          ),
          border: Border.all(
            color: msg.isUser
                ? const Color(0xFF00F0FF).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        // 🚀 THE MAGIC: MARKDOWN BODY INSTEAD OF TEXT WIDGET
        child: MarkdownBody(
          data: msg.text,
          selectable: true, // Baccha code copy kar sakega
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: msg.isUser ? Colors.white : Colors.white70,
              fontSize: 13,
              height: 1.4, // Line spacing thodi achhi ki hai
            ),
            strong: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            h3: const TextStyle(
              color: Color(0xFF00F0FF), // Headings (###) cyan color me aayengi
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            listBullet: const TextStyle(
              color: Colors.white,
            ),
            code: const TextStyle(
              backgroundColor: Colors.black45,
              color: Color(0xFF00F0FF), // Inline code cyan color me highlight hoga
            ),
            codeblockPadding: const EdgeInsets.all(8),
            codeblockDecoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 16,
      child: GestureDetector(
        onTap: () => _openChatBottomSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF00F0FF), Color(0xFF7000FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F0FF).withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "Ask Nexus",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}