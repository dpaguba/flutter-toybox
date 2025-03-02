import 'piece.dart';

/// The board's side length in squares.
const int boardSize = 10;

/// The total number of squares on the board.
const int squareCount = boardSize * boardSize;

/// How many rows of pieces each side starts with.
const int pieceRows = 4;

/// The square number for a given row and column. Row zero is at the top.
int squareAt(int row, int col) => row * boardSize + col;

/// The row a square is on.
int rowOf(int square) => square ~/ boardSize;

/// The column a square is on.
int colOf(int square) => square % boardSize;

/// Whether a square is a playable one. The game is played only on the
/// dark squares.
bool isPlaySquare(int square) => (rowOf(square) + colOf(square)).isOdd;

/// The row on which a man of side [side] becomes a king.
int promotionRowOf(Side side) => side == Side.light ? 0 : boardSize - 1;

/// Which way "forward" points for side [side]: how the row changes.
int forwardStepOf(Side side) => side == Side.light ? -1 : 1;

/// A position on the ten by ten board.
///
/// Squares live in a single hundred-element list, with an empty square
/// represented as null. No Flutter import here: search traverses the
/// board thousands of times and should not pay for widgets.
class Board {
  /// Creates a position from a ready-made list of squares.
  ///
  /// Raises:
  ///   ArgumentError: if the list does not contain exactly [squareCount]
  ///   squares.
  Board(this.squares) {
    if (squares.length != squareCount) {
      throw ArgumentError.value(
        squares.length,
        "squares",
        "the board must contain exactly $squareCount squares",
      );
    }
  }

  /// An empty board.
  Board.empty() : squares = List<Piece?>.filled(squareCount, null);

  /// The starting position: [pieceRows] rows of pieces on each side.
  factory Board.initial() {
    final board = Board.empty();
    for (var row = 0; row < pieceRows; row++) {
      for (var col = 0; col < boardSize; col++) {
        final int square = squareAt(row, col);
        if (isPlaySquare(square)) {
          board.squares[square] = darkMan;
        }
      }
    }
    for (var row = boardSize - pieceRows; row < boardSize; row++) {
      for (var col = 0; col < boardSize; col++) {
        final int square = squareAt(row, col);
        if (isPlaySquare(square)) {
          board.squares[square] = lightMan;
        }
      }
    }
    return board;
  }

  /// A position built from individual pieces. Handy for tests and for
  /// custom starting layouts.
  factory Board.withPieces(Map<int, Piece> pieces) {
    final board = Board.empty();
    pieces.forEach((square, piece) {
      board.squares[square] = piece;
    });
    return board;
  }

  final List<Piece?> squares;

  /// The piece on a square, or null.
  Piece? at(int square) => squares[square];

  /// The squares occupied by side [side].
  Iterable<int> squaresOf(Side side) sync* {
    for (var square = 0; square < squareCount; square++) {
      if (squares[square]?.side == side) {
        yield square;
      }
    }
  }

  /// How many pieces side [side] has left.
  int countOf(Side side) => squaresOf(side).length;

  /// An independent copy of the position.
  Board copy() => Board(List<Piece?>.of(squares));
}
