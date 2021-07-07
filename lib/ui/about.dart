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
  late String _appName;
  late String _packageName;
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
    _packageName = packageInfo.packageName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;

    if (!Get.isRegistered<SoundService>()) {
      Get.put<SoundService>(SoundService());
    }

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _appName = packageInfo.appName;
        _packageName = packageInfo.packageName;
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
                'Package Name:',
                style: _fieldStyle,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: Text(
                _packageName,
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
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.help),
                label: Text("Help"),
                onPressed: () async {
                  if (await canLaunch(HELP_URL)) {
                    launch(HELP_URL);
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
