import 'package:flutter/material.dart';

class SoundTrack {
  final String id;
  final String name;
  final String assetPath;
  final IconData icon;
  final bool isPremium;
  double volume;
  bool isPlaying;

  SoundTrack({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.icon,
    this.isPremium = false,
    this.volume = 0.5,
    this.isPlaying = false,
  });

  SoundTrack copyWith({
    double? volume,
    bool? isPlaying,
  }) {
    return SoundTrack(
      id: id,
      name: name,
      assetPath: assetPath,
      icon: icon,
      isPremium: isPremium,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  static List<SoundTrack> get defaultTracks => [
        SoundTrack(
          id: 'rain',
          name: 'Rain',
          assetPath: 'assets/sounds/rain.wav',
          icon: Icons.water_drop_outlined,
          isPremium: false,
        ),
        SoundTrack(
          id: 'cafe',
          name: 'Cafe',
          assetPath: 'assets/sounds/cafe.wav',
          icon: Icons.local_cafe_outlined,
          isPremium: false,
        ),
        SoundTrack(
          id: 'fire',
          name: 'Fire',
          assetPath: 'assets/sounds/fire.wav',
          icon: Icons.local_fire_department_outlined,
          isPremium: false,
        ),
        SoundTrack(
          id: 'ocean',
          name: 'Ocean',
          assetPath: 'assets/sounds/ocean.wav',
          icon: Icons.waves,
          isPremium: false,
        ),
        SoundTrack(
          id: 'white_noise',
          name: 'White Noise',
          assetPath: 'assets/sounds/white_noise.wav',
          icon: Icons.graphic_eq,
          isPremium: false,
        ),
        // Premium Tracks (Unlocked for 24h via Rewarded Ad)
        SoundTrack(
          id: 'forest',
          name: 'Forest',
          assetPath: 'assets/sounds/forest.wav',
          icon: Icons.park_outlined,
          isPremium: true,
        ),
        SoundTrack(
          id: 'thunderstorm',
          name: 'Thunder',
          assetPath: 'assets/sounds/thunderstorm.wav',
          icon: Icons.thunderstorm_outlined,
          isPremium: true,
        ),
        SoundTrack(
          id: 'night_wind',
          name: 'Night Wind',
          assetPath: 'assets/sounds/night_wind.wav',
          icon: Icons.air,
          isPremium: true,
        ),
      ];
}
