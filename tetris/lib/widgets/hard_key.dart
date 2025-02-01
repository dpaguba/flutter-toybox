import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/chassis.dart';
import 'key_glyph.dart';

/// A physical control key: a cap on a base, with travel and real press
/// feedback.
///
/// The action fires on touch-down rather than on release: in a game where
/// the piece is falling, waiting for release feels like input lag. With
/// `repeating`, the action repeats for as long as the finger stays on the
/// key, so a piece can be moved sideways with one long press. A pressed key
/// settles onto its base and stays there for as long as the finger remains
/// on it.
class HardKey extends StatefulWidget {
  const HardKey({
    super.key,
    this.label,
    this.mark,
    required this.onPressed,
    this.cap,
    this.repeating = false,
    this.compact = false,
  });

  /// Label printed on the cap, or `null` if the mark alone is enough.
  final String? label;

  /// Printed mark above the label, or `null`.
  final KeyMark? mark;

  final VoidCallback onPressed;

  /// Cap color, or `null` for a key colored like the chassis.
  ///
  /// Only keys that spend something irreversible get a color: hard drop and
  /// hold. Moving left, right, or down can always be played back, so those
  /// keys stay the chassis color.
  final Color? cap;

  /// Whether to repeat the action while the key is held.
  final bool repeating;

  /// Whether this is a small side key rather than a bottom-row key.
  final bool compact;

  /// Delay before the first repeat.
  static const Duration repeatDelay = Duration(milliseconds: 240);

  /// Delay between repeats.
  static const Duration repeatInterval = Duration(milliseconds: 70);

  /// Downward travel of the cap, in logical pixels.
  static const double travel = 4;

  @override
  State<HardKey> createState() => _HardKeyState();
}

class _HardKeyState extends State<HardKey> {
  bool _held = false;
  Timer? _delay;
  Timer? _repeat;

  @override
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  void _onDown() {
    setState(() => _held = true);
    widget.onPressed();
    if (!widget.repeating) {
      return;
    }
    _delay = Timer(HardKey.repeatDelay, () {
      _repeat = Timer.periodic(
        HardKey.repeatInterval,
        (_) => widget.onPressed(),
      );
    });
  }

  void _onUp() {
    _stopRepeating();
    if (mounted) {
      setState(() => _held = false);
    }
  }

  void _stopRepeating() {
    _delay?.cancel();
    _delay = null;
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  Widget build(BuildContext context) {
    final Chassis chassis = Chassis.of(context);
    final Color? cap = widget.cap;
    final Color ink = cap == null ? chassis.keyInk : Chassis.capInk;
    final double travel = widget.compact ? 3 : HardKey.travel;
    final double minHeight =
        (widget.compact ? 44.0 : 56.0) * boundedTextScale(context, limit: 1.3);
    final TextStyle label = keyLabel(context, color: ink);
    final double glyph = (label.fontSize ?? 13) * 1.7;

    return Semantics(
      button: true,
      label: widget.label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _onDown(),
        onTapUp: (_) => _onUp(),
        onTapCancel: _onUp,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight, minWidth: 44),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              top: _held ? travel : 0,
              bottom: _held ? 0 : travel,
            ),
            decoration: BoxDecoration(
              color: chassis.keyPlinth,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: widget.compact ? 8 : 12,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: _capFace(
                  top: cap == null ? chassis.keyCapHigh : _lift(cap),
                  bottom: cap ?? chassis.keyCapLow,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.mark != null)
                    KeyGlyph(mark: widget.mark!, color: ink, size: glyph),
                  if (widget.mark != null && widget.label != null)
                    const SizedBox(height: 4),
                  if (widget.label != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.label!,
                        textAlign: TextAlign.center,
                        style: label,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _lift(Color color) {
    return Color.lerp(color, Colors.white, 0.16) ?? color;
  }

  /// The cap: a light bevel at the top, a body, a dark bevel at the bottom.
  ///
  /// A pressed key hides the top bevel, because light no longer falls on
  /// it.
  LinearGradient _capFace({required Color top, required Color bottom}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(top, Colors.white, _held ? 0.06 : 0.3) ?? top,
        top,
        bottom,
        Color.lerp(bottom, Colors.black, 0.3) ?? bottom,
      ],
      stops: const [0, 0.1, 0.86, 1],
    );
  }
}
