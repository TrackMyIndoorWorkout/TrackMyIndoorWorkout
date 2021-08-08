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
  bool _pairingHrm = false;
  List<String> _scanResults = [];
  ThemeManager _themeManager = Get.find<ThemeManager>();
  HeartRateMonitor? _heartRateMonitor;

  @override
  void dispose() {
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  void _startScan() {
    if (_isScanning) {
      return;
    }

    _scanResults.clear();
    _isScanning = true;

    FlutterBlue.instance
        .startScan(timeout: Duration(seconds: _scanDuration))
        .whenComplete(() => {_isScanning = false});
  }

  @override
  void initState() {
    super.initState();
    final prefService = Get.find<BasePrefService>();
    _scanDuration = prefService.get<int>(SCAN_DURATION_TAG) ?? SCAN_DURATION_DEFAULT;
    _captionStyle = Get.textTheme.caption!.apply(fontSizeFactor: FONT_SIZE_FACTOR);
    _subtitleStyle = _captionStyle.apply(fontFamily: FONT_FAMILY);
    _isScanning = false;
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _startScan();
        },
        child: ListView(
          physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
          children: [
            Column(
              children: [
                _heartRateMonitor != null
                    ? ListTile(
                        title: TextOneLine(
                          _heartRateMonitor?.device?.name ?? EMPTY_MEASUREMENT,
                          overflow: TextOverflow.ellipsis,
                          style: _themeManager.boldStyle(
                            _captionStyle,
                            fontSizeFactor: FONT_SIZE_FACTOR,
                          ),
                        ),
                        subtitle: Text(
                          _heartRateMonitor?.device?.id.id ?? EMPTY_MEASUREMENT,
                          style: _subtitleStyle,
                        ),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: _heartRateMonitor?.device?.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == BluetoothDeviceState.connected) {
                              return _themeManager.getGreenFab(Icons.favorite, false, false, "",
                                  () {
                                Get.snackbar("Info", "Already connected");
                              });
                            } else {
                              return _themeManager.getGreyFab(Icons.bluetooth, () {
                                setState(() {
                                  _heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                                      ? Get.find<HeartRateMonitor>()
                                      : null;
                                });
                              });
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
                      return HeartRateMonitorScanResultTile(
                          result: r,
                          onTap: () async {
                            setState(() {
                              _pairingHrm = true;
                            });

                            var heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                                ? Get.find<HeartRateMonitor>()
                                : null;
                            final existingId = heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE;
                            final storedId = _heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE;
                            if (existingId != NOT_AVAILABLE && existingId != r.device.id.id) {
                              if (!(await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('You are connected to a HRM right now'),
                                      content: Text(
                                          'Disconnect from that HRM to connect the selected one?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.close(1),
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false)) {
                                if (existingId != storedId) {
                                  setState(() {
                                    _heartRateMonitor = heartRateMonitor;
                                  });
                                } else {
                                  await Get.delete<HeartRateMonitor>();
                                  setState(() {
                                    _heartRateMonitor = null;
                                  });
                                }

                                setState(() {
                                  _pairingHrm = false;
                                });
                                return;
                              }
                            }

                            if (heartRateMonitor != null && existingId != r.device.id.id) {
                              await heartRateMonitor.detach();
                              await heartRateMonitor.disconnect();
                            }

                            if (heartRateMonitor == null || existingId != r.device.id.id) {
                              heartRateMonitor = new HeartRateMonitor(r.device);
                              if (Get.isRegistered<HeartRateMonitor>()) {
                                Get.delete<HeartRateMonitor>();
                              }

                              Get.put<HeartRateMonitor>(heartRateMonitor);
                              await heartRateMonitor.connect();
                              await heartRateMonitor.discover();
                              setState(() {
                                _heartRateMonitor = heartRateMonitor;
                              });
                            } else if (existingId != storedId) {
                              setState(() {
                                _heartRateMonitor = heartRateMonitor;
                              });
                            }

                            await heartRateMonitor.attach();
                            setState(() {
                              _pairingHrm = false;
                            });
                          });
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
            _themeManager.getBlueFab(
                Icons.clear, false, false, "Close", () => Get.back(result: true)),
            StreamBuilder<bool>(
              stream: FlutterBlue.instance.isScanning,
              initialData: true,
              builder: (c, snapshot) {
                if (snapshot.data == null || snapshot.data!) {
                  return JumpingDotsProgressIndicator(
                    fontSize: 30.0,
                    color: _themeManager.getProtagonistColor(),
                  );
                } else if (_pairingHrm) {
                  return HeartbeatProgressIndicator(
                    child: IconButton(icon: Icon(Icons.hourglass_empty), onPressed: () => {}),
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
