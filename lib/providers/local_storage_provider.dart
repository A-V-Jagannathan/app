import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageModel {
  final SharedPreferences preferences;

  LocalStorageModel(this.preferences);

  Future<bool> setPreference<T>(String key, T value) async {
    bool result = false;
    switch (value) {
      case String _:
        result = await preferences.setString(key, value as String);
      case int _:
        result = await preferences.setInt(key, value as int);
      case double _:
        result = await preferences.setDouble(key, value as double);
      case bool _:
        result = await preferences.setBool(key, value as bool);
      case List<String> _:
        result = await preferences.setStringList(key, value as List<String>);
      default:
        result = false;
    }
    return result;
  }

  T? getPreference<T>(String key) {
    return preferences.get(key) as T?;
  }
}
