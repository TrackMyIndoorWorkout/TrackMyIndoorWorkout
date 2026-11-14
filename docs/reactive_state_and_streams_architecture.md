# Reactive State Management & Stream Architecture Roadmap

## Context & Objectives

This document formalizes the architectural design and phased migration plan to eliminate the `setState` anti-pattern, resolve frame drops during workouts (#127), modernize data streams from fitness machines and sensors to the GUI, and support:
- **Instant Settings Application** (theme light/dark mode #333, HR-only / cadence-only toggles #561, palette resets #545).
- **Customizable Live Workout UI & Modular Tiles** (reordering/hiding rows #179, #228, #242, widget-type dashboard #375, landscape & split-screen #266, #587).
- **Background Recording & Multi-Target Streaming** (screen-off/background recording #16, FTMS BLE peripheral rebroadcasting #389).
- **Live In-App Localization** (multi-language support without app restart #203 — see companion doc [`localization_and_play_store_architecture.md`](./localization_and_play_store_architecture.md)).

---

## 1. Codebase Audit & Problem Statement

1. **Broken Stream-to-Callback Pipeline (`FitnessEquipment` -> `RecordingState`)**:
   - `FitnessEquipment._listenToData` starts as an `async*` `Stream<RecordWithSport>` merging primary FTMS/CSC/RSC packets with secondary sensors.
   - However, `FitnessEquipment.pumpData` downgrades this stream into an imperative callback (`_recordHandlerFunction`), alongside `_throttlingTimerCallback` into `RecordingState` (`lib/ui/recording/recording_screen.dart`).
2. **Monolithic `setState` on Every 1–4 Hz Telemetry Packet**:
   - In `RecordingState`, every incoming record triggers `setState(() { ... })` on a ~3,100-line `StatefulWidget`.
   - Even if a single metric changes (e.g. Heart Rate +1 bpm), the entire widget subtree rebuilds: `AppBar`, `TrackVisualization` custom painter, all 6–9 `ExpandablePanel` rows, every `SfCartesianChart`, and the FAB menu.
   - Workout recording lifecycle, computation, and DB writes are coupled directly to a UI `State` object (`RecordingState`), contributing to recording gaps when the screen locks or the app is backgrounded (#16) and making dynamic row reordering prohibitively slow (#179).
3. **Synchronous DB Writes & O(N) Chart List Allocations**:
   - Every tick executes `_database.writeTxnSync(() => _database.records.putSync(record))` on the UI thread.
   - Every tick allocates up to three full clones of the sliding window queue (`_graphData.toList(growable: false)`) and recalculates statistics O(N) across the queue, forcing `SfCartesianChart` to diff full series lists even for collapsed rows.
4. **Snapshot-Once Preferences Instead of Reactive Streams**:
   - `BasePrefService` from `pref: ^2.8.0` extends `ChangeNotifier` and provides `Stream<T> stream<T>(String key)`.
   - In the legacy codebase, screens snapshot preferences once during `initState()` / `onInit()`, meaning theme changes (#333), sensor mode toggles (#561), unit switches (#280), and palette resets (#545) require screen re-entry or app restarts.

---

## 2. State Management Framework Evaluation

### `GetX` (`package:get`) vs. `get_it` + `watch_it`

- **Crucial Distinction**: `watch_it` does not run on `GetX` (`package:get`) — it is built on **`get_it`** (`package:get_it`) as part of the `flutter_it` ecosystem (`get_it` + `watch_it` + `listen_it`).
- **Why Phase Out `package:get`**:
  - `get: 4.7.3` is in maintenance limbo (`5.0.0-rc` has remained unreleased since 2023), causes symbol collisions with Material types, and requires `deprecated_member_use: ignore` in `analysis_options.yaml`.
  - In `lib/`, only **4 files** actually use GetX reactive state (`GetBuilder` in `find_devices_screen.dart` & `scan_fab_menu.dart`; `.obs` / `Obx` in `upload_manager.dart` & `upload_portal_picker.dart`). The remaining **90+ files** only use `Get.find` / `Get.put` (service locator) and `Get.to` / `Get.snackbar` (contextless navigation).

### Detailed Comparison Against Riverpod, Signals, and BLoC

| Evaluation Criteria | **`get_it` + `watch_it` + `rxdart` (Selected)** | **`flutter_riverpod` (3.x)** | **`signals_flutter`** | **`flutter_bloc` / `Cubit`** |
| :--- | :--- | :--- | :--- | :--- |
| **Service Locator / Non-UI Fit** | **1:1 match** with `Get.find<T>()` across UI, BLE descriptors, exporters, and headless `Workmanager` isolates | Replaces service locator with `ProviderScope` / `ProviderContainer`; requires threading `Ref` through 95 non-UI/BLE/isolate files | Needs `get_it` anyway for DI | Needs `get_it` or widget-coupled `RepositoryProvider` |
| **Underlying State Primitives** | **Standard Flutter/Dart primitives** (`ValueNotifier`, `ValueListenable`, `ChangeNotifier`, `Stream`) — zero vendor lock-in | Proprietary `Notifier` / `AsyncNotifier` / `Provider` graph | Custom `Signal` / `Computed` primitives | `Bloc` / `Cubit` state streams (note: `graph_bloc` is unmaintained) |
| **Aspect / Field Selection (`.select`)** | **Yes** (`watchPropertyValue((WorkoutSession s) => s.heartRate)` + distinct per-metric streams) | **Yes** (`ref.watch(provider.select(...))`) | **Yes** (`computed(() => ...)`) | **Yes** (`BlocSelector`), high state-class ceremony |
| **Dart `Stream` Ergonomics** | **First-class** (`watchStream` in `WatchingWidget` + `rxdart` `BehaviorSubject` / `distinct()`) | `StreamProvider`, heavy ceremony per telemetry metric | Needs `streamSignal` adapters over existing BLE/pref streams | Verbose `emit.forEach` + immutable `freezed` state churn at 1–4 Hz |
| **Codegen Requirements** | **Zero codegen required** | Idiomatic Riverpod 3 relies heavily on `@riverpod` + `build_runner` | Zero codegen | Typically paired with `freezed` + `build_runner` |
| **Incremental Migration** | **Seamless coexistence** alongside `package:get` | Requires root `ProviderScope` + dual DI paradigms | Requires `get_it` + signal wrappers | High rewrite cost |

**Decision**: Adopt **`get_it` + `watch_it` + `rxdart`** (with standard Flutter `ValueNotifier` / `ChangeNotifier` models) while incrementally sunsetting `package:get`. While Riverpod is an excellent choice for greenfield CRUD apps, `get_it` + `watch_it` provides identical surgical rebuilds (`watchPropertyValue` / `watchStream`) while matching our 95-file BLE, exporter, and background-isolate architecture 1:1 with zero `build_runner` overhead.

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
        │              (merges primary FTMS + HRM/cadence/power sensors + pause/throttle ticks;
        │               can simultaneously feed BLE peripheral rebroadcasting #389)
        ▼
[WorkoutSessionService (registered in get_it, decoupled from Widget lifecycle for #16)]
   ├──► Explicit Session State (`connecting` -> `ready` -> `measuring` -> `paused` -> `spinningDown`)
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
   • Hidden or collapsed tiles subscribe to nothing -> 0 rebuilds and 0 chart overhead.
```

---

## 4. Phased Implementation Roadmap

### Phase 1: Foundation & Reactive Settings (#333, #561, #545)
- Add `get_it` and `watch_it` to `pubspec.yaml` alongside existing `rxdart`.
- Register core singletons (`BasePrefService`, `SettingsService`, `ThemeManager`, `PaletteSpec`, `UploadManager`, `ExportManager`) in `get_it` with thin backwards-compatible bridges for `Get.find<T>()`.
- Convert `TrackMyIndoorExerciseApp` to `WatchingWidget` watching `ThemeMode` / performance overlay preference streams (#333).
- Make `PaletteSpec` reactive (#545, #560, #272).
- Subscribe `FindDevicesController` and `FitnessEquipment` to live workout preference streams (#561) so sensor mode changes apply instantly without app re-entry.

### Phase 2: Sensor-to-GUI Stream Pipeline & Surgical Tile Rebuilds (#127, #16)
- Refactor `FitnessEquipment.pumpData` to expose `Stream<RecordWithSport> recordStream` using `BehaviorSubject<RecordWithSport>`.
- Extract a dedicated `WorkoutSessionService` (registered in `get_it`, independent of `RecordingScreen` widget lifecycle) managing:
  - Explicit session lifecycle state (#421, #467, #387, #455).
  - Asynchronous Isar record insertion (`writeTxn`) off the UI thread.
  - Per-metric distinct streams and `ValueListenable`s (`.map(...).distinct()`).
  - Incremental `ChartSeriesController.updateDataSource` (O(1) append/evict without full series list recreation).
- Break `RecordingScreen` into granular `WatchingWidget` metric tiles, eliminating full-screen `setState`.

### Phase 3: Declarative Customizable Workout UI & Adaptive Layouts (#179, #228, #242, #266, #375)
- Introduce a reactive `TileSpec` layout model backed by preferences and `flutter_layout_grid`.
- Allow live reordering (#179), hiding/showing rows and cumulative stats (#228, #242), automatic hiding of unavailable sensor rows, and adaptive portrait/landscape/split-screen grids (#266, #587, #508) during active measurement.
- Self-contained tiles automatically pause chart/stream listening when hidden or collapsed (#314) to conserve CPU and GPU cycles.

### Accompanying: Live Localization (#203) & Final GetX Sunset
- Integrate `slang` + `slang_flutter` watched via `LocaleSettings.getLocaleStream()` and configure Android `localeFilters` + `localeConfig` for Google Play Store (detailed in [`localization_and_play_store_architecture.md`](./localization_and_play_store_architecture.md)).
- Replace remaining GetX navigation (`Get.to`, `Get.dialog`, `Get.snackbar`) with standard `MaterialApp` `navigatorKey` and `scaffoldMessengerKey`, then remove `package:get` and re-enable `deprecated_member_use` lint checks.

---

## 5. Backlog Impact Matrix: Open Tickets Unlocked or Accelerated

| Category | Open Tickets | How Reactive State & Streams Unlock Them |
| :--- | :--- | :--- |
| **Frame Drops & UI Architecture** | **#127** (Frame drops), **#267** (Source structure), **#317** (Cold start time) | Surgical per-tile rebuilds + async DB writes + O(1) chart updates fix #127; decoupling domain services from UI addresses #267; `get_it` `registerLazySingleton` defers non-critical init past first frame (#317). |
| **Configurable & Modular Workout UI** | **#179** (Row order/visibility), **#228** (Hide rows), **#242** (Hide cumulative rows), **#375** (Widget-type UI), **#314** (Accordion rows) | Independent `WatchingWidget` tiles eliminate the O(N) rebuild penalty that blocked #179 previously; hidden/collapsed tiles cost 0 CPU/GPU; accordion state (#314) ensures at most one active `SfCartesianChart` renders at a time. |
| **Adaptive & Multi-Form-Factor Layouts** | **#266** (Landscape layout), **#587** (Split screen), **#508** (Small watch screens), **#588** (Small UI summary elements) | Keeping `WorkoutSessionService` in `get_it` outside `Widget` state allows switching between portrait lists, 2-pane landscape grids (#266), split-screen (#587), and compact watch layouts (#508) mid-workout without losing state or dropping BLE packets. |
| **Instant Live Settings & Visuals** | **#333** (Live theme change), **#561** (HR/Cadence mode without restart), **#545** (Palette reset), **#560** (Zone coloring), **#272** (Color blindness), **#280** (Unit-aware settings) | `BasePrefService.stream<T>` + reactive `ThemeManager` / `PaletteSpec` apply theme, palette, accessibility colors, unit conversions, and sensor modes live across all screens. |
| **Background Recording & Companion Targets** | **#16** (Background / screen-locked gaps), **#389** (FTMS BLE peripheral broadcast), **#550** (Wear OS), **#257** (Voice commands) | Decoupling `WorkoutSessionService` from `RecordingScreen` is the core prerequisite for reliable foreground-service background recording (#16), secondary stream consumers like FTMS peripheral GATT broadcasting (#389), voice control (#257), and Wear OS (#550). |
| **Session Lifecycle & Structured / ERG Workouts** | **#421** (Pause button), **#467** (Start race condition), **#387** (Spin-down vs instant start), **#455** (Machine powered off), **#119** (Staged workouts), **#400** (ERG/slopes/structured), **#559** (FTMS targets), **#470** / **#176** (FTMS control), **#551** (Peloton guidance) | Explicit reactive session state eliminates `initState` navigation races (#467) and spin-down/pause conflicts (#387, #421); structured/ERG workout controllers subscribe cleanly to `recordStream` and emit FTMS control commands without bloating `RecordingScreen`. |
| **Extended Biometrics & Sport Metrics** | **#191** (HRV), **#556** (HRT), **#505** (Extended paddling metrics) | Each new metric is an isolated stream/notifier + optional `WatchingWidget` tile, adding zero overhead for workouts that do not use those sensors. |
| **Localization** | **#203** (Localize the app), **#281** (Store listing screenshots) | `slang` `LocaleSettings.getLocaleStream()` watched at the root `WatchingWidget` enables `BuildContext`-free service strings + instant language switching without restart. |
