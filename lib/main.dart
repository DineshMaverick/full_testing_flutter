import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:full_testing_flutter/person_form_model.dart';
import 'package:full_testing_flutter/person_form_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  final PersonFormModel? formModel;

  const MyApp({super.key, this.formModel});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Person form',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PersonFormView(),
    );

    if (formModel case final formModel?) {
      return ChangeNotifierProvider<PersonFormModel>.value(
        value: formModel,
        child: app,
      );
    }

    return ChangeNotifierProvider<PersonFormModel>(
      create: (_) => PersonFormModel(),
      child: app,
    );
  }
}
