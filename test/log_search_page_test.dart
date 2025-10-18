import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample/pages/log_search_page.dart';
import 'package:sample/models/pet.dart';

void main() {
  group('LogSearchPage', () {
    testWidgets('should show search field in app bar', (WidgetTester tester) async {
      final testPet = Pet(
        id: 'test-pet',
        name: 'テストペット',
        members: ['user1'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LogSearchPage(pet: testPet),
        ),
      );

      // Check that the search hint text is displayed
      expect(find.text('メモを検索...'), findsOneWidget);
    });

    testWidgets('should show initial search prompt when query is empty', (WidgetTester tester) async {
      final testPet = Pet(
        id: 'test-pet',
        name: 'テストペット',
        members: ['user1'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LogSearchPage(pet: testPet),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check that the initial prompt is shown
      expect(find.text('検索ワードを入力してください'), findsOneWidget);
    });
  });
}
