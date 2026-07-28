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
  final TextEditingController _portfolioCtrl = TextEditingController(); // 🚀 NEW: Portfolio
  
  final TextEditingController _summaryCtrl = TextEditingController();
  final TextEditingController _courseworkCtrl = TextEditingController(); // 🚀 NEW: ATS Keywords
  
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
        _portfolioCtrl.text = resumeData['portfolio'] ?? '';
        
        _summaryCtrl.text = resumeData['summary'] ?? '';
        _courseworkCtrl.text = resumeData['coursework'] ?? '';
        
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
      'portfolio': _portfolioCtrl.text,
      'summary': _summaryCtrl.text,
      'coursework': _courseworkCtrl.text,
      'tech_skills': _techSkillsCtrl.text,
      'tools': _toolsCtrl.text,
      'experience': _experienceCtrl.text,
      'projects': _projectsCtrl.text,
      'education': _eduCtrl.text,
      'certifications': _certCtrl.text,
    });
  }

  // --- 3. PREMIUM ATS-COMPLIANT PDF GENERATOR ---
  Future<pw.Document> _generateAtsResume() async {
    final pdf = pw.Document();
    
    // Standard ATS-Safe Fonts
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    
    // Premium Corporate Colors
    final primaryColor = PdfColor.fromHex('#1A365D'); // Deep Navy Blue
    final darkGray = PdfColor.fromHex('#2D3748'); // Readability gray
    final lightLine = PdfColor.fromHex('#CBD5E0');

    pdf.addPage(
      pw.MultiPage( // Changed to MultiPage to handle long resumes automatically
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        build: (pw.Context context) {
          return [
            // --- HEADER: NAME & CONTACT ---
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    _nameCtrl.text.isEmpty ? "YOUR FULL NAME" : _nameCtrl.text.toUpperCase(),
                    style: pw.TextStyle(font: fontBold, fontSize: 22, color: primaryColor, letterSpacing: 1.2),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    _buildContactLine(),
                    style: pw.TextStyle(font: font, fontSize: 10, color: darkGray),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // --- SECTIONS ---
            _buildAtsSection("PROFESSIONAL SUMMARY", _summaryCtrl.text, primaryColor, lightLine, font, fontBold, isBullet: false),
            _buildAtsSection("EDUCATION", _eduCtrl.text, primaryColor, lightLine, font, fontBold, isBullet: true),
            _buildAtsSection("RELEVANT COURSEWORK", _courseworkCtrl.text, primaryColor, lightLine, font, fontBold, isBullet: false),
            _buildAtsSection("TECHNICAL SKILLS", _buildSkillsText(), primaryColor, lightLine, font, fontBold, isBullet: false),
            _buildAtsSection("EXPERIENCE", _experienceCtrl.text, primaryColor, lightLine, font, fontBold, isBullet: true),
            _buildAtsSection("PROJECTS", _projectsCtrl.text, primaryColor, lightLine, font, fontBold, isBullet: true),
            _buildAtsSection("CERTIFICATIONS & ACHIEVEMENTS", _certCtrl.text, primaryColor, lightLine, font, fontBold, isBullet: true),
          ];
        },
      ),
    );
    return pdf;
  }

  String _buildContactLine() {
    List<String> contacts = [];
    if (_phoneCtrl.text.isNotEmpty) contacts.add(_phoneCtrl.text);
    if (_emailCtrl.text.isNotEmpty) contacts.add(_emailCtrl.text);
    if (_linkedinCtrl.text.isNotEmpty) contacts.add(_linkedinCtrl.text.replaceAll('https://www.', ''));
    if (_githubCtrl.text.isNotEmpty) contacts.add(_githubCtrl.text.replaceAll('https://', ''));
    if (_portfolioCtrl.text.isNotEmpty) contacts.add(_portfolioCtrl.text.replaceAll('https://', ''));
    return contacts.join("  |  ");
  }

  String _buildSkillsText() {
    String skills = "";
    if (_techSkillsCtrl.text.isNotEmpty) skills += "Languages/Frameworks: ${_techSkillsCtrl.text}\n";
    if (_toolsCtrl.text.isNotEmpty) skills += "Tools & Databases: ${_toolsCtrl.text}";
    return skills.trim();
  }

  // 🚀 SMART ATS FORMATTER: Converts raw text dashes into neat PDF bullets
  pw.Widget _buildFormattedContent(String text, pw.Font font, pw.Font fontBold, bool isBullet) {
    final lines = text.split('\n');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return pw.SizedBox(height: 4);
        
        // If line starts with a bullet/dash, format it nicely
        if (line.trim().startsWith('-') || line.trim().startsWith('•') || line.trim().startsWith('*')) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3, left: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("•  ", style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.black)),
                pw.Expanded(
                  child: pw.Text(
                    line.substring(1).trim(), 
                    style: pw.TextStyle(font: font, fontSize: 10.5, color: PdfColors.grey900, lineSpacing: 1.4)
                  )
                ),
              ]
            ),
          );
        } else {
          // It's a heading (like Job Title or Degree)
          return pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6, bottom: 2),
            child: pw.Text(
              line.trim(), 
              style: pw.TextStyle(font: isBullet ? fontBold : font, fontSize: 11, color: PdfColors.black)
            ),
          );
        }
      }).toList(),
    );
  }

  pw.Widget _buildAtsSection(String title, String content, PdfColor headingColor, PdfColor lineColor, pw.Font font, pw.Font fontBold, {required bool isBullet}) {
    if (content.trim().isEmpty) return pw.SizedBox.shrink();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 12, color: headingColor, letterSpacing: 1.1)),
        pw.Container(margin: const pw.EdgeInsets.only(top: 4, bottom: 8), height: 1, color: lineColor),
        isBullet 
          ? _buildFormattedContent(content, font, fontBold, isBullet)
          : pw.Text(content, style: pw.TextStyle(font: font, fontSize: 10.5, color: PdfColors.grey900, lineSpacing: 1.5)),
        pw.SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _linkedinCtrl.dispose(); _githubCtrl.dispose(); _portfolioCtrl.dispose();
    _summaryCtrl.dispose(); _courseworkCtrl.dispose();
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
            _saveResumeData(); 
            final isLastStep = _currentStep == 5; // 🚀 Increased steps
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
            final isLastStep = _currentStep == 5;
            return Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A67D8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? "View ATS Resume" : "Save & Next", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
              title: const Text("Contact Info", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  _buildTextField(_nameCtrl, "Full Name (e.g., Ibrahim)"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_emailCtrl, "Email")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_phoneCtrl, "Phone")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(_linkedinCtrl, "LinkedIn URL"),
                  const SizedBox(height: 10),
                  _buildTextField(_githubCtrl, "GitHub URL"),
                  const SizedBox(height: 10),
                  _buildTextField(_portfolioCtrl, "Portfolio Website (Optional)"),
                ],
              ),
            ),
            Step(
              isActive: _currentStep >= 1,
              title: const Text("Summary & Coursework", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  _buildTextField(_summaryCtrl, "Professional Summary (Highly impactful 3 lines)", maxLines: 3),
                  const SizedBox(height: 10),
                  _buildTextField(_courseworkCtrl, "Relevant Coursework (e.g., Data Structures, Computer Networks, MERN, AI)"),
                ],
              ),
            ),
            Step(
              isActive: _currentStep >= 2,
              title: const Text("Technical Skills", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  _buildTextField(_techSkillsCtrl, "Languages & Frameworks (e.g., Python, React, Next.js, Node.js)"),
                  const SizedBox(height: 10),
                  _buildTextField(_toolsCtrl, "Tools & Cloud (e.g., Git, MongoDB, AWS, Figma)"),
                ],
              ),
            ),
            Step(
              isActive: _currentStep >= 3,
              title: const Text("Projects (Crucial for Tech)", style: TextStyle(fontWeight: FontWeight.bold)),
              content: _buildTextField(
                _projectsCtrl, 
                "Example Format:\nSmart ERP System | React, Node.js\n- Built an AI-powered study planner reducing prep time by 30%\n- Implemented secure Firebase authentication", 
                maxLines: 7
              ),
            ),
            Step(
              isActive: _currentStep >= 4,
              title: const Text("Work Experience", style: TextStyle(fontWeight: FontWeight.bold)),
              content: _buildTextField(
                _experienceCtrl, 
                "Example Format:\nFreelance Developer | Self-Employed | 2024 - Present\n- Developed 3+ scalable SaaS applications using MERN stack\n- Designed Bento-grid UIs improving user retention", 
                maxLines: 6
              ),
            ),
            Step(
              isActive: _currentStep >= 5,
              title: const Text("Education & Certifications", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                children: [
                  _buildTextField(_eduCtrl, "Example:\nB.Sc Computer Science | Mumbai University | 2026\n- CGPA: 8.5/10", maxLines: 3),
                  const SizedBox(height: 10),
                  _buildTextField(_certCtrl, "Certifications (e.g., AWS Cloud Practitioner, Meta Front-End)", maxLines: 3),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        title: const Text("Live Resume Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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