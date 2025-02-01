import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/widgets/pattern_bank.dart';
import 'package:tetris/widgets/well_cell.dart';

Future<void> pumpBank(WidgetTester tester, PatternBank bank) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 80, child: bank)),
      ),
    ),
  );
}

int filledCells(WidgetTester tester) {
  return tester
      .widgetList<WellCell>(find.byType(WellCell))
      .where((cell) => cell.type != null)
      .length;
}

void main() {
  testWidgets('an empty window shows its label and no cells',
      (tester) async {
    await pumpBank(tester, const PatternBank(label: "HOLD"));
    expect(find.text("HOLD"), findsOneWidget);
    expect(filledCells(tester), 0);
  });

  testWidgets('a window with a piece shows exactly four cells',
      (tester) async {
    for (final type in TetrominoType.values) {
      await pumpBank(tester, PatternBank(label: "NEXT", type: type));
      expect(filledCells(tester), 4, reason: "$type");
    }
  });

  testWidgets('a window with no label draws no empty row', (tester) async {
    await pumpBank(tester, const PatternBank(type: TetrominoType.i));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('an unavailable window is dimmed', (tester) async {
    await pumpBank(
      tester,
      const PatternBank(label: "HOLD", type: TetrominoType.z, dimmed: true),
    );
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(PatternBank),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(0.5));
  });
}
