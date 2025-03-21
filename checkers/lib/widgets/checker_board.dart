import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/board.dart';
import '../utils/sheet.dart';
import 'checker_piece.dart';

/// How far from the center of an allowed square a tap is still drawn to it.
///
/// A square on the ten-by-ten board is narrower than a finger, so a tap
/// looks for the nearest of the squares the rules currently allow. The
/// fraction is kept under one square width, so a tap landing right in the
/// center of a neighboring square never gets pulled away to it.
const double snapRadius = 0.8;

/// The page's field: paper, ink on the non-playing squares, and the
/// rule marks.
class _FieldPainter extends CustomPainter {
  const _FieldPainter({
    required this.sheet,
    required this.origin,
    required this.destinations,
    required this.movable,
    required this.trail,
  });

  final Sheet sheet;
  final int? origin;
  final Set<int> destinations;
  final Set<int> movable;
  final Set<int> trail;

  /// The center of square [square] on a canvas with square side [side].
  static Offset centreOf(int square, double side) => Offset(
        (colOf(square) + 0.5) * side,
        (rowOf(square) + 0.5) * side,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final double side = size.width / boardSize;
    canvas.drawRect(Offset.zero & size, Paint()..color = sheet.ground);
    final Paint ink = Paint()..color = sheet.mark;
    for (var square = 0; square < squareCount; square++) {
      if (isPlaySquare(square)) {
        continue;
      }
      final double x = colOf(square) * side;
      final double y = rowOf(square) * side;
      canvas.drawRect(
        Rect.fromLTWH(x - 0.3, y - 0.3, side + 0.6, side + 0.6),
        ink,
      );
    }
    final Paint trace = Paint()
      ..color = sheet.quiet
      ..style = PaintingStyle.stroke
      ..strokeWidth = hairRule;
    for (final square in trail) {
      final double x = colOf(square) * side;
      final double y = rowOf(square) * side;
      canvas.drawRect(
        Rect.fromLTWH(x + 2, y + 2, side - 4, side - 4),
        trace,
      );
    }
    final Paint vermilion = Paint()..color = sheet.accent;
    final Set<int> field = <int>{...movable};
    if (origin != null) {
      field.add(origin!);
    }
    for (final square in field) {
      final double x = colOf(square) * side;
      final double y = rowOf(square) * side;
      canvas.drawRect(
        Rect.fromLTWH(x - 0.3, y - 0.3, side + 0.6, side + 0.6),
        vermilion,
      );
    }
    if (origin == null) {
      return;
    }
    final Paint run = Paint()
      ..color = sheet.accent
      ..strokeWidth = side * 0.16
      ..strokeCap = StrokeCap.butt;
    for (final square in destinations) {
      canvas.drawLine(
        centreOf(origin!, side),
        centreOf(square, side),
        run,
      );
    }
    final double ox = colOf(origin!) * side;
    final double oy = rowOf(origin!) * side;
    final double box = side * 0.10;
    canvas.drawRect(
      Rect.fromLTWH(ox + box / 2, oy + box / 2, side - box, side - box),
      Paint()
        ..color = sheet.mark
        ..style = PaintingStyle.stroke
        ..strokeWidth = box,
    );
  }

  @override
  bool shouldRepaint(_FieldPainter oldDelegate) =>
      oldDelegate.sheet.ground != sheet.ground ||
      oldDelegate.origin != origin ||
      !setEquals(oldDelegate.destinations, destinations) ||
      !setEquals(oldDelegate.movable, movable) ||
      !setEquals(oldDelegate.trail, trail);
}

/// Marks drawn over pieces: struck out and forbidden.
class _StrikePainter extends CustomPainter {
  const _StrikePainter({
    required this.sheet,
    required this.struck,
    required this.barred,
  });

  final Sheet sheet;
  final Set<int> struck;
  final int? barred;

  @override
  void paint(Canvas canvas, Size size) {
    final double side = size.width / boardSize;
    final Paint bar = Paint()
      ..color = sheet.accent
      ..strokeWidth = side * 0.14
      ..strokeCap = StrokeCap.butt;
    for (final square in struck) {
      final double x = colOf(square) * side;
      final double y = rowOf(square) * side;
      canvas.drawLine(
        Offset(x + side * 0.10, y + side * 0.90),
        Offset(x + side * 0.90, y + side * 0.10),
        bar,
      );
    }
    if (barred == null) {
      return;
    }
    final double x = colOf(barred!) * side;
    final double y = rowOf(barred!) * side;
    final Paint cross = Paint()
      ..color = sheet.accent
      ..strokeWidth = side * 0.12
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(x + side * 0.12, y + side * 0.12),
      Offset(x + side * 0.88, y + side * 0.88),
      cross,
    );
    canvas.drawLine(
      Offset(x + side * 0.88, y + side * 0.12),
      Offset(x + side * 0.12, y + side * 0.88),
      cross,
    );
  }

  @override
  bool shouldRepaint(_StrikePainter oldDelegate) =>
      oldDelegate.sheet.accent != sheet.accent ||
      oldDelegate.barred != barred ||
      !setEquals(oldDelegate.struck, struck);
}

/// The board as a printed page: a hundred squares, pieces as cut discs,
/// and whatever the rules currently allow set in vermilion.
class CheckerBoard extends StatelessWidget {
  const CheckerBoard({
    super.key,
    required this.board,
    required this.onTap,
    this.origin,
    this.destinations = const <int>{},
    this.movable = const <int>{},
    this.doomed = const <int>{},
    this.victims = const <int>{},
    this.trail = const <int>{},
    this.barred,
    this.enabled = true,
  });

  /// The position to print.
  final Board board;

  /// The square a tap resolved to.
  final void Function(int square) onTap;

  /// The square the current move is being made from.
  final int? origin;

  /// The squares the next step is allowed to land on.
  final Set<int> destinations;

  /// The pieces the rules currently allow to move.
  final Set<int> movable;

  /// Pieces captured in an unfinished chain: still on the board, but
  /// already out of the game.
  final Set<int> doomed;

  /// The pieces the proposed next step would remove.
  final Set<int> victims;

  /// The trail of the previous move.
  final Set<int> trail;

  /// A piece the player picked that the rules did not allow.
  final int? barred;

  /// Whether the board accepts taps.
  final bool enabled;

  /// The square a tap at point [point] actually means.
  ///
  /// Null means the tap did not land on anything meaningful.
  int? _resolve(int square, Offset point, double side) {
    final Set<int> candidates = <int>{...movable, ...destinations};
    if (candidates.contains(square)) {
      return square;
    }
    if (board.at(square) != null) {
      return square;
    }
    double best = snapRadius * side;
    int? pick;
    for (final candidate in candidates) {
      final double distance =
          (_FieldPainter.centreOf(candidate, side) - point).distance;
      if (distance < best) {
        best = distance;
        pick = candidate;
      }
    }
    if (pick != null) {
      return pick;
    }
    return isPlaySquare(square) ? square : null;
  }

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double side = constraints.maxWidth / boardSize;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _FieldPainter(
                    sheet: sheet,
                    origin: origin,
                    destinations: destinations,
                    movable: movable,
                    trail: trail,
                  ),
                ),
              ),
              for (var square = 0; square < squareCount; square++)
                if (board.at(square) != null)
                  Positioned(
                    key: ValueKey('piece-$square'),
                    left: colOf(square) * side + side * 0.09,
                    top: rowOf(square) * side + side * 0.09,
                    width: side * 0.82,
                    height: side * 0.82,
                    child: CheckerPiece(
                      key: ValueKey(
                        'disc-$square-${board.at(square)!.side.name}'
                        '-${board.at(square)!.isKing}',
                      ),
                      piece: board.at(square)!,
                      spent: doomed.contains(square),
                    ),
                  ),
              for (final square in destinations)
                Positioned(
                  left: colOf(square) * side + side * 0.24,
                  top: rowOf(square) * side + side * 0.24,
                  width: side * 0.52,
                  height: side * 0.52,
                  child: ColoredBox(
                    key: ValueKey('spot-$square'),
                    color: sheet.accent,
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _StrikePainter(
                      sheet: sheet,
                      struck: <int>{...doomed, ...victims},
                      barred: barred,
                    ),
                  ),
                ),
              ),
              for (var square = 0; square < squareCount; square++)
                Positioned(
                  left: colOf(square) * side,
                  top: rowOf(square) * side,
                  width: side,
                  height: side,
                  child: GestureDetector(
                    key: ValueKey('square-$square'),
                    behavior: HitTestBehavior.opaque,
                    onTapUp: enabled
                        ? (details) {
                            final Offset point = Offset(
                              colOf(square) * side + details.localPosition.dx,
                              rowOf(square) * side + details.localPosition.dy,
                            );
                            final int? target = _resolve(square, point, side);
                            if (target != null) {
                              onTap(target);
                            }
                          }
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
