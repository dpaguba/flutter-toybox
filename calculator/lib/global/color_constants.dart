import 'package:flutter/material.dart';

/// Colours of the neumorphic keypad, in pairs of a surface and the two
/// shadows that sit above and below it.
class ColorConst {
  /// Face of a dark key.
  static const Color bBackground = Color(0xff2e3239);
  /// Highlight along the top edge of a dark key.
  static const Color bShadowTop = Color(0xff35393f);
  /// Shadow under the bottom edge of a dark key.
  static const Color bShadowBottom = Color(0xff23262a);

  /// Face of a light key.
  static const Color wBackground = Color.fromRGBO(224, 224, 224, 1);
  /// Highlight along the top edge of a light key.
  static const Color wShadowTop = Color.fromRGBO(255, 255, 255, 1);
  /// Shadow under the bottom edge of a light key.
  static const Color wShadowDown = Color.fromRGBO(158, 158, 158, 1);

  /// Shadow cast inside a light key while it is held down.
  static const Color wInsetShadowTop = Color.fromRGBO(158, 158, 158, 1);

  /// Legend on a dark key, which is the light key's own face.
  static const Color wText = wBackground;
  /// Legend on a light key, which is the dark key's own face.
  static const Color bText = bBackground;
}
