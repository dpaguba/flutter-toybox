import 'package:checkers/utils/sheet.dart';
import 'package:checkers/widgets/slab_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The button in the page's theme.
Widget button({required bool filled, VoidCallback? onTap}) => MaterialApp(
      theme: pressTheme(Brightness.light),
      home: Scaffold(
        body: SlabButton(
          label: "PLAY",
          filled: filled,
          onTap: onTap ?? () {},
        ),
      ),
    );

/// The color the button's slab is filled with.
Color? faceOf(WidgetTester tester) {
  final Container slab = tester.widget<Container>(
    find.descendant(
      of: find.byType(SlabButton),
      matching: find.byType(Container),
    ),
  );
  return (slab.decoration! as BoxDecoration).color;
}

void main() {
  testWidgets('shows the label', (tester) async {
    await tester.pumpWidget(button(filled: true));

    expect(find.text("PLAY"), findsOneWidget);
  });

  testWidgets('a tap calls the callback exactly once', (tester) async {
    var taps = 0;
    await tester.pumpWidget(button(filled: true, onTap: () => taps++));

    await tester.tap(find.byType(SlabButton));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('a filled slab prints the word in paper, an empty one in ink',
      (tester) async {
    await tester.pumpWidget(button(filled: true));
    expect(faceOf(tester), Sheet.impression.mark);
    expect(
      tester.widget<Text>(find.text("PLAY")).style!.color,
      Sheet.impression.ground,
    );

    await tester.pumpWidget(button(filled: false));
    expect(faceOf(tester), Sheet.impression.ground);
    expect(
      tester.widget<Text>(find.text("PLAY")).style!.color,
      Sheet.impression.mark,
    );
  });

  testWidgets('the button is never shorter than a finger', (tester) async {
    await tester.pumpWidget(button(filled: true));

    expect(
      tester.getSize(find.byType(SlabButton)).height,
      greaterThanOrEqualTo(touchFloor),
    );
  });
}
