import 'package:shared_preferences/shared_preferences.dart';

class NearbyStateStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _isDiscoveringKey = 'isDiscovering';
  static const _isAdvertisingKey = 'isAdvertising';

  static bool getIsDiscovering() {
    return _prefs?.getBool(_isDiscoveringKey) ?? false;
  }

  static Future<void> setIsDiscovering(bool value) async {
    await _prefs?.setBool(_isDiscoveringKey, value);
  }

  static bool getIsAdvertising() {
    return _prefs?.getBool(_isAdvertisingKey) ?? false;
  }

  static Future<void> setIsAdvertising(bool value) async {
    await _prefs?.setBool(_isAdvertisingKey, value);
  }

  static Future<void> clearNearbyState() async {
    await _prefs?.remove(_isDiscoveringKey);
    await _prefs?.remove(_isAdvertisingKey);
  }
}
