import 'package:checkers/pages/intro.dart';
import 'package:checkers/pages/setup.dart';
import 'package:checkers/utils/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The first screen in the page's theme.
Widget intro() => MaterialApp(
      theme: pressTheme(Brightness.light),
      home: const IntroPage(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the first screen names the game and states its rule', (tester) async {
    await tester.pumpWidget(intro());

    expect(find.text("DRAUGHTS"), findsOneWidget);
    expect(find.text("TAKE"), findsOneWidget);
    expect(find.text("THE MOST"), findsOneWidget);
    expect(find.text("OR NOTHING"), findsOneWidget);
  });

  testWidgets('there is no subtitle under the name', (tester) async {
    await tester.pumpWidget(intro());

    expect(find.textContaining("INTERNATIONAL"), findsNothing);
    expect(find.textContaining("10 x 10"), findsNothing);
  });

  testWidgets('the button opens setup', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(intro());

    await tester.tap(find.text("PLAY"));
    await tester.pumpAndSettle();

    expect(find.byType(SetupPage), findsOneWidget);
  });
}
