# Internal Heart Rate Sensor Support (FAW)

## Overview
This feature enables **Track My Indoor Workout** to read heart rate data directly from the internal sensors of Full Android Watches (FAW), such as those running Android 11. This allows users to track their heart rate without needing an external Bluetooth strap.

## Implementation Details

### Architecture: Polymorphic Adapter
The implementation uses an **Adapter Pattern** to integrate the non-Bluetooth internal sensor into the application's existing Bluetooth-centric device architecture.

*   **`DeviceInternalHeartRate`**: A class that extends `HeartRateMonitor` (and by extension `DeviceBase`).
*   **Dummy Bluetooth Identity**: The class initializes with a dummy `BluetoothDevice` identifier (`"INTERNAL_HRM"`). This satisfies the type requirements of the `DeviceBase` class without requiring a real BLE connection.
*   **Bypassing BLE**: Standard BLE lifecycle methods (`connect`, `discover`, `attach`, `pumpData`) are overridden to interface with the local Android `SensorManager` instead of GATT characteristics.

### Dependencies
*   **`heart_rate_flutter`**: used to access `Sensor.TYPE_HEART_RATE` on Android.
*   **`permission_handler`**: Used to request the `BODY_SENSORS` runtime permission.

## SDK & Hardware Support

### Requirements
*   **Minimum Android SDK**: API Level 16 (Android 4.1).
*   **Hardware**: Requires a device with a built-in Heart Rate Sensor (`Sensor.TYPE_HEART_RATE`).

### Android 11 Compatibility
This feature is fully compatible with Android 11 (API Level 30).
*   **Permissions**: Android 10+ requires the `android.permission.BODY_SENSORS` permission. The app handles the runtime request for this permission when the user selects the internal sensor.

## Usage
1.  Navigate to the **Heart Rate Monitor Pairing** screen.
2.  Tap the **"Use Watch's Sensor"** option.
3.  Grant the **Body Sensors** permission when prompted.
4.  The app will connect to the internal sensor and begin streaming heart rate data.

### Conditional Visibility
The **"Use Watch's Sensor"** option is displayed dynamically:
*   **Visible on FAW**: On devices that declare the `android.hardware.sensor.heartrate` system feature.
*   **Hidden on Phones**: On devices without this sensor, the option is automatically hidden to prevent confusion.
