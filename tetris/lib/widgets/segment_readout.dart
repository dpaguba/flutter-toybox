import 'package:flutter/material.dart';

import '../theme/chassis.dart';
import 'chassis_surface.dart';

/// Number behind glass: a stenciled label on the chassis and segment digits
/// beneath it.
///
/// The digits are drawn as segments rather than set in a font, so each one
/// takes up the same width and the number does not jitter while the count
/// runs. Unused digit positions stay unlit, as on a real display.
class SegmentReadout extends StatelessWidget {
  const SegmentReadout({
    super.key,
    required this.label,
    required this.value,
    this.digits = 6,
    this.factor = 1,
  });

  /// What the readout shows: `SCORE`, `LEVEL`, `LINES`, `BEST`.
  final String label;

  /// The number itself, as a string.
  final String value;

  /// How many digit positions the readout has.
  final int digits;

  /// How much larger the digits are than the system font size.
  final double factor;

  @override
  Widget build(BuildContext context) {
    final double base =
        Theme.of(context).textTheme.titleMedium?.fontSize ?? 16;
    final double height = base * factor * boundedTextScale(context, limit: 1.4);
    final double width = SegmentDigits.widthFor(height, digits);
    return Semantics(
      label: "$label $value",
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: chassisLabel(context)),
          SizedBox(height: height * 0.22),
          RecessedPanel(
            glass: true,
            radius: 4,
            padding: EdgeInsets.symmetric(
              horizontal: height * 0.28,
              vertical: height * 0.22,
            ),
            child: SizedBox(
              width: width,
              height: height,
              child: SegmentDigits(value: value, digits: digits),
            ),
          ),
        ],
      ),
    );
  }
}

/// The segment digits alone, without the glass or the label.
class SegmentDigits extends StatelessWidget {
  const SegmentDigits({super.key, required this.value, required this.digits});

  /// The number as a string.
  final String value;

  /// How many digit positions the readout has.
  final int digits;

  /// Width of a readout with `digits` digit positions at height `height`.
  static double widthFor(double height, int digits) {
    final double cell = height * 0.58;
    return cell * digits + height * 0.16 * (digits - 1);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SegmentPainter(value: value, digits: digits),
      size: Size.infinite,
    );
  }
}

class _SegmentPainter extends CustomPainter {
  const _SegmentPainter({required this.value, required this.digits});

  final String value;
  final int digits;

  static const Map<String, String> _shapes = {
    "0": "abcdef",
    "1": "bc",
    "2": "abged",
    "3": "abgcd",
    "4": "fgbc",
    "5": "afgcd",
    "6": "afgecd",
    "7": "abc",
    "8": "abcdefg",
    "9": "abcdfg",
  };

  @override
  void paint(Canvas canvas, Size size) {
    final double gap = size.height * 0.16;
    final double cell = (size.width - gap * (digits - 1)) / digits;
    final String shown = value.length > digits
        ? value.substring(value.length - digits)
        : value.padLeft(digits);

    final Paint off = Paint()..color = Chassis.ledOff;
    final Paint on = Paint()..color = Chassis.ledOn;

    for (var i = 0; i < digits; i++) {
      final double left = i * (cell + gap);
      final String lit = _shapes[shown[i]] ?? "";
      for (final segment in "abcdefg".split("")) {
        final Path path = _path(segment, left, cell, size.height);
        canvas.drawPath(path, lit.contains(segment) ? on : off);
      }
    }
  }

  Path _path(String segment, double left, double w, double h) {
    final double t = h * 0.15;
    final double x0 = left + t * 0.6;
    final double x1 = left + w - t * 0.6;
    final double top = t * 0.5 + 1;
    final double middle = h / 2;
    final double bottom = h - t * 0.5 - 1;
    switch (segment) {
      case "a":
        return _horizontal(x0, x1, top, t);
      case "g":
        return _horizontal(x0, x1, middle, t);
      case "d":
        return _horizontal(x0, x1, bottom, t);
      case "f":
        return _vertical(x0, top + t * 0.4, middle - t * 0.4, t);
      case "b":
        return _vertical(x1, top + t * 0.4, middle - t * 0.4, t);
      case "e":
        return _vertical(x0, middle + t * 0.4, bottom - t * 0.4, t);
      default:
        return _vertical(x1, middle + t * 0.4, bottom - t * 0.4, t);
    }
  }

  Path _horizontal(double x0, double x1, double cy, double t) {
    return Path()
      ..moveTo(x0, cy)
      ..lineTo(x0 + t * 0.5, cy - t * 0.5)
      ..lineTo(x1 - t * 0.5, cy - t * 0.5)
      ..lineTo(x1, cy)
      ..lineTo(x1 - t * 0.5, cy + t * 0.5)
      ..lineTo(x0 + t * 0.5, cy + t * 0.5)
      ..close();
  }

  Path _vertical(double cx, double y0, double y1, double t) {
    return Path()
      ..moveTo(cx, y0)
      ..lineTo(cx + t * 0.5, y0 + t * 0.5)
      ..lineTo(cx + t * 0.5, y1 - t * 0.5)
      ..lineTo(cx, y1)
      ..lineTo(cx - t * 0.5, y1 - t * 0.5)
      ..lineTo(cx - t * 0.5, y0 + t * 0.5)
      ..close();
  }

  @override
  bool shouldRepaint(_SegmentPainter old) =>
      old.value != value || old.digits != digits;
}
