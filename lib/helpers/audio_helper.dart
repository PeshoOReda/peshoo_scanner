// audio_helper.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioHelper {
  final AudioPlayer audioPlayer = AudioPlayer();
  final String soundPath = 'assets/vice_city_select.mp3';

  Future<void> preloadSound() async {
    try {
      await audioPlayer.setAsset(soundPath);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audio asset: $e');
      }
    }
  }

  void playSound() async {
    try {
      audioPlayer.play();
      Timer(Duration(milliseconds: 600), () {
        audioPlayer.stop();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
    }
  }
}
