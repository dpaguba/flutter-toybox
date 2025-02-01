import 'package:flutter/material.dart';

/// The machine's chassis finish for one theme state.
///
/// The machine is the same by day and by night. Only the chassis and key
/// finish change: the well and the indicator glass stay dark under either
/// light, so the field reads the same in both themes.
@immutable
class Chassis {
  const Chassis._({
    required this.metalHigh,
    required this.metalLow,
    required this.grain,
    required this.edgeDark,
    required this.recess,
    required this.recessRim,
    required this.grid,
    required this.ink,
    required this.inkSoft,
    required this.keyCapHigh,
    required this.keyCapLow,
    required this.keyPlinth,
    required this.keyInk,
    required this.lampOn,
    required this.lampOff,
    required this.record,
  });

  /// The top of the chassis, where light falls.
  final Color metalHigh;

  /// The bottom of the chassis, where light no longer reaches.
  final Color metalLow;

  /// The grain of brushed metal.
  final Color grain;

  /// The dark bevel under a part.
  final Color edgeDark;

  /// The bottom of a recess: the well, a window, the glass.
  final Color recess;

  /// The rim of a recess, catching the light.
  final Color recessRim;

  /// Markup of empty cells at the bottom of the well.
  final Color grid;

  /// The primary paint of stenciled labels.
  final Color ink;

  /// The secondary paint of stenciled labels.
  final Color inkSoft;

  /// The top of a colorless keycap.
  final Color keyCapHigh;

  /// The bottom of a colorless keycap.
  final Color keyCapLow;

  /// The base a key sits on when pressed.
  final Color keyPlinth;

  /// The paint of the label on a colorless key.
  final Color keyInk;

  /// A lit tempo lamp.
  final Color lampOn;

  /// An unlit tempo lamp.
  final Color lampOff;

  /// The paint used on the chassis to mark a broken record.
  final Color record;

  /// Indicator glass: dark under either finish.
  static const Color glass = Color(0xFF0B0A09);

  /// A lit indicator segment.
  static const Color ledOn = Color(0xFFFF7B34);

  /// An unlit segment, still visible on the glass.
  static const Color ledOff = Color(0xFF2A1B12);

  /// The paint of the label on a colored key.
  static const Color capInk = Color(0xFF141210);

  /// The reset key: the one action that cannot be undone.
  static const Color dropCap = Color(0xFFF0574E);

  /// The hold key: one per piece.
  static const Color holdCap = Color(0xFFF2B22A);

  /// The key that starts the clock: start, resume, new game.
  ///
  /// The color is taken from the same flat paint as the keys in the well,
  /// and is deliberately neither yellow nor red: starting costs nothing and
  /// breaks nothing.
  static const Color startCap = Color(0xFF2FB3C9);

  /// Night finish: dark brushed metal.
  static const Chassis night = Chassis._(
    metalHigh: Color(0xFF302C28),
    metalLow: Color(0xFF1D1B19),
    grain: Color(0xFF44403A),
    edgeDark: Color(0xFF0D0C0B),
    recess: Color(0xFF0F0E0D),
    recessRim: Color(0xFF453F39),
    grid: Color(0xFF211F1D),
    ink: Color(0xFFF0EBE1),
    inkSoft: Color(0xFFA79E92),
    keyCapHigh: Color(0xFF433E38),
    keyCapLow: Color(0xFF322E2A),
    keyPlinth: Color(0xFF141311),
    keyInk: Color(0xFFF0EBE1),
    lampOn: Color(0xFFFFB53D),
    lampOff: Color(0xFF3B342C),
    record: Color(0xFFFFB53D),
  );

  /// Day finish: a light bone-colored chassis.
  static const Chassis day = Chassis._(
    metalHigh: Color(0xFFF2EDE3),
    metalLow: Color(0xFFDBD4C7),
    grain: Color(0xFFFFFFFF),
    edgeDark: Color(0xFFA79E8D),
    recess: Color(0xFF141311),
    recessRim: Color(0xFFB4AB9A),
    grid: Color(0xFF272421),
    ink: Color(0xFF272420),
    inkSoft: Color(0xFF5C564D),
    keyCapHigh: Color(0xFFFCF9F3),
    keyCapLow: Color(0xFFE7E0D2),
    keyPlinth: Color(0xFFAAA192),
    keyInk: Color(0xFF272420),
    lampOn: Color(0xFFC25E00),
    lampOff: Color(0xFFC3BBAB),
    record: Color(0xFF8A4500),
  );

  /// The finish that matches the theme surrounding `context`.
  static Chassis of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? night : day;
  }
}

/// The smallest font size below which a label on the chassis becomes unreadable.
const double _inkFloor = 11;

double _atLeast(double? size, double floor) {
  return size == null || size < floor ? floor : size;
}

/// A small stenciled label on the chassis: a block's name, an indicator's caption.
///
/// The font size comes from the system style, so the label grows along with
/// the text size the reader chose in their phone's settings.
TextStyle chassisLabel(BuildContext context, {bool strong = false}) {
  final TextStyle base =
      Theme.of(context).textTheme.labelSmall ?? const TextStyle();
  final Chassis chassis = Chassis.of(context);
  return base.copyWith(
    fontSize: _atLeast(base.fontSize, _inkFloor),
    fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
    letterSpacing: 1.6,
    height: 1.1,
    color: strong ? chassis.ink : chassis.inkSoft,
  );
}

/// A label on a key: larger than a stenciled one, since it is read with a thumb.
TextStyle keyLabel(BuildContext context, {required Color color}) {
  final TextStyle base =
      Theme.of(context).textTheme.labelLarge ?? const TextStyle();
  return base.copyWith(
    fontSize: _atLeast(base.fontSize, 13),
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    height: 1.1,
    color: color,
  );
}

/// The machine's nameplate: the one place where the brand typeface is used.
///
/// The typeface lives in the app's own `fonts` folder rather than being
/// pulled from the network, so the nameplate is the same on a plane and in
/// the subway.
TextStyle nameplate(BuildContext context, {double factor = 1}) {
  final TextStyle base =
      Theme.of(context).textTheme.headlineSmall ?? const TextStyle();
  return base.copyWith(
    fontFamily: "Michroma",
    fontSize: _atLeast(base.fontSize, 24) * factor,
    letterSpacing: 3,
    height: 1.15,
    color: Chassis.of(context).ink,
  );
}

/// The text scale factor, clamped so the field stays on screen.
///
/// Labels grow along with the phone's setting, but growth stops after one
/// and a half times: otherwise the keys and windows would eat into the
/// well, and the game lives precisely in the well.
double boundedTextScale(BuildContext context, {double limit = 1.5}) {
  final double scale = MediaQuery.textScaleFactorOf(context);
  if (scale < 1) {
    return 1;
  }
  return scale > limit ? limit : scale;
}

/// Clamps text growth within its subtree.
///
/// Labels follow the phone's text size setting, but the chassis must
/// remain the chassis: past the limit a label stops growing, otherwise the
/// keys and windows would push the well off the screen.
class BoundedTextScale extends StatelessWidget {
  const BoundedTextScale({super.key, required this.child, this.limit = 1.6});

  final Widget child;

  /// The largest factor still allowed through.
  final double limit;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(
        textScaleFactor: boundedTextScale(context, limit: limit),
      ),
      child: child,
    );
  }
}
