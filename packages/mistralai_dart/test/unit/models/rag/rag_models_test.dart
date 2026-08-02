@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IngestionPipelineConfiguration model', () {
    final json = {
      'id': 'cfg-1',
      'author_id': 'author-1',
      'name': 'My pipeline',
      'created_at': '2024-01-01T00:00:00.000Z',
      'modified_at': '2024-01-02T00:00:00.000Z',
      'last_run_time': '2024-01-03T00:00:00.000Z',
      'last_run_chunks_count': 10,
      'total_chunks_count': 42,
      'pipeline_composition': {'stage': 'component'},
    };

    test('round-trips through JSON', () {
      final config = IngestionPipelineConfiguration.fromJson(json);
      expect(config.id, 'cfg-1');
      expect(config.authorId, 'author-1');
      expect(config.name, 'My pipeline');
      expect(config.lastRunTime, DateTime.utc(2024, 1, 3));
      expect(config.lastRunChunksCount, 10);
      expect(config.totalChunksCount, 42);
      expect(config.pipelineComposition, {'stage': 'component'});

      final back = config.toJson();
      expect(back['id'], 'cfg-1');
      expect(back['last_run_chunks_count'], 10);
      expect(back['pipeline_composition'], {'stage': 'component'});
    });

    test('handles null last_run_time and pipeline_composition', () {
      final config = IngestionPipelineConfiguration.fromJson({
        ...json,
        'last_run_time': null,
        'pipeline_composition': null,
      });
      expect(config.lastRunTime, isNull);
      expect(config.pipelineComposition, isNull);

      final back = config.toJson();
      expect(back['last_run_time'], isNull);
      expect(back['pipeline_composition'], isNull);
    });

    test('equality and copyWith are value-based', () {
      final config = IngestionPipelineConfiguration.fromJson(json);
      expect(IngestionPipelineConfiguration.fromJson(json), config);
      expect(
        IngestionPipelineConfiguration.fromJson(json).hashCode,
        config.hashCode,
      );
      expect(config.copyWith(name: 'Renamed').name, 'Renamed');
      expect(config.copyWith(lastRunTime: null).lastRunTime, isNull);
      expect(config.copyWith().lastRunTime, config.lastRunTime);
    });
  });

  group('CreateIngestionPipelineConfigurationRequest model', () {
    test('omits null pipeline_composition in JSON', () {
      const request = CreateIngestionPipelineConfigurationRequest(
        name: 'My pipeline',
      );
      expect(request.toJson(), {'name': 'My pipeline'});

      final round = CreateIngestionPipelineConfigurationRequest.fromJson(const {
        'name': 'My pipeline',
        'pipeline_composition': {'a': 'b'},
      });
      expect(round.pipelineComposition, {'a': 'b'});
      expect(round.toJson()['pipeline_composition'], {'a': 'b'});
    });
  });

  group('UpdateRunInfo model', () {
    test('round-trips through JSON', () {
      final parsed = UpdateRunInfo.fromJson(const {
        'execution_time': '2024-01-01T00:00:00.000Z',
        'chunks_count': 7,
      });
      expect(parsed.executionTime, DateTime.utc(2024, 1, 1));
      expect(parsed.chunksCount, 7);
      expect(parsed.toJson(), {
        'execution_time': '2024-01-01T00:00:00.000Z',
        'chunks_count': 7,
      });
      expect(parsed.copyWith(chunksCount: 5).chunksCount, 5);
    });
  });

  group('SearchIndexStatus enum', () {
    test('maps values both ways', () {
      expect(SearchIndexStatus.fromJson('online'), SearchIndexStatus.online);
      expect(SearchIndexStatus.fromJson('offline'), SearchIndexStatus.offline);
      expect(SearchIndexStatus.fromJson(null), SearchIndexStatus.unknown);
      expect(SearchIndexStatus.fromJson('???'), SearchIndexStatus.unknown);
      expect(SearchIndexStatus.online.toJson(), 'online');
    });
  });
}
