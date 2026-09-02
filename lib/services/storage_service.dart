import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_log.dart';
import '../models/timer_settings.dart';

class StorageService {
  static const String _settingsKey = 'timer_settings';
  static const String _sessionLogsKey = 'session_logs';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _premiumUnlockedUntilKey = 'premium_unlocked_until';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Timer Settings
  TimerSettings loadTimerSettings() {
    final jsonStr = _prefs.getString(_settingsKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const TimerSettings();
    }
    try {
      return TimerSettings.fromJson(jsonStr);
    } catch (_) {
      return const TimerSettings();
    }
  }

  Future<bool> saveTimerSettings(TimerSettings settings) async {
    return await _prefs.setString(_settingsKey, settings.toJson());
  }

  // Theme Mode
  bool loadIsDarkMode() {
    return _prefs.getBool(_isDarkModeKey) ?? true; // default dark mode for soothing theme
  }

  Future<bool> saveIsDarkMode(bool isDark) async {
    return await _prefs.setBool(_isDarkModeKey, isDark);
  }

  // Session Logs
  List<SessionLog> loadSessionLogs() {
    final jsonList = _prefs.getStringList(_sessionLogsKey);
    if (jsonList == null) return [];
    final logs = <SessionLog>[];
    for (final str in jsonList) {
      try {
        logs.add(SessionLog.fromJson(str));
      } catch (_) {}
    }
    return logs;
  }

  Future<bool> saveSessionLog(SessionLog log) async {
    final currentLogs = loadSessionLogs();
    currentLogs.add(log);
    final stringList = currentLogs.map((l) => l.toJson()).toList();
    return await _prefs.setStringList(_sessionLogsKey, stringList);
  }

  // Premium Unlock (24 hours)
  DateTime? loadPremiumUnlockedUntil() {
    final millis = _prefs.getInt(_premiumUnlockedUntilKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<bool> savePremiumUnlockedUntil(DateTime until) async {
    return await _prefs.setInt(_premiumUnlockedUntilKey, until.millisecondsSinceEpoch);
  }
}
