import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

class CgpaCalculatorScreen extends ConsumerStatefulWidget {
  const CgpaCalculatorScreen({super.key});

  @override
  ConsumerState<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends ConsumerState<CgpaCalculatorScreen> {
  final List<TextEditingController> _sgpaControllers = List.generate(8, (_) => TextEditingController());
  double _finalCgpa = 0.00;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSgpas();
    for (var controller in _sgpaControllers) {
      controller.addListener(_calculateCGPA);
    }
  }

  // Load saved SGPAs from Firestore
  Future<void> _loadSavedSgpas() async {
    final userDoc = await ref.read(userProvider.future);
    final userData = userDoc?.data() as Map<String, dynamic>?;
    final savedSgpas = userData?['sgpas'] as Map<String, dynamic>? ?? {};

    setState(() {
      for (int i = 0; i < 8; i++) {
        if (savedSgpas.containsKey(i.toString())) {
          _sgpaControllers[i].text = savedSgpas[i.toString()].toString();
        }
      }
      _isLoading = false;
    });
    _calculateCGPA();
  }

  void _calculateCGPA() {
    double sum = 0.0;
    int validSemesters = 0;

    for (var controller in _sgpaControllers) {
      if (controller.text.isNotEmpty) {
        double? sgpa = double.tryParse(controller.text);
        if (sgpa != null && sgpa >= 0.0 && sgpa <= 10.0) {
          sum += sgpa;
          validSemesters++;
        }
      }
    }

    setState(() {
      _finalCgpa = validSemesters > 0 ? sum / validSemesters : 0.0;
    });
  }

  // Save the inputted SGPAs to Firestore
  Future<void> _saveToProfile() async {
    Map<String, double> sgpasToSave = {};
    for (int i = 0; i < 8; i++) {
      if (_sgpaControllers[i].text.isNotEmpty) {
        double? val = double.tryParse(_sgpaControllers[i].text);
        if (val != null) sgpasToSave[i.toString()] = val;
      }
    }

    await ref.read(authServiceProvider).saveAcademicRecords({'sgpas': sgpasToSave, 'cgpa': _finalCgpa});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Academic Records Saved! ✅"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _sgpaControllers) {
      controller.dispose();
    }
    super.dispose();
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
        title: const Text("Live CGPA Calculator", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildSgpaInputRow("Semester ${index + 1} SGPA", _sgpaControllers[index]),
                  );
                },
              ),
            ),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A67D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveToProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save to Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Live CGPA Display Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5A67D8).withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF5A67D8).withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  const Text("Your Expected CGPA", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    _finalCgpa.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF5A67D8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSgpaInputRow(String title, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(
          width: 80,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "0.0",
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF5A67D8), width: 2)),
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}