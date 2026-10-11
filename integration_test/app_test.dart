import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:full_testing_flutter/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('submits name and age on the device', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('nameField')), 'Ada Lovelace');
    await tester.enterText(find.byKey(const Key('ageField')), '36');
    await tester.tap(find.byKey(const Key('submitButton')));
    await tester.pumpAndSettle();

    expect(find.text('Submitted: Ada Lovelace, age 36'), findsOneWidget);
  });
}
