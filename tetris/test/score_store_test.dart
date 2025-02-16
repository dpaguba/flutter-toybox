import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/storage/score_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns zero when no record is saved', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await ScoreStore().load(), 0);
  });

  test('a saved record is read back', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ScoreStore();
    expect(await store.save(1200), isTrue);
    expect(await store.load(), 1200);
  });

  test('a lower score does not overwrite the record', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ScoreStore();
    await store.save(1200);
    expect(await store.save(900), isFalse);
    expect(await store.load(), 1200);
  });

  test('an equal score is not considered a new record', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ScoreStore();
    await store.save(500);
    expect(await store.save(500), isFalse);
  });

  test('a negative score is not saved', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ScoreStore();
    expect(await store.save(-10), isFalse);
    expect(await store.load(), 0);
  });
}
