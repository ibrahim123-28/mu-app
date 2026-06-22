import 'package:flutter/material.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  String selectedSem = "Sem 4";
  final List<String> semesters = ["Sem 1", "Sem 2", "Sem 3", "Sem 4", "Sem 5", "Sem 6", "Sem 7", "Sem 8"];

  final List<Map<String, dynamic>> testOptions = const [
    {"title": "Chapter Test", "icon": Icons.assignment_outlined, "color": Colors.green},
    {"title": "Subject Test", "icon": Icons.my_library_books_outlined, "color": Colors.blue},
    {"title": "Semester Mock Test", "icon": Icons.school_outlined, "color": Colors.red},
    {"title": "Previous Test Reports", "icon": Icons.bar_chart, "color": Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Tests & Quizzes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Working Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSem,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5A67D8)),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  onChanged: (String? newValue) {
                    setState(() { selectedSem = newValue!; });
                  },
                  items: semesters.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Test Categories List
            Expanded(
              child: ListView.builder(
                itemCount: testOptions.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: testOptions[index]["color"].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(testOptions[index]["icon"], color: testOptions[index]["color"]),
                      ),
                      title: Text(testOptions[index]["title"], style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text("For $selectedSem", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Starting ${testOptions[index]['title']} for $selectedSem")),
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