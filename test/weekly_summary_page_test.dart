import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/pages/weekly_summary_page.dart';
import 'package:sample/models/pet.dart';
import 'package:sample/data/repositories/care_log_repository.dart';

void main() {
  group('WeeklySummaryPage', () {
    testWidgets('should show title', (WidgetTester tester) async {
      final testPet = Pet(
        id: 'test-pet',
        name: 'テストペット',
        members: ['user1'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            petLogsProvider.overrideWith((ref, petId) => Stream.value(const [])),
          ],
          child: MaterialApp(
            home: WeeklySummaryPage(pet: testPet),
          ),
        ),
      );

      // Check that the title is displayed
      expect(find.text('週間サマリー'), findsOneWidget);
    });
  });
}
