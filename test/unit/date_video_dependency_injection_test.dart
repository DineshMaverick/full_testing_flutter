import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('[Date/video dependency injection]', () {
    testWidgets(
        'selecting a date initializes and automatically plays its video',
        (tester) async {
      final dateSelection = _DateSelectionModel();
      final videoContainer = _FakeVideoContainer();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<_DateSelectionModel>.value(
              value: dateSelection,
            ),
            Provider<_FakeVideoContainer>.value(value: videoContainer),
          ],
          child: const MaterialApp(home: _DateVideoView()),
        ),
      );

      await tester.tap(find.byKey(const Key('selectDateButton')));
      await tester.pumpAndSettle();

      final selectedDate = DateTime(2026, 10, 13);
      expect(dateSelection.selectedDate, selectedDate);
      expect(videoContainer.initializedDate, selectedDate);
      expect(videoContainer.events, ['initialize', 'play']);
      expect(find.text('Playing video for 2026-10-13'), findsOneWidget);

      dateSelection.dispose();
    });
  });
}

class _DateSelectionModel extends ChangeNotifier {
  DateTime? selectedDate;

  void select(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }
}

class _FakeVideoContainer {
  final List<String> events = [];
  DateTime? initializedDate;

  Future<void> initialize(DateTime date) async {
    initializedDate = date;
    events.add('initialize');
  }

  Future<void> play() async {
    events.add('play');
  }
}

class _DateVideoView extends StatelessWidget {
  const _DateVideoView();

  @override
  Widget build(BuildContext context) {
    final selectedDate = context
        .select<_DateSelectionModel, DateTime?>((model) => model.selectedDate);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            key: const Key('selectDateButton'),
            onPressed: () async {
              final date = DateTime(2026, 10, 13);
              context.read<_DateSelectionModel>().select(date);

              final videoContainer = context.read<_FakeVideoContainer>();
              await videoContainer.initialize(date);
              await videoContainer.play();
            },
            child: const Text('Select date'),
          ),
          if (selectedDate != null)
            Text(
              'Playing video for ${selectedDate.year}-'
              '${selectedDate.month.toString().padLeft(2, '0')}-'
              '${selectedDate.day.toString().padLeft(2, '0')}',
            ),
        ],
      ),
    );
  }
}
