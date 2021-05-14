import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import 'device_leaderboard.dart';

class LeaderboardDeviceHubScreen extends StatefulWidget {
  final List<Tuple2<String, String>> devices;

  LeaderboardDeviceHubScreen({Key key, @required this.devices})
      : assert(devices != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => LeaderboardDeviceHubScreenState(devices: devices);
}

class LeaderboardDeviceHubScreenState extends State<LeaderboardDeviceHubScreen> {
  final List<Tuple2<String, String>> devices;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _textStyle;

  LeaderboardDeviceHubScreenState({@required this.devices}) : assert(devices != null);

  @override
  Widget build(BuildContext context) {
    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = Get.mediaQuery.size.width / 5;
      _textStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault / 2,
      ).merge(TextStyle(color: Colors.black));
    }
    final buttonStyle = ElevatedButton.styleFrom(primary: Colors.grey.shade200);

    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard Devices')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: devices
              .map(
                (device) => Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    onPressed: () => Get.to(DeviceLeaderboardScreen(device: device)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextOneLine(
                          "${device.item2} (${device.item1})",
                          style: _textStyle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                      ],
                    ),
                    style: buttonStyle,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
