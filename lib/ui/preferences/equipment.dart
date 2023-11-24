import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/air_temperature.dart';
import '../../preferences/bike_weight.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/drag_force_tune.dart';
import '../../preferences/drive_train_loss.dart';
import '../../preferences/kayak_first_display_configuration.dart';
import '../../preferences/measurement_sink_address.dart';
import '../../preferences/paddling_with_cycling_sensors.dart';
import '../../preferences/treadmill_rsc_only_mode.dart';
import '../../preferences/water_wheel_circumference.dart';
import '../../preferences/wheel_circumference.dart';
import '../../utils/preferences.dart';
import 'kayak_first_display_slot.dart';
import 'pref_integer.dart';
import 'preferences_screen_mixin.dart';

class EquipmentPreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
  static String shortTitle = "Equipment";
  static String title = "$shortTitle Preferences";

  const EquipmentPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> equipmentPreferences = [
      PrefSlider<int>(
        title: const Text(bikeWeight),
        subtitle: const Text(bikeWeightDescription),
        pref: bikeWeightTag,
        trailing: (num value) => Text("$value kg"),
        min: bikeWeightMin,
        max: bikeWeightMax,
        divisions: bikeWeightDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: bikeWeightTag,
        min: bikeWeightMin,
        max: bikeWeightMax,
      ),
      PrefSlider<int>(
        title: const Text(wheelCircumference),
        subtitle: const Text(wheelCircumferenceDescription),
        pref: wheelCircumferenceTag,
        trailing: (num value) => Text("$value mm"),
        min: wheelCircumferenceMin,
        max: wheelCircumferenceMax,
        divisions: wheelCircumferenceDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: wheelCircumferenceTag,
        min: wheelCircumferenceMin,
        max: wheelCircumferenceMax,
      ),
      PrefSlider<int>(
        title: const Text(driveTrainLoss),
        subtitle: const Text(driveTrainLossDescription),
        pref: driveTrainLossTag,
        trailing: (num value) => Text("$value %"),
        min: driveTrainLossMin,
        max: driveTrainLossMax,
        divisions: driveTrainLossDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: driveTrainLossTag,
        min: driveTrainLossMin,
        max: driveTrainLossMax,
      ),
      PrefSlider<int>(
        title: const Text(airTemperature),
        subtitle: const Text(airTemperatureDescription),
        pref: airTemperatureTag,
        trailing: (num value) => Text("$value C"),
        min: airTemperatureMin,
        max: airTemperatureMax,
        divisions: airTemperatureDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: airTemperatureTag,
        min: airTemperatureMin,
        max: airTemperatureMax,
      ),
      PrefSlider<int>(
        title: const Text(dragForceTune),
        subtitle: const Text(dragForceTuneDescription),
        pref: dragForceTuneTag,
        trailing: (num value) => Text("$value %"),
        min: dragForceTuneMin,
        max: dragForceTuneMax,
        divisions: dragForceTuneDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: dragForceTuneTag,
        min: dragForceTuneMin,
        max: dragForceTuneMax,
      ),
      const PrefCheckbox(
        title: Text(paddlingWithCyclingSensors),
        subtitle: Text(paddlingWithCyclingSensorsDescription),
        pref: paddlingWithCyclingSensorsTag,
      ),
      PrefSlider<int>(
        title: const Text(waterWheelCircumference),
        subtitle: const Text(waterWheelCircumferenceDescription),
        pref: waterWheelCircumferenceTag,
        trailing: (num value) => Text("$value mm"),
        min: waterWheelCircumferenceMin,
        max: waterWheelCircumferenceMax,
        divisions: waterWheelCircumferenceDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: waterWheelCircumferenceTag,
        min: waterWheelCircumferenceMin,
        max: waterWheelCircumferenceMax,
      ),
      const PrefCheckbox(
        title: Text(blockSignalStartStop),
        subtitle: Text(blockSignalStartStopDescription),
        pref: blockSignalStartStopTag,
      ),
      PrefLabel(
        title: Text(treadmillRscOnlyMode, style: Get.textTheme.headlineSmall!, maxLines: 3),
        subtitle: const Text(treadmillRscOnlyModeDescription),
      ),
      const PrefRadio<String>(
        title: Text(treadmillRscOnlyModeAutoDescription),
        value: treadmillRscOnlyModeAuto,
        pref: treadmillRscOnlyModeTag,
      ),
      const PrefRadio<String>(
        title: Text(treadmillRscOnlyModeAlwaysDescription),
        value: treadmillRscOnlyModeAlways,
        pref: treadmillRscOnlyModeTag,
      ),
      const PrefRadio<String>(
        title: Text(treadmillRscOnlyModeNeverDescription),
        value: treadmillRscOnlyModeNever,
        pref: treadmillRscOnlyModeTag,
      ),
      PrefText(
        label: measurementSinkAddress,
        pref: measurementSinkAddressTag,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\d:.]"))],
        validator: (str) {
          if (str == null || str.isEmpty) {
            return null;
          }

          if (parseNetworkAddress(str, false) == dummyAddressTuple) {
            return "Doesn't look like a domain name / IP address or doesn't have a port number";
          }

          return null;
        },
      ),
      PrefLabel(
        title: Text(kayakFirstDisplay, style: Get.textTheme.headlineSmall!, maxLines: 3),
      ),
    ];

    equipmentPreferences.add(getKayakFirstDisplaySlotPref(
      kayakFirstDisplaySlot1Tag,
      kayakFirstDisplaySlot1,
      kayakFirstDisplaySlot1Description,
    ));
    equipmentPreferences.add(getKayakFirstDisplaySlotPref(
      kayakFirstDisplaySlot2Tag,
      kayakFirstDisplaySlot2,
      kayakFirstDisplaySlot2Description,
    ));
    equipmentPreferences.add(getKayakFirstDisplaySlotPref(
      kayakFirstDisplaySlot3Tag,
      kayakFirstDisplaySlot3,
      kayakFirstDisplaySlot3Description,
    ));
    equipmentPreferences.add(getKayakFirstDisplaySlotPref(
      kayakFirstDisplaySlot4Tag,
      kayakFirstDisplaySlot4,
      kayakFirstDisplaySlot4Description,
    ));
    equipmentPreferences.add(getKayakFirstDisplaySlotPref(
      kayakFirstDisplaySlot5Tag,
      kayakFirstDisplaySlot5,
      kayakFirstDisplaySlot5Description,
    ));

    return Scaffold(
      appBar: AppBar(title: Text(EquipmentPreferencesScreen.title)),
      body: PrefPage(children: equipmentPreferences),
    );
  }
}
