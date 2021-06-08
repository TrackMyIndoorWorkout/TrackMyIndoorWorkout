import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_map.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../devices/gatt_constants.dart';
import '../persistence/models/device_usage.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/strava_service.dart';
import '../utils/constants.dart';
import '../utils/scan_result_ex.dart';
import '../utils/theme_manager.dart';
import 'models/advertisement_cache.dart';
import 'parts/circular_menu.dart';
import 'parts/scan_result.dart';
import 'parts/sport_picker.dart';
import 'preferences/preferences_hub.dart';
import 'activities.dart';
import 'recording.dart';

class FindDevicesScreen extends StatefulWidget {
  FindDevicesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FindDevicesState();
  }
}

class FindDevicesState extends State<FindDevicesScreen> {
  bool _instantScan = INSTANT_SCAN_DEFAULT;
  int _scanDuration = SCAN_DURATION_DEFAULT;
  bool _autoConnect = AUTO_CONNECT_DEFAULT;
  late List<String> _lastEquipmentIds;
  bool _filterDevices = DEVICE_FILTERING_DEFAULT;
  BluetoothDevice? _openedDevice;
  late List<BluetoothDevice> _scannedDevices;
  late TextStyle _captionStyle;
  late TextStyle _subtitleStyle;
  int? _heartRate;
  late AdvertisementCache _advertisementCache;
  late ThemeManager _themeManager;
  late double _ringDiameter;
  late double _ringWidth;

  @override
  void dispose() {
    FlutterBlue.instance.stopScan();
    var heartRateMonitor =
        Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    heartRateMonitor?.cancelSubscription();
    super.dispose();
  }

  Future<void> _openDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations([
      migration1to2,
      migration2to3,
      migration3to4,
      migration4to5,
      migration5to6,
      migration6to7,
    ]).build();
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
    final prefService = Get.find<PrefServiceShared>().sharedPreferences;
    _instantScan = prefService.getBool(INSTANT_SCAN_TAG) ?? INSTANT_SCAN_DEFAULT;
    _scanDuration = prefService.getInt(SCAN_DURATION_TAG) ?? SCAN_DURATION_DEFAULT;
    _autoConnect = prefService.getBool(AUTO_CONNECT_TAG) ?? AUTO_CONNECT_DEFAULT;
    _lastEquipmentIds = [];
    PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
      final lastEquipmentId = prefService.getString(LAST_EQUIPMENT_ID_TAG_PREFIX + sport) ?? "";
      if (lastEquipmentId.isNotEmpty) {
        _lastEquipmentIds.add(lastEquipmentId);
      }
    });
    _filterDevices = prefService.getBool(DEVICE_FILTERING_TAG) ?? DEVICE_FILTERING_DEFAULT;
    if (_instantScan) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        startScan();
      });
    }
    _openDatabase();

    _advertisementCache = Get.find<AdvertisementCache>();
    _themeManager = Get.find<ThemeManager>();
    _captionStyle = Get.textTheme.headline6!;
    _subtitleStyle = _captionStyle.apply(fontFamily: FONT_FAMILY);
    _ringDiameter = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height) * 1.5;
    _ringWidth = _ringDiameter * 0.2;

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

    // Device determination logics
    // Step 1. Try to infer from the Bluetooth advertised name
    DeviceDescriptor? descriptor;
    for (var dev in deviceMap.values) {
      if (device.name.startsWith(dev.namePrefix)) {
        descriptor = dev;
        break;
      }
    }

    final advertisementDigest = _advertisementCache.getEntry(device.id.id)!;

    // Step 2. Try to infer from if it has proprietary Precor service
    if (descriptor == null && advertisementDigest.serviceUuids.contains(PRECOR_SERVICE_ID)) {
      descriptor = deviceMap[PRECOR_SPINNER_CHRONO_POWER_FOURCC];
    }

    final database = Get.find<AppDatabase>();
    DeviceUsage? deviceUsage;
    if (await database.hasDeviceUsage(device.id.id)) {
      deviceUsage = await database.deviceUsageDao.findDeviceUsageByMac(device.id.id).first;
    }

    FitnessEquipment? fitnessEquipment;
    bool success;

    // Step 3. Try to infer if it's an FTMS
    if (descriptor == null && advertisementDigest.serviceUuids.contains(FITNESS_MACHINE_ID)) {
      var sport = ActivityType.Ride;
      if (deviceUsage == null) {
        // Determine FTMS sport by analyzing 0x1826 service's characteristics
        fitnessEquipment = Get.put<FitnessEquipment>(FitnessEquipment(device: device));
        success = await fitnessEquipment.connectOnDemand(initialState, identify: true);
        if (success && fitnessEquipment.characteristicsId != null) {
          final inferredSport = fitnessEquipment.inferSportFromCharacteristicsId();
          if (inferredSport == null) {
            Get.snackbar("Error", "Could not infer sport of the device");
            return false;
          }

          sport = inferredSport;
        } else {
          Get.snackbar("Error", "Device identification failed");
          return false;
        }
      } else {
        sport = deviceUsage.sport;
      }

      descriptor = genericDescriptorForSport(sport);

      if (deviceUsage == null) {
        deviceUsage = DeviceUsage(
          sport: sport,
          mac: device.id.id,
          name: device.name,
          manufacturer: advertisementDigest.manufacturer,
          time: DateTime.now().millisecondsSinceEpoch,
        );
        await database.deviceUsageDao.insertDeviceUsage(deviceUsage);
      }
    }

    final prefService = Get.find<PrefServiceShared>().sharedPreferences;
    if (descriptor == null) {
      if (prefService.getBool(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT) {
        descriptor = deviceMap[GENERIC_FTMS_BIKE_FOURCC]!;
      } else {
        Get.snackbar("Error", "Device identification failed");
        return false;
      }
    } else if (fitnessEquipment != null) {
      fitnessEquipment.descriptor = descriptor;
    }

    if (descriptor.isMultiSport) {
      final multiSportSupport =
          prefService.getBool(MULTI_SPORT_DEVICE_SUPPORT_TAG) ?? MULTI_SPORT_DEVICE_SUPPORT_DEFAULT;
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
          await database.deviceUsageDao.updateDeviceUsage(deviceUsage);
        } else {
          deviceUsage = DeviceUsage(
            sport: sportPick,
            mac: device.id.id,
            name: device.name,
            manufacturer: advertisementDigest.manufacturer,
            time: DateTime.now().millisecondsSinceEpoch,
          );
          await database.deviceUsageDao.insertDeviceUsage(deviceUsage);
        }
      } else {
        descriptor.defaultSport = deviceUsage.sport;
        await database.deviceUsageDao.updateDeviceUsage(deviceUsage);
      }
    }

    if (fitnessEquipment == null) {
      fitnessEquipment = Get.put<FitnessEquipment>(FitnessEquipment(
        descriptor: descriptor,
        device: device,
      ));
    }
    success = await fitnessEquipment.connectOnDemand(initialState);
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
        await database.deviceUsageDao.updateDeviceUsage(deviceUsage);
      }
      Get.to(RecordingScreen(
        device: device,
        descriptor: descriptor,
        initialState: initialState,
        size: Get.mediaQuery.size,
        sport: descriptor.defaultSport,
      ));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_filterDevices ? 'Supported Devices:' : 'Devices'),
        actions: [
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: _instantScan,
            builder: (c, snapshot) {
              if (snapshot.data == null || snapshot.data!) {
                return JumpingDotsProgressIndicator(
                  fontSize: 30.0,
                  color: Colors.white,
                );
              } else {
                final lasts = _scannedDevices.where((d) => _lastEquipmentIds.contains(d.id.id));
                if (_openedDevice != null && !_advertisementCache.hasEntry(_openedDevice!.id.id) ||
                    _filterDevices &&
                        _scannedDevices.length == 1 &&
                        !_advertisementCache.hasEntry(_scannedDevices.first.id.id) ||
                    _scannedDevices.length > 1 &&
                        _lastEquipmentIds.length > 0 &&
                        lasts.length > 0 &&
                        !_advertisementCache.hasAnyEntry(_lastEquipmentIds)) {
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    startScan();
                  });
                  return Container();
                } else if (_autoConnect) {
                  if (_openedDevice != null) {
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      goToRecording(_openedDevice!, BluetoothDeviceState.connected);
                    });
                  } else {
                    if (_filterDevices && _scannedDevices.length == 1) {
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
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
                              .getEntry(a.id.id)!
                              .txPower
                              .compareTo(_advertisementCache.getEntry(b.id.id)!.txPower);
                        });
                        WidgetsBinding.instance?.addPostFrameCallback((_) {
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
        onRefresh: () async {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            startScan();
          });
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => snapshot.data == null
                    ? Container()
                    : Column(
                        children: snapshot.data!
                            .where((d) => _advertisementCache.hasEntry(d.id.id))
                            .map((d) {
                          if (!(_advertisementCache.getEntry(d.id.id)?.isHeartRateMonitor() ??
                              false)) {
                            _openedDevice = d;
                          }

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
                                  return _themeManager.getGreenGenericFab(
                                    (_advertisementCache.getEntry(d.id.id)?.isHeartRateMonitor() ??
                                            false)
                                        ? ((Get.isRegistered<HeartRateMonitor>() &&
                                                Get.find<HeartRateMonitor>().device?.id.id ==
                                                    d.id.id)
                                            ? Text(_heartRate?.toString() ?? "--")
                                            : Icon(Icons.favorite))
                                        : Icon(Icons.open_in_new),
                                    () async {
                                      if (_advertisementCache
                                              .getEntry(d.id.id)
                                              ?.isHeartRateMonitor() ??
                                          false) {
                                        return;
                                      }
                                      await FlutterBlue.instance.stopScan();
                                      await Future.delayed(Duration(milliseconds: 100));
                                      await goToRecording(d, snapshot.data!);
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
                builder: (c, snapshot) => snapshot.data == null
                    ? Container()
                    : Column(
                        children: snapshot.data!.where((d) => d.isWorthy(_filterDevices)).map((r) {
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
                              bool disconnectOnly = false;
                              if (heartRateMonitor != null) {
                                disconnectOnly = heartRateMonitor.device?.id.id == r.device.id.id;
                                final title = disconnectOnly
                                    ? 'You are connected to that HRM right now'
                                    : 'You are connected to a HRM right now';
                                final content = disconnectOnly
                                    ? 'Disconnect from the selected HRM?'
                                    : 'Disconnect from that HRM to connect to the selected one?';
                                if (!(await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(title),
                                        content: Text(content),
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

                              if (heartRateMonitor != null) {
                                await heartRateMonitor.detach();
                                await heartRateMonitor.disconnect();
                                if (disconnectOnly) {
                                  return;
                                }
                              }

                              if (heartRateMonitor == null ||
                                  heartRateMonitor.device?.id.id != r.device.id.id) {
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
      floatingActionButton: CircularFabMenu(
        fabOpenIcon: Icon(Icons.menu, color: _themeManager.getAntagonistColor()),
        fabOpenColor: _themeManager.getBlueColor(),
        fabCloseIcon: Icon(Icons.close, color: _themeManager.getAntagonistColor()),
        fabCloseColor: _themeManager.getBlueColor(),
        ringColor: _themeManager.getBlueColorInverse(),
        ringDiameter: _ringDiameter,
        ringWidth: _ringWidth,
        children: [
          _themeManager.getExitFab(),
          _themeManager.getHelpFab(),
          _themeManager.getStravaFab(() async {
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
          }),
          _themeManager.getBlueFab(Icons.list_alt, () async {
            final database = Get.find<AppDatabase>();
            final hasLeaderboardData = await database.hasLeaderboardData();
            Get.to(ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
          }),
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: _instantScan,
            builder: (c, snapshot) {
              if (snapshot.data == null) {
                return Container();
              } else if (snapshot.data!) {
                return _themeManager.getBlueFab(Icons.stop, () async {
                  await FlutterBlue.instance.stopScan();
                  await Future.delayed(Duration(milliseconds: 100));
                });
              } else {
                return _themeManager.getGreenFab(
                  Icons.search,
                  () => FlutterBlue.instance.startScan(timeout: Duration(seconds: _scanDuration)),
                );
              }
            },
          ),
          _themeManager.getBlueFab(Icons.settings, () async => Get.to(PreferencesHubScreen())),
        ],
      ),
    );
  }
}
