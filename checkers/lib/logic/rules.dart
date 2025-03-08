import '../models/board.dart';
import '../models/move.dart';
import '../models/piece.dart';
import 'move_generator.dart';

/// Whether piece [piece], having finished its move on square [square],
/// gets promoted.
///
/// What is checked is the move's actual end square: passing through the
/// last row in the middle of a capture chain does not crown a piece.
bool shouldPromote(Piece piece, int square) =>
    !piece.isKing && rowOf(square) == promotionRowOf(piece.side);

/// The position after move [move]. The original board is left unchanged.
///
/// Captured pieces are all removed together, once the chain has ended.
///
/// Raises:
///   ArgumentError: if there is no piece on the move's starting square.
Board applyMove(Board board, Move move) {
  final Piece? piece = board.at(move.from);
  if (piece == null) {
    throw ArgumentError.value(
      move.from,
      "move.from",
      "there is no piece on the move's starting square",
    );
  }
  final List<Piece?> squares = List<Piece?>.of(board.squares);
  squares[move.from] = null;
  for (final victim in move.captured) {
    squares[victim] = null;
  }
  squares[move.to] = shouldPromote(piece, move.to) ? piece.crowned() : piece;
  return Board(squares);
}

/// Whether side [side] has at least one legal move.
bool hasMoves(Board board, Side side) => legalMoves(board, side).isNotEmpty;

/// The winner, if the game has ended, otherwise null.
///
/// The side to move loses when it has no pieces or no moves left.
Side? winnerOf(Board board, Side toMove) {
  if (board.countOf(toMove) == 0 || !hasMoves(board, toMove)) {
    return opponentOf(toMove);
  }
  return null;
}
