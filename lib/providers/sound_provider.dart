import 'package:flutter/material.dart';
import '../models/sound_track.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class SoundProvider extends ChangeNotifier {
  final AudioService _audioService;
  final StorageService _storageService;

  List<SoundTrack> _tracks = [];
  DateTime? _premiumUnlockedUntil;

  SoundProvider(this._audioService, this._storageService) {
    _tracks = SoundTrack.defaultTracks;
    _premiumUnlockedUntil = _storageService.loadPremiumUnlockedUntil();
  }

  List<SoundTrack> get tracks => List.unmodifiable(_tracks);

  bool get isPremiumUnlocked {
    if (_premiumUnlockedUntil == null) return false;
    return DateTime.now().isBefore(_premiumUnlockedUntil!);
  }

  Duration get premiumTimeRemaining {
    if (!isPremiumUnlocked || _premiumUnlockedUntil == null) return Duration.zero;
    return _premiumUnlockedUntil!.difference(DateTime.now());
  }

  bool isTrackPlaying(String id) {
    final track = _tracks.firstWhere((t) => t.id == id, orElse: () => _tracks.first);
    return track.isPlaying;
  }

  double getTrackVolume(String id) {
    final track = _tracks.firstWhere((t) => t.id == id, orElse: () => _tracks.first);
    return track.volume;
  }

  Future<void> toggleTrack(String id) async {
    final index = _tracks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final track = _tracks[index];

    // Premium check
    if (track.isPremium && !isPremiumUnlocked) {
      notifyListeners();
      return;
    }

    final newIsPlaying = !track.isPlaying;
    _tracks[index] = track.copyWith(isPlaying: newIsPlaying);

    if (newIsPlaying) {
      await _audioService.playTrack(track.id, track.assetPath, track.volume);
    } else {
      await _audioService.stopTrack(track.id);
    }
    notifyListeners();
  }

  Future<void> setVolume(String id, double volume) async {
    final index = _tracks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final track = _tracks[index];
    _tracks[index] = track.copyWith(volume: volume);

    if (track.isPlaying) {
      await _audioService.updateVolume(track.id, volume);
    }
    notifyListeners();
  }

  Future<void> stopAll() async {
    for (int i = 0; i < _tracks.length; i++) {
      if (_tracks[i].isPlaying) {
        _tracks[i] = _tracks[i].copyWith(isPlaying: false);
      }
    }
    await _audioService.stopAll();
    notifyListeners();
  }

  Future<void> unlockPremiumFor24Hours() async {
    final unlockUntil = DateTime.now().add(const Duration(hours: 24));
    _premiumUnlockedUntil = unlockUntil;
    await _storageService.savePremiumUnlockedUntil(unlockUntil);
    notifyListeners();
  }
}
