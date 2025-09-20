import 'dart:io';

void main(List<String> args) {
  final pubspec = File('pubspec.yaml');
  final pubspecContent = pubspec.readAsStringSync();

  final regex = RegExp(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)');
  final match = regex.firstMatch(pubspecContent);

  if (match == null) {
    print('⚠️ No version found in pubspec.yaml');
    exit(1);
  }

  final versionName = match.group(1)!;   // e.g. 1.0.1
  final buildNumber = int.parse(match.group(2)!);

  // Handle reset option
  if (args.contains('--reset')) {
    final newVersion = 'version: $versionName+1';
    pubspec.writeAsStringSync(pubspecContent.replaceFirst(regex, newVersion));
    print('✅ Reset build number: $newVersion');
    return;
  }

  // Increment build number
  final newBuild = buildNumber + 1;
  final newVersion = 'version: $versionName+$newBuild';
  final updatedPubspec = pubspecContent.replaceFirst(regex, newVersion);
  pubspec.writeAsStringSync(updatedPubspec);

  print('✅ Updated version: $newVersion');

  // Also update setup.iss MyAppVersion with full version (including +build)
  final setupFile = File('setup.iss');
  if (setupFile.existsSync()) {
    var setupContent = setupFile.readAsStringSync();

    // Replace line: #define MyAppVersion "..."
    final setupRegex = RegExp(r'#define MyAppVersion\s+"[^"]+"');
    setupContent = setupContent.replaceFirst(
      setupRegex,
      '#define MyAppVersion "$versionName+$newBuild"',
    );

    setupFile.writeAsStringSync(setupContent);
    print('✅ Updated setup.iss → MyAppVersion = $versionName+$newBuild');
  }
}
