import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Agar tera PDF viewer kisi aur naam se hai, toh import update kar lena
import 'pdf_viewer_screen.dart'; 

class NotesListScreen extends StatelessWidget {
  final String subjectName;

  const NotesListScreen({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "$subjectName Notes",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        // 🚀 Direct collection path jisse document turant aur bina error ke mil jaye
        future: FirebaseFirestore.instance
            .collection('courses')
            .doc('bsc_cs') // Tera course document ID
            .collection('semesters')
            .doc('sem_1') // Tera semester document ID
            .collection('subjects')
            .where('subjectName', isEqualTo: subjectName)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5A67D8)));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading notes: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Subject not found in database."));
          }

          // Document data nikal rahe hain
          var subjectData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          // Agar 'notes' field database me nahi hai ya khali hai
          if (!subjectData.containsKey('notes') || subjectData['notes'] == null) {
            return _buildEmptyState();
          }

          // Notes ka Nested Map utha rahe hain
          Map<String, dynamic> notesData = subjectData['notes'];

          if (notesData.isEmpty) {
            return _buildEmptyState();
          }

          // Modules ke naam nikal kar sort kar rahe hain (Module_1, Module_2...)
          List<String> modules = notesData.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              String moduleName = modules[index];
              
              // Ensure kar rahe hain ki iske andar bhi ek Map ho (Chapters)
              if (notesData[moduleName] is! Map) {
                return const SizedBox.shrink(); // Agar map nahi hai toh kuch mat dikhao
              }
              
              Map<String, dynamic> chapters = Map<String, dynamic>.from(notesData[moduleName]);

              return _buildModuleCard(context, moduleName, chapters);
            },
          );
        },
      ),
    );
  }

  // Khali state ka UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.folder_off_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text("No notes uploaded yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  // Module ka Expandable Card
  Widget _buildModuleCard(BuildContext context, String moduleName, Map<String, dynamic> chapters) {
    List<String> chapterNames = chapters.keys.toList()..sort();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          moduleName.replaceAll('_', ' '), // "Module_1" ko "Module 1" banayega
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: const Icon(Icons.folder_copy, color: Color(0xFF5A67D8)),
        children: chapterNames.map((chapterName) {
          String pdfLink = chapters[chapterName];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            title: Text(chapterName.replaceAll('_', ' ')), // "Chapter_1" ko "Chapter 1" banayega
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              // 🚀 YAHAN TERA PDF VIEWER OPEN HOGA
              // Agar tere paas pdf_viewer_screen.dart pehle se bani hai, toh ye un-comment kar de:
              
              
             Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PdfViewerScreen(
      pdfUrl: pdfLink, 
      title: "${moduleName.replaceAll('_', ' ')} - ${chapterName.replaceAll('_', ' ')}", // 🚀 Yahan pdfTitle ko title kar diya
    )
  ),
);
              
            
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Opening $chapterName...")),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}