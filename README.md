# Track My Indoor Workout

Track My Indoor Workout is an application which supports Bluetooth Low Energy (BLE) enabled
smart fitness machines to record stationary workouts. Workouts can have GPS routes -
generated based on speed - and upload to numerous fitness portals. Workouts can be exported in
common formats and in some cases (ANT+ machines or data migration purposes) there's an option to
import saved workouts.

The ultimate mission is to improve people's health by preventing fitness machines from becoming
laundry drying racks.

For more details please see [the application's website](https://trackmyindoorworkout.github.io).

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
  and I don't employ `git hack` - `git ship` workflow. I'm avoiding squashing commits because
  I want to preserve detailed commit history to help forensic debugging. But I'm flexible if
  contributions become common and majority wants to change policies.

## Code regeneration

With certain data persistence or testing Mock changes you may need code regeneration. Due to the community build of `isar` lagging behind we'll need to temporarily set back the `anslyzer` version for successful code generation.
1. Set the `analyzer` version to `6.11.0` in the developer dependencies of the `pubspec.yaml` and comment out the override at the top.
2. `pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. Don't forget to re-run `dart format .` after that.
5. Set back the original `analyzer` version within the `drveloper` dependencies to match the override version, and remove the comments from the version override.
6. `pub get`

## License

This work is licensed under Apache 2.0.
`SPDX-License-Identifier: Apache-2.0`
