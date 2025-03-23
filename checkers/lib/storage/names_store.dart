import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';

/// Stores the two names between app launches.
///
/// A name that is empty or made only of spaces is not stored as such: a
/// placeholder comes back instead. Otherwise the panel above the board
/// would show blank space.
class NamesStore {
  static const String lightKey = "player_light_name";
  static const String darkKey = "player_dark_name";

  /// The trimmed name, or the placeholder if it is empty.
  String _orDefault(String? value, String fallback) {
    final String text = (value ?? "").trim();
    return text.isEmpty ? fallback : text;
  }

  /// The pair of names: light first, then dark.
  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      _orDefault(prefs.getString(lightKey), defaultLightName),
      _orDefault(prefs.getString(darkKey), defaultDarkName),
    ];
  }

  /// Writes both names.
  Future<void> save(String light, String dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lightKey, light.trim());
    await prefs.setString(darkKey, dark.trim());
  }
}
