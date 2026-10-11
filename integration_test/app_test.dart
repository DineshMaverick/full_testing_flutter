import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:full_testing_flutter/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('counter increments on the device', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });
}
