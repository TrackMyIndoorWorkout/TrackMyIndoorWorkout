import 'dart:math';

/// A utility to process raw accelerometer/gyroscope data and estimate cadence (RPM/SPM).
class CadenceProcessor {
  // Sampling rate assumption: ~50Hz is typical for UI/Game updates in Flutter sensors,
  // but it varies. We should track time deltas if possible, or assume a fixed rate if we rely on event streams.
  // Actually, autocorrelation works on indices (lags). If sampling is irregular, we might need interpolation (Lomb-Scargle or similar).
  // However, for the first iteration (MVP), simple autocorrelation on the buffer is often sufficient if the effective rate is stable enough.
  // Or we can just calculate frequency = (sampling_rate) / (lag_in_samples).

  // Buffer size: 3 seconds @ 50Hz = 150 samples.
  // 3 seconds allows detection of 20 SPM (0.33Hz) -> period 3s.
  // 300 SPM (5Hz) -> period 0.2s.
  final int _windowSize;
  final List<double> _buffer = [];
  final List<int> _timeStamps = [];

  CadenceProcessor({int windowSize = 256}) : _windowSize = windowSize;

  /// Adds a 3D vector (x,y,z) and timestamp (ms) to the buffer.
  /// Returns the estimated cadence (RPM) if a valid estimate is found, or null.
  /// Note: The caller should decide the polling rate (e.g. call estimate() every 1 second).
  void addData(double x, double y, double z, int timestampMs) {
    // Calculate magnitude to be orientation independent
    final magnitude = sqrt(x * x + y * y + z * z);

    _buffer.add(magnitude);
    _timeStamps.add(timestampMs);

    // Keep buffer strictly at size
    if (_buffer.length > _windowSize) {
      _buffer.removeAt(0);
      _timeStamps.removeAt(0);
    }
  }

  /// Calculates the estimated cadence in RPM (Revolutions Per Minute).
  /// Returns 0 if not enough data or no periodicity found.
  double? estimateCadence() {
    if (_buffer.length < _windowSize) {
      return null;
    }

    // 1. Detrend (Remove DC component - gravity)
    final mean = _buffer.reduce((a, b) => a + b) / _buffer.length;
    final detrended = _buffer.map((v) => v - mean).toList();

    // 2. Autocorrelation
    // simple O(N^2) implementation is fine for N=256
    final n = detrended.length;
    final List<double> acf = List.filled(n, 0.0);

    for (int lag = 0; lag < n; lag++) {
      double sum = 0.0;
      for (int i = 0; i < n - lag; i++) {
        sum += detrended[i] * detrended[i + lag];
      }
      acf[lag] = sum;
    }

    // 3. Peak Detection in ACF
    // We are looking for the *first* major peak after the initial descent.
    // The lag 0 is the maximum (energy).
    // We expect a descent, then a rise.

    // Calculate effective sampling rate
    final durationMs = _timeStamps.last - _timeStamps.first;
    if (durationMs == 0) return 0.0;
    final fs = (_buffer.length - 1) * 1000.0 / durationMs; // Hz

    // Min RPM: 20 -> Max Lag: 60/20 = 3s. But our window is ~5s? 256/50 = 5s.
    // Max RPM: 200 -> Min Lag: 60/200 = 0.3s.

    // Convert RPM limits to Lag indices
    // Lag = Fs * 60 / RPM
    final minRpm = 20.0;
    final maxRpm = 220.0;

    final minLag = (fs * 60 / maxRpm).floor();
    final maxLag = (fs * 60 / minRpm).floor();

    int bestLag = -1;
    double maxPeak = -double.infinity;

    // Search for peak in valid lag range
    // We must ensure we restrict search to indices within buffer size
    final searchEnd = min(maxLag, n - 1);

    if (minLag >= searchEnd) return 0.0;

    // Simple robust peak detection: Look for local maxima
    for (int i = minLag; i < searchEnd - 1; i++) {
      if (acf[i] > acf[i - 1] && acf[i] > acf[i + 1]) {
        if (acf[i] > maxPeak) {
          maxPeak = acf[i];
          bestLag = i;
        }
      }
    }

    if (bestLag > 0) {
      // Estimate Frequency
      // Period = bestLag / Fs
      // Frequency = Fs / bestLag
      // RPM = Frequency * 60
      final rpm = (fs / bestLag) * 60.0;
      return rpm;
    }

    return 0.0;
  }
}
