import 'package:checkers/models/board.dart';
import 'package:checkers/models/piece.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the starting layout has twenty pieces on four rows each', () {
    final board = Board.initial();
    expect(board.countOf(Side.light), 20);
    expect(board.countOf(Side.dark), 20);
  });

  test('the starting layout occupies only dark squares', () {
    final board = Board.initial();
    for (var square = 0; square < squareCount; square++) {
      if (board.at(square) != null) {
        expect(isPlaySquare(square), isTrue);
      }
    }
  });

  test('the starting layout leaves the two middle rows empty', () {
    final board = Board.initial();
    for (var col = 0; col < boardSize; col++) {
      expect(board.at(squareAt(4, col)), isNull);
      expect(board.at(squareAt(5, col)), isNull);
    }
  });

  test('dark is at the top, light at the bottom, and no kings at the start', () {
    final board = Board.initial();
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < boardSize; col++) {
        final piece = board.at(squareAt(row, col));
        if (piece != null) {
          expect(piece.side, Side.dark);
          expect(piece.isKing, isFalse);
        }
      }
    }
    for (var row = 6; row < boardSize; row++) {
      for (var col = 0; col < boardSize; col++) {
        final piece = board.at(squareAt(row, col));
        if (piece != null) {
          expect(piece.side, Side.light);
          expect(piece.isKing, isFalse);
        }
      }
    }
  });

  test('light promotes on row zero, dark on row nine', () {
    expect(promotionRowOf(Side.light), 0);
    expect(promotionRowOf(Side.dark), 9);
    expect(forwardStepOf(Side.light), -1);
    expect(forwardStepOf(Side.dark), 1);
  });

  test('a copy of the board does not carry the original along with it', () {
    final board = Board.initial();
    final other = board.copy();
    other.squares[squareAt(4, 1)] = lightMan;
    expect(board.at(squareAt(4, 1)), isNull);
  });

  test('a board with the wrong number of squares is an error', () {
    expect(() => Board(List<Piece?>.filled(64, null)), throwsArgumentError);
  });

  test('the list of a side\'s squares returns only its own pieces', () {
    final board = Board.withPieces({
      squareAt(5, 4): lightMan,
      squareAt(3, 2): darkMan,
      squareAt(7, 6): lightKing,
    });
    expect(
      board.squaresOf(Side.light).toSet(),
      {squareAt(5, 4), squareAt(7, 6)},
    );
    expect(board.squaresOf(Side.dark).toSet(), {squareAt(3, 2)});
  });
}
