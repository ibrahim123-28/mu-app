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

  late String _finalUrl;

  @override
  void initState() {
    super.initState();
    
    // 🚀 Smart Link Transformer Logic
    _finalUrl = _getFormattedPdfUrl(widget.pdfUrl, kIsWeb);

    // WebView sirf tabhi initialize hoga jab app Mobile par ho
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() { isWebViewLoading = true; });
            },
            onPageFinished: (String url) {
              if (mounted) setState(() { isWebViewLoading = false; });
            },
          ),
        )
        ..loadRequest(Uri.parse(_finalUrl));
    }
  }

  // 🚀 HELPER: Extracts Google Drive File ID & formats for Web/Mobile
  String _getFormattedPdfUrl(String rawUrl, bool isWeb) {
    String? fileId;

    // File ID extract kar rahe hain (Har format se)
    if (rawUrl.contains('/file/d/')) {
      final match = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(rawUrl);
      if (match != null) fileId = match.group(1);
    } else if (rawUrl.contains('id=')) {
      final match = RegExp(r'id=([a-zA-Z0-9_-]+)').firstMatch(rawUrl);
      if (match != null) fileId = match.group(1);
    }

    // Agar Drive link mili hai:
    if (fileId != null) {
      if (isWeb) {
        // Web Syncfusion requires DIRECT raw PDF link
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      } else {
        // Mobile WebView requires Google Docs Embedded Viewer
        return 'https://docs.google.com/viewer?url=${Uri.encodeComponent('https://drive.google.com/uc?export=download&id=$fileId')}&embedded=true';
      }
    }

    // Direct PDF hai toh as-it-is bhej do
    return rawUrl;
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
              _finalUrl,
              canShowScrollHead: false,
              onDocumentLoaded: (details) {
                if (mounted) setState(() { isWebPdfLoading = false; });
              },
              onDocumentLoadFailed: (details) {
                if (mounted) setState(() { isWebPdfLoading = false; });
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