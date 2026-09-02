import 'dart:convert';

enum SessionMode { work, shortBreak, longBreak }

extension SessionModeExtension on SessionMode {
  String get label {
    switch (this) {
      case SessionMode.work:
        return 'Focus';
      case SessionMode.shortBreak:
        return 'Short Break';
      case SessionMode.longBreak:
        return 'Long Break';
    }
  }

  String get key => name;

  static SessionMode fromKey(String key) {
    return SessionMode.values.firstWhere(
      (e) => e.name == key,
      orElse: () => SessionMode.work,
    );
  }
}

class SessionLog {
  final String id;
  final DateTime timestamp;
  final int durationMinutes;
  final SessionMode mode;

  SessionLog({
    required this.id,
    required this.timestamp,
    required this.durationMinutes,
    required this.mode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'durationMinutes': durationMinutes,
      'mode': mode.key,
    };
  }

  factory SessionLog.fromMap(Map<String, dynamic> map) {
    return SessionLog(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      mode: SessionModeExtension.fromKey(map['mode'] as String? ?? 'work'),
    );
  }

  String toJson() => json.encode(toMap());

  factory SessionLog.fromJson(String source) =>
      SessionLog.fromMap(json.decode(source) as Map<String, dynamic>);
}
