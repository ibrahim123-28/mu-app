import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final textColor = isUser ? Colors.white : Colors.black87;
    final codeBgColor = isUser ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF1F5F9);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF5A67D8) : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: MarkdownBody(
          data: text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            // Paragraphs & Basic Text
            p: TextStyle(color: textColor, fontSize: 14.5, height: 1.4),
            strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            listBullet: TextStyle(color: textColor, fontSize: 14),

            // Headings (### Key Technical Specifications)
            h1: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            h2: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            h3: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w700),

            // Inline Code (`CR`, `LF`)
            code: TextStyle(
              color: isUser ? Colors.white : const Color(0xFFE53E3E),
              backgroundColor: codeBgColor,
              fontFamily: 'monospace',
              fontSize: 13,
            ),

            // Multi-line Code Blocks (```python ... ```)
            codeblockDecoration: BoxDecoration(
              color: isUser ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            codeblockPadding: const EdgeInsets.all(10),
          ),
        ),
      ),
    );
  }
}