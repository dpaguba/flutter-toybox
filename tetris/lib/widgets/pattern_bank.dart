import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/tetromino.dart';
import '../theme/chassis.dart';
import 'chassis_surface.dart';
import 'well_cell.dart';

/// Bank window holding a single piece: held or next.
///
/// The piece is drawn inside a four-by-four square and shifted toward the
/// center so the narrow I and the wide O occupy the window the same way.
class PatternBank extends StatelessWidget {
  const PatternBank({super.key, this.label, this.type, this.dimmed = false});

  /// Stenciled label above the window, or `null` if no label is needed.
  final String? label;

  /// The piece shown in the window, or `null` if it is empty.
  final TetrominoType? type;

  /// Whether to show the piece dimmed, for example when it cannot be taken.
  final bool dimmed;

  static const int _box = 4;

  /// Padding from the window's edge to the piece.
  static const double windowPadding = 5;

  /// Ratio of the window's width to its height.
  static const double windowAspect = 1.15;

  /// Gap between the label and the window.
  static const double labelGap = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: labelGap),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(label!, style: chassisLabel(context)),
            ),
          ),
        Opacity(
          opacity: dimmed ? 0.35 : 1,
          child: RecessedPanel(
            radius: 5,
            padding: const EdgeInsets.all(windowPadding),
            child: AspectRatio(
              aspectRatio: windowAspect,
              child: _grid(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _grid() {
    final Set<Cell> filled = _centeredCells();
    return Column(
      children: [
        for (var y = 0; y < _box; y++)
          Expanded(
            child: Row(
              children: [
                for (var x = 0; x < _box; x++)
                  Expanded(
                    child: filled.contains(Cell(x, y))
                        ? WellCell(type: type)
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Set<Cell> _centeredCells() {
    final TetrominoType? shown = type;
    if (shown == null) {
      return const {};
    }
    final List<Cell> cells = Tetromino.cellsFor(shown, 0);
    final int minX = cells.map((cell) => cell.x).reduce(_min);
    final int maxX = cells.map((cell) => cell.x).reduce(_max);
    final int minY = cells.map((cell) => cell.y).reduce(_min);
    final int maxY = cells.map((cell) => cell.y).reduce(_max);
    final int dx = ((_box - (maxX - minX + 1)) / 2).floor() - minX;
    final int dy = ((_box - (maxY - minY + 1)) / 2).floor() - minY;
    return cells.map((cell) => cell.shifted(dx, dy)).toSet();
  }

  static int _min(int a, int b) => a < b ? a : b;

  static int _max(int a, int b) => a > b ? a : b;
}
