import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../preferences/enforced_time_zone.dart';
import '../preferences/welcome_presented.dart';
import '../utils/constants.dart';

class AboutScreen extends StatefulWidget {
  static String shortTitle = "About";
  static const hostUrl = "https://trackmyindoorworkout.github.io/";
  static const quickStartUrl = "${hostUrl}2020/09/25/quick-start.html";
  static const faqUrl = "${hostUrl}2020/09/22/frequently-asked-questions.html";
  static const knownIssuesUrl = "${hostUrl}2020/09/26/known-issues.html";
  static const changeLogUrl = "${hostUrl}changelog";
  static const attributionsUrl = "${hostUrl}attributions";
  static const privacyPolicyUrl = "${hostUrl}privacy/";

  const AboutScreen({Key? key}) : super(key: key);

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  late String _version;
  late String _buildNumber;
  String _detectedTimeZone = "";
  String _enforcedTimeZone = "";
  TextStyle _fieldStyle = const TextStyle();
  TextStyle _valueStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _fieldStyle = Get.textTheme.headline5!;
    _valueStyle = Get.textTheme.headline6!.apply(fontFamily: fontFamily);
    final packageInfo = Get.find<PackageInfo>();
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;

    FlutterNativeTimezone.getLocalTimezone().then((String timeZone) {
      setState(() {
        _detectedTimeZone = timeZone;
      });
    });

    final prefService = Get.find<BasePrefService>();
    _enforcedTimeZone = prefService.get<String>(enforcedTimeZoneTag) ?? enforcedTimeZoneDefault;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];
    if (kDebugMode) {
      actions.add(IconButton(
        icon: const Icon(Icons.build),
        onPressed: () async {
          Get.find<BasePrefService>().set(welcomePresentedTag, welcomePresentedDefault);
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AboutScreen.shortTitle),
        actions: actions,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ..._valueWithTitle(title: 'Version:', value: _version, oneLine: true),
          ..._valueWithTitle(title: 'Build#:', value: _buildNumber, oneLine: true),
          ..._valueWithTitle(title: 'Detected Time Zone:', value: _detectedTimeZone),
          ..._valueWithTitle(title: 'Enforced Time Zone:', value: _enforcedTimeZone),
          const Divider(),
          _buttonWithLink(buttonText: "Privacy Policy", linkUrl: AboutScreen.privacyPolicyUrl),
          _buttonWithLink(buttonText: "Quick Start", linkUrl: AboutScreen.quickStartUrl),
          _buttonWithLink(buttonText: "Frequently Asked Questions", linkUrl: AboutScreen.faqUrl),
          _buttonWithLink(buttonText: "Known Issues", linkUrl: AboutScreen.knownIssuesUrl),
          _buttonWithLink(buttonText: "Change Log", linkUrl: AboutScreen.changeLogUrl),
          _buttonWithLink(buttonText: "Attributions", linkUrl: AboutScreen.attributionsUrl),
        ],
      ),
    );
  }

  Widget _buttonWithLink({required String buttonText, required String linkUrl}) => Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: Text(buttonText),
          onPressed: () async {
            if (await canLaunchUrlString(linkUrl)) {
              launchUrlString(linkUrl);
            } else {
              Get.snackbar("Attention", "Cannot open URL");
            }
          },
        ),
      );

  List<Widget> _valueWithTitleCore({required String title, required String value}) => [
        Text(
          title,
          style: _fieldStyle,
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: _valueStyle,
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ];

  List<Widget> _valueWithTitle({
    required String title,
    required String value,
    bool oneLine = false,
  }) =>
      oneLine
          ? [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _valueWithTitleCore(title: title, value: value)),
            ]
          : _valueWithTitleCore(title: title, value: value);
}
