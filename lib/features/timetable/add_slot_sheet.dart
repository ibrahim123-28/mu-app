import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSlotSheet extends StatefulWidget {
  final String classId;
  final String initialDay; // 🚀 Received from Dashboard

  const AddSlotSheet({super.key, required this.classId, required this.initialDay});

  @override
  State<AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<AddSlotSheet> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  
  late String _selectedDay; // Will be initialized in initState
  String _selectedType = "Lecture";
  
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  
  bool _isLoading = false;

  List<String> _savedSubjects = [];
  List<String> _savedTeachers = [];
  List<String> _savedRooms = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay; // 🚀 Auto-sync day from top scroller
    _fetchSavedData();
  }

  Future<void> _fetchSavedData() async {
    final doc = await FirebaseFirestore.instance.collection('classes').doc(widget.classId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      setState(() {
        _savedSubjects = List<String>.from(data['saved_subjects'] ?? []);
        _savedTeachers = List<String>.from(data['saved_teachers'] ?? []);
        _savedRooms = List<String>.from(data['saved_rooms'] ?? []);
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hours:$minutes $period";
  }

  int _timeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      int m = int.parse(hm[1]);
      if (parts[1] == 'PM' && h != 12) h += 12;
      if (parts[1] == 'AM' && h == 12) h = 0;
      return h * 60 + m;
    } catch (e) {
      return 0;
    }
  }

  // 🚀 SHOW PROFESSIONAL CLASH POPUP DIALOG
  void _showClashPopup(Map<String, dynamic> conflict, String clashTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(clashTitle, style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("This slot conflicts with an existing schedule:", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📚 Subject: ${conflict['subject_name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text("👨‍🏫 Professor: ${conflict['teacher_name']}", style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("📍 Room/Lab: ${conflict['room_id']} (${conflict['type'] ?? 'Lecture'})", style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("⏰ Time: ${conflict['start_time']} - ${conflict['end_time']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A67D8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Okay, Change Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _checkClashAndSave() async {
    if (_subjectController.text.isEmpty || _teacherController.text.isEmpty || _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all details!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String startTimeStr = _formatTime(_startTime);
      final String endTimeStr = _formatTime(_endTime);
      final String room = _roomController.text.trim();
      final String teacher = _teacherController.text.trim();

      int newStart = _timeToMinutes(startTimeStr);
      int newEnd = _timeToMinutes(endTimeStr);

      if (newStart >= newEnd) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("End time must be after Start time!")));
        return;
      }

      // Fetch all existing slots for this class and this specific day
      final daySlots = await FirebaseFirestore.instance
          .collection('timetable_slots')
          .where('class_id', isEqualTo: widget.classId)
          .where('day_of_week', isEqualTo: _selectedDay)
          .get();

      for (var doc in daySlots.docs) {
        final existingData = doc.data() as Map<String, dynamic>;
        int existingStart = _timeToMinutes(existingData['start_time']);
        int existingEnd = _timeToMinutes(existingData['end_time']);
        
        // 🚀 Strict Overlap Math formula: (StartA < EndB) && (EndA > StartB)
        bool isOverlapping = (newStart < existingEnd && newEnd > existingStart);

        if (isOverlapping) {
          setState(() => _isLoading = false);
          
          // 1. Check if student batch is already booked at this exact time slot
          // (Ek student ek hi waqt me do alag lecture/lab attend nahi kar sakta)
          _showClashPopup(existingData, "Time Clash Detected! ❌ (Already busy)");
          return;
        }
      }

      // ALL CLEAR! SAVE TO DATABASE
      await FirebaseFirestore.instance.collection('timetable_slots').add({
        'class_id': widget.classId,
        'subject_name': _subjectController.text.trim(),
        'teacher_name': teacher,
        'room_id': room,
        'day_of_week': _selectedDay,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'type': _selectedType,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Save to autocomplete lists
      await FirebaseFirestore.instance.collection('classes').doc(widget.classId).set({
        'saved_subjects': FieldValue.arrayUnion([_subjectController.text.trim()]),
        'saved_teachers': FieldValue.arrayUnion([teacher]),
        'saved_rooms': FieldValue.arrayUnion([room]),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Slot Added Successfully! ✅"), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            
            const Text("Add New Slot", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5A67D8))),
            const SizedBox(height: 20),

            // Subject & Teacher
            Row(
              children: [
                Expanded(child: _buildAutoComplete("Subject", Icons.book, _savedSubjects, _subjectController)),
                const SizedBox(width: 12),
                Expanded(child: _buildAutoComplete("Teacher", Icons.person, _savedTeachers, _teacherController)),
              ],
            ),
            const SizedBox(height: 16),

            // Room & Type
            Row(
              children: [
                Expanded(child: _buildAutoComplete("Room / Lab", Icons.meeting_room, _savedRooms, _roomController)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: ["Lecture", "Lab"].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Day Selector (Auto-synced with top bar)
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF5A67D8)), filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              items: const [
                DropdownMenuItem(value: "1", child: Text("Monday")),
                DropdownMenuItem(value: "2", child: Text("Tuesday")),
                DropdownMenuItem(value: "3", child: Text("Wednesday")),
                DropdownMenuItem(value: "4", child: Text("Thursday")),
                DropdownMenuItem(value: "5", child: Text("Friday")),
                DropdownMenuItem(value: "6", child: Text("Saturday")),
              ],
              onChanged: (val) => setState(() => _selectedDay = val!),
            ),
            const SizedBox(height: 16),

            // Time Pickers
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _startTime);
                      if (time != null) setState(() => _startTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: const Color(0xFFEBF4FF), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text("Start Time", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(_formatTime(_startTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5A67D8))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _endTime);
                      if (time != null) setState(() => _endTime = time);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: const Color(0xFFEBF4FF), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text("End Time", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(_formatTime(_endTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5A67D8))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A67D8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _isLoading ? null : _checkClashAndSave,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Check & Save", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoComplete(String hint, IconData icon, List<String> options, TextEditingController parentController) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return options;
        return options.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) => parentController.text = selection,
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        controller.addListener(() => parentController.text = controller.text);
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF5A67D8)),
            filled: true, fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        );
      },
    );
  }
}