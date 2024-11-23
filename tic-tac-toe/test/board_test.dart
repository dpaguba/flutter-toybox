import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/board.dart';

void main() {
  test('an empty board has no winner', () {
    final board = Board.empty();
    expect(board.winner, isNull);
    expect(board.isFull, isFalse);
    expect(board.emptyCells.length, 9);
  });

  test('win by row', () {
    final board = Board.empty();
    board.place(0, "X");
    board.place(1, "X");
    board.place(2, "X");
    expect(board.winner, "X");
    expect(board.winningLine, [0, 1, 2]);
  });

  test('win by column', () {
    final board = Board.empty();
    for (final i in [1, 4, 7]) {
      board.place(i, "O");
    }
    expect(board.winner, "O");
    expect(board.winningLine, [1, 4, 7]);
  });

  test('win by diagonal in both directions', () {
    final first = Board.empty();
    for (final i in [0, 4, 8]) {
      first.place(i, "X");
    }
    expect(first.winningLine, [0, 4, 8]);

    final second = Board.empty();
    for (final i in [2, 4, 6]) {
      second.place(i, "O");
    }
    expect(second.winningLine, [2, 4, 6]);
  });

  test('a full board with no line is a draw', () {
    final board = Board.empty();
    const layout = ["X", "O", "X", "X", "O", "O", "O", "X", "X"];
    for (var i = 0; i < 9; i++) {
      board.place(i, layout[i]);
    }
    expect(board.isFull, isTrue);
    expect(board.winner, isNull);
  });

  test('an occupied cell cannot be overwritten', () {
    final board = Board.empty();
    board.place(0, "X");
    expect(board.canPlace(0), isFalse);
    board.place(0, "O");
    expect(board.cells[0], "X");
  });

  test('a copy does not drag the original along with it', () {
    final board = Board.empty();
    board.place(0, "X");
    final other = board.copy();
    other.place(1, "O");
    expect(board.cells[1], "");
  });
}
