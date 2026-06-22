import 'package:flutter/material.dart';
import 'pyq_list_screen.dart'; // Make sure this is imported

class SubjectDetailScreen extends StatelessWidget {
  final String subjectName;
  
  const SubjectDetailScreen({super.key, required this.subjectName});

  final List<Map<String, dynamic>> resources = const [
    {"title": "Syllabus PDF", "icon": Icons.picture_as_pdf_outlined, "color": Colors.red},
    {"title": "Unit-wise Notes", "icon": Icons.menu_book_outlined, "color": Colors.blue},
    {"title": "University PYQs", "icon": Icons.history_edu_outlined, "color": Colors.orange},
    {"title": "Important Questions", "icon": Icons.star_border_outlined, "color": Colors.amber},
    {"title": "Chapter-wise MCQ", "icon": Icons.fact_check_outlined, "color": Colors.green},
    {"title": "Video Lectures", "icon": Icons.play_circle_outline, "color": Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(subjectName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5A67D8), Color(0xFF8290FA)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Study Resources", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("Master $subjectName", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Detailed Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // LOGIC: Check if the clicked card is "University PYQs"
                        if (resources[index]["title"] == "University PYQs") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Pass the dynamic subjectName instead of hardcoded text
                              builder: (context) => PyqListScreen(subjectName: subjectName),
                            ),
                          );
                        } else {
                          // Default action for other cards
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Loading ${resources[index]['title']} for $subjectName...")),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(resources[index]["icon"], size: 40, color: resources[index]["color"]),
                          const SizedBox(height: 12),
                          Text(
                            resources[index]["title"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
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