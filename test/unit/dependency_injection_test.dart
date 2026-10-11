import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:full_testing_flutter/main.dart';
import 'package:full_testing_flutter/person_form_model.dart';

void main() {
  group('[Dependency injection]', () {
    testWidgets('submits the form through the injected model', (tester) async {
      final injectedModel = PersonFormModel();

      await tester.pumpWidget(MyApp(formModel: injectedModel));
      await tester.enterText(
          find.byKey(const Key('nameField')), '  Ada Lovelace  ');
      await tester.enterText(find.byKey(const Key('ageField')), '36');
      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pumpAndSettle();

      expect(
        Provider.of<PersonFormModel>(
          tester.element(find.byKey(const Key('submissionResult'))),
          listen: false,
        ),
        same(injectedModel),
      );
      expect(injectedModel.submission?.name, 'Ada Lovelace');
      expect(injectedModel.submission?.age, 36);
      expect(find.text('Submitted: Ada Lovelace, age 36'), findsOneWidget);
      injectedModel.dispose();
    });

    testWidgets('does not dispose an injected model', (tester) async {
      final injectedModel = _TrackingPersonFormModel();

      await tester.pumpWidget(MyApp(formModel: injectedModel));
      await tester.pumpWidget(const SizedBox.shrink());

      expect(injectedModel.disposed, isFalse);
      injectedModel.dispose();
    });

    testWidgets('creates and disposes its default model', (tester) async {
      await tester.pumpWidget(const MyApp());

      final context = tester.element(find.byKey(const Key('nameField')));
      final model = Provider.of<PersonFormModel>(context, listen: false);
      expect(model, isA<PersonFormModel>());

      await tester.pumpWidget(const SizedBox.shrink());

      expect(() => model.addListener(() {}), throwsFlutterError);
    });
  });
}

class _TrackingPersonFormModel extends PersonFormModel {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
