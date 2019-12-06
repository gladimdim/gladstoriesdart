pub run test ./test/main.dart --coverage=./coverage
format_coverage --packages=.packages -i ./coverage/test/main.dart.vm.json -o ./result/lcov.info -l