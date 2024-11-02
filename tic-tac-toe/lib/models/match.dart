import 'player.dart';

/// The outcome of a single round.
class RoundResult {
  const RoundResult({required this.winnerMark, required this.moves});

  /// The winner's mark, or null for a draw.
  final String? winnerMark;

  /// How many moves the round took.
  final int moves;
}

/// A series played to three wins.
class Match {
  Match({required this.left, required this.right});

  static const int winsNeeded = 3;

  final Player left;
  final Player right;
  int leftScore = 0;
  int rightScore = 0;
  final List<RoundResult> history = [];

  /// The mark that starts the current round.
  ///
  /// The first round is started by X. After that, the loser of the previous
  /// round starts, and after a draw the turn simply passes to the other side.
  /// Without this rule, whoever moves first would keep the advantage in
  /// every round of the series.
  String startingMark = "X";

  int get round => history.length + 1;

  bool get isOver =>
      leftScore >= winsNeeded || rightScore >= winsNeeded;

  Player? get champion {
    if (leftScore >= winsNeeded) {
      return left;
    }
    if (rightScore >= winsNeeded) {
      return right;
    }
    return null;
  }

  void recordRound(String? winnerMark, int moves) {
    history.add(RoundResult(winnerMark: winnerMark, moves: moves));
    if (winnerMark == left.mark) {
      leftScore++;
      startingMark = right.mark;
    } else if (winnerMark == right.mark) {
      rightScore++;
      startingMark = left.mark;
    } else {
      startingMark = startingMark == left.mark ? right.mark : left.mark;
    }
  }
}
