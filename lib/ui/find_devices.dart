import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:preferences/preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';
import '../devices/bluetooth_device_ex.dart';
import '../devices/gatt_constants.dart';
import '../devices/heart_rate_monitor.dart';
import '../persistence/preferences.dart';
import '../strava/strava_service.dart';
import 'activities.dart';
import 'preferences.dart';
import 'recording.dart';
import 'scan_result.dart';

const HELP_URL = "https://trackmyindoorworkout.github.io/2020/09/25/quick-start.html";

class FindDevicesScreen extends StatefulWidget {
  FindDevicesScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FindDevicesState();
  }
}

standOutStyle(TextStyle style, double fontSizeFactor) {
  return style.apply(
    fontSizeFactor: fontSizeFactor,
    color: Colors.black,
    fontWeightDelta: 3,
  );
}

class FindDevicesState extends State<FindDevicesScreen> {
  static const fontSizeFactor = 1.5;

  bool _instantScan;
  int _scanDuration;
  bool _autoConnect;
  String _lastEquipmentId;
  bool _filterDevices;
  BluetoothDevice _openedDevice;
  List<BluetoothDevice> _scannedDevices;
  TextStyle _adjustedCaptionStyle;
  TextStyle _subtitleStyle;
  Map<String, List<String>> _servicesMap;
  int _heartRate;

  @override
  dispose() {
    FlutterBlue.instance.stopScan();
    var heartRateMonitor =
        Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    heartRateMonitor?.cancelSubscription();
    super.dispose();
  }

  startScan() {
    setState(() {
      _scannedDevices.clear();
    });
    FlutterBlue.instance.startScan(timeout: Duration(seconds: _scanDuration));
  }

  addScannedDevice(ScanResult scanResult) {
    if (!scanResult.isWorthy(_filterDevices)) {
      return;
    }

    _servicesMap[scanResult.device.id.id] = scanResult.serviceUuids;

    if (_scannedDevices.where((d) => d.id.id == scanResult.device.id.id).length > 0) {
      return;
    }

    _scannedDevices.add(scanResult.device);
  }

  bool _isHeartRateMonitor(List<String> serviceUuids) {
    return serviceUuids?.contains(HEART_RATE_SERVICE_ID) ?? false;
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
    _scannedDevices = [];
    _instantScan = PrefService.getBool(INSTANT_SCAN_TAG);
    _scanDuration = PrefService.getInt(SCAN_DURATION_TAG);
    _autoConnect = PrefService.getBool(AUTO_CONNECT_TAG);
    _lastEquipmentId = PrefService.getString(LAST_EQUIPMENT_ID_TAG);
    _filterDevices = PrefService.getBool(DEVICE_FILTERING_TAG);
    _servicesMap = Map<String, List<String>>();
    if (_instantScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startScan();
      });
    }
    var heartRateMonitor =
        Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    heartRateMonitor?.pumpMetric((heartRate) {
      setState(() {
        _heartRate = heartRate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_adjustedCaptionStyle == null) {
      _adjustedCaptionStyle = Theme.of(context)
          .textTheme
          .caption
          .apply(fontSizeFactor: FindDevicesState.fontSizeFactor);
      _subtitleStyle = _adjustedCaptionStyle.apply(fontFamily: FONT_FAMILY);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_filterDevices ? 'Supported Exercise Equipment:' : 'Bluetooth Devices'),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: _instantScan,
            builder: (c, snapshot) {
              if (snapshot.data) {
                return JumpingDotsProgressIndicator(
                  fontSize: 30.0,
                  color: Colors.white,
                );
              } else {
                if (_autoConnect) {
                  if (_openedDevice != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Get.to(RecordingScreen(
                        device: _openedDevice,
                        serviceUuids: _servicesMap[_openedDevice.id.id],
                        initialState: BluetoothDeviceState.connected,
                        size: Get.mediaQuery.size,
                      ));
                    });
                  } else {
                    if (_filterDevices && _scannedDevices.length == 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Get.to(RecordingScreen(
                          device: _scannedDevices.first,
                          serviceUuids: _servicesMap[_scannedDevices.first.id.id],
                          initialState: BluetoothDeviceState.disconnected,
                          size: Get.mediaQuery.size,
                        ));
                      });
                    } else if (_scannedDevices.length > 1 && _lastEquipmentId.length > 0) {
                      final lasts = _scannedDevices.where((d) => d.id.id == _lastEquipmentId);
                      if (lasts.length > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Get.to(RecordingScreen(
                            device: lasts.first,
                            serviceUuids: _servicesMap[_scannedDevices.first.id.id],
                            initialState: BluetoothDeviceState.disconnected,
                            size: Get.mediaQuery.size,
                          ));
                        });
                      }
                    }
                  }
                }
                return Container();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => startScan(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data.map((d) {
                    _openedDevice = d;
                    return ListTile(
                      title: TextOneLine(
                        d.name,
                        overflow: TextOverflow.ellipsis,
                        style: standOutStyle(
                          _adjustedCaptionStyle,
                          fontSizeFactor,
                        ),
                      ),
                      subtitle: Text(d.id.id, style: _subtitleStyle),
                      trailing: StreamBuilder<BluetoothDeviceState>(
                        stream: d.state,
                        initialData: BluetoothDeviceState.disconnected,
                        builder: (c, snapshot) {
                          if (snapshot.data == BluetoothDeviceState.connected) {
                            return FloatingActionButton(
                                heroTag: null,
                                child: _isHeartRateMonitor(_servicesMap[d.id.id])
                                    ? ((Get.isRegistered<HeartRateMonitor>() &&
                                            Get.find<HeartRateMonitor>()?.device?.id?.id == d.id.id)
                                        ? Text(_heartRate?.toString() ?? "--")
                                        : Icon(Icons.favorite))
                                    : Icon(Icons.open_in_new),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                onPressed: () async {
                                  if (_isHeartRateMonitor(_servicesMap[d.id.id])) {
                                    return;
                                  }
                                  await FlutterBlue.instance.stopScan();
                                  await Future.delayed(Duration(milliseconds: 100));
                                  await Get.to(RecordingScreen(
                                    device: d,
                                    serviceUuids: _servicesMap[d.id.id],
                                    initialState: snapshot.data,
                                    size: Get.mediaQuery.size,
                                  ));
                                });
                          } else {
                            return Text(snapshot.data.toString());
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data.where((d) => d.isWorthy(_filterDevices)).map((r) {
                    addScannedDevice(r);
                    if (_autoConnect && r.device.id.id == _lastEquipmentId) {
                      FlutterBlue.instance.stopScan().whenComplete(() async {
                        await Future.delayed(Duration(milliseconds: 100));
                      });
                    }
                    return ScanResultTile(
                      result: r,
                      onEquipmentTap: () async {
                        await FlutterBlue.instance.stopScan();
                        await Future.delayed(Duration(milliseconds: 100));
                        bool goOn = true;
                        if (!r.device.getDescriptor(r.serviceUuids).canMeasureHeartRate &&
                            (!Get.isRegistered<HeartRateMonitor>() ||
                                Get.find<HeartRateMonitor>() == null)) {
                          bool dialogResult = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Heart Rate Measurement'),
                                  content: Text('Are you sure you want to continue without a HRM?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Get.close(1),
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          goOn = dialogResult;
                        }
                        if (goOn) {
                          await Get.to(RecordingScreen(
                            device: r.device,
                            serviceUuids: r.serviceUuids,
                            initialState: BluetoothDeviceState.disconnected,
                            size: Get.mediaQuery.size,
                          ));
                        }
                      },
                      onHrmTap: () async {
                        var heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                            ? Get.find<HeartRateMonitor>()
                            : null;
                        if (heartRateMonitor != null &&
                            heartRateMonitor.device.id.id != r.device.id.id) {
                          if (!(await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('You are connected to a HRM right now'),
                                  content:
                                      Text('Disconnect from that HRM to connect the selected one?'),
                                  actions: <Widget>[
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
                            return;
                          }
                        }
                        if (heartRateMonitor != null &&
                            heartRateMonitor.device.id.id != r.device.id.id) {
                          await heartRateMonitor.detach();
                          await heartRateMonitor.disconnect();
                        }
                        if (heartRateMonitor == null ||
                            heartRateMonitor.device?.id?.id != r.device.id.id) {
                          heartRateMonitor = new HeartRateMonitor(r.device);
                          Get.put<HeartRateMonitor>(heartRateMonitor);
                          await heartRateMonitor.connect();
                        }
                        await heartRateMonitor.attach();
                        heartRateMonitor.pumpMetric((heartRate) {
                          setState(() {
                            _heartRate = heartRate;
                          });
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FabCircularMenu(
        fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
        fabCloseIcon: const Icon(Icons.close, color: Colors.white),
        children: [
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.help),
            foregroundColor: Colors.lightBlue,
            backgroundColor: Colors.white,
            onPressed: () async {
              if (await canLaunch(HELP_URL)) {
                launch(HELP_URL);
              } else {
                Get.snackbar("Attention", "Cannot open URL");
              }
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(BrandIcons.strava),
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepOrangeAccent,
            onPressed: () async {
              StravaService stravaService;
              if (!Get.isRegistered<StravaService>()) {
                stravaService = Get.put<StravaService>(StravaService());
              } else {
                stravaService = Get.find<StravaService>();
              }
              final success = await stravaService.login();
              if (success) {
                Get.snackbar("Success", "Successful Strava login");
              } else {
                Get.snackbar("Warning", "Strava login unsuccessful");
              }
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.list_alt),
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            onPressed: () async => Get.to(ActivitiesScreen()),
          ),
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: _instantScan,
            builder: (c, snapshot) {
              if (snapshot.data) {
                return FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.stop),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo,
                  onPressed: () async {
                    await FlutterBlue.instance.stopScan();
                    await Future.delayed(Duration(milliseconds: 100));
                  },
                );
              } else {
                return FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.search),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  onPressed: () =>
                      FlutterBlue.instance.startScan(timeout: Duration(seconds: _scanDuration)),
                );
              }
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.settings),
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            onPressed: () async => Get.to(PreferencesScreen()),
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.filter_alt),
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            onPressed: () async {
              Get.defaultDialog(
                title: 'Device filtering',
                middleText: 'Should the app try to filter supported devices? ' +
                    'Yes: filter. No: show all nearby Bluetooth devices',
                confirm: TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    PrefService.setBool(DEVICE_FILTERING_TAG, true);
                    setState(() {
                      _filterDevices = true;
                    });
                    Get.close(1);
                  },
                ),
                cancel: TextButton(
                  child: Text("No"),
                  onPressed: () {
                    PrefService.setBool(DEVICE_FILTERING_TAG, false);
                    setState(() {
                      _filterDevices = false;
                    });
                    Get.close(1);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
