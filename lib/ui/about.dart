import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../utils/sound.dart';

class AboutScreen extends StatefulWidget {
  static String shortTitle = "About";

  @override
  State<StatefulWidget> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  static const HOST_URL = "https://trackmyindoorworkout.github.io/";
  static const QUICK_START_URL = "${HOST_URL}2020/09/25/quick-start.html";
  static const FAQ_URL = "${HOST_URL}2020/09/22/frequently-asked-questions.html";
  static const KNOWN_ISSUES_URL = "${HOST_URL}2020/09/26/known-issues.html";

  late String _appName;
  late String _version;
  late String _buildNumber;
  TextStyle _fieldStyle = TextStyle();
  TextStyle _valueStyle = TextStyle();

  @override
  void initState() {
    super.initState();
    _fieldStyle = Get.textTheme.headline5!;
    _valueStyle = Get.textTheme.headline6!.apply(
      fontFamily: FONT_FAMILY,
      // color: Colors.white,
    );
    final packageInfo = Get.find<PackageInfo>();
    _appName = packageInfo.appName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;

    if (!Get.isRegistered<SoundService>()) {
      Get.put<SoundService>(SoundService());
    }

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _appName = packageInfo.appName;
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AboutScreen.shortTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'App Name:',
                style: _fieldStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: Text(
                _appName,
                style: _valueStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
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
            Divider(),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text("Quick Start"),
                onPressed: () async {
                  if (await canLaunch(QUICK_START_URL)) {
                    launch(QUICK_START_URL);
                  } else {
                    Get.snackbar("Attention", "Cannot open URL");
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text("Frequently Asked Questions"),
                onPressed: () async {
                  if (await canLaunch(FAQ_URL)) {
                    launch(FAQ_URL);
                  } else {
                    Get.snackbar("Attention", "Cannot open URL");
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text("Known Issues"),
                onPressed: () async {
                  if (await canLaunch(KNOWN_ISSUES_URL)) {
                    launch(KNOWN_ISSUES_URL);
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
