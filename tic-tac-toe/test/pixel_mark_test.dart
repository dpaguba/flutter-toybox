import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/utils/constants.dart';
import 'package:tic_tac_toe/widgets/pixel_mark.dart';

void main() {
  test('both matrices are seven by seven', () {
    expect(markX.length, 7);
    expect(markO.length, 7);
    for (final row in markX) {
      expect(row.length, 7);
    }
    for (final row in markO) {
      expect(row.length, 7);
    }
  });

  test('the X mark is symmetric across both diagonals', () {
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        expect(markX[y][x], markX[x][y], reason: 'main diagonal');
        expect(markX[y][x], markX[6 - y][6 - x], reason: 'rotation');
      }
    }
  });

  test('the rectangles cover seventy percent of the cell', () {
    final rects = spriteRects(markX, const Size(70, 70), 0.7);
    expect(rects, isNotEmpty);
    final left = rects.map((r) => r.left).reduce((a, b) => a < b ? a : b);
    final right = rects.map((r) => r.right).reduce((a, b) => a > b ? a : b);
    expect(right - left, closeTo(49, 0.01));
    expect(left, closeTo(10.5, 0.01));
  });

  test('every one in the matrix produces exactly one square', () {
    final ones = markO.expand((row) => row).where((v) => v == 1).length;
    expect(spriteRects(markO, const Size(70, 70), 0.7).length, ones);
  });

  test('an asymmetric matrix is centered by its column count', () {
    final matrix = [
      [1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1],
    ];
    const size = Size(100, 60);
    final rects = spriteRects(matrix, size, 0.6);
    expect(rects, isNotEmpty);

    final double side = (size.shortestSide * 0.6) / matrix.length;
    final double expectedLeft = (size.width - side * matrix[0].length) / 2;

    final left = rects.map((r) => r.left).reduce((a, b) => a < b ? a : b);
    final right = rects.map((r) => r.right).reduce((a, b) => a > b ? a : b);

    expect(left, closeTo(expectedLeft, 0.01));
    expect(right - left, closeTo(side * matrix[0].length, 0.01));
    expect(size.width - right, closeTo(left, 0.01));
  });
}
