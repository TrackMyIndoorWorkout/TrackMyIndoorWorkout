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
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../persistence/models/device_usage.dart';
import '../devices/bluetooth_device_ex.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/strava_service.dart';
import '../utils/scan_result_ex.dart';
import 'models/advertisement_cache.dart';
import 'parts/common.dart';
import 'parts/scan_result.dart';
import 'parts/sport_picker.dart';
import 'activities.dart';
import 'preferences.dart';
import 'recording.dart';

const HELP_URL = "https://trackmyindoorworkout.github.io/2020/09/25/quick-start.html";

class FindDevicesScreen extends StatefulWidget {
  FindDevicesScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FindDevicesState();
  }
}

class FindDevicesState extends State<FindDevicesScreen> {
  bool _instantScan;
  int _scanDuration;
  bool _autoConnect;
  List<String> _lastEquipmentIds;
  bool _filterDevices;
  BluetoothDevice _openedDevice;
  List<BluetoothDevice> _scannedDevices;
  TextStyle _adjustedCaptionStyle;
  TextStyle _subtitleStyle;
  int _heartRate;
  AdvertisementCache _advertisementCache;

  @override
  void dispose() {
    FlutterBlue.instance.stopScan();
    var heartRateMonitor =
        Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    heartRateMonitor?.cancelSubscription();
    super.dispose();
  }

  Future<void> _openDatabase() async {
    final database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2, migration2to3, migration3to4, migration4to5]).build();
    Get.put<AppDatabase>(database);
  }

  void startScan() {
    setState(() {
      _scannedDevices.clear();
    });
    FlutterBlue.instance.startScan(timeout: Duration(seconds: _scanDuration));
  }

  void addScannedDevice(ScanResult scanResult) {
    if (!scanResult.isWorthy(_filterDevices)) {
      return;
    }

    final advertisementCache = Get.find<AdvertisementCache>();
    advertisementCache.addEntry(scanResult);

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
    _autoConnect = PrefService.getBool(AUTO_CONNECT_TAG);
    _lastEquipmentIds = [];
    PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
      final lastEquipmentId = PrefService.getString(LAST_EQUIPMENT_ID_TAG_PREFIX + sport);
      if (lastEquipmentId.isNotEmpty) {
        _lastEquipmentIds.add(lastEquipmentId);
      }
    });
    _filterDevices = PrefService.getBool(DEVICE_FILTERING_TAG);
    if (_instantScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startScan();
      });
    }
    _openDatabase();

    _advertisementCache = Get.find<AdvertisementCache>();

    var heartRateMonitor =
        Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    heartRateMonitor?.pumpMetric((heartRate) {
      setState(() {
        _heartRate = heartRate;
      });
    });
  }

  Future<bool> goToRecording(BluetoothDevice device, BluetoothDeviceState initialState) async {
    if (!_advertisementCache.hasEntry(device.id.id)) {
      return false;
    }

    final advertisementDigest = _advertisementCache.getEntry(device.id.id);
    final descriptor = device.getDescriptor(advertisementDigest.serviceUuids);
    DeviceUsage deviceUsage;
    AppDatabase database;
    if (descriptor.isMultiSport) {
      database = Get.find<AppDatabase>();
      final result = await database.database
          .rawQuery("SELECT COUNT(id) FROM $DEVICE_USAGE_TABLE_NAME WHERE mac = ?", [device.id.id]);
      if (result[0]['COUNT(id)'] > 0) {
        deviceUsage = await database?.deviceUsageDao?.findDeviceUsageByMac(device.id.id)?.first;
      }
      final multiSportSupport = PrefService.getBool(MULTI_SPORT_DEVICE_SUPPORT_TAG);
      if (deviceUsage == null || multiSportSupport) {
        final initialSport = deviceUsage?.sport ?? descriptor.defaultSport;
        final sportPick = await Get.bottomSheet(
          SportPickerBottomSheet(initialSport: initialSport, allSports: false),
          isDismissible: false,
          enableDrag: false,
        );
        if (sportPick == null) {
          return false;
        }

        descriptor.defaultSport = sportPick;
        if (deviceUsage != null) {
          deviceUsage.sport = sportPick;
          deviceUsage.time = DateTime.now().millisecondsSinceEpoch;
          await database?.deviceUsageDao?.updateDeviceUsage(deviceUsage);
        } else {
          deviceUsage = DeviceUsage(
            sport: sportPick,
            mac: device.id.id,
            name: device.name,
            manufacturer: advertisementDigest.manufacturer,
          );
          await database?.deviceUsageDao?.insertDeviceUsage(deviceUsage);
        }
      } else {
        descriptor.defaultSport = deviceUsage.sport;
        await database?.deviceUsageDao?.updateDeviceUsage(deviceUsage);
      }
    }

    final fitnessEquipment =
        Get.put<FitnessEquipment>(FitnessEquipment(descriptor: descriptor, device: device));
    bool success = await fitnessEquipment.connectOnDemand(initialState);
    if (!success) {
      Get.defaultDialog(
        middleText: 'Problem co-operating with ${descriptor.fullName}.',
        confirm: TextButton(
          child: Text("Ok"),
          onPressed: () => Get.close(1),
        ),
      );
    } else {
      if (deviceUsage != null) {
        deviceUsage.manufacturerName = fitnessEquipment.manufacturerName;
        deviceUsage.time = DateTime.now().millisecondsSinceEpoch;
        await database?.deviceUsageDao?.updateDeviceUsage(deviceUsage);
      }
      Get.to(RecordingScreen(
        device: device,
        advertisementDigest: advertisementDigest,
        initialState: initialState,
        size: Get.mediaQuery.size,
        sport: descriptor.defaultSport,
      ));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_adjustedCaptionStyle == null) {
      _adjustedCaptionStyle =
          Theme.of(context).textTheme.caption.apply(fontSizeFactor: FONT_SIZE_FACTOR);
      _subtitleStyle = _adjustedCaptionStyle.apply(fontFamily: FONT_FAMILY);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_filterDevices ? 'Supported Exercise Equipment:' : 'Bluetooth Devices'),
        actions: [
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
                final lasts = _scannedDevices.where((d) => _lastEquipmentIds.contains(d.id.id));
                if (_openedDevice != null && !_advertisementCache.hasEntry(_openedDevice.id.id) ||
                    _filterDevices &&
                        _scannedDevices.length == 1 &&
                        !_advertisementCache.hasEntry(_scannedDevices.first.id.id) ||
                    _scannedDevices.length > 1 &&
                        _lastEquipmentIds.length > 0 &&
                        lasts.length > 0 &&
                        !_advertisementCache.hasAnyEntry(_lastEquipmentIds)) {
                  startScan();
                  return Container();
                } else if (_autoConnect) {
                  if (_openedDevice != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      goToRecording(_openedDevice, BluetoothDeviceState.connected);
                    });
                  } else {
                    if (_filterDevices && _scannedDevices.length == 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        goToRecording(_scannedDevices.first, BluetoothDeviceState.disconnected);
                      });
                    } else if (_scannedDevices.length > 1 && _lastEquipmentIds.length > 0) {
                      final lasts = _scannedDevices
                          .where((d) =>
                              _lastEquipmentIds.contains(d.id.id) &&
                              _advertisementCache.hasEntry(d.id.id))
                          .toList(growable: false);
                      if (lasts.length > 0) {
                        lasts.sort((a, b) {
                          return _advertisementCache
                              .getEntry(a.id.id)
                              .txPower
                              .compareTo(_advertisementCache.getEntry(b.id.id).txPower);
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          goToRecording(lasts.last, BluetoothDeviceState.disconnected);
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
        onRefresh: () {
          startScan();
          return;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data.map((d) {
                    if (!(_advertisementCache.getEntry(d.id.id)?.isHeartRateMonitor() ?? false)) {
                      _openedDevice = d;
                    }

                    return ListTile(
                      title: TextOneLine(
                        d.name,
                        overflow: TextOverflow.ellipsis,
                        style: standOutStyle(_adjustedCaptionStyle, FONT_SIZE_FACTOR),
                      ),
                      subtitle: Text(d.id.id, style: _subtitleStyle),
                      trailing: StreamBuilder<BluetoothDeviceState>(
                        stream: d.state,
                        initialData: BluetoothDeviceState.disconnected,
                        builder: (c, snapshot) {
                          if (snapshot.data == BluetoothDeviceState.connected) {
                            return FloatingActionButton(
                              heroTag: null,
                              child: (_advertisementCache.getEntry(d.id.id)?.isHeartRateMonitor() ??
                                      false)
                                  ? ((Get.isRegistered<HeartRateMonitor>() &&
                                          Get.find<HeartRateMonitor>()?.device?.id?.id == d.id.id)
                                      ? Text(_heartRate?.toString() ?? "--")
                                      : Icon(Icons.favorite))
                                  : Icon(Icons.open_in_new),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              onPressed: () async {
                                if (_advertisementCache.getEntry(d.id.id)?.isHeartRateMonitor() ??
                                    false) {
                                  return;
                                }
                                await FlutterBlue.instance.stopScan();
                                await Future.delayed(Duration(milliseconds: 100));
                                await goToRecording(d, snapshot.data);
                              },
                            );
                          } else {
                            return Text(snapshot.data.toString());
                          }
                        },
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data.where((d) => d.isWorthy(_filterDevices)).map((r) {
                    addScannedDevice(r);
                    if (_autoConnect && _lastEquipmentIds.contains(r.device.id.id)) {
                      FlutterBlue.instance.stopScan().whenComplete(() async {
                        await Future.delayed(Duration(milliseconds: 100));
                      });
                    }
                    return ScanResultTile(
                      result: r,
                      onEquipmentTap: () async {
                        await FlutterBlue.instance.stopScan();
                        await Future.delayed(Duration(milliseconds: 100));
                        await goToRecording(r.device, BluetoothDeviceState.disconnected);
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
                          await heartRateMonitor.discover();
                        }
                        await heartRateMonitor.attach();
                        heartRateMonitor.pumpMetric((heartRate) {
                          setState(() {
                            _heartRate = heartRate;
                          });
                        });
                      },
                    );
                  }).toList(growable: false),
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
