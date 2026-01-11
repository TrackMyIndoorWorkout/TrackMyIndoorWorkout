import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth.dart';

class BluetoothAdapter {
  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;

  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<bool> checkBluetooth(bool silent, int logLevel) => bluetoothCheck(silent, logLevel);

  Future<void> startScan({
    List<Guid> withServices = const [],
    Duration? timeout,
    Duration? removeIfGone,
    bool oneByOne = false,
    bool androidUsesFineLocation = false,
  }) {
    return FlutterBluePlus.startScan(
      withServices: withServices,
      timeout: timeout,
      removeIfGone: removeIfGone,
      oneByOne: oneByOne,
      androidUsesFineLocation: androidUsesFineLocation,
    );
  }

  BluetoothAdapterState get adapterStateNow => FlutterBluePlus.adapterStateNow;

  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  Future<void> turnOn() => FlutterBluePlus.turnOn();

  Future<bool> isBluetoothOn() => isBluetoothOn();

  Future<void> stopScan() => FlutterBluePlus.stopScan();
}
