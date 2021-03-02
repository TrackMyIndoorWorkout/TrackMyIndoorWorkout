import 'package:flutter/material.dart';
import '../devices/heart_rate_monitor.dart';

class HeartRateDisplay extends StatefulWidget {
  final HeartRateMonitor hrm;
  HeartRateDisplay({Key key, @required this.hrm})
      : assert(hrm != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HeartRateDisplayState(hrm: hrm);
  }
}

class HeartRateDisplayState extends State<HeartRateDisplay> {
  final HeartRateMonitor hrm;

  HeartRateDisplayState({@required this.hrm}) : assert(hrm != null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: hrm.listenForYourHeart,
        initialData: 0,
        builder: (c, snapshot) {
          return Text(snapshot.data?.toString() ?? "--");
        });
  }
}
