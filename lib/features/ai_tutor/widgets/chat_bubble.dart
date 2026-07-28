import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // 🚀 IMPORT DAALNA MAT BHOOLNA

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF5A67D8) : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
        ),
        // 🚀 TEXT WIDGET KI JAGAH MARKDOWNBODY LAGA DIYA
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(
            // Normal Text ka color
            p: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
            // Bold (**text**) wale text ka color aur style
            strong: TextStyle(color: isUser ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
            // Agar AI points me answer de (bullets)
            listBullet: TextStyle(color: isUser ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}