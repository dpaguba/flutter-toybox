import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/sheet.dart';
import '../widgets/slab_button.dart';
import '../widgets/wedge_block.dart';
import 'setup.dart';

/// The first screen: the page that names the game and states its rule
/// right away.
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  /// A line of the manifesto, set across the full width of the column.
  ///
  /// The size is set by the available space, not a number: that is how
  /// wood type was set, and the line stays at full bleed at any system
  /// text size.
  Widget _line(BuildContext context, String text) {
    final Sheet sheet = Sheet.of(context);
    return Expanded(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          style: Theme.of(context)
              .textTheme
              .displayLarge
              ?.copyWith(color: sheet.onAccent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    return Scaffold(
      backgroundColor: sheet.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(pageMargin, 12, pageMargin, 8),
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "DRAUGHTS",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
            ),
            Container(height: heavyRule, color: sheet.mark),
            const SizedBox(height: 16),
            Expanded(
              flex: 7,
              child: WedgeBlock(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _line(context, "TAKE"),
                    _line(context, "THE MOST"),
                    _line(context, "OR NOTHING"),
                  ],
                ),
              ),
            ),
            SlabButton(
              label: "PLAY",
              footer: true,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute<void>(
                    builder: (context) => const SetupPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
