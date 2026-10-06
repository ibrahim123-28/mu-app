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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
          final capitalizedName = name.isNotEmpty
              ? "${name[0].toUpperCase()}${name.substring(1)}"
              : "Student";

          // 🚀 FETCH EXAM DATE FOR SMART HOVER
          final planner = userData?['planner'] as Map<String, dynamic>?;
          final examDateStr = planner?['exam_date'];
          String hoverMessage = "Stay consistent with your studies!";
          Color hoverColor = Colors.blueAccent;

          if (examDateStr != null) {
            try {
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
            } catch (_) {}
          }

          final userId = userDoc?.id ?? "";

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. TOP BLUE HEADER
                Container(
                  width: double.infinity,
                  height: 250,
                  padding: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Color(0xFF5A67D8)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        capitalizedName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$course • $sem",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. BOTTOM MENU OPTIONS
                Container(
                  margin: const EdgeInsets.only(top: 230),
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // 📈 MY PROGRESS
                      _buildProfileOption(
                        Icons.trending_up,
                        "My Progress",
                        context,
                        () => _showProgressBottomSheet(context, course, sem),
                      ),

                      // 🔖 BOOKMARKS
                      _buildProfileOption(
                        Icons.bookmark_border,
                        "Bookmarks",
                        context,
                        () {
                          if (userId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GlobalBookmarksScreen(userId: userId),
                              ),
                            );
                          }
                        },
                      ),

                      // 🛍️ PURCHASED CONTENT
                      _buildProfileOption(
                        Icons.shopping_bag_outlined,
                        "Purchased Content",
                        context,
                        () => _showPurchasedContentSheet(context),
                      ),

                      const Divider(height: 40),

                      // ⚙️ SETTINGS
                      _buildProfileOption(
                        Icons.settings_outlined,
                        "Settings",
                        context,
                        () => _showSettingsBottomSheet(context, userId, course, sem),
                      ),

                      // ❓ HELP & SUPPORT
                      _buildProfileOption(
                        Icons.help_outline,
                        "Help & Support",
                        context,
                        () => _showHelpSupportBottomSheet(context),
                      ),

                      const SizedBox(height: 20),

                      // 🚪 LOGOUT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text("Log Out"),
                                content: const Text("Are you sure you want to log out?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Log Out", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref.read(authServiceProvider).signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Log Out",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // 3. SMART EXAM REVISION HOVER WIDGET
                Positioned(
                  top: 195,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: hoverColor.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: hoverColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: hoverColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.lightbulb_outline_rounded, color: hoverColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hoverMessage,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF5A67D8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF5A67D8)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  // ==========================================
  // 📈 MODAL 1: MY PROGRESS BOTTOM SHEET
  // ==========================================
  void _showProgressBottomSheet(BuildContext context, String course, String sem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "My Learning Progress",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Academic Focus: $course ($sem)",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatCard("🔥 Streak", "7 Days", Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard("📚 Read Notes", "14 Chapters", const Color(0xFF5A67D8)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard("⚡ Flashcards", "85% Mastered", Colors.green),
                const SizedBox(width: 12),
                _buildStatCard("⏱️ Study Time", "18.5 hrs", Colors.teal),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Syllabus Completion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 0.65,
                minHeight: 10,
                backgroundColor: Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A67D8)),
              ),
            ),
            const SizedBox(height: 8),
            const Text("65% of current semester topics covered", style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey.shade900)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🛍️ MODAL 2: PURCHASED CONTENT SHEET
  // ==========================================
  void _showPurchasedContentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Icon(Icons.verified_rounded, size: 60, color: Colors.green.shade600),
            const SizedBox(height: 16),
            const Text(
              "Free Student Access",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "All university notes, PYQs, and AI study resources in this version are 100% Free & Open-Access for all students.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A67D8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Continue Studying", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ⚙️ MODAL 3: SETTINGS BOTTOM SHEET
  // ==========================================
  void _showSettingsBottomSheet(BuildContext context, String userId, String currentCourse, String currentSem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Settings & Preferences", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Change Course/Semester Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.school, color: Colors.blue),
                  ),
                  title: const Text("Change Course & Semester", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$currentCourse • $currentSem", style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditCourseDialog(context, userId, currentCourse, currentSem);
                  },
                ),
                const Divider(),

                // Clear Cache Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.cleaning_services_rounded, color: Colors.amber),
                  ),
                  title: const Text("Clear Temporary Cache", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Free up storage from cached documents", style: TextStyle(fontSize: 12)),
                  onTap: () {
                    imageCache.clear();
                    imageCache.clearLiveImages();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("App cache cleared successfully! 🧹")),
                    );
                  },
                ),
                const Divider(),

                // App Version
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.info_outline, color: Colors.purple),
                  ),
                  title: const Text("About MU Study App", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Version 1.0.0 (Production Build)", style: TextStyle(fontSize: 12)),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "MU Study App",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "Developed for University Students to access notes and smart study planners.",
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Update Course & Semester in Firestore
  void _showEditCourseDialog(BuildContext context, String userId, String course, String sem) {
    final courseController = TextEditingController(text: course);
    final semController = TextEditingController(text: sem);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Update Academic Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courseController,
              decoration: const InputDecoration(labelText: "Course (e.g. B.Sc CS)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: semController,
              decoration: const InputDecoration(labelText: "Semester (e.g. Sem 5)", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A67D8)),
            onPressed: () async {
              if (userId.isNotEmpty) {
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'course': courseController.text.trim(),
                  'semester': semController.text.trim(),
                });
              }
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Academic info updated in Cloud Firestore! 🚀")),
                );
              }
            },
            child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ❓ MODAL 4: HELP & SUPPORT BOTTOM SHEET
  // ==========================================
  void _showHelpSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Help & Support", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Got questions or need help? We're here for you.", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final emailUri = Uri.parse("mailto:support@mustudyapp.com?subject=MU%20App%20Support");
                      try {
                        await launchUrl(emailUri);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Contact support at: support@mustudyapp.com")),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.email_outlined, color: Color(0xFF5A67D8)),
                    label: const Text("Email Us", style: TextStyle(color: Color(0xFF5A67D8), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Frequently Asked Questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  ExpansionTile(
                    title: Text("How do I view PDF notes?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Go to Study > Select Semester > Choose Subject > Tap on any Module to view or download high-quality notes.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      )
                    ],
                  ),
                  ExpansionTile(
                    title: Text("How do Bookmarks work?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Click the Star ⭐ icon next to any subject module to save it into your personal Bookmarks tab.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      )
                    ],
                  ),
                  ExpansionTile(
                    title: Text("Is the app completely free?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Yes, all syllabus notes, PYQs, and AI study utilities are open-access.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// 🚀 GLOBAL BOOKMARKS SCREEN (Reads Personal Saved Links)
// =======================================================================
class GlobalBookmarksScreen extends StatelessWidget {
  final String userId;
  const GlobalBookmarksScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("My Saved Links", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5A67D8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('my_bookmarks')
            .orderBy('saved_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A67D8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.language_rounded, color: Color(0xFF5A67D8)),
                    ),
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
                            child: Text(
                              "Tap to Open 🌐",
                              style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('my_bookmarks')
                          .doc(bookmarks[index].id)
                          .delete(),
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