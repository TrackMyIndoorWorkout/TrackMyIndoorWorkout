import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/data_connection_addresses.dart';
import '../../preferences/device_filtering.dart';
import '../../preferences/enforced_time_zone.dart';
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
      const PrefLabel(title: Text(dataConnectionAddressesDescription, maxLines: 10)),
      PrefText(
        label: dataConnectionAddresses,
        pref: dataConnectionAddressesTag,
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
        title: Text(deviceFiltering),
        subtitle: Text(deviceFilteringDescription),
        pref: deviceFilteringTag,
      ),
      PrefDropdown<String>(
        title: const Text(enforcedTimeZone),
        subtitle: const Text(enforcedTimeZoneDescription),
        pref: enforcedTimeZoneTag,
        items: timeZoneChoices
            .map((timeZone) => DropdownMenuItem(value: timeZone, child: Text(timeZone)))
            .toList(growable: false),
      ),
    ];

    if (kDebugMode) {
      expertPreferences.add(const PrefCheckbox(
        title: Text(appDebugMode),
        subtitle: Text(appDebugModeDescription),
        pref: appDebugModeTag,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PrefPage(children: expertPreferences),
    );
  }
}
