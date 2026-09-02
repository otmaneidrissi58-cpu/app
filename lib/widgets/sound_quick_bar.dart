import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sound_provider.dart';

class SoundQuickBar extends StatelessWidget {
  final VoidCallback onOpenMixer;
  final VoidCallback onOpenRewardedAd;

  const SoundQuickBar({
    super.key,
    required this.onOpenMixer,
    required this.onOpenRewardedAd,
  });

  @override
  Widget build(BuildContext context) {
    final soundProvider = context.watch<SoundProvider>();
    final tracks = soundProvider.tracks;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sound Tracks Horizontal List
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tracks.map((track) {
                  final isPlaying = track.isPlaying;
                  final isLocked = track.isPremium && !soundProvider.isPremiumUnlocked;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        if (isLocked) {
                          onOpenRewardedAd();
                        } else {
                          soundProvider.toggleTrack(track.id);
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPlaying
                                  ? theme.colorScheme.primary
                                  : (isLocked
                                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                                      : theme.colorScheme.surfaceContainerHighest),
                              border: Border.all(
                                color: isPlaying
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  track.icon,
                                  size: 22,
                                  color: isPlaying
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface.withValues(alpha: isLocked ? 0.4 : 0.7),
                                ),
                                if (isLocked)
                                  const Positioned(
                                    right: 2,
                                    bottom: 2,
                                    child: Icon(
                                      Icons.lock,
                                      size: 12,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w400,
                              color: isPlaying
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 32,
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 8),
          // Mixer Button
          IconButton(
            onPressed: onOpenMixer,
            tooltip: 'Sound Mixer',
            icon: Icon(
              Icons.tune,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
