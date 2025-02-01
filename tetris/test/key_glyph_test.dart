import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/widgets/key_glyph.dart';

/// The raster of a single mark drawn in white on transparent.
///
/// The mark is drawn inside a `size` by `size` square and returned as RGBA bytes,
/// so the test looks at the paint itself, not the code that lays it down.
Future<GlyphInk> inkOf(WidgetTester tester, KeyMark mark, double size) async {
  final GlobalKey boundary = GlobalKey();
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        key: boundary,
        child: KeyGlyph(mark: mark, color: const Color(0xFFFFFFFF), size: size),
      ),
    ),
  );
  final RenderRepaintBoundary render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  late GlyphInk ink;
  await tester.runAsync(() async {
    final ui.Image image = await render.toImage();
    final ByteData bytes =
        (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    ink = GlyphInk(image.width, image.height, bytes);
    image.dispose();
  });
  return ink;
}

/// The mark's paint as a grid: where it is, how much of it there is, and how many pieces
/// it breaks into.
class GlyphInk {
  GlyphInk(this.width, this.height, ByteData bytes)
      : filled = List.generate(
          height,
          (y) => List.generate(
            width,
            (x) => bytes.getUint8((y * width + x) * 4 + 3) > 128,
          ),
        );

  final int width;
  final int height;
  final List<List<bool>> filled;

  /// The fraction of the square covered by paint.
  double get coverage {
    var painted = 0;
    for (final row in filled) {
      painted += row.where((cell) => cell).length;
    }
    return painted / (width * height);
  }

  /// How many separate pieces of paint the mark has.
  int get pieces {
    final seen = List.generate(height, (_) => List.filled(width, false));
    var found = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (!filled[y][x] || seen[y][x]) {
          continue;
        }
        found++;
        final stack = <List<int>>[
          [x, y]
        ];
        while (stack.isNotEmpty) {
          final point = stack.removeLast();
          final px = point[0];
          final py = point[1];
          if (px < 0 || py < 0 || px >= width || py >= height) {
            continue;
          }
          if (!filled[py][px] || seen[py][px]) {
            continue;
          }
          seen[py][px] = true;
          stack.add([px + 1, py]);
          stack.add([px - 1, py]);
          stack.add([px, py + 1]);
          stack.add([px, py - 1]);
        }
      }
    }
    return found;
  }

  /// Whether the paint touches the edge of the square, i.e. whether it got clipped.
  bool get touchesEdge {
    for (var x = 0; x < width; x++) {
      if (filled[0][x] || filled[height - 1][x]) {
        return true;
      }
    }
    for (var y = 0; y < height; y++) {
      if (filled[y][0] || filled[y][width - 1]) {
        return true;
      }
    }
    return false;
  }
}

/// How many pieces of paint each mark should have.
///
/// The arrows and turn are solid shapes, while the gap in drop, hold, and
/// pause is intentional: a triangle above a base, a nest around a piece,
/// two bars.
const Map<KeyMark, int> expectedPieces = {
  KeyMark.left: 1,
  KeyMark.right: 1,
  KeyMark.down: 1,
  KeyMark.drop: 2,
  KeyMark.turn: 1,
  KeyMark.hold: 2,
  KeyMark.pause: 2,
};

void main() {
  testWidgets('each mark is made of exactly as many pieces as it needs',
      (tester) async {
    for (final mark in KeyMark.values) {
      final ink = await inkOf(tester, mark, 96);
      expect(ink.pieces, expectedPieces[mark], reason: "$mark");
    }
  });

  testWidgets('the rotation arrow holds together instead of floating apart',
      (tester) async {
    final ink = await inkOf(tester, KeyMark.turn, 96);
    expect(ink.pieces, 1, reason: "the arrowhead detached from the arc");
  });

  testWidgets('no mark touches the edge of the key', (tester) async {
    for (final mark in KeyMark.values) {
      final ink = await inkOf(tester, mark, 96);
      expect(ink.touchesEdge, isFalse, reason: "$mark");
    }
  });

  testWidgets('the mark grows together with the key instead of drifting', (tester) async {
    for (final mark in KeyMark.values) {
      final small = await inkOf(tester, mark, 24);
      final large = await inkOf(tester, mark, 96);
      expect(large.pieces, small.pieces, reason: "$mark broke apart at a different size");
      expect(
        (large.coverage - small.coverage).abs(),
        lessThan(0.03),
        reason: "$mark covers a different fraction of the key: "
            "${small.coverage} vs ${large.coverage}",
      );
    }
  });

  testWidgets('the mark actually draws something', (tester) async {
    for (final mark in KeyMark.values) {
      final ink = await inkOf(tester, mark, 96);
      expect(ink.coverage, greaterThan(0.04), reason: "$mark is nearly empty");
    }
  });
}
