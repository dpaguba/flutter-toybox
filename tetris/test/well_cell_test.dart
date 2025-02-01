import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/theme/chassis.dart';
import 'package:tetris/utils/constants.dart';
import 'package:tetris/widgets/well_cell.dart';

BoxDecoration decorationOf(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(WellCell),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as BoxDecoration;
}

Future<void> pumpCell(
  WidgetTester tester,
  WellCell cell, {
  Brightness brightness = Brightness.dark,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 20, height: 20, child: cell),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('an empty cell is nothing but the floor outline', (tester) async {
    await pumpCell(tester, const WellCell());
    final decoration = decorationOf(tester);
    expect(decoration.color, Colors.transparent);
    expect(decoration.boxShadow, isNull);
    expect(decoration.border!.top.color, Chassis.night.grid);
  });

  testWidgets('a filled cell is flat paint without a glow',
      (tester) async {
    await pumpCell(tester, const WellCell(type: TetrominoType.t));
    final decoration = decorationOf(tester);
    expect(decoration.color, colorOf(TetrominoType.t));
    expect(decoration.boxShadow, isNull);
    expect(decoration.gradient, isNull);
  });

  testWidgets('a filled cell has a light top and a dark bottom',
      (tester) async {
    await pumpCell(tester, const WellCell(type: TetrominoType.o));
    final border = decorationOf(tester).border! as Border;
    expect(border.top.color.computeLuminance(),
        greaterThan(border.bottom.color.computeLuminance()));
  });

  testWidgets('the drop shadow is an outline in its piece own color', (tester) async {
    await pumpCell(tester, const WellCell(type: TetrominoType.s, ghost: true));
    final decoration = decorationOf(tester);
    expect(decoration.color!.opacity, lessThan(0.1));
    expect(decoration.boxShadow, isNull);
    expect(
      decoration.border!.top.color.value & 0x00FFFFFF,
      colorOf(TetrominoType.s).value & 0x00FFFFFF,
    );
  });

  testWidgets('the floor outline changes together with the theme', (tester) async {
    await pumpCell(tester, const WellCell(), brightness: Brightness.light);
    expect(decorationOf(tester).border!.top.color, Chassis.day.grid);
    expect(Chassis.day.grid, isNot(Chassis.night.grid));
  });

  testWidgets('each of the seven pieces has its own color', (tester) async {
    final colors = TetrominoType.values.map(colorOf).toSet();
    expect(colors.length, 7);
  });
}
