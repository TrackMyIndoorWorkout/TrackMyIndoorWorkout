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

* If you are on a stable branch you ned to execute `flutter update-packages --force-upgrade` to upgrade Flutter's internal pinned package versions to avoid version conflicts (but in that case you need to undo those repository changes before Flutter SDK upgrades). The other way is to be on the beta channel. For details look at https://github.com/flutter/flutter/issues/114199#issuecomment-1294263848 and https://github.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/issues/399
* For building the project locally you need to augment a dummy `secret.dart` file, see the CI build script: https://github.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/blob/99ae7f2f54fecdcc3af3916a835863bd59a90020/.github/workflows/flutter_test.yml#L26
* Execute `flutter format --line-length 100 .` at the project root. The project currently uses flutter format with 100 character line length.
* Also run `flutter analyze` at the project root which picks up settings. You can consider adding the format and the analyze execution in a client-side
[pre-push hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).
* For larger features let me know in advance, so I can open up a feature branch you can create a PR against. Internally I foolow Git Flow branching conventions ([cheat sheet](https://danielkummer.github.io/git-flow-cheatsheet/) and [another info page](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)). I'm performing releaes that way as well. I'm also using [Git Town](https://github.com/git-town/git-town) but currently only for [git town sync](https://github.com/git-town/git-town/blob/main/documentation/development/branch_hierarchy.md) and I don't employ `git hack` - `git ship` workflow. I'm avoiding squashing commits because I want to preserve detailed commit history to help forensic debugging.

## Code regeneration

When  Run this command: `flutter packages pub run build_runner build --delete-conflicting-outputs`

## License

This work is licensed under GPL 3.0.

In a nutshell if you borrow or modify any code that work must be mandatorily open source as well!

`SPDX-License-Identifier: GPL-3.0`
