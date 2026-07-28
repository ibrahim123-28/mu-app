import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 

import 'subject_detail_screen.dart';
import '../../core/services/auth_service.dart'; 

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  // 🚀 FIX: Isko null rakha hai taaki Firebase se value aane par set ho sake
  String? selectedSem;

  final List<String> semesters = ["Sem 1", "Sem 2", "Sem 3", "Sem 4", "Sem 5", "Sem 6", "Sem 7", "Sem 8"];

  final Map<String, Map<String, List<String>>> allCoursesData = {
    "B.Sc Computer Science": {
      "Sem 1": ["Digital Systems & Architecture", "Fundamentals of Database Systems", "Introduction to Programming with Python", "Statistics with R Programming", "Linux Operating System"],
      "Sem 2": ["Design & Analysis of Algorithms", "Object Oriented Programming", "Web Technologies", "Database Management Systems using PL/SQL", "Advanced Python Programming"],
      "Sem 3": ["Principles of Operating Systems", "Theory of Computation", "Data Structures", "Java Programming"],
      "Sem 4": ["Computer Networks", "Software Engineering", "IoT Technologies", "Mobile Application Development", "MEAN Stack Development"],
      "Sem 5": ["Artificial Intelligence", "Cyber & Information Security", "Moral & Ethical AI", "Ethical Hacking", "Software Testing & Quality Assurance", "Wireless & Sensor Networks"],
      "Sem 6": ["Data Science", "Cloud Computing", "Software Project Management", "Information Retrieval", "Linux Server Administration"],
    },
    "B.Sc Information Tech": {
      "Sem 1": ["Imperative Programming", "Digital Electronics", "Operating Systems", "Discrete Mathematics"],
      "Sem 2": ["Object Oriented Programming", "Microprocessor Architecture", "Web Programming", "Numerical Methods"],
      "Sem 3": ["Python Programming", "Data Structures", "Computer Networks", "Database Management Systems"],
      "Sem 4": ["Core Java", "Introduction to Embedded Systems", "Computer Oriented Statistical Techniques", "Software Engineering"],
    },
    "B.Sc Data Science": {
      "Sem 1": ["Descriptive Statistics", "Introduction to Programming", "Web Technologies", "Business Communication"],
      "Sem 2": ["Probability & Distributions 1", "Database Management", "R Programming", "Environmental Science"],
      "Sem 3": ["Linear Algebra", "Data Structures in Python", "Data Warehousing", "Economics"],
      "Sem 4": ["Probability & Distributions 2", "Advanced Python", "Statistics for Data Science", "Advanced DBMS"],
    }
  };

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (userDoc) {
        final userData = userDoc?.data() as Map<String, dynamic>?;
        final userCourse = userData?['course'] ?? "B.Sc Computer Science"; 
        
        // 🚀 THE MAGIC: Fetch actual semester from database
        final actualUserSem = userData?['semester'] ?? "Sem 1"; 

        // 🚀 Agar selectedSem abhi tak null hai (first load), toh user ka original sem set kar do
        selectedSem ??= actualUserSem;

        final courseSubjectsMap = allCoursesData[userCourse] ?? {};
        List<String> currentSubjects = courseSubjectsMap[selectedSem] ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text("Notes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSem, // 🚀 Uses the dynamically set semester
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5A67D8)),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSem = newValue!; // Updates if user manually changes it
                        });
                      },
                      items: semesters.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: currentSubjects.isEmpty 
                  ? Center(child: Text("No subjects added for $selectedSem yet."))
                  : ListView.builder(
                    itemCount: currentSubjects.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF4FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.description_outlined, color: Color(0xFF5A67D8)),
                          ),
                          title: Text(currentSubjects[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => SubjectDetailScreen(subjectName: currentSubjects[index]),
                              ),
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
    );
  }
}