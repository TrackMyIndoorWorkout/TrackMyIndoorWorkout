import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:soundpool/soundpool.dart';
import '../persistence/preferences.dart';

enum SoundEffect { Bleep, FlatBeep, TwoTone, ThreeTone }
final Map<SoundEffect, String> _soundAssetPaths = {
  SoundEffect.Bleep: "assets/bleep.mp3",
  SoundEffect.FlatBeep: "assets/flat_beep.mp3",
  SoundEffect.TwoTone: "assets/two_tone.mp3",
  SoundEffect.ThreeTone: "assets/three_tone.mp3",
};

class SoundService {
  Soundpool? _soundPool;

  Map<SoundEffect, int> _soundIds = {
    SoundEffect.Bleep: 0,
    SoundEffect.FlatBeep: 0,
    SoundEffect.TwoTone: 0,
    SoundEffect.ThreeTone: 0,
  };
  Map<SoundEffect, int> _streamIds = {
    SoundEffect.Bleep: 0,
    SoundEffect.FlatBeep: 0,
    SoundEffect.TwoTone: 0,
    SoundEffect.ThreeTone: 0,
  };
  Map<String, SoundEffect> _soundPreferences = {
    SOUND_EFFECT_BLEEP: SoundEffect.Bleep,
    SOUND_EFFECT_ONE_TONE: SoundEffect.FlatBeep,
    SOUND_EFFECT_TWO_TONE: SoundEffect.TwoTone,
    SOUND_EFFECT_THREE_TONE: SoundEffect.ThreeTone,
  };

  SoundService() {
    Get.putAsync<Soundpool>(() async {
      _soundPool = Soundpool.fromOptions(
          options: SoundpoolOptions(streamType: StreamType.music, maxStreams: 2));
      _soundAssetPaths.forEach((k, v) async {
        if ((_soundIds[k] ?? 0) <= 0) {
          var asset = await rootBundle.load(v);
          final soundId = await _soundPool?.load(asset) ?? 0;
          if (soundId > 0) {
            _soundIds.addAll({k: soundId});
          }
        }
      });

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
    final soundEffect = _soundPreferences[soundEffectString] ?? SoundEffect.Bleep;
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
    _soundIds.forEach((k, v) {
      stopSoundEffect(k);
    });
  }

  void updateVolume(newVolume) {
    _soundIds.forEach((k, v) {
      _soundPool?.setVolume(soundId: v, volume: newVolume / 100.0);
    });
  }
}
