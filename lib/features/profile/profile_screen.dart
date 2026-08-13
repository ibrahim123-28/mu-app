import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mu_study_app/features/auth/login_screen.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final Color primaryColor = const Color(0xFF5A67D8);

    return Scaffold(
      backgroundColor: Colors.white, // 🚀 Background white rakha taaki bottom list match kare
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryColor)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (userDoc) {
          final userData = userDoc?.data() as Map<String, dynamic>?;
          final course = userData?['course'] ?? "Course Not Set";
          final sem = userData?['semester'] ?? "Sem Not Set";
          final email = userData?['email'] ?? "student@test.com";
          final name = email.split('@')[0];
          final capitalizedName = "${name[0].toUpperCase()}${name.substring(1)}";
          
          // 🚀 FETCH EXAM DATE FOR SMART HOVER
          final planner = userData?['planner'] as Map<String, dynamic>?;
          final examDateStr = planner?['exam_date'];
          String hoverMessage = "Stay consistent with your studies!";
          Color hoverColor = Colors.blueAccent;

          if (examDateStr != null) {
            DateTime examDate = DateTime.parse(examDateStr);
            DateTime now = DateTime.now();
            int daysLeft = examDate.difference(now).inDays;
            
            if (daysLeft > 0 && daysLeft <= 30) {
              hoverMessage = "🔥 Quick Revision: Exams in $daysLeft days! Check saved notes.";
              hoverColor = Colors.orangeAccent;
            } else if (daysLeft == 0) {
              hoverMessage = "⚡ Best of luck! Today is your Exam!";
              hoverColor = Colors.redAccent;
            } else if (daysLeft < 0) {
              hoverMessage = "🎉 Exams are over! Time to upskill.";
              hoverColor = Colors.green;
            } else {
              hoverMessage = "📚 $daysLeft days to Exams. Start early prep!";
              hoverColor = const Color(0xFF5A67D8);
            }
          }

          // 🚀 THE MAGIC FIX: Pura Stack ab ScrollView ke andar hai
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(), 
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. TOP BLUE HEADER
                Container(
                  width: double.infinity,
                  height: 250, // Fix height taaki card properly overlap kare
                  padding: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50, color: Color(0xFF5A67D8))),
                      const SizedBox(height: 16),
                      Text(capitalizedName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text("$course • $sem", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                
                // 2. BOTTOM MENU OPTIONS
                Container(
                  margin: const EdgeInsets.only(top: 230), // Blue header ke thoda upar se shuru
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20), // Top padding for hover card
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      _buildProfileOption(Icons.trending_up, "My Progress", context, () {}),
                      _buildProfileOption(Icons.bookmark_border, "Bookmarks", context, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GlobalBookmarksScreen(userId: userDoc!.id)));
                      }),
                      _buildProfileOption(Icons.shopping_bag_outlined, "Purchased Content", context, () {}),
                      const Divider(height: 40),
                      _buildProfileOption(Icons.settings_outlined, "Settings", context, () {}),
                      _buildProfileOption(Icons.help_outline, "Help & Support", context, () {}),
                      const SizedBox(height: 20),
                      
                      // LOGOUT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            await ref.read(authServiceProvider).signOut();
                            if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
                          },
                          child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // 3. SMART EXAM REVISION HOVER WIDGET
                Positioned(
                  top: 195, // Ekdum border pe set kiya hua hai
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: hoverColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
                      border: Border.all(color: hoverColor.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: hoverColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.lightbulb_outline_rounded, color: hoverColor)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(hoverMessage, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.grey.shade800))),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Halki si grey shade
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF5A67D8).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF5A67D8))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}

// =======================================================================
// 🚀 FUNCTIONAL GLOBAL BOOKMARKS SCREEN (Reads Personal Saved Links)
// =======================================================================
class GlobalBookmarksScreen extends StatelessWidget {
  final String userId;
  const GlobalBookmarksScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text("My Saved Links", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF5A67D8), iconTheme: const IconThemeData(color: Colors.white)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('my_bookmarks').orderBy('saved_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("No personal bookmarks yet.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text("Click ⭐ in classes to save them here.", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            );
          }

          final bookmarks = snapshot.data!.docs;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final data = bookmarks[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Saved Link';
              final url = data['url'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF5A67D8).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.language_rounded, color: Color(0xFF5A67D8))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              String finalUrl = url;
                              if (!finalUrl.startsWith('http')) finalUrl = 'https://$finalUrl';
                              if (await canLaunchUrl(Uri.parse(finalUrl))) {
                                await launchUrl(Uri.parse(finalUrl), mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text("Tap to Open 🌐", style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => FirebaseFirestore.instance.collection('users').doc(userId).collection('my_bookmarks').doc(bookmarks[index].id).delete(),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}