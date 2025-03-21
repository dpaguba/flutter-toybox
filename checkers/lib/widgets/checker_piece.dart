import 'package:flutter/material.dart';

import '../models/piece.dart';
import '../utils/sheet.dart';

/// A cut disc: a piece cut out of the sheet.
///
/// Dark is solid ink, light is paper outlined in ink. Either way, a king
/// carries a ring punched through its center, so a man and a king are
/// told apart at a glance, from either side of the table.
class _DiscPainter extends CustomPainter {
  const _DiscPainter({
    required this.solid,
    required this.king,
    required this.face,
    required this.ground,
  });

  /// Whether the disc is filled solid with ink.
  final bool solid;

  /// Whether to punch a ring into the disc.
  final bool king;

  /// The disc's ink color.
  final Color face;

  /// The paper color under the disc.
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    final double d = size.shortestSide;
    final Offset centre = Offset(size.width / 2, size.height / 2);
    final double stroke = d * 0.11;
    final double radius = d / 2 - stroke / 2;
    canvas.drawCircle(
      centre,
      radius,
      Paint()..color = solid ? face : ground,
    );
    if (!solid) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..color = face
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
    }
    if (king) {
      canvas.drawCircle(
        centre,
        radius * 0.52,
        Paint()
          ..color = solid ? ground : face
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_DiscPainter oldDelegate) =>
      oldDelegate.solid != solid ||
      oldDelegate.king != king ||
      oldDelegate.face != face ||
      oldDelegate.ground != ground;
}

/// A piece on the board: a flat cut disc, with no gloss or shadow.
class CheckerPiece extends StatelessWidget {
  const CheckerPiece({super.key, required this.piece, this.spent = false});

  /// Which piece to draw.
  final Piece piece;

  /// A captured piece that, under the rules, stays on the board until the
  /// chain ends.
  final bool spent;

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    return CustomPaint(
      painter: _DiscPainter(
        solid: piece.side == Side.dark && !spent,
        king: piece.isKing,
        face: spent ? sheet.quiet : sheet.mark,
        ground: sheet.ground,
      ),
      child: const SizedBox.expand(),
    );
  }
}
