import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/models/player.dart';
import 'package:tic_tac_toe/storage/names_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('with no saved names it returns the placeholders', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await NamesStore().load(), ["PLAYER X", "PLAYER O"]);
  });

  test('a saved value is read back', () async {
    SharedPreferences.setMockInitialValues({});
    final store = NamesStore();
    await store.save("ANNA", "BORYS");
    expect(await store.load(), ["ANNA", "BORYS"]);
  });

  test('an empty name is replaced by the placeholder', () async {
    SharedPreferences.setMockInitialValues({});
    final store = NamesStore();
    await store.save("", "  ");
    expect(await store.load(), ["PLAYER X", "PLAYER O"]);
  });

  test('a human player has no difficulty', () {
    const player = Player(name: "ANNA", mark: "X");
    expect(player.isBot, isFalse);
    expect(player.difficulty, isNull);
  });

  test('the placeholder name constants are unchanged', () {
    expect(botName, "COMPUTER");
    expect(defaultLeftName, "PLAYER X");
    expect(defaultRightName, "PLAYER O");
  });
}
