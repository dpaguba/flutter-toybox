import 'dart:math';

import '../logic/evaluation.dart';
import '../logic/move_generator.dart';
import '../logic/rules.dart';
import '../models/board.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../models/player.dart';

/// The deepest search allowed at the hard difficulty.
///
/// Capturing is compulsory, so branching stays narrow and six plies search
/// quickly. The clock still holds the real upper bound: depth alone
/// promises nothing in a position with long capture chains.
const int hardMaxDepth = 6;

/// How much time the hard difficulty gets per move.
///
/// Search runs on the same thread as rendering, so the budget is
/// deliberately short: better to lose half a ply of depth than freeze the
/// screen.
const Duration hardBudget = Duration(milliseconds: 400);

/// The score of a won position. An order of magnitude above any material
/// score.
const int _winScore = 1000000;

/// The signal that the thinking-time budget has run out.
class _Deadline implements Exception {
  const _Deadline();
}

/// Minimax with alpha-beta pruning, seen from side [side]'s point of view.
///
/// Raises:
///   _Deadline: if the time budget runs out in the middle of the search.
int _search(
  Board board,
  Side side,
  Side toMove,
  int depth,
  int alpha,
  int beta,
  Stopwatch watch,
  Duration budget,
) {
  if (watch.elapsed > budget) {
    throw const _Deadline();
  }
  final List<Move> moves = legalMoves(board, toMove);
  if (moves.isEmpty) {
    return toMove == side ? -(_winScore + depth) : _winScore + depth;
  }
  if (depth == 0) {
    return evaluate(board, side);
  }
  if (toMove == side) {
    var best = -_winScore * 2;
    for (final move in moves) {
      final int value = _search(
        applyMove(board, move),
        side,
        opponentOf(toMove),
        depth - 1,
        alpha,
        beta,
        watch,
        budget,
      );
      if (value > best) {
        best = value;
      }
      if (best > alpha) {
        alpha = best;
      }
      if (beta <= alpha) {
        break;
      }
    }
    return best;
  }
  var best = _winScore * 2;
  for (final move in moves) {
    final int value = _search(
      applyMove(board, move),
      side,
      opponentOf(toMove),
      depth - 1,
      alpha,
      beta,
      watch,
      budget,
    );
    if (value < best) {
      best = value;
    }
    if (best < beta) {
      beta = best;
    }
    if (beta <= alpha) {
      break;
    }
  }
  return best;
}

/// The best move found by iterative-deepening search.
///
/// Depth grows one ply at a time, and the moment the clock runs out, the
/// best move from the last fully searched depth is returned. A depth cut
/// off partway through is discarded entirely: half of it means nothing yet.
///
/// Raises:
///   StateError: if side [side] has no legal moves.
Move bestMove(
  Board board,
  Side side, {
  Random? random,
  int maxDepth = hardMaxDepth,
  Duration budget = hardBudget,
}) {
  final List<Move> moves = legalMoves(board, side);
  if (moves.isEmpty) {
    throw StateError("side ${side.name} has no legal moves");
  }
  if (random != null) {
    moves.shuffle(random);
  }
  final Stopwatch watch = Stopwatch()..start();
  Move chosen = moves.first;
  for (var depth = 1; depth <= maxDepth; depth++) {
    try {
      Move? bestSoFar;
      var bestValue = -_winScore * 2;
      var alpha = -_winScore * 2;
      for (final move in moves) {
        final int value = _search(
          applyMove(board, move),
          side,
          opponentOf(side),
          depth - 1,
          alpha,
          _winScore * 2,
          watch,
          budget,
        );
        if (bestSoFar == null || value > bestValue) {
          bestValue = value;
          bestSoFar = move;
        }
        if (bestValue > alpha) {
          alpha = bestValue;
        }
      }
      chosen = bestSoFar!;
    } on _Deadline {
      break;
    }
  }
  return chosen;
}

/// The move with the immediate best evaluation, without looking ahead at
/// the opponent's reply.
///
/// Raises:
///   StateError: if side [side] has no legal moves.
Move greedyMove(Board board, Side side, Random random) {
  final List<Move> moves = legalMoves(board, side);
  if (moves.isEmpty) {
    throw StateError("side ${side.name} has no legal moves");
  }
  var bestValue = -_winScore * 2;
  final List<Move> best = [];
  for (final move in moves) {
    final int value = evaluate(applyMove(board, move), side);
    if (value > bestValue) {
      bestValue = value;
      best
        ..clear()
        ..add(move);
    } else if (value == bestValue) {
      best.add(move);
    }
  }
  return best[random.nextInt(best.length)];
}

/// The computer's move at difficulty [level].
///
/// The random source is passed in from outside rather than created
/// internally: otherwise a test could not replay the same game twice.
///
/// Raises:
///   StateError: if side [side] has no legal moves.
Move chooseMove(
  Board board,
  Side side,
  Difficulty level,
  Random random, {
  Duration budget = hardBudget,
}) {
  if (level == Difficulty.easy) {
    final List<Move> moves = legalMoves(board, side);
    if (moves.isEmpty) {
      throw StateError("side ${side.name} has no legal moves");
    }
    return moves[random.nextInt(moves.length)];
  }
  if (level == Difficulty.medium) {
    return greedyMove(board, side, random);
  }
  return bestMove(board, side, random: random, budget: budget);
}
