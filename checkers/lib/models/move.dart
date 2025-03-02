/// A single move: either a quiet step or a whole capture chain.
///
/// [path] holds the squares the piece lands on, one after another, so a
/// quiet move has exactly one element there. The chain is kept step by
/// step because on screen the player walks through it jump by jump.
class Move {
  const Move({required this.from, required this.path, this.captured = const []});

  /// Where the move starts.
  final int from;

  /// The landing squares, in the order the move visits them.
  final List<int> path;

  /// The captured squares, in the order they are taken.
  final List<int> captured;

  /// The move's final square.
  int get to => path.last;

  /// How many pieces the move captures.
  int get captureCount => captured.length;

  /// Whether the move is a capture.
  bool get isCapture => captured.isNotEmpty;

  /// The square the piece lands on at step [step].
  int landingAt(int step) => path[step];

  @override
  bool operator ==(Object other) =>
      other is Move &&
      other.from == from &&
      other.path.length == path.length &&
      other.captured.length == captured.length &&
      _sameOrder(other.path, path) &&
      _sameOrder(other.captured, captured);

  @override
  int get hashCode => Object.hash(
        from,
        Object.hashAll(path),
        Object.hashAll(captured),
      );

  @override
  String toString() => "$from -> ${path.join('-')} x${captured.join(',')}";

  static bool _sameOrder(List<int> first, List<int> second) {
    for (var i = 0; i < first.length; i++) {
      if (first[i] != second[i]) {
        return false;
      }
    }
    return true;
  }
}
