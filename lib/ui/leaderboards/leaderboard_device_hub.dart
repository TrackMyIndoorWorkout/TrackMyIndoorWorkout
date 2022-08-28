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
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline5!.apply(
          fontFamily: fontFamily,
          color: Colors.white,
        );
    final sizeDefault = textStyle.fontSize! * 3;
    final subTextStyle = Theme.of(context).textTheme.headline6!.apply(
          fontFamily: fontFamily,
          color: Colors.white,
        );

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
                            style: textStyle,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextOneLine(
                            "(${device.item1})",
                            style: subTextStyle,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Icon(Icons.chevron_right, size: sizeDefault),
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
