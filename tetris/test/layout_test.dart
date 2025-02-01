import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/logic/game_engine.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/pages/game.dart';
import 'package:tetris/pages/intro.dart';

import 'fixed_source.dart';

/// Screen sizes on which the game must fit without clipped edges.
///
/// The first height is what remains on a phone with a notch after the status and
/// gesture bars, so it is smaller than the full screen.
const List<Size> screens = [
  Size(390, 763),
  Size(390, 844),
  Size(375, 667),
];

/// Finishes in which the device is seen: night and day.
const List<Brightness> finishes = [Brightness.dark, Brightness.light];

Widget shell(Widget page, Brightness brightness, double textScale) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness, useMaterial3: true),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: textScale),
      child: child!,
    ),
    home: page,
  );
}

void main() {
  testWidgets('the intro screen fits within the phone window', (tester) async {
    SharedPreferences.setMockInitialValues({"tetris_high_score": 123456});
    for (final size in screens) {
      for (final finish in finishes) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(shell(const IntroPage(), finish, 1));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: "$size $finish");
      }
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('the game screen fits within the phone window', (tester) async {
    SharedPreferences.setMockInitialValues({});
    for (final size in screens) {
      for (final finish in finishes) {
        await tester.binding.setSurfaceSize(size);
        final engine = GameEngine(source: FixedSource(TetrominoType.values));
        await tester.pumpWidget(shell(GamePage(engine: engine), finish, 1));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: "$size $finish");

        await tester.tap(find.byKey(const ValueKey("control-pause")));
        await tester.pump();
        expect(find.text("PAUSED"), findsOneWidget);
        expect(tester.takeException(), isNull, reason: "pause at $size");
      }
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('a large text size does not clip anything', (tester) async {
    SharedPreferences.setMockInitialValues({"tetris_high_score": 987654});
    for (final scale in [1.5, 2.0, 3.0]) {
      for (final size in screens) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(shell(const IntroPage(), Brightness.dark,
            scale));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: "intro $size $scale");

        final engine = GameEngine(source: FixedSource(TetrominoType.values));
        await tester.pumpWidget(
          shell(GamePage(engine: engine), Brightness.light, scale),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: "game $size $scale");
      }
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('the game over screen fits within the phone window', (tester) async {
    SharedPreferences.setMockInitialValues({});
    for (final size in screens) {
      await tester.binding.setSurfaceSize(size);
      final engine = GameEngine(source: FixedSource([TetrominoType.o]));
      await tester.pumpWidget(shell(GamePage(engine: engine),
          Brightness.dark, 1.5));
      for (var drop = 0; drop < 14; drop++) {
        if (find.text("GAME OVER").evaluate().isNotEmpty) {
          break;
        }
        await tester.tap(find.byKey(const ValueKey("control-drop")));
        await tester.pump();
      }
      expect(find.text("GAME OVER"), findsOneWidget, reason: "$size");
      expect(tester.takeException(), isNull, reason: "$size");
    }
    await tester.binding.setSurfaceSize(null);
  });
}
