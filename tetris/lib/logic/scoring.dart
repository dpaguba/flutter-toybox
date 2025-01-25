/// Score, levels, and fall speed.
class Scoring {
  const Scoring._();

  /// Points awarded for one, two, three, and four lines at the first level.
  static const List<int> lineScores = [0, 100, 300, 500, 800];

  /// How many lines one level holds.
  static const int linesPerLevel = 10;

  /// The highest level at which speed still increases.
  static const int topLevel = 10;

  /// Pause between fall steps in milliseconds, from the first level to the tenth.
  static const List<int> gravitySteps = [
    800,
    720,
    630,
    550,
    470,
    380,
    300,
    220,
    130,
    100,
  ];

  /// Points for `lines` cleared lines at `level`.
  ///
  /// Raises:
  ///   ArgumentError: if lines is less than zero or greater than four, or if
  ///     level is less than the first.
  static int lineScore(int lines, int level) {
    if (lines < 0 || lines >= lineScores.length) {
      throw ArgumentError.value(lines, "lines", "Lines must be between 0 and 4");
    }
    _requireLevel(level);
    return lineScores[lines] * level;
  }

  /// Points for soft-dropping `cells` cells.
  static int softDropScore(int cells) => cells;

  /// Points for hard-dropping `cells` cells.
  static int hardDropScore(int cells) => cells * 2;

  /// Level for a total of `lines` cleared lines.
  static int levelForLines(int lines) => 1 + lines ~/ linesPerLevel;

  /// Pause between fall steps at `level`.
  ///
  /// Raises:
  ///   ArgumentError: if level is less than the first.
  static int gravityForLevel(int level) {
    _requireLevel(level);
    return level >= topLevel ? gravitySteps.last : gravitySteps[level - 1];
  }

  /// Checks that level is not lower than the first.
  ///
  /// Raises:
  ///   ArgumentError: if level is less than the first.
  static void _requireLevel(int level) {
    if (level < 1) {
      throw ArgumentError.value(level, "level", "Level starts at 1");
    }
  }
}
