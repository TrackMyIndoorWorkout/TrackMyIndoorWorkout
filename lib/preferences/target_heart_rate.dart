import 'generic.dart';
import 'sound_effects.dart';

const targetHeartRateMode = "Target Heart Rate Mode:";
const targetHeartRateModeTag = "target_heart_rate_mode";
const targetHeartRateModeDescription =
    "You can configure target heart rate BPM range or zone range. "
    "The app will alert visually (and optionally audio as well) when you are outside of the range. "
    "The lower and upper zone can be the same if you want to target just one zone.";
const targetHeartRateModeNone = "none";
const targetHeartRateModeNoneDescription = "Target heart rate alert is turned off";
const targetHeartRateModeBpm = "bpm";
const targetHeartRateModeBpmDescription =
    "Bounds are specified by explicit beat per minute numbers";
const targetHeartRateModeZones = "zones";
const targetHeartRateModeZonesDescription = "Bounds are specified by HR zone numbers";
const targetHeartRateModeDefault = targetHeartRateModeNone;

const targetHeartRateLowerBpm = "Target Heart Rate Lower BPM";
const targetHeartRateLowerBpmTag = "target_heart_rate_bpm_lower";
const targetHeartRateLowerBpmIntTag = targetHeartRateLowerBpmTag + intTagPostfix;
const targetHeartRateLowerBpmMin = 0;
const targetHeartRateLowerBpmDefault = 120;
const targetHeartRateLowerBpmDescription =
    "Lower bpm of the target heart rate (for bpm target mode).";

const targetHeartRateUpperBpm = "Target Heart Rate Upper BPM";
const targetHeartRateUpperBpmTag = "target_heart_rate_bpm_upper";
const targetHeartRateUpperBpmIntTag = targetHeartRateUpperBpmTag + intTagPostfix;
const targetHeartRateUpperBpmDefault = 140;
const targetHeartRateUpperBpmMax = 300;
const targetHeartRateUpperBpmDescription =
    "Upper bpm of the target heart rate (for bpm target mode).";

const targetHeartRateLowerZone = "Target Heart Rate Lower Zone";
const targetHeartRateLowerZoneTag = "target_heart_rate_zone_lower";
const targetHeartRateLowerZoneIntTag = targetHeartRateLowerZoneTag + intTagPostfix;
const targetHeartRateLowerZoneMin = 0;
const targetHeartRateLowerZoneDefault = 3;
const targetHeartRateLowerZoneDescription =
    "Lower zone of the target heart rate (for zone target mode).";

const targetHeartRateUpperZone = "Target Heart Rate Upper Zone";
const targetHeartRateUpperZoneTag = "target_heart_rate_zone_upper";
const targetHeartRateUpperZoneIntTag = targetHeartRateUpperZoneTag + intTagPostfix;
const targetHeartRateUpperZoneDefault = 3;
const targetHeartRateUpperZoneMax = 7;
const targetHeartRateUpperZoneDescription =
    "Upper zone of the target heart rate (for zone target mode).";

const targetHeartRateAudio = "Target Heart Rate Audio";
const targetHeartRateAudioTag = "target_heart_rate_audio";
const targetHeartRateAudioDefault = false;
const targetHeartRateAudioDescription = "Should a sound effect play when HR is out of range.";

const targetHeartRateAudioPeriod = "Target HR Audio Period (seconds)";
const targetHeartRateAudioPeriodTag = "target_heart_rate_audio_period";
const targetHeartRateAudioPeriodIntTag = targetHeartRateAudioPeriodTag + intTagPostfix;
const targetHeartRateAudioPeriodMin = 0;
const targetHeartRateAudioPeriodDefault = 0;
const targetHeartRateAudioPeriodMax = 10;
const targetHeartRateAudioPeriodDescription = "0 or 1: no periodicity. Larger than 1 seconds: "
    "the selected sound effect will play with the periodicity until the HR is back in range.";

const targetHeartRateSoundEffect = "Target Heart Rate Out of Range Sound Effect:";
const targetHeartRateSoundEffectTag = "target_heart_rate_sound_effect";
const targetHeartRateSoundEffectDescription =
    "Select the type of sound effect played when the HR gets out of range:";
const targetHeartRateSoundEffectDefault = soundEffectTwoTone;
