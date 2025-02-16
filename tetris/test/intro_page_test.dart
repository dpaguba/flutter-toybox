import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/main.dart';
import 'package:tetris/pages/intro.dart';
import 'package:tetris/theme/chassis.dart';
import 'package:tetris/widgets/hard_key.dart';
import 'package:tetris/widgets/playfield_view.dart';
import 'package:tetris/widgets/segment_readout.dart';
import 'package:tetris/widgets/tempo_strip.dart';

Future<void> pumpIntro(WidgetTester tester, Map<String, Object> saved) async {
  SharedPreferences.setMockInitialValues(saved);
  await tester.pumpWidget(const MaterialApp(home: IntroPage()));
  await tester.pump();
}

void main() {
  testWidgets('the intro screen shows the badge, the high score, and the start key', (tester) async {
    await pumpIntro(tester, {});
    expect(find.byKey(const ValueKey("intro-title")), findsOneWidget);
    expect(find.text("BEST"), findsOneWidget);
    expect(find.text("START"), findsOneWidget);
  });

  testWidgets('with no games played the high score is zero', (tester) async {
    await pumpIntro(tester, {});
    expect(
      tester.widget<SegmentReadout>(find.byType(SegmentReadout)).value,
      "0",
    );
  });

  testWidgets('a saved high score is visible on the intro screen', (tester) async {
    await pumpIntro(tester, {"tetris_high_score": 7400});
    expect(
      tester.widget<SegmentReadout>(find.byType(SegmentReadout)).value,
      "7400",
    );
  });

  testWidgets('the START key opens the well', (tester) async {
    await pumpIntro(tester, {});
    await tester.tap(find.byKey(const ValueKey("intro-start")));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PlayfieldView), findsOneWidget);
    expect(find.text("SCORE"), findsOneWidget);
  });

  testWidgets('the intro screen has no tempo strip', (tester) async {
    await pumpIntro(tester, {});
    expect(find.byType(TempoStrip), findsNothing);
    expect(find.text("TEMPO"), findsNothing);
  });

  testWidgets('the start key is painted in the machine color', (tester) async {
    await pumpIntro(tester, {});
    final HardKey start = tester.widget<HardKey>(
      find.byKey(const ValueKey("intro-start")),
    );
    expect(start.cap, Chassis.startCap);
    expect(start.cap, isNot(Chassis.dropCap));
    expect(start.cap, isNot(Chassis.holdCap));
  });

  testWidgets('the badge is set in the brand typeface', (tester) async {
    await pumpIntro(tester, {});
    final Text title = tester.widget<Text>(
      find.byKey(const ValueKey("intro-title")),
    );
    expect(title.style?.fontFamily, "Michroma");
  });

  testWidgets('the app opens on the intro screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TetrisApp());
    await tester.pump();
    expect(find.byType(IntroPage), findsOneWidget);
  });
}
