import 'package:flutter/material.dart';

import '../theme/chassis.dart';
import 'hard_key.dart';
import 'key_glyph.dart';

/// The machine's bottom row of keys.
///
/// The keys are not equal to one another, because their consequences are
/// not equal. Moving left, right, and down repeats for as long as the
/// finger is on the key, and can always be played back. Hard drop fires
/// once, locks the piece in place for good, and so sits apart from the
/// rest, wider than all of them and under its own color.
class KeyDeck extends StatelessWidget {
  const KeyDeck({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
    required this.onHold,
    this.canHold = true,
  });

  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback onHold;

  /// Whether the piece can be held right now.
  final bool canHold;

  /// Gap between adjacent keys.
  static const double gap = 8;

  /// Gap separating hard drop from the rest of the row.
  static const double dropGap = 20;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: HardKey(
                key: const ValueKey("control-left"),
                mark: KeyMark.left,
                label: "LEFT",
                repeating: true,
                onPressed: onLeft,
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              flex: 3,
              child: HardKey(
                key: const ValueKey("control-rotate"),
                mark: KeyMark.turn,
                label: "TURN",
                onPressed: onRotate,
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              flex: 4,
              child: HardKey(
                key: const ValueKey("control-right"),
                mark: KeyMark.right,
                label: "RIGHT",
                repeating: true,
                onPressed: onRight,
              ),
            ),
          ],
        ),
        const SizedBox(height: gap),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: HardKey(
                key: const ValueKey("control-hold"),
                mark: KeyMark.hold,
                label: "HOLD",
                cap: canHold ? Chassis.holdCap : null,
                onPressed: onHold,
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              flex: 3,
              child: HardKey(
                key: const ValueKey("control-down"),
                mark: KeyMark.down,
                label: "DOWN",
                repeating: true,
                onPressed: onSoftDrop,
              ),
            ),
            const SizedBox(width: dropGap),
            Expanded(
              flex: 5,
              child: HardKey(
                key: const ValueKey("control-drop"),
                mark: KeyMark.drop,
                label: "DROP",
                cap: Chassis.dropCap,
                onPressed: onHardDrop,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
