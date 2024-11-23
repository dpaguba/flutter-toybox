import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/ai/bot.dart';
import 'package:tic_tac_toe/models/board.dart';
import 'package:tic_tac_toe/models/player.dart';

/// Plays out every possible game of a human against a perfect bot.
///
/// The human plays X and moves first, trying every possible move in turn.
/// The bot plays O and always takes the best move available. The function
/// returns the number of games the bot lost.
int losses(Board board, bool humanTurn) {
  final champion = board.winner;
  if (champion != null) {
    return champion == "X" ? 1 : 0;
  }
  if (board.isFull) {
    return 0;
  }
  if (humanTurn) {
    var total = 0;
    for (final index in board.emptyCells) {
      final next = board.copy();
      next.place(index, "X");
      total += losses(next, false);
    }
    return total;
  }
  final next = board.copy();
  next.place(bestMove(next, "O"), "O");
  return losses(next, true);
}

void main() {
  /// This test plays against the bestMove function, i.e. perfect play with
  /// no randomness mixed in. Difficulty.hard deliberately deviates from
  /// bestMove on one move in ten (see chooseMove), so the hard level itself
  /// can still lose a game: that is verified by a separate test below.
  test('minimax never loses a single game', () {
    expect(losses(Board.empty(), true), 0);
  });

  test('hard finishes the game when it can', () {
    final board = Board(["O", "O", "", "X", "X", "", "", "", ""]);
    expect(bestMove(board, "O"), 2);
  });

  test('hard blocks an inevitable loss', () {
    final board = Board(["X", "X", "", "", "O", "", "", "", ""]);
    expect(bestMove(board, "O"), 2);
  });

  test('hard sometimes does not play the best move', () {
    final board = Board(["X", "X", "", "", "O", "", "", "", ""]);
    var deviations = 0;
    for (var seed = 0; seed < 400; seed++) {
      if (chooseMove(board, "O", Difficulty.hard, Random(seed)) != 2) {
        deviations++;
      }
    }
    expect(deviations, greaterThan(10));
    expect(deviations, lessThan(120));
  });

  /// chooseMove takes a random move in 10% of games, but out of nine free
  /// cells that random move occasionally coincides with bestMove itself, so
  /// the number of deviations comes out somewhat below a flat 10% (around
  /// 178 out of 2000, not 200). The band around this number is deliberately
  /// wide so it does not catch statistical noise.
  test('hard deviates roughly one time in ten', () {
    final Board board = Board.empty();
    final int best = bestMove(board, "O");
    var deviations = 0;
    for (var seed = 0; seed < 2000; seed++) {
      if (chooseMove(board, "O", Difficulty.hard, Random(seed)) != best) {
        deviations++;
      }
    }
    expect(deviations, inInclusiveRange(120, 320));
  });
}
