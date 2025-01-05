import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../utils/constants.dart';
import '../../utils/string_ex.dart';
import 'device_leaderboard.dart';

class LeaderboardDeviceHubScreen extends StatefulWidget {
  final List<Tuple3<String, String, String>> devices;

  const LeaderboardDeviceHubScreen({super.key, required this.devices});

  @override
  LeaderboardDeviceHubScreenState createState() => LeaderboardDeviceHubScreenState();
}

class LeaderboardDeviceHubScreenState extends State<LeaderboardDeviceHubScreen> {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge!.apply(
          fontFamily: fontFamily,
          color: Colors.white,
        );
    final sizeDefault = textStyle.fontSize! * 3;
    final subTextStyle = Theme.of(context).textTheme.titleLarge!.apply(
          fontFamily: fontFamily,
          color: Colors.white,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard Devices')),
      body: ListView.separated(
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, index) => ElevatedButton(
                onPressed: () =>
                    Get.to(() => DeviceLeaderboardScreen(device: widget.devices[index])),
                child: FitHorizontally(
                  shrinkLimit: shrinkLimit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.devices[index].item1, style: textStyle),
                          Text(widget.devices[index].item2.shortAddressString(),
                              style: subTextStyle),
                        ],
                      ),
                      Icon(Icons.chevron_right, size: sizeDefault),
                    ],
                  ),
                ),
              ),
          separatorBuilder: (context, index) => const SizedBox(width: 10, height: 10),
          itemCount: widget.devices.length),
    );
  }
}
