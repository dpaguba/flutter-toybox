import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/widgets/pixel_board.dart';
import 'package:tic_tac_toe/widgets/pixel_mark.dart';

void main() {
  testWidgets('shows marks for non-empty cells', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PixelBoard(
          cells: const ["X", "", "O", "", "", "", "", "", "X"],
          onTap: (_) {},
        ),
      ),
    ));
    expect(find.byType(PixelMark), findsNWidgets(3));
  });

  testWidgets('tapping an empty cell reports its index', (tester) async {
    final List<int> tapped = [];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PixelBoard(
          cells: List.filled(9, ""),
          onTap: tapped.add,
        ),
      ),
    ));
    await tester.tap(find.byKey(const ValueKey('cell-4')));
    expect(tapped, [4]);
  });

  testWidgets('a board of nine cells', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PixelBoard(cells: List.filled(9, ""), onTap: (_) {}),
      ),
    ));
    for (var i = 0; i < 9; i++) {
      expect(find.byKey(ValueKey('cell-$i')), findsOneWidget);
    }
  });
}
