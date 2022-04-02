import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:url_launcher/url_launcher.dart';
import '../preferences/enforced_time_zone.dart';
import '../preferences/palette_spec.dart';
import '../utils/constants.dart';

class AboutScreen extends StatefulWidget {
  static String shortTitle = "About";

  const AboutScreen({Key? key}) : super(key: key);

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  static const hostUrl = "https://trackmyindoorworkout.github.io/";
  static const quickStartUrl = "${hostUrl}2020/09/25/quick-start.html";
  static const faqUrl = "${hostUrl}2020/09/22/frequently-asked-questions.html";
  static const knownIssuesUrl = "${hostUrl}2020/09/26/known-issues.html";
  static const changeLogUrl = "${hostUrl}changelog";
  static const attributionsUrl = "${hostUrl}attributions";

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
          final prefService = Get.find<BasePrefService>();
          for (final lightOrDark in [false, true]) {
            for (final fgOrBg in [false, true]) {
              for (final paletteSize in [5, 6, 7]) {
                final tag = PaletteSpec.getPaletteTag(lightOrDark, fgOrBg, paletteSize);
                final str = PaletteSpec.getDefaultPaletteString(lightOrDark, fgOrBg, paletteSize);
                prefService.set<String>(tag, str);
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
            ..._valueWithTitle(title: 'Version:', value: _version),
            ..._valueWithTitle(title: 'Build#:', value: _buildNumber),
            ..._valueWithTitle(title: 'Detected Time Zone:', value: _detectedTimeZone),
            ..._valueWithTitle(title: 'Enforced Time Zone:', value: _enforcedTimeZone),
            const Divider(),
            _buttonWithLink(buttonText: "Quick Start", linkUrl: quickStartUrl),
            _buttonWithLink(buttonText: "Frequently Asked Questions", linkUrl: faqUrl),
            _buttonWithLink(buttonText: "Known Issues", linkUrl: knownIssuesUrl),
            _buttonWithLink(buttonText: "Change Log", linkUrl: changeLogUrl),
            _buttonWithLink(buttonText: "Attributions", linkUrl: attributionsUrl),
          ],
        ),
      ),
    );
  }

  Widget _buttonWithLink({required String buttonText, required String linkUrl}) => Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: Text(buttonText),
          onPressed: () async {
            if (await canLaunch(linkUrl)) {
              launch(linkUrl);
            } else {
              Get.snackbar("Attention", "Cannot open URL");
            }
          },
        ),
      );

  List<Widget> _valueWithTitle({required String title, required String value}) => [
        Flexible(
          child: Text(
            title,
            style: _fieldStyle,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: _valueStyle,
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        )
      ];
}
