import 'package:flutter/material.dart';

import '../models/piece.dart';
import '../models/playfield.dart';
import '../models/tetromino.dart';
import 'chassis_surface.dart';
import 'well_cell.dart';

/// The well: the socket in the chassis, the settled pieces, the drop shadow,
/// and the piece that is falling.
///
/// The widget computes nothing: it receives a ready state and lays it out
/// on the grid. The piece is drawn over the shadow, and the shadow over the
/// empty cells.
class PlayfieldView extends StatelessWidget {
  const PlayfieldView({
    super.key,
    required this.field,
    this.current,
    this.ghost,
  });

  final Playfield field;

  /// The piece currently falling.
  final Piece? current;

  /// The place where the piece will land on hard drop.
  final Piece? ghost;

  @override
  Widget build(BuildContext context) {
    final List<List<TetrominoType?>> shown = List.generate(
      field.rows,
      (y) => List.generate(field.columns, (x) => field.at(x, y)),
    );
    final List<List<bool>> outline = List.generate(
      field.rows,
      (_) => List.filled(field.columns, false),
    );

    for (final cell in ghost?.cells ?? const []) {
      if (_inside(cell.x, cell.y)) {
        shown[cell.y][cell.x] = ghost!.type;
        outline[cell.y][cell.x] = true;
      }
    }
    for (final cell in current?.cells ?? const []) {
      if (_inside(cell.x, cell.y)) {
        shown[cell.y][cell.x] = current!.type;
        outline[cell.y][cell.x] = false;
      }
    }

    return RecessedPanel(
      radius: 8,
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          for (var y = 0; y < field.rows; y++)
            Expanded(
              child: Row(
                children: [
                  for (var x = 0; x < field.columns; x++)
                    Expanded(
                      child: WellCell(
                        key: ValueKey("cell-$x-$y"),
                        type: shown[y][x],
                        ghost: outline[y][x],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _inside(int x, int y) =>
      x >= 0 && x < field.columns && y >= 0 && y < field.rows;
}
