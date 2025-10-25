import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/converters.dart';

void main() {
  group('TimestampConverter', () {
    const converter = TimestampConverter();

    test('fromJson returns epoch for null', () {
      final dt = converter.fromJson(null);
      expect(dt.isUtc, isTrue);
      expect(dt.millisecondsSinceEpoch, 0);
    });

    test('fromJson converts DateTime to UTC', () {
      final local = DateTime(2025, 1, 1, 12, 34, 56);
      final dt = converter.fromJson(local);
      expect(dt.isUtc, isTrue);
      expect(dt.toUtc(), local.toUtc());
    });

    test('fromJson parses Firestore map with _seconds/_nanoseconds', () {
      final dt = converter.fromJson({'_seconds': 1704155696, '_nanoseconds': 123000000});
      expect(dt.isUtc, isTrue);
      expect(dt.millisecondsSinceEpoch, 1704155696 * 1000 + 123);
    });

    test('fromJson parses ISO8601 string', () {
      final dt = converter.fromJson('2025-01-01T00:00:00Z');
      expect(dt.isUtc, isTrue);
      expect(dt.toIso8601String(), '2025-01-01T00:00:00.000Z');
    });

    test('toJson always outputs UTC DateTime', () {
      final local = DateTime(2025, 1, 1, 9, 0, 0);
      final json = converter.toJson(local);
      expect(json is DateTime, isTrue);
      final dt = json as DateTime;
      expect(dt.isUtc, isTrue);
      expect(dt, local.toUtc());
    });
  });
}
