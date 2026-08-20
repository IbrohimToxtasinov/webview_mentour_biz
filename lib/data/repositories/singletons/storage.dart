import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  static StorageRepository? _storageUtil;
  static SharedPreferences? _preferences;

  static Future<StorageRepository> getInstance() async {
    if (_storageUtil == null) {
      var secureStorage = StorageRepository._();
      await secureStorage._init();
      _storageUtil = secureStorage;
    }
    return _storageUtil!;
  }

  StorageRepository._();

  Future _init() async {
    try {
      _preferences = await SharedPreferences.getInstance();
    } catch (e) {
      print('StorageRepository initialization error: $e');
    }
  }

  static Future<bool>? putString(String key, String value) {
    debugPrint('writing $value');
    if (_preferences == null) return null;
    return _preferences!.setString(key, value);
  }

  static String getString(String key, {String defValue = ''}) {
    if (_preferences == null) return defValue;
    return _preferences!.getString(key) ?? defValue;
  }

  static Future<bool>? deleteString(String key) {
    if (_preferences == null) return null;
    return _preferences!.remove(key);
  }

  static Future<bool>? putList(String key, List<String> value) {
    debugPrint('writing $value');
    if (_preferences == null) return null;
    return _preferences!.setStringList(key, value);
  }

  static List<String> getList(String key, {List<String> defValue = const []}) {
    if (_preferences == null) return List.empty(growable: true);
    return _preferences!.getStringList(key) ?? List.empty(growable: true);
  }

  static Future<bool>? putDouble(String key, double value) {
    debugPrint('writing $value');
    if (_preferences == null) return null;
    return _preferences!.setDouble(key, value);
  }

  static double getDouble(String key, {double defValue = 0.0}) {
    if (_preferences == null) return defValue;
    return _preferences!.getDouble(key) ?? defValue;
  }

  static Future<bool>? deleteDouble(String key) {
    if (_preferences == null) return null;
    return _preferences!.remove(key);
  }

  static Future<bool>? putBool(String key, bool value) {
    if (_preferences == null) return null;
    return _preferences!.setBool(key, value);
  }

  static bool getBool(String key, {bool defValue = false}) {
    if (_preferences == null) return defValue;
    return _preferences!.getBool(key) ?? defValue;
  }

  static Future<bool>? deleteBool(String key) {
    if (_preferences == null) return null;
    return _preferences!.remove(key);
  }

  static Future<bool>? putInt(String key, int value) {
    debugPrint('writing $value');
    if (_preferences == null) return null;
    return _preferences!.setInt(key, value);
  }

  static int getInt(String key, {int defValue = 0}) {
    if (_preferences == null) return defValue;
    return _preferences!.getInt(key) ?? defValue;
  }

  static Future<bool>? deleteInt(String key) {
    if (_preferences == null) return null;
    return _preferences!.remove(key);
  }

  static Future<bool>? clear() {
    debugPrint('Clearing all stored data');
    if (_preferences == null) return null;
    return _preferences!.clear();
  }
}
