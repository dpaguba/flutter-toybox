import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/pages/setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('in two-player mode there are two name fields and no difficulty',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: SetupPage()));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text("EASY"), findsNothing);
  });

  testWidgets('switching to the bot leaves one field and shows difficulty',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: SetupPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mode-bot')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(1));
    expect(find.text("EASY"), findsOneWidget);
    expect(find.text("MEDIUM"), findsOneWidget);
    expect(find.text("HARD"), findsOneWidget);
  });

  testWidgets('saved names are filled into the fields', (tester) async {
    SharedPreferences.setMockInitialValues({
      "player_left_name": "ANNA",
      "player_right_name": "BORYS",
    });
    await tester.pumpWidget(const MaterialApp(home: SetupPage()));
    await tester.pumpAndSettle();
    expect(find.text("ANNA"), findsOneWidget);
    expect(find.text("BORYS"), findsOneWidget);
  });
}
