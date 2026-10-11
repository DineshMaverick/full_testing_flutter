import 'package:flutter/foundation.dart';

class PersonSubmission {
  final String name;
  final int age;

  const PersonSubmission({required this.name, required this.age});
}

class PersonFormModel extends ChangeNotifier {
  PersonSubmission? _submission;

  PersonSubmission? get submission => _submission;

  bool submit({required String name, required String age}) {
    final normalizedName = name.trim();
    final parsedAge = int.tryParse(age.trim());

    if (normalizedName.isEmpty || parsedAge == null || parsedAge <= 0) {
      return false;
    }

    _submission = PersonSubmission(name: normalizedName, age: parsedAge);
    notifyListeners();
    return true;
  }
}
