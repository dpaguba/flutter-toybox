import 'dart:math';

import '../models/tetromino.dart';

/// Where the game draws its next pieces from.
///
/// The engine does not know how pieces are chosen, so a test can substitute
/// a known-in-advance order in place of a shuffled bag.
abstract class PieceSource {
  /// The next piece to enter play.
  TetrominoType next();

  /// The next `count` pieces, without drawing them.
  List<TetrominoType> peek(int count);
}

/// Piece generator following the seven-bag rule.
///
/// Every seven pieces are a shuffled set of the seven distinct types, so the
/// same piece can never come up three times in a row, and any given piece
/// never makes you wait longer than two bags.
class SevenBag implements PieceSource {
  SevenBag({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<TetrominoType> _queue = [];

  /// The next piece drawn from the bag.
  @override
  TetrominoType next() {
    _fillTo(1);
    return _queue.removeAt(0);
  }

  /// The next `count` pieces, without drawing them from the bag.
  @override
  List<TetrominoType> peek(int count) {
    _fillTo(count);
    return _queue.sublist(0, count);
  }

  void _fillTo(int count) {
    while (_queue.length < count) {
      final List<TetrominoType> bag = List.of(TetrominoType.values)
        ..shuffle(_random);
      _queue.addAll(bag);
    }
  }
}
