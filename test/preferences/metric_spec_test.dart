import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_my_indoor_exercise/preferences/metric_spec.dart';
import 'package:track_my_indoor_exercise/preferences/palette_spec.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'dart:async';

class FakePrefService implements BasePrefService {
  final Map<String, dynamic> _data = {};

  @override
  FutureOr<bool> set<T>(String key, T value) {
    _data[key] = value;
    return true;
  }

  @override
  T? get<T>(String key) => _data[key] as T?;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "FakePrefService";
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakePrefService mockPrefService;

  setUp(() {
    mockPrefService = FakePrefService();
    Get.put<BasePrefService>(mockPrefService);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  MetricSpec createTestSpec() {
    return MetricSpec(
      metric: 'power',
      title: 'Power',
      unit: 'W',
      thresholdTagPostfix: 'threshold',
      oldThresholdDefaultInts: {'Ride': 200, 'Run': 200, 'Kayak': 200, 'Swim': 200},
      thresholdDefaultInts: {'Ride': 200, 'Run': 200, 'Kayak': 200, 'Swim': 200},
      zonesTagPostfix: 'zones',
      oldZoneDefaultInts: [50, 75, 90, 105, 120],
      zonesDefaultInts: {
        'Ride': [50, 75, 90, 105, 120],
        'Run': [50, 75, 90, 105, 120],
        'Kayak': [50, 75, 90, 105, 120],
        'Swim': [50, 75, 90, 105, 120],
      },
      indexDisplayDefault: true,
      coloringByZoneDefault: true,
      icon: const IconData(0xf123, fontFamily: 'MaterialIcons'),
    );
  }

  PaletteSpec createTestPalette() {
    final p = PaletteSpec();
    p.lightBgPalette.forEach((k, v) => v.addAll(PaletteSpec.lightBgPaletteDefaults[k]!));
    p.darkBgPalette.forEach((k, v) => v.addAll(PaletteSpec.darkBgPaletteDefaults[k]!));
    return p;
  }

  group('MetricSpec.calculateBounds NaN/Infinity Safety Tests', () {
    // Test for: if (threshold < 0.1) { plotBands.clear(); return; }
    test('calculateBounds clears plotBands when threshold is less than 0.1', () {
      final spec = createTestSpec();
      spec.threshold = 0.05; // Less than 0.1
      spec.zoneBounds = [10.0, 20.0, 30.0];
      final palette = createTestPalette();

      spec.calculateBounds(0.0, 100.0, true, palette);

      expect(spec.plotBands, isEmpty, reason: 'plotBands should be empty when threshold < 0.1');
    });

    // Test for: if (minVal.isNaN || minVal.isInfinite) { minVal = 0; }
    test('calculateBounds sanitizes NaN minVal to 0', () {
      final spec = createTestSpec();
      spec.threshold = 200.0;
      spec.zoneBounds = [100.0, 150.0, 200.0];
      final palette = createTestPalette();

      // Should not throw and should produce valid plotBands
      spec.calculateBounds(double.nan, 300.0, true, palette);

      // Verify no NaN values in plotBands
      for (var band in spec.plotBands) {
        if (band.start is double) {
          expect((band.start as double).isNaN, isFalse, reason: 'plotBand.start should not be NaN');
        }
        if (band.end is double) {
          expect((band.end as double).isNaN, isFalse, reason: 'plotBand.end should not be NaN');
        }
      }
    });

    // Test for: if (maxVal.isNaN || maxVal.isInfinite) { maxVal = 0; }
    test('calculateBounds sanitizes Infinite maxVal', () {
      final spec = createTestSpec();
      spec.threshold = 200.0;
      spec.zoneBounds = [100.0, 150.0, 200.0];
      final palette = createTestPalette();

      // With infinite maxVal sanitized to 0, and minVal=0, we have maxVal <= minVal + eps
      // This should trigger the zero-range protection and clear plotBands
      spec.calculateBounds(0.0, double.infinity, true, palette);

      expect(
        spec.plotBands,
        isEmpty,
        reason:
            'plotBands should be empty when maxVal is Infinite (sanitized to 0, causing zero range)',
      );
    });

    // Test for: if (maxVal <= minVal + eps) { plotBands.clear(); return; }
    test('calculateBounds clears plotBands when range is zero (maxVal == minVal)', () {
      final spec = createTestSpec();
      spec.threshold = 200.0;
      spec.zoneBounds = [100.0, 150.0, 200.0];
      final palette = createTestPalette();

      spec.calculateBounds(100.0, 100.0, true, palette);

      expect(
        spec.plotBands,
        isEmpty,
        reason: 'plotBands should be empty when maxVal == minVal (zero range)',
      );
    });

    test(
      'calculateBounds clears plotBands when range is effectively zero (maxVal <= minVal + eps)',
      () {
        final spec = createTestSpec();
        spec.threshold = 200.0;
        spec.zoneBounds = [100.0, 150.0, 200.0];
        final palette = createTestPalette();

        // eps is 1e-6, so adding half of it should still trigger the guard
        spec.calculateBounds(100.0, 100.0 + (eps / 2), true, palette);

        expect(
          spec.plotBands,
          isEmpty,
          reason: 'plotBands should be empty when maxVal <= minVal + eps',
        );
      },
    );

    // Test for: Final safety check on zoneLower/zoneUpper
    test('calculateBounds generates valid plotBands with valid inputs', () {
      final spec = createTestSpec();
      spec.threshold = 200.0;
      spec.zoneBounds = [100.0, 150.0, 200.0];
      final palette = createTestPalette();

      spec.calculateBounds(0.0, 300.0, true, palette);

      expect(spec.plotBands, isNotEmpty, reason: 'plotBands should be generated with valid inputs');

      // Verify all plotBand values are finite
      for (var band in spec.plotBands) {
        if (band.start is double) {
          expect(
            (band.start as double).isFinite,
            isTrue,
            reason: 'plotBand.start should be finite',
          );
        }
        if (band.end is double) {
          expect((band.end as double).isFinite, isTrue, reason: 'plotBand.end should be finite');
        }
      }
    });

    test('calculateBounds handles both minVal and maxVal being NaN', () {
      final spec = createTestSpec();
      spec.threshold = 200.0;
      spec.zoneBounds = [100.0, 150.0, 200.0];
      final palette = createTestPalette();

      // Both NaN -> both become 0 -> maxVal (0) <= minVal (0) + eps -> clear
      spec.calculateBounds(double.nan, double.nan, true, palette);

      expect(
        spec.plotBands,
        isEmpty,
        reason: 'plotBands should be empty when both minVal and maxVal are NaN',
      );
    });
  });
}
