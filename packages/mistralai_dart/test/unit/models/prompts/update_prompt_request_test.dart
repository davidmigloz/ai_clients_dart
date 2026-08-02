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

      test('emits explicit null when clearX flags are set', () {
        const request = UpdatePromptRequest(
          clearDescription: true,
          clearTitle: true,
          clearSharingScope: true,
        );

        expect(request.toJson(), {
          'description': null,
          'title': null,
          'sharingScope': null,
        });
      });
    });

    group('constructor', () {
      test('asserts when a clearX flag and its value are both set', () {
        expect(
          () => UpdatePromptRequest(description: 'x', clearDescription: true),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => UpdatePromptRequest(title: 'x', clearTitle: true),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => UpdatePromptRequest(
            sharingScope: RegistrySharingScope.workspace,
            clearSharingScope: true,
          ),
          throwsA(isA<AssertionError>()),
        );
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

      test('clearX: true clears the field and resets the value', () {
        const original = UpdatePromptRequest(description: 'a');

        final cleared = original.copyWith(clearDescription: true);

        expect(cleared.description, isNull);
        expect(cleared.clearDescription, isTrue);
        expect(cleared.toJson(), {'description': null});
      });

      test('a new non-null value resets the clearX flag', () {
        const original = UpdatePromptRequest(clearDescription: true);

        final replaced = original.copyWith(description: 'b');

        expect(replaced.description, 'b');
        expect(replaced.clearDescription, isFalse);
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
