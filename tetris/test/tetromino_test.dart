import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/cell.dart';
import 'package:tetris/models/tetromino.dart';

/// Returns the set of cells rotated clockwise within the bounding box.
Set<Cell> turnedClockwise(List<Cell> cells, int box) {
  return cells.map((cell) => Cell(box - 1 - cell.y, cell.x)).toSet();
}

void main() {
  test('every piece has four rotations of four cells each', () {
    for (final type in TetrominoType.values) {
      for (var rotation = 0; rotation < 4; rotation++) {
        expect(
          Tetromino.cellsFor(type, rotation).length,
          4,
          reason: "$type at rotation $rotation",
        );
      }
    }
  });

  test('I in all four rotation states', () {
    expect(Tetromino.cellsFor(TetrominoType.i, 0).toSet(),
        {const Cell(0, 1), const Cell(1, 1), const Cell(2, 1), const Cell(3, 1)});
    expect(Tetromino.cellsFor(TetrominoType.i, 1).toSet(),
        {const Cell(2, 0), const Cell(2, 1), const Cell(2, 2), const Cell(2, 3)});
    expect(Tetromino.cellsFor(TetrominoType.i, 2).toSet(),
        {const Cell(0, 2), const Cell(1, 2), const Cell(2, 2), const Cell(3, 2)});
    expect(Tetromino.cellsFor(TetrominoType.i, 3).toSet(),
        {const Cell(1, 0), const Cell(1, 1), const Cell(1, 2), const Cell(1, 3)});
  });

  test('T in all four rotation states', () {
    expect(Tetromino.cellsFor(TetrominoType.t, 0).toSet(),
        {const Cell(1, 0), const Cell(0, 1), const Cell(1, 1), const Cell(2, 1)});
    expect(Tetromino.cellsFor(TetrominoType.t, 1).toSet(),
        {const Cell(1, 0), const Cell(1, 1), const Cell(2, 1), const Cell(1, 2)});
    expect(Tetromino.cellsFor(TetrominoType.t, 2).toSet(),
        {const Cell(0, 1), const Cell(1, 1), const Cell(2, 1), const Cell(1, 2)});
    expect(Tetromino.cellsFor(TetrominoType.t, 3).toSet(),
        {const Cell(1, 0), const Cell(0, 1), const Cell(1, 1), const Cell(1, 2)});
  });

  test('S in all four rotation states', () {
    expect(Tetromino.cellsFor(TetrominoType.s, 0).toSet(),
        {const Cell(1, 0), const Cell(2, 0), const Cell(0, 1), const Cell(1, 1)});
    expect(Tetromino.cellsFor(TetrominoType.s, 1).toSet(),
        {const Cell(1, 0), const Cell(1, 1), const Cell(2, 1), const Cell(2, 2)});
    expect(Tetromino.cellsFor(TetrominoType.s, 2).toSet(),
        {const Cell(1, 1), const Cell(2, 1), const Cell(0, 2), const Cell(1, 2)});
    expect(Tetromino.cellsFor(TetrominoType.s, 3).toSet(),
        {const Cell(0, 0), const Cell(0, 1), const Cell(1, 1), const Cell(1, 2)});
  });

  test('Z in all four rotation states', () {
    expect(Tetromino.cellsFor(TetrominoType.z, 0).toSet(),
        {const Cell(0, 0), const Cell(1, 0), const Cell(1, 1), const Cell(2, 1)});
    expect(Tetromino.cellsFor(TetrominoType.z, 1).toSet(),
        {const Cell(2, 0), const Cell(1, 1), const Cell(2, 1), const Cell(1, 2)});
    expect(Tetromino.cellsFor(TetrominoType.z, 2).toSet(),
        {const Cell(0, 1), const Cell(1, 1), const Cell(1, 2), const Cell(2, 2)});
    expect(Tetromino.cellsFor(TetrominoType.z, 3).toSet(),
        {const Cell(1, 0), const Cell(0, 1), const Cell(1, 1), const Cell(0, 2)});
  });

  test('J in all four rotation states', () {
    expect(Tetromino.cellsFor(TetrominoType.j, 0).toSet(),
        {const Cell(0, 0), const Cell(0, 1), const Cell(1, 1), const Cell(2, 1)});
    expect(Tetromino.cellsFor(TetrominoType.j, 1).toSet(),
        {const Cell(1, 0), const Cell(2, 0), const Cell(1, 1), const Cell(1, 2)});
    expect(Tetromino.cellsFor(TetrominoType.j, 2).toSet(),
        {const Cell(0, 1), const Cell(1, 1), const Cell(2, 1), const Cell(2, 2)});
    expect(Tetromino.cellsFor(TetrominoType.j, 3).toSet(),
        {const Cell(1, 0), const Cell(1, 1), const Cell(0, 2), const Cell(1, 2)});
  });

  test('L in all four rotation states', () {
    expect(Tetromino.cellsFor(TetrominoType.l, 0).toSet(),
        {const Cell(2, 0), const Cell(0, 1), const Cell(1, 1), const Cell(2, 1)});
    expect(Tetromino.cellsFor(TetrominoType.l, 1).toSet(),
        {const Cell(1, 0), const Cell(1, 1), const Cell(1, 2), const Cell(2, 2)});
    expect(Tetromino.cellsFor(TetrominoType.l, 2).toSet(),
        {const Cell(0, 1), const Cell(1, 1), const Cell(2, 1), const Cell(0, 2)});
    expect(Tetromino.cellsFor(TetrominoType.l, 3).toSet(),
        {const Cell(0, 0), const Cell(1, 0), const Cell(1, 1), const Cell(1, 2)});
  });

  test('O is identical in all four rotations', () {
    final first = Tetromino.cellsFor(TetrominoType.o, 0).toSet();
    for (var rotation = 1; rotation < 4; rotation++) {
      expect(Tetromino.cellsFor(TetrominoType.o, rotation).toSet(), first);
    }
  });

  test('each next rotation is the previous one turned a quarter', () {
    for (final type in TetrominoType.values) {
      final int box = Tetromino.boxSize(type);
      for (var rotation = 0; rotation < 4; rotation++) {
        expect(
          turnedClockwise(Tetromino.cellsFor(type, rotation), box),
          Tetromino.cellsFor(type, (rotation + 1) % 4).toSet(),
          reason: "$type from rotation $rotation",
        );
      }
    }
  });

  test('the bounding box is four cells for I, two for O, three for the rest', () {
    expect(Tetromino.boxSize(TetrominoType.i), 4);
    expect(Tetromino.boxSize(TetrominoType.o), 2);
    for (final type in [
      TetrominoType.t,
      TetrominoType.s,
      TetrominoType.z,
      TetrominoType.j,
      TetrominoType.l,
    ]) {
      expect(Tetromino.boxSize(type), 3);
    }
  });

  test('a rotation outside the zero-to-three range is rejected', () {
    expect(() => Tetromino.cellsFor(TetrominoType.i, 4), throwsArgumentError);
    expect(() => Tetromino.cellsFor(TetrominoType.i, -1), throwsArgumentError);
  });

  test('pieces spawn centered on the field', () {
    expect(Tetromino.spawnColumn(TetrominoType.o), 4);
    expect(Tetromino.spawnColumn(TetrominoType.i), 3);
    expect(Tetromino.spawnColumn(TetrominoType.t), 3);
  });

  test('cells are equal by value, not by reference', () {
    expect(const Cell(2, 3), const Cell(2, 3));
    expect(const Cell(2, 3).hashCode, const Cell(2, 3).hashCode);
    expect(const Cell(2, 3) == const Cell(3, 2), isFalse);
    expect(const Cell(2, 3).shifted(1, -1), const Cell(3, 2));
  });
}
