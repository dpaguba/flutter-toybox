import '../models/cell.dart';
import '../models/piece.dart';
import '../models/playfield.dart';
import '../models/tetromino.dart';

/// Rotation using the SRS system with kicks off walls and pieces.
///
/// After a rotation, the piece first tries to stay in place, and if that's
/// too tight, it goes through five predefined kicks and settles on the
/// first one that fits. The kick tables are separate for I and for the
/// rest of the pieces: the I box is twice as long, and the same kicks
/// would leave it stuck in the wall.
///
/// The kicks are written in field coordinates, where rows grow downward.
/// The paper SRS specification counts rows upward, so where it has plus
/// one row, here it's minus one.
class RotationSystem {
  const RotationSystem._();

  static const Cell _noShift = Cell(0, 0);

  static const Map<int, List<Cell>> _standardKicks = {
    _from0toR: [_noShift, Cell(-1, 0), Cell(-1, -1), Cell(0, 2), Cell(-1, 2)],
    _fromRto0: [_noShift, Cell(1, 0), Cell(1, 1), Cell(0, -2), Cell(1, -2)],
    _fromRto2: [_noShift, Cell(1, 0), Cell(1, 1), Cell(0, -2), Cell(1, -2)],
    _from2toR: [_noShift, Cell(-1, 0), Cell(-1, -1), Cell(0, 2), Cell(-1, 2)],
    _from2toL: [_noShift, Cell(1, 0), Cell(1, -1), Cell(0, 2), Cell(1, 2)],
    _fromLto2: [_noShift, Cell(-1, 0), Cell(-1, 1), Cell(0, -2), Cell(-1, -2)],
    _fromLto0: [_noShift, Cell(-1, 0), Cell(-1, 1), Cell(0, -2), Cell(-1, -2)],
    _from0toL: [_noShift, Cell(1, 0), Cell(1, -1), Cell(0, 2), Cell(1, 2)],
  };

  static const Map<int, List<Cell>> _longKicks = {
    _from0toR: [_noShift, Cell(-2, 0), Cell(1, 0), Cell(-2, 1), Cell(1, -2)],
    _fromRto0: [_noShift, Cell(2, 0), Cell(-1, 0), Cell(2, -1), Cell(-1, 2)],
    _fromRto2: [_noShift, Cell(-1, 0), Cell(2, 0), Cell(-1, -2), Cell(2, 1)],
    _from2toR: [_noShift, Cell(1, 0), Cell(-2, 0), Cell(1, 2), Cell(-2, -1)],
    _from2toL: [_noShift, Cell(2, 0), Cell(-1, 0), Cell(2, -1), Cell(-1, 2)],
    _fromLto2: [_noShift, Cell(-2, 0), Cell(1, 0), Cell(-2, 1), Cell(1, -2)],
    _fromLto0: [_noShift, Cell(1, 0), Cell(-2, 0), Cell(1, 2), Cell(-2, -1)],
    _from0toL: [_noShift, Cell(-1, 0), Cell(2, 0), Cell(-1, -2), Cell(2, 1)],
  };

  static const int _from0toR = 1;
  static const int _fromRto0 = 4;
  static const int _fromRto2 = 6;
  static const int _from2toR = 9;
  static const int _from2toL = 11;
  static const int _fromLto2 = 14;
  static const int _fromLto0 = 12;
  static const int _from0toL = 3;

  /// Kicks for the transition from position `from` to the adjacent `to`.
  ///
  /// Raises:
  ///   ArgumentError: if a position is out of the zero-to-three range, or if
  ///     they are not adjacent, because a rotation straight to a half turn
  ///     is not supported.
  static List<Cell> kicks(TetrominoType type, int from, int to) {
    if (from < 0 || from > 3 || to < 0 || to > 3) {
      throw ArgumentError("Piece position must be between 0 and 3");
    }
    final int key = from * 4 + to;
    final Map<int, List<Cell>> table =
        type == TetrominoType.i ? _longKicks : _standardKicks;
    final List<Cell>? found = table[key];
    if (found == null) {
      throw ArgumentError(
        "Rotation directly from position $from to $to is not supported",
      );
    }
    return found;
  }

  /// Rotates the piece a quarter turn, or `null` if no kick fits.
  static Piece? rotate({
    required Piece piece,
    required Playfield field,
    required bool clockwise,
  }) {
    final Piece turned = piece.turned(clockwise ? 1 : -1);
    for (final shift in kicks(piece.type, piece.rotation, turned.rotation)) {
      final Piece candidate = turned.moved(shift.x, shift.y);
      if (field.fits(candidate)) {
        return candidate;
      }
    }
    return null;
  }
}
