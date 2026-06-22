import 'package:flutter/material.dart';

class PlacementScreen extends StatelessWidget {
  const PlacementScreen({super.key});

  final List<Map<String, dynamic>> prepTopics = const [
    {"title": "Python Interview Q&A", "icon": Icons.code, "color": Colors.blue},
    {"title": "SQL Interview Q&A", "icon": Icons.storage, "color": Colors.orange},
    {"title": "Statistics Q&A", "icon": Icons.bar_chart, "color": Colors.green},
    {"title": "Data Science Q&A", "icon": Icons.science_outlined, "color": Colors.purple},
    {"title": "Aptitude Tests", "icon": Icons.calculate_outlined, "color": Colors.teal},
    {"title": "Resume Tips", "icon": Icons.document_scanner_outlined, "color": Colors.redAccent},
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Interview Preparation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Master these topics to ace your placements.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: prepTopics.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Opening ${prepTopics[index]['title']}...")),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: prepTopics[index]["color"].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                prepTopics[index]["icon"],
                                color: prepTopics[index]["color"],
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              prepTopics[index]["title"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}