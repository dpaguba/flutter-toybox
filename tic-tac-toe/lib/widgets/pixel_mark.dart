import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Computes the sprite's rectangles for a given cell.
///
/// The sprite fits into a square whose side is [fill] of the cell's shorter
/// side, and is centered. Kept separate from the painting code so the
/// geometry can be tested without a canvas.
List<Rect> spriteRects(List<List<int>> matrix, Size size, double fill) {
  final int rows = matrix.length;
  final int cols = matrix[0].length;
  final double side = (size.shortestSide * fill) / rows;
  final double left = (size.width - side * cols) / 2;
  final double top = (size.height - side * rows) / 2;
  final List<Rect> rects = [];
  for (var y = 0; y < rows; y++) {
    for (var x = 0; x < matrix[y].length; x++) {
      if (matrix[y][x] == 1) {
        rects.add(Rect.fromLTWH(
          left + x * side,
          top + y * side,
          side,
          side,
        ));
      }
    }
  }
  return rects;
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.matrix, this.color);

  final List<List<int>> matrix;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    for (final rect in spriteRects(matrix, size, 0.7)) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.matrix != matrix || old.color != color;
}

/// Paints an X or O as a pixel sprite filling the whole cell.
class PixelMark extends StatelessWidget {
  const PixelMark({super.key, required this.mark, this.color = Colors.white});

  final String mark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (mark != "X" && mark != "O") {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      painter: _MarkPainter(mark == "X" ? markX : markO, color),
      size: Size.infinite,
    );
  }
}
