import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../persistence/database.dart';
import '../utils/constants.dart';

class AboutScreen extends StatefulWidget {
  static String shortTitle = "About";

  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  static const hostUrl = "https://trackmyindoorworkout.github.io/";
  static const quickStartUrl = "${hostUrl}2020/09/25/quick-start.html";
  static const faqUrl = "${hostUrl}2020/09/22/frequently-asked-questions.html";
  static const knownIssuesUrl = "${hostUrl}2020/09/26/known-issues.html";
  static const changeLogUrl = "${hostUrl}changelog";

  late String _version;
  late String _buildNumber;
  String _timeZone = "";
  TextStyle _fieldStyle = const TextStyle();
  TextStyle _valueStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _fieldStyle = Get.textTheme.headline5!;
    _valueStyle = Get.textTheme.headline6!.apply(
      fontFamily: FONT_FAMILY,
      // color: Colors.white,
    );
    final packageInfo = Get.find<PackageInfo>();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;

    FlutterNativeTimezone.getLocalTimezone().then((String timeZone) {
      setState(() {
        _timeZone = timeZone;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];
    if (kDebugMode) {
      actions.add(IconButton(
        icon: const Icon(Icons.build),
        onPressed: () async {
          final database = Get.find<AppDatabase>();
          final activities = await database.activityDao.findAllActivities();
          for (var activity in activities) {
            final lastRecord =
                await database.recordDao.findLastRecordOfActivity(activity.id!).first;
            if (lastRecord != null) {
              int updated = 0;
              if (lastRecord.calories != null &&
                  lastRecord.calories! > 0 &&
                  activity.calories == 0) {
                activity.calories = lastRecord.calories!;
                updated++;
              }

              if (lastRecord.distance != null &&
                  lastRecord.distance! > 0 &&
                  activity.distance == 0) {
                activity.distance = lastRecord.distance!;
                updated++;
              }

              if (lastRecord.elapsed != null && lastRecord.elapsed! > 0 && activity.elapsed == 0) {
                activity.elapsed = lastRecord.elapsed!;
                updated++;
              }

              if (lastRecord.timeStamp != null && lastRecord.timeStamp! > 0 && activity.end == 0) {
                activity.end = lastRecord.timeStamp!;
                updated++;
              }

              if (updated > 0) {
                database.activityDao.updateActivity(activity);
                Get.snackbar("Activity ${activity.id}", "Updated $updated fields");
              }
            }
          }
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AboutScreen.shortTitle),
        actions: actions,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Version:',
                style: _fieldStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: Text(
                _version,
                style: _valueStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: Text(
                'Build#:',
                style: _fieldStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: Text(
                _buildNumber,
                style: _valueStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: Text(
                'Time Zone:',
                style: _fieldStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: Text(
                _timeZone,
                style: _valueStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text("Quick Start"),
                onPressed: () async {
                  if (await canLaunch(quickStartUrl)) {
                    launch(quickStartUrl);
                  } else {
                    Get.snackbar("Attention", "Cannot open URL");
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text("Frequently Asked Questions"),
                onPressed: () async {
                  if (await canLaunch(faqUrl)) {
                    launch(faqUrl);
                  } else {
                    Get.snackbar("Attention", "Cannot open URL");
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text("Known Issues"),
                onPressed: () async {
                  if (await canLaunch(knownIssuesUrl)) {
                    launch(knownIssuesUrl);
                  } else {
                    Get.snackbar("Attention", "Cannot open URL");
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text("Change Log"),
                onPressed: () async {
                  if (await canLaunch(changeLogUrl)) {
                    launch(changeLogUrl);
                  } else {
                    Get.snackbar("Attention", "Cannot open URL");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
