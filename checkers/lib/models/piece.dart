/// A side in the game: light at the bottom, dark at the top.
enum Side { light, dark }

/// The opposite side.
Side opponentOf(Side side) => side == Side.light ? Side.dark : Side.light;

/// A piece on the board: a man or a king.
///
/// Immutable: instead of crowning a piece in place, the move generator
/// creates a new one. That way a board copy made during search cannot
/// silently mutate the original.
class Piece {
  const Piece({required this.side, this.isKing = false});

  /// Which side the piece belongs to.
  final Side side;

  /// Whether the piece is a king.
  final bool isKing;

  /// The same piece, but now a king.
  Piece crowned() => isKing ? this : Piece(side: side, isKing: true);

  @override
  bool operator ==(Object other) =>
      other is Piece && other.side == side && other.isKing == isKing;

  @override
  int get hashCode => Object.hash(side, isKing);

  @override
  String toString() => "${side.name}${isKing ? 'King' : 'Man'}";
}

/// A light man.
const Piece lightMan = Piece(side: Side.light);

/// A dark man.
const Piece darkMan = Piece(side: Side.dark);

/// A light king.
const Piece lightKing = Piece(side: Side.light, isKing: true);

/// A dark king.
const Piece darkKing = Piece(side: Side.dark, isKing: true);
