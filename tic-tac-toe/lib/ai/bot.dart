import 'dart:math';

import '../models/board.dart';
import '../models/player.dart';

/// The opponent's mark.
String _other(String mark) => mark == "X" ? "O" : "X";

/// Finds a cell that immediately completes a line for [mark].
int? _winningMove(Board board, String mark) {
  for (final index in board.emptyCells) {
    final probe = board.copy();
    probe.place(index, mark);
    if (probe.winner == mark) {
      return index;
    }
  }
  return null;
}

/// Scores a position for [mark] with alpha-beta pruning.
///
/// Returns a positive number for a win (the sooner the win, the larger the
/// number), a negative number for a loss, and zero for a draw. Depth is
/// subtracted so the bot wins as quickly as possible and loses as slowly as
/// possible, instead of dragging a won position out to the end of the board.
int _score(Board board, String mark, String turn, int depth, int alpha,
    int beta) {
  final String? champion = board.winner;
  if (champion != null) {
    return champion == mark ? 10 - depth : depth - 10;
  }
  if (board.isFull) {
    return 0;
  }
  if (turn == mark) {
    var best = -100;
    for (final index in board.emptyCells) {
      final next = board.copy();
      next.place(index, turn);
      final value =
          _score(next, mark, _other(turn), depth + 1, alpha, beta);
      best = value > best ? value : best;
      alpha = alpha > best ? alpha : best;
      if (beta <= alpha) {
        break;
      }
    }
    return best;
  }
  var best = 100;
  for (final index in board.emptyCells) {
    final next = board.copy();
    next.place(index, turn);
    final value = _score(next, mark, _other(turn), depth + 1, alpha, beta);
    best = value < best ? value : best;
    beta = beta < best ? beta : best;
    if (beta <= alpha) {
      break;
    }
  }
  return best;
}

/// The best move, with no randomness mixed in.
///
/// Raises:
///   StateError: if there are no empty cells left.
int bestMove(Board board, String mark) {
  final List<int> free = board.emptyCells;
  if (free.isEmpty) {
    throw StateError("no empty cells left on the board");
  }
  var bestIndex = free.first;
  var bestValue = -100;
  for (final index in free) {
    final next = board.copy();
    next.place(index, mark);
    final value = _score(next, mark, _other(mark), 1, -100, 100);
    if (value > bestValue) {
      bestValue = value;
      bestIndex = index;
    }
  }
  return bestIndex;
}

/// Chooses a move according to the difficulty level.
///
/// The random generator is passed in from outside rather than created
/// internally: otherwise a test could not reproduce the same game twice.
///
/// Raises:
///   StateError: if there are no empty cells left.
int chooseMove(Board board, String mark, Difficulty level, Random random) {
  final List<int> free = board.emptyCells;
  if (free.isEmpty) {
    throw StateError("no empty cells left on the board");
  }
  if (level == Difficulty.easy) {
    return free[random.nextInt(free.length)];
  }
  if (level == Difficulty.hard) {
    if (random.nextInt(10) == 0) {
      return free[random.nextInt(free.length)];
    }
    return bestMove(board, mark);
  }
  final int? win = _winningMove(board, mark);
  if (win != null) {
    return win;
  }
  final int? block = _winningMove(board, _other(mark));
  if (block != null) {
    return block;
  }
  return free[random.nextInt(free.length)];
}
