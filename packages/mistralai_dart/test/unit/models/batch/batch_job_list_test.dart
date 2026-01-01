import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BatchJobList', () {
    group('fromJson', () {
      test('parses list with jobs', () {
        final json = {
          'object': 'list',
          'data': [
            {
              'id': 'batch-1',
              'input_file_id': 'file-1',
              'endpoint': '/v1/chat/completions',
              'model': 'mistral-small-latest',
              'status': 'QUEUED',
            },
            {
              'id': 'batch-2',
              'input_file_id': 'file-2',
              'endpoint': '/v1/embeddings',
              'model': 'mistral-embed',
              'status': 'SUCCESS',
            },
          ],
          'total': 10,
        };

        final list = BatchJobList.fromJson(json);

        expect(list.object, 'list');
        expect(list.data, hasLength(2));
        expect(list.data[0].id, 'batch-1');
        expect(list.data[1].id, 'batch-2');
        expect(list.total, 10);
      });

      test('parses empty list', () {
        final json = {'object': 'list', 'data': <dynamic>[]};

        final list = BatchJobList.fromJson(json);

        expect(list.object, 'list');
        expect(list.data, isEmpty);
        expect(list.total, isNull);
      });

      test('handles missing data field', () {
        final json = {'object': 'list'};

        final list = BatchJobList.fromJson(json);

        expect(list.data, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes list', () {
        const list = BatchJobList(
          data: [
            BatchJob(
              id: 'batch-1',
              inputFileId: 'file-1',
              endpoint: '/v1/chat/completions',
              model: 'mistral-small-latest',
              status: BatchJobStatus.queued,
            ),
          ],
          total: 5,
        );

        final json = list.toJson();

        expect(json['object'], 'list');
        expect(json['data'], hasLength(1));
        final data = json['data'] as List<Map<String, dynamic>>;
        expect(data.first['id'], 'batch-1');
        expect(json['total'], 5);
      });

      test('omits null total', () {
        const list = BatchJobList(data: []);

        final json = list.toJson();

        expect(json.containsKey('total'), isFalse);
      });
    });

    test('toString returns readable representation', () {
      const list = BatchJobList(
        data: [
          BatchJob(
            id: 'batch-1',
            inputFileId: 'file-1',
            endpoint: '/v1/chat/completions',
            model: 'mistral-small-latest',
            status: BatchJobStatus.queued,
          ),
          BatchJob(
            id: 'batch-2',
            inputFileId: 'file-2',
            endpoint: '/v1/embeddings',
            model: 'mistral-embed',
            status: BatchJobStatus.success,
          ),
        ],
        total: 10,
      );

      expect(list.toString(), contains('count: 2'));
      expect(list.toString(), contains('total: 10'));
    });
  });
}
