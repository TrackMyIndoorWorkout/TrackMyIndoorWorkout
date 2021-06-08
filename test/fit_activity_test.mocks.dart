// Mocks generated by Mockito 5.0.9 from annotations
// in track_my_indoor_exercise/test/fit_activity_test.dart.
// Do not manually edit this file.

import 'package:mockito/mockito.dart' as _i1;
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart' as _i2;
import 'package:track_my_indoor_exercise/export/export_model.dart' as _i3;
import 'package:track_my_indoor_exercise/export/export_record.dart' as _i4;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

class _FakeDateTime extends _i1.Fake implements DateTime {}

class _FakeDeviceDescriptor extends _i1.Fake implements _i2.DeviceDescriptor {}

/// A class which mocks [ExportModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockExportModel extends _i1.Mock implements _i3.ExportModel {
  MockExportModel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get sport => (super.noSuchMethod(Invocation.getter(#sport), returnValue: '') as String);
  @override
  set sport(String? _sport) =>
      super.noSuchMethod(Invocation.setter(#sport, _sport), returnValueForMissingStub: null);
  @override
  double get totalDistance =>
      (super.noSuchMethod(Invocation.getter(#totalDistance), returnValue: 0.0) as double);
  @override
  set totalDistance(double? _totalDistance) =>
      super.noSuchMethod(Invocation.setter(#totalDistance, _totalDistance),
          returnValueForMissingStub: null);
  @override
  double get totalTime =>
      (super.noSuchMethod(Invocation.getter(#totalTime), returnValue: 0.0) as double);
  @override
  set totalTime(double? _totalTime) => super
      .noSuchMethod(Invocation.setter(#totalTime, _totalTime), returnValueForMissingStub: null);
  @override
  double get averageSpeed =>
      (super.noSuchMethod(Invocation.getter(#averageSpeed), returnValue: 0.0) as double);
  @override
  set averageSpeed(double? _averageSpeed) =>
      super.noSuchMethod(Invocation.setter(#averageSpeed, _averageSpeed),
          returnValueForMissingStub: null);
  @override
  double get maximumSpeed =>
      (super.noSuchMethod(Invocation.getter(#maximumSpeed), returnValue: 0.0) as double);
  @override
  set maximumSpeed(double? _maximumSpeed) =>
      super.noSuchMethod(Invocation.setter(#maximumSpeed, _maximumSpeed),
          returnValueForMissingStub: null);
  @override
  int get calories => (super.noSuchMethod(Invocation.getter(#calories), returnValue: 0) as int);
  @override
  set calories(int? _calories) =>
      super.noSuchMethod(Invocation.setter(#calories, _calories), returnValueForMissingStub: null);
  @override
  int get averageHeartRate =>
      (super.noSuchMethod(Invocation.getter(#averageHeartRate), returnValue: 0) as int);
  @override
  set averageHeartRate(int? _averageHeartRate) =>
      super.noSuchMethod(Invocation.setter(#averageHeartRate, _averageHeartRate),
          returnValueForMissingStub: null);
  @override
  int get maximumHeartRate =>
      (super.noSuchMethod(Invocation.getter(#maximumHeartRate), returnValue: 0) as int);
  @override
  set maximumHeartRate(int? _maximumHeartRate) =>
      super.noSuchMethod(Invocation.setter(#maximumHeartRate, _maximumHeartRate),
          returnValueForMissingStub: null);
  @override
  int get averageCadence =>
      (super.noSuchMethod(Invocation.getter(#averageCadence), returnValue: 0) as int);
  @override
  set averageCadence(int? _averageCadence) =>
      super.noSuchMethod(Invocation.setter(#averageCadence, _averageCadence),
          returnValueForMissingStub: null);
  @override
  int get maximumCadence =>
      (super.noSuchMethod(Invocation.getter(#maximumCadence), returnValue: 0) as int);
  @override
  set maximumCadence(int? _maximumCadence) =>
      super.noSuchMethod(Invocation.setter(#maximumCadence, _maximumCadence),
          returnValueForMissingStub: null);
  @override
  double get averagePower =>
      (super.noSuchMethod(Invocation.getter(#averagePower), returnValue: 0.0) as double);
  @override
  set averagePower(double? _averagePower) =>
      super.noSuchMethod(Invocation.setter(#averagePower, _averagePower),
          returnValueForMissingStub: null);
  @override
  double get maximumPower =>
      (super.noSuchMethod(Invocation.getter(#maximumPower), returnValue: 0.0) as double);
  @override
  set maximumPower(double? _maximumPower) =>
      super.noSuchMethod(Invocation.setter(#maximumPower, _maximumPower),
          returnValueForMissingStub: null);
  @override
  DateTime get dateActivity =>
      (super.noSuchMethod(Invocation.getter(#dateActivity), returnValue: _FakeDateTime())
          as DateTime);
  @override
  set dateActivity(DateTime? _dateActivity) =>
      super.noSuchMethod(Invocation.setter(#dateActivity, _dateActivity),
          returnValueForMissingStub: null);
  @override
  List<_i4.ExportRecord> get records =>
      (super.noSuchMethod(Invocation.getter(#records), returnValue: <_i4.ExportRecord>[])
          as List<_i4.ExportRecord>);
  @override
  set records(List<_i4.ExportRecord>? _records) =>
      super.noSuchMethod(Invocation.setter(#records, _records), returnValueForMissingStub: null);
  @override
  _i2.DeviceDescriptor get descriptor =>
      (super.noSuchMethod(Invocation.getter(#descriptor), returnValue: _FakeDeviceDescriptor())
          as _i2.DeviceDescriptor);
  @override
  set descriptor(_i2.DeviceDescriptor? _descriptor) => super
      .noSuchMethod(Invocation.setter(#descriptor, _descriptor), returnValueForMissingStub: null);
  @override
  String get deviceId =>
      (super.noSuchMethod(Invocation.getter(#deviceId), returnValue: '') as String);
  @override
  set deviceId(String? _deviceId) =>
      super.noSuchMethod(Invocation.setter(#deviceId, _deviceId), returnValueForMissingStub: null);
  @override
  int get versionMajor =>
      (super.noSuchMethod(Invocation.getter(#versionMajor), returnValue: 0) as int);
  @override
  set versionMajor(int? _versionMajor) =>
      super.noSuchMethod(Invocation.setter(#versionMajor, _versionMajor),
          returnValueForMissingStub: null);
  @override
  int get versionMinor =>
      (super.noSuchMethod(Invocation.getter(#versionMinor), returnValue: 0) as int);
  @override
  set versionMinor(int? _versionMinor) =>
      super.noSuchMethod(Invocation.setter(#versionMinor, _versionMinor),
          returnValueForMissingStub: null);
  @override
  int get buildMajor => (super.noSuchMethod(Invocation.getter(#buildMajor), returnValue: 0) as int);
  @override
  set buildMajor(int? _buildMajor) => super
      .noSuchMethod(Invocation.setter(#buildMajor, _buildMajor), returnValueForMissingStub: null);
  @override
  int get buildMinor => (super.noSuchMethod(Invocation.getter(#buildMinor), returnValue: 0) as int);
  @override
  set buildMinor(int? _buildMinor) => super
      .noSuchMethod(Invocation.setter(#buildMinor, _buildMinor), returnValueForMissingStub: null);
  @override
  String get author => (super.noSuchMethod(Invocation.getter(#author), returnValue: '') as String);
  @override
  set author(String? _author) =>
      super.noSuchMethod(Invocation.setter(#author, _author), returnValueForMissingStub: null);
  @override
  String get name => (super.noSuchMethod(Invocation.getter(#name), returnValue: '') as String);
  @override
  set name(String? _name) =>
      super.noSuchMethod(Invocation.setter(#name, _name), returnValueForMissingStub: null);
  @override
  int get swVersionMajor =>
      (super.noSuchMethod(Invocation.getter(#swVersionMajor), returnValue: 0) as int);
  @override
  set swVersionMajor(int? _swVersionMajor) =>
      super.noSuchMethod(Invocation.setter(#swVersionMajor, _swVersionMajor),
          returnValueForMissingStub: null);
  @override
  int get swVersionMinor =>
      (super.noSuchMethod(Invocation.getter(#swVersionMinor), returnValue: 0) as int);
  @override
  set swVersionMinor(int? _swVersionMinor) =>
      super.noSuchMethod(Invocation.setter(#swVersionMinor, _swVersionMinor),
          returnValueForMissingStub: null);
  @override
  int get buildVersionMajor =>
      (super.noSuchMethod(Invocation.getter(#buildVersionMajor), returnValue: 0) as int);
  @override
  set buildVersionMajor(int? _buildVersionMajor) =>
      super.noSuchMethod(Invocation.setter(#buildVersionMajor, _buildVersionMajor),
          returnValueForMissingStub: null);
  @override
  int get buildVersionMinor =>
      (super.noSuchMethod(Invocation.getter(#buildVersionMinor), returnValue: 0) as int);
  @override
  set buildVersionMinor(int? _buildVersionMinor) =>
      super.noSuchMethod(Invocation.setter(#buildVersionMinor, _buildVersionMinor),
          returnValueForMissingStub: null);
  @override
  String get langID => (super.noSuchMethod(Invocation.getter(#langID), returnValue: '') as String);
  @override
  set langID(String? _langID) =>
      super.noSuchMethod(Invocation.setter(#langID, _langID), returnValueForMissingStub: null);
  @override
  String get partNumber =>
      (super.noSuchMethod(Invocation.getter(#partNumber), returnValue: '') as String);
  @override
  set partNumber(String? _partNumber) => super
      .noSuchMethod(Invocation.setter(#partNumber, _partNumber), returnValueForMissingStub: null);
}
