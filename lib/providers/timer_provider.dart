import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_log.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import 'settings_provider.dart';
import 'stats_provider.dart';

enum TimerState { idle, running, paused }

class TimerProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final AudioService _audioService;
  SettingsProvider _settingsProvider;
  StatsProvider _statsProvider;

  SessionMode _currentMode = SessionMode.work;
  TimerState _timerState = TimerState.idle;

  int _totalSeconds = 25 * 60;
  int _secondsRemaining = 25 * 60;
  int _completedSessionsCount = 0;

  Timer? _ticker;
  DateTime? _targetEndTime;

  bool _justCompletedSession = false;

  TimerProvider(
    this._notificationService,
    this._audioService,
    this._settingsProvider,
    this._statsProvider,
  ) {
    _resetToCurrentModeDuration();
  }

  void updateDependencies(SettingsProvider settings, StatsProvider stats) {
    _settingsProvider = settings;
    _statsProvider = stats;
    if (_timerState == TimerState.idle) {
      _resetToCurrentModeDuration();
    }
  }

  SessionMode get currentMode => _currentMode;
  TimerState get timerState => _timerState;
  int get totalSeconds => _totalSeconds;
  int get secondsRemaining => _secondsRemaining;
  int get completedSessionsCount => _completedSessionsCount;
  bool get justCompletedSession => _justCompletedSession;

  double get progress {
    if (_totalSeconds == 0) return 0.0;
    final p = 1.0 - (_secondsRemaining / _totalSeconds);
    return p.clamp(0.0, 1.0);
  }

  String get formattedTime {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    final minStr = mins.toString().padLeft(2, '0');
    final secStr = secs.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  void _resetToCurrentModeDuration() {
    switch (_currentMode) {
      case SessionMode.work:
        _totalSeconds = _settingsProvider.workDurationMinutes * 60;
        break;
      case SessionMode.shortBreak:
        _totalSeconds = _settingsProvider.shortBreakDurationMinutes * 60;
        break;
      case SessionMode.longBreak:
        _totalSeconds = _settingsProvider.longBreakDurationMinutes * 60;
        break;
    }
    _secondsRemaining = _totalSeconds;
    notifyListeners();
  }

  void startTimer() {
    if (_timerState == TimerState.running) return;

    _timerState = TimerState.running;
    _justCompletedSession = false;
    _targetEndTime = DateTime.now().add(Duration(seconds: _secondsRemaining));

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });

    notifyListeners();
  }

  void pauseTimer() {
    if (_timerState != TimerState.running) return;

    _ticker?.cancel();
    _timerState = TimerState.paused;
    _targetEndTime = null;
    notifyListeners();
  }

  void skipTimer() {
    _ticker?.cancel();
    _timerState = TimerState.idle;
    _targetEndTime = null;
    _justCompletedSession = false;

    _advanceToNextMode(isCompleted: false);
  }

  void _onTick() {
    if (_targetEndTime == null) return;

    final diff = _targetEndTime!.difference(DateTime.now()).inSeconds;
    if (diff <= 0) {
      _secondsRemaining = 0;
      _onSessionCompleted();
    } else {
      _secondsRemaining = diff;
      notifyListeners();
    }
  }

  // Called on App Lifecycle Resume to adjust timer state accurately
  void updateOnAppResume() {
    if (_timerState == TimerState.running && _targetEndTime != null) {
      final diff = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        _secondsRemaining = 0;
        _onSessionCompleted();
      } else {
        _secondsRemaining = diff;
        notifyListeners();
      }
    }
  }

  void _onSessionCompleted() {
    _ticker?.cancel();
    _timerState = TimerState.idle;
    _targetEndTime = null;
    _justCompletedSession = true;

    final durationMins = _totalSeconds ~/ 60;

    // Log Session
    _statsProvider.recordSession(
      durationMinutes: durationMins,
      mode: _currentMode,
    );

    // Audio Chime
    if (_settingsProvider.soundEnabled) {
      _audioService.playSessionCompleteChime();
    }

    // Local Notification
    if (_settingsProvider.notificationsEnabled) {
      final title = _currentMode == SessionMode.work
          ? 'Focus Session Completed! 🎉'
          : 'Break Finished! ⚡';
      final body = _currentMode == SessionMode.work
          ? 'Great job staying focused. Time for a restful break.'
          : 'Ready to dive back into deep work?';
      _notificationService.showSessionCompleteNotification(
        title: title,
        body: body,
      );
    }

    _advanceToNextMode(isCompleted: true);
  }

  void _advanceToNextMode({required bool isCompleted}) {
    if (_currentMode == SessionMode.work) {
      if (isCompleted) {
        _completedSessionsCount++;
      }

      if (_completedSessionsCount >= _settingsProvider.sessionsBeforeLongBreak) {
        _currentMode = SessionMode.longBreak;
        _completedSessionsCount = 0;

        // Show Interstitial Ad when reaching long break after 4 sessions
        AdService.instance.showInterstitialAd();
      } else {
        _currentMode = SessionMode.shortBreak;
      }
    } else {
      _currentMode = SessionMode.work;
    }

    _resetToCurrentModeDuration();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
