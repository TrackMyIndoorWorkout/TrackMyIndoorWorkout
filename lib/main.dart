import 'dart:io';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'ui/models/advertisement_cache.dart';
import 'devices/company_registry.dart';
import 'persistence/preferences.dart';
import 'tcx/activity_type.dart';
import 'utils/preferences.dart';
import 'track_my_indoor_exercise_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await PrefService.init(prefix: 'pref_');
  Map<String, dynamic> prefDefaults = {
    PREFERENCES_VERSION_TAG: PREFERENCES_VERSION_DEFAULT,
    UNIT_SYSTEM_TAG: UNIT_SYSTEM_DEFAULT,
    INSTANT_SCAN_TAG: INSTANT_SCAN_DEFAULT,
    SCAN_DURATION_TAG: SCAN_DURATION_DEFAULT,
    AUTO_CONNECT_TAG: AUTO_CONNECT_DEFAULT,
    INSTANT_MEASUREMENT_START_TAG: INSTANT_MEASUREMENT_START_DEFAULT,
    INSTANT_UPLOAD_TAG: INSTANT_UPLOAD_DEFAULT,
    SIMPLER_UI_TAG: await getSimplerUiDefault(),
    DEVICE_FILTERING_TAG: DEVICE_FILTERING_DEFAULT,
    MULTI_SPORT_DEVICE_SUPPORT_TAG: MULTI_SPORT_DEVICE_SUPPORT_DEFAULT,
    MEASUREMENT_PANELS_EXPANDED_TAG: MEASUREMENT_PANELS_EXPANDED_DEFAULT,
    MEASUREMENT_DETAIL_SIZE_TAG: MEASUREMENT_DETAIL_SIZE_DEFAULT,
    APP_DEBUG_MODE_TAG: APP_DEBUG_MODE_DEFAULT,
    THROTTLE_POWER_TAG: THROTTLE_POWER_DEFAULT,
    THROTTLE_OTHER_TAG: THROTTLE_OTHER_DEFAULT,
    COMPRESS_DOWNLOAD_TAG: COMPRESS_DOWNLOAD_DEFAULT,
    STROKE_RATE_SMOOTHING_TAG: STROKE_RATE_SMOOTHING_DEFAULT,
    EQUIPMENT_DISCONNECTION_WATCHDOG_TAG: EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT,
    CALORIE_CARRYOVER_WORKAROUND_TAG: CALORIE_CARRYOVER_WORKAROUND_DEFAULT,
    CADENCE_GAP_PATCHING_WORKAROUND_TAG: CADENCE_GAP_PATCHING_WORKAROUND_DEFAULT,
  };
  PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
    PreferencesSpec.preferencesSpecs.forEach((prefSpec) {
      prefDefaults.addAll({
        prefSpec.thresholdTag(sport): prefSpec.thresholdDefault(sport),
        prefSpec.zonesTag(sport): prefSpec.zonesDefault(sport),
      });
    });
    prefDefaults.addAll({LAST_EQUIPMENT_ID_TAG_PREFIX + sport: LAST_EQUIPMENT_ID_DEFAULT});
    if (sport != ActivityType.Ride) {
      prefDefaults.addAll(
          {PreferencesSpec.slowSpeedTag(sport): PreferencesSpec.slowSpeeds[sport].toString()});
    }
  });
  PrefService.setDefaultValues(prefDefaults);

  if (PrefService.getInt(PREFERENCES_VERSION_TAG) < PREFERENCES_VERSION_SPORT_THRESHOLDS) {
    PreferencesSpec.preferencesSpecs.forEach((prefSpec) {
      final thresholdTag = PreferencesSpec.THRESHOLD_PREFIX + prefSpec.metric;
      var thresholdString = PrefService.getString(thresholdTag);
      if (prefSpec.metric == "speed") {
        thresholdString = decimalRound(double.tryParse(thresholdString) * MI2KM).toString();
      }
      PrefService.setString(prefSpec.thresholdTag(ActivityType.Ride), thresholdString);
      final zoneTag = prefSpec.metric + PreferencesSpec.ZONES_POSTFIX;
      PrefService.setString(prefSpec.zonesTag(ActivityType.Ride), PrefService.getString(zoneTag));
    });
  }
  if (PrefService.getInt(PREFERENCES_VERSION_TAG) <
      PREFERENCES_VERSION_EQUIPMENT_REMEMBRANCE_PER_SPORT) {
    final lastEquipmentId = PrefService.getString(LAST_EQUIPMENT_ID_TAG);
    if ((lastEquipmentId?.length ?? 0) > 0) {
      PrefService.setString(LAST_EQUIPMENT_ID_TAG_PREFIX + ActivityType.Ride, lastEquipmentId);
    }
  }
  PrefService.setInt(PREFERENCES_VERSION_TAG, PREFERENCES_VERSION_DEFAULT + 1);

  PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
    if (sport != ActivityType.Ride) {
      final slowSpeedString = PrefService.getString(PreferencesSpec.slowSpeedTag(sport));
      PreferencesSpec.slowSpeeds[sport] = double.tryParse(slowSpeedString);
    }
  });

  final addressesString = PrefService.getString(DATA_CONNECTION_ADDRESSES) ?? "";
  if (addressesString.trim().isNotEmpty) {
    final addressTuples = parseIpAddresses(addressesString);
    if (addressTuples.length > 0) {
      DataConnectionChecker().addresses = addressTuples
          .map((addressTuple) => AddressCheckOptions(
                InternetAddress(addressTuple.item1),
                port: addressTuple.item2,
              ))
          .toList(growable: false);
    }
  }

  final companyRegistry = CompanyRegistry();
  await companyRegistry.loadCompanyIdentifiers();
  Get.put<CompanyRegistry>(companyRegistry);

  Get.put<AdvertisementCache>(AdvertisementCache());

  runApp(TrackMyIndoorExerciseApp());
}
