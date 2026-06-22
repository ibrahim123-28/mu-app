import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // WebView Controller Setup
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Google Drive ko JavaScript chahiye hoti hai
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() { isLoading = true; });
          },
          onPageFinished: (String url) {
            setState(() { isLoading = false; }); // Page load hote hi loading spinner band
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.pdfUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      // Stack use kar rahe hain taaki WebView ke upar Loading Spinner dikha sakein
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
        ],
      ),
    );
  }
}