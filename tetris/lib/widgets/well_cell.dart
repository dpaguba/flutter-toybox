import 'package:flutter/material.dart';

import '../models/tetromino.dart';
import '../theme/chassis.dart';
import '../utils/constants.dart';

/// One cell of the well.
///
/// A filled cell is a tool keycap: flat paint, a light top edge and a dark
/// bottom edge, i.e. a shape molded from plastic, not a blob of light. An
/// empty cell is bottom markup, and the drop shadow is a faint mark of the
/// spot where the piece will land.
class WellCell extends StatelessWidget {
  const WellCell({super.key, this.type, this.ghost = false});

  /// The piece the cell belongs to, or `null` if the cell is empty.
  final TetrominoType? type;

  /// Whether this is the spot the piece will land on if dropped.
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final TetrominoType? shown = type;
    if (shown == null) {
      return Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Chassis.of(context).grid, width: 0.7),
        ),
      );
    }

    final Color color = colorOf(shown);
    if (ghost) {
      return Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: color.withOpacity(0.5), width: 1.2),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color: color,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.24)),
          left: BorderSide(color: Colors.white.withOpacity(0.14)),
          right: BorderSide(color: Colors.black.withOpacity(0.2)),
          bottom: BorderSide(color: Colors.black.withOpacity(0.3)),
        ),
      ),
    );
  }
}
