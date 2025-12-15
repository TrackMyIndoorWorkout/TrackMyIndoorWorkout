# Track My Indoor Workout

Track My Indoor Workout is an application which supports Bluetooth Low Energy (BLE) enabled
smart fitness machines to record stationary workouts. Workouts can have GPS routes -
generated based on speed - and upload to numerous fitness portals. Workouts can be exported in
common formats and in some cases (ANT+ machines or data migration purposes) there's an option to
import saved workouts.

The ultimate mission is to improve people's health by preventing fitness machines from becoming
laundry drying racks.

For more details please see [the application's website](https://trackmyindoorworkout.github.io).

## Technical Architecture and Design

DeepWiki: https://deepwiki.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/

## Contribution Rules

* The project works on the Flutter stable channel. (For a good while it was on the beta channel
  because for example
  https://github.com/flutter/flutter/issues/114199#issuecomment-1294263848 and
  https://github.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/issues/399).
* For a successful local build you need to augment a dummy `secret.dart` file,
  see the the CI build script for a hint:
  https://github.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/blob/develop/.github/workflows/flutter_test.yml#L24
* Execute `dart format --line-length 100 .` at the project root.
  The project currently uses flutter format with 100 character line length.
* Also run `flutter analyze` at the project root. That picks up the analyzer settings from the yaml.
  You can consider adding the format and the analyze execution in a client-side
  [pre-push hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).
* For larger features let me know your plans in advance, so I can open up a feature branch so you
  can create a PR against that. Internally I follow Git Flow branching conventions
  ([cheat sheet](https://danielkummer.github.io/git-flow-cheatsheet/) and
  [another info page](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)).
  I'm performing releases that way as well.
  I'm also using [Git Town](https://github.com/git-town/git-town) but currently only for
  [git sync](https://github.com/git-town/git-town/blob/main/documentation/development/branch_hierarchy.md)
  and I don't use the `git hack` - `git ship` workflow. I'm avoiding squashing commits because
  I want to preserve detailed commit history to help forensic debugging. But I'm flexible if
  contributions become common and majority wants to change policies.

## Extra build quirks

* Some plugins which have native parts may require the Java version to raise from `1.8` to `17`
  (there are two types of these variables `JavaVersion.VERSION_17` and `17`,
  you'd need to edit the build files in the cache).
* If you don't have you may need to install 28.2.13676358 version of the NDK:
  1. `cd ${HOME}/{ANDROID_SDK}/cmdline-tools/latest/bin/`
     (in my case `/home/csaba/Android/Sdk/cmdline-tools/latest/bin/`)
  2. Verify that you can install this version of NDK: `./sdkmanager --list | grep "ndk;28.2.13676358"`
  3. Install it: `./sdkmanager "ndk;28.2.13676358"`
  4. In you `local.properties` if you have NDK directory, reference that:
     ```
     sdk.dir=/home/csaba/Android/Sdk
     ndk.dir=/home/csaba/Android/Sdk/ndk/28.2.13676358
     ```

## Code regeneration

With certain data persistence or testing Mock changes you may need code regeneration.
It's always good to regen the persistence code after any `isar` version change.
1. `dart run build_runner build --delete-conflicting-outputs`
2. Don't forget to re-run `dart format .` after that.

## License

This work is licensed under Apache 2.0.
`SPDX-License-Identifier: Apache-2.0`
