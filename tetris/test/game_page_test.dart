import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/logic/game_engine.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/pages/game.dart';
import 'package:tetris/widgets/well_cell.dart';
import 'package:tetris/widgets/pattern_bank.dart';
import 'package:tetris/widgets/playfield_view.dart';
import 'package:tetris/widgets/segment_readout.dart';
import 'package:tetris/widgets/tempo_strip.dart';

import 'fixed_source.dart';

/// Coordinates of the field cells currently painted with fill or outline.
List<List<int>> drawnCells(WidgetTester tester, {required bool ghost}) {
  final List<List<int>> found = [];
  for (final element in find.byType(WellCell).evaluate()) {
    final cell = element.widget as WellCell;
    final key = cell.key;
    if (cell.type == null || cell.ghost != ghost || key is! ValueKey<String>) {
      continue;
    }
    final parts = key.value.split("-");
    found.add([int.parse(parts[1]), int.parse(parts[2])]);
  }
  found.sort((a, b) => a[1] == b[1] ? a[0] - b[0] : a[1] - b[1]);
  return found;
}

Future<GameEngine> pumpGame(
  WidgetTester tester,
  List<TetrominoType> order,
) async {
  SharedPreferences.setMockInitialValues({});
  final engine = GameEngine(source: FixedSource(order));
  await tester.pumpWidget(MaterialApp(home: GamePage(engine: engine)));
  return engine;
}

/// The value of a counter from the screen header.
String statValue(WidgetTester tester, String name) {
  return tester
      .widget<SegmentReadout>(find.byKey(ValueKey("stat-$name")))
      .value;
}

/// Drops pieces until the game ends.
Future<void> dropUntilGameOver(WidgetTester tester) async {
  for (var drop = 0; drop < 14; drop++) {
    if (find.text("GAME OVER").evaluate().isNotEmpty) {
      return;
    }
    await press(tester, "drop");
  }
}

Future<void> press(WidgetTester tester, String control) async {
  await tester.tap(find.byKey(ValueKey("control-$control")));
  await tester.pump();
}

void main() {
  testWidgets('the game screen shows the field, preview, and counters', (tester) async {
    await pumpGame(tester, [TetrominoType.t, TetrominoType.i]);

    expect(find.byType(PlayfieldView), findsOneWidget);
    expect(find.byKey(const ValueKey("cell-0-0")), findsOneWidget);
    expect(find.byKey(const ValueKey("cell-9-19")), findsOneWidget);
    expect(find.text("SCORE"), findsOneWidget);
    expect(find.text("LEVEL"), findsOneWidget);
    expect(find.text("LINES"), findsOneWidget);
    expect(find.text("HOLD"), findsNWidgets(2));
    expect(find.text("NEXT"), findsOneWidget);
    expect(find.byType(PatternBank), findsNWidgets(4));
    expect(find.byType(TempoStrip), findsOneWidget);
  });

  testWidgets('the left and right buttons move the piece', (tester) async {
    await pumpGame(tester, [TetrominoType.t]);
    final before = drawnCells(tester, ghost: false);

    await press(tester, "left");
    final left = drawnCells(tester, ghost: false);
    expect(left.length, before.length);
    for (var i = 0; i < before.length; i++) {
      expect(left[i][0], before[i][0] - 1);
      expect(left[i][1], before[i][1]);
    }

    await press(tester, "right");
    expect(drawnCells(tester, ghost: false), before);
  });

  testWidgets("rotation changes the piece's outline", (tester) async {
    await pumpGame(tester, [TetrominoType.t]);
    final before = drawnCells(tester, ghost: false);
    await press(tester, "rotate");
    expect(drawnCells(tester, ghost: false), isNot(before));
  });

  testWidgets('the drop shadow sits on the floor below the piece', (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    final ghost = drawnCells(tester, ghost: true);
    expect(ghost.length, 4);
    expect(ghost.last[1], 19);
  });

  testWidgets('soft drop lowers the piece and adds a point', (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    final before = drawnCells(tester, ghost: false);
    await press(tester, "down");
    final after = drawnCells(tester, ghost: false);
    for (var i = 0; i < before.length; i++) {
      expect(after[i][1], before[i][1] + 1);
    }
    expect(statValue(tester, "score"), "1");
  });

  testWidgets('hard drop places the piece on the floor', (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    await press(tester, "drop");
    final cells = drawnCells(tester, ghost: false);
    expect(cells.where((cell) => cell[1] == 19).length, 2);
    expect(cells.where((cell) => cell[1] == 0).length, 2);
  });

  testWidgets('gravity lowers the piece by itself', (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    final before = drawnCells(tester, ghost: false);
    await tester.pump(const Duration(milliseconds: 900));
    final after = drawnCells(tester, ghost: false);
    expect(after.first[1], greaterThan(before.first[1]));
  });

  testWidgets('pause stops the game, resume brings it back', (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    await press(tester, "pause");
    expect(find.text("PAUSED"), findsOneWidget);

    final before = drawnCells(tester, ghost: false);
    await tester.pump(const Duration(milliseconds: 2000));
    expect(drawnCells(tester, ghost: false), before);

    await tester.tap(find.text("RESUME"));
    await tester.pump();
    expect(find.text("PAUSED"), findsNothing);

    await tester.pump(const Duration(milliseconds: 900));
    expect(drawnCells(tester, ghost: false), isNot(before));
  });

  testWidgets('the held piece appears in the HOLD window', (tester) async {
    await pumpGame(tester, [TetrominoType.t, TetrominoType.i]);
    PatternBank hold() => tester.widget<PatternBank>(
          find.byKey(const ValueKey("preview-hold")),
        );
    expect(hold().type, isNull);

    await press(tester, "hold");
    expect(hold().type, TetrominoType.t);
    expect(hold().dimmed, isTrue);

    await press(tester, "hold");
    expect(hold().type, TetrominoType.t);
  });

  testWidgets('a filled row disappears and adds a hundred points', (tester) async {
    final engine = await pumpGame(tester, [TetrominoType.i]);
    for (var x = 0; x < 10; x++) {
      if (x < 3 || x > 6) {
        engine.field.setAt(x, 19, TetrominoType.z);
      }
    }
    await press(tester, "drop");

    expect(statValue(tester, "lines"), "1");
    expect(statValue(tester, "score"), "136");
    expect(drawnCells(tester, ghost: false).where((c) => c[1] == 19).isEmpty,
        isTrue);
  });

  testWidgets('when the top is filled, the game ends', (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    await dropUntilGameOver(tester);

    expect(find.text("GAME OVER"), findsOneWidget);
    expect(find.text("PLAY AGAIN"), findsOneWidget);
  });

  testWidgets('a new game starts with a clean field', (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    await dropUntilGameOver(tester);
    expect(find.text("GAME OVER"), findsOneWidget);

    await tester.tap(find.text("PLAY AGAIN"));
    await tester.pump();

    expect(find.text("GAME OVER"), findsNothing);
    expect(drawnCells(tester, ghost: false).length, 4);
  });

  testWidgets('a new record is noted on the game over screen',
      (tester) async {
    await pumpGame(tester, [TetrominoType.o]);
    await dropUntilGameOver(tester);
    await tester.pumpAndSettle();

    expect(find.text("NEW RECORD"), findsOneWidget);
  });
}
