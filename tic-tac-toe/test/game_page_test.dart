import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/pages/game.dart';
import 'package:tic_tac_toe/widgets/pixel_mark.dart';

GamePage twoHumanGame() => const GamePage(
      left: Player(name: "ANNA", mark: "X"),
      right: Player(name: "BORYS", mark: "O"),
    );

GamePage vsBotGame() => const GamePage(
      left: Player(name: "ANNA", mark: "X"),
      right: Player(
        name: botName,
        mark: "O",
        isBot: true,
        difficulty: Difficulty.easy,
      ),
    );

void main() {
  testWidgets(
    'tapping an empty cell places the mark of the player whose turn it is and passes the turn',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: twoHumanGame()));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      expect(find.byKey(const ValueKey('mark-0-X')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump();
      expect(find.byKey(const ValueKey('mark-1-O')), findsOneWidget);
    },
  );

  /// The cell stays X rather than switching to O, and no other cell got
  /// filled in: that means O's turn never actually came.
  testWidgets('tapping an occupied cell changes nothing', (tester) async {
    await tester.pumpWidget(MaterialApp(home: twoHumanGame()));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('cell-0')));
    await tester.pump();
    expect(find.byKey(const ValueKey('mark-0-X')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cell-0')));
    await tester.pump();
    expect(find.byKey(const ValueKey('mark-0-X')), findsOneWidget);
    expect(find.byType(PixelMark), findsNWidgets(1));
  });

  /// The bot "thinks" for 400 ms; a tap within that window must be ignored.
  /// Once the delay elapses, the bot's deferred move fires and adds exactly
  /// one new mark.
  testWidgets(
    'in a game against the bot, a tap during its thinking is ignored, and the bot moves exactly once',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: vsBotGame()));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      expect(find.byType(PixelMark), findsNWidgets(1));

      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PixelMark), findsNWidgets(1));

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(PixelMark), findsNWidgets(2));
    },
  );

  /// X takes 0, 1, 2 (the top row); O takes 3 and 4 between X's moves,
  /// blocking nothing. The series is not over yet (three wins are needed):
  /// the dialog shows "1 : 0" only if recordRound fired exactly once, not
  /// twice.
  testWidgets(
    'a completed line records exactly one round',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: twoHumanGame()));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-4')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-2')));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("1 : 0"), findsOneWidget);
    },
  );

  testWidgets(
    'while the series is in progress, the dialog title stays "<name> WINS ROUND"',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: twoHumanGame()));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-4')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-2')));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text("ANNA WINS ROUND"),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text("MATCH OVER"),
        ),
        findsNothing,
      );
    },
  );

  /// Round 1: X wins the top row (0, 1, 2); leftScore -> 1. Round 2 is
  /// started by O (the loser moves first), and O wins the top row;
  /// rightScore -> 1. Round 3 is started by X, who again wins the top row;
  /// leftScore -> 2. Round 4 is started by O; X wins the left column
  /// (0, 3, 6) before O can complete its own line, taking leftScore to 3
  /// and ending the series.
  ///
  /// History rows must not stretch the dialog to fit a long name: each one
  /// should stay a single line with an ellipsis rather than wrapping or
  /// overflowing.
  testWidgets(
    'when the series is over, the dialog title is "MATCH OVER" instead of '
    '"... WINS ROUND", and the final score is shown',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: twoHumanGame()));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-4')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-2')));
      await tester.pump();
      await tester.tap(find.text("NEXT ROUND"));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-4')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-2')));
      await tester.pump();
      await tester.tap(find.text("NEXT ROUND"));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-4')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-2')));
      await tester.pump();
      await tester.tap(find.text("NEXT ROUND"));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-4')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cell-6')));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text("MATCH OVER"),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text("ANNA WINS ROUND"),
        ),
        findsNothing,
      );
      expect(find.text("3 : 1"), findsOneWidget);

      final List<Text> historyRows = tester
          .widgetList<Text>(find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Text),
          ))
          .where((text) => text.data?.startsWith('R') ?? false)
          .toList();

      expect(historyRows, hasLength(4));
      for (final Text row in historyRows) {
        expect(row.maxLines, 1);
        expect(row.overflow, TextOverflow.ellipsis);
      }
    },
  );
}
