import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../preferences/audio_volume.dart';
import '../preferences/data_stream_gap_sound_effect.dart';
import '../preferences/sound_effects.dart';
import '../preferences/target_heart_rate.dart';

enum SoundEffect { bleep, flatBeep, twoTone, threeTone }

final Map<SoundEffect, String> _soundAssetPaths = {
  SoundEffect.bleep: "assets/audio/bleep.mp3",
  SoundEffect.flatBeep: "assets/audio/flat_beep.mp3",
  SoundEffect.twoTone: "assets/audio/two_tone.mp3",
  SoundEffect.threeTone: "assets/audio/three_tone.mp3",
};

class SoundService {
  late AudioPlayer _audioPlayer;

  final Map<SoundEffect, AssetSource> _soundCache = {
  };
  final Map<String, SoundEffect> _soundPreferences = {
    soundEffectBleep: SoundEffect.bleep,
    soundEffectOneTone: SoundEffect.flatBeep,
    soundEffectTwoTone: SoundEffect.twoTone,
    soundEffectThreeTone: SoundEffect.threeTone,
  };

  SoundService() {
    _audioPlayer = AudioPlayer();
    Get.putAsync<AudioPlayer>(() async {
      for (var entry in _soundAssetPaths.entries) {
        if (!_soundCache.containsKey(entry.key)) {
          final soundSource = AssetSource(entry.value);
          _soundCache.addAll({entry.key: soundSource});
        }
      }

      return _audioPlayer;
    }, permanent: true);
  }

  Future<int> playSoundEffect(SoundEffect soundEffect) async {
    if (!_soundCache.containsKey(soundEffect)) {
      return 0;
    }

    final prefService = Get.find<BasePrefService>();
    final volumePercent = prefService.get<int>(audioVolumeIntTag) ?? audioVolumeDefault;
    final volume = volumePercent / 100.0;
    await _audioPlayer.play(_soundCache[soundEffect]!, volume: volume);
    return 1;
  }

  Future<int> playSpecificSoundEffect(String soundEffectString) async {
    final soundEffect = _soundPreferences[soundEffectString] ?? SoundEffect.bleep;
    return await playSoundEffect(soundEffect);
  }

  Future<int> playTargetHrSoundEffect() async {
    final prefService = Get.find<BasePrefService>();
    final soundEffectString =
        prefService.get<String>(targetHeartRateSoundEffectTag) ?? targetHeartRateSoundEffectDefault;
    return await playSpecificSoundEffect(soundEffectString);
  }

  Future<int> playDataTimeoutSoundEffect() async {
    final prefService = Get.find<BasePrefService>();
    final soundEffectString =
        prefService.get<String>(dataStreamGapSoundEffectTag) ?? dataStreamGapSoundEffectDefault;
    if (soundEffectString == soundEffectNone) {
      return 0;
    }

    return await playSpecificSoundEffect(soundEffectString);
  }

  void stopSoundEffect() {
    _audioPlayer.stop();
  }
}
