import 'package:flutter/material.dart';

import '../theme/chassis.dart';

/// Step strip: a single lamp runs along the row at the pace of the piece's
/// fall.
///
/// This is the only motion in the whole app; nothing else moves. The lamp
/// completes a step in exactly the time it takes the piece to drop by one
/// cell, so the level is seen as a speed rather than a number. When paused,
/// the lamp stops, because time itself stops.
class TempoStrip extends StatefulWidget {
  const TempoStrip({
    super.key,
    required this.stepMs,
    required this.running,
    required this.level,
    this.steps = 16,
  });

  /// How long one drop step lasts, in milliseconds.
  final int stepMs;

  /// Whether time is running right now.
  final bool running;

  /// Current level: the strip lights up according to it when motion is
  /// disabled system-wide.
  final int level;

  /// How many lamps are in the strip.
  final int steps;

  @override
  State<TempoStrip> createState() => _TempoStripState();
}

class _TempoStripState extends State<TempoStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: _period,
  );

  Duration get _period =>
      Duration(milliseconds: widget.stepMs * widget.steps);

  @override
  void initState() {
    super.initState();
    if (widget.running) {
      _clock.repeat();
    }
  }

  @override
  void didUpdateWidget(TempoStrip old) {
    super.didUpdateWidget(old);
    if (old.stepMs != widget.stepMs || old.steps != widget.steps) {
      _clock.duration = _period;
      if (_clock.isAnimating) {
        _clock.repeat();
      }
    }
    if (widget.running && !_clock.isAnimating) {
      _clock.repeat();
    } else if (!widget.running && _clock.isAnimating) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool still = MediaQuery.of(context).disableAnimations;
    if (still && _clock.isAnimating) {
      _clock.stop();
    }
    final Chassis chassis = Chassis.of(context);
    final double height = 8 * boundedTextScale(context, limit: 1.3);
    return Row(
      children: [
        Text("TEMPO", style: chassisLabel(context)),
        const SizedBox(width: 10),
        Expanded(
          child: RepaintBoundary(
            child: SizedBox(
              height: height,
              child: AnimatedBuilder(
                animation: _clock,
                builder: (context, _) {
                  return CustomPaint(
                    painter: LampPainter(
                      chassis: chassis,
                      steps: widget.steps,
                      lit: still ? null : _index,
                      filled: still ? widget.level : 0,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  int get _index => (_clock.value * widget.steps).floor() % widget.steps;
}

/// Draws the lamps of the tempo strip.
class LampPainter extends CustomPainter {
  const LampPainter({
    required this.chassis,
    required this.steps,
    required this.lit,
    required this.filled,
  });

  /// The chassis finish that the lamp colors are drawn from.
  final Chassis chassis;

  /// How many lamps are in the strip.
  final int steps;

  /// The lamp currently lit, or `null` when motion is disabled.
  final int? lit;

  /// How many lamps are lit when motion is disabled.
  final int filled;

  @override
  void paint(Canvas canvas, Size size) {
    final double gap = size.height * 0.7;
    final double width = (size.width - gap * (steps - 1)) / steps;
    final Paint seat = Paint()..color = chassis.edgeDark.withOpacity(0.45);
    for (var i = 0; i < steps; i++) {
      final Rect lamp = Rect.fromLTWH(
        i * (width + gap),
        0,
        width,
        size.height,
      );
      final RRect shape =
          RRect.fromRectAndRadius(lamp, Radius.circular(size.height * 0.3));
      canvas.drawRRect(shape.inflate(0.8), seat);
      final bool on = lit == null ? i < filled : i == lit;
      canvas.drawRRect(
        shape,
        Paint()..color = on ? chassis.lampOn : chassis.lampOff,
      );
    }
  }

  @override
  bool shouldRepaint(LampPainter oldDelegate) =>
      oldDelegate.lit != lit ||
      oldDelegate.filled != filled ||
      oldDelegate.chassis != chassis;
}
