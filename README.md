# A Dart Implementation of runtime and editor of Interactive Fiction Story format GladStoriesEngine

## Interactive Fiction Engine Home Page: https://github.com/gladimdim/GladStoriesEngine

# Examples

Go to ./examples/ and check the dart source code there. It has a lot of comments.

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

- View the LCOV report at ./coverage/index.html
