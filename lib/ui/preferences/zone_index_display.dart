import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class ZoneIndexDisplayPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Index Disp.";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> indexDisplayPreferences = [
      PreferenceTitle(PreferencesSpec.ZONE_INDEX_DISPLAY_EXTRA_NOTE),
      SwitchPreference(
        ZONE_INDEX_DISPLAY_COLORING,
        ZONE_INDEX_DISPLAY_COLORING_TAG,
        defaultVal: ZONE_INDEX_DISPLAY_COLORING_DEFAULT,
        desc: ZONE_INDEX_DISPLAY_COLORING_DESCRIPTION,
      ),
    ];

    indexDisplayPreferences.addAll(
        PreferencesSpec.preferencesSpecs.where((spec) => spec.metric != "speed").map((prefSpec) {
      return SwitchPreference(
        prefSpec.zoneIndexText,
        prefSpec.zoneIndexTag,
        defaultVal: prefSpec.indexDisplayDefault,
        desc: prefSpec.zoneIndexDescription,
      );
    }));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(indexDisplayPreferences),
    );
  }
}
