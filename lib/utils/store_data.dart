import 'package:shared_preferences/shared_preferences.dart';

void storeData(String key, String value) async {
  final pref = await SharedPreferences.getInstance();
  pref.setString(key, value);
}
