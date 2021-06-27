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
  bool _isScanning = false;
  List<String> _scanResults = [];
  ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  void dispose() {
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  void _startScan() {
    if (_isScanning) {
      return;
    }

    setState(() {
      _scanResults.clear();
      _isScanning = true;
      FlutterBlue.instance
          .startScan(timeout: Duration(seconds: _scanDuration))
          .whenComplete(() => {_isScanning = false});
    });
  }

  @override
  void initState() {
    super.initState();
    final prefService = Get.find<BasePrefService>();
    _scanDuration = prefService.get<int>(SCAN_DURATION_TAG) ?? SCAN_DURATION_DEFAULT;
    _captionStyle = Get.textTheme.caption!.apply(fontSizeFactor: FONT_SIZE_FACTOR);
    _subtitleStyle = _captionStyle.apply(fontFamily: FONT_FAMILY);
    _isScanning = false;
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
            Column(
              children: [
                Get.isRegistered<HeartRateMonitor>()
                    ? ListTile(
                        title: TextOneLine(
                          Get.find<HeartRateMonitor>().device?.name ?? EMPTY_MEASUREMENT,
                          overflow: TextOverflow.ellipsis,
                          style: _themeManager.boldStyle(_captionStyle,
                              fontSizeFactor: FONT_SIZE_FACTOR),
                        ),
                        subtitle: Text(
                            Get.find<HeartRateMonitor>().device?.id.id ?? EMPTY_MEASUREMENT,
                            style: _subtitleStyle),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: Get.find<HeartRateMonitor>().device?.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == BluetoothDeviceState.connected) {
                              return _themeManager.getGreenFab(Icons.favorite, () {
                                Get.snackbar("Info", "Already connected");
                              });
                            } else {
                              return _themeManager.getGreenFab(Icons.bluetooth_disabled, null);
                            }
                          },
                        ),
                      )
                    : Container(),
              ],
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
