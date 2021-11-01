import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../persistence/database.dart';
import '../../persistence/models/activity.dart';
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
  Map<String, bool> uploadStates = {};

  @override
  void initState() {
    super.initState();
    _largerTextStyle = Get.textTheme.headline4!;
    for (final portalName in portalNames) {
      uploadStates[portalName] = widget.activity.isUploaded(portalName);
    }
  }

  Future<bool> uploadActivity(String portalName) async {
    UploadService uploadService = UploadService.getInstance(portalName);

    final success = await uploadService.login();
    if (!success) {
      Get.snackbar("Warning", "$portalName login unsuccessful");
      return false;
    }

    final AppDatabase _database = Get.find<AppDatabase>();
    final records = await _database.recordDao.findAllActivityRecords(widget.activity.id ?? 0);

    final statusCode = await uploadService.upload(widget.activity, records);
    final finalResult =
        statusCode == StravaStatusCode.statusOk || statusCode >= 200 && statusCode < 300;
    final resultMessage = finalResult
        ? "Activity ${widget.activity.id} submitted successfully"
        : "Activity ${widget.activity.id} upload failure";
    Get.snackbar("Upload", resultMessage);

    if (finalResult) {
      setState(() {
        for (final portalName in portalNames) {
          uploadStates[portalName] = widget.activity.isUploaded(portalName);
        }
      });
    }

    return finalResult;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> choiceRows = [
      Text(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      widget.activity.hasWorkoutUrl(e.value.name) ?
                      IconButton(
                        icon: Icon(
                          Icons.open_in_new,
                          size: _largerTextStyle.fontSize! * 1.5,
                          color: _themeManager.getProtagonistColor(),
                        ),
                        onPressed: () async {
                          final workoutUrl = widget.activity.workoutUrl(e.value.name);
                          debugPrint("Workout URL: $workoutUrl");
                          if (await canLaunch(workoutUrl)) {
                            launch(workoutUrl);
                          } else {
                            Get.snackbar("Attention", "Cannot open URL");
                          }
                        },
                      ) : Container(),
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
