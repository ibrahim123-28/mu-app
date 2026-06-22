import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
class SelectSemesterScreen extends ConsumerWidget {
  final String courseName;
  const SelectSemesterScreen({super.key, required this.courseName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Semester"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseName, style: const TextStyle(color: Color(0xFF5A67D8), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text("Which semester are you in?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                ),
                itemCount: 8, // NEP 2020 8 Semesters
                itemBuilder: (context, index) {
                  return InkWell(
                   onTap: () async {
  // Show a quick loading spinner
  showDialog(
    context: context, 
    barrierDismissible: false,
    builder: (c) => const Center(child: CircularProgressIndicator())
  );try {
    // 1. Save data to Firestore using our service!
    final semesterString = "Sem ${index + 1}";
    await ref.read(authServiceProvider).saveUserCourseData(courseName, semesterString);

    // 2. Remove loading spinner
    if (context.mounted) Navigator.pop(context);

    // 3. Go to Dashboard
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Semester ${index + 1}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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