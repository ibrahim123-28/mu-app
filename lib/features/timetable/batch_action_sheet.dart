import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BatchActionSheet extends StatefulWidget {
  final String userId;

  const BatchActionSheet({super.key, required this.userId});

  @override
  State<BatchActionSheet> createState() => _BatchActionSheetState();
}

class _BatchActionSheetState extends State<BatchActionSheet> {
  bool _isJoinMode = true; // Toggle between Join and Create

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  String _generatedCode = "";
  bool _isLoading = false;

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    setState(() {
      _generatedCode = String.fromCharCodes(
        Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
      );
    });
  }

  void _shareToWhatsApp() {
    final text = "Hey! Join my class/group '${_batchNameController.text}' on Turing B.Sc. Use this code to join: $_generatedCode";
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invite text copied for WhatsApp! ✅"), backgroundColor: Color(0xFF5A67D8)),
    );
  }

  // 🚀 CREATE FLEXIBLE CLASS/GROUP
  Future<void> _createClass() async {
    if (_batchNameController.text.isEmpty || _generatedCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Code are required!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newClassRef = FirebaseFirestore.instance.collection('classes').doc();
      
      // 1. Create the class document
      await newClassRef.set({
        'class_name': _batchNameController.text.trim(),
        'description': _descController.text.trim(),
        'join_code': _generatedCode,
        'created_by': widget.userId,
        'created_at': FieldValue.serverTimestamp(),
        'members': [widget.userId], // Creator is automatically the first member
      });

      // 2. Add this class ID to the user's joined list
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'joined_classes': FieldValue.arrayUnion([newClassRef.id])
      }, SetOptions(merge: true)); // merge: true preserves old data like cgpa, planner

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Class Created! 🎉"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🚀 JOIN EXISTING CLASS/GROUP
  Future<void> _joinClass() async {
    final enteredCode = _codeController.text.trim().toUpperCase();
    if (enteredCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6-digit code.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('join_code', isEqualTo: enteredCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid Code! ❌"), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final classId = querySnapshot.docs.first.id;
      final className = querySnapshot.docs.first['class_name'];

      // 1. Add user to class members
      await FirebaseFirestore.instance.collection('classes').doc(classId).update({
        'members': FieldValue.arrayUnion([widget.userId])
      });

      // 2. Add class to user's joined list
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'joined_classes': FieldValue.arrayUnion([classId])
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Joined $className! 🎉"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),

          // 🚀 PREMIUM TOGGLE (Join vs Create)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isJoinMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isJoinMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isJoinMode ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)] : [],
                      ),
                      child: Center(child: Text("Join Class", style: TextStyle(fontWeight: FontWeight.bold, color: _isJoinMode ? const Color(0xFF5A67D8) : Colors.grey))),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isJoinMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isJoinMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !_isJoinMode ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)] : [],
                      ),
                      child: Center(child: Text("Create Class", style: TextStyle(fontWeight: FontWeight.bold, color: !_isJoinMode ? const Color(0xFF5A67D8) : Colors.grey))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // UI: JOIN CLASS
          // ==========================================
          if (_isJoinMode) ...[
            const Text("Class Code", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "e.g. FYCS26",
                filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
                counterText: "",
                prefixIcon: const Icon(Icons.qr_code, color: Color(0xFF5A67D8)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A67D8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: _isLoading ? null : _joinClass,
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Join Class", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ] 
          // ==========================================
          // UI: CREATE CLASS
          // ==========================================
          else ...[
            const Text("Class Name", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _batchNameController,
              decoration: InputDecoration(
                hintText: "e.g. DBMS Study Group",
                filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Code Generator
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF4FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF5A67D8).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _generatedCode.isEmpty ? "Tap to Generate Code ->" : _generatedCode,
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: _generatedCode.isEmpty ? 0 : 2,
                        color: _generatedCode.isEmpty ? Colors.grey : const Color(0xFF5A67D8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _generateCode,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF5A67D8), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.autorenew, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.wechat_rounded, color: Color(0xFF25D366)),
                      label: const Text("Invite", style: TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold)),
                      onPressed: _generatedCode.isEmpty ? null : _shareToWhatsApp,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5A67D8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      onPressed: _generatedCode.isEmpty || _isLoading ? null : _createClass,
                      child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Create", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}