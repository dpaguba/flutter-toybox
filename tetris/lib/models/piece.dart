import 'cell.dart';
import 'tetromino.dart';

/// A piece on the field: type, rotation state, and the box's corner.
///
/// The class is immutable: every move or rotation returns a new piece.
/// This lets the engine try a move, check it against the field, and
/// discard it without corrupting the current game state.
class Piece {
  const Piece({
    required this.type,
    required this.rotation,
    required this.x,
    required this.y,
  });

  /// The piece at the position where it appears at the start of a drop.
  factory Piece.spawn(TetrominoType type) => Piece(
        type: type,
        rotation: 0,
        x: Tetromino.spawnColumn(type),
        y: 0,
      );

  final TetrominoType type;
  final int rotation;

  /// The column of the box's left edge.
  final int x;

  /// The row of the box's top edge.
  final int y;

  /// The piece's cells in field coordinates.
  List<Cell> get cells => Tetromino.cellsFor(type, rotation)
      .map((cell) => cell.shifted(x, y))
      .toList();

  /// The same piece, shifted by `dx` columns and `dy` rows.
  Piece moved(int dx, int dy) => Piece(
        type: type,
        rotation: rotation,
        x: x + dx,
        y: y + dy,
      );

  /// The same piece at the given box corner.
  Piece movedTo(int newX, int newY) => Piece(
        type: type,
        rotation: rotation,
        x: newX,
        y: newY,
      );

  /// The same piece, rotated `steps` quarter turns clockwise.
  Piece turned(int steps) => Piece(
        type: type,
        rotation: (rotation + steps) % Tetromino.rotationCount,
        x: x,
        y: y,
      );
}
