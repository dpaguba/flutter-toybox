import 'package:flutter/material.dart';

import '../utils/sheet.dart';

/// How long the slab's stamp animation lasts.
const Duration stampDuration = Duration(milliseconds: 260);

/// A player's slab: their name in bold type, and what the rules are
/// currently telling them.
///
/// The slab of whoever's turn it is is set in vermilion and larger than
/// the other player's, so the turn is visible from either side of the
/// table. [inverted] flips the slab for the player sitting opposite.
class TurnSlab extends StatefulWidget {
  const TurnSlab({
    super.key,
    required this.name,
    required this.claim,
    required this.took,
    required this.active,
    this.compulsory = false,
    this.inverted = false,
  });

  /// The player's name.
  final String name;

  /// The line the rules are telling this player right now.
  final String claim;

  /// How many of the opponent's pieces they have taken off the board.
  final int took;

  /// Whether it is their turn.
  final bool active;

  /// Whether this is the compulsory-maximum-capture requirement: only
  /// that one gets the stamp animation.
  final bool compulsory;

  /// Whether to flip the slab for the player sitting opposite.
  final bool inverted;

  @override
  State<TurnSlab> createState() => _TurnSlabState();
}

class _TurnSlabState extends State<TurnSlab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stamp = AnimationController(
    vsync: this,
    duration: stampDuration,
    value: 1,
  );

  @override
  void didUpdateWidget(TurnSlab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool struck = widget.active &&
        widget.compulsory &&
        (widget.claim != oldWidget.claim || !oldWidget.active);
    if (struck && !MediaQuery.of(context).disableAnimations) {
      _stamp.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _stamp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    final TextTheme type = Theme.of(context).textTheme;
    final Color letters = widget.active ? sheet.onAccent : sheet.mark;
    final Widget slab = Container(
      color: widget.active ? sheet.accent : sheet.ground,
      padding: EdgeInsets.symmetric(
        horizontal: pageMargin,
        vertical: widget.active ? 14 : 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (widget.active ? type.displayMedium : type.displaySmall)
                ?.copyWith(color: letters),
          ),
          const SizedBox(height: 2),
          Wrap(
            spacing: 14,
            children: [
              if (widget.active)
                Text(
                  widget.claim,
                  style: type.labelLarge?.copyWith(color: letters),
                ),
              Text(
                "TOOK ${widget.took}",
                style: type.labelMedium?.copyWith(
                  color: widget.active ? sheet.onAccent : sheet.quiet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    final Widget stamped = AnimatedBuilder(
      animation: _stamp,
      builder: (context, child) => Transform.scale(
        scale: 1 + 0.06 * (1 - Curves.easeOutExpo.transform(_stamp.value)),
        child: child,
      ),
      child: slab,
    );
    return widget.inverted
        ? RotatedBox(quarterTurns: 2, child: stamped)
        : stamped;
  }
}
