import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/match.dart';
import 'package:tic_tac_toe/models/player.dart';

Match freshMatch() => Match(
      left: const Player(name: "ANNA", mark: "X"),
      right: const Player(name: "BORYS", mark: "O"),
    );

void main() {
  test('a new series starts at zero and with X', () {
    final match = freshMatch();
    expect(match.leftScore, 0);
    expect(match.rightScore, 0);
    expect(match.round, 1);
    expect(match.startingMark, "X");
    expect(match.isOver, isFalse);
  });

  test('a win adds a point and a history entry', () {
    final match = freshMatch();
    match.recordRound("X", 5);
    expect(match.leftScore, 1);
    expect(match.rightScore, 0);
    expect(match.history.length, 1);
    expect(match.history.first.moves, 5);
    expect(match.round, 2);
  });

  test('the next round is started by whoever lost', () {
    final match = freshMatch();
    match.recordRound("X", 5);
    expect(match.startingMark, "O");
  });

  test('after a draw the turn passes to the other side', () {
    final match = freshMatch();
    match.recordRound(null, 9);
    expect(match.startingMark, "O");
    expect(match.leftScore, 0);
    expect(match.rightScore, 0);
  });

  test('the series ends on the third win', () {
    final match = freshMatch();
    match.recordRound("X", 5);
    match.recordRound("X", 6);
    expect(match.isOver, isFalse);
    match.recordRound("X", 7);
    expect(match.isOver, isTrue);
    expect(match.champion!.name, "ANNA");
  });

  test('there is no champion while the series is still in progress', () {
    final match = freshMatch();
    match.recordRound("O", 5);
    expect(match.champion, isNull);
    expect(match.rightScore, 1);
  });
}
