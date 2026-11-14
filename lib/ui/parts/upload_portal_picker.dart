import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../export/virtual_sport.dart';
import '../../persistence/activity.dart';
import '../../preferences/calculate_gps.dart';
import '../../preferences/virtual_workout.dart';
import '../../upload/constants.dart';
import '../../upload/upload_manager.dart';
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
  bool _virtualWorkout = virtualWorkoutDefault;
  Map<String, bool> uploadStates = {};

  @override
  void initState() {
    super.initState();
    _largerTextStyle = Get.textTheme.headlineMedium!.apply(
      color: _themeManager.getProtagonistColor(),
    );
    final prefService = Get.find<BasePrefService>();
    _calculateGps = prefService.get<bool>(calculateGpsTag) ?? calculateGpsDefault;
    _virtualWorkout = prefService.get<bool>(virtualWorkoutTag) ?? virtualWorkoutDefault;
    for (final portalName in portalNames) {
      uploadStates[portalName] = widget.activity.isUploaded(portalName);
    }
  }

  Future<bool> uploadActivity(String portalName) async {
    if (UploadManager.instance.isUploading(widget.activity.id, portalName)) {
      return false;
    }

    final success = await UploadManager.instance.uploadActivity(
      widget.activity,
      portalName,
      calculateGps: _calculateGps,
      virtualWorkout: _virtualWorkout,
    );

    if (mounted) {
      setState(() {
        uploadStates[portalName] = widget.activity.isUploaded(portalName);
      });
    }

    return success;
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);

    return Obx(() {
      final isAnyUploading = UploadManager.instance.isUploading(widget.activity.id);

      List<Widget> choiceRows = [
        isAnyUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      semanticsLabel: "Progress indicator",
                    ),
                  ),
                  const SizedBox(width: 12),
                  JumpingText("Uploading in background...", style: _largerTextStyle),
                ],
              )
            : Text("Integrations:", style: _largerTextStyle, textAlign: TextAlign.center),
      ];

      if (VirtualSport.hasVirtualCounterpart(widget.activity.sport)) {
        choiceRows.add(
          SwitchListTile(
            title: const Text("Virtual Workout"),
            subtitle: Text("Upload as ${VirtualSport.getVirtualSport(widget.activity.sport)}"),
            value: _virtualWorkout,
            activeTrackColor: _themeManager.getProtagonistColor(),
            onChanged: (bool value) {
              setState(() {
                _virtualWorkout = value;
              });
            },
          ),
        );
      }

      choiceRows.addAll(
        getPortalChoices(false, _themeManager).asMap().entries.map((e) {
          final isThisUploading = UploadManager.instance.isUploading(
            widget.activity.id,
            e.value.name,
          );
          final isUploaded =
              widget.activity.isUploaded(e.value.name) || (uploadStates[e.value.name] ?? false);

          Widget leadingIcon;
          if (isThisUploading) {
            leadingIcon = SizedBox(
              width: _largerTextStyle.fontSize! * 1.5,
              height: _largerTextStyle.fontSize! * 1.5,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            );
          } else if (isUploaded) {
            leadingIcon = Icon(
              Icons.check,
              size: _largerTextStyle.fontSize! * 1.5,
              color: _themeManager.getGreenColor(),
            );
          } else {
            leadingIcon = Icon(
              Icons.upload,
              size: _largerTextStyle.fontSize! * 1.5,
              color: _themeManager.getProtagonistColor(),
            );
          }

          return ListTile(
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
                    onTap: isThisUploading
                        ? null
                        : () {
                            uploadActivity(e.value.name);
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        leadingIcon,
                        SizedBox(width: 10, height: _largerTextStyle.fontSize! * 1.5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          height: _largerTextStyle.fontSize! * e.value.heightMultiplier + 10,
                          width: mediaWidth - 150,
                          padding: const EdgeInsets.all(5),
                          child: e.value.getSvg(false, _largerTextStyle.fontSize!),
                        ),
                      ],
                    ),
                  ),
                  isUploaded
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
          );
        }),
      );

      return Scaffold(
        body: ListView(children: choiceRows),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.back()),
      );
    });
  }
}
