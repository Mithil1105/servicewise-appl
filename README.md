# ServiceWise Application

A Flutter app that wraps [ServiceWise](https://servicewise.unimisk.com/) in a WebView, with file access and permissions configured for all supported platforms.

## Supported platforms

| Platform | WebView / behavior |
|----------|--------------------|
| **Android** | `webview_flutter` with file upload via file picker |
| **iOS** | `webview_flutter` (WKWebView) |
| **macOS** | `webview_flutter` (WKWebView) |
| **Windows** | `webview_windows` (WebView2) |
| **Linux** | Opens the site in the default browser (no in-app WebView) |

## Running the app

### Android
```bash
flutter run
# or
flutter run -d <android-device-id>
```
- **Permissions:** On first run the app may request storage, photos, camera, and microphone so the website can use file upload and media when needed.

### iOS
```bash
flutter run -d <ios-device-or-simulator>
```
- **Info.plist** already includes usage descriptions for photo library, camera, and microphone.

### macOS
```bash
flutter run -d macos
```
- **Entitlements:** Network client and user-selected file read/write are enabled so the WebView and file uploads work.

### Windows
```bash
flutter run -d windows
```
- **Requirement:** [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/) must be installed (usually present on Windows 10/11).
- File and media permission prompts from the site are handled in-app (allowed by default).

### Linux
```bash
flutter run -d linux
```
- The app shows a single screen with a button **“Open ServiceWise in browser”** and opens the site in your default browser (no in-app WebView on Linux).

## File access and permissions

- **Android:** `AndroidManifest.xml` declares `INTERNET`, storage/media (including scoped storage for API 33+), camera, and microphone. File uploads in the WebView use a file picker and `setOnShowFileSelector` (via `file_picker`).
- **iOS / macOS:** `Info.plist` includes `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` (and photo add on iOS). The app requests storage/photos/camera/microphone at startup on mobile so the website can use them when the user chooses.
- **Windows:** WebView2 permission requests (e.g. file access) are handled in the `permissionRequested` callback and are allowed so the site can function fully.
- **Linux:** Opening in the browser uses the system’s default handler; no extra app permissions are required.

## Building for release

- **Android:** `flutter build apk` or `flutter build appbundle`
- **iOS:** `flutter build ios`
- **macOS:** `flutter build macos`
- **Windows:** `flutter build windows`
- **Linux:** `flutter build linux`

## Project structure

- `lib/main.dart` – App entry and `MaterialApp`.
- `lib/app_scaffold.dart` – Root scaffold with app bar.
- `lib/webview_screen.dart` – Chooses WebView implementation by platform (mobile, Windows, Linux fallback).
- `lib/webview_mobile.dart` – WebView for Android/iOS/macOS (`webview_flutter`), with Android file upload and permission handling.
- `lib/webview_windows_impl.dart` – WebView for Windows (`webview_windows`), with permission callback.
