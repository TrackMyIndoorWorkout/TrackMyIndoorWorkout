# Reactive State Management & Stream Architecture Roadmap

## Context & Objectives

This document formalizes the architectural design and phased migration plan to eliminate the `setState` anti-pattern, resolve frame drops during workouts (#127), modernize data streams from fitness machines and sensors to the GUI, and support:
- **Instant Settings Application** (theme light/dark mode #333, HR-only / cadence-only toggles #561, palette resets #545).
- **Customizable Live Workout UI & Modular Tiles** (reconfiguring tiles and layouts live during measurement #375, #228, #242).
- **Live In-App Localization** (multi-language support without app restart #203).

---

## 1. Codebase Audit & Problem Statement

1. **Broken Stream-to-Callback Pipeline (`FitnessEquipment` -> `RecordingState`)**:
   - `FitnessEquipment._listenToData` starts as an `async*` `Stream<RecordWithSport>` merging primary FTMS/CSC/RSC packets with secondary sensors.
   - However, `FitnessEquipment.pumpData` downgrades this stream into an imperative callback (`_recordHandlerFunction`), alongside `_throttlingTimerCallback` into `RecordingState` (`lib/ui/recording/recording_screen.dart`).
2. **Monolithic `setState` on Every 1–4 Hz Telemetry Packet**:
   - In `RecordingState`, every incoming record triggers `setState(() { ... })` on a ~3,100-line `StatefulWidget`.
   - Even if a single metric changes (e.g. Heart Rate +1 bpm), the entire widget subtree rebuilds: `AppBar`, `TrackVisualization` custom painter, all 6–9 `ExpandablePanel` rows, every `SfCartesianChart`, and the FAB menu.
3. **Synchronous DB Writes & O(N) Chart List Allocations**:
   - Every tick executes `_database.writeTxnSync(() => _database.records.putSync(record))` on the UI thread.
   - Every tick allocates up to three full clones of the sliding window queue (`_graphData.toList(growable: false)`) and recalculates statistics O(N) across the queue, forcing `SfCartesianChart` to diff full series lists even for collapsed rows.
4. **Snapshot-Once Preferences Instead of Reactive Streams**:
   - `BasePrefService` from `pref: ^2.8.0` extends `ChangeNotifier` and provides `Stream<T> stream<T>(String key)`.
   - In the legacy codebase, screens snapshot preferences once during `initState()` / `onInit()`, meaning theme changes (#333), sensor mode toggles (#561), and unit switches require screen re-entry or app restarts.

---

## 2. State Management Framework Evaluation

### `GetX` (`package:get`) vs. `get_it` + `watch_it`

- **Crucial Distinction**: `watch_it` does not run on `GetX` (`package:get`) — it is built on **`get_it`** (`package:get_it`) as part of the `flutter_it` ecosystem (`get_it` + `watch_it` + `listen_it`).
- **Why Phase Out `package:get`**:
  - `get: 4.7.3` is in maintenance limbo (`5.0.0-rc` has remained unreleased since 2023), causes symbol collisions with Material types, and requires `deprecated_member_use: ignore` in `analysis_options.yaml`.
  - In `lib/`, only **4 files** actually use GetX reactive state (`GetBuilder` in `find_devices_screen.dart` & `scan_fab_menu.dart`; `.obs` / `Obx` in `upload_manager.dart` & `upload_portal_picker.dart`). The remaining **90+ files** only use `Get.find` / `Get.put` (service locator) and `Get.to` / `Get.snackbar` (contextless navigation).
- **Comparison of Alternatives**:

| Evaluation Criteria | **`get_it` + `watch_it` + `rxdart` (Selected)** | **`flutter_riverpod` (3.x)** | **`signals_flutter`** | **`flutter_bloc` / `Cubit`** |
| :--- | :--- | :--- | :--- | :--- |
| **Service Locator / DI Fit** | **1:1 match** with `Get.find<T>()` across UI, BLE descriptors, and background tasks | Requires `ProviderScope` + threading `Ref` through 90+ non-UI files | Needs `get_it` anyway for DI | Heavy boilerplate; needs `RepositoryProvider` |
| **Dart `Stream` Ergonomics** | **First-class** (`watchStream` in `WatchingWidget` + `rxdart` `BehaviorSubject` / `distinct()`) | `StreamProvider`, but heavy ceremony per telemetry metric | Requires `streamSignal` adapters | Verbose `emit.forEach` / state classes |
| **Codegen Requirements** | **Zero codegen required** | Heavy reliance on `@riverpod` + `build_runner` | Zero codegen | Often paired with `freezed` |
| **Surgical Tile Rebuilds** | **Yes** (`WatchingWidget` rebuilds only the exact metric tile) | Yes (`Consumer`) | Yes (`Watch`) | Yes (`BlocSelector`) |

**Decision**: Adopt **`get_it` + `watch_it` + `rxdart`** while incrementally sunsetting `package:get`.

---

## 3. Target End-to-End Reactive Stream Architecture

```
[BLE Characteristics (flutter_blue_plus) / Internal Sensors]
        │  raw byte / sensor streams
        ▼
[DeviceDescriptor / Sensor Classes]
        │  parsed RecordWithSport streams
        ▼
[FitnessEquipment] ──► BehaviorSubject<RecordWithSport> (rxdart broadcast stream)
        │              (merges primary FTMS + HRM/cadence/power sensors + pause/throttle ticks)
        ▼
[WorkoutSessionService (registered in get_it)]
   ├──► Async DB Writer: `_database.writeTxn(...)` off the synchronous UI frame path
   ├──► Per-Metric Distinct Streams / ValueListenables (`.map(...).distinct()`):
   │      • elapsed / movingTime          • distance
   │      • power (inst / avg / max / zone)• speed / pace (inst / avg / max / zone)
   │      • cadence (inst / avg / max / z) • heartRate (inst / avg / max / zone)
   │      • calories                      • resistance / inclination / strokeCount
   ├──► Incremental Chart Series Controllers (`ChartSeriesController.updateDataSource`)
   └──► Track Position `ValueNotifier<TrackMarkerState>`
        │
        ▼
[Granular `WatchingWidget` UI Tiles + Reactive `SettingsService` (`BasePrefService.stream<T>`)]
   • Each `MetricTile extends WatchingWidget` watches ONLY its own metric + unit/palette listenable.
   • Unchanged metrics trigger 0 widget rebuilds.
```

---

## 4. Phased Implementation Roadmap

### Phase 1: Foundation & Reactive Settings (#333, #561, #545)
- Add `get_it` and `watch_it` to `pubspec.yaml` alongside existing `rxdart`.
- Register core singletons (`BasePrefService`, `SettingsService`, `ThemeManager`, `PaletteSpec`, `UploadManager`, `ExportManager`) in `get_it` with thin backwards-compatible bridges for `Get.find<T>()`.
- Convert `TrackMyIndoorExerciseApp` to `WatchingWidget` watching `ThemeMode` / performance overlay preference streams (#333).
- Make `PaletteSpec` reactive (#545).
- Subscribe `FindDevicesController` and `FitnessEquipment` to live workout preference streams (#561) so sensor mode changes apply instantly without app re-entry.

### Phase 2: Sensor-to-GUI Stream Pipeline & Surgical Tile Rebuilds (#127)
- Refactor `FitnessEquipment.pumpData` to expose `Stream<RecordWithSport> recordStream` using `BehaviorSubject<RecordWithSport>`.
- Extract a dedicated `WorkoutSessionService` (registered in `get_it`) managing:
  - Asynchronous Isar record insertion (`writeTxn`) off the UI thread.
  - Per-metric distinct streams and `ValueListenable`s (`.map(...).distinct()`).
  - Incremental `ChartSeriesController.updateDataSource` (O(1) append/evict without full series list recreation).
- Break `RecordingScreen` into granular `WatchingWidget` metric tiles, eliminating full-screen `setState`.

### Phase 3: Declarative Customizable Workout UI & Modular Layouts (#375, #228, #242)
- Introduce a reactive `TileSpec` layout model backed by preferences and `flutter_layout_grid`.
- Allow live reordering, resizing, hiding, or showing metrics and charts during active measurement.
- Self-contained tiles automatically pause stream listening when hidden or collapsed to conserve CPU and GPU cycles.

### Accompanying: Live Localization (#203) & Final GetX Sunset
- Integrate `slang` + `slang_flutter` watched via `LocaleSettings.getLocaleStream()`.
- Provides context-less translations in services/isolates and instant UI re-rendering upon language selection.
- Replace remaining GetX navigation (`Get.to`, `Get.dialog`, `Get.snackbar`) with standard `MaterialApp` `navigatorKey` and `scaffoldMessengerKey`, then remove `package:get`.
