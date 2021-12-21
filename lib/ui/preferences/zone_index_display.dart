import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/zone_index_display_coloring.dart';
import '../../persistence/preferences_spec.dart';
import 'preferences_base.dart';

class ZoneIndexDisplayPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Index Disp.";
  static String title = "$shortTitle Preferences";

  const ZoneIndexDisplayPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> indexDisplayPreferences = [
      const PrefLabel(title: Text(PreferencesSpec.zoneIndexDisplayExtraNote, maxLines: 10)),
      const PrefCheckbox(
        title: Text(zoneIndexDisplayColoring),
        subtitle: Text(zoneIndexDisplayColoringDescription),
        pref: zoneIndexDisplayColoringTag,
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
