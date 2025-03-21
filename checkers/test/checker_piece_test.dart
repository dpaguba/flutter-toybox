import 'package:checkers/models/piece.dart';
import 'package:checkers/utils/sheet.dart';
import 'package:checkers/widgets/checker_piece.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The disc of a given piece, in the page's theme.
Widget disc(Piece piece,
        {bool spent = false, Brightness look = Brightness.light}) =>
    MaterialApp(
      theme: pressTheme(look),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CheckerPiece(piece: piece, spent: spent),
          ),
        ),
      ),
    );

/// The disc's drawing, as the canvas sees it.
CustomPainter painterOf(WidgetTester tester) => tester
    .widget<CustomPaint>(
      find.descendant(
        of: find.byType(CheckerPiece),
        matching: find.byType(CustomPaint),
      ),
    )
    .painter!;

void main() {
  testWidgets('a man and a king are drawn differently', (tester) async {
    await tester.pumpWidget(disc(darkMan));
    final CustomPainter man = painterOf(tester);

    await tester.pumpWidget(disc(darkKing));

    expect(painterOf(tester).shouldRepaint(man), isTrue);
  });

  testWidgets('light and dark pieces are drawn differently', (tester) async {
    await tester.pumpWidget(disc(lightMan));
    final CustomPainter light = painterOf(tester);

    await tester.pumpWidget(disc(darkMan));

    expect(painterOf(tester).shouldRepaint(light), isTrue);
  });

  testWidgets('a captured piece is drawn in muted ink', (tester) async {
    await tester.pumpWidget(disc(darkMan));
    final CustomPainter whole = painterOf(tester);

    await tester.pumpWidget(disc(darkMan, spent: true));

    expect(painterOf(tester).shouldRepaint(whole), isTrue);
  });

  testWidgets('on the printing plate the disc takes the ink of that same sheet',
      (tester) async {
    await tester.pumpWidget(disc(darkMan));
    final CustomPainter onPaper = painterOf(tester);

    await tester.pumpWidget(disc(darkMan, look: Brightness.dark));
    await tester.pumpAndSettle();

    expect(painterOf(tester).shouldRepaint(onPaper), isTrue);
  });
}
