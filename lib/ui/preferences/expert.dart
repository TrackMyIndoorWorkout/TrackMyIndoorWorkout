import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import '../../utils/preferences.dart';
import 'preferences_base.dart';

class ExpertPreferencesScreen extends PreferencesScreenBase {
  static String shortTitle = "Expert";
  static String title = "$shortTitle Preferences";

  @override
  Widget build(BuildContext context) {
    List<Widget> expertPreferences = [
      PreferenceTitle(DATA_CONNECTION_ADDRESSES_DESCRIPTION),
      TextFieldPreference(
        DATA_CONNECTION_ADDRESSES,
        DATA_CONNECTION_ADDRESSES_TAG,
        defaultVal: DATA_CONNECTION_ADDRESSES_DEFAULT,
        validator: (str) {
          final addressTuples = parseIpAddresses(str);
          if (addressTuples == null || addressTuples.isEmpty) {
            return "Invalid or empty addresses, default DNS servers will be used";
          } else {
            if (str.split(",").length > addressTuples.length) {
              return "There's some malformed address(es) in the configuration";
            }
          }
          return null;
        },
      ),
    ];

    if (kDebugMode) {
      expertPreferences.add(SwitchPreference(
        APP_DEBUG_MODE,
        APP_DEBUG_MODE_TAG,
        defaultVal: APP_DEBUG_MODE_DEFAULT,
        desc: APP_DEBUG_MODE_DESCRIPTION,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PreferencePage(expertPreferences),
    );
  }
}
