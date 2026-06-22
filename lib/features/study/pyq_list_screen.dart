import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pdf_viewer_screen.dart';

class PyqListScreen extends StatelessWidget {
  final String subjectName;

  const PyqListScreen({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("$subjectName PYQs", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      // THE MAGIC WALL: FutureBuilder handles fetching, loading states, and data parsing
      body: FutureBuilder<QuerySnapshot>(
        // collectionGroup trick: Searches ALL collections named 'subjects' for your specific subject!
        future: FirebaseFirestore.instance
            .collectionGroup('subjects')
            .where('subjectName', isEqualTo: subjectName)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5A67D8)));
          }

          // 2. Error State
          // 2. Error State (Now showing the ACTUAL error)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Asli Error:\n\n${snapshot.error}", 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          // 3. No Document Found State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Subject not found in database.", style: TextStyle(color: Colors.grey, fontSize: 16)));
          }

          // Fetching the document data
          final docData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          
          // Safely extracting the 'pyqs' map. If it doesn't exist, we return an empty map {}.
          final pyqData = docData['pyqs'] as Map<String, dynamic>? ?? {};

          // 4. Empty PYQ Map State
          if (pyqData.isEmpty) {
            return const Center(child: Text("No PYQs uploaded yet.", style: TextStyle(color: Colors.grey, fontSize: 16)));
          }

          // Sort years in descending order (e.g., 2023, 2022, 2021)
          final sortedYears = pyqData.keys.toList()..sort((a, b) => b.compareTo(a));

          // 5. Success State: Build the list!
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedYears.length,
            itemBuilder: (context, index) {
              String year = sortedYears[index];
              String pdfLink = pyqData[year].toString();

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Color(0xFF5A67D8)),
                  ),
                  title: Text("$year University Paper", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Send the Direct Google Drive Link to our universal PDF Viewer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          pdfUrl: pdfLink,
                          title: "$year - $subjectName",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}