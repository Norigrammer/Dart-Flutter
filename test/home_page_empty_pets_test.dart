import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sample/pages/home_page.dart';
import 'package:sample/data/repositories/pet_repository.dart';

void main() {
  testWidgets('ペットが空の場合 空表示メッセージが出る', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myPetsStreamProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    // 初期 build
    await tester.pump();

    expect(find.text('まだペットが登録されていません'), findsOneWidget);
  });
}
