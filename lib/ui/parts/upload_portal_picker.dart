import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../persistence/isar/activity.dart';
import '../../preferences/calculate_gps.dart';
import '../../upload/constants.dart';
import '../../upload/strava/strava_status_code.dart';
import '../../upload/upload_service.dart';
import '../../utils/theme_manager.dart';

class UploadPortalPickerBottomSheet extends StatefulWidget {
  final Activity activity;

  const UploadPortalPickerBottomSheet({super.key, required this.activity});

  @override
  UploadPortalPickerBottomSheetState createState() => UploadPortalPickerBottomSheetState();
}

class UploadPortalPickerBottomSheetState extends State<UploadPortalPickerBottomSheet> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = const TextStyle();
  bool _calculateGps = calculateGpsDefault;
  bool uploadInProgress = false;
  Map<String, bool> uploadStates = {};

  @override
  void initState() {
    super.initState();
    _largerTextStyle =
        Get.textTheme.headlineMedium!.apply(color: _themeManager.getProtagonistColor());
    final prefService = Get.find<BasePrefService>();
    _calculateGps = prefService.get<bool>(calculateGpsTag) ?? calculateGpsDefault;
    for (final portalName in portalNames) {
      uploadStates[portalName] = widget.activity.isUploaded(portalName);
    }
  }

  Future<bool> uploadActivity(String portalName) async {
    UploadService uploadService = UploadService.getInstance(portalName);

    setState(() {
      uploadInProgress = true;
    });
    final success = await uploadService.login();
    if (!success) {
      Get.snackbar("Warning", "$portalName login unsuccessful");
      setState(() {
        uploadInProgress = false;
      });
      return false;
    }

    final statusCode = await uploadService.upload(widget.activity, _calculateGps);
    final finalResult =
        statusCode == StravaStatusCode.statusOk || statusCode >= 200 && statusCode < 300;
    final resultMessage = finalResult
        ? "Activity ${widget.activity.id} submitted successfully"
        : "Activity ${widget.activity.id} upload failure";
    Get.snackbar("Upload", resultMessage);

    setState(() {
      uploadInProgress = false;
      if (finalResult) {
        for (final portalName in portalNames) {
          uploadStates[portalName] = widget.activity.isUploaded(portalName);
        }
      }
    });

    return finalResult;
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    List<Widget> choiceRows = [
      uploadInProgress
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  semanticsLabel: "Progress indicator",
                ),
                JumpingText(
                  "Uploading...",
                  style: _largerTextStyle,
                ),
              ],
            )
          : Text(
              "Integrations:",
              style: _largerTextStyle,
              textAlign: TextAlign.center,
            ),
    ];
    choiceRows.addAll(
      getPortalChoices(false, _themeManager).asMap().entries.map(
            (e) => ListTile(
              title: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _largerTextStyle.fontSize! / 3,
                  horizontal: 0.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        uploadActivity(e.value.name);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            (uploadStates[e.value.name] ?? false) ? Icons.check : Icons.upload,
                            size: _largerTextStyle.fontSize! * 1.5,
                            color: (uploadStates[e.value.name] ?? false)
                                ? _themeManager.getGreenColor()
                                : _themeManager.getProtagonistColor(),
                          ),
                          SizedBox(width: 10, height: _largerTextStyle.fontSize! * 1.5),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            height: _largerTextStyle.fontSize! * e.value.heightMultiplier + 10,
                            width: mediaWidth - 150,
                            padding: const EdgeInsets.all(5),
                            child: SvgPicture.asset(
                              e.value.assetName,
                              colorFilter:
                                  const ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
                              height: _largerTextStyle.fontSize! * e.value.heightMultiplier,
                              semanticsLabel: '${e.value.name} Logo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    (uploadStates[e.value.name] ?? false)
                        ? IconButton(
                            icon: Icon(
                              Icons.open_in_new,
                              size: _largerTextStyle.fontSize! * 1.5,
                              color: widget.activity.isSpecificWorkoutUrl(e.value.name)
                                  ? _themeManager.getProtagonistColor()
                                  : _themeManager.getGreyColor(),
                            ),
                            onPressed: () async {
                              final workoutUrl = widget.activity.workoutUrl(e.value.name);
                              if (await canLaunchUrlString(workoutUrl)) {
                                launchUrlString(workoutUrl, mode: LaunchMode.externalApplication);
                              } else {
                                Get.snackbar("Attention", "Cannot open URL");
                              }
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
    );

    return Scaffold(
      body: ListView(children: choiceRows),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.back()),
    );
  }
}
