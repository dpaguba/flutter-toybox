import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/widgets/pixel_button.dart';

void main() {
  testWidgets('shows the label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PixelButton(label: "PLAY GAME", onTap: () {}),
      ),
    ));

    expect(find.text("PLAY GAME"), findsOneWidget);
  });

  testWidgets('a tap calls the callback exactly once', (tester) async {
    int taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PixelButton(label: "START", onTap: () => taps++),
      ),
    ));

    await tester.tap(find.byType(PixelButton));
    await tester.pump();

    expect(taps, 1);
  });
}
