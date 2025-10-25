import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/providers/statistics_provider.dart';
import 'package:sample/data/repositories/care_log_repository.dart';
import 'package:sample/models/care_log.dart';

void main() {
  testWidgets('petStatisticsProvider computes stats from logs', (tester) async {
    final now = DateTime.now().toUtc();
    final logs = <CareLog>[
      CareLog(
        id: '1',
        petId: 'p1',
        type: CareLogType.walk,
        at: now.subtract(const Duration(days: 3)),
        createdBy: 'u',
        createdAt: now,
      ),
      CareLog(
        id: '2',
        petId: 'p1',
        type: CareLogType.feed,
        at: now.subtract(const Duration(days: 2)),
        createdBy: 'u',
        createdAt: now,
      ),
      CareLog(
        id: '3',
        petId: 'p1',
        type: CareLogType.walk,
        at: now.subtract(const Duration(days: 1)),
        createdBy: 'u',
        createdAt: now,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          petLogsProvider.overrideWith((ref, petId) => Stream.value(logs)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final v = ref.watch(petStatisticsProvider('p1'));
                return v.when(
                  data: (stats) => Column(
                    children: [
                      Text('total:${stats.totalLogs}', key: const Key('total')),
                      Text('walk:${stats.walkCount}', key: const Key('walk')),
                      Text('feed:${stats.feedCount}', key: const Key('feed')),
                      Text('clinic:${stats.clinicCount}', key: const Key('clinic')),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, st) => Text('error:$e'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('total')), findsOneWidget);
    expect(find.text('total:3'), findsOneWidget);
    expect(find.text('walk:2'), findsOneWidget);
    expect(find.text('feed:1'), findsOneWidget);
    expect(find.text('clinic:0'), findsOneWidget);
  });
}
