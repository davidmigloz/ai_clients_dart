import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AuthToken', () {
    test('creates with required fields', () {
      const token = AuthToken();
      expect(token.name, isNull);
      expect(token.expireTime, isNull);
      expect(token.newSessionExpireTime, isNull);
      expect(token.uses, isNull);
      expect(token.bidiGenerateContentSetup, isNull);
      expect(token.fieldMask, isNull);
      expect(token.interactionId, isNull);
    });

    test('creates with all fields', () {
      final expireTime = DateTime.utc(2026, 1, 1);
      final newSessionExpireTime = DateTime.utc(2026, 1, 1, 0, 1);
      final token = AuthToken(
        name: 'auth-tokens/abc123',
        expireTime: expireTime,
        newSessionExpireTime: newSessionExpireTime,
        uses: 1,
        fieldMask: 'model',
        interactionId: 'interactions/xyz789',
      );
      expect(token.name, 'auth-tokens/abc123');
      expect(token.expireTime, expireTime);
      expect(token.newSessionExpireTime, newSessionExpireTime);
      expect(token.uses, 1);
      expect(token.fieldMask, 'model');
      expect(token.interactionId, 'interactions/xyz789');
    });

    test('serializes to JSON', () {
      final expireTime = DateTime.utc(2026, 1, 1);
      final token = AuthToken(
        expireTime: expireTime,
        uses: 1,
        interactionId: 'interactions/xyz789',
      );
      final json = token.toJson();
      expect(json['expireTime'], expireTime.toIso8601String());
      expect(json['uses'], 1);
      expect(json['interactionId'], 'interactions/xyz789');
    });

    test('omits null fields from JSON', () {
      const token = AuthToken();
      final json = token.toJson();
      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('expireTime'), isFalse);
      expect(json.containsKey('newSessionExpireTime'), isFalse);
      expect(json.containsKey('uses'), isFalse);
      expect(json.containsKey('bidiGenerateContentSetup'), isFalse);
      expect(json.containsKey('fieldMask'), isFalse);
      expect(json.containsKey('interactionId'), isFalse);
    });

    test('deserializes from JSON', () {
      final json = {
        'name': 'auth-tokens/abc123',
        'expireTime': '2026-01-01T00:00:00.000Z',
        'uses': 1,
        'interactionId': 'interactions/xyz789',
      };
      final token = AuthToken.fromJson(json);
      expect(token.name, 'auth-tokens/abc123');
      expect(token.expireTime, DateTime.utc(2026, 1, 1));
      expect(token.uses, 1);
      expect(token.interactionId, 'interactions/xyz789');
    });

    test('roundtrip serialization', () {
      final original = AuthToken(
        name: 'auth-tokens/abc123',
        expireTime: DateTime.utc(2026, 1, 1),
        uses: 1,
        interactionId: 'interactions/xyz789',
      );
      final json = original.toJson();
      final restored = AuthToken.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.expireTime, original.expireTime);
      expect(restored.uses, original.uses);
      expect(restored.interactionId, original.interactionId);
    });

    test('copyWith replaces values', () {
      const original = AuthToken(interactionId: 'interactions/old');
      final copy = original.copyWith(interactionId: 'interactions/new');
      expect(copy.interactionId, 'interactions/new');
    });

    test('copyWith preserves values by default', () {
      const original = AuthToken(uses: 1, interactionId: 'interactions/keep');
      final copy = original.copyWith();
      expect(copy.uses, original.uses);
      expect(copy.interactionId, original.interactionId);
    });

    test('== and hashCode reflect interactionId differences', () {
      const a = AuthToken(name: 'auth-tokens/abc', interactionId: 'i-1');
      const b = AuthToken(name: 'auth-tokens/abc', interactionId: 'i-1');
      const c = AuthToken(name: 'auth-tokens/abc', interactionId: 'i-2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('toString contains interactionId', () {
      const token = AuthToken(interactionId: 'interactions/xyz789');
      expect(token.toString(), contains('interactions/xyz789'));
    });
  });
}
