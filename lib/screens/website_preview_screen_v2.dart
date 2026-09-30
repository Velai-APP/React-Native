import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsitePreviewScreen extends StatefulWidget {
  const WebsitePreviewScreen({
    super.key,
    required this.html,
    required this.projectId,
  });

  final String html;
  final String projectId;

  @override
  State<WebsitePreviewScreen> createState() => _WebsitePreviewScreenState();
}

class _WebsitePreviewScreenState extends State<WebsitePreviewScreen> {
  late final WebViewController _controller;

  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress;
            });
          },
        ),
      )
      ..loadHtmlString(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectId),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.loadHtmlString(widget.html);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
