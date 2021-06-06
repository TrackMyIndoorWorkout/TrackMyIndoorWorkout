import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../utils/constants.dart';
import 'device_leaderboard.dart';

class LeaderboardDeviceHubScreen extends StatefulWidget {
  final List<Tuple2<String, String>> devices;

  LeaderboardDeviceHubScreen({Key? key, required this.devices}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LeaderboardDeviceHubScreenState(devices: devices);
}

class LeaderboardDeviceHubScreenState extends State<LeaderboardDeviceHubScreen> {
  final List<Tuple2<String, String>> devices;
  late double _sizeDefault;
  late TextStyle _textStyle;
  late TextStyle _subTextStyle;

  LeaderboardDeviceHubScreenState({required this.devices});

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headline5!.apply(
      fontFamily: FONT_FAMILY,
      color: Colors.white,
    );
    _sizeDefault = _textStyle.fontSize! * 3;
    _subTextStyle = Get.textTheme.headline6!.apply(
      fontFamily: FONT_FAMILY,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
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
