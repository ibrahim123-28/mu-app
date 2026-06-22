import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/services/auth_service.dart';

class ResumeBuilderScreen extends ConsumerStatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  ConsumerState<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen> {
  int _currentStep = 0;
  bool _isLoading = true;

  // --- FORM CONTROLLERS ---
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _linkedinCtrl = TextEditingController();
  final TextEditingController _githubCtrl = TextEditingController();
  final TextEditingController _summaryCtrl = TextEditingController();
  final TextEditingController _techSkillsCtrl = TextEditingController();
  final TextEditingController _toolsCtrl = TextEditingController();
  final TextEditingController _experienceCtrl = TextEditingController();
  final TextEditingController _projectsCtrl = TextEditingController();
  final TextEditingController _eduCtrl = TextEditingController();
  final TextEditingController _certCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadResumeData();
  }

  // --- 1. FIREBASE: LOAD DATA ---
  Future<void> _loadResumeData() async {
    final userDoc = await ref.read(userProvider.future);
    final userData = userDoc?.data() as Map<String, dynamic>?;
    final resumeData = userData?['resume'] as Map<String, dynamic>? ?? {};

    if (mounted) {
      setState(() {
        _nameCtrl.text = resumeData['name'] ?? '';
        _emailCtrl.text = resumeData['email'] ?? '';
        _phoneCtrl.text = resumeData['phone'] ?? '';
        _linkedinCtrl.text = resumeData['linkedin'] ?? '';
        _githubCtrl.text = resumeData['github'] ?? '';
        _summaryCtrl.text = resumeData['summary'] ?? '';
        _techSkillsCtrl.text = resumeData['tech_skills'] ?? '';
        _toolsCtrl.text = resumeData['tools'] ?? '';
        _experienceCtrl.text = resumeData['experience'] ?? '';
        _projectsCtrl.text = resumeData['projects'] ?? '';
        _eduCtrl.text = resumeData['education'] ?? '';
        _certCtrl.text = resumeData['certifications'] ?? '';
        
        _isLoading = false;
      });
    }
  }

  // --- 2. FIREBASE: AUTO-SAVE DATA ---
  Future<void> _saveResumeData() async {
    await ref.read(authServiceProvider).saveResumeData({
      'name': _nameCtrl.text,
      'email': _emailCtrl.text,
      'phone': _phoneCtrl.text,
      'linkedin': _linkedinCtrl.text,
      'github': _githubCtrl.text,
      'summary': _summaryCtrl.text,
      'tech_skills': _techSkillsCtrl.text,
      'tools': _toolsCtrl.text,
      'experience': _experienceCtrl.text,
      'projects': _projectsCtrl.text,
      'education': _eduCtrl.text,
      'certifications': _certCtrl.text,
    });
  }

  // --- 3. REFINED ATS PDF GENERATOR ENGINE ---
  Future<pw.Document> _generateAtsResume() async {
    final pdf = pw.Document();
    
    // Clean, professional fonts
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    
    // Refined color palette (Dark Navy for headings, rich charcoal for text)
    final primaryNavy = PdfColor.fromHex('#1B263B'); 
    final accentLine = PdfColor.fromHex('#415A77');
    final darkCharcoal = PdfColor.fromHex('#2D2D2D');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 45, vertical: 40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      _nameCtrl.text.isEmpty ? "YOUR FULL NAME" : _nameCtrl.text.toUpperCase(),
                      style: pw.TextStyle(font: fontBold, fontSize: 26, color: primaryNavy, letterSpacing: 1.5),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      _buildContactLine(),
                      style: pw.TextStyle(font: font, fontSize: 10, color: darkCharcoal),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // --- DYNAMIC SECTIONS ---
              _buildRefinedSection("PROFESSIONAL SUMMARY", _summaryCtrl.text, primaryNavy, accentLine, font, fontBold),
              _buildRefinedSection("TECHNICAL SKILLS", _buildSkillsText(), primaryNavy, accentLine, font, fontBold),
              _buildRefinedSection("WORK EXPERIENCE", _experienceCtrl.text, primaryNavy, accentLine, font, fontBold),
              _buildRefinedSection("PROJECTS", _projectsCtrl.text, primaryNavy, accentLine, font, fontBold),
              _buildRefinedSection("EDUCATION", _eduCtrl.text, primaryNavy, accentLine, font, fontBold),
              _buildRefinedSection("CERTIFICATIONS & ACHIEVEMENTS", _certCtrl.text, primaryNavy, accentLine, font, fontBold),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  String _buildContactLine() {
    List<String> contacts = [];
    if (_phoneCtrl.text.isNotEmpty) contacts.add(_phoneCtrl.text);
    if (_emailCtrl.text.isNotEmpty) contacts.add(_emailCtrl.text);
    if (_linkedinCtrl.text.isNotEmpty) contacts.add(_linkedinCtrl.text);
    if (_githubCtrl.text.isNotEmpty) contacts.add(_githubCtrl.text);
    return contacts.join("  •  ");
  }

  String _buildSkillsText() {
    String skills = "";
    if (_techSkillsCtrl.text.isNotEmpty) skills += "Languages/Frameworks: ${_techSkillsCtrl.text}\n";
    if (_toolsCtrl.text.isNotEmpty) skills += "Tools/Cloud: ${_toolsCtrl.text}";
    return skills.trim();
  }

  // Refined Section Builder
  pw.Widget _buildRefinedSection(String title, String content, PdfColor headingColor, PdfColor lineColor, pw.Font font, pw.Font fontBold) {
    if (content.trim().isEmpty) return pw.SizedBox.shrink();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(font: fontBold, fontSize: 13, color: headingColor, letterSpacing: 1.2),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 10),
          height: 1.2,
          color: lineColor,
        ),
        pw.Text(
          content,
          style: pw.TextStyle(font: font, fontSize: 10.5, color: PdfColors.black, lineSpacing: 1.6),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _linkedinCtrl.dispose(); _githubCtrl.dispose(); _summaryCtrl.dispose();
    _techSkillsCtrl.dispose(); _toolsCtrl.dispose(); _experienceCtrl.dispose();
    _projectsCtrl.dispose(); _eduCtrl.dispose(); _certCtrl.dispose();
    super.dispose();
  }

  // --- 4. THE UI (STEPPER) ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("ATS Resume Builder", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Theme(
        data: ThemeData(colorScheme: const ColorScheme.light(primary: Color(0xFF5A67D8))),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            _saveResumeData(); // Auto-Save trigger
            final isLastStep = _currentStep == 4;
            if (isLastStep) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfPreviewScreen(
                    pdfFuture: _generateAtsResume(),
                    fileName: '${_nameCtrl.text.replaceAll(' ', '_')}_Resume.pdf',
                  ),
                ),
              );
            } else {
              setState(() => _currentStep += 1);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep -= 1);
          },
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            final isLastStep = _currentStep == 4;
            return Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A67D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? "View Live Preview" : "Save & Next", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: details.onStepCancel,
                        child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              isActive: _currentStep >= 0,
              title: const Text("Contact Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                children: [
                  _buildTextField(_nameCtrl, "Full Name"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_emailCtrl, "Email")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_phoneCtrl, "Phone")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_linkedinCtrl, "LinkedIn URL (Optional)"),
                  const SizedBox(height: 12),
                  _buildTextField(_githubCtrl, "GitHub URL (Optional)"),
                ],
              ),
            ),
            Step(
              isActive: _currentStep >= 1,
              title: const Text("Summary & Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                children: [
                  _buildTextField(_summaryCtrl, "Professional Summary (2-4 lines)", maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(_techSkillsCtrl, "Languages & Frameworks (e.g. Python, Flutter, React)"),
                  const SizedBox(height: 12),
                  _buildTextField(_toolsCtrl, "Tools & Cloud (e.g. Git, AWS, Firebase, Docker)"),
                ],
              ),
            ),
            Step(
              isActive: _currentStep >= 2,
              title: const Text("Work Experience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: _buildTextField(
                _experienceCtrl, 
                "Format:\nJob Title | Company | Duration\n• Action Verb + Task + Metric (e.g., Developed API reducing load time by 30%)", 
                maxLines: 6
              ),
            ),
            Step(
              isActive: _currentStep >= 3,
              title: const Text("Projects", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: _buildTextField(
                _projectsCtrl, 
                "Format:\nProject Name | Tech Stack\n• Impact Point 1\n• Impact Point 2", 
                maxLines: 6
              ),
            ),
            Step(
              isActive: _currentStep >= 4,
              title: const Text("Education & Certifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                children: [
                  _buildTextField(_eduCtrl, "Degree | University | CGPA", maxLines: 2),
                  const SizedBox(height: 12),
                  _buildTextField(_certCtrl, "Certifications & Achievements (Optional)", maxLines: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF5A67D8), width: 2)),
      ),
    );
  }
}

// ==========================================
// IN-APP LIVE PDF PREVIEWER
// ==========================================
class PdfPreviewScreen extends StatelessWidget {
  final Future<pw.Document> pdfFuture;
  final String fileName;

  const PdfPreviewScreen({super.key, required this.pdfFuture, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A67D8),
        title: const Text("Resume Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<pw.Document>(
        future: pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return PdfPreview(
              build: (format) => snapshot.data!.save(),
              pdfFileName: fileName,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            );
          }
          return const Center(child: Text("Error generating preview."));
        },
      ),
    );
  }
}