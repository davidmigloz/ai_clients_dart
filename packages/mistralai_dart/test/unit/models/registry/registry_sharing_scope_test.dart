import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RegistrySharingScope', () {
    group('fromString', () {
      test('parses known values', () {
        expect(
          RegistrySharingScope.fromString('sharing_scope_unspecified'),
          RegistrySharingScope.sharingScopeUnspecified,
        );
        expect(
          RegistrySharingScope.fromString('private'),
          RegistrySharingScope.private,
        );
        expect(
          RegistrySharingScope.fromString('workspace'),
          RegistrySharingScope.workspace,
        );
      });

      test('returns null for null input', () {
        expect(RegistrySharingScope.fromString(null), isNull);
      });

      test('returns unknown for an unrecognized value', () {
        expect(
          RegistrySharingScope.fromString('something_new'),
          RegistrySharingScope.unknown,
        );
      });
    });

    test('value returns the wire string', () {
      expect(RegistrySharingScope.workspace.value, 'workspace');
    });
  });
}
