import 'package:shared_preferences/shared_preferences.dart';

class CachedData {
  static late SharedPreferences sharedPreferences;
  CachedData._();
  static Future<void> cacheInitialization() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setData({
    required String key,
    required dynamic value,
  }) async {
    if (value is int) {
      await sharedPreferences.setInt(key, value);
      return true;
    } else if (value is double) {
      await sharedPreferences.setDouble(key, value);
      return true;
    } else if (value is bool) {
      await sharedPreferences.setBool(key, value);
      return true;
    } else if (value is String) {
      await sharedPreferences.setString(key, value);
      return true;
    } else {
      return false;
    }
  }

  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  //delete item
  static void deleteItem({required String key}) {
    sharedPreferences.remove(key);
  }

  //clear cache
  static void clearData() {
    sharedPreferences.clear();
  }
}
