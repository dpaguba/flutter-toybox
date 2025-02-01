import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/widgets/tempo_strip.dart';

Future<void> pumpStrip(
  WidgetTester tester, {
  int stepMs = 100,
  bool running = true,
  int level = 1,
  bool stillness = false,
}) {
  return tester.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: stillness),
      child: child!,
    ),
    home: Scaffold(
      body: TempoStrip(stepMs: stepMs, running: running, level: level),
    ),
  ));
}

LampPainter painterOf(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(TempoStrip),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as LampPainter;
}

void main() {
  testWidgets('the strip is labeled and starts at the first lamp', (tester) async {
    await pumpStrip(tester);
    expect(find.text("TEMPO"), findsOneWidget);
    expect(painterOf(tester).lit, 0);
  });

  testWidgets('the lamp moves to the next one after one step of time',
      (tester) async {
    await pumpStrip(tester, stepMs: 100);
    final int start = painterOf(tester).lit!;
    await tester.pump(const Duration(milliseconds: 101));
    expect(painterOf(tester).lit, start + 1);
    await tester.pump(const Duration(milliseconds: 101));
    expect(painterOf(tester).lit, start + 2);
    await tester.pump(const Duration(milliseconds: 101));
    expect(painterOf(tester).lit, start + 3);
  });

  testWidgets('the lamp stays still while paused', (tester) async {
    await pumpStrip(tester, stepMs: 100, running: false);
    final int before = painterOf(tester).lit!;
    await tester.pump(const Duration(milliseconds: 500));
    expect(painterOf(tester).lit, before);
  });

  testWidgets('a higher level drives the lamp faster', (tester) async {
    await pumpStrip(tester, stepMs: 400);
    await tester.pump(const Duration(milliseconds: 200));
    final int slow = painterOf(tester).lit!;

    await pumpStrip(tester, stepMs: 100);
    await tester.pump(const Duration(milliseconds: 200));
    expect(painterOf(tester).lit, greaterThan(slow));
  });

  testWidgets('when motion is disabled, the strip shows the level as a number of lit lamps',
      (tester) async {
    await pumpStrip(tester, level: 4, stillness: true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(painterOf(tester).lit, isNull);
    expect(painterOf(tester).filled, 4);
  });
}
