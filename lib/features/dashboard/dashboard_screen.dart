import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../study/notes_screen.dart';
import '../tests/tests_screen.dart';
import '../tools/cgpa_calc.dart';
import '../placement/placement_screen.dart';
import '../profile/profile_screen.dart';
import '../planner/planner_screen.dart';
import '../../core/services/auth_service.dart';
import '../resume/resume_builder_screen.dart';
import '../timetable/batch_action_sheet.dart';
import '../timetable/my_classes_screen.dart';
import '../placement/placement_screen.dart';
 // Apna path check kar lena agar alag folder me rakha ho
// 🚀 AI Provider import karna zaroori hai
import '../ai_tutor/providers/ai_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real-time user stream
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text("Error: $error"))),
      data: (userDoc) {
        // Safety check
        if (userDoc == null || !userDoc.exists) {
          return const Scaffold(body: Center(child: Text("Please Login First")));
        }

        // Extract real data from Firestore!
        final userData = userDoc.data() as Map<String, dynamic>?;
        
        final courseName = userData?['course'] ?? "Course Not Set";
        final currentSem = userData?['semester'] ?? "Sem Not Set";
        
        final email = userData?['email'] ?? "Student";
        final name = email.split('@')[0];
        final capitalizedName = "${name[0].toUpperCase()}${name.substring(1)}";

        // REAL TIME STATS FROM FIRESTORE
        final savedCgpa = userData?['cgpa']?.toStringAsFixed(2) ?? "0.00";
        // EXTRACT PLANNER DATA FOR DASHBOARD
        final plannerData = userData?['planner'] as Map<String, dynamic>?;
        
        // Calculate Attendance Percentage
        String attendance = "N/A";
        if (plannerData != null && plannerData['attended_classes'] != null && plannerData['total_classes'] != null) {
          int att = plannerData['attended_classes'];
          int tot = plannerData['total_classes'];
          if (tot > 0) {
            attendance = "${((att / tot) * 100).toStringAsFixed(0)}%";
          }
        }

        // Calculate Exam Countdown
        String upcomingExam = "-- Days";
        if (plannerData != null && plannerData['exam_date'] != null) {
          DateTime examDate = DateTime.parse(plannerData['exam_date']);
          int diff = examDate.difference(DateTime.now()).inDays;
          upcomingExam = diff >= 0 ? "$diff Days" : "Passed";
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Real-time Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello, $capitalizedName! 👋", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text("Welcome Back", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {})
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Real-time Current Semester Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF4FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Current Semester", style: TextStyle(color: Colors.black54)),
                            const SizedBox(height: 4),
                            // DYNAMIC SEMESTER
                            Text(currentSem, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            // DYNAMIC COURSE
                            Text(courseName, style: const TextStyle(color: Color(0xFF5A67D8), fontSize: 12)),
                          ],
                        ),
                        const Icon(Icons.menu_book, size: 60, color: Color(0xFF5A67D8)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

            // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard("Attendance", attendance), 
                  _buildStatCard("CGPA", savedCgpa),
                  _buildStatCard("Upcoming Exam", upcomingExam),
                ],
              ),
                  const SizedBox(height: 24),

                  // Continue Studying Section
                  const Text("Continue Studying", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // DYNAMIC CHECK: Did they study anything yet?
                  Builder(
                    builder: (context) {
                      final lastStudied = userData?['last_studied'] as Map<String, dynamic>?;

                      // IF NO DATA: Show a friendly "Start Learning" message
                      if (lastStudied == null) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12, style: BorderStyle.solid),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.rocket_launch, color: Color(0xFF5A67D8), size: 30),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Ready to start learning?", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Open the Study tab to begin.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // IF DATA EXISTS: Show their actual progress
                      final subject = lastStudied['subject'] ?? "Subject";
                      final topic = lastStudied['topic'] ?? "Topic";
                      final progress = (lastStudied['progress'] ?? 0.0) as double;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFEBF4FF), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.code, color: Color(0xFF5A67D8)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(subject, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(topic, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey[200],
                                    color: const Color(0xFF5A67D8),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                 const Text("Quick Access", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickAccessBtn(Icons.description_outlined, "Notes", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen()));
                        }),
                        const SizedBox(width: 16),
                        _buildQuickAccessBtn(Icons.edit_note, "Tests", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TestsScreen()));
                        }),
                        const SizedBox(width: 16),
                        _buildQuickAccessBtn(Icons.calculate_outlined, "CGPA", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CgpaCalculatorScreen()));
                        }),
                        const SizedBox(width: 16),
                        _buildQuickAccessBtn(Icons.work_outline, "Placement", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PlacementDashboard()));
                  }),
                        const SizedBox(width: 16),
                        _buildQuickAccessBtn(Icons.calendar_month_outlined, "Planner", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PlannerScreen()));
                        }),
                         const SizedBox(width: 16),
                        _buildQuickAccessBtn(Icons.assignment_ind_outlined, "Resume", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ResumeBuilderScreen()));
                        }),
                        
                        // 🚀 Yahan spacing missing thi, wo add kar di hai
                        const SizedBox(width: 16), 

                       _buildQuickAccessBtn(Icons.group_add_outlined, "Class", () {
                          final userId = userDoc.id;
                          // 🚀 Check if user has joined any classes
                          final joinedClasses = userData?['joined_classes'] as List<dynamic>? ?? [];

                          if (joinedClasses.isEmpty) {
                            // Agar koi class nahi hai, toh direct Join/Create Sheet kholo
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => BatchActionSheet(userId: userId),
                            );
                          } else {
                            // Agar class hai, toh My Classes wali List Screen kholo
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyClassesScreen(userId: userId),
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // FULLY FUNCTIONAL BOTTOM NAVIGATION BAR
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0, // Highlight Home
            selectedItemColor: const Color(0xFF5A67D8),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 0) {
                // Do nothing, already on Home
              } else if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen()));
              } else if (index == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TestsScreen()));
              } else if (index == 3) {
                // 🚀 YAHAN AI BOTTOM SHEET KHULEGA 🚀
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const NexusAiBottomSheet(),
                );
              } else if (index == 4) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Study"),
              BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: "Tests"),
              BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: "AI"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Icon(icon, color: const Color(0xFF5A67D8)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// =========================================================================
// 🤖 NEXUS AI BOTTOM SHEET (Alag Widget taaki Dashboard clean rahe)
// =========================================================================
class NexusAiBottomSheet extends ConsumerStatefulWidget {
  const NexusAiBottomSheet({super.key});

  @override
  ConsumerState<NexusAiBottomSheet> createState() => _NexusAiBottomSheetState();
}

class _NexusAiBottomSheetState extends ConsumerState<NexusAiBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    // Naya message aane par scroll ko bottom par le jana
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, sheetController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: const Color(0xFF0D0E15), // Premium Dark Background
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 5,
                  decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.smart_toy, color: Color(0xFF5A67D8)),
                      const SizedBox(width: 10),
                      const Text("NEXUS AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
                const Divider(color: Colors.white10),
                
                // Chat List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatState.messages[index];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser ? const Color(0xFF5A67D8) : Colors.white12,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
                              bottomRight: Radius.circular(msg.isUser ? 0 : 16),
                            ),
                          ),
                          child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                      );
                    },
                  ),
                ),

                // AI Loading Indicator
                if (chatState.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5A67D8))),
                        SizedBox(width: 10),
                        Text("Nexus is typing...", style: TextStyle(color: Color(0xFF5A67D8), fontSize: 12)),
                      ],
                    ),
                  ),

                // Input Box
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10, left: 12, right: 12, top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Ask doubt...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5A67D8)),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: () {
                            if (_textController.text.trim().isNotEmpty) {
                              ref.read(aiChatProvider.notifier).sendMessage(_textController.text);
                              _textController.clear();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}