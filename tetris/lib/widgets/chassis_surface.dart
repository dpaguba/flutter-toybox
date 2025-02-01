import 'package:flutter/material.dart';

import '../theme/chassis.dart';

/// Brushed metal chassis covering the full screen area.
///
/// The metal is lighter at the top and darker at the bottom, with a fine
/// brushed grain running through it. The grain is painted rather than built
/// from widgets, so it costs nothing in layout and never intercepts taps.
class BrushedPanel extends StatelessWidget {
  const BrushedPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Chassis chassis = Chassis.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: chassis.metalLow),
      child: CustomPaint(
        painter: _BrushedPainter(chassis),
        child: child,
      ),
    );
  }
}

class _BrushedPainter extends CustomPainter {
  const _BrushedPainter(this.chassis);

  final Chassis chassis;

  static const double _pitch = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect area = Offset.zero & size;
    canvas.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [chassis.metalHigh, chassis.metalLow],
        ).createShader(area),
    );

    final Paint line = Paint()..strokeWidth = 1;
    final int rows = (size.height / _pitch).ceil();
    for (var i = 0; i < rows; i++) {
      final double y = i * _pitch;
      final int step = (i * 7) % 5;
      line.color = step < 2
          ? chassis.grain.withOpacity(0.08)
          : chassis.edgeDark.withOpacity(0.07);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(_BrushedPainter old) => old.chassis != chassis;
}

/// A recess in the chassis: a well, a bank window, an indicator glass.
///
/// Light falls from above, so the top edge casts a shadow inward while the
/// bottom edge catches a highlight, the same effect a milled socket
/// produces in metal.
class RecessedPanel extends StatelessWidget {
  const RecessedPanel({
    super.key,
    required this.child,
    this.radius = 6,
    this.padding = EdgeInsets.zero,
    this.glass = false,
  });

  final Widget child;

  /// Corner radius of the socket.
  final double radius;

  /// Padding from the socket's edge to its content.
  final EdgeInsets padding;

  /// Whether this is indicator glass, which stays dark regardless of theme.
  final bool glass;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RecessPainter(
        chassis: Chassis.of(context),
        radius: radius,
        glass: glass,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _RecessPainter extends CustomPainter {
  const _RecessPainter({
    required this.chassis,
    required this.radius,
    required this.glass,
  });

  final Chassis chassis;
  final double radius;
  final bool glass;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect area = Offset.zero & size;
    final RRect shape = RRect.fromRectAndRadius(area, Radius.circular(radius));
    canvas.drawRRect(
      shape,
      Paint()..color = glass ? Chassis.glass : chassis.recess,
    );

    canvas.save();
    canvas.clipRRect(shape);
    final double depth = size.height * 0.05 + 4;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, depth),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.55),
            Colors.black.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, depth)),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, depth * 0.6, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, depth * 0.6, size.height)),
    );
    canvas.drawLine(
      Offset(radius, size.height - 0.75),
      Offset(size.width - radius, size.height - 0.75),
      Paint()
        ..color = chassis.recessRim.withOpacity(0.55)
        ..strokeWidth = 1.5,
    );
    canvas.restore();

    canvas.drawRRect(
      shape.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = chassis.edgeDark.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(_RecessPainter old) =>
      old.chassis != chassis || old.radius != radius || old.glass != glass;
}
