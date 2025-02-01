import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/theme/chassis.dart';
import 'package:tetris/widgets/hard_key.dart';
import 'package:tetris/widgets/key_deck.dart';

Future<void> pumpDeck(
  WidgetTester tester, {
  List<String>? pressed,
  bool canHold = true,
}) {
  void note(String name) => pressed?.add(name);
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: KeyDeck(
          canHold: canHold,
          onLeft: () => note("left"),
          onRight: () => note("right"),
          onRotate: () => note("rotate"),
          onSoftDrop: () => note("down"),
          onHardDrop: () => note("drop"),
          onHold: () => note("hold"),
        ),
      ),
    ),
  ));
}

Rect keyRect(WidgetTester tester, String name) =>
    tester.getRect(find.byKey(ValueKey("control-$name")));

void main() {
  testWidgets('each key triggers its own action', (tester) async {
    final List<String> pressed = [];
    await pumpDeck(tester, pressed: pressed);

    for (final name in ["left", "right", "rotate", "down", "drop", "hold"]) {
      await tester.tap(find.byKey(ValueKey("control-$name")));
      await tester.pump();
    }

    expect(pressed, ["left", "right", "rotate", "down", "drop", "hold"]);
  });

  testWidgets('all six keys are labeled', (tester) async {
    await pumpDeck(tester);
    for (final label in ["LEFT", "TURN", "RIGHT", "HOLD", "DOWN", "DROP"]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('the drop key is wider than the movement keys and set apart from them', (tester) async {
    await pumpDeck(tester);
    final Rect drop = keyRect(tester, "drop");
    final Rect down = keyRect(tester, "down");
    final Rect hold = keyRect(tester, "hold");

    expect(drop.width, greaterThan(down.width));
    expect(drop.width, greaterThan(keyRect(tester, "left").width));
    expect(drop.left - down.right, greaterThan(down.left - hold.right));
  });

  testWidgets('keys are no smaller than forty-four points', (tester) async {
    await pumpDeck(tester);
    for (final name in ["left", "right", "rotate", "down", "drop", "hold"]) {
      final Rect rect = keyRect(tester, name);
      expect(rect.width, greaterThanOrEqualTo(44), reason: name);
      expect(rect.height, greaterThanOrEqualTo(44), reason: name);
    }
  });

  testWidgets('the hold key is colored only while it is available', (tester) async {
    await pumpDeck(tester);
    HardKey hold() =>
        tester.widget<HardKey>(find.byKey(const ValueKey("control-hold")));
    expect(hold().cap, Chassis.holdCap);

    await pumpDeck(tester, canHold: false);
    expect(hold().cap, isNull);
  });

  testWidgets('movement keys can auto-repeat, the drop key cannot', (tester) async {
    await pumpDeck(tester);
    HardKey key(String name) =>
        tester.widget<HardKey>(find.byKey(ValueKey("control-$name")));
    for (final name in ["left", "right", "down"]) {
      expect(key(name).repeating, isTrue, reason: name);
      expect(key(name).cap, isNull, reason: name);
    }
    expect(key("drop").repeating, isFalse);
    expect(key("drop").cap, Chassis.dropCap);
    expect(key("rotate").repeating, isFalse);
  });
}
