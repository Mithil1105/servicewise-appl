import 'package:flutter/material.dart';
import 'package:servicewiseapplication/webview_screen.dart';

/// Root scaffold that picks the right WebView implementation per platform.
/// Uses [SafeArea] so content stays below the status bar, notch/Dynamic Island
/// (iOS), and pinhole/cutout (Android) and above the home indicator/nav bar.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: const SizedBox.expand(child: WebViewScreen()),
      ),
    );
  }
}
