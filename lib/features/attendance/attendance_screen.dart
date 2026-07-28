import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceScreen extends StatefulWidget {
  final String classId;
  final String subjectName;
  final String slotId;

  const AttendanceScreen({
    super.key,
    required this.classId,
    required this.subjectName,
    required this.slotId,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Color primaryColor = const Color(0xFF5A67D8);
  
  // Is map me hum store karenge ki kaunsa student present hai (true/false)
  Map<String, bool> attendanceData = {}; 
  bool _isLoading = true;
  List<String> _membersList = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  // 🚀 Fetch all students from the class
  Future<void> _fetchMembers() async {
    try {
      final classDoc = await FirebaseFirestore.instance.collection('classes').doc(widget.classId).get();
      if (classDoc.exists && classDoc.data() != null) {
        final data = classDoc.data()!;
        _membersList = List<String>.from(data['members'] ?? []);
        
        // By default, mark everyone as Present (true)
        for (var member in _membersList) {
          attendanceData[member] = true; 
        }
      }
    } catch (e) {
      debugPrint("Error fetching members: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🚀 Save Attendance to Firebase
  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    try {
      String todayDate = DateTime.now().toIso8601String().split('T')[0]; // Format: 2026-07-27
      String docId = "${widget.slotId}_$todayDate"; // Unique ID for this lecture's attendance

      await FirebaseFirestore.instance.collection('attendance').doc(docId).set({
        'class_id': widget.classId,
        'slot_id': widget.slotId,
        'subject': widget.subjectName,
        'date': todayDate,
        'records': attendanceData, // Saves mapping of StudentUID -> true/false
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance Saved Successfully! ✅"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPresent = attendanceData.values.where((val) => val == true).length;
    int totalAbsent = attendanceData.length - totalPresent;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text("Mark Attendance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Text(widget.subjectName, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              children: [
                // Stats Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn("Total", _membersList.length.toString(), Colors.black87),
                      Container(height: 30, width: 1, color: Colors.grey.shade300),
                      _buildStatColumn("Present", totalPresent.toString(), Colors.green),
                      Container(height: 30, width: 1, color: Colors.grey.shade300),
                      _buildStatColumn("Absent", totalAbsent.toString(), Colors.redAccent),
                    ],
                  ),
                ),
                
                // Student List
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _membersList.length,
                    itemBuilder: (context, index) {
                      String studentId = _membersList[index];
                      bool isPresent = attendanceData[studentId] ?? true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isPresent ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: SwitchListTile(
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.redAccent,
                          inactiveTrackColor: Colors.red.withValues(alpha: 0.2),
                          title: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
                            builder: (context, snapshot) {
                              String name = "Student (${studentId.substring(0, 5)}...)";
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                name = data['name'] ?? data['email'] ?? name;
                              }
                              return Text(name, style: const TextStyle(fontWeight: FontWeight.bold));
                            },
                          ),
                          subtitle: Text(isPresent ? "Present" : "Absent", style: TextStyle(color: isPresent ? Colors.green : Colors.redAccent, fontWeight: FontWeight.w600)),
                          value: isPresent,
                          onChanged: (val) {
                            setState(() {
                              attendanceData[studentId] = val;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _membersList.isEmpty ? null : _submitAttendance,
            child: const Text("Submit Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}