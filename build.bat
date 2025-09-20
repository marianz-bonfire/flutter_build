@echo off
setlocal enabledelayedexpansion

:: ==============================
:: CONFIG - set your Flutter SDK path here
:: ==============================
set "ROOT_DIR=%~dp0"


:: Toggle between specified SDK and global command
:: true  = use the specific Flutter/Dart path
:: false = use system-wide flutter/dart
set "USE_SPECIFIED=true"

:: ----- SPECIFIED VERSION PATHS -----
set "FLUTTER_HOME=D:\Android\flutter_3.13.9\bin"
set "FLUTTER_SPEC=%FLUTTER_HOME%\flutter.bat"
set "DART_SPEC=%FLUTTER_HOME%\cache\dart-sdk\bin\dart.exe"

:: ----- GLOBAL COMMANDS -----
set "FLUTTER_GLOBAL=flutter"
set "DART_GLOBAL=dart"

:: ----- FINAL COMMANDS -----
if /i "%USE_SPECIFIED%"=="true" (
    set "FLUTTER=%FLUTTER_SPEC%"
    set "DART=%DART_SPEC%"
    echo "Using specified Flutter/Dart version at %FLUTTER_HOME%"
) else (
    set "FLUTTER=%FLUTTER_GLOBAL%"
    set "DART=%DART_GLOBAL%"
    echo "Using global Flutter/Dart commands"
)

:: Paths
set "APK_PATH=build\app\outputs\flutter-apk\app-release.apk"
set "WIN_PATH=build\windows\x64\runner\Release"

:: Inno Setup compiler location (adjust if needed)
set "INNO=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

:: ==============================
:: HELP
:: ==============================
if "%~1"=="" (
    echo.
    echo "Usage: build.bat [debug^|release^|reset] [android^|windows^|both]"
    echo.
    echo "Examples:"
    echo "  build.bat debug android   :: Build a debug APK for Android"
    echo "  build.bat release windows :: Build a release EXE for Windows (runs Inno Setup)"
    echo "  build.bat release both    :: Build release builds for both Android and Windows"
    echo "  build.bat reset           :: Reset build number in pubspec.yaml"
    echo.
    echo.
    exit /b 1
)

:: ==============================
:: RESET BUILD NUMBER
:: ==============================
if /i "%~1"=="reset" (
    "%DART%" run tool/increment_build.dart --reset
    exit /b 0
)

:: ==============================
:: INCREMENT BUILD NUMBER
:: ==============================
"%DART%" run tool/increment_build.dart

:: Extract version and trim spaces/newlines
for /f "tokens=2 delims=:" %%v in ('findstr /b "version:" pubspec.yaml') do (
    set "APP_VERSION=%%v"
)
for /f "tokens=* delims= " %%a in ("%APP_VERSION%") do set "APP_VERSION=%%a"
set "APP_VERSION=%APP_VERSION:"=%"   :: strip quotes if any

:: Extract app name and trim spaces
for /f "tokens=2 delims=:" %%n in ('findstr /b "name:" pubspec.yaml') do (
    set "APP_NAME=%%n"
)
for /f "tokens=* delims= " %%a in ("%APP_NAME%") do set "APP_NAME=%%a"
set "APP_NAME=%APP_NAME:"=%"

:: Get safe date (YYYYMMDD) and time (HHMMSS)
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value') do set ldt=%%i
set "DATESTAMP=%ldt:~0,8%.%ldt:~8,6%"



set "APK_NAME=%APP_NAME%(%APP_VERSION%)_%DATESTAMP%.apk"
:: echo "Android APK (%APK_NAME%)..."

:: ==============================
:: BUILD TYPE
:: ==============================
set "BUILD_TYPE=%~1"
set "TARGET=%~2"

if /i "%BUILD_TYPE%"=="debug" (
    set "BUILD_FLAG=--debug"
) else (
    if /i "%BUILD_TYPE%"=="release" (
        set "BUILD_FLAG=--release"
    ) else (
        echo "Invalid build type. Use: debug, release, or reset"
        exit /b 1
    )
)

if "%TARGET%"=="" set "TARGET=both"

:: ==============================
:: BUILD
:: ==============================
if /i "%TARGET%"=="android" (
    echo "Building Android APK (%BUILD_TYPE%)..."
    "%FLUTTER%" build apk %BUILD_FLAG%

    if /i "%BUILD_TYPE%"=="release" (
        if exist "%APK_PATH%" (
            echo "Copying APK to %ROOT_DIR%%APK_NAME%..."
            copy "%APK_PATH%" "%ROOT_DIR%%APK_NAME%" >nul
            echo "√ APK copied to %ROOT_DIR%%APK_NAME%"
        ) else (
            echo "⚠️ APK not found at %APK_PATH%"
        )
    )
)

if /i "%TARGET%"=="windows" (
    echo "Building Windows app (%BUILD_TYPE%)..."
    "%FLUTTER%" build windows %BUILD_FLAG%

    if /i "%BUILD_TYPE%"=="release" (
        echo "📦 Running Inno Setup..."
        "%INNO%" setup.iss
    )
)

if /i "%TARGET%"=="both" (
    echo "Building Android APK (%BUILD_TYPE%)..."
    "%FLUTTER%" build apk %BUILD_FLAG%
    if /i "%BUILD_TYPE%"=="release" (
        if exist "%APK_PATH%" (
            echo "Copying APK to %ROOT_DIR%%APK_NAME%..."
            copy "%APK_PATH%" "%ROOT_DIR%%APK_NAME%" >nul
            echo "√ APK copied to %ROOT_DIR%%APK_NAME%"
        ) else (
            echo "⚠️ APK not found at %APK_PATH%"
        )
    )

    echo "Building Windows app (%BUILD_TYPE%)..."
    "%FLUTTER%" build windows %BUILD_FLAG%
    if /i "%BUILD_TYPE%"=="release" (
        echo "📦 Running Inno Setup..."
        "%INNO%" setup.iss
    )
)

:: ==============================
:: DONE
:: ==============================
echo.
echo "✅ Build complete → Version %APP_VERSION%"
echo.
if exist "%APK_NAME%" (
    echo "📂 Open APK folder:"
    explorer /select,"%CD%\%APK_NAME%"
)

if exist "%WIN_PATH%\%APP_NAME%.exe" (
    echo "📂 Open Windows app folder:"
    explorer /select,"%CD%\%WIN_PATH%\%APP_NAME%.exe"
)

endlocal
