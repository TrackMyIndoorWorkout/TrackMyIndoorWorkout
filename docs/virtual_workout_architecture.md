# Virtual Workout Architecture & Implementation Plan (#564)

## Context & Objectives

Issue **#564 ("Allow upload and save of virtual workout (FIT)")** addresses the need for indoor workouts recorded by Track My Indoor Workout to be saved or uploaded as **Virtual Activities** (`VirtualRide`, `VirtualRun`, `VirtualRow`), rather than regular outdoor workouts.

### Motivation & Problems Solved
1. **Strava Equipment & Leaderboard Contamination**:
   - Currently, uploads to Strava default to `Ride` or `Run`. Strava automatically binds the user's default outdoor bike/shoes, tracks mileage against outdoor gear, and (if GPS track simulation is enabled) can trigger outdoor segment matching.
   - Strava does not allow athletes to manually switch an activity to `VirtualRide` or `VirtualRun` via their website or app after upload to protect leaderboards.
2. **FIT Sub-Sport Misconfiguration**:
   - In `fit_sport.dart`, `VirtualRide` was mapped to `sub_sport: 6` (*indoor_cycling*) and `VirtualRun` to `sub_sport: 1` (*treadmill*).
   - In the official Garmin FIT SDK, simulated courses and virtual trainer workouts use **`sub_sport: 58` (`virtual_activity`)**. Setting `sub_sport: 58` instructs platforms (Strava, Intervals.icu, Garmin Connect) to treat GPS coordinates as a virtual course (preserving map display without outdoor leaderboard conflicts or timezone overriding).
3. **Strava v3 API Compliance**:
   - Strava deprecated `activity_type` in favor of `sport_type` (which explicitly supports `VirtualRide`, `VirtualRun`, and `VirtualRow`).
   - The upload endpoint `POST /api/v3/uploads` accepts `sport_type` as a multipart form field.

---

## 1. Core Architectural Rule: Canonical Internal Sport

Across `track_my_indoor_exercise`, over **50 decision points** check `sport == ActivityType.ride` or `sport != ActivityType.ride` (in `record.dart`, `display.dart`, `measurement_counter.dart`, `activity_detail_graphs.dart`, `sport_leaderboard.dart`, `workout_summary.dart`, `sport_spec.dart`, etc.).

**Architectural Invariant**:
- **`Activity.sport` remains strictly canonical** (`Ride`, `Run`, `Rowing`, etc.) in the database, BLE communication, recording screen, leaderboard, and charts.
- **Virtual Workout is strictly an export & upload boundary projection** (`bool virtualWorkout`).
- Canonical sports are mapped to virtual counterparts only at file generation or upload dispatch time.

### Supported Virtual Sports Mapping

Only sports that have a genuine virtual counterpart in the FIT SDK and upload platforms are supported:

| Canonical Sport | Virtual Counterpart | FIT `sport` ID | FIT `sub_sport` ID | Strava `sport_type` | UnderArmour ID |
| :--- | :--- | :---: | :---: | :--- | :---: |
| `ActivityType.ride` | `ActivityType.virtualRide` | `2` (cycling) | `58` (virtual_activity) | `VirtualRide` | `19` |
| `ActivityType.run` | `ActivityType.virtualRun` | `1` (running) | `58` (virtual_activity) | `VirtualRun` | `25` |
| `ActivityType.rowing` | `ActivityType.virtualRow` | `15` (rowing) | `58` (virtual_activity) | `VirtualRow` | `99` |

All other sports (`Kayaking`, `Canoeing`, `Swim`, `Elliptical`, `NordicSki`, `StairStepper`, `RockClimbing`, `Workout`) have **`hasVirtualCounterpart == false`**. They remain strictly non-virtual across all formats and portals without prompting.

---

## 2. Preference & User Experience (UX) Design

### A. Global Preference in `DataPreferencesScreen`
Located in `lib/ui/preferences/data.dart` under the **Workout** section (alongside `calculateGps` and `stationaryWorkout`):
- **Preference Key**: `virtual_workout` (`virtualWorkoutTag`)
- **Default**: `false` (Standard non-virtual, preserving continuity for existing users)
- **Title**: `Virtual Workout`
- **Subtitle**: `Upload and export supported sports (Cycling, Running, Rowing) as virtual workouts (VirtualRide, VirtualRun, VirtualRow).`

### B. Unattended Workflows (Instant Upload, Instant Export, Background Retry Queue)
- **Zero modal prompts**: Automatic/unattended workflows strictly respect the global setting (`virtualWorkoutTag`).
- If `virtual_workout` is enabled in settings and the sport is supported, instant upload and instant export write virtual activities automatically.

### C. Manual Export & Upload Pickers (Inline Overrides Without Modal Dialog Stacking)
Instead of stacking extra modal dialogs on top of bottom sheets:
1. **`UploadPortalPickerBottomSheet`**:
   - When `hasVirtualCounterpart(activity.sport)` is true, an inline `SwitchListTile` is rendered above the portal list:
     - Title: *"Virtual Workout (VirtualRide)"* (dynamically showing the target virtual sport name).
     - Initialized to the user's global `virtualWorkoutTag` preference.
     - Flipping the switch allows immediate, one-off toggling for that upload session without navigating away.
2. **`ExportFormatPickerBottomSheet`**:
   - When `hasVirtualCounterpart(activity.sport)` is true, an inline `SwitchListTile` is rendered:
     - Title: *"Virtual Workout (VirtualRide)"* (effective for FIT export).
     - Initialized to the user's global `virtualWorkoutTag` preference.

---

## 3. Platform & Target Behavior

1. **Direct FIT Export & Instant Export**:
   - If `virtualWorkout` is active, writes `sub_sport: 58` (`virtual_activity`) in `FitSession`, `FitLap`, and `FitSport`.
2. **Strava**:
   - Form field `sport_type: "VirtualRide"` / `"VirtualRun"` / `"VirtualRow"`.
   - Encodes FIT with `sub_sport: 58`.
   - If `calculateGps == true`, `trainer = 'false'` to ensure Strava renders the simulated track map.
3. **Suunto (Restrictive)**:
   - Suunto's API enforces strict standard FIT files. `ExportTarget.suunto` automatically strips `sub_sport` and writes only canonical primary sport IDs, ensuring Suunto uploads never fail.
4. **UnderArmour / MapMyFitness**:
   - Uses `underArmourSport[virtualSport]` (e.g. `19` for VirtualRide, `25` for VirtualRun, `99` for VirtualRow).
5. **Dreeve / Custom Endpoint**:
   - Standard FIT with `ExportTarget.regular`, receiving `sub_sport: 58`.
6. **TrainingPeaks, TCX, CSV**:
   - Standard schemas without virtual sport support; safely unaffected.
7. **Offline Retry Queue (`BackgroundUploadQueue`)**:
   - `BackgroundUploadItem` stores `bool virtualWorkout` so offline retried uploads preserve the user's choice.
