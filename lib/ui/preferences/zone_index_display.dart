import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import 'preferences_base.dart';

class ZoneIndexDisplayPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Index Disp.";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> indexDisplayPreferences = [
      PrefTitle(title: Text(PreferencesSpec.ZONE_INDEX_DISPLAY_EXTRA_NOTE)),
      PrefCheckbox(
        title: Text(ZONE_INDEX_DISPLAY_COLORING),
        subtitle: Text(ZONE_INDEX_DISPLAY_COLORING_DESCRIPTION),
        pref: ZONE_INDEX_DISPLAY_COLORING_TAG,
      ),
    ];

    indexDisplayPreferences.addAll(
        PreferencesSpec.preferencesSpecs.where((spec) => spec.metric != "speed").map((prefSpec) {
      return PrefCheckbox(
        title: Text(prefSpec.zoneIndexText),
        subtitle: Text(prefSpec.zoneIndexDescription),
        pref: prefSpec.zoneIndexTag,
      );
    }));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: indexDisplayPreferences),
    );
  }
}
