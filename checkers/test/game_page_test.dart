import 'package:checkers/models/board.dart';
import 'package:checkers/models/piece.dart';
import 'package:checkers/models/player.dart';
import 'package:checkers/pages/game.dart';
import 'package:checkers/pages/result.dart';
import 'package:checkers/utils/sheet.dart';
import 'package:checkers/widgets/checker_board.dart';
import 'package:checkers/widgets/turn_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A game between two humans, starting from a given position.
Widget humanGame(Board board) => MaterialApp(
      theme: pressTheme(Brightness.light),
      home: GamePage(
        light: const Player(name: "ANNA", side: Side.light),
        dark: const Player(name: "BORYS", side: Side.dark),
        startBoard: board,
      ),
    );

/// A game against the computer at a given difficulty.
Widget botGame(Board board, Difficulty level) => MaterialApp(
      theme: pressTheme(Brightness.light),
      home: GamePage(
        light: const Player(name: "ANNA", side: Side.light),
        dark: Player(
          name: botName,
          side: Side.dark,
          isBot: true,
          difficulty: level,
        ),
        startBoard: board,
      ),
    );

/// The slab of whoever's turn it currently is.
TurnSlab activeSlab(WidgetTester tester) => tester
    .widgetList<TurnSlab>(find.byType(TurnSlab))
    .firstWhere((slab) => slab.active);

/// The board, as it is currently printed.
CheckerBoard shownBoard(WidgetTester tester) =>
    tester.widget<CheckerBoard>(find.byType(CheckerBoard));

/// The name set on the result page as the winner.
String winnerOnResult(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('winner'))).data!;

/// Text inside the result page.
Finder onResult(String text) => find.descendant(
      of: find.byType(ResultPage),
      matching: find.text(text),
    );

void main() {
  testWidgets('tapping a piece highlights that piece\'s own legal moves',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(0, 1): darkMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-54')));
    await tester.pump();

    expect(find.byKey(const ValueKey('spot-43')), findsOneWidget);
    expect(find.byKey(const ValueKey('spot-45')), findsOneWidget);
    expect(find.byKey(const ValueKey('spot-63')), findsNothing);
    expect(find.byKey(const ValueKey('spot-65')), findsNothing);
  });

  testWidgets('the board marks every piece the rules allow to move',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(7, 8): lightMan,
          squareAt(0, 1): darkMan,
        }),
      ),
    );
    await tester.pump();

    expect(shownBoard(tester).movable, {squareAt(5, 4), squareAt(7, 8)});
  });

  testWidgets('when a capture exists, only the piece taking the maximum is allowed',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(4, 5): darkMan,
          squareAt(7, 8): lightMan,
        }),
      ),
    );
    await tester.pump();

    expect(activeSlab(tester).claim, "MUST TAKE 1");
    expect(find.text("MUST TAKE 1"), findsOneWidget);
    expect(shownBoard(tester).movable, {squareAt(5, 4)});
  });

  testWidgets('a piece with no capture is not selected and stays struck out',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(4, 5): darkMan,
          squareAt(7, 8): lightMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-78')));
    await tester.pump();
    expect(find.byKey(const ValueKey('spot-67')), findsNothing);
    expect(find.byKey(const ValueKey('spot-69')), findsNothing);
    expect(shownBoard(tester).barred, squareAt(7, 8));

    await tester.tap(find.byKey(const ValueKey('square-54')));
    await tester.pump();
    expect(find.byKey(const ValueKey('spot-36')), findsOneWidget);
    expect(shownBoard(tester).barred, isNull);
  });

  testWidgets('the requirement names how many pieces the longest capture takes',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(6, 3): lightMan,
          squareAt(5, 4): darkMan,
          squareAt(3, 4): darkMan,
        }),
      ),
    );
    await tester.pump();

    expect(activeSlab(tester).claim, "MUST TAKE 2");
    expect(activeSlab(tester).compulsory, isTrue);
  });

  testWidgets('an opponent\'s piece cannot be selected', (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(2, 3): darkMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-23')));
    await tester.pump();

    expect(find.byKey(const ValueKey('spot-32')), findsNothing);
    expect(find.byKey(const ValueKey('spot-34')), findsNothing);
    expect(shownBoard(tester).barred, isNull);
  });

  testWidgets(
    'a chain proceeds step by step: the captured piece stays on the board and the turn does not pass',
    (tester) async {
      await tester.pumpWidget(
        humanGame(
          Board.withPieces({
            squareAt(6, 3): lightMan,
            squareAt(5, 4): darkMan,
            squareAt(3, 4): darkMan,
            squareAt(8, 1): darkMan,
          }),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('square-63')));
      await tester.pump();
      expect(find.byKey(const ValueKey('spot-45')), findsOneWidget);
      expect(find.byKey(const ValueKey('spot-23')), findsNothing);
      expect(shownBoard(tester).victims, {squareAt(5, 4)});

      await tester.tap(find.byKey(const ValueKey('square-45')));
      await tester.pump();

      expect(activeSlab(tester).name, "ANNA");
      expect(find.byKey(const ValueKey('piece-45')), findsOneWidget);
      expect(find.byKey(const ValueKey('piece-63')), findsNothing);
      expect(find.byKey(const ValueKey('piece-54')), findsOneWidget);
      expect(shownBoard(tester).doomed, {squareAt(5, 4)});
      expect(find.byKey(const ValueKey('spot-23')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('square-23')));
      await tester.pump();

      expect(activeSlab(tester).name, "BORYS");
      expect(find.byKey(const ValueKey('piece-23')), findsOneWidget);
      expect(find.byKey(const ValueKey('piece-54')), findsNothing);
      expect(find.byKey(const ValueKey('piece-34')), findsNothing);
      expect(find.text("TOOK 2"), findsOneWidget);
    },
  );

  testWidgets('a move that ends on the last row draws a ring',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(1, 2): lightMan,
          squareAt(5, 4): darkMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-12')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square-1')));
    await tester.pump();

    expect(find.byKey(const ValueKey('disc-1-light-true')), findsOneWidget);
  });

  testWidgets('passing through the last row mid chain does not draw a ring',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(2, 3): lightMan,
          squareAt(1, 4): darkMan,
          squareAt(1, 6): darkMan,
          squareAt(8, 1): darkMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-23')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square-5')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square-27')));
    await tester.pump();

    expect(find.byKey(const ValueKey('disc-27-light-false')), findsOneWidget);
    expect(find.byKey(const ValueKey('disc-27-light-true')), findsNothing);
  });

  testWidgets('when the opponent has no pieces left, the result page shows',
      (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(4, 5): darkMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-54')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square-36')));
    await tester.pumpAndSettle();

    expect(find.byType(ResultPage), findsOneWidget);
    expect(winnerOnResult(tester), "ANNA");
    expect(onResult("WINS"), findsOneWidget);
    expect(onResult("TOOK 1"), findsOneWidget);
    expect(onResult("TOOK 0"), findsOneWidget);
    expect(onResult("PLAY AGAIN"), findsOneWidget);
  });

  testWidgets('when no moves are left, the game ends too', (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(4, 5): darkMan,
          squareAt(9, 0): darkMan,
          squareAt(8, 1): lightMan,
          squareAt(7, 2): lightMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-54')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square-36')));
    await tester.pumpAndSettle();

    expect(find.byType(ResultPage), findsOneWidget);
    expect(winnerOnResult(tester), "ANNA");
  });

  testWidgets('a new game returns the board to its starting state', (tester) async {
    await tester.pumpWidget(
      humanGame(
        Board.withPieces({
          squareAt(5, 4): lightMan,
          squareAt(4, 5): darkMan,
        }),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-54')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square-36')));
    await tester.pumpAndSettle();
    await tester.tap(onResult("PLAY AGAIN"));
    await tester.pumpAndSettle();

    expect(find.byType(ResultPage), findsNothing);
    expect(find.byKey(const ValueKey('piece-54')), findsOneWidget);
    expect(find.byKey(const ValueKey('piece-45')), findsOneWidget);
    expect(find.text("TOOK 0"), findsNWidgets(2));
  });

  for (final level in Difficulty.values) {
    testWidgets('the computer at difficulty ${level.name} replies with its own move',
        (tester) async {
      await tester.pumpWidget(botGame(Board.initial(), level));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('square-61')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('square-50')));
      await tester.pump();

      expect(activeSlab(tester).name, botName);
      expect(find.text("THINKING"), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));

      expect(activeSlab(tester).name, "ANNA");
      expect(find.byKey(const ValueKey('piece-50')), findsOneWidget);
    });
  }

  testWidgets('the computer\'s slab is not inverted, the human\'s slab is inverted',
      (tester) async {
    await tester.pumpWidget(botGame(Board.initial(), Difficulty.easy));
    await tester.pump();

    final TurnSlab botSlab = tester
        .widgetList<TurnSlab>(find.byType(TurnSlab))
        .firstWhere((slab) => slab.name == botName);
    expect(botSlab.inverted, isFalse);
    await tester.pump(const Duration(seconds: 1));

    await tester.pumpWidget(humanGame(Board.initial()));
    await tester.pump();
    final TurnSlab darkSlab = tester
        .widgetList<TurnSlab>(find.byType(TurnSlab))
        .firstWhere((slab) => slab.name == "BORYS");
    expect(darkSlab.inverted, isTrue);
  });

  testWidgets('while the computer is thinking, taps do not go through', (tester) async {
    await tester.pumpWidget(botGame(Board.initial(), Difficulty.easy));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-61')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square-50')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('square-63')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('spot-52')), findsNothing);

    await tester.pump(const Duration(seconds: 1));
  });
}
