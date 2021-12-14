# Track My Indoor Workout

[See details at the app website](https://trackmyindoorworkout.github.io)

## Branching Strategy

The project uses Git Flow branching conventions. See this
[cheat sheet](https://danielkummer.github.io/git-flow-cheatsheet/) first and maybe also
https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow.
Features will be developed in their own branches and those will merge into `develop` when
features are deemed finished. Releases merge the `develop` branch into `master`.

## Code Style

The project uses flutter format with 100 character line length.
To achieve that supply an extra parameter to `flutter format` at the project root:
`flutter format --line-length 100 ./`
