import 'package:checkers/logic/move_generator.dart';
import 'package:checkers/logic/rules.dart';
import 'package:checkers/models/board.dart';
import 'package:checkers/models/move.dart';
import 'package:checkers/models/piece.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a move carries the piece and leaves the starting square empty', () {
    final board = Board.withPieces({squareAt(5, 4): lightMan});
    final next = applyMove(
      board,
      Move(from: squareAt(5, 4), path: [squareAt(4, 3)]),
    );
    expect(next.at(squareAt(5, 4)), isNull);
    expect(next.at(squareAt(4, 3)), lightMan);
    expect(board.at(squareAt(5, 4)), lightMan);
  });

  test('captured pieces are removed once the chain has finished', () {
    final board = Board.withPieces({
      squareAt(6, 3): lightMan,
      squareAt(5, 4): darkMan,
      squareAt(3, 4): darkMan,
    });
    final move = legalMoves(board, Side.light).single;
    final next = applyMove(board, move);
    expect(next.at(squareAt(5, 4)), isNull);
    expect(next.at(squareAt(3, 4)), isNull);
    expect(next.at(squareAt(2, 3)), lightMan);
    expect(next.countOf(Side.dark), 0);
  });

  test('a man becomes a king when it finishes its move on the last row', () {
    final board = Board.withPieces({squareAt(1, 2): lightMan});
    final next = applyMove(
      board,
      Move(from: squareAt(1, 2), path: [squareAt(0, 1)]),
    );
    expect(next.at(squareAt(0, 1))!.isKing, isTrue);
  });

  test('dark becomes a king on row nine', () {
    final board = Board.withPieces({squareAt(8, 1): darkMan});
    final next = applyMove(
      board,
      Move(from: squareAt(8, 1), path: [squareAt(9, 0)]),
    );
    expect(next.at(squareAt(9, 0))!.isKing, isTrue);
  });

  test('a capture that ends on the last row promotes to a king', () {
    final board = Board.withPieces({
      squareAt(2, 3): lightMan,
      squareAt(1, 4): darkMan,
    });
    final move = legalMoves(board, Side.light).single;
    expect(move.to, squareAt(0, 5));
    final next = applyMove(board, move);
    expect(next.at(squareAt(0, 5))!.isKing, isTrue);
  });

  test('passing through the last row mid chain does not crown a piece', () {
    final board = Board.withPieces({
      squareAt(2, 3): lightMan,
      squareAt(1, 4): darkMan,
      squareAt(1, 6): darkMan,
    });
    final move = legalMoves(board, Side.light).single;
    expect(move.path, [squareAt(0, 5), squareAt(2, 7)]);
    final next = applyMove(board, move);
    expect(next.at(squareAt(2, 7))!.isKing, isFalse);
  });

  test('a man mid chain does not gain a king\'s long-range capture', () {
    final board = Board.withPieces({
      squareAt(2, 3): lightMan,
      squareAt(1, 4): darkMan,
      squareAt(1, 6): darkMan,
    });
    final move = legalMoves(board, Side.light).single;
    expect(move.captureCount, 2);
    expect(move.to, squareAt(2, 7));
  });

  test('a king on the last row stays a king', () {
    final board = Board.withPieces({squareAt(1, 2): lightKing});
    final next = applyMove(
      board,
      Move(from: squareAt(1, 2), path: [squareAt(0, 1)]),
    );
    expect(next.at(squareAt(0, 1))!.isKing, isTrue);
  });

  test('a move from an empty square is an error', () {
    final board = Board.empty();
    expect(
      () => applyMove(
        board,
        Move(from: squareAt(5, 4), path: [squareAt(4, 3)]),
      ),
      throwsArgumentError,
    );
  });

  test('a side with no pieces loses', () {
    final board = Board.withPieces({squareAt(5, 4): darkMan});
    expect(winnerOf(board, Side.light), Side.dark);
  });

  test('a side with no moves loses', () {
    final board = Board.withPieces({
      squareAt(9, 0): lightMan,
      squareAt(8, 1): darkMan,
      squareAt(7, 2): darkMan,
    });
    expect(winnerOf(board, Side.light), Side.dark);
  });

  test('as long as a move exists, there is no winner', () {
    expect(winnerOf(Board.initial(), Side.light), isNull);
    expect(winnerOf(Board.initial(), Side.dark), isNull);
  });
}
