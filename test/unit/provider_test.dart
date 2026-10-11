import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:full_testing_flutter/main.dart';
import 'package:full_testing_flutter/counter.dart';

void main() async {
  group('[Provider]', () {
    testWidgets('Update when the value changes', (tester) async {
      await tester.pumpWidget(const MyApp());
      final childContext = tester.element(find.byKey(const Key('counter')));

      expect(Provider.of<Counter>(childContext, listen: false).value, 0);

      Provider.of<Counter>(childContext, listen: false).increment();
      await tester.pump();

      expect(Provider.of<Counter>(childContext, listen: false).value, 1);

      Provider.of<Counter>(childContext, listen: false).decrement();
      await tester.pump();

      // Check decremented value...
      expect(Provider.of<Counter>(childContext, listen: false).value, 0);
    });
  });
}
