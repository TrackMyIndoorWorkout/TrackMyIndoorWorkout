import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/cadence_processing.dart';

void main() {
  group('CadenceProcessor Tests', () {
    late CadenceProcessor processor;

    setUp(() {
      processor = CadenceProcessor(windowSize: 200);
    });

    test('Initial state returns null', () {
      expect(processor.estimateCadence(), isNull);
    });

    test('Sine wave at 60 RPM (1 Hz) should be detected', () {
      // 50Hz sampling rate
      final fs = 50.0;
      final freq = 1.0; // 1 Hz = 60 RPM

      // Feed 4 seconds of data (200 samples)
      for (int i = 0; i < 200; i++) {
        final t = i / fs;
        // Simulate gravity + motion
        double x = 0;
        double y = 9.8 + sin(2 * pi * freq * t);
        double z = 0;

        processor.addData(x, y, z, (t * 1000).toInt());
      }

      final rpm = processor.estimateCadence();
      // Expect around 60 (within margin)
      expect(rpm, closeTo(60, 5));
    });

    test('Sine wave at 180 RPM (3 Hz) should be detected', () {
      // 50Hz sampling rate
      final fs = 50.0;
      final freq = 3.0; // 3 Hz = 180 RPM

      for (int i = 0; i < 250; i++) {
        final t = i / fs;
        double x = sin(2 * pi * freq * t);
        double y = 9.8;
        double z = 0;

        processor.addData(x, y, z, (t * 1000).toInt());
      }

      final rpm = processor.estimateCadence();
      expect(rpm, closeTo(180, 5));
    });

    test('Consistent Static Data should return 0', () {
      for (int i = 0; i < 200; i++) {
        processor.addData(0.1, 9.8, 0.2, i * 20);
      }

      final rpm = processor.estimateCadence();
      expect(rpm, 0.0);
    });
  });
}
