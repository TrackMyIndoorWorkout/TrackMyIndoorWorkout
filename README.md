# Track My Indoor Workout

Track My Indoor Workout is an application which supports Bluetooth Low Energy (BLE) enabled
smart fitness machines to record stationary workouts. Workouts can have GPS routes -
generated based on speed - and upload to numerous fitness portals. Workouts can be exported in
common formats and in some cases (ANT+ machines or data migration purposes) there's an option to
import saved workouts.

The ultimate mission is to improve people's health by preventing fitness machines from becoming
laundry drying racks.

For more details please see [the application's website](https://trackmyindoorworkout.github.io).

## Code Style

The project currently uses flutter format with 100 character line length.
To achieve that supply an extra parameter to *flutter format* at the project root:
`flutter format --line-length 100 .`. Besides that we also run `flutter analyze`.

## Continuous Integration

The CI script executes the above `flutter format --line-length 100 .` and
`flutter analize .` commands and then runs the unit tests. If any of them fails the CI is
deemed broken. The best to avoid that is to execute those in a client-side
[pre-push hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).

## Branching Strategy

For common contributors: please base your pull request against the `develop` branch.
The project currently uses Git Flow branching conventions. See this
[cheat sheet](https://danielkummer.github.io/git-flow-cheatsheet/) first and maybe also
https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow.
Features will be developed in their own branches (after `git flow feature start my_feature_x`)
and will merge into `develop` with a `git flow feature finish my_feature_x`
when deemed finished. Production releases (`git flow release start my_next_big_release`)
merge the `develop` branch into `master`. The only downside of that is it does not interoperate
with the pull request infrastructure, so in the future we may switch to using
[Git Town](https://github.com/git-town/git-town) operating
on [somewhat similar branch hierarchy](https://github.com/git-town/git-town/blob/main/documentation/development/branch_hierarchy.md)
mainly with `git town hack my_feature_x` and `git ship town my_feature_x`.

## Code regeneration

Run this command: `flutter packages pub run build_runner build --delete-conflicting-outputs`

## License

This work is dual-licensed under Apache 2.0 and GPL 3.0.
You can choose between one of them if you use this work.

`SPDX-License-Identifier: Apache-2.0 OR GPL-3.0`
