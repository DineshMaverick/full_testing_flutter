set -e # abort CI if an error happens
flutter packages get
dart format --set-exit-if-changed lib test test_driver integration_test
flutter analyze lib test test_driver integration_test
flutter test --no-pub --coverage
