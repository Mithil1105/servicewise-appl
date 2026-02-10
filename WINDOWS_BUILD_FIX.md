# Fix: LNK1168 "cannot open .exe for writing"

## Cause
The Windows app (**servicewiseapplication.exe**) is still running. Windows locks the .exe while it’s in use, so the linker can’t overwrite it when you run `flutter run` again.

## Fix (do in order)

1. **Close the app**
   - Close the ServiceWise app window, or
   - If you started it from the terminal, press **Ctrl+C** in that terminal to stop it.

2. **Rebuild**
   ```bash
   flutter run -d windows
   ```

3. **If it still fails**
   - Make sure no other terminal/IDE has the app running.
   - Optionally do a clean build:
     ```bash
     flutter clean
     flutter pub get
     flutter run -d windows
     ```

## NuGet message
If you see "Nuget.exe not found" — that’s a warning. The build can still succeed. To fix NuGet for future builds, install it or add it to your PATH.
