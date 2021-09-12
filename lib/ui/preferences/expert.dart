import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/preferences.dart';
import 'preferences_base.dart';

class ExpertPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Expert";
  static String title = "$shortTitle Preferences";

  const ExpertPreferencesScreen({Key? key}) : super(key: key);

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
          String addressesString =
              PrefService.of(context).get<String>(DATA_CONNECTION_ADDRESSES_TAG) ??
                  DATA_CONNECTION_ADDRESSES_DEFAULT;
          final addressTuples = parseIpAddresses(addressesString);
          applyDataConnectionCheckConfiguration(addressTuples);
          if (await InternetConnectionChecker().hasConnection) {
            Get.snackbar("Info", "Data connection detected");
          } else {
            Get.snackbar("Warning", "No data connection detected");
          }
        },
        child: const Text("Apply Check Configuration and Test"),
      ),
      const PrefCheckbox(
        title: Text(DEVICE_FILTERING),
        subtitle: Text(DEVICE_FILTERING_DESCRIPTION),
        pref: DEVICE_FILTERING_TAG,
      )
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
