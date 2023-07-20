import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../utils/constants.dart';
import '../../utils/string_ex.dart';
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
    _textStyle = Get.textTheme.titleLarge!.apply(fontFamily: fontFamily);
    _sizeDefault = _textStyle.fontSize! * 3;
    _subTextStyle = Get.textTheme.titleLarge!.apply(fontFamily: fontFamily);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard Devices')),
      body: ListView.separated(
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, index) => ElevatedButton(
                onPressed: () =>
                    Get.to(() => DeviceLeaderboardScreen(device: widget.devices[index])),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextOneLine(
                          widget.devices[index].item1,
                          style: _textStyle,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                        TextOneLine(
                          widget.devices[index].item2.shortAddressString(),
                          style: _subTextStyle,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: _sizeDefault),
                  ],
                ),
              ),
          separatorBuilder: (context, index) => const SizedBox(width: 10, height: 10),
          itemCount: widget.devices.length),
    );
  }
}
