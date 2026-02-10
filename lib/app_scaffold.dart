import 'package:flutter/material.dart';
import 'package:servicewiseapplication/webview_screen.dart';

/// Root scaffold that picks the right WebView implementation per platform.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(child: WebViewScreen()),
    );
  }
}
