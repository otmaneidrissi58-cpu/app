import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sound_provider.dart';
import '../providers/timer_provider.dart';
import '../services/ad_service.dart';
import '../widgets/circular_timer.dart';
import '../widgets/sound_mixer_bottom_sheet.dart';
import '../widgets/sound_quick_bar.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  void _showRewardedAd(BuildContext context) {
    final soundProvider = context.read<SoundProvider>();
    AdService.instance.showRewardedAd(
      onUserEarnedReward: (reward) {
        soundProvider.unlockPremiumFor24Hours();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Premium Sounds Unlocked for 24 Hours!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad could not be loaded. Please try again later.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _openMixerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoundMixerBottomSheet(
        onWatchRewardedAd: () {
          Navigator.of(ctx).pop();
          _showRewardedAd(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final theme = Theme.of(context);
    final isRunning = timerProvider.timerState == TimerState.running;
    final isPaused = timerProvider.timerState == TimerState.paused;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Title
            Text(
              'FocusFlow',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Distraction-free Pomodoro',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),

            // Main Animated Circular Timer
            const CircularTimerWidget(),

            const Spacer(),

            // Control Buttons (Start / Pause / Skip)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip Button
                if (isRunning || isPaused)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: IconButton.filledTonal(
                      onPressed: () {
                        timerProvider.skipTimer();
                      },
                      iconSize: 24,
                      padding: const EdgeInsets.all(16),
                      icon: const Icon(Icons.skip_next_rounded),
                      tooltip: 'Skip Session',
                    ),
                  ),

                // Primary Start/Pause Button
                GestureDetector(
                  onTap: () {
                    if (isRunning) {
                      timerProvider.pauseTimer();
                    } else {
                      timerProvider.startTimer();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
                    decoration: BoxDecoration(
                      color: isRunning
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: (isRunning
                                  ? Colors.grey
                                  : theme.colorScheme.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 28,
                          color: isRunning
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isRunning ? 'PAUSE' : (isPaused ? 'RESUME' : 'START FOCUS'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: isRunning
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Quick Access Sound Bar at Bottom
            SoundQuickBar(
              onOpenMixer: () => _openMixerBottomSheet(context),
              onOpenRewardedAd: () => _showRewardedAd(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
