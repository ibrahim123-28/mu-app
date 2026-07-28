import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flashcard_screen.dart'; // ✅ Ab isko properly import kar liya hai!

class PlacementDashboard extends ConsumerStatefulWidget {
  const PlacementDashboard({super.key});

  @override
  ConsumerState<PlacementDashboard> createState() => _PlacementDashboardState();
}

class _PlacementDashboardState extends ConsumerState<PlacementDashboard> {
  final Color primaryColor = const Color(0xFF5A67D8);

  // Dummy data (Baad me Firebase se aayega)
  final List<Map<String, dynamic>> topics = [
    {"id": "python_core", "title": "Python Interview Q&A", "icon": Icons.code_rounded, "color": Colors.blue},
    {"id": "sql_dbms", "title": "SQL & DBMS", "icon": Icons.storage_rounded, "color": Colors.orange},
    {"id": "hr", "title": "HR & Soft Skills", "icon": Icons.groups_rounded, "color": Colors.purple},
    {"id": "dsa", "title": "DSA Basics", "icon": Icons.account_tree_rounded, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Placement Prep", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚀 1. INTERVIEW RULES & GUIDELINES SECTION (Top Banner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF818CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.lightbulb_outline, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Golden Interview Rules",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRuleRow("Don't know the answer? Be honest, don't fake it."),
                  _buildRuleRow("Use the STAR method (Situation, Task, Action, Result)."),
                  _buildRuleRow("Think out loud! Interviewers want to see your logic."),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 🚀 2. INTERVIEW PREPARATION GRID
            const Text(
              "Master these topics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return InkWell(
                  onTap: () {
                    // 🚀 NAYI SCREEN PAR BHEJ RAHA HAI (Flashcard Screen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                     builder: (context) => FlashcardScreen(
      topicId: topic['id'],
      title: topic['title'], // 🚀 Bas yahi do lines honi chahiye, 'topicTitle' aur extra text hata de
    ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: topic['color'].withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(topic['icon'], color: topic['color'], size: 36),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            topic['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to display rules cleanly
  Widget _buildRuleRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}