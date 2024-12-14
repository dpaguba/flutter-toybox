import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// The shared button used on every screen: a white rectangle with a
/// centered label.
///
/// The side margin matches the content padding on the setup screen, so the
/// button lines up with the fields above it. Without it, the white bar would
/// reach the edges of the display and read as a system banner rather than a
/// game button. The corners stay sharp: rounding them would clash with the
/// pixel font.
class PixelButton extends StatelessWidget {
  const PixelButton({super.key, required this.label, required this.onTap});

  static const double sideMargin = 24;

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sideMargin, 0, sideMargin, 16),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                label,
                style: customFontBlack.copyWith(fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
