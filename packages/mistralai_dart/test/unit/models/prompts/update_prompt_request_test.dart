import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UpdatePromptRequest', () {
    group('toJson', () {
      test('serializes all fields', () {
        const request = UpdatePromptRequest(
          description: 'new desc',
          title: 'new title',
          sharingScope: RegistrySharingScope.workspace,
        );

        expect(request.toJson(), {
          'description': 'new desc',
          'title': 'new title',
          'sharingScope': 'workspace',
        });
      });

      test('omits fields when null', () {
        const request = UpdatePromptRequest();

        expect(request.toJson(), <String, dynamic>{});
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = UpdatePromptRequest(description: 'a');

        final copy = original.copyWith(description: 'b');

        expect(copy.description, 'b');
      });

      test('clears fields when null is passed explicitly', () {
        const original = UpdatePromptRequest(title: 'a');

        final copy = original.copyWith(title: null);

        expect(copy.title, isNull);
      });

      test('preserves fields when not specified', () {
        const original = UpdatePromptRequest(description: 'a');

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = UpdatePromptRequest(description: 'a');
        const b = UpdatePromptRequest(description: 'a');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when description differs', () {
        const a = UpdatePromptRequest(description: 'a');
        const b = UpdatePromptRequest(description: 'b');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes fields', () {
      const request = UpdatePromptRequest(title: 'title');

      expect(request.toString(), contains('UpdatePromptRequest'));
      expect(request.toString(), contains('title'));
    });
  });
}
