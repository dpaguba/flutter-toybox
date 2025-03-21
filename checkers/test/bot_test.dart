import 'dart:math';

import 'package:checkers/ai/bot.dart';
import 'package:checkers/logic/move_generator.dart';
import 'package:checkers/logic/rules.dart';
import 'package:checkers/models/board.dart';
import 'package:checkers/models/piece.dart';
import 'package:checkers/models/player.dart';
import 'package:flutter_test/flutter_test.dart';

/// A handful of dissimilar positions that every difficulty is run through.
List<Board> positions() => [
      Board.initial(),
      Board.withPieces({
        squareAt(6, 3): lightMan,
        squareAt(5, 4): darkMan,
        squareAt(3, 4): darkMan,
        squareAt(2, 1): darkKing,
      }),
      Board.withPieces({
        squareAt(9, 0): lightKing,
        squareAt(5, 4): darkMan,
        squareAt(1, 2): darkKing,
        squareAt(8, 7): lightMan,
      }),
    ];

void main() {
  for (final level in Difficulty.values) {
    test('difficulty ${level.name} always returns a legal move', () {
      for (final board in positions()) {
        final allowed = legalMoves(board, Side.light).toSet();
        for (var seed = 0; seed < 8; seed++) {
          final move = chooseMove(board, Side.light, level, Random(seed));
          expect(allowed.contains(move), isTrue);
        }
      }
    });
  }

  test('with no legal moves the bot throws an error', () {
    final board = Board.withPieces({
      squareAt(9, 0): lightMan,
      squareAt(8, 1): darkMan,
      squareAt(7, 2): darkMan,
    });
    expect(
      () => chooseMove(board, Side.light, Difficulty.easy, Random(1)),
      throwsStateError,
    );
  });

  test('easy difficulty does not always repeat the same move', () {
    final board = Board.initial();
    final seen = <String>{};
    for (var seed = 0; seed < 20; seed++) {
      seen.add(
        chooseMove(board, Side.light, Difficulty.easy, Random(seed)).toString(),
      );
    }
    expect(seen.length, greaterThan(1));
  });

  test('medium difficulty takes the promotion to a king', () {
    final board = Board.withPieces({
      squareAt(1, 2): lightMan,
      squareAt(5, 4): lightMan,
      squareAt(8, 7): darkMan,
    });
    final move = chooseMove(board, Side.light, Difficulty.medium, Random(3));
    expect(move.from, squareAt(1, 2));
    expect(applyMove(board, move).at(move.to)!.isKing, isTrue);
  });

  test('hard difficulty sees the opponent\'s reply and does not hang a piece', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(3, 6): darkMan,
      squareAt(1, 2): darkMan,
    });
    for (var seed = 0; seed < 5; seed++) {
      final move = chooseMove(board, Side.light, Difficulty.hard, Random(seed));
      expect(move.to, squareAt(4, 3));
    }
  });

  test('medium difficulty looks only at its own evaluation and heads for the center', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(3, 6): darkMan,
      squareAt(1, 2): darkMan,
    });
    final move = chooseMove(board, Side.light, Difficulty.medium, Random(4));
    expect(move.to, squareAt(4, 5));
  });

  test('hard difficulty stays within the time budget', () {
    final board = Board.initial();
    final watch = Stopwatch()..start();
    chooseMove(
      board,
      Side.light,
      Difficulty.hard,
      Random(1),
      budget: const Duration(milliseconds: 300),
    );
    watch.stop();
    expect(watch.elapsedMilliseconds, lessThan(1200));
  });
}
