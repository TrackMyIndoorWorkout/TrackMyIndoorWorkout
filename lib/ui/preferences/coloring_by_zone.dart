import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../preferences/metric_spec.dart';
import 'preferences_screen_mixin.dart';

class ColoringByZonePreferencesScreen extends StatelessWidget with PreferencesScreenMixin {
  static String shortTitle = "Color by Zone";
  static String title = "$shortTitle Preferences";

  const ColoringByZonePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> coloringByZonePreferences = [
      const PrefLabel(title: Text(MetricSpec.zoneIndexDisplayExtraNote, maxLines: 10)),
    ];

    coloringByZonePreferences.addAll(MetricSpec.preferencesSpecs.map((prefSpec) {
      return PrefCheckbox(
        title: Text(prefSpec.coloringByZoneText),
        subtitle: Text(prefSpec.coloringByZoneDescription),
        pref: prefSpec.coloringByZoneTag,
      );
    }));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: coloringByZonePreferences),
    );
  }
}
