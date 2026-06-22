import 'package:flutter/material.dart';
import 'select_semester_screen.dart';

class SelectCourseScreen extends StatelessWidget {
  const SelectCourseScreen({super.key});

  final List<String> courses = const ["B.Sc Computer Science", "B.Sc Information Tech", "B.Sc Data Science"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Course"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What are you studying?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Select your program at Mumbai University", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEBF4FF),
                        child: Icon(Icons.computer, color: Color(0xFF5A67D8)),
                      ),
                      title: Text(courses[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SelectSemesterScreen(courseName: courses[index])),
                        );
                      },
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