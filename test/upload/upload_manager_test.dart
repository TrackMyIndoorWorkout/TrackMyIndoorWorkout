import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/upload_manager.dart';
import 'package:track_my_indoor_exercise/upload/upload_service.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class MockUploadService extends Mock implements UploadService {}

Activity createTestActivity({int id = 42}) {
  return Activity(
    id: id,
    deviceName: "Test Bike",
    deviceId: "test_dev",
    hrmId: "test_hrm",
    start: DateTime.now(),
    distance: 1000.0,
    elapsed: 100,
    movingTime: 100000,
    calories: 50,
    fourCC: schwinnICBikeFourCC,
    sport: ActivityType.ride,
    powerFactor: 1.0,
    calorieFactor: 1.0,
    hrCalorieFactor: 1.0,
    hrmCalorieFactor: 1.0,
    hrBasedCalories: false,
    timeZone: "UTC",
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(createTestActivity());
  });

  setUp(() {
    Get.reset();
  });

  test('UploadManager reports idle initially and handles successful upload', () async {
    final mockService = MockUploadService();
    when(() => mockService.login()).thenAnswer((_) async => true);
    when(() => mockService.upload(any(), any())).thenAnswer((_) async => 200);

    final manager = UploadManager(serviceResolver: (_) => mockService);

    final activity = createTestActivity();
    expect(manager.getStatus(activity.id, stravaChoice), equals(UploadStatus.idle));
    expect(manager.isUploading(activity.id), isFalse);

    final result = await manager.uploadActivity(
      activity,
      stravaChoice,
      calculateGps: false,
      showNotification: false,
    );

    expect(result, isTrue);
    expect(manager.getStatus(activity.id, stravaChoice), equals(UploadStatus.success));
    expect(manager.isUploading(activity.id), isFalse);
    verify(() => mockService.login()).called(1);
    verify(() => mockService.upload(activity, false)).called(1);
  });

  test('UploadManager handles login failure cleanly', () async {
    final mockService = MockUploadService();
    when(() => mockService.login()).thenAnswer((_) async => false);

    final manager = UploadManager(serviceResolver: (_) => mockService);
    final activity = createTestActivity();

    final result = await manager.uploadActivity(
      activity,
      suuntoChoice,
      calculateGps: false,
      showNotification: false,
    );

    expect(result, isFalse);
    expect(manager.getStatus(activity.id, suuntoChoice), equals(UploadStatus.failed));
    expect(manager.isUploading(activity.id), isFalse);
    verify(() => mockService.login()).called(1);
    verifyNever(() => mockService.upload(any(), any()));
  });

  test('UploadManager handles upload HTTP error status code', () async {
    final mockService = MockUploadService();
    when(() => mockService.login()).thenAnswer((_) async => true);
    when(() => mockService.upload(any(), any())).thenAnswer((_) async => 500);

    final manager = UploadManager(serviceResolver: (_) => mockService);
    final activity = createTestActivity();

    final result = await manager.uploadActivity(
      activity,
      trainingPeaksChoice,
      calculateGps: false,
      showNotification: false,
    );

    expect(result, isFalse);
    expect(manager.getStatus(activity.id, trainingPeaksChoice), equals(UploadStatus.failed));
    expect(manager.isUploading(activity.id), isFalse);
  });

  test('UploadManager handles network exceptions gracefully without crashing', () async {
    final mockService = MockUploadService();
    when(() => mockService.login()).thenAnswer((_) async => true);
    when(() => mockService.upload(any(), any()))
        .thenThrow(const SocketException("Connection timed out"));

    final manager = UploadManager(serviceResolver: (_) => mockService);
    final activity = createTestActivity();

    final result = await manager.uploadActivity(
      activity,
      underArmourChoice,
      calculateGps: false,
      showNotification: false,
    );

    expect(result, isFalse);
    expect(manager.getStatus(activity.id, underArmourChoice), equals(UploadStatus.failed));
    expect(manager.isUploading(activity.id), isFalse);
  });

  test(
    'UploadManager prevents duplicate concurrent uploads for the same activity and portal',
    () async {
      final completer = Completer<int>();
      final mockService = MockUploadService();
      when(() => mockService.login()).thenAnswer((_) async => true);
      when(() => mockService.upload(any(), any())).thenAnswer((_) => completer.future);

      final manager = UploadManager(serviceResolver: (_) => mockService);
      final activity = createTestActivity();

      // Start first upload (hangs waiting for completer)
      final firstFuture = manager.uploadActivity(
        activity,
        stravaChoice,
        calculateGps: false,
        showNotification: false,
      );

      expect(manager.isUploading(activity.id, stravaChoice), isTrue);
      expect(manager.isUploading(activity.id), isTrue);
      expect(manager.getStatus(activity.id, stravaChoice), equals(UploadStatus.uploading));

      // Try starting duplicate second upload
      final secondResult = await manager.uploadActivity(
        activity,
        stravaChoice,
        calculateGps: false,
        showNotification: false,
      );
      expect(secondResult, isFalse); // Rejected because one is already in-flight

      // Complete the first upload
      completer.complete(200);
      final firstResult = await firstFuture;

      expect(firstResult, isTrue);
      expect(manager.getStatus(activity.id, stravaChoice), equals(UploadStatus.success));
      expect(manager.isUploading(activity.id), isFalse);
      verify(() => mockService.login()).called(1); // Only called once
      verify(() => mockService.upload(any(), any())).called(1); // Only called once
    },
  );
}
