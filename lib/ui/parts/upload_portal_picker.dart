import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../persistence/database.dart';
import '../../persistence/models/activity.dart';
import '../../preferences/calculate_gps.dart';
import '../../upload/constants.dart';
import '../../upload/strava/strava_status_code.dart';
import '../../upload/upload_service.dart';
import '../../utils/theme_manager.dart';

class UploadPortalPickerBottomSheet extends StatefulWidget {
  final Activity activity;

  const UploadPortalPickerBottomSheet({Key? key, required this.activity}) : super(key: key);

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
    _largerTextStyle = Get.textTheme.headline4!.apply(color: _themeManager.getProtagonistColor());
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

    final AppDatabase database = Get.find<AppDatabase>();
    final records = await database.recordDao.findAllActivityRecords(widget.activity.id ?? 0);

    final statusCode = await uploadService.upload(widget.activity, records, _calculateGps);
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
      getPortalChoices(_themeManager).asMap().entries.map(
            (e) => Column(
              children: [
                Padding(
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
                            SvgPicture.asset(
                              e.value.assetName,
                              color: e.value.color,
                              height: _largerTextStyle.fontSize! * e.value.heightMultiplier,
                              semanticsLabel: '${e.value.name} Logo',
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
                                  launchUrlString(workoutUrl);
                                } else {
                                  Get.snackbar("Attention", "Cannot open URL");
                                }
                              },
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: choiceRows,
        ),
      ),
    );
  }
}
