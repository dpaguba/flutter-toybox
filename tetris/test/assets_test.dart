import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the brand typeface ships inside the app, not from the network', () {
    expect(
      File("fonts/Michroma-Regular.ttf").existsSync(),
      isTrue,
      reason: "no typeface file found",
    );
    final String pubspec = File("pubspec.yaml").readAsStringSync();
    expect(pubspec.contains("family: Michroma"), isTrue);
    expect(pubspec.contains("fonts/Michroma-Regular.ttf"), isTrue);
  });

  test('the typeface licence sits next to the typeface', () {
    final File licence = File("fonts/OFL.txt");
    expect(licence.existsSync(), isTrue);
    expect(licence.readAsStringSync().contains("Open Font License"), isTrue);
  });

  test('no screen pulls fonts from the network', () {
    final files = Directory("lib")
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith(".dart"));
    for (final file in files) {
      expect(
        file.readAsStringSync().contains("google_fonts"),
        isFalse,
        reason: "${file.path} pulls a font from the network",
      );
    }
  });
}
