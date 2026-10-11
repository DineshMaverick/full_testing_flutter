import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('[Driver -> Counter App]', () {
    final counterTextFinder = find.byValueKey('counter');
    final buttonFinder = find.byValueKey('increment');
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('starts at 0', () async {
      expect(await driver.getText(counterTextFinder), '0');
    });

    test('increments the counter', () async {
      await driver.tap(buttonFinder);
      expect(await driver.getText(counterTextFinder), '1');
    });
  });
}
