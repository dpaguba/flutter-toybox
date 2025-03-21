import 'package:flutter/material.dart';

import '../utils/sheet.dart';

/// What fraction of the width the wedge's bottom edge cuts off at a slant.
const double wedgeSlope = 0.22;

/// Cuts a rectangle at a slant along its bottom edge.
class _WedgeClipper extends CustomClipper<Path> {
  const _WedgeClipper();

  @override
  Path getClip(Size size) {
    final double cut = size.width * wedgeSlope;
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_WedgeClipper oldClipper) => false;
}

/// A wedge: a full-width block of vermilion, cut at a slant.
///
/// This is the same slanted rule that cuts the page into wedges, only
/// filled with ink, so the block of text inside it reads as a pull quote
/// rather than as a card.
class WedgeBlock extends StatelessWidget {
  const WedgeBlock({super.key, required this.child});

  /// The typesetting inside the wedge.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipPath(
          clipper: const _WedgeClipper(),
          child: ColoredBox(
            color: sheet.accent,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pageMargin,
                pageMargin,
                pageMargin,
                pageMargin + constraints.maxWidth * wedgeSlope,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
