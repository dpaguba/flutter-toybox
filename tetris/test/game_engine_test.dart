import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/logic/bag.dart';
import 'package:tetris/logic/game_engine.dart';
import 'package:tetris/logic/scoring.dart';
import 'package:tetris/models/tetromino.dart';

import 'fixed_source.dart';

GameEngine startedWith(List<TetrominoType> order) {
  final engine = GameEngine(source: FixedSource(order));
  engine.start();
  return engine;
}

/// Fills row `y` except for the listed columns.
void fillRowExcept(GameEngine engine, int y, List<int> gaps) {
  for (var x = 0; x < engine.field.columns; x++) {
    if (!gaps.contains(x)) {
      engine.field.setAt(x, y, TetrominoType.z);
    }
  }
}

void main() {
  test('a new game starts with a clean field and zero score', () {
    final engine = startedWith([TetrominoType.t]);
    expect(engine.status, GameStatus.running);
    expect(engine.score, 0);
    expect(engine.lines, 0);
    expect(engine.level, 1);
    expect(engine.field.isEmpty, isTrue);
    expect(engine.current, isNotNull);
    expect(engine.current!.type, TetrominoType.t);
    expect(engine.held, isNull);
  });

  test('the preview shows the three next pieces', () {
    final engine = startedWith([
      TetrominoType.t,
      TetrominoType.i,
      TetrominoType.o,
      TetrominoType.s,
    ]);
    expect(engine.next, [TetrominoType.i, TetrominoType.o, TetrominoType.s]);
  });

  test('the drop shadow stands at the bottom of an empty field', () {
    final engine = startedWith([TetrominoType.o]);
    expect(engine.ghost!.y, 18);
    expect(engine.ghost!.x, engine.current!.x);
    expect(engine.ghost!.rotation, engine.current!.rotation);
  });

  test('the drop shadow rests on top of placed pieces', () {
    final engine = startedWith([TetrominoType.o]);
    engine.field.setAt(4, 10, TetrominoType.i);
    expect(engine.ghost!.y, 8);
  });

  test('sideways movement stops at the walls', () {
    final engine = startedWith([TetrominoType.o]);
    var moves = 0;
    while (engine.moveLeft()) {
      moves++;
      expect(moves, lessThan(20));
    }
    expect(engine.current!.x, 0);
    expect(engine.moveLeft(), isFalse);

    while (engine.moveRight()) {
      moves++;
      expect(moves, lessThan(40));
    }
    expect(engine.current!.x, 8);
  });

  test('soft drop gives one point per cell', () {
    final engine = startedWith([TetrominoType.o]);
    final startY = engine.current!.y;
    expect(engine.softDrop(), isTrue);
    expect(engine.current!.y, startY + 1);
    expect(engine.score, Scoring.softDropScore(1));
  });

  test('hard drop gives two points per cell and places the piece', () {
    final engine = startedWith([TetrominoType.o]);
    final distance = engine.ghost!.y - engine.current!.y;
    expect(engine.hardDrop(), distance);
    expect(engine.score, Scoring.hardDropScore(distance));
    expect(engine.field.at(4, 19), TetrominoType.o);
    expect(engine.current!.y, 0);
  });

  test('gravity lowers the piece without awarding points', () {
    final engine = startedWith([TetrominoType.o]);
    engine.update(engine.gravityMs);
    expect(engine.current!.y, 1);
    expect(engine.score, 0);
  });

  test('a piece does not fall while paused', () {
    final engine = startedWith([TetrominoType.o]);
    engine.pause();
    engine.update(10000);
    expect(engine.current!.y, 0);
    expect(engine.status, GameStatus.paused);

    engine.resume();
    engine.update(engine.gravityMs);
    expect(engine.current!.y, 1);
  });

  test('a piece does not lock immediately after landing', () {
    final engine = startedWith([TetrominoType.o]);
    while (engine.softDrop()) {}
    expect(engine.field.isEmpty, isTrue);

    engine.update(GameEngine.lockDelayMs - 1);
    expect(engine.field.isEmpty, isTrue);

    engine.update(2);
    expect(engine.field.isEmpty, isFalse);
    expect(engine.current!.y, 0);
  });

  test('clearing one line gives a hundred points and increases the line counter', () {
    final engine = startedWith([TetrominoType.i]);
    fillRowExcept(engine, 19, [3, 4, 5, 6]);
    engine.hardDrop();
    expect(engine.lines, 1);
    expect(engine.level, 1);
    expect(
      engine.score,
      Scoring.lineScore(1, 1) + Scoring.hardDropScore(18),
    );
    expect(engine.field.isEmpty, isTrue);
  });

  test('clearing four lines at once gives eight hundred points', () {
    final engine = startedWith([TetrominoType.i]);
    for (var y = 16; y < 20; y++) {
      fillRowExcept(engine, y, [0]);
    }
    expect(engine.rotate(clockwise: true), isTrue);
    for (var i = 0; i < 5; i++) {
      expect(engine.moveLeft(), isTrue);
    }
    engine.hardDrop();
    expect(engine.lines, 4);
    expect(
      engine.score,
      Scoring.lineScore(4, 1) + Scoring.hardDropScore(16),
    );
    expect(engine.field.isEmpty, isTrue);
  });

  test('the level increases on the tenth line', () {
    final engine = startedWith([TetrominoType.i]);
    for (var drop = 0; drop < 10; drop++) {
      fillRowExcept(engine, 19, [3, 4, 5, 6]);
      engine.hardDrop();
      expect(engine.lines, drop + 1);
    }
    expect(engine.lines, 10);
    expect(engine.level, 2);
    expect(engine.gravityMs, Scoring.gravityForLevel(2));
  });

  test('a piece can be held only once per drop', () {
    final engine = startedWith([
      TetrominoType.t,
      TetrominoType.i,
      TetrominoType.o,
      TetrominoType.s,
      TetrominoType.z,
    ]);
    expect(engine.canHold, isTrue);
    expect(engine.hold(), isTrue);
    expect(engine.held, TetrominoType.t);
    expect(engine.current!.type, TetrominoType.i);

    expect(engine.canHold, isFalse);
    expect(engine.hold(), isFalse);
    expect(engine.held, TetrominoType.t);
    expect(engine.current!.type, TetrominoType.i);
  });

  test('after a drop, the held piece can be swapped again', () {
    final engine = startedWith([
      TetrominoType.t,
      TetrominoType.i,
      TetrominoType.o,
    ]);
    engine.hold();
    engine.hardDrop();
    expect(engine.canHold, isTrue);
    expect(engine.current!.type, TetrominoType.o);

    expect(engine.hold(), isTrue);
    expect(engine.held, TetrominoType.o);
    expect(engine.current!.type, TetrominoType.t);
  });

  test('a held piece returns at the top, not where it was', () {
    final engine = startedWith([TetrominoType.t, TetrominoType.i]);
    engine.softDrop();
    engine.softDrop();
    engine.moveLeft();
    engine.hold();
    expect(engine.current!.y, 0);
    expect(engine.current!.x, 3);
  });

  test('the game ends when the top of the field is filled', () {
    final engine = startedWith([TetrominoType.o]);
    engine.field.setAt(4, 2, TetrominoType.z);
    engine.field.setAt(5, 2, TetrominoType.z);
    engine.hardDrop();
    expect(engine.status, GameStatus.over);
    expect(engine.current, isNull);
  });

  test('after game over, controls do nothing', () {
    final engine = startedWith([TetrominoType.o]);
    engine.field.setAt(4, 2, TetrominoType.z);
    engine.field.setAt(5, 2, TetrominoType.z);
    engine.hardDrop();
    final scoreAtEnd = engine.score;

    expect(engine.moveLeft(), isFalse);
    expect(engine.moveRight(), isFalse);
    expect(engine.rotate(clockwise: true), isFalse);
    expect(engine.softDrop(), isFalse);
    expect(engine.hold(), isFalse);
    expect(engine.hardDrop(), 0);
    engine.update(5000);
    expect(engine.score, scoreAtEnd);
    expect(engine.status, GameStatus.over);
  });

  test('a new game resets the score, level, and field', () {
    final engine = startedWith([TetrominoType.o]);
    engine.hardDrop();
    engine.hold();
    engine.start();
    expect(engine.score, 0);
    expect(engine.lines, 0);
    expect(engine.level, 1);
    expect(engine.held, isNull);
    expect(engine.field.isEmpty, isTrue);
    expect(engine.status, GameStatus.running);
  });

  test('rotating near a wall pushes the piece back into the field', () {
    final engine = startedWith([TetrominoType.i]);
    while (engine.moveLeft()) {}
    expect(engine.rotate(clockwise: true), isTrue);
    expect(engine.field.fits(engine.current!), isTrue);
  });

  test('a long game does not drive the game into an impossible state', () {
    final random = Random(42);
    final engine = GameEngine(source: SevenBag(random: Random(11)));
    engine.start();

    int score = 0;
    int lines = 0;
    for (var step = 0; step < 4000; step++) {
      if (engine.status == GameStatus.over) {
        engine.start();
        score = 0;
        lines = 0;
        continue;
      }
      switch (random.nextInt(7)) {
        case 0:
          engine.moveLeft();
          break;
        case 1:
          engine.moveRight();
          break;
        case 2:
          engine.rotate(clockwise: true);
          break;
        case 3:
          engine.rotate(clockwise: false);
          break;
        case 4:
          engine.softDrop();
          break;
        case 5:
          engine.hardDrop();
          break;
        default:
          engine.update(120);
      }
      if (engine.current != null) {
        expect(engine.field.fits(engine.current!), isTrue, reason: "step $step");
        expect(engine.field.fits(engine.ghost!), isTrue, reason: "step $step");
      }
      expect(engine.score, greaterThanOrEqualTo(score));
      expect(engine.lines, greaterThanOrEqualTo(lines));
      expect(engine.level, Scoring.levelForLines(engine.lines));
      expect(engine.next.length, GameEngine.previewCount);
      score = engine.score;
      lines = engine.lines;
    }
  });

  test('the field keeps no holes from cleared lines', () {
    final engine = GameEngine(source: SevenBag(random: Random(3)));
    engine.start();
    final random = Random(9);
    for (var step = 0; step < 600 && engine.status != GameStatus.over; step++) {
      for (var move = 0; move < random.nextInt(4); move++) {
        engine.moveLeft();
      }
      engine.hardDrop();
    }
    for (var y = 0; y < engine.field.rows; y++) {
      final bool full = List.generate(
        engine.field.columns,
        (x) => engine.field.at(x, y),
      ).every((cell) => cell != null);
      expect(full, isFalse, reason: "row $y remained full");
    }
  });
}
