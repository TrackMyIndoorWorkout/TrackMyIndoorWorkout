import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide LogLevel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../devices/bluetooth_device_ex.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/device_factory.dart';
import '../devices/device_fourcc.dart';
import '../devices/gadgets/complex_sensor.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../devices/gatt/csc.dart';
import '../devices/gatt/concept2.dart';
import '../devices/gatt/ftms.dart';
import '../devices/gatt/kayak_first.dart';
import '../devices/gatt/power_meter.dart';
import '../devices/gatt/precor.dart';
import '../devices/gatt/schwinn_x70.dart';
import '../devices/gatt_maps.dart';
import '../preferences/auto_connect.dart';
import '../persistence/database.dart';
import '../preferences/device_filtering.dart';
import '../preferences/instant_scan.dart';
import '../preferences/last_equipment_id.dart';
import '../preferences/log_level.dart';
import '../persistence/models/device_usage.dart';
import '../preferences/multi_sport_device_support.dart';
import '../preferences/paddling_with_cycling_sensors.dart';
import '../preferences/scan_duration.dart';
import '../preferences/sport_spec.dart';
import '../preferences/two_column_layout.dart';
import '../preferences/welcome_presented.dart';
import '../preferences/workout_mode.dart';
import '../utils/address_names.dart';
import '../utils/bluetooth.dart';
import '../utils/constants.dart';
import '../utils/delays.dart';
import '../utils/logging.dart';
import '../utils/machine_type.dart';
import '../utils/scan_result_ex.dart';
import '../utils/string_ex.dart';
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
import 'donation.dart';
import 'recording.dart';

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  FindDevicesState createState() => FindDevicesState();
}

class FindDevicesState extends State<FindDevicesScreen> {
  static const String tag = "FIND_DEVICES";
  bool _instantScan = instantScanDefault;
  int _scanDuration = scanDurationDefault;
  bool _autoConnect = autoConnectDefault;
  bool _circuitWorkout = workoutModeDefault == workoutModeCircuit;
  bool _paddlingWithCyclingSensors = paddlingWithCyclingSensorsDefault;
  bool _isScanning = false;
  final List<BluetoothDevice> _scannedDevices = [];
  final StreamController<List<ScanResult>> _scanStreamController = StreamController.broadcast();
  StreamSubscription<List<ScanResult>>? _scanStreamSubscription;
  final Map<String, String> _deviceSport = {};
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
  double _mediaSizeMin = 0;
  double _mediaHeight = 0;
  double _mediaWidth = 0;
  bool _landscape = false;
  bool _twoColumnLayout = twoColumnLayoutDefault;
  final AdvertisementCache _advertisementCache = Get.find<AdvertisementCache>();
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  bool _privacyStatementViews = false;

  @override
  void dispose() {
    if (_isScanning) {
      try {
        FlutterBluePlus.instance.stopScan();
      } on Exception catch (e, stack) {
        Logging.logException(
            _logLevel, tag, "dispose", "FlutterBluePlus.instance.stopScan", e, stack);
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
      migration17to18,
    ]).build();
    if (AppDatabase.additional15to16Migration) {
      await database.correctCalorieFactors();
    }

    if (AppDatabase.additional16to17Migration) {
      await database.initializeExistingActivityMovingTimes();
    }

    Get.put<AppDatabase>(database, permanent: true);
    final addressNames = Get.find<AddressNames>();
    await database.getAddressNameDictionary(addressNames);

    if (_instantScan) {
      await _startScan(true);
    }
  }

  void _readPreferencesValues() {
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

    _circuitWorkout =
        (prefService.get<String>(workoutModeTag) ?? workoutModeDefault) == workoutModeCircuit;
    _paddlingWithCyclingSensors =
        prefService.get<bool>(paddlingWithCyclingSensorsTag) ?? paddlingWithCyclingSensorsDefault;
    _filterDevices = prefService.get<bool>(deviceFilteringTag) ?? deviceFilteringDefault;
    _logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    _twoColumnLayout = prefService.get<bool>(twoColumnLayoutTag) ?? twoColumnLayoutDefault;
  }

  Future<void> _readDeviceSports() async {
    _deviceSport.clear();
    final database = Get.find<AppDatabase>();
    for (final deviceUsage in await database.deviceUsageDao.findAllDeviceUsages()) {
      _deviceSport[deviceUsage.mac] = deviceUsage.sport;
    }
  }

  Future<void> _startScan(bool silent) async {
    if (_isScanning) {
      Logging.log(_logLevel, logLevelInfo, tag, "startScan", "Scan already in progress");

      return;
    }

    if (!await bluetoothCheck(silent, _logLevel)) {
      Logging.log(_logLevel, logLevelInfo, tag, "startScan", "bluetooth check failed");

      return;
    }

    Logging.log(_logLevel, logLevelInfo, tag, "startScan", "Scan initiated");

    _readPreferencesValues();
    await _readDeviceSports();
    _scannedDevices.clear();
    setState(() {
      _isScanning = true;
    });

    _isScanning = true;
    _autoConnectLatch = true;

    if (_scanStreamSubscription?.isPaused ?? false) {
      _scanStreamSubscription?.resume();
    }

    try {
      await FlutterBluePlus.instance.startScan(timeout: Duration(seconds: _scanDuration));
      setState(() {
        _isScanning = false;
      });

      if (!silent || !_autoConnect) {
        return;
      }

      // Try auto-connect
      final lasts = _scannedDevices.where((d) => _lastEquipmentIds.contains(d.id.id));
      if (_fitnessEquipment != null &&
              !_advertisementCache.hasEntry(_fitnessEquipment!.device?.id.id ?? emptyMeasurement) ||
          _filterDevices &&
              _scannedDevices.length == 1 &&
              !_advertisementCache.hasEntry(_scannedDevices.first.id.id) ||
          _scannedDevices.length > 1 &&
              _lastEquipmentIds.isNotEmpty &&
              lasts.isNotEmpty &&
              !_advertisementCache.hasAnyEntry(_lastEquipmentIds)) {
        Logging.log(_logLevel, logLevelWarning, tag, "_startScan finished pre auto-connect",
            "advertisementCache miss");
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
                    _lastEquipmentIds.contains(d.id.id) && _advertisementCache.hasEntry(d.id.id))
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
    } on Exception catch (e, stack) {
      Logging.logException(
          _logLevel, tag, "_startScan", "FlutterBluePlus.instance.startScan", e, stack);
    }
  }

  void addScannedDevice(ScanResult scanResult) {
    if (!scanResult.isWorthy(_filterDevices)) {
      return;
    }

    final advertisementCache = Get.find<AdvertisementCache>();
    String deviceId = scanResult.device.id.id;
    String deviceSport = _deviceSport[deviceId] ?? "";
    advertisementCache.addEntry(scanResult, deviceSport);

    if (_scannedDevices.where((d) => d.id.id == scanResult.device.id.id).isEmpty) {
      _scannedDevices.add(scanResult.device);
    }
  }

  Stream<List<ScanResult>> get _throttledScanStream async* {
    await for (var scanResults in FlutterBluePlus.instance.scanResults.throttleTime(
      const Duration(milliseconds: uiIntermittentDelay),
      leading: false,
      trailing: true,
    )) {
      yield scanResults;
    }
  }

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
    _readPreferencesValues();
    _isScanning = false;
    _scanStreamSubscription =
        _throttledScanStream.listen((scanResults) => _scanStreamController.add(scanResults));
    _openDatabase();

    _captionStyle = Get.textTheme.titleLarge!;
    _subtitleStyle = _captionStyle.apply(fontFamily: fontFamily);

    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;

    if (huaweiAppGalleryBuild) {
      final prefService = Get.find<BasePrefService>();
      final welcomePresented =
          Get.find<BasePrefService>().get<bool>(welcomePresentedTag) ?? welcomePresentedDefault;
      if (!welcomePresented) {
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
    Logging.logVersion(Get.find<PackageInfo>());

    if (!_advertisementCache.hasEntry(device.id.id)) {
      return false;
    }

    if (_goingToRecording || _autoConnect && !manual && !_autoConnectLatch) {
      return false;
    }

    setState(() {
      _goingToRecording = true;
    });
    _scanStreamSubscription?.pause();
    _autoConnectLatch = false;

    // Device determination logics
    // Step 1. Try to infer from the Bluetooth advertised name
    DeviceDescriptor? descriptor;
    for (MapEntry<String, List<String>> mapEntry in deviceNamePrefixes.entries) {
      for (var prefix in mapEntry.value) {
        if (device.name.toLowerCase().startsWith(prefix.toLowerCase())) {
          descriptor = DeviceFactory.getDescriptorForFourCC(mapEntry.key);
          break;
        }
      }
    }

    final database = Get.find<AppDatabase>();
    var deviceUsage = await database.deviceUsageDao.findDeviceUsageByMac(device.id.id);
    final advertisementDigest = _advertisementCache.getEntry(device.id.id)!;

    // Step 2. Try to infer from if it has proprietary Precor service
    // Or other dedicated workarounds
    if (descriptor == null) {
      if (!advertisementDigest.serviceUuids.contains(fitnessMachineUuid)) {
        if (advertisementDigest.serviceUuids.contains(precorServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(precorSpinnerChronoPowerFourCC);
        } else if (advertisementDigest.serviceUuids.contains(schwinnX70ServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(schwinnX70BikeFourCC);
        } else if (advertisementDigest.serviceUuids.contains(c2RowingPrimaryServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(concept2RowerFourCC);
        } else if (advertisementDigest.serviceUuids.contains(kayakFirstServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(kayakFirstFourCC);
        } else if (advertisementDigest.serviceUuids.contains(cyclingPowerServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(powerMeterBasedBikeFourCC);
        } else if (advertisementDigest.serviceUuids.contains(cyclingCadenceServiceUuid)) {
          if (_paddlingWithCyclingSensors) {
            descriptor = DeviceFactory.getDescriptorForFourCC(cscSensorBasedPaddleFourCC);
          } else {
            descriptor = DeviceFactory.getDescriptorForFourCC(cscSensorBasedBikeFourCC);
          }
        }
      } else if (advertisementDigest.needsMatrixSpecialTreatment()) {
        if (advertisementDigest.machineType == MachineType.treadmill) {
          descriptor = DeviceFactory.getDescriptorForFourCC(matrixTreadmillFourCC);
        } else if (advertisementDigest.machineType == MachineType.indoorBike) {
          descriptor = DeviceFactory.getDescriptorForFourCC(matrixBikeFourCC);
        }
      } else if (deviceUsage != null) {
        descriptor = DeviceFactory.genericDescriptorForSport(deviceUsage.sport);
      }
    }

    FitnessEquipment? fitnessEquipment;
    bool preConnectLogic = true;
    bool navigate = true;
    if (manual) {
      ComplexSensor? identifySensor;
      if (_fitnessEquipment != null &&
          _fitnessEquipment!.device != null &&
          _fitnessEquipment!.device!.id.id == device.id.id &&
          _fitnessEquipment!.descriptor != null &&
          (_fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.primarySensor ||
              _fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.secondarySensor)) {
        if (_fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.primarySensor) {
          // The user clicked twice on a primary sensor, probably there's no secondary sensor
          // And the user wants to navigate
          fitnessEquipment = _fitnessEquipment;
          preConnectLogic = false;
        } else if (_fitnessEquipment!.descriptor!.deviceCategory ==
            DeviceCategory.secondarySensor) {
          // The user clicked twice on a secondary sensor, ignore
          // But secondary sensor shouldn't have a FitnessEquipment anyway
          Get.snackbar("Warning", "Cannot measure with a pedal cadence sensor only!");
          setState(() {
            _goingToRecording = false;
          });

          _scanStreamSubscription?.resume();
          return false;
        }
      } else if (descriptor != null &&
          (descriptor.deviceCategory == DeviceCategory.secondarySensor ||
              descriptor.deviceCategory == DeviceCategory.primarySensor)) {
        bool isPrimarySensor = descriptor.deviceCategory == DeviceCategory.primarySensor;
        if (descriptor.deviceCategory == DeviceCategory.secondarySensor) {
          // Speed sensor names contain SPEED (Wahoo) or contain SPD (Garmin)
          // or starts with XOSS_VOR_S (Xoss Vortex)
          // Cadence sensor names contain CADENCE (Wahoo) or contain CAD (Garmin)
          // or starts with XOSS_VOR_C (Xoss Vortex)
          if (device.name.contains("SPEED") ||
              device.name.contains("SPD") ||
              device.name.contains("XOSS_VOR_S")) {
            descriptor.deviceCategory = DeviceCategory.primarySensor;
            isPrimarySensor = true;
          } else if (!device.name.contains("CADENCE") &&
              !device.name.contains("CAD") &&
              !device.name.contains("XOSS_VOR_C")) {
            var success = false;
            if (_fitnessEquipment != null &&
                _fitnessEquipment!.device != null &&
                _fitnessEquipment!.device!.id.id == device.id.id) {
              success = await _fitnessEquipment?.connectOnDemand(identify: true) ?? false;
            } else {
              identifySensor = descriptor.getSensor(device);
              success = await identifySensor?.connectAndDiscover() ?? false;
            }

            if (success) {
              final deviceCategory = identifySensor != null
                  ? await identifySensor.cscSensorType()
                  : await _fitnessEquipment?.cscSensorType() ?? DeviceCategory.smartDevice;
              if (deviceCategory == DeviceCategory.primarySensor) {
                isPrimarySensor = true;
                descriptor.deviceCategory = DeviceCategory.primarySensor;
                if (identifySensor == null) {
                  _fitnessEquipment?.descriptor?.deviceCategory = DeviceCategory.primarySensor;
                }
              }
            }
          }
        }

        bool currentPrimarySensor = _fitnessEquipment != null &&
            _fitnessEquipment!.descriptor != null &&
            _fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.primarySensor;
        if (isPrimarySensor && !currentPrimarySensor) {
          navigate = false;
        } else if (!isPrimarySensor && !currentPrimarySensor) {
          Get.snackbar(
              "Warning",
              "Please select a primary (wheel speed or power) sensor first. "
                  "Pedal cadence sensor should be added later.");
          setState(() {
            _goingToRecording = false;
          });

          _scanStreamSubscription?.resume();
          return false;
        } else {
          // currentPrimarySensor, instantiate this primary and secondary sensor,
          // connect and discover and add it as a companion sensor to the primary
          // and then navigate
          if (_fitnessEquipment != null) {
            if (identifySensor != null) {
              await _fitnessEquipment?.addIdentifiedCompanionSensor(descriptor, identifySensor);
            } else {
              await _fitnessEquipment?.addCompanionSensor(descriptor, device);
            }

            fitnessEquipment = _fitnessEquipment;
            device = _fitnessEquipment!.device!;
            descriptor = _fitnessEquipment?.descriptor;
            preConnectLogic = false;
          } else {
            fitnessEquipment = FitnessEquipment(device: device);
          }
        }
      }
    }

    if (preConnectLogic) {
      // Step 3. Try to infer from DeviceUsage, FTMS advertisement service data or characteristics
      bool pickedAlready = false;
      if (descriptor == null) {
        String? inferredSport;
        if (advertisementDigest.machineType.isSpecificFtms) {
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
          Logging.log(_logLevel, logLevelError, tag, "goToRecording",
              "Could not infer sport of the device");

          setState(() {
            _goingToRecording = false;
          });

          _scanStreamSubscription?.resume();
          return false;
        } else {
          descriptor = DeviceFactory.genericDescriptorForSport(inferredSport);
          if (!descriptor.isMultiSport) {
            deviceUsage = DeviceUsage(
              sport: inferredSport,
              mac: device.id.id,
              name: device.nonEmptyName,
              manufacturer: advertisementDigest.manufacturer,
              time: DateTime.now().millisecondsSinceEpoch,
            );
            await database.deviceUsageDao.insertDeviceUsage(deviceUsage);
          }
        }
      }

      final prefService = Get.find<BasePrefService>();
      if (descriptor.isMultiSport && !pickedAlready) {
        final multiSportSupport =
            prefService.get<bool>(multiSportDeviceSupportTag) ?? multiSportDeviceSupportDefault;
        if (deviceUsage == null || multiSportSupport) {
          final initialSport = deviceUsage?.sport ?? descriptor.sport;
          final sportPick = await Get.bottomSheet(
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SportPickerBottomSheet(
                        sportChoices:
                            descriptor.fourCC == kayakFirstFourCC ? paddleSports : waterSports,
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

            _scanStreamSubscription?.resume();
            return false;
          }

          descriptor.sport = sportPick;
          if (deviceUsage != null) {
            deviceUsage.sport = sportPick;
            deviceUsage.time = DateTime.now().millisecondsSinceEpoch;
            await database.deviceUsageDao.updateDeviceUsage(deviceUsage);
          } else {
            deviceUsage = DeviceUsage(
              sport: sportPick,
              mac: device.id.id,
              name: device.nonEmptyName,
              manufacturer: advertisementDigest.manufacturer,
              time: DateTime.now().millisecondsSinceEpoch,
            );
            await database.deviceUsageDao.insertDeviceUsage(deviceUsage);
          }
        } else {
          descriptor.sport = deviceUsage.sport;
          await database.deviceUsageDao.updateDeviceUsage(deviceUsage);
        }
      }

      FitnessEquipment? ftmsWithoutServiceData = fitnessEquipment;
      fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;

      await Get.delete<FitnessEquipment>(force: true);
      if (fitnessEquipment != null) {
        if (fitnessEquipment.device?.id.id != device.id.id) {
          try {
            final deviceState = await fitnessEquipment.device?.state.first.timeout(
                    const Duration(milliseconds: spinDownThreshold * 2),
                    onTimeout: () => BluetoothDeviceState.disconnected) ??
                BluetoothDeviceState.disconnected;
            if (deviceState != BluetoothDeviceState.disconnecting &&
                deviceState != BluetoothDeviceState.disconnected) {
              await fitnessEquipment.detach();
              if (!_circuitWorkout) {
                await fitnessEquipment.disconnect();
              }
            }
          } on Exception catch (e, stack) {
            Logging.logException(_logLevel, tag, "goToRecording preConnectLogic",
                "fitnessEquipment.disconnect", e, stack);
          }

          fitnessEquipment = null;
        }
      } else {
        fitnessEquipment = ftmsWithoutServiceData;
      }

      if (fitnessEquipment != null &&
          fitnessEquipment.serviceId == descriptor.dataServiceId &&
          fitnessEquipment.characteristicId == descriptor.dataCharacteristicId) {
        fitnessEquipment.descriptor = descriptor;
      } else {
        fitnessEquipment = FitnessEquipment(descriptor: descriptor, device: device);
      }

      Get.put<FitnessEquipment>(fitnessEquipment, permanent: true);

      setState(() {
        _fitnessEquipment = fitnessEquipment;
      });
    }

    final success = await fitnessEquipment!.connectOnDemand();
    if (!success) {
      Get.defaultDialog(
        middleText: 'Problem connecting to ${descriptor!.fullName}.',
        confirm: TextButton(
          child: const Text("Ok"),
          onPressed: () => Get.close(1),
        ),
      );
    }

    if (success && navigate) {
      if (deviceUsage != null) {
        deviceUsage.manufacturerName = fitnessEquipment.manufacturerName;
        deviceUsage.time = DateTime.now().millisecondsSinceEpoch;
        await database.deviceUsageDao.updateDeviceUsage(deviceUsage);
      }

      await Get.to(() => RecordingScreen(
            device: device,
            descriptor: descriptor!,
            initialState: initialState,
            size: Get.mediaQuery.size,
            sport: descriptor.sport,
          ));
      setState(() {
        _goingToRecording = false;
      });
    } else {
      setState(() {
        _goingToRecording = false;
      });

      _scanStreamSubscription?.resume();
    }

    return success;
  }

  @override
  Widget build(BuildContext context) {
    final size = Get.mediaQuery.size;
    if (size.width != _mediaWidth || size.height != _mediaHeight) {
      _mediaWidth = size.width;
      _mediaHeight = size.height;
      _landscape = _mediaWidth > _mediaHeight;
    }

    final mediaSizeMin =
        _landscape && _twoColumnLayout ? _mediaWidth / 2 : min(_mediaWidth, _mediaHeight);
    if (_mediaSizeMin < eps || (_mediaSizeMin - mediaSizeMin).abs() > eps) {
      _mediaSizeMin = mediaSizeMin;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_filterDevices ? 'Supported Devices:' : 'Devices'),
        actions: [
          _isScanning
              ? JumpingDotsProgressIndicator(
                  fontSize: 30.0,
                  color: _themeManager.getProtagonistColor(),
                )
              : (_goingToRecording || _pairingHrm)
                  ? HeartbeatProgressIndicator(
                      child:
                          IconButton(icon: const Icon(Icons.hourglass_empty), onPressed: () => {}),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async => await _startScan(false))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _startScan(false);
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
                          style: _themeManager.boldStyle(_captionStyle,
                              fontSizeFactor: fontSizeFactor),
                        ),
                        subtitle: Text(
                          _heartRateMonitor?.device?.id.id.shortAddressString() ?? emptyMeasurement,
                          style: _subtitleStyle,
                        ),
                        trailing: _themeManager.getGreenFab(
                          Icons.favorite,
                          () async {
                            if (await _heartRateMonitor?.device?.state.first ==
                                BluetoothDeviceState.connected) {
                              Get.snackbar("Info", "HRM Already connected");

                              Logging.log(_logLevel, logLevelWarning, tag, "HRM click",
                                  "HRM Already connected");
                            } else {
                              setState(() {
                                _heartRateMonitor = Get.isRegistered<HeartRateMonitor>()
                                    ? Get.find<HeartRateMonitor>()
                                    : null;
                              });
                            }
                          },
                        ),
                      )
                    : Container(),
                _fitnessEquipment != null
                    ? ListTile(
                        title: TextOneLine(
                          _fitnessEquipment?.device?.nonEmptyName ?? emptyMeasurement,
                          overflow: TextOverflow.ellipsis,
                          style: _themeManager.boldStyle(
                            _captionStyle,
                            fontSizeFactor: fontSizeFactor,
                          ),
                        ),
                        subtitle: Text(
                          _fitnessEquipment?.device?.id.id.shortAddressString() ?? emptyMeasurement,
                          style: _subtitleStyle,
                        ),
                        trailing: _themeManager.getGreenFab(
                          Icons.open_in_new,
                          () async {
                            final deviceState = await _fitnessEquipment?.device?.state.first ??
                                BluetoothDeviceState.disconnected;
                            if (deviceState == BluetoothDeviceState.connected) {
                              if (_isScanning) {
                                await FlutterBluePlus.instance.stopScan();
                                await Future.delayed(
                                    const Duration(milliseconds: uiIntermittentDelay));
                              }

                              await goToRecording(
                                _fitnessEquipment!.device!,
                                deviceState,
                                true,
                              );
                            } else {
                              setState(() {
                                _fitnessEquipment = Get.isRegistered<FitnessEquipment>()
                                    ? Get.find<FitnessEquipment>()
                                    : null;
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
              stream: _scanStreamController.stream,
              initialData: const [],
              builder: (c, snapshot) => snapshot.data == null
                  ? Container()
                  : Column(
                      children: snapshot.data!.where((d) => d.isWorthy(_filterDevices)).map((r) {
                        addScannedDevice(r);
                        if (_logLevel >= logLevelInfo) {
                          Logging.log(_logLevel, logLevelInfo, tag, "ScanResult", r.toString());
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
                          deviceSport: _deviceSport[r.device.id.id] ?? "",
                          mediaWidth: _mediaSizeMin,
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
                const Tuple2<IconData, String>(Icons.coffee, "Donation"),
                const Tuple2<IconData, String>(Icons.help, "About"),
                const Tuple2<IconData, String>(Icons.info_rounded, "Help Legend"),
              ]);
            },
          ),
          _themeManager.getAboutFab(),
          _themeManager.getBlueFab(Icons.coffee, () async {
            Get.to(() => const DonationScreen());
          }),
          _themeManager.getBlueFab(Icons.list_alt, () async {
            final database = Get.find<AppDatabase>();
            final hasLeaderboardData =
                (await database.workoutSummaryDao.getLeaderboardDataCount() ?? 0) > 0;
            Get.to(() => ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
          }),
          _isScanning
              ? _themeManager.getBlueFab(Icons.stop, () async {
                  if (_isScanning) {
                    await FlutterBluePlus.instance.stopScan();
                    await Future.delayed(const Duration(milliseconds: uiIntermittentDelay));
                  }
                })
              : _themeManager.getGreenFab(Icons.search, () async => await _startScan(false)),
          _themeManager.getBlueFab(
            Icons.settings,
            () async => Get.to(() => const PreferencesHubScreen()),
          ),
        ],
      ),
    );
  }
}
