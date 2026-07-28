import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'batch_action_sheet.dart'; // Isko import karna zaroori hai
import 'class_dashboard_screen.dart';

class MyClassesScreen extends StatelessWidget {
  final String userId;

  const MyClassesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("My Classes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🚀 SMART QUERY: Sirf wahi classes lao jisme ye user 'members' array me hai
        stream: FirebaseFirestore.instance
            .collection('classes')
            .where('members', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5A67D8)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No classes found. Join or create one!", style: TextStyle(color: Colors.grey)));
          }

          final classes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index].data() as Map<String, dynamic>;
              final className = classData['class_name'] ?? 'Unnamed Class';
              final joinCode = classData['join_code'] ?? '---';
              final membersCount = (classData['members'] as List<dynamic>? ?? []).length;
              final isCreator = classData['created_by'] == userId;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header (Premium Purple)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5A67D8),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              className,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCreator)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                              child: const Text("Admin", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                    ),
                    
                    // Card Body
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Class Code", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(joinCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Members", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.people, size: 16, color: Color(0xFF5A67D8)),
                                  const SizedBox(width: 4),
                                  Text("$membersCount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 🚀 Action Button (Enter Class) - Updated Navigation
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5A67D8)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            // 🚀 Asli Navigation yahan hai
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassDashboardScreen(
                                  classId: classes[index].id,
                                  className: className,
                                  joinCode: joinCode,
                                  currentUserId: userId,
                                  isCreator: isCreator,
                                ),
                              ),
                            );
                          },
                          child: const Text("Enter Class", style: TextStyle(color: Color(0xFF5A67D8), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      
      // 🚀 FLOATING ACTION BUTTON TO ADD MORE CLASSES
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5A67D8),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => BatchActionSheet(userId: userId),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}