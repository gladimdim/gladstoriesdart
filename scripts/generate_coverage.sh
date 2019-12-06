pub run test ./test/main.dart --coverage=./coverage
format_coverage --packages=.packages --report-on lib -i ./coverage/test/main.dart.vm.json -o ./result/lcov.info -l
genhtml -o result result/lcov.info