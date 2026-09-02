import 'package:flutter/material.dart';
import '../models/timer_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;
  late TimerSettings _settings;

  SettingsProvider(this._storageService) {
    _settings = _storageService.loadTimerSettings();
  }

  TimerSettings get settings => _settings;

  int get workDurationMinutes => _settings.workDurationMinutes;
  int get shortBreakDurationMinutes => _settings.shortBreakDurationMinutes;
  int get longBreakDurationMinutes => _settings.longBreakDurationMinutes;
  int get sessionsBeforeLongBreak => _settings.sessionsBeforeLongBreak;
  bool get soundEnabled => _settings.soundEnabled;
  bool get notificationsEnabled => _settings.notificationsEnabled;

  void updateSettings(TimerSettings newSettings) {
    _settings = newSettings;
    _storageService.saveTimerSettings(_settings);
    notifyListeners();
  }

  void updateWorkDuration(int minutes) {
    updateSettings(_settings.copyWith(workDurationMinutes: minutes));
  }

  void updateShortBreakDuration(int minutes) {
    updateSettings(_settings.copyWith(shortBreakDurationMinutes: minutes));
  }

  void updateLongBreakDuration(int minutes) {
    updateSettings(_settings.copyWith(longBreakDurationMinutes: minutes));
  }

  void updateSessionsBeforeLongBreak(int count) {
    updateSettings(_settings.copyWith(sessionsBeforeLongBreak: count));
  }

  void toggleSound(bool value) {
    updateSettings(_settings.copyWith(soundEnabled: value));
  }

  void toggleNotifications(bool value) {
    updateSettings(_settings.copyWith(notificationsEnabled: value));
  }
}
