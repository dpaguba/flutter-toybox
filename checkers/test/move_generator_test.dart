import 'package:checkers/logic/move_generator.dart';
import 'package:checkers/models/board.dart';
import 'package:checkers/models/move.dart';
import 'package:checkers/models/piece.dart';
import 'package:flutter_test/flutter_test.dart';

/// The squares each of the moves leads to.
Set<int> destinations(List<Move> moves) => moves.map((move) => move.to).toSet();

void main() {
  test('a man moves diagonally forward in either direction', () {
    final board = Board.withPieces({squareAt(5, 4): lightMan});
    final moves = legalMoves(board, Side.light);
    expect(destinations(moves), {squareAt(4, 3), squareAt(4, 5)});
  });

  test('a man does not move backward without capturing', () {
    final board = Board.withPieces({squareAt(5, 4): lightMan});
    final moves = legalMoves(board, Side.light);
    expect(destinations(moves).contains(squareAt(6, 3)), isFalse);
    expect(destinations(moves).contains(squareAt(6, 5)), isFalse);
  });

  test('a dark man moves toward row nine', () {
    final board = Board.withPieces({squareAt(4, 5): darkMan});
    expect(
      destinations(legalMoves(board, Side.dark)),
      {squareAt(5, 4), squareAt(5, 6)},
    );
  });

  test('a man captures backward', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(6, 5): darkMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves, hasLength(1));
    expect(moves.first.to, squareAt(7, 6));
    expect(moves.first.captured, [squareAt(6, 5)]);
  });

  test('capturing is compulsory: quiet moves disappear', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(4, 5): darkMan,
      squareAt(7, 8): lightMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves, hasLength(1));
    expect(moves.first.from, squareAt(5, 4));
    expect(moves.first.to, squareAt(3, 6));
  });

  test('among several captures, only the longest one survives', () {
    final board = Board.withPieces({
      squareAt(6, 3): lightMan,
      squareAt(5, 2): darkMan,
      squareAt(5, 4): darkMan,
      squareAt(3, 4): darkMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves, hasLength(1));
    expect(moves.first.captureCount, 2);
    expect(
      moves.first.captured.toSet(),
      {squareAt(5, 4), squareAt(3, 4)},
    );
    expect(moves.first.to, squareAt(2, 3));
  });

  test('a king moves diagonally any distance', () {
    final board = Board.withPieces({squareAt(5, 4): lightKing});
    final moves = legalMoves(board, Side.light);
    expect(moves, hasLength(17));
    expect(destinations(moves).contains(squareAt(1, 0)), isTrue);
    expect(destinations(moves).contains(squareAt(0, 9)), isTrue);
    expect(destinations(moves).contains(squareAt(9, 0)), isTrue);
    expect(destinations(moves).contains(squareAt(9, 8)), isTrue);
  });

  test('a king stops in front of a piece blocking its path', () {
    final board = Board.withPieces({
      squareAt(9, 0): lightKing,
      squareAt(6, 3): lightMan,
    });
    final moves = legalMoves(board, Side.light)
        .where((move) => move.from == squareAt(9, 0))
        .toList();
    expect(
      destinations(moves),
      {squareAt(8, 1), squareAt(7, 2)},
    );
  });

  test('a king captures from afar and can land on any free square beyond the captured piece', () {
    final board = Board.withPieces({
      squareAt(9, 0): lightKing,
      squareAt(5, 4): darkMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves, hasLength(5));
    expect(
      destinations(moves),
      {
        squareAt(4, 5),
        squareAt(3, 6),
        squareAt(2, 7),
        squareAt(1, 8),
        squareAt(0, 9),
      },
    );
    for (final move in moves) {
      expect(move.captured, [squareAt(5, 4)]);
    }
  });

  test('a king does not capture when another piece stands right behind the opponent\'s', () {
    final board = Board.withPieces({
      squareAt(9, 0): lightKing,
      squareAt(5, 4): darkMan,
      squareAt(4, 5): darkMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves.every((move) => !move.isCapture), isTrue);
  });

  test('a piece cannot jump over one of its own', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(4, 5): lightMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves.every((move) => !move.isCapture), isTrue);
    final fromMan = moves.where((move) => move.from == squareAt(5, 4));
    expect(destinations(fromMan.toList()), {squareAt(4, 3)});
  });

  test('the same piece cannot be captured twice in one chain', () {
    final board = Board.withPieces({
      squareAt(4, 3): lightMan,
      squareAt(3, 4): darkMan,
      squareAt(3, 6): darkMan,
      squareAt(5, 6): darkMan,
      squareAt(5, 4): darkMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves, isNotEmpty);
    for (final move in moves) {
      expect(move.captureCount, 4);
      expect(move.captured.toSet(), hasLength(4));
      expect(move.to, squareAt(4, 3));
    }
  });

  test('a captured piece stays on the board until the chain ends and blocks the way', () {
    final board = Board.withPieces({
      squareAt(6, 1): lightMan,
      squareAt(5, 2): darkMan,
      squareAt(3, 2): darkMan,
      squareAt(3, 4): darkMan,
      squareAt(5, 4): darkMan,
    });
    final moves = legalMoves(board, Side.light);
    expect(moves, isNotEmpty);
    for (final move in moves) {
      expect(move.captureCount, 2);
      expect(move.to, isNot(squareAt(6, 1)));
    }
  });

  test('with no pieces of its own, a side has no moves', () {
    final board = Board.withPieces({squareAt(5, 4): darkMan});
    expect(legalMoves(board, Side.light), isEmpty);
  });

  test('a boxed-in man has no moves', () {
    final board = Board.withPieces({
      squareAt(9, 0): lightMan,
      squareAt(8, 1): darkMan,
      squareAt(7, 2): darkMan,
    });
    expect(legalMoves(board, Side.light), isEmpty);
  });

  test('at the start both sides have nine moves each', () {
    final board = Board.initial();
    expect(legalMoves(board, Side.light), hasLength(9));
    expect(legalMoves(board, Side.dark), hasLength(9));
  });

  test('a chain records the step-by-step path, not just the final square', () {
    final board = Board.withPieces({
      squareAt(6, 3): lightMan,
      squareAt(5, 4): darkMan,
      squareAt(3, 4): darkMan,
    });
    final move = legalMoves(board, Side.light).single;
    expect(move.path, [squareAt(4, 5), squareAt(2, 3)]);
    expect(move.captured, [squareAt(5, 4), squareAt(3, 4)]);
  });
}
