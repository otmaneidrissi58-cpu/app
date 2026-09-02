import 'dart:convert';

class TimerSettings {
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int sessionsBeforeLongBreak;
  final bool soundEnabled;
  final bool notificationsEnabled;

  const TimerSettings({
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
  });

  TimerSettings copyWith({
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? sessionsBeforeLongBreak,
    bool? soundEnabled,
    bool? notificationsEnabled,
  }) {
    return TimerSettings(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes: shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes: longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workDurationMinutes': workDurationMinutes,
      'shortBreakDurationMinutes': shortBreakDurationMinutes,
      'longBreakDurationMinutes': longBreakDurationMinutes,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory TimerSettings.fromMap(Map<String, dynamic> map) {
    return TimerSettings(
      workDurationMinutes: (map['workDurationMinutes'] as num?)?.toInt() ?? 25,
      shortBreakDurationMinutes: (map['shortBreakDurationMinutes'] as num?)?.toInt() ?? 5,
      longBreakDurationMinutes: (map['longBreakDurationMinutes'] as num?)?.toInt() ?? 15,
      sessionsBeforeLongBreak: (map['sessionsBeforeLongBreak'] as num?)?.toInt() ?? 4,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimerSettings.fromJson(String source) =>
      TimerSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
