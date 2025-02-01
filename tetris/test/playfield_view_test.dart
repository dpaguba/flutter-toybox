import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/models/piece.dart';
import 'package:tetris/models/playfield.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/widgets/well_cell.dart';
import 'package:tetris/widgets/playfield_view.dart';

WellCell cellAt(WidgetTester tester, int x, int y) {
  return tester.widget<WellCell>(find.byKey(ValueKey("cell-$x-$y")));
}

Future<void> pumpField(
  WidgetTester tester, {
  required Playfield field,
  Piece? current,
  Piece? ghost,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 400,
            child: PlayfieldView(field: field, current: current, ghost: ghost),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('well draws two hundred cells', (tester) async {
    await pumpField(tester, field: Playfield());
    expect(find.byType(WellCell), findsNWidgets(200));
    expect(cellAt(tester, 0, 0).type, isNull);
    expect(cellAt(tester, 9, 19).type, isNull);
  });

  testWidgets('a settled cell shows its own color', (tester) async {
    final field = Playfield();
    field.setAt(2, 15, TetrominoType.l);
    await pumpField(tester, field: field);
    expect(cellAt(tester, 2, 15).type, TetrominoType.l);
    expect(cellAt(tester, 2, 15).ghost, isFalse);
    expect(cellAt(tester, 3, 15).type, isNull);
  });

  testWidgets('a falling piece is drawn on top of the field', (tester) async {
    await pumpField(
      tester,
      field: Playfield(),
      current: const Piece(type: TetrominoType.o, rotation: 0, x: 4, y: 0),
    );
    expect(cellAt(tester, 4, 0).type, TetrominoType.o);
    expect(cellAt(tester, 5, 1).type, TetrominoType.o);
    expect(cellAt(tester, 6, 1).type, isNull);
  });

  testWidgets('the drop shadow is shown as an outline, the piece as a fill',
      (tester) async {
    const current = Piece(type: TetrominoType.i, rotation: 0, x: 3, y: 0);
    await pumpField(
      tester,
      field: Playfield(),
      current: current,
      ghost: const Piece(type: TetrominoType.i, rotation: 0, x: 3, y: 18),
    );
    expect(cellAt(tester, 3, 19).type, TetrominoType.i);
    expect(cellAt(tester, 3, 19).ghost, isTrue);
    expect(cellAt(tester, 3, 1).type, TetrominoType.i);
    expect(cellAt(tester, 3, 1).ghost, isFalse);
  });

  testWidgets('the piece overlaps the shadow when they coincide', (tester) async {
    const piece = Piece(type: TetrominoType.o, rotation: 0, x: 4, y: 18);
    await pumpField(
      tester,
      field: Playfield(),
      current: piece,
      ghost: piece,
    );
    expect(cellAt(tester, 4, 18).ghost, isFalse);
    expect(cellAt(tester, 4, 18).type, TetrominoType.o);
  });

  testWidgets('cells of a piece above the field are not drawn', (tester) async {
    await pumpField(
      tester,
      field: Playfield(),
      current: const Piece(type: TetrominoType.o, rotation: 0, x: 4, y: -2),
    );
    expect(find.byType(WellCell), findsNWidgets(200));
    expect(cellAt(tester, 4, 0).type, isNull);
  });
}
