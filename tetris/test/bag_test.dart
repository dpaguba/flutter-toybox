import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/logic/bag.dart';
import 'package:tetris/models/tetromino.dart';

void main() {
  test('the first seven pieces are seven distinct pieces', () {
    final bag = SevenBag(random: Random(1));
    final drawn = List.generate(7, (_) => bag.next());
    expect(drawn.toSet().length, 7);
    expect(drawn.toSet(), TetrominoType.values.toSet());
  });

  test('across two bags each piece appears exactly twice', () {
    final bag = SevenBag(random: Random(7));
    final drawn = List.generate(14, (_) => bag.next());
    for (final type in TetrominoType.values) {
      expect(drawn.where((item) => item == type).length, 2, reason: "$type");
    }
  });

  test('different seeds give a different order', () {
    final first = List.generate(7, (_) => SevenBag(random: Random(1)).next());
    final firstBag = SevenBag(random: Random(1));
    final secondBag = SevenBag(random: Random(99));
    final a = List.generate(7, (_) => firstBag.next());
    final b = List.generate(7, (_) => secondBag.next());
    expect(first.length, 7);
    expect(a == b, isFalse);
  });

  test('the same bag with the same seed repeats itself', () {
    final a = SevenBag(random: Random(5));
    final b = SevenBag(random: Random(5));
    expect(
      List.generate(21, (_) => a.next()),
      List.generate(21, (_) => b.next()),
    );
  });

  test('the bag can see upcoming pieces without drawing them', () {
    final bag = SevenBag(random: Random(3));
    final peeked = bag.peek(3);
    expect(peeked.length, 3);
    expect(List.generate(3, (_) => bag.next()), peeked);
  });

  test('peeking can look further ahead than a single bag', () {
    final bag = SevenBag(random: Random(3));
    expect(bag.peek(10).length, 10);
  });
}
