import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sheet: a complete set of colors for one look.
///
/// The light look is an impression on paper. The dark one is that same
/// page seen as a printing plate: the background turns to ink, and the
/// marks turn to paper. There is one vermilion for both looks, because in
/// this world it is the only color and it always means one thing: the
/// rules are speaking.
@immutable
class Sheet {
  const Sheet({
    required this.ground,
    required this.mark,
    required this.quiet,
    required this.accent,
    required this.onAccent,
  });

  /// The page's background.
  final Color ground;

  /// The main ink: text, rules, dark pieces.
  final Color mark;

  /// The muted ink of secondary lines.
  final Color quiet;

  /// The single vermilion.
  final Color accent;

  /// The color of marks printed on the vermilion.
  final Color onAccent;

  /// An impression on paper: daylight.
  static const Sheet impression = Sheet(
    ground: Color(0xFFF4EFE4),
    mark: Color(0xFF141210),
    quiet: Color(0xFF5F574B),
    accent: Color(0xFFC22B12),
    onAccent: Color(0xFFF4EFE4),
  );

  /// A printing plate: evening light, when paper cannot be shone into
  /// your eyes.
  static const Sheet plate = Sheet(
    ground: Color(0xFF100E0C),
    mark: Color(0xFFEDE7DA),
    quiet: Color(0xFF9A9184),
    accent: Color(0xFFC22B12),
    onAccent: Color(0xFFEDE7DA),
  );

  /// The sheet matching the system's current look.
  static Sheet of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? plate : impression;
}

/// The margin from the page edge, where the typesetting does not bleed
/// off the page.
const double pageMargin = 20;

/// The thickness of the heavy rule that cuts across the page.
const double heavyRule = 5;

/// The thickness of the thin rule.
const double hairRule = 1.5;

/// The smallest side of an element meant to be touched.
const double touchFloor = 44;

/// The cap on text scaling in switches with a width known in advance.
///
/// A segment does not grow wider, so without a cap the word inside it
/// gets clipped. The rest of the page follows the system size with no
/// limit.
const double segmentScaleCap = 1.6;

/// The size of a word in the typesetting.
///
/// The steps match the scale of iOS's system text styles, so the
/// typesetting follows the text size the player chose in their phone's
/// settings.
TextTheme _pressType(Sheet sheet) {
  final TextStyle slab = GoogleFonts.ultra();
  return TextTheme(
    displayLarge: slab.copyWith(
      fontSize: 42,
      height: 1.02,
      letterSpacing: -1.2,
      color: sheet.mark,
    ),
    displayMedium: slab.copyWith(
      fontSize: 30,
      height: 1.05,
      letterSpacing: -0.6,
      color: sheet.mark,
    ),
    displaySmall: slab.copyWith(
      fontSize: 22,
      height: 1.1,
      letterSpacing: -0.3,
      color: sheet.mark,
    ),
    titleLarge: slab.copyWith(fontSize: 20, color: sheet.mark),
    bodyLarge: TextStyle(fontSize: 17, height: 1.4, color: sheet.mark),
    bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: sheet.quiet),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: sheet.mark,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: sheet.quiet,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: sheet.quiet,
    ),
  );
}

/// The app's theme for one look.
ThemeData pressTheme(Brightness brightness) {
  final Sheet sheet =
      brightness == Brightness.dark ? Sheet.plate : Sheet.impression;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: sheet.ground,
    canvasColor: sheet.ground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: sheet.accent,
      brightness: brightness,
    ).copyWith(
      primary: sheet.accent,
      onPrimary: sheet.onAccent,
      surface: sheet.ground,
      onSurface: sheet.mark,
      background: sheet.ground,
      onBackground: sheet.mark,
    ),
    textTheme: _pressType(sheet),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: sheet.accent,
      selectionColor: sheet.accent.withOpacity(0.28),
      selectionHandleColor: sheet.accent,
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: sheet.accent,
      barBackgroundColor: sheet.ground,
      scaffoldBackgroundColor: sheet.ground,
    ),
  );
}
