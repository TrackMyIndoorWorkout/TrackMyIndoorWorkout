import 'dart:io';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide LogLevel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_fourcc.dart';
import '../devices/device_map.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../devices/gatt_constants.dart';
import '../devices/gatt_maps.dart';
import '../preferences/auto_connect.dart';
import '../persistence/database.dart';
import '../preferences/device_filtering.dart';
import '../preferences/instant_scan.dart';
import '../preferences/last_equipment_id.dart';
import '../preferences/log_level.dart';
import '../persistence/models/device_usage.dart';
import '../preferences/multi_sport_device_support.dart';
import '../preferences/scan_duration.dart';
import '../preferences/sport_spec.dart';
import '../preferences/welcome_presented.dart';
import '../preferences/workout_mode.dart';
import '../utils/bluetooth.dart';
import '../utils/constants.dart';
import '../utils/delays.dart';
import '../utils/logging.dart';
import '../utils/machine_type.dart';
import '../utils/scan_result_ex.dart';
import '../utils/theme_manager.dart';
import 'models/advertisement_cache.dart';
import 'parts/boolean_question.dart';
import 'parts/circular_menu.dart';
import 'parts/legend_dialog.dart';
import 'parts/scan_result.dart';
import 'parts/sport_picker.dart';
import 'preferences/preferences_hub.dart';
import 'about.dart';
import 'activities.dart';
import 'recording.dart';

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  FindDevicesState createState() => FindDevicesState();
}

class FindDevicesState extends State<FindDevicesScreen> {
  bool _instantScan = instantScanDefault;
  int _scanDuration = scanDurationDefault;
  bool _autoConnect = autoConnectDefault;
  bool _circuitWorkout = workoutModeDefault == workoutModeCircuit;
  bool _isScanning = false;
  final List<BluetoothDevice> _scannedDevices = [];
  bool _goingToRecording = false;
  bool _autoConnectLatch = false;
  int _logLevel = logLevelDefault;
  bool _pairingHrm = false;
  final List<String> _lastEquipmentIds = [];
  bool _filterDevices = deviceFilteringDefault;
  HeartRateMonitor? _heartRateMonitor;
  FitnessEquipment? _fitnessEquipment;
  TextStyle _captionStyle = const TextStyle();
  TextStyle _subtitleStyle = const TextStyle();
  final AdvertisementCache _advertisementCache = Get.find<AdvertisementCache>();
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  final RegExp _colonRegex = RegExp(r'\:');
  bool _privacyStatementViews = false;

  @override
  void dispose() {
    if (_isScanning) {
      try {
        FlutterBluePlus.instance.stopScan();
      } on PlatformException catch (e, stack) {
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
        Logging.log(
          _logLevel,
          logLevelError,
          "FIND_DEVICES",
          "dispose",
          "${e.message}",
        );
      }
    }

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
      migration8to9,
      migration9to10,
      migration10to11,
      migration11to12,
      migration12to13,
      migration13to14,
      migration14to15,
      migration15to16,
      migration16to17,
    ]).build();
    if (AppDatabase.additional15to16Migration) {
      await database.correctCalorieFactors();
    }

    if (AppDatabase.additional16to17Migration) {
      await database.initializeExistingActivityMovingTimes();
    }

    Get.put<AppDatabase>(database, permanent: true);
  }

  Future<void> _startScan(bool silent) async {
    if (_isScanning) {
      if (_logLevel >= logLevelInfo) {
        Logging.log(
          _logLevel,
          logLevelInfo,
          "FIND_DEVICES",
          "startScan",
          "Scan already in progress",
        );
      }

      return;
    }

    if (!await bluetoothCheck(silent, _logLevel)) {
      if (_logLevel >= logLevelInfo) {
        Logging.log(
          _logLevel,
          logLevelInfo,
          "FIND_DEVICES",
          "startScan",
          "bluetooth check failed",
        );
      }

      return;
    }

    if (_logLevel >= logLevelInfo) {
      Logging.log(
        _logLevel,
        logLevelInfo,
        "FIND_DEVICES",
        "startScan",
        "Scan initiated",
      );
    }

    final prefService = Get.find<BasePrefService>();
    _scanDuration = prefService.get<int>(scanDurationTag) ?? scanDurationDefault;
    _autoConnect = prefService.get<bool>(autoConnectTag) ?? autoConnectDefault;
    _circuitWorkout =
        (prefService.get<String>(workoutModeTag) ?? workoutModeDefault) == workoutModeCircuit;
    _filterDevices = prefService.get<bool>(deviceFilteringTag) ?? deviceFilteringDefault;
    _logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    _scannedDevices.clear();
    _isScanning = true;
    _autoConnectLatch = true;
    try {
      FlutterBluePlus.instance
          .startScan(timeout: Duration(seconds: _scanDuration))
          .whenComplete(() => {_isScanning = false});
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
      Logging.log(
        _logLevel,
        logLevelError,
        "FIND_DEVICES",
        "_startScan",
        "${e.message}",
      );
    }
  }

  void addScannedDevice(ScanResult scanResult) {
    if (!scanResult.isWorthy(_filterDevices)) {
      return;
    }

    final advertisementCache = Get.find<AdvertisementCache>();
    advertisementCache.addEntry(scanResult);

    if (_scannedDevices.where((d) => d.id.id == scanResult.device.id.id).isNotEmpty) {
      return;
    }

    _scannedDevices.add(scanResult.device);
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
    final prefService = Get.find<BasePrefService>();
    _instantScan = prefService.get<bool>(instantScanTag) ?? instantScanDefault;
    _scanDuration = prefService.get<int>(scanDurationTag) ?? scanDurationDefault;
    _autoConnect = prefService.get<bool>(autoConnectTag) ?? autoConnectDefault;
    for (var sport in SportSpec.sportPrefixes) {
      final lastEquipmentId = prefService.get<String>(lastEquipmentIdTagPrefix + sport) ?? "";
      if (lastEquipmentId.isNotEmpty) {
        _lastEquipmentIds.add(lastEquipmentId);
      }
    }
    _logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    _filterDevices = prefService.get<bool>(deviceFilteringTag) ?? deviceFilteringDefault;
    _isScanning = false;
    _openDatabase().then((value) => _instantScan ? _startScan(true) : {});

    _captionStyle = Get.textTheme.headline6!;
    _subtitleStyle = _captionStyle.apply(fontFamily: fontFamily);

    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;

    if (huaweiAppGalleryBuild) {
      if (!prefService.get(welcomePresentedTag)) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final agreed = await Get.defaultDialog(
            barrierDismissible: false,
            title: "Welcome to $displayAppName",
            content: ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Click to Read Privacy Policy"),
              onPressed: () async {
                if (await canLaunchUrlString(AboutScreen.privacyPolicyUrl)) {
                  if (await launchUrlString(AboutScreen.privacyPolicyUrl)) {
                    setState(() {
                      _privacyStatementViews = true;
                    });
                  }
                } else {
                  Get.snackbar(
                      "Attention", "Please open URL manually: ${AboutScreen.privacyPolicyUrl}");
                }
              },
            ),
            confirm: TextButton(
              child: const Text("Agree"),
              onPressed: () {
                if (_privacyStatementViews) {
                  Get.back(result: true);
                } else {
                  Get.snackbar(
                      "Must read Privacy Policy to agree", "Click the dialog's button to read");
                }
              },
            ),
            cancel: TextButton(
              child: const Text("Deny"),
              onPressed: () {
                try {
                  Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                } catch (e) {
                  Platform.isAndroid ? exit(0) : SystemNavigator.pop();
                }
                Get.back(result: false);
              },
            ),
          );

          if (agreed) {
            prefService.set(welcomePresentedTag, true);
          }
        });
      }
    }
  }

  Future<bool> goToRecording(
    BluetoothDevice device,
    BluetoothDeviceState initialState,
    bool manual,
  ) async {
    if (!_advertisementCache.hasEntry(device.id.id)) {
      return false;
    }

    if (_goingToRecording || _autoConnect && !manual && !_autoConnectLatch) {
      return false;
    }

    _goingToRecording = true;
    _autoConnectLatch = false;

    // Device determination logics
    // Step 1. Try to infer from the Bluetooth advertised name
    DeviceDescriptor? descriptor;
    for (var dev in deviceMap.values) {
      for (var prefix in dev.namePrefixes) {
        if (device.name.toLowerCase().startsWith(prefix.toLowerCase())) {
          descriptor = dev;
          break;
        }
      }
    }

    final advertisementDigest = _advertisementCache.getEntry(device.id.id)!;

    // Step 2. Try to infer from if it has proprietary Precor service
    // Or other dedicated workarounds
    if (descriptor == null) {
      if (advertisementDigest.serviceUuids.contains(precorServiceUuid)) {
        descriptor = deviceMap[precorSpinnerChronoPowerFourCC];
      } else if (advertisementDigest.serviceUuids.contains(schwinnX70ServiceUuid)) {
        descriptor = deviceMap[schwinnX70BikeFourCC];
      } else if (advertisementDigest.serviceUuids.contains(cyclingPowerServiceUuid)) {
        descriptor = deviceMap[powerMeterBasedBikeFourCC];
      } else if (advertisementDigest.serviceUuids.contains(cyclingCadenceServiceUuid)) {
        descriptor = deviceMap[cscSensorBasedBikeFourCC];
      } else if (advertisementDigest.needsMatrixSpecialTreatment()) {
        if (advertisementDigest.machineType == MachineType.treadmill) {
          descriptor = deviceMap[matrixTreadmillFourCC];
        } else if (advertisementDigest.machineType == MachineType.indoorBike) {
          descriptor = deviceMap[matrixBikeFourCC];
        }
      }
    }

    final database = Get.find<AppDatabase>();
    DeviceUsage? deviceUsage;
    if (await database.hasDeviceUsage(device.id.id)) {
      deviceUsage = await database.deviceUsageDao.findDeviceUsageByMac(device.id.id).first;
    }

    FitnessEquipment? fitnessEquipment;

    // Step 3. Try to infer from DeviceUsage, FTMS advertisement service data or characteristics
    bool pickedAlready = false;
    if (descriptor == null) {
      if (deviceUsage != null) {
        descriptor = genericDescriptorForSport(deviceUsage.sport);
      } else {
        String? inferredSport;
        if (advertisementDigest.machineType.isFtms) {
          // Determine FTMS sport by Service Data bits
          inferredSport = advertisementDigest.machineType.sport;
        } else if (advertisementDigest.serviceUuids.contains(fitnessMachineUuid)) {
          // Determine FTMS sport by analyzing 0x1826 service's characteristics
          setState(() {
            _goingToRecording = true;
          });

          fitnessEquipment = FitnessEquipment(device: device);
          final success = await fitnessEquipment.connectOnDemand(identify: true);
          if (success) {
            final inferredSports = fitnessEquipment.inferSportsFromCharacteristicIds();
            if (inferredSports.isNotEmpty) {
              if (inferredSports.length == 1) {
                inferredSport = inferredSports.first;
              } else {
                inferredSport = await Get.bottomSheet(
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: SportPickerBottomSheet(
                              sportChoices: inferredSports,
                              initialSport: inferredSports.first,
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
                pickedAlready = inferredSport != null;
                await fitnessEquipment.setCharacteristicById(sportToUuid[inferredSport]!);
              }
            }
          }
        }

        if (inferredSport == null) {
          Get.snackbar("Error", "Could not infer sport of the device");
          if (_logLevel > logLevelNone) {
            Logging.log(
              _logLevel,
              logLevelError,
              "FIND_DEVICES",
              "goToRecording",
              "Could not infer sport of the device",
            );
          }

          setState(() {
            _goingToRecording = false;
          });

          return false;
        } else {
          descriptor = genericDescriptorForSport(inferredSport);
          if (!descriptor.isMultiSport) {
            deviceUsage = DeviceUsage(
              sport: inferredSport,
              mac: device.id.id,
              name: device.name,
              manufacturer: advertisementDigest.manufacturer,
              time: DateTime.now().millisecondsSinceEpoch,
            );
            await database.deviceUsageDao.insertDeviceUsage(deviceUsage);
          }
        }
      }
    }

    final prefService = Get.find<BasePrefService>();

    if (descriptor.isMultiSport && !pickedAlready) {
      final multiSportSupport =
          prefService.get<bool>(multiSportDeviceSupportTag) ?? multiSportDeviceSupportDefault;
      if (deviceUsage == null || multiSportSupport) {
        final initialSport = deviceUsage?.sport ?? descriptor.defaultSport;
        final sportPick = await Get.bottomSheet(
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SportPickerBottomSheet(
                      sportChoices: waterSports,
                      initialSport: initialSport,
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
        if (sportPick == null) {
          setState(() {
            _goingToRecording = false;
          });

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

    FitnessEquipment? ftmsWithoutServiceData = fitnessEquipment;
    fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;

    await Get.delete<FitnessEquipment>(force: true);
    if (fitnessEquipment != null) {
      if (fitnessEquipment.device?.id.id != device.id.id) {
        try {
          await fitnessEquipment.detach();
          if (!_circuitWorkout) {
            await fitnessEquipment.disconnect();
          }
        } on PlatformException catch (e, stack) {
          debugPrint("$e");
          debugPrintStack(stackTrace: stack, label: "trace:");
        }

        fitnessEquipment = null;
      }
    } else {
      fitnessEquipment = ftmsWithoutServiceData;
    }

    if (fitnessEquipment != null) {
      fitnessEquipment.descriptor = descriptor;
    } else {
      fitnessEquipment = FitnessEquipment(
        descriptor: descriptor,
        device: device,
      );
    }

    Get.put<FitnessEquipment>(fitnessEquipment, permanent: true);

    setState(() {
      _fitnessEquipment = fitnessEquipment;
    });

    final success = await fitnessEquipment.connectOnDemand();
    if (!success) {
      Get.defaultDialog(
        middleText: 'Problem connecting to ${descriptor.fullName}.',
        confirm: TextButton(
          child: const Text("Ok"),
          onPressed: () => Get.close(1),
        ),
      );

      setState(() {
        _goingToRecording = false;
      });
    } else {
      if (deviceUsage != null) {
        deviceUsage.manufacturerName = fitnessEquipment.manufacturerName;
        deviceUsage.time = DateTime.now().millisecondsSinceEpoch;
        await database.deviceUsageDao.updateDeviceUsage(deviceUsage);
      }

      Get.to(() => RecordingScreen(
            device: device,
            descriptor: descriptor!,
            initialState: initialState,
            size: Get.mediaQuery.size,
            sport: descriptor.defaultSport,
          ))?.then((_) {
        setState(() {
          _goingToRecording = false;
        });
      });
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
            stream: FlutterBluePlus.instance.isScanning,
            initialData: _instantScan,
            builder: (c, snapshot) {
              if (snapshot.data == null || snapshot.data!) {
                return JumpingDotsProgressIndicator(
                  fontSize: 30.0,
                  color: Colors.white,
                );
              } else {
                _isScanning = false;
                final lasts = _scannedDevices.where((d) => _lastEquipmentIds.contains(d.id.id));
                if (_fitnessEquipment != null &&
                        !_advertisementCache
                            .hasEntry(_fitnessEquipment!.device?.id.id ?? emptyMeasurement) ||
                    _filterDevices &&
                        _scannedDevices.length == 1 &&
                        !_advertisementCache.hasEntry(_scannedDevices.first.id.id) ||
                    _scannedDevices.length > 1 &&
                        _lastEquipmentIds.isNotEmpty &&
                        lasts.isNotEmpty &&
                        !_advertisementCache.hasAnyEntry(_lastEquipmentIds)) {
                  Get.snackbar("Request", "Please scan again");
                  if (_logLevel > logLevelNone) {
                    Logging.log(
                      _logLevel,
                      logLevelWarning,
                      "FIND_DEVICES",
                      "build",
                      "advertisementCache miss",
                    );
                  }
                } else if (_autoConnect && !_goingToRecording && _autoConnectLatch) {
                  if (_fitnessEquipment != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      goToRecording(
                        _fitnessEquipment!.device!,
                        BluetoothDeviceState.connected,
                        false,
                      );
                    });
                  } else {
                    if (_filterDevices && _scannedDevices.length == 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        goToRecording(
                          _scannedDevices.first,
                          BluetoothDeviceState.disconnected,
                          false,
                        );
                      });
                    } else if (_scannedDevices.length > 1 && _lastEquipmentIds.isNotEmpty) {
                      final lasts = _scannedDevices
                          .where((d) =>
                              _lastEquipmentIds.contains(d.id.id) &&
                              _advertisementCache.hasEntry(d.id.id))
                          .toList(growable: false);
                      if (lasts.isNotEmpty) {
                        lasts.sort((a, b) {
                          return _advertisementCache
                              .getEntry(a.id.id)!
                              .txPower
                              .compareTo(_advertisementCache.getEntry(b.id.id)!.txPower);
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          goToRecording(lasts.last, BluetoothDeviceState.disconnected, false);
                        });
                      }
                    }
                  }
                }
                if (_goingToRecording || _pairingHrm) {
                  return HeartbeatProgressIndicator(
                    child: IconButton(icon: const Icon(Icons.hourglass_empty), onPressed: () => {}),
                  );
                } else {
                  return IconButton(
                      icon: const Icon(Icons.refresh), onPressed: () => _startScan(false));
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _startScan(false);
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
                          style: _themeManager.boldStyle(_captionStyle,
                              fontSizeFactor: fontSizeFactor),
                        ),
                        subtitle: Text(
                          _heartRateMonitor?.device?.id.id.replaceAll(_colonRegex, '') ??
                              emptyMeasurement,
                          style: _subtitleStyle,
                        ),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: _heartRateMonitor?.device?.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == BluetoothDeviceState.connected) {
                              return _themeManager.getGreenGenericFab(
                                const Icon(Icons.favorite),
                                () {
                                  Get.snackbar("Info", "HRM Already connected");

                                  if (_logLevel > logLevelNone) {
                                    Logging.log(
                                      _logLevel,
                                      logLevelWarning,
                                      "FIND_DEVICES",
                                      "HRM click",
                                      "HRM Already connected",
                                    );
                                  }
                                },
                              );
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
                          _fitnessEquipment?.device?.name ?? emptyMeasurement,
                          overflow: TextOverflow.ellipsis,
                          style: _themeManager.boldStyle(
                            _captionStyle,
                            fontSizeFactor: fontSizeFactor,
                          ),
                        ),
                        subtitle: Text(
                          _fitnessEquipment?.device?.id.id.replaceAll(_colonRegex, '') ??
                              emptyMeasurement,
                          style: _subtitleStyle,
                        ),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: _fitnessEquipment?.device?.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == BluetoothDeviceState.connected) {
                              return _themeManager.getGreenGenericFab(
                                const Icon(Icons.open_in_new),
                                () async {
                                  if (_isScanning) {
                                    await FlutterBluePlus.instance.stopScan();
                                    await Future.delayed(
                                        const Duration(milliseconds: uiIntermittentDelay));
                                  }

                                  await goToRecording(
                                    _fitnessEquipment!.device!,
                                    snapshot.data!,
                                    true,
                                  );
                                },
                              );
                            } else {
                              return _themeManager.getGreenFab(
                                Icons.bluetooth_disabled,
                                () {
                                  setState(() {
                                    _fitnessEquipment = Get.isRegistered<FitnessEquipment>()
                                        ? Get.find<FitnessEquipment>()
                                        : null;
                                  });
                                },
                              );
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
                      children: snapshot.data!.where((d) => d.isWorthy(_filterDevices)).map((r) {
                        addScannedDevice(r);
                        if (_logLevel >= logLevelInfo) {
                          Logging.log(
                            _logLevel,
                            logLevelInfo,
                            "FIND_DEVICES",
                            "ScanResult",
                            r.toString(),
                          );
                        }

                        if (_autoConnect && _lastEquipmentIds.contains(r.device.id.id)) {
                          if (_isScanning) {
                            FlutterBluePlus.instance.stopScan().whenComplete(() async {
                              await Future.delayed(
                                  const Duration(milliseconds: uiIntermittentDelay));
                            });
                          }
                        }

                        return ScanResultTile(
                          result: r,
                          onEquipmentTap: () async {
                            if (!await bluetoothCheck(false, _logLevel)) {
                              return;
                            }

                            if (_isScanning) {
                              await FlutterBluePlus.instance.stopScan();
                              await Future.delayed(
                                  const Duration(milliseconds: uiIntermittentDelay));
                            }

                            await goToRecording(r.device, BluetoothDeviceState.disconnected, true);
                          },
                          onHrmTap: () async {
                            if (!await bluetoothCheck(false, _logLevel)) {
                              return;
                            }

                            setState(() {
                              _pairingHrm = true;
                            });

                            var heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                                ? Get.find<HeartRateMonitor>()
                                : null;
                            final existingId = heartRateMonitor?.device?.id.id ?? notAvailable;
                            final storedId = _heartRateMonitor?.device?.id.id ?? notAvailable;
                            bool disconnectOnly = false;
                            if (heartRateMonitor != null) {
                              disconnectOnly = existingId == r.device.id.id;
                              final title = disconnectOnly
                                  ? 'You are connected to that HRM right now'
                                  : 'You are connected to a HRM right now';
                              final content = disconnectOnly
                                  ? 'Disconnect from the selected HRM?'
                                  : 'Disconnect from that HRM to connect to the selected one?';
                              final verdict = await Get.bottomSheet(
                                SafeArea(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: BooleanQuestionBottomSheet(
                                            title: title,
                                            content: content,
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
                                }

                                setState(() {
                                  _pairingHrm = false;
                                });

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

                            setState(() {
                              _pairingHrm = false;
                            });
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
        children: [
          _themeManager.getTutorialFab(
            () async {
              legendDialog([
                const Tuple2<IconData, String>(Icons.favorite, "HRM"),
                const Tuple2<IconData, String>(Icons.search, "Start Scanning"),
                const Tuple2<IconData, String>(Icons.stop, "Stop Scanning"),
                const Tuple2<IconData, String>(Icons.refresh, "Scan Again"),
                const Tuple2<IconData, String>(Icons.play_arrow, "Start Workout"),
                const Tuple2<IconData, String>(Icons.open_in_new, "Workout Again"),
                const Tuple2<IconData, String>(Icons.list_alt, "Workout List"),
                const Tuple2<IconData, String>(Icons.settings, "Preferences"),
                const Tuple2<IconData, String>(Icons.help, "About"),
                const Tuple2<IconData, String>(Icons.info_rounded, "Help Legend"),
              ]);
            },
          ),
          _themeManager.getAboutFab(),
          _themeManager.getBlueFab(Icons.list_alt, () async {
            final database = Get.find<AppDatabase>();
            final hasLeaderboardData = await database.hasLeaderboardData();
            Get.to(() => ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
          }),
          StreamBuilder<bool>(
            stream: FlutterBluePlus.instance.isScanning,
            initialData: _instantScan,
            builder: (c, snapshot) {
              if (snapshot.data == null) {
                return Container();
              } else if (snapshot.data!) {
                return _themeManager.getBlueFab(Icons.stop, () async {
                  if (_isScanning) {
                    await FlutterBluePlus.instance.stopScan();
                    await Future.delayed(const Duration(milliseconds: uiIntermittentDelay));
                  }
                });
              } else {
                return _themeManager.getGreenFab(Icons.search, () => _startScan(false));
              }
            },
          ),
          _themeManager.getBlueFab(
            Icons.settings,
            () async => Get.to(() => const PreferencesHubScreen()),
          ),
        ],
      ),
    );
  }
}
