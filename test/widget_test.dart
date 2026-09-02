import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/models/session_log.dart';
import 'package:focus_flow/models/sound_track.dart';
import 'package:focus_flow/models/timer_settings.dart';

void main() {
  group('FocusFlow Model Tests', () {
    test('TimerSettings defaults and copyWith', () {
      const settings = TimerSettings();
      expect(settings.workDurationMinutes, 25);
      expect(settings.shortBreakDurationMinutes, 5);
      expect(settings.longBreakDurationMinutes, 15);
      expect(settings.sessionsBeforeLongBreak, 4);
      expect(settings.soundEnabled, true);
      expect(settings.notificationsEnabled, true);

      final updated = settings.copyWith(workDurationMinutes: 30, soundEnabled: false);
      expect(updated.workDurationMinutes, 30);
      expect(updated.soundEnabled, false);
      expect(updated.shortBreakDurationMinutes, 5);
    });

    test('SessionLog serialization', () {
      final log = SessionLog(
        id: 'test-123',
        timestamp: DateTime(2026, 8, 25, 10, 0),
        durationMinutes: 25,
        mode: SessionMode.work,
      );

      final jsonStr = log.toJson();
      final restored = SessionLog.fromJson(jsonStr);

      expect(restored.id, 'test-123');
      expect(restored.durationMinutes, 25);
      expect(restored.mode, SessionMode.work);
    });

    test('SoundTrack default tracks list', () {
      final tracks = SoundTrack.defaultTracks;
      expect(tracks.length, 8);

      final freeTracks = tracks.where((t) => !t.isPremium).toList();
      final premiumTracks = tracks.where((t) => t.isPremium).toList();

      expect(freeTracks.length, 5);
      expect(premiumTracks.length, 3);
    });
  });
}
