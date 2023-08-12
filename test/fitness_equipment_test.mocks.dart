// Mocks generated by Mockito 5.4.2 from annotations
// in track_my_indoor_exercise/test/fitness_equipment_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDeviceIdentifier_0 extends _i1.SmartFake implements _i2.DeviceIdentifier {
  _FakeDeviceIdentifier_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGuid_1 extends _i1.SmartFake implements _i2.Guid {
  _FakeGuid_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCharacteristicProperties_2 extends _i1.SmartFake
    implements _i2.CharacteristicProperties {
  _FakeCharacteristicProperties_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [BluetoothDevice].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothDevice extends _i1.Mock implements _i2.BluetoothDevice {
  @override
  _i2.DeviceIdentifier get remoteId => (super.noSuchMethod(
        Invocation.getter(#remoteId),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
      ) as _i2.DeviceIdentifier);
  @override
  String get localName => (super.noSuchMethod(
        Invocation.getter(#localName),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i2.BluetoothDeviceType get type => (super.noSuchMethod(
        Invocation.getter(#type),
        returnValue: _i2.BluetoothDeviceType.unknown,
        returnValueForMissingStub: _i2.BluetoothDeviceType.unknown,
      ) as _i2.BluetoothDeviceType);
  @override
  _i3.Stream<bool> get isDiscoveringServices => (super.noSuchMethod(
        Invocation.getter(#isDiscoveringServices),
        returnValue: _i3.Stream<bool>.empty(),
        returnValueForMissingStub: _i3.Stream<bool>.empty(),
      ) as _i3.Stream<bool>);
  @override
  _i3.Stream<List<_i2.BluetoothService>> get servicesStream => (super.noSuchMethod(
        Invocation.getter(#servicesStream),
        returnValue: _i3.Stream<List<_i2.BluetoothService>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<_i2.BluetoothService>>.empty(),
      ) as _i3.Stream<List<_i2.BluetoothService>>);
  @override
  _i3.Stream<_i2.BluetoothConnectionState> get connectionState => (super.noSuchMethod(
        Invocation.getter(#connectionState),
        returnValue: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
        returnValueForMissingStub: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
      ) as _i3.Stream<_i2.BluetoothConnectionState>);
  @override
  _i3.Stream<int> get mtu => (super.noSuchMethod(
        Invocation.getter(#mtu),
        returnValue: _i3.Stream<int>.empty(),
        returnValueForMissingStub: _i3.Stream<int>.empty(),
      ) as _i3.Stream<int>);
  @override
  _i2.DeviceIdentifier get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#id),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#id),
        ),
      ) as _i2.DeviceIdentifier);
  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i3.Stream<_i2.BluetoothConnectionState> get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
        returnValueForMissingStub: _i3.Stream<_i2.BluetoothConnectionState>.empty(),
      ) as _i3.Stream<_i2.BluetoothConnectionState>);
  @override
  _i3.Stream<List<_i2.BluetoothService>> get services => (super.noSuchMethod(
        Invocation.getter(#services),
        returnValue: _i3.Stream<List<_i2.BluetoothService>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<_i2.BluetoothService>>.empty(),
      ) as _i3.Stream<List<_i2.BluetoothService>>);
  @override
  _i3.Future<void> connect({
    Duration? timeout = const Duration(seconds: 35),
    bool? autoConnect = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #connect,
          [],
          {
            #timeout: timeout,
            #autoConnect: autoConnect,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> disconnect({int? timeout = 35}) => (super.noSuchMethod(
        Invocation.method(
          #disconnect,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<List<_i2.BluetoothService>> discoverServices({int? timeout = 15}) =>
      (super.noSuchMethod(
        Invocation.method(
          #discoverServices,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<List<_i2.BluetoothService>>.value(<_i2.BluetoothService>[]),
        returnValueForMissingStub:
            _i3.Future<List<_i2.BluetoothService>>.value(<_i2.BluetoothService>[]),
      ) as _i3.Future<List<_i2.BluetoothService>>);
  @override
  _i3.Future<int> readRssi({int? timeout = 15}) => (super.noSuchMethod(
        Invocation.method(
          #readRssi,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<int>.value(0),
        returnValueForMissingStub: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);
  @override
  _i3.Future<int> requestMtu(
    int? desiredMtu, {
    int? timeout = 15,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #requestMtu,
          [desiredMtu],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<int>.value(0),
        returnValueForMissingStub: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);
  @override
  _i3.Future<void> requestConnectionPriority(
          {required _i2.ConnectionPriority? connectionPriorityRequest}) =>
      (super.noSuchMethod(
        Invocation.method(
          #requestConnectionPriority,
          [],
          {#connectionPriorityRequest: connectionPriorityRequest},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> setPreferredPhy({
    required int? txPhy,
    required int? rxPhy,
    required _i2.PhyCoding? option,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setPreferredPhy,
          [],
          {
            #txPhy: txPhy,
            #rxPhy: rxPhy,
            #option: option,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> createBond({int? timeout = 90}) => (super.noSuchMethod(
        Invocation.method(
          #createBond,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> removeBond({int? timeout = 30}) => (super.noSuchMethod(
        Invocation.method(
          #removeBond,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> clearGattCache() => (super.noSuchMethod(
        Invocation.method(
          #clearGattCache,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Stream<_i2.BluetoothBondState> bondState() => (super.noSuchMethod(
        Invocation.method(
          #bondState,
          [],
        ),
        returnValue: _i3.Stream<_i2.BluetoothBondState>.empty(),
        returnValueForMissingStub: _i3.Stream<_i2.BluetoothBondState>.empty(),
      ) as _i3.Stream<_i2.BluetoothBondState>);
  @override
  _i3.Future<void> pair() => (super.noSuchMethod(
        Invocation.method(
          #pair,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [BluetoothService].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothService extends _i1.Mock implements _i2.BluetoothService {
  @override
  _i2.DeviceIdentifier get remoteId => (super.noSuchMethod(
        Invocation.getter(#remoteId),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
      ) as _i2.DeviceIdentifier);
  @override
  _i2.Guid get serviceUuid => (super.noSuchMethod(
        Invocation.getter(#serviceUuid),
        returnValue: _FakeGuid_1(
          this,
          Invocation.getter(#serviceUuid),
        ),
        returnValueForMissingStub: _FakeGuid_1(
          this,
          Invocation.getter(#serviceUuid),
        ),
      ) as _i2.Guid);
  @override
  bool get isPrimary => (super.noSuchMethod(
        Invocation.getter(#isPrimary),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  List<_i2.BluetoothCharacteristic> get characteristics => (super.noSuchMethod(
        Invocation.getter(#characteristics),
        returnValue: <_i2.BluetoothCharacteristic>[],
        returnValueForMissingStub: <_i2.BluetoothCharacteristic>[],
      ) as List<_i2.BluetoothCharacteristic>);
  @override
  List<_i2.BluetoothService> get includedServices => (super.noSuchMethod(
        Invocation.getter(#includedServices),
        returnValue: <_i2.BluetoothService>[],
        returnValueForMissingStub: <_i2.BluetoothService>[],
      ) as List<_i2.BluetoothService>);
  @override
  _i2.Guid get uuid => (super.noSuchMethod(
        Invocation.getter(#uuid),
        returnValue: _FakeGuid_1(
          this,
          Invocation.getter(#uuid),
        ),
        returnValueForMissingStub: _FakeGuid_1(
          this,
          Invocation.getter(#uuid),
        ),
      ) as _i2.Guid);
  @override
  _i2.DeviceIdentifier get deviceId => (super.noSuchMethod(
        Invocation.getter(#deviceId),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#deviceId),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#deviceId),
        ),
      ) as _i2.DeviceIdentifier);
}

/// A class which mocks [BluetoothCharacteristic].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothCharacteristic extends _i1.Mock implements _i2.BluetoothCharacteristic {
  @override
  _i2.DeviceIdentifier get remoteId => (super.noSuchMethod(
        Invocation.getter(#remoteId),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#remoteId),
        ),
      ) as _i2.DeviceIdentifier);
  @override
  _i2.Guid get serviceUuid => (super.noSuchMethod(
        Invocation.getter(#serviceUuid),
        returnValue: _FakeGuid_1(
          this,
          Invocation.getter(#serviceUuid),
        ),
        returnValueForMissingStub: _FakeGuid_1(
          this,
          Invocation.getter(#serviceUuid),
        ),
      ) as _i2.Guid);
  @override
  _i2.Guid get characteristicUuid => (super.noSuchMethod(
        Invocation.getter(#characteristicUuid),
        returnValue: _FakeGuid_1(
          this,
          Invocation.getter(#characteristicUuid),
        ),
        returnValueForMissingStub: _FakeGuid_1(
          this,
          Invocation.getter(#characteristicUuid),
        ),
      ) as _i2.Guid);
  @override
  _i2.CharacteristicProperties get properties => (super.noSuchMethod(
        Invocation.getter(#properties),
        returnValue: _FakeCharacteristicProperties_2(
          this,
          Invocation.getter(#properties),
        ),
        returnValueForMissingStub: _FakeCharacteristicProperties_2(
          this,
          Invocation.getter(#properties),
        ),
      ) as _i2.CharacteristicProperties);
  @override
  List<_i2.BluetoothDescriptor> get descriptors => (super.noSuchMethod(
        Invocation.getter(#descriptors),
        returnValue: <_i2.BluetoothDescriptor>[],
        returnValueForMissingStub: <_i2.BluetoothDescriptor>[],
      ) as List<_i2.BluetoothDescriptor>);
  @override
  List<int> get lastValue => (super.noSuchMethod(
        Invocation.getter(#lastValue),
        returnValue: <int>[],
        returnValueForMissingStub: <int>[],
      ) as List<int>);
  @override
  set lastValue(List<int>? _lastValue) => super.noSuchMethod(
        Invocation.setter(
          #lastValue,
          _lastValue,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i2.Guid get uuid => (super.noSuchMethod(
        Invocation.getter(#uuid),
        returnValue: _FakeGuid_1(
          this,
          Invocation.getter(#uuid),
        ),
        returnValueForMissingStub: _FakeGuid_1(
          this,
          Invocation.getter(#uuid),
        ),
      ) as _i2.Guid);
  @override
  _i3.Stream<List<int>> get lastValueStream => (super.noSuchMethod(
        Invocation.getter(#lastValueStream),
        returnValue: _i3.Stream<List<int>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<int>>.empty(),
      ) as _i3.Stream<List<int>>);
  @override
  _i3.Stream<List<int>> get onValueReceived => (super.noSuchMethod(
        Invocation.getter(#onValueReceived),
        returnValue: _i3.Stream<List<int>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<int>>.empty(),
      ) as _i3.Stream<List<int>>);
  @override
  bool get isNotifying => (super.noSuchMethod(
        Invocation.getter(#isNotifying),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  _i2.DeviceIdentifier get deviceId => (super.noSuchMethod(
        Invocation.getter(#deviceId),
        returnValue: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#deviceId),
        ),
        returnValueForMissingStub: _FakeDeviceIdentifier_0(
          this,
          Invocation.getter(#deviceId),
        ),
      ) as _i2.DeviceIdentifier);
  @override
  _i3.Stream<List<int>> get value => (super.noSuchMethod(
        Invocation.getter(#value),
        returnValue: _i3.Stream<List<int>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<int>>.empty(),
      ) as _i3.Stream<List<int>>);
  @override
  _i3.Stream<List<int>> get onValueChangedStream => (super.noSuchMethod(
        Invocation.getter(#onValueChangedStream),
        returnValue: _i3.Stream<List<int>>.empty(),
        returnValueForMissingStub: _i3.Stream<List<int>>.empty(),
      ) as _i3.Stream<List<int>>);
  @override
  _i3.Future<List<int>> read({int? timeout = 15}) => (super.noSuchMethod(
        Invocation.method(
          #read,
          [],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<List<int>>.value(<int>[]),
        returnValueForMissingStub: _i3.Future<List<int>>.value(<int>[]),
      ) as _i3.Future<List<int>>);
  @override
  _i3.Future<void> write(
    List<int>? value, {
    bool? withoutResponse = false,
    int? timeout = 15,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #write,
          [value],
          {
            #withoutResponse: withoutResponse,
            #timeout: timeout,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<bool> setNotifyValue(
    bool? notify, {
    int? timeout = 15,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setNotifyValue,
          [notify],
          {#timeout: timeout},
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
}
