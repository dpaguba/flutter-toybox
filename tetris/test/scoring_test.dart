import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/logic/scoring.dart';

void main() {
  test('score for lines at the first level', () {
    expect(Scoring.lineScore(0, 1), 0);
    expect(Scoring.lineScore(1, 1), 100);
    expect(Scoring.lineScore(2, 1), 300);
    expect(Scoring.lineScore(3, 1), 500);
    expect(Scoring.lineScore(4, 1), 800);
  });

  test('score for lines is multiplied by the level', () {
    expect(Scoring.lineScore(1, 3), 300);
    expect(Scoring.lineScore(2, 4), 1200);
    expect(Scoring.lineScore(4, 7), 5600);
  });

  test('more than four lines at once never happens', () {
    expect(() => Scoring.lineScore(5, 1), throwsArgumentError);
    expect(() => Scoring.lineScore(-1, 1), throwsArgumentError);
    expect(() => Scoring.lineScore(1, 0), throwsArgumentError);
  });

  test('a soft drop gives one point per cell, a hard drop gives two', () {
    expect(Scoring.softDropScore(1), 1);
    expect(Scoring.softDropScore(5), 5);
    expect(Scoring.hardDropScore(0), 0);
    expect(Scoring.hardDropScore(6), 12);
  });

  test('the level increases every ten lines', () {
    expect(Scoring.levelForLines(0), 1);
    expect(Scoring.levelForLines(9), 1);
    expect(Scoring.levelForLines(10), 2);
    expect(Scoring.levelForLines(19), 2);
    expect(Scoring.levelForLines(20), 3);
    expect(Scoring.levelForLines(95), 10);
  });

  test('fall speed ranges from eight hundred down to one hundred milliseconds', () {
    expect(Scoring.gravityForLevel(1), 800);
    expect(Scoring.gravityForLevel(10), 100);
    expect(Scoring.gravityForLevel(25), 100);
    for (var level = 1; level < 10; level++) {
      expect(
        Scoring.gravityForLevel(level) > Scoring.gravityForLevel(level + 1),
        isTrue,
        reason: "level $level",
      );
    }
  });

  test('a level below the first never happens', () {
    expect(() => Scoring.gravityForLevel(0), throwsArgumentError);
  });
}
