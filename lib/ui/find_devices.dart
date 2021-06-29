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
import '../persistence/preferences_spec.dart';
import '../strava/strava_service.dart';
import '../utils/constants.dart';
import '../utils/delays.dart';
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
  State<StatefulWidget> createState() => FindDevicesState();
}

class FindDevicesState extends State<FindDevicesScreen> {
  bool _instantScan = INSTANT_SCAN_DEFAULT;
  int _scanDuration = SCAN_DURATION_DEFAULT;
  bool _autoConnect = AUTO_CONNECT_DEFAULT;
  bool _isScanning = false;
  List<BluetoothDevice> _scannedDevices = [];
  bool _goingToRecording = false;
  List<String> _lastEquipmentIds = [];
  bool _filterDevices = DEVICE_FILTERING_DEFAULT;
  HeartRateMonitor? _heartRateMonitor;
  FitnessEquipment? _fitnessEquipment;
  TextStyle _captionStyle = TextStyle();
  TextStyle _subtitleStyle = TextStyle();
  AdvertisementCache _advertisementCache = Get.find<AdvertisementCache>();
  ThemeManager _themeManager = Get.find<ThemeManager>();
  double _ringDiameter = 1.0;
  double _ringWidth = 1.0;

  @override
  void dispose() {
    FlutterBlue.instance.stopScan();
    _heartRateMonitor?.detach();
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
      migration7to8,
    ]).build();
    Get.put<AppDatabase>(database);
  }

  void _startScan() {
    if (_isScanning) {
      return;
    }

    final prefService = Get.find<BasePrefService>();
    _scanDuration = prefService.get<int>(SCAN_DURATION_TAG) ?? SCAN_DURATION_DEFAULT;
    _autoConnect = prefService.get<bool>(AUTO_CONNECT_TAG) ?? AUTO_CONNECT_DEFAULT;
    _filterDevices = prefService.get<bool>(DEVICE_FILTERING_TAG) ?? DEVICE_FILTERING_DEFAULT;
    _scannedDevices.clear();
    _isScanning = true;
    FlutterBlue.instance
        .startScan(timeout: Duration(seconds: _scanDuration))
        .whenComplete(() => {_isScanning = false});
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
    final prefService = Get.find<BasePrefService>();
    _instantScan = prefService.get<bool>(INSTANT_SCAN_TAG) ?? INSTANT_SCAN_DEFAULT;
    _scanDuration = prefService.get<int>(SCAN_DURATION_TAG) ?? SCAN_DURATION_DEFAULT;
    _autoConnect = prefService.get<bool>(AUTO_CONNECT_TAG) ?? AUTO_CONNECT_DEFAULT;
    PreferencesSpec.SPORT_PREFIXES.forEach((sport) {
      final lastEquipmentId = prefService.get<String>(LAST_EQUIPMENT_ID_TAG_PREFIX + sport) ?? "";
      if (lastEquipmentId.isNotEmpty) {
        _lastEquipmentIds.add(lastEquipmentId);
      }
    });

    _filterDevices = prefService.get<bool>(DEVICE_FILTERING_TAG) ?? DEVICE_FILTERING_DEFAULT;
    _isScanning = false;
    if (_instantScan) {
      _startScan();
    }

    _openDatabase();

    _captionStyle = Get.textTheme.headline6!;
    _subtitleStyle = _captionStyle.apply(fontFamily: FONT_FAMILY);
    _ringDiameter = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height) * 1.5;
    _ringWidth = _ringDiameter * 0.2;

    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
  }

  Future<bool> goToRecording(BluetoothDevice device, BluetoothDeviceState initialState) async {
    if (!_advertisementCache.hasEntry(device.id.id)) {
      return false;
    }

    if (_goingToRecording) {
      return false;
    }

    _goingToRecording = true;

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
        fitnessEquipment = FitnessEquipment(device: device);
        success = await fitnessEquipment.connectOnDemand(identify: true);
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

    final prefService = Get.find<BasePrefService>();
    if (descriptor == null) {
      if (prefService.get<bool>(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT) {
        descriptor = deviceMap[GENERIC_FTMS_BIKE_FOURCC]!;
      } else {
        Get.snackbar("Error", "Device identification failed");
        return false;
      }
    }

    if (descriptor.isMultiSport) {
      final multiSportSupport = prefService.get<bool>(MULTI_SPORT_DEVICE_SUPPORT_TAG) ??
          MULTI_SPORT_DEVICE_SUPPORT_DEFAULT;
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

    final currentEquipment =
        Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
    bool shouldRegister = true;
    if (currentEquipment != null) {
      if (currentEquipment.device?.id.id == device.id.id) {
        fitnessEquipment = currentEquipment;
        shouldRegister = false;
      } else {
        await currentEquipment.detach();
        await currentEquipment.disconnect();
      }
    }

    if (fitnessEquipment != null) {
      fitnessEquipment.descriptor = descriptor;
    } else {
      fitnessEquipment = FitnessEquipment(
        descriptor: descriptor,
        device: device,
      );
    }

    if (shouldRegister) {
      if (Get.isRegistered<FitnessEquipment>()) {
        await Get.delete<FitnessEquipment>();
      }

      Get.put<FitnessEquipment>(fitnessEquipment);
      setState(() {
        _fitnessEquipment = fitnessEquipment;
      });
    }

    success = await fitnessEquipment.connectOnDemand();
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

      _goingToRecording = false;
      Get.to(() => RecordingScreen(
            device: device,
            descriptor: descriptor!,
            initialState: initialState,
            size: Get.mediaQuery.size,
            sport: descriptor.defaultSport,
          ));
    }

    if (fitnessEquipment.device?.id.id != _fitnessEquipment?.device?.id.id) {
      setState(() {
        _fitnessEquipment = fitnessEquipment;
      });
    }

    _goingToRecording = false;
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
                if (_fitnessEquipment != null &&
                        !_advertisementCache
                            .hasEntry(_fitnessEquipment!.device?.id.id ?? EMPTY_MEASUREMENT) ||
                    _filterDevices &&
                        _scannedDevices.length == 1 &&
                        !_advertisementCache.hasEntry(_scannedDevices.first.id.id) ||
                    _scannedDevices.length > 1 &&
                        _lastEquipmentIds.length > 0 &&
                        lasts.length > 0 &&
                        !_advertisementCache.hasAnyEntry(_lastEquipmentIds)) {
                  Get.snackbar("Request", "Please scan again");
                } else if (_autoConnect) {
                  if (_fitnessEquipment != null) {
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      goToRecording(_fitnessEquipment!.device!, BluetoothDeviceState.connected);
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
                return IconButton(icon: Icon(Icons.refresh), onPressed: () => _startScan());
              }
            },
          ),
        ],
      ),
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
                          style: _themeManager.boldStyle(_captionStyle,
                              fontSizeFactor: FONT_SIZE_FACTOR),
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
                              return _themeManager.getGreenGenericFab(Icon(Icons.favorite), () {
                                Get.snackbar("Info", "HRM Already connected");
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
                _fitnessEquipment != null
                    ? ListTile(
                        title: TextOneLine(
                          _fitnessEquipment?.device?.name ?? EMPTY_MEASUREMENT,
                          overflow: TextOverflow.ellipsis,
                          style: _themeManager.boldStyle(
                            _captionStyle,
                            fontSizeFactor: FONT_SIZE_FACTOR,
                          ),
                        ),
                        subtitle: Text(
                          _fitnessEquipment?.device?.id.id ?? EMPTY_MEASUREMENT,
                          style: _subtitleStyle,
                        ),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: _fitnessEquipment?.device?.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == BluetoothDeviceState.connected) {
                              return _themeManager.getGreenGenericFab(
                                Icon(Icons.open_in_new),
                                () async {
                                  await FlutterBlue.instance.stopScan();
                                  await Future.delayed(
                                      Duration(milliseconds: UI_INTERMITTENT_DELAY));
                                  await goToRecording(_fitnessEquipment!.device!, snapshot.data!);
                                },
                              );
                            } else {
                              return _themeManager.getGreenFab(Icons.bluetooth_disabled, () {
                                setState(() {
                                  _fitnessEquipment = Get.isRegistered<FitnessEquipment>()
                                      ? Get.find<FitnessEquipment>()
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
                      children: snapshot.data!.where((d) => d.isWorthy(_filterDevices)).map((r) {
                        addScannedDevice(r);
                        if (_autoConnect && _lastEquipmentIds.contains(r.device.id.id)) {
                          FlutterBlue.instance.stopScan().whenComplete(() async {
                            await Future.delayed(Duration(milliseconds: UI_INTERMITTENT_DELAY));
                          });
                        }
                        return ScanResultTile(
                          result: r,
                          onEquipmentTap: () async {
                            await FlutterBlue.instance.stopScan();
                            await Future.delayed(Duration(milliseconds: UI_INTERMITTENT_DELAY));
                            await goToRecording(r.device, BluetoothDeviceState.disconnected);
                          },
                          onHrmTap: () async {
                            var heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                                ? Get.find<HeartRateMonitor>()
                                : null;
                            final existingId = heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE;
                            final storedId = _heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE;
                            bool disconnectOnly = false;
                            if (heartRateMonitor != null) {
                              disconnectOnly = existingId == r.device.id.id;
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
                                if (existingId != storedId) {
                                  setState(() {
                                    _heartRateMonitor = heartRateMonitor;
                                  });
                                }
                                return;
                              }
                            }

                            if (heartRateMonitor != null) {
                              await heartRateMonitor.detach();
                              await heartRateMonitor.disconnect();
                              if (disconnectOnly) {
                                if (existingId != storedId) {
                                  setState(() {
                                    _heartRateMonitor = heartRateMonitor;
                                  });
                                }

                                return;
                              }
                            }

                            if (heartRateMonitor == null || existingId != r.device.id.id) {
                              heartRateMonitor = new HeartRateMonitor(r.device);
                              if (Get.isRegistered<HeartRateMonitor>()) {
                                await Get.delete<HeartRateMonitor>();
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
                          },
                        );
                      }).toList(growable: false),
                    ),
            ),
          ],
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
          _themeManager.getAboutFab(),
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
            Get.to(() => ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
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
                  await Future.delayed(Duration(milliseconds: UI_INTERMITTENT_DELAY));
                });
              } else {
                return _themeManager.getGreenFab(
                  Icons.search,
                  () => _startScan(),
                );
              }
            },
          ),
          _themeManager.getBlueFab(
              Icons.settings, () async => Get.to(() => PreferencesHubScreen())),
        ],
      ),
    );
  }
}
