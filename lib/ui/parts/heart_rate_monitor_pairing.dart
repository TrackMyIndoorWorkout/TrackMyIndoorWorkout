import 'dart:async';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';

import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../devices/bluetooth_device_ex.dart';
import '../../preferences/log_level.dart';
import '../../preferences/scan_duration.dart';
import '../../utils/bluetooth.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/logging.dart';
import '../../utils/string_ex.dart';
import '../../utils/theme_manager.dart';
import 'boolean_question.dart';
import 'heart_rate_monitor_scan_result.dart';

class HeartRateMonitorPairingBottomSheet extends StatefulWidget {
  const HeartRateMonitorPairingBottomSheet({super.key});

  @override
  HeartRateMonitorPairingBottomSheetState createState() =>
      HeartRateMonitorPairingBottomSheetState();
}

class HeartRateMonitorPairingBottomSheetState extends State<HeartRateMonitorPairingBottomSheet> {
  static const String tag = "HRM_PAIRING";

  int _scanDuration = 4;
  TextStyle _captionStyle = const TextStyle();
  TextStyle _subtitleStyle = const TextStyle();
  bool _isScanning = false;
  bool _pairingHrm = false;
  final List<String> _scanResults = [];
  final StreamController<List<ScanResult>> _scanStreamController = StreamController.broadcast();
  StreamSubscription<List<ScanResult>>? _scanStreamSubscription;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  HeartRateMonitor? _heartRateMonitor;
  int _logLevel = logLevelDefault;

  @override
  void dispose() {
    _scanStreamSubscription?.pause();
    try {
      FlutterBluePlus.stopScan();
    } on Exception catch (e, stack) {
      Logging().logException(_logLevel, tag, "dispose", "FlutterBluePlus.stopScan", e, stack);
    }

    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) {
      return;
    }

    _scanResults.clear();
    setState(() {
      _isScanning = true;
    });

    _isScanning = true;

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: _scanDuration));
      setState(() {
        _isScanning = false;
      });
    } on Exception catch (e, stack) {
      Logging().logException(_logLevel, tag, "_startScan", "FlutterBluePlus.startScan", e, stack);
    }

    Logging().logVersion(Get.find<PackageInfo>());
  }

  Stream<List<ScanResult>> get _throttledScanStream async* {
    await for (var scanResults in FlutterBluePlus.scanResults.throttleTime(
      const Duration(milliseconds: uiIntermittentDelay),
      leading: false,
      trailing: true,
    )) {
      yield scanResults;
    }
  }

  @override
  void initState() {
    super.initState();
    final prefService = Get.find<BasePrefService>();
    _logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    _scanDuration = prefService.get<int>(scanDurationTag) ?? scanDurationDefault;
    _captionStyle = Get.textTheme.bodySmall!.apply(fontSizeFactor: fontSizeFactor);
    _subtitleStyle = _captionStyle.apply(fontFamily: fontFamily);
    _isScanning = false;
    _scanStreamSubscription =
        _throttledScanStream.listen((scanResults) => _scanStreamController.add(scanResults));
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _startScan();
        },
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: [
            Column(
              children: [
                _heartRateMonitor != null
                    ? ListTile(
                        title: TextOneLine(
                          _heartRateMonitor?.device?.nonEmptyName ?? emptyMeasurement,
                          overflow: TextOverflow.ellipsis,
                          style: _themeManager.boldStyle(
                            _captionStyle,
                            fontSizeFactor: fontSizeFactor,
                          ),
                        ),
                        subtitle: Text(
                          _heartRateMonitor?.device?.remoteId.str.shortAddressString() ??
                              emptyMeasurement,
                          style: _subtitleStyle,
                        ),
                        trailing: _themeManager.getGreenFab(Icons.favorite, () async {
                          if (await _heartRateMonitor?.device?.connectionState.first ==
                              BluetoothConnectionState.connected) {
                            Get.snackbar("Info", "Already connected");
                          } else {
                            setState(() {
                              _heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                                  ? Get.find<HeartRateMonitor>()
                                  : null;
                            });
                          }
                        }),
                      )
                    : Container(),
              ],
            ),
            const Divider(),
            StreamBuilder<List<ScanResult>>(
              stream: _scanStreamController.stream,
              initialData: const [],
              builder: (c, snapshot) => snapshot.data == null
                  ? Container()
                  : Column(
                      children: snapshot.data!.where((d) => d.isWorthy()).map((r) {
                      _scanResults.add(r.device.remoteId.str);
                      return HeartRateMonitorScanResultTile(
                          result: r,
                          onTap: () async {
                            if (!await bluetoothCheck(false, _logLevel)) {
                              return;
                            }

                            setState(() {
                              _pairingHrm = true;
                            });

                            var heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                                ? Get.find<HeartRateMonitor>()
                                : null;
                            final existingId =
                                heartRateMonitor?.device?.remoteId.str ?? notAvailable;
                            final storedId =
                                _heartRateMonitor?.device?.remoteId.str ?? notAvailable;
                            if (existingId != notAvailable && existingId != r.device.remoteId.str) {
                              final verdict = await Get.bottomSheet(
                                const SafeArea(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: BooleanQuestionBottomSheet(
                                            title: "You are connected to a HRM right now",
                                            content:
                                                "Disconnect from that HRM to connect the selected one?",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                isScrollControlled: true,
                                ignoreSafeArea: false,
                                isDismissible: false,
                                enableDrag: false,
                              );

                              if (!verdict) {
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

                            if (heartRateMonitor != null && existingId != r.device.remoteId.str) {
                              await heartRateMonitor.detach();
                              await heartRateMonitor.disconnect();
                            }

                            if (heartRateMonitor == null || existingId != r.device.remoteId.str) {
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
            _themeManager.getBlueFab(Icons.clear, () => Get.back(result: true)),
            const SizedBox(width: 10, height: 10),
            _isScanning
                ? JumpingDotsProgressIndicator(
                    fontSize: 30.0,
                    color: _themeManager.getProtagonistColor(),
                  )
                : _pairingHrm
                    ? HeartbeatProgressIndicator(
                        child: IconButton(
                            icon: const Icon(Icons.hourglass_empty), onPressed: () => {}),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async => await _startScan(),
                      )
          ],
        ),
      ),
    );
  }
}
