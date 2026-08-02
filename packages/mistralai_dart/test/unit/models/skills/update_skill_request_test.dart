import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateSkillRequest', () {
    group('toJson', () {
      test('serializes sharingScope', () {
        const request = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.workspace,
        );

        expect(request.toJson(), {'sharingScope': 'workspace'});
      });

      test('omits sharingScope when null', () {
        const request = UpdateSkillRequest();

        expect(request.toJson(), <String, dynamic>{});
      });
    });

    group('copyWith', () {
      test('replaces sharingScope', () {
        const original = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.private,
        );

        final copy = original.copyWith(
          sharingScope: RegistrySharingScope.workspace,
        );

        expect(copy.sharingScope, RegistrySharingScope.workspace);
      });

      test('clears sharingScope when null is passed explicitly', () {
        const original = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.private,
        );

        final copy = original.copyWith(sharingScope: null);

        expect(copy.sharingScope, isNull);
      });

      test('preserves sharingScope when not specified', () {
        const original = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.private,
        );

        expect(original.copyWith(), equals(original));
      });
    });

    group('equality', () {
      test('equal when sharingScope matches', () {
        const a = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.private,
        );
        const b = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.private,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when sharingScope differs', () {
        const a = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.private,
        );
        const b = UpdateSkillRequest(
          sharingScope: RegistrySharingScope.workspace,
        );

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes sharingScope', () {
      const request = UpdateSkillRequest(
        sharingScope: RegistrySharingScope.workspace,
      );

      expect(request.toString(), contains('UpdateSkillRequest'));
      expect(request.toString(), contains('workspace'));
    });
  });
}
