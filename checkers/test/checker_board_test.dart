import 'package:checkers/models/board.dart';
import 'package:checkers/models/piece.dart';
import 'package:checkers/utils/sheet.dart';
import 'package:checkers/widgets/checker_board.dart';
import 'package:checkers/widgets/checker_piece.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The board's width in the tests, and the side of a single square.
const double boardWidth = 360;
const double squareSide = boardWidth / boardSize;

Widget wrap(Widget child) => MaterialApp(
      theme: pressTheme(Brightness.light),
      home: Scaffold(
        body: Center(child: SizedBox(width: boardWidth, child: child)),
      ),
    );

void main() {
  testWidgets('draws all one hundred squares', (tester) async {
    await tester.pumpWidget(
      wrap(CheckerBoard(board: Board.initial(), onTap: (_) {})),
    );

    expect(find.byKey(const ValueKey('square-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('square-99')), findsOneWidget);
  });

  testWidgets('pieces stand where they were placed', (tester) async {
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.withPieces({
            squareAt(5, 4): lightMan,
            squareAt(2, 3): darkKing,
          }),
          onTap: (_) {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('piece-54')), findsOneWidget);
    expect(find.byKey(const ValueKey('piece-23')), findsOneWidget);
    expect(find.byKey(const ValueKey('piece-55')), findsNothing);
  });

  testWidgets('a king is drawn with a ring, a man without', (tester) async {
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.withPieces({
            squareAt(5, 4): lightMan,
            squareAt(2, 3): darkKing,
          }),
          onTap: (_) {},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('disc-23-dark-true')), findsOneWidget);
    expect(find.byKey(const ValueKey('disc-54-light-false')), findsOneWidget);
  });

  testWidgets('allowed squares are marked with vermilion blocks',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.withPieces({squareAt(5, 4): lightMan}),
          onTap: (_) {},
          origin: squareAt(5, 4),
          destinations: {squareAt(4, 3), squareAt(4, 5)},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('spot-43')), findsOneWidget);
    expect(find.byKey(const ValueKey('spot-45')), findsOneWidget);
    expect(find.byKey(const ValueKey('spot-63')), findsNothing);
    expect(
      tester.widget<ColoredBox>(find.byKey(const ValueKey('spot-43'))).color,
      Sheet.impression.accent,
    );
  });

  testWidgets('a tap yields the square number', (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.initial(),
          onTap: taps.add,
          movable: {squareAt(6, 1)},
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('square-61')));
    await tester.pump();

    expect(taps, [61]);
  });

  testWidgets('a tap in the center of a non-playing square leads nowhere',
      (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.initial(),
          onTap: taps.add,
          movable: {squareAt(6, 1), squareAt(6, 3)},
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('square-55')));
    await tester.pump();

    expect(taps, isEmpty);
  });

  testWidgets('a tap near an allowed square snaps to it',
      (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.withPieces({squareAt(5, 4): lightMan}),
          onTap: taps.add,
          origin: squareAt(5, 4),
          destinations: {squareAt(4, 3)},
        ),
      ),
    );

    final Offset corner = tester.getTopLeft(
      find.byKey(const ValueKey('square-44')),
    );
    await tester.tapAt(corner + const Offset(squareSide * 0.1, squareSide / 2));
    await tester.pump();

    expect(taps, [43]);
  });

  testWidgets('a piece the rules do not allow yields itself',
      (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.initial(),
          onTap: taps.add,
          movable: {squareAt(6, 1)},
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('square-72')));
    await tester.pump();

    expect(taps, [72]);
  });

  testWidgets('a disabled board does not accept taps', (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.initial(),
          onTap: taps.add,
          movable: {squareAt(6, 1)},
          enabled: false,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('square-61')));
    await tester.pump();

    expect(taps, isEmpty);
  });

  testWidgets('a captured piece stays on the board, muted', (tester) async {
    await tester.pumpWidget(
      wrap(
        CheckerBoard(
          board: Board.withPieces({squareAt(4, 5): darkMan}),
          onTap: (_) {},
          doomed: {squareAt(4, 5)},
        ),
      ),
    );

    expect(find.byKey(const ValueKey('piece-45')), findsOneWidget);
    expect(
      tester
          .widget<CheckerPiece>(
              find.byKey(const ValueKey('disc-45-dark-false')))
          .spent,
      isTrue,
    );
  });
}
