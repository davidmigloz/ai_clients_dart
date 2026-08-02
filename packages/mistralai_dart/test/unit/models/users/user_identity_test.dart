import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UserIdentity', () {
    final fullJson = {
      'id': 'user-1',
      'email': 'user@example.com',
      'first_name': 'Ada',
      'last_name': 'Lovelace',
      'api_key': {'id': 'key-1', 'name': 'My Key'},
      'organization': {'id': 'org-1', 'name': 'Acme'},
      'workspace': {'id': 'ws-1', 'name': 'Main'},
    };

    group('fromJson', () {
      test('parses all fields', () {
        final identity = UserIdentity.fromJson(fullJson);

        expect(identity.id, 'user-1');
        expect(identity.email, 'user@example.com');
        expect(identity.firstName, 'Ada');
        expect(identity.lastName, 'Lovelace');
        expect(
          identity.apiKey,
          const UserIdentityApiKey(id: 'key-1', name: 'My Key'),
        );
        expect(
          identity.organization,
          const UserIdentityOrganization(id: 'org-1', name: 'Acme'),
        );
        expect(
          identity.workspace,
          const UserIdentityWorkspace(id: 'ws-1', name: 'Main'),
        );
      });

      test('parses required-but-nullable fields as null', () {
        final identity = UserIdentity.fromJson(const {
          'id': 'user-1',
          'email': null,
          'first_name': null,
          'last_name': null,
        });

        expect(identity.email, isNull);
        expect(identity.firstName, isNull);
        expect(identity.lastName, isNull);
        expect(identity.apiKey, isNull);
      });

      test('throws FormatException when id missing', () {
        expect(
          () => UserIdentity.fromJson(const {'email': 'a@b.com'}),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final identity = UserIdentity.fromJson(fullJson);

        expect(identity.toJson(), fullJson);
      });

      test('always includes required-but-nullable fields, even when null', () {
        const identity = UserIdentity(
          id: 'u1',
          email: null,
          firstName: null,
          lastName: null,
        );

        expect(identity.toJson(), {
          'id': 'u1',
          'email': null,
          'first_name': null,
          'last_name': null,
        });
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves data', () {
        final original = UserIdentity.fromJson(fullJson);

        final roundTripped = UserIdentity.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = UserIdentity(
          id: 'u1',
          email: 'a@b.com',
          firstName: 'A',
          lastName: 'B',
        );

        final copy = original.copyWith(email: 'c@d.com');

        expect(copy.email, 'c@d.com');
        expect(copy.id, 'u1');
      });

      test('clears nullable fields when null is passed explicitly', () {
        const original = UserIdentity(
          id: 'u1',
          email: 'a@b.com',
          firstName: 'A',
          lastName: 'B',
        );

        final copy = original.copyWith(email: null);

        expect(copy.email, isNull);
      });

      test('preserves fields when not specified', () {
        const original = UserIdentity(
          id: 'u1',
          email: 'a@b.com',
          firstName: 'A',
          lastName: 'B',
        );

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = UserIdentity.fromJson(fullJson);
        final b = UserIdentity.fromJson(fullJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when id differs', () {
        const a = UserIdentity(
          id: 'u1',
          email: null,
          firstName: null,
          lastName: null,
        );
        const b = UserIdentity(
          id: 'u2',
          email: null,
          firstName: null,
          lastName: null,
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes id and email', () {
      final identity = UserIdentity.fromJson(fullJson);

      expect(identity.toString(), contains('UserIdentity'));
      expect(identity.toString(), contains('user-1'));
      expect(identity.toString(), contains('user@example.com'));
    });
  });

  group('UserIdentityApiKey', () {
    group('fromJson', () {
      test('parses fields', () {
        final apiKey = UserIdentityApiKey.fromJson(const {
          'id': 'key-1',
          'name': 'My Key',
        });

        expect(apiKey.id, 'key-1');
        expect(apiKey.name, 'My Key');
      });

      test('parses null name', () {
        final apiKey = UserIdentityApiKey.fromJson(const {
          'id': 'key-1',
          'name': null,
        });

        expect(apiKey.name, isNull);
      });

      test('throws FormatException when id missing', () {
        expect(
          () => UserIdentityApiKey.fromJson(const {'name': 'x'}),
          throwsFormatException,
        );
      });
    });

    test('toJson serializes fields, including a null name', () {
      const apiKey = UserIdentityApiKey(id: 'key-1', name: null);

      expect(apiKey.toJson(), {'id': 'key-1', 'name': null});
    });

    group('copyWith', () {
      test('clears name when null is passed explicitly', () {
        const original = UserIdentityApiKey(id: 'key-1', name: 'My Key');

        final copy = original.copyWith(name: null);

        expect(copy.name, isNull);
      });

      test('preserves fields when not specified', () {
        const original = UserIdentityApiKey(id: 'key-1', name: 'My Key');

        expect(original.copyWith(), equals(original));
      });
    });

    test('equality and hashCode', () {
      const a = UserIdentityApiKey(id: 'key-1', name: 'My Key');
      const b = UserIdentityApiKey(id: 'key-1', name: 'My Key');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('UserIdentityOrganization', () {
    test('round-trips', () {
      const original = UserIdentityOrganization(id: 'org-1', name: 'Acme');

      final roundTripped = UserIdentityOrganization.fromJson(original.toJson());

      expect(roundTripped, equals(original));
    });

    test('throws FormatException when fields missing', () {
      expect(
        () => UserIdentityOrganization.fromJson(const {'id': 'org-1'}),
        throwsFormatException,
      );
    });
  });

  group('UserIdentityWorkspace', () {
    test('round-trips', () {
      const original = UserIdentityWorkspace(id: 'ws-1', name: 'Main');

      final roundTripped = UserIdentityWorkspace.fromJson(original.toJson());

      expect(roundTripped, equals(original));
    });

    test('throws FormatException when fields missing', () {
      expect(
        () => UserIdentityWorkspace.fromJson(const {'id': 'ws-1'}),
        throwsFormatException,
      );
    });
  });
}
