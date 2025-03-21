import 'package:checkers/logic/evaluation.dart';
import 'package:checkers/models/board.dart';
import 'package:checkers/models/piece.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the starting position is even', () {
    expect(evaluate(Board.initial(), Side.light), 0);
    expect(evaluate(Board.initial(), Side.dark), 0);
  });

  test('the evaluation is symmetric: a plus for one side is a minus for the other', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(7, 6): lightKing,
      squareAt(2, 3): darkMan,
    });
    expect(
      evaluate(board, Side.light),
      -evaluate(board, Side.dark),
    );
  });

  test('an extra piece is an advantage', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(6, 5): lightMan,
      squareAt(2, 3): darkMan,
    });
    expect(evaluate(board, Side.light), greaterThan(0));
  });

  test('a king is worth more than a man', () {
    final withKing = Board.withPieces({
      squareAt(5, 4): lightKing,
      squareAt(2, 3): darkMan,
    });
    final withMan = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(2, 3): darkMan,
    });
    expect(
      evaluate(withKing, Side.light),
      greaterThan(evaluate(withMan, Side.light)),
    );
  });

  test('advancing forward adds to the evaluation', () {
    final near = Board.withPieces({
      squareAt(2, 3): lightMan,
      squareAt(7, 6): darkMan,
    });
    final far = Board.withPieces({
      squareAt(8, 3): lightMan,
      squareAt(7, 6): darkMan,
    });
    expect(
      evaluate(near, Side.light),
      greaterThan(evaluate(far, Side.light)),
    );
  });

  test('the center is worth more than the edge', () {
    final center = Board.withPieces({squareAt(5, 4): lightKing});
    final edge = Board.withPieces({squareAt(5, 0): lightKing});
    expect(
      evaluate(center, Side.light),
      greaterThan(evaluate(edge, Side.light)),
    );
  });
}
