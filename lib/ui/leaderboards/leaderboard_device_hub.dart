import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../utils/constants.dart';
import 'device_leaderboard.dart';

class LeaderboardDeviceHubScreen extends StatefulWidget {
  final List<Tuple3<String, String, String>> devices;

  const LeaderboardDeviceHubScreen({Key? key, required this.devices}) : super(key: key);

  @override
  LeaderboardDeviceHubScreenState createState() => LeaderboardDeviceHubScreenState();
}

class LeaderboardDeviceHubScreenState extends State<LeaderboardDeviceHubScreen> {
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();
  TextStyle _subTextStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headline5!.apply(
      fontFamily: fontFamily,
      color: Colors.white,
    );
    _sizeDefault = _textStyle.fontSize! * 3;
    _subTextStyle = Get.textTheme.headline6!.apply(
      fontFamily: fontFamily,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard Devices')),
      body: ListView(
        children: widget.devices
            .map(
              (device) => Container(
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: () => Get.to(() => DeviceLeaderboardScreen(device: device)),
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
    );
  }
}
