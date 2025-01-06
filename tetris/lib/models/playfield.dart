import 'piece.dart';
import 'tetromino.dart';

/// The playfield: a grid of colors for placed pieces.
///
/// A cell holds the type of the piece it was left by, or `null` if empty.
/// Rows are counted top to bottom, so the last row is the bottom.
class Playfield {
  Playfield({this.columns = defaultColumns, this.rows = defaultRows})
      : _cells = List<List<TetrominoType?>>.generate(
          rows,
          (_) => List<TetrominoType?>.filled(columns, null),
        );

  /// Default field width.
  static const int defaultColumns = 10;

  /// Default field height.
  static const int defaultRows = 20;

  final int columns;
  final int rows;

  final List<List<TetrominoType?>> _cells;

  /// What's in the cell, or `null` outside the field or in an empty cell.
  TetrominoType? at(int x, int y) {
    if (x < 0 || x >= columns || y < 0 || y >= rows) {
      return null;
    }
    return _cells[y][x];
  }

  /// Puts a color in the cell, silently ignoring anything outside the field.
  void setAt(int x, int y, TetrominoType? type) {
    if (x < 0 || x >= columns || y < 0 || y >= rows) {
      return;
    }
    _cells[y][x] = type;
  }

  /// Whether the cell rejects a piece.
  ///
  /// The space above the field is free: a piece appears partly above the
  /// visible grid, and while it's there, that's not a collision yet.
  bool isBlocked(int x, int y) {
    if (x < 0 || x >= columns || y >= rows) {
      return true;
    }
    if (y < 0) {
      return false;
    }
    return _cells[y][x] != null;
  }

  /// Whether the piece stands in an allowed spot.
  bool fits(Piece piece) =>
      piece.cells.every((cell) => !isBlocked(cell.x, cell.y));

  /// Writes the piece into the grid permanently.
  ///
  /// Raises:
  ///   StateError: if the piece doesn't fit in the field, i.e. it goes
  ///     beyond the walls, past the floor, or overlaps cells already
  ///     placed.
  void lock(Piece piece) {
    if (!fits(piece)) {
      throw StateError("Cannot place a piece outside the field");
    }
    for (final cell in piece.cells) {
      setAt(cell.x, cell.y, piece.type);
    }
  }

  /// Clears all full rows and returns how many there were.
  int clearFullRows() {
    final List<List<TetrominoType?>> kept = [];
    for (final row in _cells) {
      if (row.any((cell) => cell == null)) {
        kept.add(row);
      }
    }
    final int cleared = rows - kept.length;
    for (var y = 0; y < rows; y++) {
      final int keptIndex = y - cleared;
      _cells[y] = keptIndex < 0
          ? List<TetrominoType?>.filled(columns, null)
          : kept[keptIndex];
    }
    return cleared;
  }

  /// Whether the field has no placed cells at all.
  bool get isEmpty =>
      _cells.every((row) => row.every((cell) => cell == null));

  /// Clears everything from the field.
  void reset() {
    for (var y = 0; y < rows; y++) {
      _cells[y] = List<TetrominoType?>.filled(columns, null);
    }
  }
}
