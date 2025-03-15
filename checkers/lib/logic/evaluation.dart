import '../models/board.dart';
import '../models/piece.dart';

/// The value of a man.
const int manValue = 100;

/// The value of a king.
const int kingValue = 320;

/// The bonus for each row a man has advanced toward promotion.
const int advanceValue = 5;

/// The bonus for closeness to the center of the board.
const int centerValue = 2;

/// How far side [side]'s man has advanced from square [square].
///
/// Zero on its own edge, nine on the promotion row.
int advanceOf(int square, Side side) =>
    side == Side.light ? boardSize - 1 - rowOf(square) : rowOf(square);

/// How close square [square] is to the center: eight right in the middle,
/// zero in the corners.
int centerBonusOf(int square) {
  final int rowDistance = (2 * rowOf(square) - (boardSize - 1)).abs();
  final int colDistance = (2 * colOf(square) - (boardSize - 1)).abs();
  return (2 * boardSize - 2 - rowDistance - colDistance) ~/ 2;
}

/// The sum of the weights of all of side [side]'s pieces.
int _weightOf(Board board, Side side) {
  var total = 0;
  for (final square in board.squaresOf(side)) {
    final Piece piece = board.at(square)!;
    total += piece.isKing
        ? kingValue
        : manValue + advanceValue * advanceOf(square, side);
    total += centerValue * centerBonusOf(square);
  }
  return total;
}

/// The position's evaluation from side [side]'s point of view: higher
/// means better for it.
///
/// Accounts for material, kings, how far the men have advanced, and
/// control of the center. The evaluation is strictly symmetric, so the
/// starting position scores zero for both sides.
int evaluate(Board board, Side side) =>
    _weightOf(board, side) - _weightOf(board, opponentOf(side));
