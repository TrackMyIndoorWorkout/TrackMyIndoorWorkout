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
import '../devices/devices.dart';
import '../devices/gatt_constants.dart';
import '../persistence/preferences.dart';
import '../strava/strava_service.dart';
import 'activities.dart';
import 'preferences.dart';
import 'recording.dart';
import 'scan_result.dart';

const HELP_URL = "https://trackmyindoorworkout.github.io/2020/09/25/quick-start.html";

extension DeviceMathing on ScanResult {
  bool isWorthy(bool filterDevices) {
    if (!advertisementData.connectable) {
      return false;
    }

    if (device.name == null || device.name.length <= 0) {
      return false;
    }

    if (device.id.id == null || device.id.id.length <= 0) {
      return false;
    }

    if (!filterDevices) {
      return true;
    }

    for (var dev in deviceMap.values) {
      if (device.name.startsWith(dev.namePrefix)) {
        return true;
      }
      if (advertisementData.serviceUuids.isNotEmpty) {
        final serviceUuids =
            advertisementData.serviceUuids.map((x) => x.substring(4, 8).toLowerCase()).toList();
        if (serviceUuids.contains(FITNESS_MACHINE_ID) ||
            serviceUuids.contains(PRECOR_SERVICE_ID) ||
            serviceUuids.contains(HEART_RATE_SERVICE_ID)) {
          return true;
        }
      }
    }

    return false;
  }
}

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
  bool _instantWorkout;
  String _lastEquipmentId;
  bool _filterDevices;
  BluetoothDevice _openedDevice;
  List<BluetoothDevice> _scannedDevices;
  TextStyle _adjustedCaptionStyle;
  TextStyle _subtitleStyle;

  @override
  dispose() {
    FlutterBlue.instance.stopScan();
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

    if (_scannedDevices.where((d) => d.id.id == scanResult.device.id.id).length > 0) {
      return;
    }

    _scannedDevices.add(scanResult.device);
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
    _scannedDevices = [];
    _instantScan = PrefService.getBool(INSTANT_SCAN_TAG);
    _scanDuration = PrefService.getInt(SCAN_DURATION_TAG);
    _instantWorkout = PrefService.getBool(INSTANT_WORKOUT_TAG);
    _lastEquipmentId = PrefService.getString(LAST_EQUIPMENT_ID_TAG);
    _filterDevices = PrefService.getBool(DEVICE_FILTERING_TAG);
    if (_instantScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startScan();
      });
    }
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
                if (_instantWorkout) {
                  if (_openedDevice != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Get.to(RecordingScreen(
                        device: _openedDevice,
                        initialState: BluetoothDeviceState.connected,
                        size: Get.mediaQuery.size,
                      ));
                    });
                  } else {
                    if (_filterDevices && _scannedDevices.length == 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Get.to(RecordingScreen(
                          device: _scannedDevices.first,
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
                                child: Icon(Icons.open_in_new),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                onPressed: () async {
                                  await FlutterBlue.instance.stopScan();
                                  await Future.delayed(Duration(milliseconds: 100));
                                  await Get.to(RecordingScreen(
                                      device: d,
                                      initialState: snapshot.data,
                                      size: Get.mediaQuery.size));
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
                    if (_instantWorkout && r.device.id.id == _lastEquipmentId) {
                      FlutterBlue.instance.stopScan().whenComplete(() async {
                        await Future.delayed(Duration(milliseconds: 100));
                      });
                    }
                    return ScanResultTile(
                      result: r,
                      onTap: () async {
                        await FlutterBlue.instance.stopScan();
                        await Future.delayed(Duration(milliseconds: 100));
                        await Get.to(RecordingScreen(
                          device: r.device,
                          initialState: BluetoothDeviceState.disconnected,
                          size: Get.mediaQuery.size,
                        ));
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
