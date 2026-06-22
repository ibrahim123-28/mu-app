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
  List<dynamic> _dailyTasks = [
    {"task": "Set up your first study goal!", "isDone": false},
  ];

  @override
  void initState() {
    super.initState();
    _loadPlannerData();
  }

  // 1. Load Data from Firestore
  Future<void> _loadPlannerData() async {
    final userDoc = await ref.read(userProvider.future);
    final userData = userDoc?.data() as Map<String, dynamic>?;
    final plannerData = userData?['planner'] as Map<String, dynamic>? ?? {};

    if (mounted) {
      setState(() {
        // Load Exam Date
        if (plannerData['exam_date'] != null) {
          _examDate = DateTime.parse(plannerData['exam_date']);
        }
        
        // Load Attendance Stats
        if (plannerData['attended_classes'] != null) {
          _attendedCtrl.text = plannerData['attended_classes'].toString();
          _totalCtrl.text = plannerData['total_classes'].toString();
          _calculateAttendance(); // Recalculate the message
        }

        // Load Tasks
        if (plannerData['tasks'] != null) {
          _dailyTasks = plannerData['tasks'];
        }
        
        _isLoading = false;
      });
    }
  }

  // 2. Save Data to Firestore
  Future<void> _saveData() async {
    await ref.read(authServiceProvider).savePlannerData({
      'exam_date': _examDate?.toIso8601String(),
      'attended_classes': int.tryParse(_attendedCtrl.text),
      'total_classes': int.tryParse(_totalCtrl.text),
      'tasks': _dailyTasks,
    });
  }

  // 3. Select Exam Date & Auto-Save
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF5A67D8)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _examDate) {
      setState(() => _examDate = picked);
      _saveData(); // Save instantly
    }
  }

  // 4. The Smart Attendance Logic (75% Criteria)
  void _calculateAttendance() {
    int attended = int.tryParse(_attendedCtrl.text) ?? 0;
    int total = int.tryParse(_totalCtrl.text) ?? 0;

    if (total == 0 || attended > total) {
      setState(() {
        _attendanceMessage = "Invalid input. Check your numbers.";
        _messageColor = Colors.red;
      });
      return;
    }

    double percentage = (attended / total) * 100;

    setState(() {
      if (percentage >= 75) {
        // Safe bunk calculation: B <= (Attended / 0.75) - Total
        int safeBunks = (attended / 0.75).floor() - total;
        _attendanceMessage = "Current: ${percentage.toStringAsFixed(1)}%\nYou can safely bunk $safeBunks classes. 😎";
        _messageColor = Colors.green;
      } else {
        // Needed calculation: N = 3*Total - 4*Attended
        int needed = (3 * total) - (4 * attended);
        _attendanceMessage = "Current: ${percentage.toStringAsFixed(1)}%\nYou MUST attend the next $needed classes to reach 75%. 🚨";
        _messageColor = Colors.red;
      }
    });
    
    _saveData(); // Auto-save after calculation
  }

  String get _daysRemaining {
    if (_examDate == null) return "Set Date";
    final difference = _examDate!.difference(DateTime.now()).inDays;
    return "$difference Days";
  }

  @override
  void dispose() {
    _attendedCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }
void _addNewTask() {
    TextEditingController taskCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("New Study Goal", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: taskCtrl,
          decoration: const InputDecoration(
            hintText: "E.g., Practice Python OOPs",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A67D8)),
            onPressed: () {
              if (taskCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _dailyTasks.add({"task": taskCtrl.text.trim(), "isDone": false});
                });
                _saveData(); // Save new task to Firestore instantly
                Navigator.pop(context);
              }
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Exam Planner
            const Text("Target Exam Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
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
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A67D8)),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A67D8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(_daysRemaining),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 2. Smart Attendance Calculator
            const Text("75% Attendance Predictor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _attendedCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Classes Attended", border: OutlineInputBorder()),
                          onChanged: (v) => _calculateAttendance(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _totalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Total Conducted", border: OutlineInputBorder()),
                          onChanged: (v) => _calculateAttendance(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _messageColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _messageColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _attendanceMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _messageColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Persistent Daily Tasks
            // 3. Persistent Daily Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Daily Targets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF5A67D8), size: 28),
                  onPressed: _addNewTask, // Triggers the popup
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_dailyTasks.length, (index) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black12), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ListTile(
                  // 1. Checkbox on the left
                  leading: Checkbox(
                    activeColor: const Color(0xFF5A67D8),
                    value: _dailyTasks[index]["isDone"],
                    onChanged: (bool? value) {
                      setState(() {
                        // Just toggle the completed status
                        _dailyTasks[index]["isDone"] = value!;
                      });
                      _saveData(); // Save status to Firebase
                    },
                  ),
                  
                  // 2. Task Text (with strikethrough if done)
                  title: Text(
                    _dailyTasks[index]["task"],
                    style: TextStyle(
                      decoration: _dailyTasks[index]["isDone"] ? TextDecoration.lineThrough : null,
                      color: _dailyTasks[index]["isDone"] ? Colors.grey : Colors.black,
                    ),
                  ),
                  
                  // 3. Dedicated Delete Button on the right
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        // Remove the task completely
                        _dailyTasks.removeAt(index);
                      });
                      _saveData(); // Update Firebase immediately
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Task deleted! 🗑️"),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
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