/// The computer opponent's difficulty level.
enum Difficulty { easy, medium, hard }

/// The computer's name. Not editable on the setup screen.
const String botName = "COMPUTER";

/// Placeholder names used when a player leaves the field empty.
const String defaultLeftName = "PLAYER X";
const String defaultRightName = "PLAYER O";

/// A participant in the game.
class Player {
  const Player({
    required this.name,
    required this.mark,
    this.isBot = false,
    this.difficulty,
  });

  final String name;
  final String mark;
  final bool isBot;
  final Difficulty? difficulty;
}
