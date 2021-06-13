import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/preferences.dart';
import 'preferences_base.dart';

class ExpertPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Expert";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> expertPreferences = [
      PrefLabel(title: Text(DATA_CONNECTION_ADDRESSES_DESCRIPTION, maxLines: 10)),
      PrefText(
        label: DATA_CONNECTION_ADDRESSES,
        pref: DATA_CONNECTION_ADDRESSES_TAG,
        validator: (str) {
          if (str == null) {
            return "Invalid or empty addresses, address won't be changed or default DNS servers will be used";
          }

          final addressTuples = parseIpAddresses(str);
          if (addressTuples.isEmpty) {
            return "Invalid or empty addresses, address won't be changed or default DNS servers will be used";
          } else {
            if (str.split(",").length > addressTuples.length) {
              return "There's some malformed address(es) in the configuration";
            }
          }

          return null;
        },
      ),
      PrefCheckbox(
        title: Text(DEVICE_FILTERING),
        subtitle: Text(DEVICE_FILTERING_DESCRIPTION),
        pref: DEVICE_FILTERING_TAG,
      )
    ];

    if (kDebugMode) {
      expertPreferences.add(PrefCheckbox(
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
