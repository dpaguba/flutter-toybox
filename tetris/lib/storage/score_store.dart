import 'package:shared_preferences/shared_preferences.dart';

/// Stores the best score across launches.
class ScoreStore {
  static const String _key = "tetris_high_score";

  /// The best score, or zero if the game has never been played.
  Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  /// Saves a score and reports whether it beat the previous record.
  ///
  /// A score equal to the record does not count as a new record: otherwise
  /// the game-over screen would congratulate the player on a record after
  /// every identical run.
  Future<bool> save(int score) async {
    if (score <= 0) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final int best = prefs.getInt(_key) ?? 0;
    if (score <= best) {
      return false;
    }
    await prefs.setInt(_key, score);
    return true;
  }
}
