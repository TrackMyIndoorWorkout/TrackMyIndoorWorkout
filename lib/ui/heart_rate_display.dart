import 'dart:async';

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
  // ignore: cancel_subscriptions
  StreamSubscription _subscription;
  int _heartRate;

  @override
  void initState() {
    super.initState();
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _subscription = _heartRateMonitor.pumpMetric((heartRate) {
      setState(() {
        _heartRate = heartRate;
      });
    });
  }

  @override
  void dispose() {
    _heartRateMonitor.cancelSubscription(_subscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_heartRate?.toString() ?? "--");
  }
}
