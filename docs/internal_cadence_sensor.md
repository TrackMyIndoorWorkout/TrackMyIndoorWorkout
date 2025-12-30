# Internal Motion Sensor (RPM/SPM)

## Overview
This feature allows `TrackMyIndoorWorkout` to use the device's built-in accelerometer to estimate cadence (RPM for cycling, SPM for running/rowing) without requiring external sensors. This is particularly useful for casual workouts or when external sensors are unavailable.

## Features
*   **Multi-Sport Support:**
    *   **Cycling:** Estimates RPM (Revolutions Per Minute).
    *   **Running:** Estimates SPM (Steps Per Minute).
    *   **Rowing:** Estimates SPM (Strokes Per Minute).
*   **Robust Signal Processing:** Uses autocorrelation to analyze the periodicity of accelerometer magnitude, filtering out noise and non-rhythmic motion.
*   **Seamless Integration:** Treated as a standard sensor within the app, merging data into workout records automatically.

## Architecture

### 1. Signal Processing (`CadenceProcessor`)
Located in `lib/utils/cadence_processing.dart`.
*   **Input:** 3-axis accelerometer data (x, y, z).
*   **Preprocessing:** Calculates magnitude (`sqrt(x^2 + y^2 + z^2)`) and removes DC offset (gravity).
*   **Analysis:** Performs autocorrelation on a sliding window (default 4 seconds at 50Hz) to find the dominant periodic component.
*   **Constraints:** Filters results to a realistic cadence range (30-220 RPM).

### 2. Device Integration (`DeviceInternalMotion`)
Located in `lib/devices/gadgets/cadence_monitor_internal.dart`.
*   Extends `ComplexSensor` to mimic the lifecycle of external Bluetooth devices (Connect, Discover, Pump Data).
*   Subscribes to `accelerometerEventStream()` from the `sensors_plus` package.
*   Converts raw sensor events into `RecordWithSport` objects containing the estimated cadence.

### 3. User Interface
*   **Pairing:** A dedicated bottom sheet (`CadenceMonitorPairingBottomSheet`) allows users to selecting the target sport mode.
*   **Recording:** The `RecordingFabMenu` provides quick access to enable/disable the sensor.

## Usage

1.  **Start a Workout:** Go to the Recording screen.
2.  **Open Menu:** Tap the `+` Floating Action Button (FAB).
3.  **Select Sensor:** Tap the **Cadence Sensor** icon (Sensors icon).
4.  **Choose Mode:** Select the appropriate sport (Cycling, Running, or Rowing).
5.  **Placement:** Place the phone/device securely on your person (e.g., pocket, armband) or the equipment (if applicable) where it can detect the rhythmic motion.
    *   *Note: For cycling, a thigh pocket or hip mount is recommended.*
    *   *Note: For rowing, placing on the moving seat or handle (if safe) works best.*
6.  **Verify:** Cadence data should appear in the "Cadence" or "SPM" field on the recording screen.
