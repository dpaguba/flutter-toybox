import 'package:tetris/logic/bag.dart';
import 'package:tetris/models/tetromino.dart';

/// A piece source with a predetermined order, so the test is reproducible.
///
/// When the list runs out, it starts over from the beginning, so a single
/// value is enough for the game to keep receiving the same piece indefinitely.
class FixedSource implements PieceSource {
  FixedSource(this.order);

  final List<TetrominoType> order;
  int _index = 0;

  @override
  TetrominoType next() {
    final TetrominoType type = order[_index % order.length];
    _index++;
    return type;
  }

  @override
  List<TetrominoType> peek(int count) => List.generate(
        count,
        (offset) => order[(_index + offset) % order.length],
      );
}
