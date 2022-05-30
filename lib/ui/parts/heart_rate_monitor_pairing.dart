import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../preferences/scan_duration.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import 'heart_rate_monitor_scan_result.dart';

class HeartRateMonitorPairingBottomSheet extends StatefulWidget {
  const HeartRateMonitorPairingBottomSheet({Key? key}) : super(key: key);

  @override
  HeartRateMonitorPairingBottomSheetState createState() =>
      HeartRateMonitorPairingBottomSheetState();
}

class HeartRateMonitorPairingBottomSheetState extends State<HeartRateMonitorPairingBottomSheet> {
  static RegExp colonRegex = RegExp(r'\:');

  int _scanDuration = 4;
  TextStyle _captionStyle = const TextStyle();
  TextStyle _subtitleStyle = const TextStyle();
  bool _isScanning = false;
  bool _pairingHrm = false;
  final List<String> _scanResults = [];
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  HeartRateMonitor? _heartRateMonitor;

  @override
  void dispose() {
    FlutterBluePlus.instance.stopScan();
    super.dispose();
  }

  void _startScan() {
    if (_isScanning) {
      return;
    }

    _scanResults.clear();
    _isScanning = true;

    FlutterBluePlus.instance
        .startScan(timeout: Duration(seconds: _scanDuration))
        .whenComplete(() => {_isScanning = false});
  }

  @override
  void initState() {
    super.initState();
    final prefService = Get.find<BasePrefService>();
    _scanDuration = prefService.get<int>(scanDurationTag) ?? scanDurationDefault;
    _captionStyle = Get.textTheme.caption!.apply(fontSizeFactor: fontSizeFactor);
    _subtitleStyle = _captionStyle.apply(fontFamily: fontFamily);
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
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: [
            Column(
              children: [
                _heartRateMonitor != null
                    ? ListTile(
                        title: TextOneLine(
                          _heartRateMonitor?.device?.name ?? emptyMeasurement,
                          overflow: TextOverflow.ellipsis,
                          style: _themeManager.boldStyle(
                            _captionStyle,
                            fontSizeFactor: fontSizeFactor,
                          ),
                        ),
                        subtitle: Text(
                          _heartRateMonitor?.device?.id.id.replaceAll(colonRegex, '') ??
                              emptyMeasurement,
                          style: _subtitleStyle,
                        ),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: _heartRateMonitor?.device?.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == BluetoothDeviceState.connected) {
                              return _themeManager.getGreenFab(Icons.favorite, false, false, "", 0,
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
            const Divider(),
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.instance.scanResults,
              initialData: const [],
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
                            final existingId = heartRateMonitor?.device?.id.id ?? notAvailable;
                            final storedId = _heartRateMonitor?.device?.id.id ?? notAvailable;
                            if (existingId != notAvailable && existingId != r.device.id.id) {
                              if (!(await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('You are connected to a HRM right now'),
                                      content: const Text(
                                          'Disconnect from that HRM to connect the selected one?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.close(1),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Yes'),
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
                                  await Get.delete<HeartRateMonitor>(force: true);
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
                              heartRateMonitor = HeartRateMonitor(r.device);
                              if (Get.isRegistered<HeartRateMonitor>()) {
                                await Get.delete<HeartRateMonitor>(force: true);
                              }

                              Get.put<HeartRateMonitor>(heartRateMonitor, permanent: true);
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
        margin: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueFab(
                Icons.clear, false, false, "Close", 0, () => Get.back(result: true)),
            StreamBuilder<bool>(
              stream: FlutterBluePlus.instance.isScanning,
              initialData: true,
              builder: (c, snapshot) {
                if (snapshot.data == null || snapshot.data!) {
                  return JumpingDotsProgressIndicator(
                    fontSize: 30.0,
                    color: _themeManager.getProtagonistColor(),
                  );
                } else if (_pairingHrm) {
                  return HeartbeatProgressIndicator(
                    child: IconButton(icon: const Icon(Icons.hourglass_empty), onPressed: () => {}),
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
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
