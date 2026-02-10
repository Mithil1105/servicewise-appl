import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'webview_mobile.dart';
import 'webview_windows_impl.dart';

const String kServiceWiseUrl = 'https://servicewise.unimisk.com/';

/// Single screen that shows the wrapped website.
/// Uses webview_flutter on Android/iOS/macOS, webview_windows on Windows,
/// and url_launcher on Linux. On web, shows open-in-browser.
class WebViewScreen extends StatelessWidget {
  const WebViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _LinuxFallback();
    }
    if (Platform.isLinux) {
      return const _LinuxFallback();
    }
    if (Platform.isWindows) {
      return const WindowsWebViewBody();
    }
    return const MobileWebViewBody();
  }
}

/// Linux: WebView not supported by webview_flutter; open in browser.
class _LinuxFallback extends StatelessWidget {
  const _LinuxFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 80, fit: BoxFit.contain),
            const SizedBox(height: 24),
            const Text(
              'ServiceWise',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'On Linux, the app opens ServiceWise in your default browser for the best experience.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _openInBrowser(),
              icon: const Icon(Icons.launch),
              label: const Text('Open ServiceWise in browser'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(kServiceWiseUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
