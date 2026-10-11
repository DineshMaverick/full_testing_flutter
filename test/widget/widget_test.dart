import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:full_testing_flutter/main.dart';

void main() {
  group('[Widget -> Person form]', () {
    testWidgets('shows name and age fields and a submit button',
        (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byKey(const Key('nameField')), findsOneWidget);
      expect(find.byKey(const Key('ageField')), findsOneWidget);
      expect(find.byKey(const Key('submitButton')), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid input', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter a valid age'), findsOneWidget);
      expect(find.byKey(const Key('submissionResult')), findsNothing);
    });

    testWidgets('submits valid form input', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.enterText(
          find.byKey(const Key('nameField')), 'Grace Hopper');
      await tester.enterText(find.byKey(const Key('ageField')), '85');
      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Submitted: Grace Hopper, age 85'), findsOneWidget);
    });
  });
}
