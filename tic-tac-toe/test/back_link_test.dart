import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/widgets/back_link.dart';

void main() {
  testWidgets('shows the text "< MAIN MENU"', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BackLink(onTap: () {}),
      ),
    ));

    expect(find.text("< MAIN MENU"), findsOneWidget);
  });

  testWidgets('a tap calls the callback exactly once', (tester) async {
    int taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BackLink(onTap: () => taps++),
      ),
    ));

    await tester.tap(find.byType(BackLink));
    await tester.pump();

    expect(taps, 1);
  });
}
