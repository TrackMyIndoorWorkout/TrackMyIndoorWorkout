import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import 'heart_rate_monitor_scan_result.dart';

class HeartRateMonitorPairingBottomSheet extends StatefulWidget {
  @override
  _HeartRateMonitorPairingBottomSheetState createState() =>
      _HeartRateMonitorPairingBottomSheetState();
}

class _HeartRateMonitorPairingBottomSheetState extends State<HeartRateMonitorPairingBottomSheet> {
  int _scanDuration = 4;
  TextStyle _captionStyle = TextStyle();
  TextStyle _subtitleStyle = TextStyle();
  List<String> _scanResults = [];
  ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void dispose() {
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _scanResults.clear();
      FlutterBlue.instance.startScan(timeout: Duration(seconds: _scanDuration));
    });
  }

  @override
  void initState() {
    super.initState();
    final prefService = Get.find<BasePrefService>();
    _scanDuration = prefService.get<int>(SCAN_DURATION_TAG) ?? SCAN_DURATION_DEFAULT;
    _captionStyle = Get.textTheme.caption!.apply(fontSizeFactor: FONT_SIZE_FACTOR);
    _subtitleStyle = _captionStyle.apply(fontFamily: FONT_FAMILY);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _startScan();
          });
        },
        child: ListView(
          physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
          children: [
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(Duration(seconds: 2))
                  .asyncMap((_) => FlutterBlue.instance.connectedDevices),
              initialData: [],
              builder: (c, snapshot) => snapshot.data == null
                  ? Container()
                  : Column(
                      children: snapshot.data!
                          .where((h) =>
                              _scanResults.contains(h.id.id) ||
                              (Get.isRegistered<HeartRateMonitor>() &&
                                  Get.find<HeartRateMonitor>().device?.id.id == h.id.id))
                          .map((d) {
                        return ListTile(
                          title: TextOneLine(
                            d.name,
                            overflow: TextOverflow.ellipsis,
                            style: _themeManager.boldStyle(_captionStyle,
                                fontSizeFactor: FONT_SIZE_FACTOR),
                          ),
                          subtitle: Text(d.id.id, style: _subtitleStyle),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: d.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (c, snapshot) {
                              if (snapshot.data == BluetoothDeviceState.connected) {
                                return _themeManager.getGreenFab(Icons.favorite, () {
                                  Get.snackbar("Info", "Already connected");
                                });
                              } else {
                                return Text(snapshot.data.toString());
                              }
                            },
                          ),
                        );
                      }).toList(growable: false),
                    ),
            ),
            Divider(),
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: [],
              builder: (c, snapshot) => snapshot.data == null
                  ? Container()
                  : Column(
                      children: snapshot.data!.where((d) => d.isWorthy()).map((r) {
                      _scanResults.add(r.device.id.id);
                      return HeartRateMonitorScanResultTile(result: r);
                    }).toList(growable: false)),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueFab(Icons.clear, () => Get.back(result: true)),
            StreamBuilder<bool>(
              stream: FlutterBlue.instance.isScanning,
              initialData: true,
              builder: (c, snapshot) {
                if (snapshot.data == null || snapshot.data!) {
                  return JumpingDotsProgressIndicator(
                    fontSize: 30.0,
                    color: Colors.white,
                  );
                } else {
                  return IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => _startScan(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
