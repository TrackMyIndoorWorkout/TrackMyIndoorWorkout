import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:soundpool/soundpool.dart';
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
  Soundpool? _soundPool;

  final Map<SoundEffect, int> _soundIds = {
    SoundEffect.bleep: 0,
    SoundEffect.flatBeep: 0,
    SoundEffect.twoTone: 0,
    SoundEffect.threeTone: 0,
  };
  final Map<SoundEffect, int> _streamIds = {
    SoundEffect.bleep: 0,
    SoundEffect.flatBeep: 0,
    SoundEffect.twoTone: 0,
    SoundEffect.threeTone: 0,
  };
  final Map<String, SoundEffect> _soundPreferences = {
    soundEffectBleep: SoundEffect.bleep,
    soundEffectOneTone: SoundEffect.flatBeep,
    soundEffectTwoTone: SoundEffect.twoTone,
    soundEffectThreeTone: SoundEffect.threeTone,
  };

  SoundService() {
    Get.putAsync<Soundpool>(() async {
      _soundPool = Soundpool.fromOptions(
          options: const SoundpoolOptions(streamType: StreamType.music, maxStreams: 2));
      for (var entry in _soundAssetPaths.entries) {
        if ((_soundIds[entry.key] ?? 0) <= 0) {
          var asset = await rootBundle.load(entry.value);
          final soundId = await _soundPool?.load(asset) ?? 0;
          if (soundId > 0) {
            _soundIds.addAll({entry.key: soundId});
          }
        }
      }

      return _soundPool!;
    }, permanent: true);
  }

  Future<int> playSoundEffect(SoundEffect soundEffect) async {
    final soundId = _soundIds[soundEffect] ?? 0;
    if (soundId <= 0) {
      return 0;
    }

    final prefService = Get.find<BasePrefService>();
    final volumePercent = prefService.get<int>(audioVolumeIntTag) ?? audioVolumeDefault;
    final volume = volumePercent / 100.0;
    _soundPool?.setVolume(soundId: soundId, volume: volume);
    final streamId = await _soundPool?.play(soundId) ?? 0;
    if (streamId > 0) {
      _streamIds.addAll({soundEffect: streamId});
      _soundPool?.setVolume(streamId: streamId, volume: volume);
    }

    return streamId;
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

  void stopSoundEffect(SoundEffect soundEffect) {
    final streamId = _streamIds[soundEffect] ?? 0;
    if (streamId > 0) {
      _soundPool?.stop(streamId);
      _streamIds[soundEffect] = 0;
    }
  }

  void stopAllSoundEffects() {
    for (var entry in _soundIds.entries) {
      stopSoundEffect(entry.key);
    }
  }

  void updateVolume(newVolume) {
    for (var entry in _soundIds.entries) {
      _soundPool?.setVolume(soundId: entry.value, volume: newVolume / 100.0);
    }
  }
}
