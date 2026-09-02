import 'package:flutter/material.dart';
import '../models/session_log.dart';
import '../services/storage_service.dart';

class DayFocusData {
  final String dayLabel; // e.g. 'Mon', 'Tue'
  final DateTime date;
  final int focusMinutes;

  DayFocusData({
    required this.dayLabel,
    required this.date,
    required this.focusMinutes,
  });
}

class StatsProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<SessionLog> _logs = [];

  StatsProvider(this._storageService) {
    _logs = _storageService.loadSessionLogs();
  }

  List<SessionLog> get logs => List.unmodifiable(_logs);

  int get totalFocusMinutesToday {
    final now = DateTime.now();
    return _logs
        .where((log) =>
            log.mode == SessionMode.work &&
            log.timestamp.year == now.year &&
            log.timestamp.month == now.month &&
            log.timestamp.day == now.day)
        .fold(0, (sum, log) => sum + log.durationMinutes);
  }

  int get totalFocusMinutesThisWeek {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return _logs
        .where((log) =>
            log.mode == SessionMode.work &&
            log.timestamp.isAfter(startOfWeek.subtract(const Duration(seconds: 1))))
        .fold(0, (sum, log) => sum + log.durationMinutes);
  }

  int get totalCompletedSessions {
    return _logs.where((log) => log.mode == SessionMode.work).length;
  }

  int get currentDailyStreak {
    final workLogs = _logs.where((l) => l.mode == SessionMode.work).toList();
    if (workLogs.isEmpty) return 0;

    final datesWithWork = workLogs
        .map((l) => DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (datesWithWork.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = todayDate;

    if (!datesWithWork.contains(todayDate)) {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      if (!datesWithWork.contains(yesterday)) {
        return 0;
      }
      checkDate = yesterday;
    }

    while (datesWithWork.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<DayFocusData> get last7DaysData {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final days = <DayFocusData>[];

    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final targetDate = todayDate.subtract(Duration(days: i));
      final dayMins = _logs
          .where((l) =>
              l.mode == SessionMode.work &&
              l.timestamp.year == targetDate.year &&
              l.timestamp.month == targetDate.month &&
              l.timestamp.day == targetDate.day)
          .fold(0, (sum, l) => sum + l.durationMinutes);

      days.add(DayFocusData(
        dayLabel: weekdayNames[targetDate.weekday - 1],
        date: targetDate,
        focusMinutes: dayMins,
      ));
    }

    return days;
  }

  Future<void> recordSession({
    required int durationMinutes,
    required SessionMode mode,
  }) async {
    final log = SessionLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      durationMinutes: durationMinutes,
      mode: mode,
    );
    _logs.add(log);
    await _storageService.saveSessionLog(log);
    notifyListeners();
  }
}
