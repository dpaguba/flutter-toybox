import 'package:flutter/material.dart';

/// Mark printed on a key.
enum KeyMark {
  /// Triangle pointing left.
  left,

  /// Triangle pointing right.
  right,

  /// Triangle pointing down.
  down,

  /// Triangle above a baseline: the piece goes all the way down.
  drop,

  /// Arc with an arrowhead: clockwise rotation.
  turn,

  /// A piece in a side slot: hold.
  hold,

  /// Two bars: pause time.
  pause,
}

/// The printed mark on a key, drawn with lines rather than set in a font.
class KeyGlyph extends StatelessWidget {
  const KeyGlyph({
    super.key,
    required this.mark,
    required this.color,
    required this.size,
  });

  /// Which mark is printed.
  final KeyMark mark;

  /// Color of the mark: the same as the label on the cap.
  final Color color;

  /// Side length of the square the mark is inscribed in.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlyphPainter(mark: mark, color: color)),
    );
  }
}

/// A quarter of a full turn, in radians.
const double _quarter = 1.5707963267948966;

/// Paints a [KeyMark] as a figure built from lines and fills.
///
/// A mark is meant to hold together as one connected figure rather than
/// break into separate specks of paint; a gap is drawn only where the mark's
/// own shape calls for one (the base of drop, the nest of hold, the two bars
/// of pause). The turn arrowhead follows this rule too: its position is
/// derived from the arc's own end point rather than placed by independent
/// constants, because independently placed coordinates drift apart from the
/// arc as the key's size changes and the arrowhead ends up visibly detached
/// from it.
class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.mark, required this.color});

  final KeyMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint fill = Paint()..color = color;
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.square;

    switch (mark) {
      case KeyMark.left:
        canvas.drawPath(
          _triangle(Offset(w * 0.28, h * 0.5), Offset(w * 0.68, h * 0.2),
              Offset(w * 0.68, h * 0.8)),
          fill,
        );
        break;
      case KeyMark.right:
        canvas.drawPath(
          _triangle(Offset(w * 0.72, h * 0.5), Offset(w * 0.32, h * 0.2),
              Offset(w * 0.32, h * 0.8)),
          fill,
        );
        break;
      case KeyMark.down:
        canvas.drawPath(
          _triangle(Offset(w * 0.5, h * 0.74), Offset(w * 0.2, h * 0.32),
              Offset(w * 0.8, h * 0.32)),
          fill,
        );
        break;
      case KeyMark.drop:
        canvas.drawPath(
          _triangle(Offset(w * 0.5, h * 0.62), Offset(w * 0.22, h * 0.16),
              Offset(w * 0.78, h * 0.16)),
          fill,
        );
        canvas.drawRect(
          Rect.fromLTRB(w * 0.18, h * 0.76, w * 0.82, h * 0.88),
          fill,
        );
        break;
      case KeyMark.turn:
        final Offset centre = Offset(w * 0.5, h * 0.54);
        final double radius = w * 0.27;
        canvas.drawArc(
          Rect.fromCircle(center: centre, radius: radius),
          0,
          _quarter * 3,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.12
            ..strokeCap = StrokeCap.butt,
        );
        final Offset head = centre + Offset(0, -radius);
        canvas.drawPath(
          _triangle(
            head + Offset(w * 0.17, 0),
            head + Offset(-w * 0.03, -w * 0.115),
            head + Offset(-w * 0.03, w * 0.115),
          ),
          fill,
        );
        break;
      case KeyMark.hold:
        canvas.drawRect(
          Rect.fromLTRB(w * 0.16, h * 0.22, w * 0.84, h * 0.78),
          stroke,
        );
        canvas.drawRect(
          Rect.fromLTRB(w * 0.34, h * 0.4, w * 0.66, h * 0.6),
          fill,
        );
        break;
      case KeyMark.pause:
        canvas.drawRect(
          Rect.fromLTRB(w * 0.28, h * 0.2, w * 0.42, h * 0.8),
          fill,
        );
        canvas.drawRect(
          Rect.fromLTRB(w * 0.58, h * 0.2, w * 0.72, h * 0.8),
          fill,
        );
        break;
    }
  }

  Path _triangle(Offset a, Offset b, Offset c) {
    return Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.mark != mark || old.color != color;
}
