import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// All files with the `.dart` extension in the folder and its subfolders.
List<File> dartFilesIn(String path) {
  final directory = Directory(path);
  expect(directory.existsSync(), isTrue, reason: "no such folder $path");
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith(".dart"))
      .toList();
}

void main() {
  test('game mechanics does not depend on Flutter', () {
    final files = [
      ...dartFilesIn("lib/models"),
      ...dartFilesIn("lib/logic"),
    ];
    expect(files.length, greaterThanOrEqualTo(7));

    for (final file in files) {
      final source = file.readAsStringSync();
      expect(
        source.contains("package:flutter"),
        isFalse,
        reason: "${file.path} imports Flutter",
      );
      expect(
        source.contains("dart:ui"),
        isFalse,
        reason: "${file.path} imports dart:ui",
      );
    }
  });

  test('screens and widgets do not hold game rules', () {
    for (final file in dartFilesIn("lib/widgets")) {
      final source = file.readAsStringSync();
      expect(
        source.contains("logic/game_engine.dart"),
        isFalse,
        reason: "${file.path} pulls the engine into rendering",
      );
    }
  });
}
