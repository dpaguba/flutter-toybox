import 'cell.dart';

/// The seven pieces of classic Tetris.
enum TetrominoType { i, o, t, s, z, j, l }

/// Piece shapes in four rotation states and their spawn positions.
///
/// Each rotation state is a set of cells inside a square box: four by four
/// for I, two by two for O, three by three for the rest. The next state is
/// the previous one rotated clockwise, i.e. cell (x, y) becomes
/// (size - 1 - y, x). The tables are spelled out in full rather than
/// computed on the fly, so they can be checked by eye against the paper
/// SRS specification.
class Tetromino {
  const Tetromino._();

  /// How many rotation states each piece has.
  static const int rotationCount = 4;

  static const Map<TetrominoType, List<List<Cell>>> _shapes = {
    TetrominoType.i: [
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(3, 1)],
      [Cell(2, 0), Cell(2, 1), Cell(2, 2), Cell(2, 3)],
      [Cell(0, 2), Cell(1, 2), Cell(2, 2), Cell(3, 2)],
      [Cell(1, 0), Cell(1, 1), Cell(1, 2), Cell(1, 3)],
    ],
    TetrominoType.o: [
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(0, 0), Cell(1, 0), Cell(0, 1), Cell(1, 1)],
    ],
    TetrominoType.t: [
      [Cell(1, 0), Cell(0, 1), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(1, 1), Cell(2, 1), Cell(1, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(1, 2)],
      [Cell(1, 0), Cell(0, 1), Cell(1, 1), Cell(1, 2)],
    ],
    TetrominoType.s: [
      [Cell(1, 0), Cell(2, 0), Cell(0, 1), Cell(1, 1)],
      [Cell(1, 0), Cell(1, 1), Cell(2, 1), Cell(2, 2)],
      [Cell(1, 1), Cell(2, 1), Cell(0, 2), Cell(1, 2)],
      [Cell(0, 0), Cell(0, 1), Cell(1, 1), Cell(1, 2)],
    ],
    TetrominoType.z: [
      [Cell(0, 0), Cell(1, 0), Cell(1, 1), Cell(2, 1)],
      [Cell(2, 0), Cell(1, 1), Cell(2, 1), Cell(1, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(1, 2), Cell(2, 2)],
      [Cell(1, 0), Cell(0, 1), Cell(1, 1), Cell(0, 2)],
    ],
    TetrominoType.j: [
      [Cell(0, 0), Cell(0, 1), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(2, 0), Cell(1, 1), Cell(1, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(2, 2)],
      [Cell(1, 0), Cell(1, 1), Cell(0, 2), Cell(1, 2)],
    ],
    TetrominoType.l: [
      [Cell(2, 0), Cell(0, 1), Cell(1, 1), Cell(2, 1)],
      [Cell(1, 0), Cell(1, 1), Cell(1, 2), Cell(2, 2)],
      [Cell(0, 1), Cell(1, 1), Cell(2, 1), Cell(0, 2)],
      [Cell(0, 0), Cell(1, 0), Cell(1, 1), Cell(1, 2)],
    ],
  };

  /// The cells of piece `type` at rotation state `rotation`, in box
  /// coordinates.
  ///
  /// Raises:
  ///   ArgumentError: if `rotation` is out of the zero-to-three range.
  static List<Cell> cellsFor(TetrominoType type, int rotation) {
    if (rotation < 0 || rotation >= rotationCount) {
      throw ArgumentError.value(
        rotation,
        "rotation",
        "Piece position must be between 0 and 3",
      );
    }
    return _shapes[type]![rotation];
  }

  /// The side length of the box the piece rotates in.
  static int boxSize(TetrominoType type) {
    switch (type) {
      case TetrominoType.i:
        return 4;
      case TetrominoType.o:
        return 2;
      default:
        return 3;
    }
  }

  /// The column where the piece's box lands when it spawns.
  ///
  /// O is one cell narrower than the rest, so it's shifted right, otherwise
  /// it would appear left of the field's center.
  static int spawnColumn(TetrominoType type) =>
      type == TetrominoType.o ? 4 : 3;
}
