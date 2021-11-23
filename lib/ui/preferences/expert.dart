import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/preferences.dart';
import 'preferences_base.dart';

class ExpertPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Expert";
  static String title = "$shortTitle Preferences";
  final List<String> timeZoneChoices;

  const ExpertPreferencesScreen({Key? key, required this.timeZoneChoices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> expertPreferences = [
      const PrefLabel(title: Text(DATA_CONNECTION_ADDRESSES_DESCRIPTION, maxLines: 10)),
      PrefText(
        label: DATA_CONNECTION_ADDRESSES,
        pref: DATA_CONNECTION_ADDRESSES_TAG,
        validator: (str) {
          if (str == null) {
            return null;
          }

          final addressTuples = parseIpAddresses(str);
          if (addressTuples.isEmpty) {
            return null;
          } else {
            if (str.split(",").length > addressTuples.length) {
              return "There's some malformed address(es) in the configuration";
            }
          }

          return null;
        },
      ),
      PrefButton(
        onTap: () async {
          if (await hasInternetConnection()) {
            Get.snackbar("Info", "Data connection detected");
          } else {
            Get.snackbar("Warning", "No data connection detected");
          }
        },
        child: const Text("Apply Configuration and Test"),
      ),
      const PrefCheckbox(
        title: Text(DEVICE_FILTERING),
        subtitle: Text(DEVICE_FILTERING_DESCRIPTION),
        pref: DEVICE_FILTERING_TAG,
      ),
      PrefDropdown<String>(
        title: const Text(ENFORCED_TIME_ZONE),
        subtitle: const Text(ENFORCED_TIME_ZONE_DESCRIPTION),
        pref: ENFORCED_TIME_ZONE_TAG,
        items: timeZoneChoices
            .map((timeZone) => DropdownMenuItem(value: timeZone, child: Text(timeZone)))
            .toList(growable: false),
      ),
    ];

    if (kDebugMode) {
      expertPreferences.add(const PrefCheckbox(
        title: Text(APP_DEBUG_MODE),
        subtitle: Text(APP_DEBUG_MODE_DESCRIPTION),
        pref: APP_DEBUG_MODE_TAG,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: expertPreferences),
    );
  }
}
