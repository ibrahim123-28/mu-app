import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  bool _isLoading = true;
  DateTime? _examDate;
  
  // Attendance Controllers
  final TextEditingController _attendedCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();
  String _attendanceMessage = "Enter your attendance to see your status.";
  Color _messageColor = Colors.grey;

  // Daily Tasks
  List<dynamic> _dailyTasks = [];

  final Color primaryColor = const Color(0xFF5A67D8);

  @override
  void initState() {
    super.initState();
    _loadPlannerData();
  }

  Future<void> _loadPlannerData() async {
    final userDoc = await ref.read(userProvider.future);
    final userData = userDoc?.data() as Map<String, dynamic>?;
    final plannerData = userData?['planner'] as Map<String, dynamic>? ?? {};

    if (mounted) {
      setState(() {
        if (plannerData['exam_date'] != null) {
          _examDate = DateTime.parse(plannerData['exam_date']);
        }
        if (plannerData['attended_classes'] != null) {
          _attendedCtrl.text = plannerData['attended_classes'].toString();
          _totalCtrl.text = plannerData['total_classes'].toString();
          _calculateAttendance(); 
        }
        if (plannerData['tasks'] != null) {
          _dailyTasks = plannerData['tasks'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    await ref.read(authServiceProvider).savePlannerData({
      'exam_date': _examDate?.toIso8601String(),
      'attended_classes': int.tryParse(_attendedCtrl.text),
      'total_classes': int.tryParse(_totalCtrl.text),
      'tasks': _dailyTasks,
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initial = (_examDate != null && _examDate!.isAfter(DateTime.now())) 
        ? _examDate! 
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)), child: child!);
      },
    );
    if (picked != null && picked != _examDate) {
      setState(() => _examDate = picked);
      _saveData(); 
    }
  }

  void _calculateAttendance() {
    int attended = int.tryParse(_attendedCtrl.text) ?? 0;
    int total = int.tryParse(_totalCtrl.text) ?? 0;

    if (total == 0 || attended > total) {
      setState(() { _attendanceMessage = "Invalid input. Check your numbers."; _messageColor = Colors.red; });
      return;
    }

    double percentage = (attended / total) * 100;
    setState(() {
      if (percentage >= 75) {
        int safeBunks = (attended / 0.75).floor() - total;
        _attendanceMessage = "Current: ${percentage.toStringAsFixed(1)}%\nYou can safely bunk $safeBunks classes. 😎";
        _messageColor = Colors.green;
      } else {
        int needed = (3 * total) - (4 * attended);
        _attendanceMessage = "Current: ${percentage.toStringAsFixed(1)}%\nYou MUST attend the next $needed classes to reach 75%. 🚨";
        _messageColor = Colors.red;
      }
    });
    _saveData(); 
  }

  // 🚀 1. B.Sc CS REAL SYLLABUS DATA FOR AI CARD
  final Map<int, List<Map<String, String>>> bscCsSyllabus = {
    1: [
      {"topic": "Python / C Programming", "how": "Practice Loops, Functions, and Arrays logic on PC for 1.5 Hrs."},
      {"topic": "Digital Electronics", "how": "Solve 5 K-Map equations and revise Logic Gates for 1 Hr."},
      {"topic": "Operating Systems", "how": "Read Process Scheduling & Memory Management theory for 45 Mins."},
    ],
    2: [
      {"topic": "Data Structures", "how": "Write code for Stack, Queue, and Linked List implementations - 2 Hrs."},
      {"topic": "Calculus & Math", "how": "Solve 10 Integration & Derivation university problems - 1.5 Hrs."},
      {"topic": "Web Programming", "how": "Build a static webpage using HTML/CSS/JS without Bootstrap - 1 Hr."},
    ],
    3: [
      {"topic": "Core Java", "how": "Practice OOPs concepts (Inheritance, Polymorphism) with code - 1.5 Hrs."},
      {"topic": "Theory of Computation", "how": "Draw DFA, NFA and write Regular Expressions - 1.5 Hrs."},
      {"topic": "Database Mgmt (DBMS)", "how": "Write and practice 10 complex SQL Queries (Joins, Subqueries) - 1 Hr."},
    ],
    4: [
      {"topic": "Computer Networks", "how": "Memorize OSI & TCP/IP models with diagrams - 1 Hr."},
      {"topic": "Advanced Java / .NET", "how": "Practice JDBC/Database connectivity code - 1.5 Hrs."},
      {"topic": "Software Engineering", "how": "Draw DFD and UML diagrams for a sample project - 1 Hr."},
    ],
    5: [
      {"topic": "Artificial Intelligence", "how": "Study A* Search, Minimax, and Expert Systems - 1.5 Hrs."},
      {"topic": "Linux Server Admin", "how": "Memorize core Linux terminal commands and Bash scripting - 1 Hr."},
      {"topic": "Software Testing", "how": "Write test cases for a login page (Black box/White box) - 45 Mins."},
    ],
    6: [
      {"topic": "Cloud Computing", "how": "Understand AWS/Azure architectures and Virtualization - 1.5 Hrs."},
      {"topic": "Data Science", "how": "Practice Pandas/Numpy data manipulation in Python - 1.5 Hrs."},
      {"topic": "Project Work", "how": "Write 2 pages of your final year project documentation - 1 Hr."},
    ],
  };

  // 🚀 2. THE PREMIUM HOVER CARD (AI PLANNER DIALOG)
  void _showAIPlannerDialog() {
    int selectedSem = 1;
    bool showingPlan = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            elevation: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome, color: Colors.purple),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text("AI Study Strategist", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87)),
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (!showingPlan) ...[
                    const Text("Select your B.Sc CS Semester to generate a targeted study routine:", style: TextStyle(color: Colors.black54, fontSize: 14)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(6, (index) {
                        int sem = index + 1;
                        bool isSelected = selectedSem == sem;
                        return ChoiceChip(
                          label: Text("Sem $sem", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: Colors.grey.shade100,
                          onSelected: (val) => setDialogState(() => selectedSem = sem),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => setDialogState(() => showingPlan = true),
                        child: const Text("Generate Strategy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ] else ...[
                    // 🚀 GENERATED PLAN PREVIEW
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text("Showing roadmap for Sem $selectedSem", style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold))),
                          InkWell(
                            onTap: () => setDialogState(() => showingPlan = false),
                            child: Text("Change", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      height: 220, // Scrollable area for the plan
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: bscCsSyllabus[selectedSem]!.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("📚 ${item['topic']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text("👉 ${item['how']}", style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          // Apply generated plan to actual list
                          List<dynamic> newTasks = bscCsSyllabus[selectedSem]!.map((e) => {
                            "task": "${e['topic']}: ${e['how']}",
                            "isDone": false
                          }).toList();

                          setState(() => _dailyTasks = newTasks);
                          _saveData();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plan applied to Daily Targets!"), backgroundColor: Colors.green));
                        },
                        icon: const Icon(Icons.add_task, color: Colors.white),
                        label: const Text("Apply to My Targets", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addOrEditTask({int? index}) {
    TextEditingController taskCtrl = TextEditingController(text: index != null ? _dailyTasks[index]["task"] : "");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(index != null ? "Edit Study Goal ✏️" : "New Study Goal 🎯", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(controller: taskCtrl, decoration: const InputDecoration(hintText: "E.g., Practice Python", border: OutlineInputBorder()), maxLines: 2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              if (taskCtrl.text.trim().isNotEmpty) {
                setState(() {
                  if (index != null) {
                    _dailyTasks[index]["task"] = taskCtrl.text.trim();
                  } else {
                    _dailyTasks.add({"task": taskCtrl.text.trim(), "isDone": false});
                  }
                });
                _saveData(); 
                Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  String get _daysRemaining {
    if (_examDate == null) return "Set Date";
    final difference = _examDate!.difference(DateTime.now()).inDays;
    if (difference < 0) return "Done";
    if (difference == 0) return "Today!";
    return "$difference Days";
  }

  @override
  void dispose() {
    _attendedCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryColor)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Smart Study Planner", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Exam Planner
            const Text("Target Exam Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Exam Countdown", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        _examDate == null ? "Not Set" : "${_examDate!.day}/${_examDate!.month}/${_examDate!.year}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(_daysRemaining, style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 2. Smart Attendance Calculator
            const Text("75% Attendance Predictor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _attendedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Classes Attended", border: OutlineInputBorder()), onChanged: (v) => _calculateAttendance())),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: _totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Total Conducted", border: OutlineInputBorder()), onChanged: (v) => _calculateAttendance())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _messageColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _messageColor.withValues(alpha: 0.5))),
                    child: Text(_attendanceMessage, textAlign: TextAlign.center, style: TextStyle(color: _messageColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. 🚀 NEW PREMIUM DAILY TARGETS HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Daily Targets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    // ✨ NEW AI ASSISTANT BUTTON MOVED HERE
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.purple, backgroundColor: Colors.purple.withValues(alpha: 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: _showAIPlannerDialog, 
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text("AI Assistant", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: primaryColor, size: 28),
                      onPressed: () => _addOrEditTask(), 
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_dailyTasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                child: const Center(child: Text("Set up your first study goal! 🎯", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              )
            else
              ...List.generate(_dailyTasks.length, (index) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(side: BorderSide(color: _dailyTasks[index]["isDone"] ? Colors.green.shade200 : Colors.black12), borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Checkbox(
                      activeColor: Colors.green,
                      value: _dailyTasks[index]["isDone"],
                      onChanged: (bool? value) {
                        setState(() => _dailyTasks[index]["isDone"] = value!);
                        _saveData(); 
                      },
                    ),
                    title: Text(
                      _dailyTasks[index]["task"],
                      style: TextStyle(
                        decoration: _dailyTasks[index]["isDone"] ? TextDecoration.lineThrough : null,
                        color: _dailyTasks[index]["isDone"] ? Colors.grey.shade600 : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600, size: 20), onPressed: () => _addOrEditTask(index: index)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () { setState(() => _dailyTasks.removeAt(index)); _saveData(); }),
                      ],
                    ),
                  ),
                );
              }),  
          ],
        ),
      ),
    );
  }
}