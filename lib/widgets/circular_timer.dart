import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/session_log.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';

class CircularTimerWidget extends StatefulWidget {
  const CircularTimerWidget({super.key});

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    Color progressColor;
    switch (timerProvider.currentMode) {
      case SessionMode.work:
        progressColor = theme.colorScheme.primary;
        break;
      case SessionMode.shortBreak:
        progressColor = theme.colorScheme.secondary;
        break;
      case SessionMode.longBreak:
        progressColor = const Color(0xFFF59E0B); // Amber warmth
        break;
    }

    final isRunning = timerProvider.timerState == TimerState.running;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mode Tag Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: progressColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: progressColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            timerProvider.currentMode.label.toUpperCase(),
            style: TextStyle(
              color: progressColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Circular Timer Display
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = isRunning
                ? 1.0 + (_pulseController.value * 0.015)
                : 1.0;
            return Transform.scale(
              scale: scale,
              child: CircularPercentIndicator(
                radius: 140.0,
                lineWidth: 12.0,
                percent: timerProvider.progress,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                progressColor: progressColor,
                animation: false,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerProvider.formattedTime,
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1.0,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRunning
                          ? 'FOCUSING'
                          : (timerProvider.timerState == TimerState.paused
                              ? 'PAUSED'
                              : 'READY'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Sessions indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            settingsProvider.sessionsBeforeLongBreak,
            (index) {
              final isCompleted = index < timerProvider.completedSessionsCount;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isCompleted ? 12 : 8,
                height: isCompleted ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? progressColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
