import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Eval', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'eval-abc123',
        'created_at': 1614807352,
        'name': 'Test Evaluation',
        'object': 'eval',
        'data_source_config': {
          'type': 'custom',
          'item_schema': {
            'type': 'object',
            'properties': {
              'prompt': {'type': 'string'},
            },
          },
        },
        'testing_criteria': [
          {
            'type': 'string_check',
            'name': 'matches_hello',
            'input': '{{sample.output_text}}',
            'operation': 'ilike',
            'reference': '%hello%',
          },
        ],
        'metadata': {'env': 'test'},
      };

      final eval = Eval.fromJson(json);

      expect(eval.id, 'eval-abc123');
      expect(eval.createdAt, 1614807352);
      expect(eval.name, 'Test Evaluation');
      expect(eval.object, 'eval');
      expect(eval.dataSourceConfig, isA<CustomDataSourceConfig>());
      expect(eval.testingCriteria, hasLength(1));
      expect(eval.testingCriteria.first, isA<StringCheckGrader>());
      expect(eval.metadata, {'env': 'test'});
    });

    test('toJson serializes correctly', () {
      const eval = Eval(
        id: 'eval-abc123',
        createdAt: 1614807352,
        name: 'Test Evaluation',
        object: 'eval',
        dataSourceConfig: CustomDataSourceConfig(
          itemSchema: {'type': 'object'},
        ),
        testingCriteria: [
          StringCheckGrader(
            name: 'check',
            input: '{{sample.output_text}}',
            operation: StringCheckOperation.equals,
            reference: 'test',
          ),
        ],
      );

      final json = eval.toJson();

      expect(json['id'], 'eval-abc123');
      expect(json['created_at'], 1614807352);
      expect(json['name'], 'Test Evaluation');
      expect(
        (json['data_source_config'] as Map<String, dynamic>)['type'],
        'custom',
      );
      expect(json['testing_criteria'], hasLength(1));
    });
  });

  group('EvalList', () {
    test('fromJson parses correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'eval-1',
            'created_at': 1614807352,
            'name': 'Eval 1',
            'object': 'eval',
            'data_source_config': {'type': 'logs'},
            'testing_criteria': <dynamic>[],
          },
        ],
        'has_more': true,
        'first_id': 'eval-1',
        'last_id': 'eval-1',
      };

      final list = EvalList.fromJson(json);

      expect(list.object, 'list');
      expect(list.data, hasLength(1));
      expect(list.hasMore, isTrue);
      expect(list.firstId, 'eval-1');
      expect(list.lastId, 'eval-1');
    });
  });

  group('CreateEvalRequest', () {
    test('toJson serializes correctly', () {
      final request = CreateEvalRequest(
        name: 'My Eval',
        dataSourceConfig: EvalDataSourceConfig.custom(
          itemSchema: {'type': 'object'},
          includeSampleSchema: true,
        ),
        testingCriteria: [
          EvalGrader.stringCheck(
            name: 'check',
            input: '{{sample.output_text}}',
            operation: StringCheckOperation.ilike,
            reference: '%hello%',
          ),
        ],
        metadata: const {'version': '1'},
      );

      final json = request.toJson();

      expect(json['name'], 'My Eval');
      final dataSourceConfig =
          json['data_source_config'] as Map<String, dynamic>;
      expect(dataSourceConfig['type'], 'custom');
      expect(dataSourceConfig['include_sample_schema'], true);
      expect(json['testing_criteria'], hasLength(1));
      expect(json['metadata'], {'version': '1'});
    });
  });

  group('UpdateEvalRequest', () {
    test('toJson serializes correctly', () {
      const request = UpdateEvalRequest(
        name: 'New Name',
        metadata: {'updated': 'true'},
      );

      final json = request.toJson();

      expect(json['name'], 'New Name');
      expect(json['metadata'], {'updated': 'true'});
    });

    test('toJson omits null fields', () {
      const request = UpdateEvalRequest(name: 'New Name');

      final json = request.toJson();

      expect(json['name'], 'New Name');
      expect(json.containsKey('metadata'), isFalse);
    });
  });

  group('DeleteEvalResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'eval_id': 'eval-abc123',
        'object': 'eval.deleted',
        'deleted': true,
      };

      final response = DeleteEvalResponse.fromJson(json);

      expect(response.evalId, 'eval-abc123');
      expect(response.object, 'eval.deleted');
      expect(response.deleted, isTrue);
    });
  });
}
