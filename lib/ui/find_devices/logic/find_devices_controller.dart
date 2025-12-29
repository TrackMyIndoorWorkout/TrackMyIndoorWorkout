import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../devices/bluetooth_device_ex.dart';
import '../../../devices/device_descriptors/device_descriptor.dart';
import '../../../devices/device_factory.dart';
import '../../../devices/device_fourcc.dart';
import '../../../devices/gadgets/complex_sensor.dart';
import '../../../devices/gadgets/fitness_equipment.dart';
import '../../../devices/gadgets/heart_rate_monitor.dart';
import '../../../devices/gatt/appearance.dart';
import '../../../devices/gatt/concept2.dart';
import '../../../devices/gatt/csc.dart';
import '../../../devices/gatt/ftms.dart';
import '../../../devices/gatt/hrm.dart';
import '../../../devices/gatt/kayak_first.dart';
import '../../../devices/gatt/power_meter.dart';
import '../../../devices/gatt/precor.dart';
import '../../../devices/gatt/schwinn_x70.dart';
import '../../../devices/gatt_maps.dart';
import '../../../persistence/db_utils.dart';
import '../../../persistence/device_usage.dart';
import '../../../preferences/auto_connect.dart';
import '../../../preferences/device_filtering.dart';
import '../../../preferences/heart_rate_monitor_workout.dart';
import '../../../preferences/instant_scan.dart';
import '../../../preferences/last_equipment_id.dart';
import '../../../preferences/log_level.dart';
import '../../../preferences/multi_sport_device_support.dart';
import '../../../preferences/paddling_with_cycling_sensors.dart';
import '../../../preferences/scan_duration.dart';
import '../../../preferences/sport_spec.dart';
import '../../../preferences/stationary_workout.dart';
import '../../../preferences/treadmill_rsc_only_mode.dart';
import '../../../preferences/two_column_layout.dart';
import '../../../preferences/welcome_presented.dart';
import '../../../preferences/workout_mode.dart';
import '../../../utils/address_names.dart';
import '../../../utils/bluetooth.dart';
import '../../../utils/constants.dart';
import '../../../utils/delays.dart';
import '../../../utils/logging.dart';
import '../../../utils/machine_type.dart';
import '../../../utils/scan_result_ex.dart';
import '../../../utils/theme_manager.dart';
import '../../about.dart';
import '../../models/advertisement_cache.dart';
import '../../parts/boolean_question.dart';
import '../../parts/sport_picker.dart';
import '../../recording/recording_screen.dart';

class FindDevicesController extends GetxController {
  static const String tag = "FIND_DEVICES";

  bool instantScan = instantScanDefault;
  int _scanDuration = scanDurationDefault;
  bool autoConnect = autoConnectDefault;
  bool _circuitWorkout = workoutModeDefault == workoutModeCircuit;
  bool _paddlingWithCyclingSensors = paddlingWithCyclingSensorsDefault;
  String _treadmillRscOnlyMode = treadmillRscOnlyModeDefault;
  bool _stationaryWorkout = stationaryWorkoutDefault;
  bool heartRateMonitorWorkout = heartRateMonitorWorkoutDefault;
  bool isScanning = false;
  final List<BluetoothDevice> scannedDevices = [];
  final StreamController<List<ScanResult>> scanStreamController = StreamController.broadcast();
  StreamSubscription<List<ScanResult>>? _scanStreamSubscription;
  final Map<String, String> deviceSport = {};
  bool goingToRecording = false;
  bool _autoConnectLatch = false;
  int logLevel = logLevelDefault;
  bool pairingHrm = false;
  final List<String> _lastEquipmentIds = [];
  bool filterDevices = deviceFilteringDefault;
  HeartRateMonitor? heartRateMonitor;
  FitnessEquipment? fitnessEquipment;

  // Media / Layout
  double mediaSizeMin = 0;
  double mediaHeight = 0;
  double mediaWidth = 0;
  bool landscape = false;
  bool twoColumnLayout = twoColumnLayoutDefault;

  bool privacyStatementViews = false;

  final AdvertisementCache advertisementCache = Get.find<AdvertisementCache>();
  final ThemeManager themeManager = Get.find<ThemeManager>();

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting();

    final addressNames = Get.find<AddressNames>();
    DbUtils().getAddressNameDictionary(addressNames);

    _readPreferencesValues();
    isScanning = false;
    _scanStreamSubscription = _throttledScanStream.listen((scanResults) {
      _processScanResults(scanResults);
      scanStreamController.add(scanResults);
    });

    heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;

    _checkWelcomeAndStart();
  }

  @override
  void onClose() {
    scanStreamController.close();
    _scanStreamSubscription?.cancel();

    if (isScanning) {
      try {
        FlutterBluePlus.stopScan();
      } on Exception catch (e, stack) {
        Logging().logException(logLevel, tag, "dispose", "FlutterBluePlus.stopScan", e, stack);
      }
    }

    heartRateMonitor?.detach();
    super.onClose();
  }

  void _checkWelcomeAndStart() {
    if (huaweiAppGalleryBuild) {
      final prefService = Get.find<BasePrefService>();
      final welcomePresented =
          Get.find<BasePrefService>().get<bool>(welcomePresentedTag) ?? welcomePresentedDefault;
      if (!welcomePresented) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Dialog logic needs Context or Get.dialog
          await _showWelcomeDialog(prefService);
        });
      } else if (instantScan) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          startScan(true);
        });
      }
    } else if (instantScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startScan(true);
      });
    }
  }

  Future<void> _showWelcomeDialog(BasePrefService prefService) async {
    final agreed = await Get.defaultDialog(
      barrierDismissible: false,
      title: "Welcome to $displayAppName",
      content: ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: const Text("Click to Read Privacy Policy"),
        onPressed: () async {
          if (await canLaunchUrlString(AboutScreen.privacyPolicyUrl)) {
            if (await launchUrlString(AboutScreen.privacyPolicyUrl)) {
              privacyStatementViews = true;
              update();
            }
          } else {
            Get.snackbar("Attention", "Please open URL manually: ${AboutScreen.privacyPolicyUrl}");
          }
        },
      ),
      confirm: TextButton(
        child: const Text("Agree"),
        onPressed: () {
          if (privacyStatementViews) {
            Get.back(result: true);
          } else {
            Get.snackbar("Must read Privacy Policy to agree", "Click the dialog's button to read");
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

    if (agreed == true) {
      prefService.set<bool>(welcomePresentedTag, true);
      if (instantScan) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          startScan(true);
        });
      }
    }
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

  void _readPreferencesValues() {
    final prefService = Get.find<BasePrefService>();
    instantScan = prefService.get<bool>(instantScanTag) ?? instantScanDefault;
    _scanDuration = prefService.get<int>(scanDurationTag) ?? scanDurationDefault;
    autoConnect = prefService.get<bool>(autoConnectTag) ?? autoConnectDefault;
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
    _treadmillRscOnlyMode =
        prefService.get<String>(treadmillRscOnlyModeTag) ?? treadmillRscOnlyModeDefault;
    _stationaryWorkout = prefService.get<bool>(stationaryWorkoutTag) ?? stationaryWorkoutDefault;
    heartRateMonitorWorkout =
        prefService.get<bool>(heartRateMonitorWorkoutTag) ?? heartRateMonitorWorkoutDefault;
    filterDevices = prefService.get<bool>(deviceFilteringTag) ?? deviceFilteringDefault;
    logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    twoColumnLayout = prefService.get<bool>(twoColumnLayoutTag) ?? twoColumnLayoutDefault;
  }

  Future<void> _readDeviceSports() async {
    deviceSport.clear();
    final database = Get.find<Isar>();
    for (final deviceUsage in await database.deviceUsages.where().findAll()) {
      deviceSport[deviceUsage.mac] = deviceUsage.sport;
    }
  }

  Future<void> startScan(bool silent) async {
    if (isScanning) {
      Logging().log(logLevel, logLevelInfo, tag, "_startScan", "Scan already in progress");
      return;
    }

    if (!await bluetoothCheck(silent, logLevel)) {
      Logging().log(logLevel, logLevelInfo, tag, "_startScan", "bluetooth check failed");
      return;
    }

    await _startScanCore(silent);
  }

  Future<void> _startScanCore(bool silent) async {
    Logging().log(logLevel, logLevelInfo, tag, "_startScanCore", "Scan initiated");

    _readPreferencesValues();
    await _readDeviceSports();
    scannedDevices.clear();
    isScanning = true;
    update();

    _autoConnectLatch = true;

    if (_scanStreamSubscription?.isPaused ?? false) {
      _scanStreamSubscription?.resume();
    }

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: _scanDuration));

      isScanning = false;
      update();

      if (!silent || !autoConnect) {
        return;
      }

      // Try auto-connect
      final lasts = scannedDevices.where((d) => _lastEquipmentIds.contains(d.remoteId.str));
      if (fitnessEquipment != null &&
              !advertisementCache.hasEntry(
                fitnessEquipment!.device?.remoteId.str ?? emptyMeasurement,
              ) ||
          filterDevices &&
              scannedDevices.length == 1 &&
              !advertisementCache.hasEntry(scannedDevices.first.remoteId.str) ||
          scannedDevices.length > 1 &&
              _lastEquipmentIds.isNotEmpty &&
              lasts.isNotEmpty &&
              !advertisementCache.hasAnyEntry(_lastEquipmentIds)) {
        Logging().log(
          logLevel,
          logLevelWarning,
          tag,
          "_startScanCore finished pre auto-connect",
          "advertisementCache miss",
        );
      } else if (autoConnect && !goingToRecording && _autoConnectLatch) {
        if (fitnessEquipment != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            goToRecording(fitnessEquipment!.device!, BluetoothConnectionState.connected, false);
          });
        } else {
          if (filterDevices && scannedDevices.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              goToRecording(scannedDevices.first, BluetoothConnectionState.disconnected, false);
            });
          } else if (scannedDevices.length > 1 && _lastEquipmentIds.isNotEmpty) {
            final lasts = scannedDevices
                .where(
                  (d) =>
                      _lastEquipmentIds.contains(d.remoteId.str) &&
                      advertisementCache.hasEntry(d.remoteId.str),
                )
                .toList(growable: false);
            if (lasts.isNotEmpty) {
              lasts.sort((a, b) {
                return advertisementCache
                    .getEntry(a.remoteId.str)!
                    .txPower
                    .compareTo(advertisementCache.getEntry(b.remoteId.str)!.txPower);
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                goToRecording(lasts.last, BluetoothConnectionState.disconnected, false);
              });
            }
          }
        }
      }
    } on Exception catch (e, stack) {
      Logging().logException(
        logLevel,
        tag,
        "_startScanCore",
        "FlutterBluePlus.startScan",
        e,
        stack,
      );
    }
  }

  void addScannedDevice(ScanResult scanResult) {
    if (!scanResult.isWorthy(filterDevices)) {
      return;
    }

    String deviceId = scanResult.device.remoteId.str;
    String dSport = deviceSport[deviceId] ?? "";
    advertisementCache.addEntry(scanResult, dSport);

    if (scannedDevices.where((d) => d.remoteId.str == scanResult.device.remoteId.str).isEmpty) {
      scannedDevices.add(scanResult.device);
    }
  }

  // Define goToRecording and other methods here...
  Future<bool> goToRecording(
    BluetoothDevice device,
    BluetoothConnectionState initialState,
    bool manual,
  ) async {
    Logging().logVersion(Get.find<PackageInfo>());

    if (!advertisementCache.hasEntry(device.remoteId.str)) {
      return false;
    }

    if (goingToRecording || autoConnect && !manual && !_autoConnectLatch) {
      return false;
    }

    goingToRecording = true;
    update();
    _scanStreamSubscription?.pause();
    _autoConnectLatch = false;

    // Device determination logics
    // Step 1. Try to infer from the Bluetooth advertised name
    final advertisementDigest = advertisementCache.getEntry(device.remoteId.str)!;
    DeviceDescriptor? descriptor;
    if (!advertisementDigest.needsMatrixSpecialTreatment()) {
      final loweredPlatformName = device.platformName.toLowerCase();
      final ftmsServiceSports = advertisementDigest.machineTypes
          .map((m) => m.sport)
          .toList(growable: false);
      var found = false;
      for (final mapEntry in deviceNamePrefixes.entries.whereNot((dnp) => dnp.value.ambiguous)) {
        if (found) break;
        final lowerPostfix = mapEntry.value.deviceNameLoweredPostfix;
        final descriptorDefaultSport = deviceSportDescriptors[mapEntry.key]!.defaultSport;
        for (var lowerPrefix in mapEntry.value.deviceNameLoweredPrefixes) {
          if (loweredPlatformName.startsWith(lowerPrefix) &&
              (lowerPostfix.isEmpty || loweredPlatformName.endsWith(lowerPostfix)) &&
              !mapEntry.value.shouldBeExcludedByBluetoothName(loweredPlatformName) &&
              (!mapEntry.value.sportsMatch || ftmsServiceSports.contains(descriptorDefaultSport)) &&
              advertisementDigest.isPrefixContained(mapEntry.value.manufacturerNameLoweredPrefix)) {
            if (mapEntry.key == technogymRunFourCC &&
                _treadmillRscOnlyMode == treadmillRscOnlyModeNever) {
              continue;
            }

            if (allConcept2FourCCs.contains(mapEntry.key) &&
                advertisementDigest.serviceUuids.contains(fitnessMachineUuid)) {
              // TODO: Does BikeErg implement Indoor Bike FTMS (if any at all)?
              // TODO: What does SkiErg implement (if any at all)?
              continue;
            }

            var descriptorCandidate = DeviceFactory.getDescriptorForFourCC(mapEntry.key);
            if (descriptorCandidate.sport == ActivityType.run &&
                mapEntry.key != technogymRunFourCC &&
                _treadmillRscOnlyMode == treadmillRscOnlyModeAlways) {
              descriptorCandidate = DeviceFactory.getDescriptorForFourCC(technogymRunFourCC);
            }

            descriptor = descriptorCandidate;
            found = true;
            break;
          }
        }
      }
    }

    final database = Get.find<Isar>();
    var deviceUsage = await database.deviceUsages
        .where()
        .filter()
        .macEqualTo(device.remoteId.str)
        .sortByTimeDesc()
        .findFirst();

    // Step 2. Try to infer from if it has proprietary service
    // Or other dedicated workarounds
    if (descriptor == null) {
      if (!advertisementDigest.serviceUuids.contains(fitnessMachineUuid)) {
        if (advertisementDigest.serviceUuids.contains(precorServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(precorSpinnerChronoPowerFourCC);
        } else if (advertisementDigest.serviceUuids.contains(schwinnX70ServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(schwinnX70BikeFourCC);
        } else if (advertisementDigest.serviceUuids.contains(c2ErgPrimaryServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(concept2ErgFourCC);
        } else if (advertisementDigest.serviceUuids.contains(kayakFirstServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(kayakFirstFourCC);
        } else if (advertisementDigest.serviceUuids.contains(cyclingPowerServiceUuid)) {
          if (_paddlingWithCyclingSensors) {
            descriptor = DeviceFactory.getDescriptorForFourCC(powerMeterBasedPaddleFourCC);
          } else {
            descriptor = DeviceFactory.getDescriptorForFourCC(powerMeterBasedBikeFourCC);
          }
        } else if (advertisementDigest.serviceUuids.contains(cyclingCadenceServiceUuid)) {
          if (_paddlingWithCyclingSensors) {
            descriptor = DeviceFactory.getDescriptorForFourCC(cscSensorBasedPaddleFourCC);
          } else {
            descriptor = DeviceFactory.getDescriptorForFourCC(cscSensorBasedBikeFourCC);
          }
        } else if (advertisementDigest.serviceUuids.contains(heartRateServiceUuid) &&
            heartRateMonitorWorkout) {
          descriptor = DeviceFactory.getDescriptorForFourCC(heartRateMonitorFourCC);
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

    FitnessEquipment? fitnessEquipmentToConnect;
    bool preConnectLogic = true;
    bool navigate = true;
    if (manual) {
      ComplexSensor? identifySensor;
      if (fitnessEquipment != null &&
          fitnessEquipment!.device != null &&
          fitnessEquipment!.device!.remoteId.str == device.remoteId.str &&
          fitnessEquipment!.descriptor != null &&
          (fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.primarySensor ||
              fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.secondarySensor)) {
        if (primaryCyclingSensorAppearances.contains(advertisementDigest.appearance) ||
            fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.primarySensor) {
          // The user clicked twice on a primary sensor, probably there's no secondary sensor
          // And the user wants to navigate
          fitnessEquipmentToConnect = fitnessEquipment;
          preConnectLogic = false;
        } else if (advertisementDigest.appearance == appearanceCadenceSensor &&
            fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.secondarySensor) {
          // The user clicked twice on a secondary sensor, ignore
          // But secondary sensor shouldn't have a FitnessEquipment anyway
          Get.snackbar("Warning", "Cannot measure distance and speed with a cadence sensor only!");
          goingToRecording = false;
          update();

          _scanStreamSubscription?.resume();
          return false;
        }
      } else if (descriptor != null &&
          (descriptor.deviceCategory == DeviceCategory.secondarySensor ||
              descriptor.deviceCategory == DeviceCategory.primarySensor)) {
        bool isPrimarySensor = descriptor.deviceCategory == DeviceCategory.primarySensor;
        if (descriptor.deviceCategory == DeviceCategory.secondarySensor) {
          if (device.platformName.contains("SPEED") ||
              device.platformName.contains("SPD") ||
              device.platformName.contains("XOSS_VOR_S")) {
            descriptor.deviceCategory = DeviceCategory.primarySensor;
            isPrimarySensor = true;
          } else if (!device.platformName.contains("CADENCE") &&
              !device.platformName.contains("CAD") &&
              !device.platformName.contains("XOSS_VOR_C")) {
            var success = false;
            if (fitnessEquipment != null &&
                fitnessEquipment!.device != null &&
                fitnessEquipment!.device!.remoteId.str == device.remoteId.str) {
              success = await fitnessEquipment?.connectOnDemand(identify: true) ?? false;
            } else {
              identifySensor = descriptor.getSensor(device);
              success = await identifySensor?.connectAndDiscover() ?? false;
            }

            if (success) {
              final deviceCategory = identifySensor != null
                  ? await identifySensor.cscSensorType()
                  : await fitnessEquipment?.cscSensorType() ?? DeviceCategory.smartDevice;
              if (deviceCategory == DeviceCategory.primarySensor) {
                isPrimarySensor = true;
                descriptor.deviceCategory = DeviceCategory.primarySensor;
                if (identifySensor == null) {
                  fitnessEquipment?.descriptor?.deviceCategory = DeviceCategory.primarySensor;
                }
              }
            }
          }
        }

        bool currentPrimarySensor =
            _stationaryWorkout ||
            (fitnessEquipment != null &&
                fitnessEquipment!.descriptor != null &&
                fitnessEquipment!.descriptor!.deviceCategory == DeviceCategory.primarySensor);
        if (isPrimarySensor && !currentPrimarySensor) {
          navigate = false;
        } else if (!isPrimarySensor && !currentPrimarySensor) {
          Get.snackbar(
            "Warning",
            "Please select a speed / pace or power sensor first. "
                "Cadence sensor may not be enough for speed / pace.",
          );
          goingToRecording = false;
          update();

          _scanStreamSubscription?.resume();
          return false;
        } else {
          if (fitnessEquipment != null) {
            if (identifySensor != null) {
              await fitnessEquipment?.addIdentifiedCompanionSensor(descriptor, identifySensor);
            } else {
              await fitnessEquipment?.addCompanionSensor(descriptor, device);
            }

            fitnessEquipmentToConnect = fitnessEquipment;
            device = fitnessEquipment!.device!;
            descriptor = fitnessEquipment?.descriptor;
            preConnectLogic = false;
          } else {
            fitnessEquipmentToConnect = FitnessEquipment(device: device);
          }
        }
      }
    }

    if (preConnectLogic) {
      bool pickedAlready = false;
      if (descriptor == null) {
        String? inferredSport;
        if (advertisementDigest.machineType.isSpecificFtms) {
          inferredSport = advertisementDigest.machineType.sport;
        } else if (advertisementDigest.serviceUuids.contains(fitnessMachineUuid)) {
          goingToRecording = true;
          update();

          fitnessEquipmentToConnect = FitnessEquipment(device: device);
          final success = await fitnessEquipmentToConnect.connectOnDemand(identify: true);
          if (success) {
            final inferredSports = fitnessEquipmentToConnect.inferSportsFromCharacteristicIds();
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
                await fitnessEquipmentToConnect.setCharacteristicById(sportToUuid[inferredSport]!);
              }
            }
          }
        }

        if (inferredSport == null) {
          Get.snackbar("Error", "Could not infer sport of the device");
          Logging().log(
            logLevel,
            logLevelError,
            tag,
            "goToRecording",
            "Could not infer sport of the device",
          );

          goingToRecording = false;
          update();

          _scanStreamSubscription?.resume();
          return false;
        } else {
          descriptor = DeviceFactory.genericDescriptorForSport(inferredSport);
          if (!descriptor.isMultiSport) {
            deviceUsage = DeviceUsage(
              sport: inferredSport,
              mac: device.remoteId.str,
              name: device.nonEmptyName,
              manufacturer: advertisementDigest.manufacturers.join("| "),
              time: DateTime.now(),
            );
            database.writeTxnSync(() {
              database.deviceUsages.putSync(deviceUsage!);
            });
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
                        sportChoices: DeviceFactory.getSportChoices(descriptor.fourCC),
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
            goingToRecording = false;
            update();

            _scanStreamSubscription?.resume();
            return false;
          }

          descriptor.sport = sportPick;
          if (deviceUsage != null) {
            deviceUsage.sport = sportPick;
            deviceUsage.time = DateTime.now();
            database.writeTxnSync(() {
              database.deviceUsages.putSync(deviceUsage!);
            });
          } else {
            deviceUsage = DeviceUsage(
              sport: sportPick,
              mac: device.remoteId.str,
              name: device.nonEmptyName,
              manufacturer: advertisementDigest.manufacturers.join("| "),
              time: DateTime.now(),
            );
            database.writeTxnSync(() {
              database.deviceUsages.putSync(deviceUsage!);
            });
          }
        } else {
          descriptor.sport = deviceUsage.sport;
          database.writeTxnSync(() {
            database.deviceUsages.putSync(deviceUsage!);
          });
        }
      }

      FitnessEquipment? ftmsWithoutServiceData = fitnessEquipmentToConnect;
      fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;

      await Get.delete<FitnessEquipment>(force: true);
      if (fitnessEquipment != null) {
        if (fitnessEquipment!.device?.remoteId.str != device.remoteId.str) {
          try {
            final connectionState =
                await fitnessEquipment!.device?.connectionState.first.timeout(
                  const Duration(milliseconds: spinDownThreshold * 2),
                  onTimeout: () => BluetoothConnectionState.disconnected,
                ) ??
                BluetoothConnectionState.disconnected;
            if (connectionState != BluetoothConnectionState.disconnected) {
              await fitnessEquipment!.detach();
              if (!_circuitWorkout) {
                await fitnessEquipment!.disconnect();
              }
            }
          } on Exception catch (e, stack) {
            Logging().logException(
              logLevel,
              tag,
              "goToRecording preConnectLogic",
              "fitnessEquipment.disconnect",
              e,
              stack,
            );
          }

          fitnessEquipment = null;
        }
      } else {
        fitnessEquipmentToConnect = ftmsWithoutServiceData;
      }

      if (fitnessEquipmentToConnect != null &&
          fitnessEquipmentToConnect.serviceId == descriptor.dataServiceId &&
          fitnessEquipmentToConnect.characteristicId == descriptor.dataCharacteristicId) {
        fitnessEquipmentToConnect.descriptor = descriptor;
      } else {
        fitnessEquipmentToConnect = FitnessEquipment(descriptor: descriptor, device: device);
      }

      Get.put<FitnessEquipment>(fitnessEquipmentToConnect, permanent: true);

      fitnessEquipment = fitnessEquipmentToConnect;
      update();
    }

    final success = await fitnessEquipment!.connectOnDemand();
    if (!success) {
      Get.defaultDialog(
        middleText: 'Problem connecting to ${descriptor!.fullName}.',
        confirm: TextButton(child: const Text("Ok"), onPressed: () => Get.close(1)),
      );
    }

    if (success && navigate) {
      if (deviceUsage != null) {
        deviceUsage.manufacturerName = fitnessEquipment!.manufacturerName;
        deviceUsage.time = DateTime.now();
        database.writeTxnSync(() {
          database.deviceUsages.putSync(deviceUsage!);
        });
      }

      await Get.to(
        () => RecordingScreen(
          device: device,
          descriptor: descriptor!,
          initialState: initialState,
          size: Get.mediaQuery.size,
          sport: descriptor.sport,
        ),
      );
      goingToRecording = false;
      update();
    } else {
      goingToRecording = false;
      update();

      _scanStreamSubscription?.resume();
    }

    return success;
  }

  void updateLayout(Size size) {
    if (size.width != mediaWidth || size.height != mediaHeight) {
      mediaWidth = size.width;
      mediaHeight = size.height;
      landscape = mediaWidth > mediaHeight;
    }

    final mSizeMin = landscape && twoColumnLayout ? mediaWidth / 2 : min(mediaWidth, mediaHeight);
    if (mediaSizeMin < eps || (mediaSizeMin - mSizeMin).abs() > eps) {
      mediaSizeMin = mSizeMin;
      update();
    }
  }

  // Public methods to trigger UI actions from FAB or Tiles

  Future<void> onScanToggle(bool start) async {
    if (start) {
      await startScan(false);
    } else {
      if (isScanning) {
        await FlutterBluePlus.stopScan();
        await Future.delayed(const Duration(milliseconds: uiIntermittentDelay));
        // isScanning is updated by startScan's awaited future completing?
        // To be safe:
        isScanning = false;
        update();
      }
    }
  }

  Future<void> onEquipmentTap(ScanResult r) async {
    if (!await bluetoothCheck(false, logLevel)) {
      return;
    }

    if (isScanning) {
      await FlutterBluePlus.stopScan();
      await Future.delayed(const Duration(milliseconds: uiIntermittentDelay));
      isScanning = false;
      update();
    }

    await goToRecording(r.device, BluetoothConnectionState.disconnected, true);
  }

  Future<void> onHrmTap(ScanResult r) async {
    if (!await bluetoothCheck(false, logLevel)) {
      return;
    }

    pairingHrm = true;
    update();

    var heartRateMonitorCandidate = Get.isRegistered<HeartRateMonitor>()
        ? Get.find<HeartRateMonitor>()
        : null;
    final existingId = heartRateMonitorCandidate?.device?.remoteId.str ?? notAvailable;
    final storedId = heartRateMonitor?.device?.remoteId.str ?? notAvailable;
    bool disconnectOnly = false;
    if (heartRateMonitorCandidate != null) {
      disconnectOnly = existingId == r.device.remoteId.str;
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
                  child: BooleanQuestionBottomSheet(title: title, content: content),
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

      if (verdict != true) {
        if (existingId != storedId) {
          heartRateMonitor = heartRateMonitorCandidate;
          update();
        }

        pairingHrm = false;
        update();
        return;
      }
    }

    if (heartRateMonitorCandidate != null) {
      await heartRateMonitorCandidate.detach();
      await heartRateMonitorCandidate.disconnect();
      if (disconnectOnly) {
        if (existingId != storedId) {
          heartRateMonitor = heartRateMonitorCandidate;
          update();
        } else {
          await Get.delete<HeartRateMonitor>(force: true);
          heartRateMonitor = null;
          update();
        }

        pairingHrm = false;
        update();
        return;
      }
    }

    if (heartRateMonitorCandidate == null || existingId != r.device.remoteId.str) {
      heartRateMonitorCandidate = HeartRateMonitor(r.device);
      if (Get.isRegistered<HeartRateMonitor>()) {
        await Get.delete<HeartRateMonitor>(force: true);
      }

      Get.put<HeartRateMonitor>(heartRateMonitorCandidate, permanent: true);
      await heartRateMonitorCandidate.connect();
      await heartRateMonitorCandidate.discover();
      heartRateMonitor = heartRateMonitorCandidate;
      update();
    } else if (existingId != storedId) {
      heartRateMonitor = heartRateMonitorCandidate;
      update();
    }

    pairingHrm = false;
    update();
  }

  void _processScanResults(List<ScanResult> results) {
    for (var r in results) {
      if (!r.isWorthy(filterDevices)) continue;

      addScannedDevice(r);
      if (logLevel >= logLevelInfo) {
        Logging().log(logLevel, logLevelInfo, tag, "ScanResult", r.toString());
      }

      if (autoConnect && _lastEquipmentIds.contains(r.device.remoteId.str)) {
        if (isScanning) {
          FlutterBluePlus.stopScan().whenComplete(() async {
            await Future.delayed(const Duration(milliseconds: uiIntermittentDelay));
            isScanning = false;
            update();
          });
        }
      }
    }
  }

  Future<void> onConnectedHrmTap() async {
    final hrmConnectionState = await heartRateMonitor?.device?.connectionState.first;
    if (heartRateMonitorWorkout) {
      if (heartRateMonitor != null &&
          heartRateMonitor!.device != null &&
          hrmConnectionState != null) {
        await goToRecording(heartRateMonitor!.device!, hrmConnectionState, true);
        return;
      } else {
        Get.snackbar("Info", "HRM or BLE device or state is null");

        Logging().log(
          logLevel,
          logLevelWarning,
          tag,
          "HRM connection error",
          "HRM or BLE device or state is null",
        );
      }
    }
    if (hrmConnectionState == BluetoothConnectionState.connected) {
      Get.snackbar("Info", "HRM Already connected");

      Logging().log(logLevel, logLevelWarning, tag, "HRM click", "HRM Already connected");
    } else {
      heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
      update();
    }
  }

  Future<void> onConnectedEquipmentTap() async {
    final connectionState =
        await fitnessEquipment?.device?.connectionState.first ??
        BluetoothConnectionState.disconnected;
    if (connectionState == BluetoothConnectionState.connected) {
      if (isScanning) {
        await FlutterBluePlus.stopScan();
        await Future.delayed(const Duration(milliseconds: uiIntermittentDelay));
        isScanning = false;
        update();
      }

      await goToRecording(fitnessEquipment!.device!, connectionState, true);
    } else {
      fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
      update();
    }
  }
}
