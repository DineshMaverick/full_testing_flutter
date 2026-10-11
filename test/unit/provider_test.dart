import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:full_testing_flutter/main.dart';
import 'package:full_testing_flutter/person_form_model.dart';
import 'package:provider/provider.dart';

void main() {
  group('[Provider]', () {
    testWidgets('updates the view when the model submits a person',
        (tester) async {
      final model = PersonFormModel();
      await tester.pumpWidget(MyApp(formModel: model));

      model.submit(name: 'Katherine Johnson', age: '101');
      await tester.pump();

      expect(
          find.text('Submitted: Katherine Johnson, age 101'), findsOneWidget);
      expect(
        Provider.of<PersonFormModel>(
          tester.element(find.byKey(const Key('submissionResult'))),
          listen: false,
        ),
        same(model),
      );
      model.dispose();
    });
  });
}
