import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardScreen extends StatefulWidget {
  final String topicId;
  final String title;

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
        const SnackBar(
          content: Text("🎉 You've completed all questions!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
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
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // 🚀 FUTURE KI JAGAH STREAMBUILDER (Realtime live updates)
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('placement_materials')
            .doc(widget.topicId.trim())
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          // 2. Error State (Security Rules / Network error catch karega)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Firebase Error: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          // 3. Document check
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    "Topic '${widget.topicId}' not found in database!",
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>?;
          List<dynamic> questions = data?['questions'] ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text("No questions added for this topic yet."));
          }

          // Index safety check
          if (currentIndex >= questions.length) {
            currentIndex = 0;
          }

          final currentQ = questions[currentIndex] as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress Counter
                Text(
                  "Question ${currentIndex + 1} of ${questions.length}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 16,
                  ),
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
                          final angle = (ValueKey(isFlipped) != child!.key)
                              ? min(rotate.value, pi / 2)
                              : rotate.value;
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
                            content: currentQ['a']?.toString() ?? "No answer provided",
                            color: Colors.green.shade50,
                            textColor: Colors.green.shade900,
                          )
                        : _buildCardSide(
                            key: const ValueKey(false),
                            title: "🤔 Question",
                            content: currentQ['q']?.toString() ?? "No question text",
                            color: Colors.white,
                            textColor: Colors.black87,
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                // NEXT BUTTON / INSTRUCTION
                isFlipped
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _nextQuestion(questions.length),
                        child: const Text(
                          "Next Question ➡️",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
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

  Widget _buildCardSide({
    required Key key,
    required String title,
    required String content,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280, maxHeight: 380),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor.withValues(alpha: 0.6),
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}