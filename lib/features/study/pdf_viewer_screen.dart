import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Syncfusion for Web
import '/features/ai_tutor/widgets/ai_hover_chat.dart'; // Tera Hover Bot

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late final WebViewController controller;
  bool isWebViewLoading = true;
  bool isWebPdfLoading = true;

  @override
  void initState() {
    super.initState();
    
    // WebView sirf tabhi initialize hoga jab app Mobile par ho
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() { isWebViewLoading = true; });
            },
            onPageFinished: (String url) {
              setState(() { isWebViewLoading = false; });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.pdfUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // 1. WEB UI (Uses Syncfusion)
    // ---------------------------------------------------------
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 16)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Stack(
          children: [
            // Syncfusion renderer for Web
            SfPdfViewer.network(
              widget.pdfUrl,
              canShowScrollHead: false,
              onDocumentLoaded: (details) {
                setState(() { isWebPdfLoading = false; });
              },
              onDocumentLoadFailed: (details) {
                setState(() { isWebPdfLoading = false; });
              },
            ),
            
            // Loading Spinner for Web
            if (isWebPdfLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),

            // Hover Chat Overlay!
            const AiHoverChat(),
          ],
        ),
      );
    }

    // ---------------------------------------------------------
    // 2. MOBILE UI (Uses WebView)
    // ---------------------------------------------------------
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // WebView renderer for Mobile
          WebViewWidget(controller: controller),
          
          // Loading Spinner for Mobile
          if (isWebViewLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
            
          // Hover Chat Overlay!
          const AiHoverChat(),
        ],
      ),
    );
  }
}