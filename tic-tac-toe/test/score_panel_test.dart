import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/widgets/score_panel.dart';

void main() {
  testWidgets('long names do not overflow a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ScorePanel(
          leftName: "VERYLONGNAME",
          rightName: "ANOTHERLONGONE",
          leftScore: 3,
          rightScore: 2,
          activeIsLeft: true,
        ),
      ),
    ));

    expect(tester.takeException(), isNull);

    final nameText = tester.widget<Text>(find.text("VERYLONGNAME"));
    expect(nameText.maxLines, 1);
    expect(nameText.overflow, TextOverflow.ellipsis);
  });

  testWidgets('shows both names and both scores', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ScorePanel(
          leftName: "ANNA",
          rightName: "BORYS",
          leftScore: 1,
          rightScore: 2,
          activeIsLeft: false,
        ),
      ),
    ));
    expect(find.text("ANNA"), findsOneWidget);
    expect(find.text("BORYS"), findsOneWidget);
    expect(find.text("1"), findsOneWidget);
    expect(find.text("2"), findsOneWidget);
  });

  testWidgets('a large text scale factor does not break the panel', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(textScaleFactor: 2.0),
      child: MaterialApp(
        home: Scaffold(
          body: ScorePanel(
            leftName: "ANNA",
            rightName: "BORYS",
            leftScore: 1,
            rightScore: 2,
            activeIsLeft: true,
          ),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });
}
