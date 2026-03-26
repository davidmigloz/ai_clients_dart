import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RunningModel', () {
    final fullJson = {
      'name': 'llama3.2:latest',
      'model': 'llama3.2:latest',
      'size': 5137025024,
      'digest':
          'a80c4f17acd55265feec403c7aef86be0c25983ab279d83f3bcd3a735f1a4e70',
      'details': {
        'format': 'gguf',
        'family': 'llama',
        'parameter_size': '3.2B',
        'quantization_level': 'Q4_0',
      },
      'expires_at': '2024-06-04T14:38:31.83753-07:00',
      'size_vram': 5137025024,
      'context_length': 8192,
    };

    test('fromJson parses all fields', () {
      final model = RunningModel.fromJson(fullJson);

      expect(model.name, 'llama3.2:latest');
      expect(model.model, 'llama3.2:latest');
      expect(model.size, 5137025024);
      expect(model.digest, startsWith('a80c4f17'));
      expect(model.details, isA<Map<String, dynamic>>());
      expect(model.details!['family'], 'llama');
      expect(model.expiresAt, '2024-06-04T14:38:31.83753-07:00');
      expect(model.sizeVram, 5137025024);
      expect(model.contextLength, 8192);
    });

    test('fromJson handles missing fields', () {
      final model = RunningModel.fromJson(const {'model': 'llama3.2:latest'});

      expect(model.name, isNull);
      expect(model.model, 'llama3.2:latest');
      expect(model.size, isNull);
      expect(model.digest, isNull);
      expect(model.details, isNull);
      expect(model.expiresAt, isNull);
      expect(model.sizeVram, isNull);
      expect(model.contextLength, isNull);
    });

    test('toJson round-trips correctly', () {
      final model = RunningModel.fromJson(fullJson);
      final json = model.toJson();

      expect(json['name'], 'llama3.2:latest');
      expect(json['model'], 'llama3.2:latest');
      expect(json['size'], 5137025024);
      expect(json['digest'], fullJson['digest']);
      expect(json['details'], fullJson['details']);
      expect(json['expires_at'], fullJson['expires_at']);
      expect(json['size_vram'], 5137025024);
      expect(json['context_length'], 8192);
    });

    test('toJson omits null fields', () {
      const model = RunningModel(model: 'llama3.2:latest');
      final json = model.toJson();

      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('model'), isTrue);
      expect(json.containsKey('size'), isFalse);
      expect(json.containsKey('details'), isFalse);
    });

    test('equality compares all fields', () {
      final model1 = RunningModel.fromJson(fullJson);
      final model2 = RunningModel.fromJson(fullJson);

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('equality detects name difference', () {
      final model1 = RunningModel.fromJson(fullJson);
      final model2 = model1.copyWith(name: 'other:latest');

      expect(model1, isNot(equals(model2)));
    });

    test('copyWith replaces fields selectively', () {
      final original = RunningModel.fromJson(fullJson);
      final copied = original.copyWith(
        name: 'other:latest',
        contextLength: 4096,
      );

      expect(copied.name, 'other:latest');
      expect(copied.contextLength, 4096);
      expect(copied.model, original.model);
      expect(copied.size, original.size);
    });

    test('copyWith can set fields to null', () {
      final original = RunningModel.fromJson(fullJson);
      final copied = original.copyWith(name: null, sizeVram: null);

      expect(copied.name, isNull);
      expect(copied.sizeVram, isNull);
      expect(copied.model, original.model);
    });

    test('toString includes all fields', () {
      final model = RunningModel.fromJson(fullJson);
      final str = model.toString();

      expect(str, contains('name:'));
      expect(str, contains('model:'));
      expect(str, contains('size:'));
      expect(str, contains('digest:'));
      expect(str, contains('details:'));
      expect(str, contains('expiresAt:'));
      expect(str, contains('sizeVram:'));
      expect(str, contains('contextLength:'));
    });
  });

  group('PsResponse', () {
    test('fromJson parses models list', () {
      final json = {
        'models': [
          {'name': 'llama3.2:latest', 'model': 'llama3.2:latest', 'size': 100},
          {
            'name': 'codellama:latest',
            'model': 'codellama:latest',
            'size': 200,
          },
        ],
      };

      final response = PsResponse.fromJson(json);

      expect(response.models, hasLength(2));
      expect(response.models![0].name, 'llama3.2:latest');
      expect(response.models![1].name, 'codellama:latest');
    });

    test('fromJson handles empty models list', () {
      final response = PsResponse.fromJson(const {'models': <dynamic>[]});

      expect(response.models, isEmpty);
    });

    test('fromJson handles missing models key', () {
      final response = PsResponse.fromJson(const <String, dynamic>{});

      expect(response.models, isNull);
    });

    test('equality compares models list by content', () {
      const response1 = PsResponse(
        models: [
          RunningModel(model: 'a'),
          RunningModel(model: 'b'),
        ],
      );
      const response2 = PsResponse(
        models: [
          RunningModel(model: 'a'),
          RunningModel(model: 'b'),
        ],
      );
      const response3 = PsResponse(
        models: [
          RunningModel(model: 'a'),
          RunningModel(model: 'c'),
        ],
      );

      expect(response1, equals(response2));
      expect(response1.hashCode, equals(response2.hashCode));
      expect(response1, isNot(equals(response3)));
    });
  });
}
