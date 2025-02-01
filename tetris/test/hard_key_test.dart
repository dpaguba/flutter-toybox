import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/widgets/hard_key.dart';
import 'package:tetris/widgets/key_glyph.dart';

Future<void> pumpKey(WidgetTester tester, HardKey key) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: key))),
  );
}

EdgeInsets paddingOf(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(HardKey),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return container.padding! as EdgeInsets;
}

void main() {
  testWidgets('the key shows its label', (tester) async {
    await pumpKey(tester, HardKey(label: "START", onPressed: () {}));
    expect(find.text("START"), findsOneWidget);
  });

  testWidgets('a tap fires exactly once', (tester) async {
    int taps = 0;
    await pumpKey(tester, HardKey(label: "DROP", onPressed: () => taps++));
    await tester.tap(find.byType(HardKey));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('a pressed key sits down onto its base', (tester) async {
    await pumpKey(
      tester,
      HardKey(label: "DROP", mark: KeyMark.drop, onPressed: () {}),
    );
    expect(paddingOf(tester).top, 0);
    expect(paddingOf(tester).bottom, HardKey.travel);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HardKey)),
    );
    await tester.pump();
    expect(paddingOf(tester).top, HardKey.travel);
    expect(paddingOf(tester).bottom, 0);

    await gesture.up();
    await tester.pump();
    expect(paddingOf(tester).top, 0);
  });

  testWidgets('the key is no smaller than forty-four points', (tester) async {
    await pumpKey(tester, HardKey(mark: KeyMark.pause, compact: true,
        onPressed: () {}));
    final size = tester.getSize(find.byType(HardKey));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('holding repeats the action', (tester) async {
    int taps = 0;
    await pumpKey(
      tester,
      HardKey(label: "LEFT", repeating: true, onPressed: () => taps++),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HardKey)),
    );
    await tester.pump();
    expect(taps, 1);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(taps, greaterThan(3));

    await gesture.up();
    final int afterRelease = taps;
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(taps, afterRelease);
  });

  testWidgets('without repeating, holding does not multiply the action', (tester) async {
    int taps = 0;
    await pumpKey(tester, HardKey(label: "HOLD", onPressed: () => taps++));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HardKey)),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 900));
    await gesture.up();
    await tester.pump();
    expect(taps, 1);
  });
}
