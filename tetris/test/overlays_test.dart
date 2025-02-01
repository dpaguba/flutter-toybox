import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/widgets/game_over_panel.dart';
import 'package:tetris/widgets/pause_overlay.dart';
import 'package:tetris/widgets/segment_readout.dart';

String readout(WidgetTester tester, String name) {
  return tester
      .widget<SegmentReadout>(find.byKey(ValueKey("over-$name")))
      .value;
}

Future<void> pumpOver(
  WidgetTester tester, {
  required bool isRecord,
  int score = 4200,
  int lines = 17,
  int level = 2,
  VoidCallback? onRestart,
  VoidCallback? onQuit,
}) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: GameOverPanel(
        score: score,
        lines: lines,
        level: level,
        isRecord: isRecord,
        onRestart: onRestart ?? () {},
        onQuit: onQuit ?? () {},
      ),
    ),
  ));
}

void main() {
  testWidgets('the pause overlay has resume and quit actions', (tester) async {
    int resumed = 0;
    int quit = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PauseOverlay(
          onResume: () => resumed++,
          onQuit: () => quit++,
        ),
      ),
    ));

    expect(find.text("PAUSED"), findsOneWidget);
    await tester.tap(find.text("RESUME"));
    await tester.pump();
    expect(resumed, 1);

    await tester.tap(find.text("QUIT"));
    await tester.pump();
    expect(quit, 1);
  });

  testWidgets('game over shows the score, lines, and level', (tester) async {
    await pumpOver(tester, isRecord: false);

    expect(find.text("GAME OVER"), findsOneWidget);
    expect(readout(tester, "score"), "4200");
    expect(readout(tester, "lines"), "17");
    expect(readout(tester, "level"), "2");
    expect(find.text("NEW RECORD"), findsNothing);
  });

  testWidgets('the score stands apart from lines and level', (tester) async {
    await pumpOver(tester, isRecord: false);
    final double score =
        tester.getSize(find.byKey(const ValueKey("over-score"))).height;
    final double lines =
        tester.getSize(find.byKey(const ValueKey("over-lines"))).height;
    expect(score, greaterThan(lines * 1.4));
  });

  testWidgets('a new high score is marked separately', (tester) async {
    await pumpOver(tester, isRecord: true, score: 9000, lines: 30, level: 4);
    expect(find.text("NEW RECORD"), findsOneWidget);
  });

  testWidgets('the game-over keys trigger their actions', (tester) async {
    int restarted = 0;
    int quit = 0;
    await pumpOver(
      tester,
      isRecord: false,
      score: 100,
      lines: 1,
      level: 1,
      onRestart: () => restarted++,
      onQuit: () => quit++,
    );

    await tester.tap(find.text("PLAY AGAIN"));
    await tester.pump();
    expect(restarted, 1);

    await tester.tap(find.text("QUIT"));
    await tester.pump();
    expect(quit, 1);
  });
}
