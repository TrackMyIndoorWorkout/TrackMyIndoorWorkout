import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:soundpool/soundpool.dart';
import '../persistence/preferences.dart';

enum SoundEffect { bleep, flatBeep, twoTone, threeTone }
final Map<SoundEffect, String> _soundAssetPaths = {
  SoundEffect.bleep: "assets/bleep.mp3",
  SoundEffect.flatBeep: "assets/flat_beep.mp3",
  SoundEffect.twoTone: "assets/two_tone.mp3",
  SoundEffect.threeTone: "assets/three_tone.mp3",
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
    SOUND_EFFECT_BLEEP: SoundEffect.bleep,
    SOUND_EFFECT_ONE_TONE: SoundEffect.flatBeep,
    SOUND_EFFECT_TWO_TONE: SoundEffect.twoTone,
    SOUND_EFFECT_THREE_TONE: SoundEffect.threeTone,
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
    });
  }

  Future<int> playSoundEffect(SoundEffect soundEffect) async {
    final soundId = _soundIds[soundEffect] ?? 0;
    if (soundId <= 0) {
      return 0;
    }

    final prefService = Get.find<BasePrefService>();
    final volumePercent = prefService.get<int>(AUDIO_VOLUME_INT_TAG) ?? AUDIO_VOLUME_DEFAULT;
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
    final soundEffectString = prefService.get<String>(TARGET_HEART_RATE_SOUND_EFFECT_TAG) ??
        TARGET_HEART_RATE_SOUND_EFFECT_DEFAULT;
    return await playSpecificSoundEffect(soundEffectString);
  }

  Future<int> playDataTimeoutSoundEffect() async {
    final prefService = Get.find<BasePrefService>();
    final soundEffectString = prefService.get<String>(DATA_STREAM_GAP_SOUND_EFFECT_TAG) ??
        DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT;
    if (soundEffectString == SOUND_EFFECT_NONE) {
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
