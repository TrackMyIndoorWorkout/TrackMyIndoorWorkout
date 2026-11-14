# Localization (`slang`) & Google Play Store Integration Architecture

## Context & Objectives

This document accompanies [`reactive_state_and_streams_architecture.md`](./reactive_state_and_streams_architecture.md) and details the architecture for **Issue #203 ("Localize the app")**, covering:
1. Why **`slang` + `slang_flutter`** is selected for Dart/Flutter localization.
2. How live language switching integrates with **`get_it` + `watch_it` + `BasePrefService`** without app restarts.
3. How to configure **Android native resources and Google Play Store** (plus Galaxy Store, F-Droid, and OEM stores) so localized Flutter builds are accurately detected, indexed, and surfaced to users.

---

## 1. Localization Library Selection: Why `slang`?

| Requirement in `track_my_indoor_exercise` | **`slang` + `slang_flutter` (Selected)** | **Official Flutter `gen-l10n` (`.arb`)** | **`easy_localization`** |
| :--- | :--- | :--- | :--- |
| **`BuildContext`-Free Access** (BLE descriptors, `ExportManager`, `UploadManager`, `Workmanager` isolates, `MetricSpec`) | **Native**: `t.metrics.power.title` works synchronously anywhere in pure Dart | Requires `BuildContext` (`AppLocalizations.of(context)!`) or awkward manual global caching | Global `tr()`, but stringly-typed and fragile in headless isolates |
| **Compile-Time Key & Plural Safety** | **Yes** — missing keys or wrong parameter types are compile errors | **Yes** | **No** — string keys fail at runtime |
| **Unit Test Reliability** | **Zero async asset setup**; works synchronously in unit tests | Requires localization delegate pumping in widget tests | Known `LateInitializationError` pitfalls with pluralization in tests |
| **Codegen Tooling** | **Fast standalone CLI** (`dart run slang`, <0.5s, **no `build_runner` required**) | Built into Flutter tool (`flutter gen-l10n`) | No codegen by default |
| **Translator File Formats** | Supports **`.i18n.json`**, `.yaml`, `.csv`, and **`.arb`** (compatible with Weblate / Crowdin / Poeditor) | `.arb` only | `.json` / `.csv` / `.yaml` |

### Why Not Read Android `res/values/strings.xml` Directly from Flutter?
- Flutter renders its UI in Dart and cannot synchronously look up Android XML resources at 60 fps without asynchronous `MethodChannel` round-trips, nor would Android `strings.xml` work on iOS (#34) or macOS.
- Therefore, **all in-app UI and background service strings live in `slang`**, while Android `res/` XML files are used strictly for **OS-level launcher/permission metadata and App Store locale detection** (see Section 3).

---

## 2. Reactive Architecture & Codebase Integration

### A. Instant In-App Language Switching (`watch_it` + `BasePrefService`)
1. Add a language preference in `PreferencesSpec` (default `"system"`, plus explicit overrides such as `"en"`, `"de"`, `"fr"`, `"es"`, `"hu"`).
2. Subscribe to `BasePrefService.stream<String>(appLanguageTag)`:
   - When `"system"` is selected, call `LocaleSettings.useDeviceLocale()`.
   - When a specific locale is selected, call `LocaleSettings.setLocaleRaw(langCode)`.
3. In `TrackMyIndoorExerciseApp` (converted to a `WatchingWidget` wrapped in `TranslationProvider`):
   - Watch `LocaleSettings.getLocaleStream()` via `watchStream(...)` (or `TranslationProvider.of(context).flutterLocale`).
   - Pass `locale`, `supportedLocales: AppLocaleUtils.supportedLocales`, and `GlobalMaterialLocalizations.delegates` (`flutter_localizations`) to `MaterialApp`.
   - Switching languages in Preferences immediately re-renders active screens and tiles without restarting the app or interrupting an active workout.

### B. Refactoring Static/Cached Spec Labels into Dynamic Getters
- Currently, classes such as `MetricSpec` (`lib/preferences/metric_spec.dart`), sport definitions, and preference option descriptors store `title`, `unit`, and `description` as final `String` fields constructed once at startup.
- During string extraction, convert these from static strings to **dynamic getters** (e.g., `String get title => t.metrics.speed.title;`) so cached spec instances always resolve against the active `LocaleSettings.currentTranslations` instead of holding stale text from startup.

### C. Isolate Localization (`ExportManager` & `Workmanager`)
- When spawning background isolates (`Isolate.run` in `ExportManager` or headless `Workmanager` tasks in `workmanager_dispatcher.dart`), pass `LocaleSettings.currentLocale.languageTag` and call `LocaleSettings.setLocaleRaw(tag)` inside the isolate entrypoint if localized strings are formatted there.

---

## 3. How Google Play Store & Android Process Flutter Localizations

**Critical Gotcha**: Google Play's App Bundle (`.aab`) analyzer **does not inspect Dart code (`libapp.so`) or `flutter_assets/`** to determine which languages your app supports. Instead, Google Play and Android 13+ inspect **compiled Android resource tables (`resources.arsc`)**, **`AndroidManifest.xml`**, and **Play Console store listings**.

Without explicit native Android configuration, two problems occur:
1. **False "80+ Languages Supported" Badge**: Transitive dependencies (`androidx.core`, `appcompat`, Google Play Services) bundle `res/values-af` through `res/values-zu` into your AAB. Google Play sees those resource tables and tells users your app supports French, German, Japanese, etc.—leading to 1-star *"No French"* reviews when the UI is actually English-only.
2. **Missing Android 13+ Per-App Language Picker & Split-APK Stripping**: Without `localeConfig`, Android 13+ (API 33+) will not show your app in **System Settings → Apps → App Languages**, and Play App Signing split APKs may strip locale resources not declared in `localeFilters`.

### The 3-Layer Native Android & Store Configuration

#### Layer 1: `localeFilters` in `android/app/build.gradle.kts` (Prevents False Language Claims)
Explicitly restrict packaged Android resource locales to the exact languages translated in `slang` (and already do this today with `"en"` until the first translation lands!):

```kotlin
android {
    // ...
    androidResources {
        localeFilters += listOf("en", "de", "fr", "es") // Keep strictly in sync with slang locales
    }
}
```

#### Layer 2: `locales_config.xml` + `AndroidManifest.xml` (Android 13+ OS Picker & Play Store Detection)
1. Create `android/app/src/main/res/xml/locales_config.xml` listing the exact supported BCP-47 tags:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <locale-config xmlns:android="http://schemas.android.com/apk/res/android">
       <locale android:name="en"/>
       <locale android:name="de"/>
       <locale android:name="fr"/>
       <locale android:name="es"/>
   </locale-config>
   ```
2. Reference it on `<application>` in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <application
       android:localeConfig="@xml/locales_config"
       ... >
   ```
3. *(Recommended for Galaxy Store #333, F-Droid #418, Xiaomi/OPPO/Vivo #388, HONOR #374)*: Include a minimal `android/app/src/main/res/values-<lang>/strings.xml` (e.g., `<string name="app_name">Track My Indoor Workout</string>`) for each supported locale so every store's `aapt2 dump configurations` scanner detects the exact same language set in `resources.arsc`.

#### Layer 3: Play Console Store Listing Metadata (Pre-Install Store Visibility)
- Users browsing Google Play in Germany, France, or Spain see localized **Title, Short Description, Full Description, Changelogs, and Screenshots (#281)** only when translations are added in **Google Play Console → Store presence → Main store listing** (or uploaded automatically via Fastlane `metadata/android/<locale>/`).
- Keeping Fastlane-formatted `metadata/android/<locale>/` text files in git allows volunteer translators (#203) to translate the Play Store description alongside the `slang` `.i18n.json` files in a single Pull Request—and the same text files can be reused directly for **F-Droid (#418)**!
