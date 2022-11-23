import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/air_temperature.dart';
import '../../preferences/bike_weight.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/drag_force_tune.dart';
import '../../preferences/drive_train_loss.dart';
import '../../preferences/wheel_circumference.dart';
import 'preferences_screen_mixin.dart';

class EquipmentPreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Equipment";
  static String title = "$shortTitle Preferences";

  const EquipmentPreferencesScreen({Key? key}) : super(key: key);

  @override
  EquipmentPreferencesScreenState createState() => EquipmentPreferencesScreenState();
}

class EquipmentPreferencesScreenState extends State<EquipmentPreferencesScreen> {
  int _wheelCircumferenceEdit = 0;

  void onWheelCircumferenceSpinTap(int delta) {
    setState(() {
      final circumference = PrefService.of(context).get(wheelCircumferenceTag);
      PrefService.of(context).set(wheelCircumferenceTag, circumference + delta);
      _wheelCircumferenceEdit++;
    });
  }

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
      PrefSlider<int>(
        key: Key("wheelCircumference$_wheelCircumferenceEdit"),
        title: const Text(wheelCircumference),
        subtitle: const Text(wheelCircumferenceDescription),
        pref: wheelCircumferenceTag,
        trailing: (num value) => Text("$value mm"),
        min: wheelCircumferenceMin,
        max: wheelCircumferenceMax,
        divisions: wheelCircumferenceDivisions,
        direction: Axis.vertical,
      ),
      PrefButton(
        onTap: () => onWheelCircumferenceSpinTap(1),
        child: const Text("+1 mm"),
      ),
      PrefButton(
        onTap: () => onWheelCircumferenceSpinTap(-1),
        child: const Text("-1 mm"),
      ),
      PrefButton(
        onTap: () => onWheelCircumferenceSpinTap(10),
        child: const Text("+10 mm"),
      ),
      PrefButton(
        onTap: () => onWheelCircumferenceSpinTap(-10),
        child: const Text("-10 mm"),
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
      appBar: AppBar(title: Text(EquipmentPreferencesScreen.title)),
      body: PrefPage(children: equipmentPreferences),
    );
  }
}
