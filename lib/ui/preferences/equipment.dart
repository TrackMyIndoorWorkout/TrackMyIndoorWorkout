import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/air_temperature.dart';
import '../../preferences/bike_weight.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/drag_force_tune.dart';
import '../../preferences/drive_train_loss.dart';
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
        direction: Axis.vertical,
      ),
      PrefSlider<int>(
        title: const Text(driveTrainLoss),
        subtitle: const Text(driveTrainLossDescription),
        pref: driveTrainLossTag,
        trailing: (num value) => Text("$value %"),
        min: driveTrainLossMin,
        max: driveTrainLossMax,
        direction: Axis.vertical,
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
      const PrefCheckbox(
        title: Text(blockSignalStartStop),
        subtitle: Text(blockSignalStartStopDescription),
        pref: blockSignalStartStopTag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: equipmentPreferences),
    );
  }
}
