import 'package:flutter_test/flutter_test.dart';
import 'package:full_testing_flutter/counter.dart';

void main() {
  group('[Counter]', () {
    late Counter counter;

    setUp(() {
      counter = Counter();
    });

    test('Counter initial value should be 0', () {
      expect(counter.value, 0);
    });

    test('Counter class type should be `Counter`', () {
      expect(counter.runtimeType, equals(Counter));
    });

    test('Counter value type should be `int`', () {
      expect(counter.value.runtimeType, equals(int));
    });

    test('Counter value should not be `null`', () {
      expect(counter.value, isNotNull);
    });

    test('Counter value should be incremented', () {
      counter.increment();

      expect(counter.value, 1);
    });

    test('Counter value should be decremented', () {
      counter.decrement();

      expect(counter.value, -1);
    });

    test('Counter value should be first incremented and then decremented', () {
      counter.increment();
      counter.decrement();

      expect(counter.value, 0);
    });
  });
}
