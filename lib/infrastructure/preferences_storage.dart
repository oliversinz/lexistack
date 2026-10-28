import 'package:shared_preferences/shared_preferences.dart';

import '../app/storage.dart';

class PreferencesStorage implements ProgressStorage {
  static const key = 'lexistack.progress';
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read() => _preferences.getString(key);
  @override
  Future<void> write(String document) => _preferences.setString(key, document);
}
