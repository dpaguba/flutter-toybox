import '../models/board.dart';
import '../models/move.dart';
import '../models/piece.dart';

/// The four diagonal directions as (row step, column step) pairs.
const List<List<int>> _diagonals = [
  [-1, -1],
  [-1, 1],
  [1, -1],
  [1, 1],
];

/// The square [distance] steps away from [square] in direction (dr, dc),
/// or null if it falls off the board.
int? _shift(int square, int dr, int dc, int distance) {
  final int row = rowOf(square) + dr * distance;
  final int col = colOf(square) + dc * distance;
  if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
    return null;
  }
  return squareAt(row, col);
}

/// A single jump: which square it captures through, and where it lands.
class _Jump {
  const _Jump(this.victim, this.landing);

  final int victim;
  final int landing;
}

/// All jumps available to piece [piece] from square [square].
///
/// [taken] holds the pieces already captured in this chain. They still
/// stand on the board, blocking the way, and cannot be captured again.
List<_Jump> _jumpsFrom(
  List<Piece?> squares,
  int square,
  Piece piece,
  Set<int> taken,
) {
  final List<_Jump> jumps = [];
  for (final direction in _diagonals) {
    final int dr = direction[0];
    final int dc = direction[1];
    if (piece.isKing) {
      var distance = 1;
      int? victim = _shift(square, dr, dc, distance);
      while (victim != null && squares[victim] == null) {
        distance++;
        victim = _shift(square, dr, dc, distance);
      }
      if (victim == null ||
          squares[victim]!.side == piece.side ||
          taken.contains(victim)) {
        continue;
      }
      var landingDistance = distance + 1;
      int? landing = _shift(square, dr, dc, landingDistance);
      while (landing != null && squares[landing] == null) {
        jumps.add(_Jump(victim, landing));
        landingDistance++;
        landing = _shift(square, dr, dc, landingDistance);
      }
    } else {
      final int? victim = _shift(square, dr, dc, 1);
      if (victim == null ||
          squares[victim] == null ||
          squares[victim]!.side == piece.side ||
          taken.contains(victim)) {
        continue;
      }
      final int? landing = _shift(square, dr, dc, 2);
      if (landing == null || squares[landing] != null) {
        continue;
      }
      jumps.add(_Jump(victim, landing));
    }
  }
  return jumps;
}

/// Unwinds the capture chain depth first and collects the finished chains
/// into [out].
///
/// The piece stays whatever it was when the move started: a man that
/// passes through the last row in the middle of a chain does not gain a
/// king's long-range capture.
void _extendChain(
  List<Piece?> squares,
  int from,
  int current,
  Piece piece,
  List<int> path,
  List<int> captured,
  Set<int> taken,
  List<Move> out,
) {
  final List<_Jump> jumps = _jumpsFrom(squares, current, piece, taken);
  if (jumps.isEmpty) {
    if (captured.isNotEmpty) {
      out.add(
        Move(
          from: from,
          path: List<int>.of(path),
          captured: List<int>.of(captured),
        ),
      );
    }
    return;
  }
  for (final jump in jumps) {
    path.add(jump.landing);
    captured.add(jump.victim);
    taken.add(jump.victim);
    _extendChain(
      squares,
      from,
      jump.landing,
      piece,
      path,
      captured,
      taken,
      out,
    );
    path.removeLast();
    captured.removeLast();
    taken.remove(jump.victim);
  }
}

/// All capture chains for side [side], each carried through to its end.
///
/// A chain cannot be cut short partway through: the list holds only those
/// chains with no further continuation.
List<Move> captureMoves(Board board, Side side) {
  final List<Move> moves = [];
  for (final square in board.squaresOf(side)) {
    final Piece piece = board.at(square)!;
    final List<Piece?> working = List<Piece?>.of(board.squares);
    working[square] = null;
    _extendChain(working, square, square, piece, [], [], <int>{}, moves);
  }
  return moves;
}

/// Non-capturing moves for side [side].
///
/// A man moves one square forward; a king slides along the diagonal for
/// as long as the squares stay empty.
List<Move> quietMoves(Board board, Side side) {
  final List<Move> moves = [];
  for (final square in board.squaresOf(side)) {
    final Piece piece = board.at(square)!;
    if (piece.isKing) {
      for (final direction in _diagonals) {
        var distance = 1;
        int? target = _shift(square, direction[0], direction[1], distance);
        while (target != null && board.at(target) == null) {
          moves.add(Move(from: square, path: [target]));
          distance++;
          target = _shift(square, direction[0], direction[1], distance);
        }
      }
    } else {
      final int dr = forwardStepOf(side);
      for (final dc in [-1, 1]) {
        final int? target = _shift(square, dr, dc, 1);
        if (target != null && board.at(target) == null) {
          moves.add(Move(from: square, path: [target]));
        }
      }
    }
  }
  return moves;
}

/// Legal moves for side [side] under international draughts rules.
///
/// Capturing is compulsory, and of all the chains only the longest ones
/// survive: what is compared is the number of pieces captured, not which
/// pieces they are.
List<Move> legalMoves(Board board, Side side) {
  final List<Move> captures = captureMoves(board, side);
  if (captures.isEmpty) {
    return quietMoves(board, side);
  }
  var best = 0;
  for (final move in captures) {
    if (move.captureCount > best) {
      best = move.captureCount;
    }
  }
  return captures.where((move) => move.captureCount == best).toList();
}
