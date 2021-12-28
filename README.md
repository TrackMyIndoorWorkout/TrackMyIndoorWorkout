# Track My Indoor Workout

[Application website](https://trackmyindoorworkout.github.io)

## Branching Strategy

The project uses Git Flow branching conventions. See this
[cheat sheet](https://danielkummer.github.io/git-flow-cheatsheet/) first and maybe also
https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow.
Features will be developed in their own branches and those will merge into `develop` when
features are deemed finished. Releases merge the `develop` branch into `master`. That's on
client side and thena contributer can formulate a Pull Request.

## Code Style

The project uses flutter format with 100 character line length.
To achieve that supply an extra parameter to `flutter format` at the project root:
`flutter format --line-length 100 ./`

## Continuous Integration

The CI script executes the above `flutter format --line-length 100 .` command and also
a `flutter analize .` and then runs the unit tests. If any of them fails the CI is
deemed broken. The best to avoid that is to execute those in a client-side
[pre-commit hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).
