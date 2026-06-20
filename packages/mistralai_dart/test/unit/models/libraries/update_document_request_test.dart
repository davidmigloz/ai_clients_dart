import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateDocumentRequest', () {
    test('fromJson parses all fields', () {
      final request = UpdateDocumentRequest.fromJson(const {
        'name': 'doc.pdf',
        'attributes': {'team': 'eng', 'priority': 1},
        'expires_at': '2030-01-01T00:00:00Z',
      });

      expect(request.name, 'doc.pdf');
      expect(request.attributes, {'team': 'eng', 'priority': 1});
      expect(request.expiresAt, '2030-01-01T00:00:00Z');
    });

    test('toJson omits null optionals', () {
      const request = UpdateDocumentRequest(name: 'doc.pdf');

      expect(request.toJson(), {'name': 'doc.pdf'});
    });

    test('toJson round-trips', () {
      const request = UpdateDocumentRequest(
        name: 'doc.pdf',
        attributes: {'team': 'eng'},
        expiresAt: '2030-01-01T00:00:00Z',
      );

      expect(UpdateDocumentRequest.fromJson(request.toJson()), equals(request));
    });

    test('copyWith replaces and clears values', () {
      const request = UpdateDocumentRequest(
        name: 'doc.pdf',
        attributes: {'team': 'eng'},
        expiresAt: '2030-01-01T00:00:00Z',
      );

      expect(request.copyWith(name: 'other.pdf').name, 'other.pdf');
      expect(request.copyWith(attributes: null).attributes, isNull);
      expect(request.copyWith(expiresAt: null).expiresAt, isNull);
      expect(request.copyWith().attributes, {'team': 'eng'});
    });

    test('equality uses deep map comparison', () {
      const a = UpdateDocumentRequest(name: 'doc', attributes: {'k': 'v'});
      const b = UpdateDocumentRequest(name: 'doc', attributes: {'k': 'v'});
      const c = UpdateDocumentRequest(name: 'doc', attributes: {'k': 'x'});

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains key fields', () {
      const request = UpdateDocumentRequest(name: 'doc.pdf');

      expect(request.toString(), contains('doc.pdf'));
    });
  });
}
