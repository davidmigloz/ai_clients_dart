import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateLibraryRequest', () {
    test('fromJson parses fields', () {
      final request = UpdateLibraryRequest.fromJson(const {
        'name': 'My Library',
        'description': 'A description',
      });

      expect(request.name, 'My Library');
      expect(request.description, 'A description');
    });

    test('toJson omits null description', () {
      const request = UpdateLibraryRequest(name: 'My Library');

      expect(request.toJson(), {'name': 'My Library'});
    });

    test('supports description-only update (name omitted)', () {
      const request = UpdateLibraryRequest(description: 'New description');

      expect(request.name, isNull);
      expect(request.toJson(), {'description': 'New description'});
    });

    test('clearDescription emits an explicit null', () {
      const request = UpdateLibraryRequest(clearDescription: true);

      expect(request.toJson(), {'description': null});
    });

    test('fromJson distinguishes explicit null from absent', () {
      final cleared = UpdateLibraryRequest.fromJson(const {
        'description': null,
      });
      expect(cleared.description, isNull);
      expect(cleared.clearDescription, isTrue);
      expect(cleared.toJson(), {'description': null});

      final absent = UpdateLibraryRequest.fromJson(const {'name': 'L'});
      expect(absent.clearDescription, isFalse);
      expect(absent.toJson(), {'name': 'L'});
    });

    test('toJson round-trips', () {
      const request = UpdateLibraryRequest(name: 'Lib', description: 'Desc');

      expect(UpdateLibraryRequest.fromJson(request.toJson()), equals(request));
    });

    test('copyWith replaces and clears values', () {
      const request = UpdateLibraryRequest(name: 'Lib', description: 'Desc');

      expect(request.copyWith(name: 'Other').name, 'Other');
      expect(request.copyWith(description: null).description, isNull);
      expect(request.copyWith().description, 'Desc');
    });

    test('equality and hashCode', () {
      const a = UpdateLibraryRequest(name: 'Lib', description: 'Desc');
      const b = UpdateLibraryRequest(name: 'Lib', description: 'Desc');
      const c = UpdateLibraryRequest(name: 'Lib');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains key fields', () {
      const request = UpdateLibraryRequest(name: 'Lib', description: 'Desc');

      expect(request.toString(), contains('Lib'));
      expect(request.toString(), contains('Desc'));
    });
  });
}
