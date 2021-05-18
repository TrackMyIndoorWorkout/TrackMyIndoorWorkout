import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class ZoneIndexDisplayPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Index Disp.";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> indexDisplayPreferences =
        PreferencesSpec.preferencesSpecs.where((spec) => spec.metric != "speed").map((prefSpec) {
      return SwitchPreference(
        "${prefSpec.title} ${PreferencesSpec.ZONE_INDEX_DISPLAY_TEXT}",
        "${prefSpec.metric}_${PreferencesSpec.ZONE_INDEX_DISPLAY_TAG_POSTFIX}",
        defaultVal: prefSpec.indexDisplayDefault,
        desc: prefSpec.zoneIndexDescription,
      );
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(indexDisplayPreferences),
    );
  }
}
