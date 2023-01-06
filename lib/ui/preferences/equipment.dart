import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:string_validator/string_validator.dart';
import '../../preferences/air_temperature.dart';
import '../../preferences/bike_weight.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/drag_force_tune.dart';
import '../../preferences/drive_train_loss.dart';
import '../../preferences/measurement_sink_address.dart';
import '../../preferences/paddling_with_cycling_sensors.dart';
import '../../preferences/water_wheel_circumference.dart';
import '../../preferences/wheel_circumference.dart';
import 'pref_integer.dart';
import 'preferences_screen_mixin.dart';

class EquipmentPreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
  static String shortTitle = "Equipment";
  static String title = "$shortTitle Preferences";

  const EquipmentPreferencesScreen({Key? key}) : super(key: key);

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
        title: Text(blockSignalStartStop),
        subtitle: Text(blockSignalStartStopDescription),
        pref: blockSignalStartStopTag,
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
      PrefText(
        label: measurementSinkAddress,
        pref: measurementSinkAddressTag,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("a-zA-Z0-9.:"))],
        validator: (str) {
          if (str == null) {
            return null;
          }

          if (str.contains(",")) {
            return "This settings takes only one server name / IP address";
          }

          if (!isFQDN(str) && !isIP(str)) {
            return "Doesn't look like a domain name or an IP address";
          }

          return null;
        },
      ),
      PrefLabel(
        title: Text(measurementSinkPort, style: Get.textTheme.headline5!, maxLines: 3),
      ),
      const PrefSlider<int>(
        title: Text(measurementSinkPort),
        subtitle: Text(measurementSinkPortDescription),
        pref: measurementSinkPortTag,
        min: portNumberMin,
        max: portNumberMax,
        divisions: portNumberDivisions,
        direction: Axis.vertical,
      ),
      const PrefInteger(
        pref: measurementSinkPortTag,
        min: portNumberMin,
        max: portNumberMax,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(EquipmentPreferencesScreen.title)),
      body: PrefPage(children: equipmentPreferences),
    );
  }
}
