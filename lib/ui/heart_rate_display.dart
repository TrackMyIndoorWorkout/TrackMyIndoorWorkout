import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../devices/heart_rate_monitor.dart';

class HeartRateDisplay extends StatefulWidget {
  HeartRateDisplay({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HeartRateDisplayState();
  }
}

class HeartRateDisplayState extends State<HeartRateDisplay> {
  HeartRateMonitor _heartRateMonitor;

  @override
  void initState() {
    _heartRateMonitor = Get.find<HeartRateMonitor>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: _heartRateMonitor.listenForYourHeart,
        initialData: 0,
        builder: (c, snapshot) {
          return Text(snapshot.data?.toString() ?? "--");
        });
  }
}
