import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardScreen extends StatefulWidget {
  final String topicId;
  final String title; // 🚀 Yahan humne 'title' rakha hai

  const FlashcardScreen({
    super.key, 
    required this.topicId, 
    required this.title,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool isFlipped = false;

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void _nextQuestion(int totalLength) {
    if (currentIndex < totalLength - 1) {
      setState(() {
        isFlipped = false;
        currentIndex++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 You've completed all questions!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context); // Wapas dashboard par chale jayenge
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF5A67D8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // 🚀 FIREBASE SE DATA FETCH KAR RAHE HAIN
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('placement_materials').doc(widget.topicId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Questions coming soon! 🚀", style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;
          List<dynamic> questions = data?['questions'] ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text("No questions added for this topic yet."));
          }

          final currentQ = questions[currentIndex];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress Counter
                Text(
                  "Question ${currentIndex + 1} of ${questions.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 24),

                // 🚀 3D FLIP CARD
                GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                      return AnimatedBuilder(
                        animation: rotate,
                        child: child,
                        builder: (context, child) {
                          final angle = (ValueKey(isFlipped) != child!.key) ? min(rotate.value, pi / 2) : rotate.value;
                          return Transform(
                            transform: Matrix4.rotationY(angle),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                      );
                    },
                    child: isFlipped
                        ? _buildCardSide(
                            key: const ValueKey(true),
                            title: "💡 Answer",
                            content: currentQ['a'] ?? "",
                            color: Colors.green.shade50,
                            textColor: Colors.green.shade900,
                          )
                        : _buildCardSide(
                            key: const ValueKey(false),
                            title: "🤔 Question",
                            content: currentQ['q'] ?? "",
                            color: Colors.white,
                            textColor: Colors.black87,
                          ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // NEXT BUTTON / TIP
                isFlipped
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _nextQuestion(questions.length),
                        child: const Text("Next Question ➡️", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    : Text(
                        "Tap the card to reveal the answer",
                        style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                      )
              ],
            ),
          );
        },
      ),
    );
  }

  // Card UI Helper
  Widget _buildCardSide({required Key key, required String title, required String content, required Color color, required Color textColor}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withOpacity(0.5), fontSize: 16, letterSpacing: 1.5),
          ),
          const SizedBox(height: 20),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}