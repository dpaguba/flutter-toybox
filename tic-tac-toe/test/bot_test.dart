import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/ai/bot.dart';
import 'package:tic_tac_toe/models/board.dart';
import 'package:tic_tac_toe/models/player.dart';

void main() {
  test('easy only moves into an empty cell', () {
    final board = Board(["X", "O", "X", "", "O", "", "X", "", ""]);
    for (var seed = 0; seed < 50; seed++) {
      final move = chooseMove(board, "O", Difficulty.easy, Random(seed));
      expect(board.canPlace(move), isTrue);
    }
  });

  test('medium finishes the game when a winning move is available', () {
    final board = Board(["O", "O", "", "X", "X", "", "", "", ""]);
    expect(chooseMove(board, "O", Difficulty.medium, Random(1)), 2);
  });

  test("medium blocks the opponent's win", () {
    final board = Board(["X", "X", "", "O", "", "", "", "", ""]);
    expect(chooseMove(board, "O", Difficulty.medium, Random(1)), 2);
  });

  test('taking its own win outweighs blocking', () {
    final board = Board(["O", "O", "", "X", "X", "", "", "", ""]);
    final move = chooseMove(board, "O", Difficulty.medium, Random(1));
    expect(move, 2);
    expect(move, isNot(5));
  });

  test('throws on a full board', () {
    final board = Board(
      ["X", "O", "X", "X", "O", "O", "O", "X", "X"],
    );
    expect(
      () => chooseMove(board, "O", Difficulty.easy, Random(1)),
      throwsStateError,
    );
  });
}
