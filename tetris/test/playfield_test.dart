import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/cell.dart';
import 'package:tetris/models/piece.dart';
import 'package:tetris/models/playfield.dart';
import 'package:tetris/models/tetromino.dart';

/// Fills row `y` except for column `gap`.
void fillRowExcept(Playfield field, int y, int gap) {
  for (var x = 0; x < field.columns; x++) {
    if (x != gap) {
      field.setAt(x, y, TetrominoType.o);
    }
  }
}

void main() {
  test('the field is ten by twenty and starts empty', () {
    final field = Playfield();
    expect(field.columns, 10);
    expect(field.rows, 20);
    expect(field.isEmpty, isTrue);
    for (var y = 0; y < field.rows; y++) {
      for (var x = 0; x < field.columns; x++) {
        expect(field.at(x, y), isNull);
      }
    }
  });

  test('the walls and floor are blocked, the space above the field is free', () {
    final field = Playfield();
    expect(field.isBlocked(-1, 5), isTrue);
    expect(field.isBlocked(10, 5), isTrue);
    expect(field.isBlocked(5, 20), isTrue);
    expect(field.isBlocked(5, -3), isFalse);
    expect(field.isBlocked(5, 5), isFalse);
  });

  test('a piece does not fit where something already lies', () {
    final field = Playfield();
    final piece = Piece.spawn(TetrominoType.o).movedTo(0, 18);
    expect(field.fits(piece), isTrue);
    field.setAt(0, 19, TetrominoType.i);
    expect(field.fits(piece), isFalse);
  });

  test('a locked piece leaves its color in the cells', () {
    final field = Playfield();
    final piece = Piece.spawn(TetrominoType.t).movedTo(0, 0);
    field.lock(piece);
    for (final cell in piece.cells) {
      expect(field.at(cell.x, cell.y), TetrominoType.t);
    }
    expect(field.isEmpty, isFalse);
  });

  test('a piece cannot be locked outside the field', () {
    final field = Playfield();
    expect(
      () => field.lock(Piece.spawn(TetrominoType.o).movedTo(0, 19)
          .moved(0, 1)),
      throwsStateError,
    );
  });

  test('one full row disappears and the top shifts down', () {
    final field = Playfield();
    fillRowExcept(field, 19, 0);
    field.setAt(0, 19, TetrominoType.z);
    field.setAt(3, 18, TetrominoType.i);

    expect(field.clearFullRows(), 1);
    expect(field.at(3, 19), TetrominoType.i);
    for (var x = 0; x < field.columns; x++) {
      expect(field.at(x, 18), isNull);
    }
  });

  test('four full rows disappear all at once', () {
    final field = Playfield();
    for (var y = 16; y < 20; y++) {
      fillRowExcept(field, y, 0);
      field.setAt(0, y, TetrominoType.i);
    }
    field.setAt(5, 15, TetrominoType.t);

    expect(field.clearFullRows(), 4);
    expect(field.at(5, 19), TetrominoType.t);
    expect(field.isEmpty, isFalse);
    for (var y = 0; y < 19; y++) {
      for (var x = 0; x < field.columns; x++) {
        expect(field.at(x, y), isNull);
      }
    }
  });

  test('an incomplete row stays in place', () {
    final field = Playfield();
    fillRowExcept(field, 19, 4);
    expect(field.clearFullRows(), 0);
    expect(field.at(0, 19), TetrominoType.o);
  });

  test('reset clears the field', () {
    final field = Playfield();
    field.setAt(0, 0, TetrominoType.l);
    field.reset();
    expect(field.isEmpty, isTrue);
  });

  test('a piece knows its cells in field coordinates', () {
    const piece = Piece(type: TetrominoType.o, rotation: 0, x: 4, y: 0);
    expect(piece.cells.toSet(), {
      const Cell(4, 0),
      const Cell(5, 0),
      const Cell(4, 1),
      const Cell(5, 1),
    });
  });

  test('shifting and rotating produce a new piece, the old one stays unchanged', () {
    const piece = Piece(type: TetrominoType.t, rotation: 0, x: 3, y: 0);
    final moved = piece.moved(1, 2);
    expect(moved.x, 4);
    expect(moved.y, 2);
    expect(piece.x, 3);

    final turned = piece.turned(1);
    expect(turned.rotation, 1);
    expect(piece.rotation, 0);
    expect(piece.turned(-1).rotation, 3);
    expect(piece.turned(4).rotation, 0);
  });

  test('a piece spawns in its own column on row zero', () {
    final piece = Piece.spawn(TetrominoType.i);
    expect(piece.x, 3);
    expect(piece.y, 0);
    expect(piece.rotation, 0);
    expect(Piece.spawn(TetrominoType.o).x, 4);
  });
}
