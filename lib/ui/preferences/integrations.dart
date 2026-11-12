import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../preferences/instant_upload.dart';
import '../../preferences/training_peaks_upload_public.dart';
import '../../preferences/upload_display_mode.dart';
import '../../upload/constants.dart';
import '../../upload/dreeve/dreeve_service.dart';
import '../../upload/upload_service.dart';
import '../../utils/preferences.dart';
import '../../utils/theme_manager.dart';
import 'dreeve_dialog.dart';
import 'preferences_screen_mixin.dart';

class IntegrationPreferencesScreen extends StatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Integrations";
  static String title = "$shortTitle Preferences";

  const IntegrationPreferencesScreen({super.key});

  @override
  IntegrationPreferencesScreenState createState() => IntegrationPreferencesScreenState();
}

class IntegrationPreferencesScreenState extends State<IntegrationPreferencesScreen> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = const TextStyle();
  Map<String, bool> integrationStates = {};

  @override
  void initState() {
    super.initState();
    _largerTextStyle = Get.textTheme.headlineMedium!;
    _loadIntegrationStates();
  }

  Future<void> _loadIntegrationStates() async {
    for (final portalName in portalNames) {
      final isEnabled = await UploadService.isIntegrationEnabled(portalName);
      if (!mounted) return;
      setState(() {
        integrationStates[portalName] = isEnabled;
      });
    }
  }

  Future<bool> toggleIntegration(String portalName) async {
    if (portalName == dreeveChoice) {
      if (integrationStates[dreeveChoice] ?? false) {
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Dreeve Integration"),
            content: Text("Connected to ${DreeveService.getServerUrl()}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, "cancel"),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, "disconnect"),
                child: Text("Disconnect", style: TextStyle(color: _themeManager.getRedColor())),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, "edit"),
                child: const Text("Edit Settings"),
              ),
            ],
          ),
        );

        if (action == "disconnect") {
          await UploadService.getInstance(dreeveChoice).logout();
          Get.snackbar("Success", "Disconnected from Dreeve");
          await _loadIntegrationStates();
          return true;
        } else if (action == "edit") {
          if (mounted) {
            await DreeveConfigDialog.show(context, onSaved: _loadIntegrationStates);
            await _loadIntegrationStates();
          }
          return true;
        }
        return false;
      } else {
        await DreeveConfigDialog.show(context, onSaved: _loadIntegrationStates);
        await _loadIntegrationStates();
        return integrationStates[dreeveChoice] ?? false;
      }
    }

    if (!await hasInternetConnection()) {
      Get.snackbar("Warning", "No data connection detected, try again later!");
      return false;
    }

    UploadService uploadService = UploadService.getInstance(portalName);
    var success = false;
    if (await UploadService.isIntegrationEnabled(portalName)) {
      final returnCode = await uploadService.logout();
      debugPrint("Logout (deauthorization) return code: $returnCode");
      if (returnCode >= 200 && returnCode < 300) {
        Get.snackbar("Success", "Successful $portalName logout");
        success = true;
      } else {
        Get.snackbar("Warning", "$portalName logout unsuccessful");
      }
    } else {
      final loginSuccess = await uploadService.login();
      if (loginSuccess) {
        Get.snackbar("Success", "Successful $portalName login");
        success = true;
      } else {
        Get.snackbar("Warning", "$portalName login unsuccessful");
      }
    }

    if (success) {
      final isEnabled = await UploadService.isIntegrationEnabled(portalName);
      if (mounted) {
        setState(() {
          integrationStates[portalName] = isEnabled;
        });
      }
    }

    return success;
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    List<Widget> integrationPreferences = [
      const PrefCheckbox(
        title: Text(instantUpload),
        subtitle: Text(instantUploadDescription),
        pref: instantUploadTag,
      ),
      const PrefCheckbox(
        title: Text(trainingPeaksUploadPublic),
        subtitle: Text(trainingPeaksUploadPublicDescription),
        pref: trainingPeaksUploadPublicTag,
      ),
      PrefLabel(title: Text(uploadDisplayMode, style: Get.textTheme.headlineSmall!, maxLines: 3)),
      const PrefRadio<String>(
        title: Text(uploadDisplayModeNoneTitle),
        subtitle: Text(uploadDisplayModeNoneDescription),
        value: uploadDisplayModeNone,
        pref: uploadDisplayModeTag,
      ),
      const PrefRadio<String>(
        title: Text(uploadDisplayModeAggregateTitle),
        subtitle: Text(uploadDisplayModeAggregateDescription),
        value: uploadDisplayModeAggregate,
        pref: uploadDisplayModeTag,
      ),
      const PrefRadio<String>(
        title: Text(uploadDisplayModeDetailedTitle),
        subtitle: Text(uploadDisplayModeDetailedDescription),
        value: uploadDisplayModeDetailed,
        pref: uploadDisplayModeTag,
      ),
      PrefLabel(
        title: Text("Available Integrations:", style: Get.textTheme.headlineSmall!, maxLines: 3),
      ),
    ];

    integrationPreferences.addAll(
      getPortalChoices(true, _themeManager).asMap().entries.map(
        (e) => PrefButton(
          child: GestureDetector(
            onTap: () async {
              await toggleIntegration(e.value.name);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  (integrationStates[e.value.name] ?? false) ? Icons.link : Icons.link_off,
                  size: _largerTextStyle.fontSize! * 1.5,
                  color: _themeManager.getProtagonistColor(),
                ),
                SizedBox(width: 10, height: _largerTextStyle.fontSize! * 1.5),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  height: _largerTextStyle.fontSize! * e.value.heightMultiplier + 10,
                  width: mediaWidth - 130,
                  padding: const EdgeInsets.all(5),
                  child: e.value.getSvg(false, _largerTextStyle.fontSize!),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(IntegrationPreferencesScreen.title)),
      body: PrefPage(children: integrationPreferences),
    );
  }
}
