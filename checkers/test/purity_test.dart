import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Directories where any mention of Flutter is forbidden.
const List<String> pureFolders = ['lib/models', 'lib/logic', 'lib/ai'];

void main() {
  test('models, rules, and the bot do not depend on Flutter', () {
    final List<String> offenders = [];
    for (final folder in pureFolders) {
      final directory = Directory(folder);
      expect(directory.existsSync(), isTrue, reason: '$folder must exist');
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        final String source = entity.readAsStringSync();
        if (source.contains('package:flutter') ||
            source.contains("import 'dart:ui'")) {
          offenders.add(entity.path);
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('every pure directory has at least one file', () {
    for (final folder in pureFolders) {
      final files = Directory(folder)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      expect(files, isNotEmpty, reason: '$folder is empty');
    }
  });
}
