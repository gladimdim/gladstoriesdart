pub run test ./test/gladstoriesengine_test.dart --coverage=./coverage
format_coverage --packages=.packages --report-on lib -i ./coverage/test/gladstoriesengine_test.dart.vm.json -o ./coverage/lcov.info -l
genhtml -o coverage coverage/lcov.info