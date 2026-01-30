import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EvalDataSourceConfig', () {
    test('fromJson parses custom type', () {
      final json = {
        'type': 'custom',
        'item_schema': {
          'type': 'object',
          'properties': {
            'prompt': {'type': 'string'},
          },
        },
        'include_sample_schema': true,
      };

      final config = EvalDataSourceConfig.fromJson(json);

      expect(config, isA<CustomDataSourceConfig>());
      final custom = config as CustomDataSourceConfig;
      expect(custom.type, 'custom');
      expect(custom.itemSchema!['type'], 'object');
      expect(custom.includeSampleSchema, true);
    });

    test('fromJson parses logs type', () {
      final json = {
        'type': 'logs',
        'schema': {'type': 'object'},
        'metadata': {'env': 'prod'},
      };

      final config = EvalDataSourceConfig.fromJson(json);

      expect(config, isA<LogsDataSourceConfig>());
      final logs = config as LogsDataSourceConfig;
      expect(logs.type, 'logs');
      expect(logs.schema, {'type': 'object'});
      expect(logs.metadata, {'env': 'prod'});
    });

    test('fromJson throws on unknown type', () {
      final json = {'type': 'unknown'};

      expect(
        () => EvalDataSourceConfig.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('CustomDataSourceConfig', () {
    test('static factory creates correctly', () {
      final config = EvalDataSourceConfig.custom(
        itemSchema: {'type': 'object'},
        includeSampleSchema: true,
      );

      expect(config.type, 'custom');
      expect(config.itemSchema, {'type': 'object'});
      expect(config.includeSampleSchema, true);
    });

    test('toJson serializes correctly', () {
      const config = CustomDataSourceConfig(
        itemSchema: {'type': 'object'},
        includeSampleSchema: true,
      );

      final json = config.toJson();

      expect(json['type'], 'custom');
      expect(json['item_schema'], {'type': 'object'});
      expect(json['include_sample_schema'], true);
    });

    test('toJson omits null includeSampleSchema', () {
      const config = CustomDataSourceConfig(itemSchema: {'type': 'object'});

      final json = config.toJson();

      expect(json.containsKey('include_sample_schema'), isFalse);
    });
  });

  group('LogsDataSourceConfig', () {
    test('static factory creates correctly', () {
      final config = EvalDataSourceConfig.logs(
        schema: {'type': 'object'},
        metadata: {'env': 'test'},
      );

      expect(config.type, 'logs');
      expect(config.schema, {'type': 'object'});
      expect(config.metadata, {'env': 'test'});
    });

    test('toJson serializes correctly', () {
      const config = LogsDataSourceConfig(
        schema: {'type': 'object'},
        metadata: {'key': 'value'},
      );

      final json = config.toJson();

      expect(json['type'], 'logs');
      expect(json['schema'], {'type': 'object'});
      expect(json['metadata'], {'key': 'value'});
    });

    test('toJson omits null fields', () {
      const config = LogsDataSourceConfig();

      final json = config.toJson();

      expect(json['type'], 'logs');
      expect(json.containsKey('schema'), isFalse);
      expect(json.containsKey('metadata'), isFalse);
    });
  });
}
