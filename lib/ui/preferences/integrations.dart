import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/instant_upload.dart';
import '../../preferences/training_peaks_upload_public.dart';
import '../../preferences/upload_display_mode.dart';
import '../../providers/theme_mode.dart';
import '../../upload/constants.dart';
import '../../upload/upload_service.dart';
import '../../utils/preferences.dart';
import '../../utils/theme_manager.dart';
import 'preferences_screen_mixin.dart';

class IntegrationPreferencesScreen extends ConsumerStatefulWidget with PreferencesScreenMixin {
  static String shortTitle = "Integrations";
  static String title = "$shortTitle Preferences";

  const IntegrationPreferencesScreen({super.key});

  @override
  IntegrationPreferencesScreenState createState() => IntegrationPreferencesScreenState();
}

class IntegrationPreferencesScreenState extends ConsumerState<IntegrationPreferencesScreen> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  Map<String, bool> integrationStates = {};

  @override
  void initState() {
    super.initState();
    for (final portalName in portalNames) {
      integrationStates[portalName] = UploadService.isIntegrationEnabled(portalName);
    }
  }

  Future<bool> toggleIntegration(String portalName) async {
    if (!await hasInternetConnection()) {
      Get.snackbar("Warning", "No data connection detected, try again later!");
      return false;
    }

    UploadService uploadService = UploadService.getInstance(portalName);
    var success = false;
    if (UploadService.isIntegrationEnabled(portalName)) {
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
      setState(() {
        integrationStates[portalName] = UploadService.isIntegrationEnabled(portalName);
      });
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
      PrefLabel(
        title: Text(uploadDisplayMode, style: Get.textTheme.headlineSmall!, maxLines: 3),
      ),
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
        title: Text(
          "Available Integrations:",
          style: Theme.of(context).textTheme.headlineSmall!,
          maxLines: 3,
        ),
      ),
    ];

    final themeMode = ref.watch(themeModeProvider);
    final largerTextStyle = Theme.of(context).textTheme.headlineMedium!;
    integrationPreferences.addAll(
      getPortalChoices(true, themeManager, themeMode).asMap().entries.map(
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
                      size: largerTextStyle.fontSize! * 1.5,
                      color: _themeManager.getProtagonistColor(themeMode),
                    ),
                    SizedBox(width: 10, height: largerTextStyle.fontSize! * 1.5),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      height: largerTextStyle.fontSize! * e.value.heightMultiplier + 10,
                      width: mediaWidth - 130,
                      padding: const EdgeInsets.all(5),
                      child: e.value.getSvg(false, largerTextStyle.fontSize!),
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
