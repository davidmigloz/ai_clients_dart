import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DeleteBatchJobResponse', () {
    test('fromJson parses all fields', () {
      final response = DeleteBatchJobResponse.fromJson(const {
        'id': 'batch-123',
        'deleted': true,
        'object': 'batch.deleted',
      });

      expect(response.id, 'batch-123');
      expect(response.deleted, isTrue);
      expect(response.object, 'batch.deleted');
    });

    test('fromJson parses minimal payload', () {
      final response = DeleteBatchJobResponse.fromJson(const {'id': 'batch-1'});

      expect(response.id, 'batch-1');
      expect(response.deleted, isNull);
      expect(response.object, isNull);
    });

    test('toJson omits null optionals', () {
      const response = DeleteBatchJobResponse(id: 'batch-1');

      expect(response.toJson(), {'id': 'batch-1'});
    });

    test('toJson round-trips full payload', () {
      const response = DeleteBatchJobResponse(
        id: 'batch-9',
        deleted: false,
        object: 'batch.deleted',
      );

      expect(
        DeleteBatchJobResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith replaces and clears values', () {
      const response = DeleteBatchJobResponse(
        id: 'batch-1',
        deleted: true,
        object: 'batch.deleted',
      );

      expect(response.copyWith(id: 'batch-2').id, 'batch-2');
      expect(response.copyWith(deleted: null).deleted, isNull);
      expect(response.copyWith().deleted, isTrue);
    });

    test('equality and hashCode', () {
      const a = DeleteBatchJobResponse(id: 'batch-1', deleted: true);
      const b = DeleteBatchJobResponse(id: 'batch-1', deleted: true);
      const c = DeleteBatchJobResponse(id: 'batch-1', deleted: false);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains key fields', () {
      const response = DeleteBatchJobResponse(id: 'batch-1', deleted: true);

      expect(response.toString(), contains('batch-1'));
      expect(response.toString(), contains('deleted: true'));
    });
  });
}
