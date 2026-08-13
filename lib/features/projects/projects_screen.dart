import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🚀 YE WALI LINE MISSING HAI!

// =========================================================================
// 🚀 RIVERPOD PROVIDER FOR BOOKMARKS
// =========================================================================
// =========================================================================
// 🚀 NEW RIVERPOD 2.0+ NOTIFIER FOR BOOKMARKS
// =========================================================================
final bookmarkedProjectsProvider = NotifierProvider<BookmarkNotifier, List<Map<String, dynamic>>>(() {
  return BookmarkNotifier();
});

class BookmarkNotifier extends Notifier<List<Map<String, dynamic>>> {
  
  @override
  List<Map<String, dynamic>> build() {
    return []; // Ye initial state hai (empty list)
  }

  void toggleBookmark(Map<String, dynamic> project) {
    // Agar pehle se saved hai, toh remove karo, warna add karo
    final isExisting = state.any((p) => p['title'] == project['title']);
    if (isExisting) {
      state = state.where((p) => p['title'] != project['title']).toList();
    } else {
      state = [...state, project];
    }
  }

  bool isBookmarked(String title) {
    return state.any((p) => p['title'] == title);
  }
}
// =========================================================================
// 💡 MAIN PROJECTS SCREEN
// =========================================================================
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFF5A67D8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🚀 DUMMY DATA (Baad me isko Firebase se connect kar sakte ho)
  final List<Map<String, dynamic>> researchProjects = [
    {
      "title": "Importance of Exercise Analysis",
      "tagline": "Course Enrichment Research",
      "techStack": ["Data Science", "Analytics", "Python"],
      "summary": "Formal research documenting the physiological impacts and data interpretations of regular physical exercise on student performance."
    },
    {
      "title": "4-Layer IoT Architecture",
      "tagline": "Sensor Integration & Networking",
      "techStack": ["IoT", "Circuit Design", "C++"],
      "summary": "An exploratory study on integrating RGB LED circuits and temperature sensors within a layered network topology."
    },
  ];

  final List<Map<String, dynamic>> innovationProjects = [
    {
      "title": "Orbit AI (Nexus.os)",
      "tagline": "Modular AI SaaS Platform",
      "techStack": ["Next.js", "Node.js", "OpenAI"],
      "summary": "A modular platform featuring an emotional AI assistant, document generators, and subscription-based feature gating."
    },
    {
      "title": "Glassmorphic UI Engine",
      "tagline": "Next-Level Aesthetic Framework",
      "techStack": ["React", "Framer Motion", "Tailwind"],
      "summary": "A production-ready design system utilizing bento grids and cyberpunk anime themes for modern web applications."
    },
  ];

  final List<Map<String, dynamic>> problemSolvingProjects = [
    {
      "title": "Smart Classes ERP",
      "tagline": "Institute Management Made Paperless",
      "techStack": ["React", "Laravel", "MySQL"],
      "summary": "A comprehensive backend and frontend solution for handling student attendance, fee management, and automated result processing."
    },
    {
      "title": "Network Topology Visualizer",
      "tagline": "OSI & TCP/IP Model Analyzer",
      "techStack": ["Flutter", "Dart", "Networking"],
      "summary": "An interactive tool to visualize transmission media and compare networking architectures for exam preparation."
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Watch bookmarked count for the badge
    final bookmarkedList = ref.watch(bookmarkedProjectsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Project Ideas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // 🚀 BOOKMARK BUTTON IN APP BAR
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_added_outlined, color: Color(0xFF5A67D8), size: 28),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedProjectsScreen()));
                },
              ),
              if (bookmarkedList.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Text(
                      '${bookmarkedList.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.science_outlined), text: "Research"),
            Tab(icon: Icon(Icons.lightbulb_outline), text: "Innovation"),
            Tab(icon: Icon(Icons.extension_outlined), text: "Solving"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectList(researchProjects),
          _buildProjectList(innovationProjects),
          _buildProjectList(problemSolvingProjects),
        ],
      ),
    );
  }

  Widget _buildProjectList(List<Map<String, dynamic>> projects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return ProjectCard(project: projects[index], primaryColor: primaryColor);
      },
    );
  }
}

// =========================================================================
// 📝 REUSABLE PROJECT CARD (Taki Bookmark aur Main screen dono pe use ho sake)
// =========================================================================
class ProjectCard extends ConsumerWidget {
  final Map<String, dynamic> project;
  final Color primaryColor;

  const ProjectCard({super.key, required this.project, required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if this project is bookmarked
    final isSaved = ref.watch(bookmarkedProjectsProvider.notifier).isBookmarked(project['title']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(project['tagline'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
                  ],
                ),
              ),
              // 🚀 BOOKMARK ICON Toggling
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? primaryColor : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  ref.read(bookmarkedProjectsProvider.notifier).toggleBookmark(project);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSaved ? "Removed from saved ideas" : "Idea saved to bookmarks! 🚀"),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (project['techStack'] as List<String>).map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tech, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
              );
            }).toList(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Text(project['summary'], style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}

// =========================================================================
// 🔖 SAVED PROJECTS SCREEN (Yahan bookmarked ideas aayenge)
// =========================================================================
class SavedProjectsScreen extends ConsumerWidget {
  const SavedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedProjects = ref.watch(bookmarkedProjectsProvider);
    final primaryColor = const Color(0xFF5A67D8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Saved Ideas", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: savedProjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("No saved ideas yet!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text("Bookmark your favorite projects\nto find them here easily.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: savedProjects.length,
              itemBuilder: (context, index) {
                return ProjectCard(project: savedProjects[index], primaryColor: primaryColor);
              },
            ),
    );
  }
}