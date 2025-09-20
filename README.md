
# 🚀 Flutter Build Automation Script

This repository includes a custom build system for Flutter projects using `build.bat` and `tool/increment_build.dart`. It simplifies versioning and packaging for Android and Windows builds.


_The advantage of this custom `build.bat + increment_build.dart` system is that it automates a lot of repetitive work when developing Flutter apps — especially if you target multiple platforms (Android + Windows). Instead of remembering commands or manually bumping build numbers, everything is scripted._

## 📌 Features

- 🔢 Automatic versioning
    - Increments pubspec.yaml build number on every build.
    - Option to reset the build number.
    - Updates setup.iss (Inno Setup) automatically with the latest version.

- 📱 Cross-platform builds
    - Build Android APKs (debug / release).
    - Build Windows installers via Inno Setup (.exe).
    - Option to build both Android & Windows in one command.

- ⚙️ Configurable Flutter/Dart path
    - Use specific Flutter/Dart SDK versions (pinned in the script).
    - Or fallback to global flutter and dart commands in PATH.

- 📦 Custom file naming
    - Build outputs are renamed using a standard pattern:
    ```
    <AppName>(<version+build>)_<timestamp>.apk
    <AppName>(<version+build>)_<timestamp>.exe
    ```
## 🔧 Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Inno Setup](https://jrsoftware.org/isinfo.php) (for Windows builds)

## ▶️ Usage

Run the build script with parameters:
```
build.bat [debug|release|reset] [platform]
```

Examples
```
build.bat debug android    :: Build a debug APK for Android
build.bat release windows  :: Build a release EXE for Windows (runs Inno Setup)
build.bat release both     :: Build release builds for both Android and Windows
build.bat reset            :: Reset build number in pubspec.yaml
```

## ⚙️ Configuration

At the top of build.bat, you can configure Flutter/Dart usage:
```
:: true  = use specific Flutter/Dart SDK version
:: false = use global flutter/dart from PATH
set "USE_SPECIFIED=true"
```
If USE_SPECIFIED=true, it will use the pinned SDK:
```
set "FLUTTER_HOME=D:\Android\flutter_3.13.9\bin"
set "FLUTTER=%FLUTTER_HOME%\flutter.bat"
set "DART=%FLUTTER_HOME%\cache\dart-sdk\bin\dart.exe"
```
If USE_SPECIFIED=false, it falls back to:
```
set "FLUTTER=flutter"
set "DART=dart"
```

## 📂 Output

- Android builds: saved to the project root as
`MyApp(1.0.2+6)_20250920.154812.apk`

- Windows builds: saved to the project root as
`MyApp(1.0.2+6)_20250920.154812.exe`