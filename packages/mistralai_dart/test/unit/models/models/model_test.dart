import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Model', () {
    group('constructor', () {
      test('creates with required fields', () {
        const model = Model(id: 'mistral-small', object: 'model');

        expect(model.id, 'mistral-small');
        expect(model.object, 'model');
        expect(model.created, isNull);
        expect(model.ownedBy, isNull);
        expect(model.name, isNull);
        expect(model.description, isNull);
        expect(model.maxContextLength, isNull);
        expect(model.aliases, isNull);
        expect(model.defaultModelTemperature, isNull);
        expect(model.type, isNull);
        expect(model.capabilities, const ModelCapabilities());
      });

      test('creates with all fields', () {
        const capabilities = ModelCapabilities(
          completionChat: true,
          completionFim: false,
          functionCalling: true,
          fineTuning: false,
          vision: true,
          classification: false,
          audioTranscription: false,
        );
        const model = Model(
          id: 'mistral-large',
          object: 'model',
          created: 1700000000,
          ownedBy: 'mistralai',
          name: 'Mistral Large',
          description: 'A large model',
          maxContextLength: 32768,
          aliases: ['mistral-large-latest'],
          defaultModelTemperature: 0.7,
          type: 'base',
          capabilities: capabilities,
        );

        expect(model.id, 'mistral-large');
        expect(model.object, 'model');
        expect(model.created, 1700000000);
        expect(model.ownedBy, 'mistralai');
        expect(model.name, 'Mistral Large');
        expect(model.description, 'A large model');
        expect(model.maxContextLength, 32768);
        expect(model.aliases, ['mistral-large-latest']);
        expect(model.defaultModelTemperature, 0.7);
        expect(model.type, 'base');
        expect(model.capabilities, capabilities);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'id': 'mistral-large',
          'object': 'model',
          'created': 1700000000,
          'owned_by': 'mistralai',
          'name': 'Mistral Large',
          'description': 'A large model',
          'max_context_length': 32768,
          'aliases': ['mistral-large-latest', 'ml'],
          'default_model_temperature': 0.7,
          'type': 'base',
          'capabilities': {
            'completion_chat': true,
            'completion_fim': false,
            'function_calling': true,
            'fine_tuning': false,
            'vision': true,
            'classification': false,
            'audio_transcription': false,
          },
        };

        final model = Model.fromJson(json);

        expect(model.id, 'mistral-large');
        expect(model.object, 'model');
        expect(model.created, 1700000000);
        expect(model.ownedBy, 'mistralai');
        expect(model.name, 'Mistral Large');
        expect(model.description, 'A large model');
        expect(model.maxContextLength, 32768);
        expect(model.aliases, ['mistral-large-latest', 'ml']);
        expect(model.defaultModelTemperature, 0.7);
        expect(model.type, 'base');
        expect(model.capabilities.completionChat, isTrue);
        expect(model.capabilities.completionFim, isFalse);
        expect(model.capabilities.functionCalling, isTrue);
        expect(model.capabilities.fineTuning, isFalse);
        expect(model.capabilities.vision, isTrue);
        expect(model.capabilities.classification, isFalse);
        expect(model.capabilities.audioTranscription, isFalse);
      });

      test('handles missing optional fields', () {
        final json = {'id': 'mistral-small', 'object': 'model'};

        final model = Model.fromJson(json);

        expect(model.id, 'mistral-small');
        expect(model.object, 'model');
        expect(model.created, isNull);
        expect(model.ownedBy, isNull);
        expect(model.name, isNull);
        expect(model.description, isNull);
        expect(model.maxContextLength, isNull);
        expect(model.aliases, isNull);
        expect(model.defaultModelTemperature, isNull);
        expect(model.type, isNull);
        expect(model.capabilities, const ModelCapabilities());
      });

      test('handles missing required fields with defaults', () {
        final json = <String, dynamic>{};

        final model = Model.fromJson(json);

        expect(model.id, '');
        expect(model.object, 'model');
      });

      test('handles nested capabilities', () {
        final json = {
          'id': 'test',
          'object': 'model',
          'capabilities': {'completion_chat': true, 'vision': true},
        };

        final model = Model.fromJson(json);

        expect(model.capabilities.completionChat, isTrue);
        expect(model.capabilities.vision, isTrue);
        expect(model.capabilities.completionFim, isNull);
        expect(model.capabilities.functionCalling, isNull);
      });
    });

    group('toJson', () {
      test('serializes required fields only and omits nulls', () {
        const model = Model(id: 'mistral-small', object: 'model');
        final json = model.toJson();

        expect(json['id'], 'mistral-small');
        expect(json['object'], 'model');
        expect(json.containsKey('created'), isFalse);
        expect(json.containsKey('owned_by'), isFalse);
        expect(json.containsKey('name'), isFalse);
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('max_context_length'), isFalse);
        expect(json.containsKey('aliases'), isFalse);
        expect(json.containsKey('default_model_temperature'), isFalse);
        expect(json.containsKey('type'), isFalse);
        expect(json['capabilities'], isA<Map<String, dynamic>>());
      });

      test('serializes all fields', () {
        const model = Model(
          id: 'mistral-large',
          object: 'model',
          created: 1700000000,
          ownedBy: 'mistralai',
          name: 'Mistral Large',
          description: 'A large model',
          maxContextLength: 32768,
          aliases: ['mistral-large-latest'],
          defaultModelTemperature: 0.7,
          type: 'base',
          capabilities: ModelCapabilities(completionChat: true, vision: false),
        );
        final json = model.toJson();

        expect(json['id'], 'mistral-large');
        expect(json['object'], 'model');
        expect(json['created'], 1700000000);
        expect(json['owned_by'], 'mistralai');
        expect(json['name'], 'Mistral Large');
        expect(json['description'], 'A large model');
        expect(json['max_context_length'], 32768);
        expect(json['aliases'], ['mistral-large-latest']);
        expect(json['default_model_temperature'], 0.7);
        expect(json['type'], 'base');
        expect(json['capabilities'], isA<Map<String, dynamic>>());
        final caps = json['capabilities'] as Map<String, dynamic>;
        expect(caps['completion_chat'], isTrue);
        expect(caps['vision'], isFalse);
      });
    });

    group('copyWith', () {
      const original = Model(
        id: 'mistral-small',
        object: 'model',
        created: 1700000000,
        ownedBy: 'mistralai',
        name: 'Mistral Small',
        description: 'A small model',
        maxContextLength: 8192,
        aliases: ['ms'],
        defaultModelTemperature: 0.5,
        type: 'base',
        capabilities: ModelCapabilities(completionChat: true),
      );

      test('copies with no changes', () {
        final copy = original.copyWith();

        expect(copy, equals(original));
        expect(copy.id, original.id);
        expect(copy.object, original.object);
        expect(copy.created, original.created);
        expect(copy.ownedBy, original.ownedBy);
        expect(copy.name, original.name);
        expect(copy.description, original.description);
        expect(copy.maxContextLength, original.maxContextLength);
        expect(copy.aliases, original.aliases);
        expect(copy.defaultModelTemperature, original.defaultModelTemperature);
        expect(copy.type, original.type);
        expect(copy.capabilities, original.capabilities);
      });

      test('copies with all changes', () {
        final copy = original.copyWith(
          id: 'mistral-large',
          object: 'model-v2',
          created: 1800000000,
          ownedBy: 'other',
          name: 'Mistral Large',
          description: 'A large model',
          maxContextLength: 32768,
          aliases: ['ml'],
          defaultModelTemperature: 0.9,
          type: 'fine-tuned',
          capabilities: const ModelCapabilities(vision: true),
        );

        expect(copy.id, 'mistral-large');
        expect(copy.object, 'model-v2');
        expect(copy.created, 1800000000);
        expect(copy.ownedBy, 'other');
        expect(copy.name, 'Mistral Large');
        expect(copy.description, 'A large model');
        expect(copy.maxContextLength, 32768);
        expect(copy.aliases, ['ml']);
        expect(copy.defaultModelTemperature, 0.9);
        expect(copy.type, 'fine-tuned');
        expect(copy.capabilities.vision, isTrue);
      });

      test('copies with partial changes', () {
        final copy = original.copyWith(id: 'new-id', name: 'New Name');

        expect(copy.id, 'new-id');
        expect(copy.name, 'New Name');
        expect(copy.object, original.object);
        expect(copy.created, original.created);
        expect(copy.ownedBy, original.ownedBy);
      });

      test('sets nullable field to null using sentinel', () {
        final copy = original.copyWith(
          created: null,
          ownedBy: null,
          name: null,
          description: null,
          maxContextLength: null,
          aliases: null,
          defaultModelTemperature: null,
          type: null,
        );

        expect(copy.id, original.id);
        expect(copy.object, original.object);
        expect(copy.created, isNull);
        expect(copy.ownedBy, isNull);
        expect(copy.name, isNull);
        expect(copy.description, isNull);
        expect(copy.maxContextLength, isNull);
        expect(copy.aliases, isNull);
        expect(copy.defaultModelTemperature, isNull);
        expect(copy.type, isNull);
        expect(copy.capabilities, original.capabilities);
      });
    });

    group('equality', () {
      test('equal with same fields', () {
        const model1 = Model(
          id: 'mistral-small',
          object: 'model',
          name: 'Mistral Small',
        );
        const model2 = Model(
          id: 'mistral-small',
          object: 'model',
          name: 'Mistral Small',
        );

        expect(model1, equals(model2));
      });

      test('not equal with different id', () {
        const model1 = Model(id: 'mistral-small', object: 'model');
        const model2 = Model(id: 'mistral-large', object: 'model');

        expect(model1, isNot(equals(model2)));
      });

      test('not equal with different capabilities', () {
        const model1 = Model(
          id: 'mistral-small',
          object: 'model',
          capabilities: ModelCapabilities(completionChat: true),
        );
        const model2 = Model(
          id: 'mistral-small',
          object: 'model',
          capabilities: ModelCapabilities(completionChat: false),
        );

        expect(model1, isNot(equals(model2)));
      });
    });

    group('hashCode', () {
      test('same for equal objects', () {
        const model1 = Model(
          id: 'mistral-small',
          object: 'model',
          aliases: ['ms'],
        );
        const model2 = Model(
          id: 'mistral-small',
          object: 'model',
          aliases: ['ms'],
        );

        expect(model1.hashCode, equals(model2.hashCode));
      });
    });

    test('toString returns descriptive string with all fields', () {
      const model = Model(
        id: 'mistral-large',
        object: 'model',
        created: 1700000000,
        ownedBy: 'mistralai',
        name: 'Mistral Large',
      );

      final str = model.toString();
      expect(str, contains('mistral-large'));
      expect(str, contains('model'));
      expect(str, contains('1700000000'));
      expect(str, contains('mistralai'));
      expect(str, contains('Mistral Large'));
    });

    test('round-trip preserves all data through JSON', () {
      const original = Model(
        id: 'mistral-large',
        object: 'model',
        created: 1700000000,
        ownedBy: 'mistralai',
        name: 'Mistral Large',
        description: 'A large model',
        maxContextLength: 32768,
        aliases: ['mistral-large-latest', 'ml'],
        defaultModelTemperature: 0.7,
        type: 'base',
        capabilities: ModelCapabilities(
          completionChat: true,
          completionFim: false,
          functionCalling: true,
          fineTuning: false,
          vision: true,
          classification: false,
          audioTranscription: false,
        ),
      );

      final json = original.toJson();
      final restored = Model.fromJson(json);

      expect(restored, equals(original));
      expect(restored.id, original.id);
      expect(restored.object, original.object);
      expect(restored.created, original.created);
      expect(restored.ownedBy, original.ownedBy);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.maxContextLength, original.maxContextLength);
      expect(restored.aliases, original.aliases);
      expect(
        restored.defaultModelTemperature,
        original.defaultModelTemperature,
      );
      expect(restored.type, original.type);
      expect(restored.capabilities, original.capabilities);
    });
  });

  group('ModelCapabilities', () {
    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'completion_chat': true,
          'completion_fim': false,
          'function_calling': true,
          'fine_tuning': false,
          'vision': true,
          'classification': false,
          'audio_transcription': true,
        };

        final caps = ModelCapabilities.fromJson(json);

        expect(caps.completionChat, isTrue);
        expect(caps.completionFim, isFalse);
        expect(caps.functionCalling, isTrue);
        expect(caps.fineTuning, isFalse);
        expect(caps.vision, isTrue);
        expect(caps.classification, isFalse);
        expect(caps.audioTranscription, isTrue);
      });

      test('handles empty JSON', () {
        final caps = ModelCapabilities.fromJson(const <String, dynamic>{});

        expect(caps.completionChat, isNull);
        expect(caps.completionFim, isNull);
        expect(caps.functionCalling, isNull);
        expect(caps.fineTuning, isNull);
        expect(caps.vision, isNull);
        expect(caps.classification, isNull);
        expect(caps.audioTranscription, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const caps = ModelCapabilities(
          completionChat: true,
          completionFim: false,
          functionCalling: true,
          fineTuning: false,
          vision: true,
          classification: false,
          audioTranscription: true,
        );

        final json = caps.toJson();

        expect(json['completion_chat'], isTrue);
        expect(json['completion_fim'], isFalse);
        expect(json['function_calling'], isTrue);
        expect(json['fine_tuning'], isFalse);
        expect(json['vision'], isTrue);
        expect(json['classification'], isFalse);
        expect(json['audio_transcription'], isTrue);
      });

      test('omits null fields', () {
        const caps = ModelCapabilities(completionChat: true);

        final json = caps.toJson();

        expect(json['completion_chat'], isTrue);
        expect(json.containsKey('completion_fim'), isFalse);
        expect(json.containsKey('function_calling'), isFalse);
        expect(json.containsKey('fine_tuning'), isFalse);
        expect(json.containsKey('vision'), isFalse);
        expect(json.containsKey('classification'), isFalse);
        expect(json.containsKey('audio_transcription'), isFalse);
      });
    });

    group('equality', () {
      test('equal with same fields', () {
        const caps1 = ModelCapabilities(completionChat: true, vision: false);
        const caps2 = ModelCapabilities(completionChat: true, vision: false);

        expect(caps1, equals(caps2));
      });

      test('not equal with different fields', () {
        const caps1 = ModelCapabilities(completionChat: true);
        const caps2 = ModelCapabilities(completionChat: false);

        expect(caps1, isNot(equals(caps2)));
      });
    });

    test('hashCode same for equal objects', () {
      const caps1 = ModelCapabilities(completionChat: true, vision: true);
      const caps2 = ModelCapabilities(completionChat: true, vision: true);

      expect(caps1.hashCode, equals(caps2.hashCode));
    });

    test('toString returns descriptive string', () {
      const caps = ModelCapabilities(
        completionChat: true,
        completionFim: false,
        functionCalling: true,
        vision: true,
      );

      final str = caps.toString();
      expect(str, contains('chat: true'));
      expect(str, contains('fim: false'));
      expect(str, contains('functions: true'));
      expect(str, contains('vision: true'));
    });
  });
}
