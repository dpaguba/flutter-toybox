import 'package:flutter/material.dart';

import '../utils/sheet.dart';

/// A standing head: the page title, set at a right angle.
///
/// The word stands in a strip of ink along the left edge, so the title
/// does not eat into the height that the margins and the button already
/// need.
class StandingHead extends StatelessWidget {
  const StandingHead({super.key, required this.text});

  /// The title's word.
  final String text;

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    return ColoredBox(
      color: sheet.mark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            text,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(color: sheet.ground),
          ),
        ),
      ),
    );
  }
}
