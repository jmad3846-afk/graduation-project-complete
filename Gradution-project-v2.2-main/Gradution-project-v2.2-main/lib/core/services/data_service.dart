import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ems_op_room/core/localization/app_localization.dart';

class DataService {
  static const String _languageKey = 'app_language';
  static const String _themeKey = 'app_theme';
  static const String _missionsKey = 'missions_data';
  static const String _centersKey = 'centers_data';

  // Language Management
  Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
  }

  Future<AppLanguage> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey) ?? 'en';
    return savedCode == 'ar' ? AppLanguage.arabic : AppLanguage.english;
  }

  // Theme Management
  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Missions Data Management
  Future<void> saveMissions(List<Map<String, dynamic>> missions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_missionsKey, jsonEncode(missions));
  }

  Future<List<Map<String, dynamic>>> getSavedMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = prefs.getString(_missionsKey);
    if (missionsJson == null) {
      return _getDefaultMissions();
    }
    return List<Map<String, dynamic>>.from(jsonDecode(missionsJson));
  }

  List<Map<String, dynamic>> _getDefaultMissions() {
    return [
      {
        'id': '#1001',
        'type': 'حادث سير',
        'location': 'المزرعة',
        'time': 'منذ 5 د',
        'priority': 'high',
        'status': 'waiting',
        'assignedCenter': '',
      },
      {
        'id': '#1002',
        'type': 'احتشاء عضلة قلبية',
        'location': 'حي السلام',
        'time': 'منذ 15 د',
        'priority': 'high',
        'status': 'waiting',
        'assignedCenter': '',
      },
      {
        'id': '#1003',
        'type': 'حريق محدود',
        'location': 'الصناعة',
        'time': 'منذ 25 د',
        'priority': 'medium',
        'status': 'waiting',
        'assignedCenter': '',
      },
    ];
  }

  // Centers Data Management
  Future<void> saveCenters(List<Map<String, dynamic>> centers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_centersKey, jsonEncode(centers));
  }

  Future<List<Map<String, dynamic>>> getSavedCenters() async {
    final prefs = await SharedPreferences.getInstance();
    final centersJson = prefs.getString(_centersKey);
    if (centersJson == null) {
      return _getDefaultCenters();
    }
    return List<Map<String, dynamic>>.from(jsonDecode(centersJson));
  }

  List<Map<String, dynamic>> _getDefaultCenters() {
    return [
      {
        'name': 'Center 100',
        'activeTasks': 3,
        'teams': {'active': 12, 'busy': 8, 'available': 15},
        'location': 'المزرعة',
        'capacity': 35,
        'status': 'operational',
      },
      {
        'name': 'Center 115',
        'activeTasks': 1,
        'teams': {'active': 15, 'busy': 11, 'available': 13},
        'location': 'حي السلام',
        'capacity': 39,
        'status': 'operational',
      },
      {
        'name': 'Center 120',
        'activeTasks': 0,
        'teams': {'active': 8, 'busy': 2, 'available': 20},
        'location': 'الصناعة',
        'capacity': 30,
        'status': 'standby',
      },
    ];
  }

  // Utility Methods
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> resetToDefaults() async {
    await saveMissions(_getDefaultMissions());
    await saveCenters(_getDefaultCenters());
  }
}