import 'package:checkers/models/piece.dart';
import 'package:checkers/models/player.dart';
import 'package:checkers/storage/names_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('with no names saved, returns the placeholders', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await NamesStore().load(), [defaultLightName, defaultDarkName]);
  });

  test('what was saved reads back', () async {
    SharedPreferences.setMockInitialValues({});
    final store = NamesStore();
    await store.save("ANNA", "BORYS");
    expect(await store.load(), ["ANNA", "BORYS"]);
  });

  test('an empty name is replaced with the placeholder', () async {
    SharedPreferences.setMockInitialValues({});
    final store = NamesStore();
    await store.save("", "  ");
    expect(await store.load(), [defaultLightName, defaultDarkName]);
  });

  test('a human player has no difficulty', () {
    const player = Player(name: "ANNA", side: Side.light);
    expect(player.isBot, isFalse);
    expect(player.difficulty, isNull);
  });

  test('the placeholder name constants stay fixed', () {
    expect(botName, "COMPUTER");
    expect(defaultLightName, "MAPLE");
    expect(defaultDarkName, "WALNUT");
  });
}
