import 'package:flutter/material.dart';

import '../utils/sheet.dart';
import '../widgets/slab_button.dart';
import '../widgets/wedge_block.dart';

/// What the player chose on the result page.
enum ResultChoice {
  /// Set the pieces up again.
  again,

  /// Go back to the first screen.
  menu,
}

/// The result page: who won, and how many pieces each side took off the
/// board.
class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.winner,
    required this.lightName,
    required this.darkName,
    required this.lightTook,
    required this.darkTook,
  });

  /// The winner's name.
  final String winner;

  /// The name of whoever played light.
  final String lightName;

  /// The name of whoever played dark.
  final String darkName;

  /// How many pieces light took.
  final int lightTook;

  /// How many pieces dark took.
  final int darkTook;

  /// One player's tally line.
  Widget _tally(BuildContext context, String name, int took) {
    final TextTheme type = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: type.bodyLarge,
            ),
          ),
          Text("TOOK $took", style: type.labelLarge),
        ],
      ),
    );
  }

  /// A headline line, set across the full width of the column.
  Widget _line(BuildContext context, String text, {Key? key}) {
    final Sheet sheet = Sheet.of(context);
    return Expanded(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          key: key,
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
            const SizedBox(height: 24),
            Expanded(
              flex: 5,
              child: WedgeBlock(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _line(context, winner, key: const ValueKey('winner')),
                    _line(context, "WINS"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(pageMargin, 22, pageMargin, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: heavyRule, color: sheet.mark),
                  _tally(context, lightName, lightTook),
                  _tally(context, darkName, darkTook),
                ],
              ),
            ),
            const Spacer(),
            SlabButton(
              label: "PLAY AGAIN",
              onTap: () => Navigator.of(context).pop(ResultChoice.again),
            ),
            SlabButton(
              label: "MAIN MENU",
              filled: false,
              footer: true,
              onTap: () => Navigator.of(context).pop(ResultChoice.menu),
            ),
          ],
        ),
      ),
    );
  }
}
