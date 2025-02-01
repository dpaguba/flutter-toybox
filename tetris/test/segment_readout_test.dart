import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/widgets/segment_readout.dart';

Future<void> pumpReadout(WidgetTester tester, SegmentReadout readout) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: readout))),
  );
}

void main() {
  testWidgets('the label is printed on the housing', (tester) async {
    await pumpReadout(
      tester,
      const SegmentReadout(label: "SCORE", value: "1200"),
    );
    expect(find.text("SCORE"), findsOneWidget);
  });

  testWidgets('the number is drawn with segments, not set as text',
      (tester) async {
    await pumpReadout(
      tester,
      const SegmentReadout(label: "SCORE", value: "1200"),
    );
    expect(find.text("1200"), findsNothing);
    expect(
      tester.widget<SegmentDigits>(find.byType(SegmentDigits)).value,
      "1200",
    );
  });

  testWidgets('digits have equal width no matter what the number is',
      (tester) async {
    await pumpReadout(tester, const SegmentReadout(label: "BEST", value: "7"));
    final Size narrow = tester.getSize(find.byType(SegmentDigits));

    await pumpReadout(
      tester,
      const SegmentReadout(label: "BEST", value: "654321"),
    );
    expect(tester.getSize(find.byType(SegmentDigits)), narrow);
  });

  testWidgets('the number grows together with the device text size', (tester) async {
    await pumpReadout(tester, const SegmentReadout(label: "BEST", value: "7"));
    final double plain = tester.getSize(find.byType(SegmentDigits)).height;

    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.4),
        child: child!,
      ),
      home: const Scaffold(
        body: Center(child: SegmentReadout(label: "BEST", value: "7")),
      ),
    ));
    expect(
      tester.getSize(find.byType(SegmentDigits)).height,
      greaterThan(plain),
    );
  });

  testWidgets('the indicator is read aloud as label and number', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpReadout(
      tester,
      const SegmentReadout(label: "SCORE", value: "1200"),
    );
    expect(find.bySemanticsLabel("SCORE 1200"), findsOneWidget);
    handle.dispose();
  });
}
