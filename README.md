# A Dart Implementation of runtime and editor of Interactive Fiction Story format GladStoriesEngine

## Home Page: https://github.com/gladimdim/GladStoriesEngine

# How to run Tests with coverage

- Install coverage https://pub.dev/packages/coverage:

```sh
pub global activate coverage
```

Install genhtml/lcov to generate html report from lcov:

```
brew install lcov
```

- Run script:

```sh
./scripts/generate_coverage.sh
```

- View the LCOV report with any tool