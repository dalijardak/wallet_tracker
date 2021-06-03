// Here we store our config (Hash,Currency) into Shared Preferences

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveConfig({String hash, String currency}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("hash", hash);
  await prefs.setString("currency", currency);
}

Future<String> loadHash() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("hash");
}

Future<String> loadCurrency() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.get("currency");
}
