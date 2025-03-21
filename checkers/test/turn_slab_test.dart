import 'package:checkers/utils/sheet.dart';
import 'package:checkers/widgets/turn_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The slab in the page's theme.
Widget slab({
  required bool active,
  bool compulsory = false,
  bool inverted = false,
  String claim = "TO MOVE",
}) =>
    MaterialApp(
      theme: pressTheme(Brightness.light),
      home: Scaffold(
        body: TurnSlab(
          name: "ANNA",
          claim: claim,
          took: 3,
          active: active,
          compulsory: compulsory,
          inverted: inverted,
        ),
      ),
    );

/// The color the slab is filled with.
Color? groundOf(WidgetTester tester) => tester
    .widget<Container>(
      find.descendant(
        of: find.byType(TurnSlab),
        matching: find.byType(Container),
      ),
    )
    .color;

/// How many times over its normal size the slab is currently stamped.
double scaleOf(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(TurnSlab),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .getMaxScaleOnAxis();

/// The size the name is set at.
double sizeOfName(WidgetTester tester) =>
    tester.widget<Text>(find.text("ANNA")).style!.fontSize!;

void main() {
  testWidgets('the slab shows the name and how many the player has taken', (tester) async {
    await tester.pumpWidget(slab(active: false));

    expect(find.text("ANNA"), findsOneWidget);
    expect(find.text("TOOK 3"), findsOneWidget);
  });

  testWidgets('only the slab of whoever\'s turn it is prints the rules\' claim',
      (tester) async {
    await tester.pumpWidget(slab(active: false));
    expect(find.text("TO MOVE"), findsNothing);

    await tester.pumpWidget(slab(active: true));
    expect(find.text("TO MOVE"), findsOneWidget);
  });

  testWidgets('the slab of whoever\'s turn it is is filled with vermilion and set larger',
      (tester) async {
    await tester.pumpWidget(slab(active: false));
    final Color? quietGround = groundOf(tester);
    final double quietName = sizeOfName(tester);

    await tester.pumpWidget(slab(active: true));

    expect(groundOf(tester), Sheet.impression.accent);
    expect(quietGround, Sheet.impression.ground);
    expect(sizeOfName(tester), greaterThan(quietName));
  });

  testWidgets('an inverted slab stands rotated half a turn', (tester) async {
    await tester.pumpWidget(slab(active: true, inverted: true));

    final RotatedBox box = tester.widget<RotatedBox>(
      find.descendant(
        of: find.byType(TurnSlab),
        matching: find.byType(RotatedBox),
      ),
    );
    expect(box.quarterTurns, 2);
  });

  testWidgets('the capture requirement prints with a stamp and settles back to its own size',
      (tester) async {
    await tester.pumpWidget(slab(active: true));
    expect(scaleOf(tester), 1);

    await tester.pumpWidget(
      slab(active: true, compulsory: true, claim: "MUST TAKE 2"),
    );
    await tester.pump(const Duration(milliseconds: 1));
    expect(scaleOf(tester), greaterThan(1));

    await tester.pump(stampDuration);
    expect(scaleOf(tester), closeTo(1, 0.001));
  });

  testWidgets('an ordinary turn does not get the stamp', (tester) async {
    await tester.pumpWidget(slab(active: true));
    await tester.pumpWidget(slab(active: true, claim: "TO MOVE AGAIN"));
    await tester.pump(const Duration(milliseconds: 1));

    expect(scaleOf(tester), 1);
  });
}
