import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import 'webview_screen.dart';

/// WebView body for Windows using WebView2 (webview_windows).
/// Shown only when Platform.isWindows.
class WindowsWebViewBody extends StatefulWidget {
  const WindowsWebViewBody({super.key});

  @override
  State<WindowsWebViewBody> createState() => _WindowsWebViewBodyState();
}

class _WindowsWebViewBodyState extends State<WindowsWebViewBody> {
  final _controller = WebviewController();
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(const Color(0xFFFFFFFF));
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl(kServiceWiseUrl);
      if (!mounted) return;
      setState(() {
        _initialized = true;
        _error = null;
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _initialized = false;
        _error = e.toString();
      });
      debugPrint('WebView init error: $e\n$st');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
    String url,
    WebviewPermissionKind kind,
    bool isUserInitiated,
  ) async {
    // Allow file access, media, and other permissions the website may need
    return WebviewPermissionDecision.allow;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load WebView', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  setState(() => _error = null);
                  _initWebView();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (!_initialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading ServiceWise...'),
          ],
        ),
      );
    }
    return Stack(
      children: [
        Webview(
          _controller,
          permissionRequested: _onPermissionRequested,
        ),
        StreamBuilder<LoadingState>(
          stream: _controller.loadingState,
          builder: (context, snapshot) {
            if (snapshot.data == LoadingState.loading) {
              return const LinearProgressIndicator();
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
