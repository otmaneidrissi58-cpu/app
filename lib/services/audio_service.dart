import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final Map<String, AudioPlayer> _players = {};
  AudioPlayer? _chimePlayer;

  Future<void> playTrack(String soundId, String assetPath, double volume) async {
    try {
      if (_players.containsKey(soundId)) {
        await _players[soundId]!.stop();
      } else {
        _players[soundId] = AudioPlayer();
      }

      final player = _players[soundId]!;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(volume.clamp(0.0, 1.0));
      // Remove 'assets/' prefix if AudioPlayer AssetSource adds it, standard audioplayers uses relative path within assets
      final cleanPath = assetPath.startsWith('assets/')
          ? assetPath.substring(7)
          : assetPath;
      await player.play(AssetSource(cleanPath));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing track $soundId: $e');
      }
    }
  }

  Future<void> updateVolume(String soundId, double volume) async {
    try {
      if (_players.containsKey(soundId)) {
        await _players[soundId]!.setVolume(volume.clamp(0.0, 1.0));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating volume for $soundId: $e');
      }
    }
  }

  Future<void> stopTrack(String soundId) async {
    try {
      if (_players.containsKey(soundId)) {
        await _players[soundId]!.stop();
        await _players[soundId]!.dispose();
        _players.remove(soundId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping track $soundId: $e');
      }
    }
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      try {
        await player.stop();
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
  }

  Future<void> playSessionCompleteChime() async {
    try {
      _chimePlayer ??= AudioPlayer();
      await _chimePlayer!.stop();
      await _chimePlayer!.setVolume(0.8);
      await _chimePlayer!.play(AssetSource('sounds/white_noise.wav'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing complete chime: $e');
      }
    }
  }

  void dispose() {
    stopAll();
    _chimePlayer?.dispose();
  }
}
