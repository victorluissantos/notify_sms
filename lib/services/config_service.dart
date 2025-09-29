import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sms_config.dart';

class ConfigService {
  static const String _configKey = 'sms_config';

  static Future<void> saveConfig(SMSConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = config.toJson();
    await prefs.setString(_configKey, jsonEncode(configJson));
  }

  static Future<SMSConfig?> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configString = prefs.getString(_configKey);
      
      if (configString != null) {
        final configJson = jsonDecode(configString) as Map<String, dynamic>;
        return SMSConfig.fromJson(configJson);
      }
    } catch (e) {
      // Em caso de erro, retorna null
    }
    return null;
  }

  static Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configKey);
  }
}
