import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/widgets/pixel_board.dart';
import 'package:tic_tac_toe/widgets/pixel_mark.dart';

void main() {
  testWidgets('the mark grows in rather than appearing instantly', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PixelBoard(
          cells: const ["X", "", "", "", "", "", "", "", ""],
          onTap: (_) {},
        ),
      ),
    ));
    await tester.pump();
    final ScaleTransition transition = tester.widget(
      find.ancestor(
        of: find.byType(PixelMark),
        matching: find.byType(ScaleTransition),
      ),
    );
    expect(transition.scale.value, lessThan(1.0));
    await tester.pumpAndSettle();
    expect(transition.scale.value, 1.0);
  });

  testWidgets('tapping an empty cell leaves the widget alive',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PixelBoard(cells: List.filled(9, ""), onTap: (_) {}),
      ),
    ));
    await tester.tap(find.byKey(const ValueKey('cell-0')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
