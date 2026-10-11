import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:full_testing_flutter/person_form_model.dart';

class PersonFormView extends StatefulWidget {
  const PersonFormView({super.key});

  @override
  State<PersonFormView> createState() => _PersonFormViewState();
}

class _PersonFormViewState extends State<PersonFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<PersonFormModel>().submit(
          name: _nameController.text,
          age: _ageController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Person details')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('nameField'),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('ageField'),
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final age = int.tryParse(value?.trim() ?? '');
                      if (age == null || age <= 0) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('submitButton'),
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 16),
                  Consumer<PersonFormModel>(
                    builder: (context, model, _) {
                      final submission = model.submission;
                      if (submission == null) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        'Submitted: ${submission.name}, age ${submission.age}',
                        key: const Key('submissionResult'),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
