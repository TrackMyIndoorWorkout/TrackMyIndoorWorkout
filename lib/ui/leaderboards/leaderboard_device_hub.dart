import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
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
  TextStyle _subTextStyle;

  LeaderboardDeviceHubScreenState({@required this.devices}) : assert(devices != null);

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = _mediaWidth / 5;
      _textStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _mediaWidth / 16,
        color: Get.textTheme.button.color,
      );
      _subTextStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _mediaWidth / 20,
        color: Get.textTheme.button.color,
      );
    }

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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextOneLine(
                              device.item2,
                              style: _textStyle,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            TextOneLine(
                              "(${device.item1})",
                              style: _subTextStyle,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, size: _sizeDefault),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
