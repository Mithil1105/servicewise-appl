import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    show AndroidWebViewController, AndroidWebViewWidgetCreationParams, FileSelectorMode;
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webview_screen.dart';

/// True when running on Windows, macOS, or Linux (not web, not mobile).
bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

/// Desktop-only: EagerGestureRecognizer (pointer) + Pan + Scale so touchpad two-finger scroll
/// and mouse wheel reach the native WebView. Touchpad sends PointerPanZoom, not PointerScroll.
final _desktopGestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
  Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
};

/// Mobile (Android/iOS): unchanged — Eager so WebView receives touch events.
final _webViewGestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
};

/// WebView body for Android, iOS, and macOS using webview_flutter.
class MobileWebViewBody extends StatefulWidget {
  const MobileWebViewBody({super.key});

  @override
  State<MobileWebViewBody> createState() => _MobileWebViewBodyState();
}

class _MobileWebViewBodyState extends State<MobileWebViewBody> {
  late final WebViewController _controller;
  bool _permissionsHandled = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _requestPermissionsAndLoad();
  }

  WebViewController _createController() {
    final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (_) {},
          onPageStarted: (_) {},
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (e) {
            if ((e.isForMainFrame ?? false) && mounted) {
              setState(() => _error = e.description);
            }
          },
          onNavigationRequest: (request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(kServiceWiseUrl));

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      _setupAndroidFileUpload(platform);
      platform.setVerticalScrollBarEnabled(true);
      platform.setHorizontalScrollBarEnabled(true);
    }

    return controller;
  }

  void _setupAndroidFileUpload(AndroidWebViewController android) {
    android.setOnShowFileSelector((params) async {
      final accept = params.acceptTypes.join(' ').toLowerCase();
      final type = accept.contains('image')
          ? FileType.image
          : accept.contains('video')
              ? FileType.video
              : FileType.any;
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: params.mode == FileSelectorMode.openMultiple,
      );
      if (result == null || result.files.isEmpty) return <String>[];
      return result.files
          .where((f) => f.path != null)
          .map((f) => 'file://${f.path}')
          .toList();
    });
  }

  Future<void> _requestPermissionsAndLoad() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      setState(() => _permissionsHandled = true);
      return;
    }

    final permissions = <Permission>[
      Permission.storage,
      Permission.photos,
      Permission.camera,
      Permission.microphone,
    ];

    await permissions.request();
    if (!mounted) return;
    setState(() => _permissionsHandled = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsHandled) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  setState(() => _error = null);
                  _controller.loadRequest(Uri.parse(kServiceWiseUrl));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: _buildWebViewWidget(),
        ),
        if (_loading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: LinearProgressIndicator(),
            ),
          ),
      ],
    );
  }

  /// Builds WebView widget. Desktop: Eager + Pan + Scale so touchpad (pan/zoom) and mouse wheel reach native WebView. Mobile: unchanged.
  Widget _buildWebViewWidget() {
    final gestureRecognizers = isDesktop
        ? _desktopGestureRecognizers
        : _webViewGestureRecognizers;

    if (Platform.isAndroid && _controller.platform is AndroidWebViewController) {
      final platform = _controller.platform as AndroidWebViewController;
      final params = AndroidWebViewWidgetCreationParams(
        controller: platform,
        layoutDirection: TextDirection.ltr,
        gestureRecognizers: gestureRecognizers,
        displayWithHybridComposition: true,
      );
      return WebViewWidget.fromPlatformCreationParams(params: params);
    }
    return WebViewWidget(
      controller: _controller,
      gestureRecognizers: gestureRecognizers,
    );
  }
}
