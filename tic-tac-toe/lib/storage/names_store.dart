import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';

/// Persists two names across app launches.
///
/// An empty name, or one made up only of whitespace, is not stored as such:
/// a placeholder comes back instead. Otherwise the score panel would show a
/// blank space.
class NamesStore {
  static const String _leftKey = "player_left_name";
  static const String _rightKey = "player_right_name";

  String _orDefault(String? value, String fallback) {
    final String text = (value ?? "").trim();
    return text.isEmpty ? fallback : text;
  }

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      _orDefault(prefs.getString(_leftKey), defaultLeftName),
      _orDefault(prefs.getString(_rightKey), defaultRightName),
    ];
  }

  Future<void> save(String left, String right) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_leftKey, left.trim());
    await prefs.setString(_rightKey, right.trim());
  }
}
