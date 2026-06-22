import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

// Change to ConsumerWidget to use Riverpod
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user data for the header
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A67D8),
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (userDoc) {
          final userData = userDoc?.data() as Map<String, dynamic>?;
          final course = userData?['course'] ?? "Course Not Set";
          final sem = userData?['semester'] ?? "Sem Not Set";
          final email = userData?['email'] ?? "student@test.com";
          final name = email.split('@')[0];
          final capitalizedName = "${name[0].toUpperCase()}${name.substring(1)}";

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 30, top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5A67D8),
                    borderRadius: BorderRadius.only(
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$course • $sem",
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Menu Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildProfileOption(Icons.trending_up, "My Progress", context),
                      _buildProfileOption(Icons.bookmark_border, "Bookmarks", context),
                      _buildProfileOption(Icons.shopping_bag_outlined, "Purchased Content", context),
                      const Divider(height: 40),
                      _buildProfileOption(Icons.settings_outlined, "Settings", context),
                      _buildProfileOption(Icons.help_outline, "Help & Support", context),
                      const SizedBox(height: 20),
                      
                      // FUNCTIONAL Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            // 1. Log out via Firebase
                            await ref.read(authServiceProvider).signOut();
                            // 2. The main.dart router will automatically throw the user back to the login screen!
                          },
                          child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF4FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF5A67D8)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title coming soon!")),
           );
        },
      ),
    );
  }
}