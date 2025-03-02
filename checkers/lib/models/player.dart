import 'piece.dart';

/// The computer opponent's difficulty level.
enum Difficulty { easy, medium, hard }

/// The computer's name. Not editable on the setup screen.
const String botName = "COMPUTER";

/// The placeholder name for light, when the player has typed nothing.
const String defaultLightName = "MAPLE";

/// The placeholder name for dark, when the player has typed nothing.
const String defaultDarkName = "WALNUT";

/// A participant in the game.
class Player {
  const Player({
    required this.name,
    required this.side,
    this.isBot = false,
    this.difficulty,
  });

  /// The name, as shown on screen.
  final String name;

  /// The side this player plays.
  final Side side;

  /// Whether this is the computer.
  final bool isBot;

  /// The computer's difficulty; empty for a human.
  final Difficulty? difficulty;
}
