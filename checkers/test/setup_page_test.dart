import 'package:checkers/pages/game.dart';
import 'package:checkers/pages/intro.dart';
import 'package:checkers/pages/setup.dart';
import 'package:checkers/models/piece.dart';
import 'package:checkers/utils/sheet.dart';
import 'package:checkers/widgets/checker_piece.dart';
import 'package:checkers/widgets/turn_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The setup screen in the page's theme.
Widget setup() => MaterialApp(
      theme: pressTheme(Brightness.light),
      home: const SetupPage(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('two-player mode shows two name fields and no difficulty levels', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(setup());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text("EASY"), findsNothing);
  });

  testWidgets('switching to computer mode leaves one field and offers three difficulty levels',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(setup());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mode-bot')));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(1));
    expect(find.text("EASY"), findsOneWidget);
    expect(find.text("MEDIUM"), findsOneWidget);
    expect(find.text("HARD"), findsOneWidget);
  });

  testWidgets('switching back to two-player mode brings back the second field', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(setup());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mode-bot')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mode-two')));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text("EASY"), findsNothing);
  });

  testWidgets('a piece of the matching side stands next to each label',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(setup());
    await tester.pumpAndSettle();

    final Iterable<CheckerPiece> discs =
        tester.widgetList<CheckerPiece>(find.byType(CheckerPiece));
    expect(discs.map((disc) => disc.piece.side), [Side.light, Side.dark]);
  });

  testWidgets('saved names are filled into the fields', (tester) async {
    SharedPreferences.setMockInitialValues({
      "player_light_name": "ANNA",
      "player_dark_name": "BORYS",
    });
    await tester.pumpWidget(setup());
    await tester.pumpAndSettle();

    expect(find.text("ANNA"), findsOneWidget);
    expect(find.text("BORYS"), findsOneWidget);
  });

  testWidgets('starting opens the board with the entered names', (tester) async {
    SharedPreferences.setMockInitialValues({
      "player_light_name": "ANNA",
      "player_dark_name": "BORYS",
    });
    await tester.pumpWidget(setup());
    await tester.pumpAndSettle();

    await tester.tap(find.text("START"));
    await tester.pumpAndSettle();

    expect(find.byType(GamePage), findsOneWidget);
    final Iterable<TurnSlab> slabs =
        tester.widgetList<TurnSlab>(find.byType(TurnSlab));
    expect(slabs.map((slab) => slab.name), ["BORYS", "ANNA"]);
    expect(slabs.firstWhere((slab) => slab.active).name, "ANNA");
  });

  testWidgets('the back button returns to the first screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(theme: pressTheme(Brightness.light), home: const IntroPage()),
    );
    await tester.tap(find.text("PLAY"));
    await tester.pumpAndSettle();
    expect(find.byType(SetupPage), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('back')));
    await tester.pumpAndSettle();

    expect(find.byType(IntroPage), findsOneWidget);
    expect(find.byType(SetupPage), findsNothing);
  });
}
