// ignore_for_file: deprecated_member_use_from_same_package
import 'package:openai_dart/openai_dart.dart'
    show JsonObjectResponseFormat, JsonSchemaResponseFormat, TextResponseFormat;
import 'package:openai_dart/openai_dart_assistants.dart';
import 'package:test/test.dart';

void main() {
  group('Assistant', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'asst_abc123',
        'object': 'assistant',
        'created_at': 1699472000,
        'model': 'gpt-4o',
        'name': 'Math Tutor',
        'description': 'A helpful math tutor',
        'instructions': 'You are a math tutor.',
        'tools': [
          {'type': 'code_interpreter'},
          {'type': 'file_search'},
        ],
        'metadata': {'category': 'education'},
        'temperature': 0.7,
        'top_p': 0.9,
        'response_format': {'type': 'text'},
      };

      final assistant = Assistant.fromJson(json);

      expect(assistant.id, 'asst_abc123');
      expect(assistant.object, 'assistant');
      expect(assistant.createdAt, 1699472000);
      expect(assistant.model, 'gpt-4o');
      expect(assistant.name, 'Math Tutor');
      expect(assistant.description, 'A helpful math tutor');
      expect(assistant.instructions, 'You are a math tutor.');
      expect(assistant.tools.length, 2);
      expect(assistant.tools[0], isA<CodeInterpreterTool>());
      expect(assistant.tools[1], isA<FileSearchTool>());
      expect(assistant.metadata['category'], 'education');
      expect(assistant.temperature, 0.7);
      expect(assistant.topP, 0.9);
      expect(assistant.responseFormat, isA<TextResponseFormat>());
    });

    test('fromJson parses json_schema response format', () {
      final json = {
        'id': 'asst_abc123',
        'object': 'assistant',
        'created_at': 1699472000,
        'model': 'gpt-4o',
        'tools': <dynamic>[],
        'metadata': <String, dynamic>{},
        'response_format': {
          'type': 'json_schema',
          'json_schema': {
            'name': 'response',
            'schema': {'type': 'object'},
            'strict': true,
          },
        },
      };

      final assistant = Assistant.fromJson(json);

      expect(assistant.responseFormat, isA<JsonSchemaResponseFormat>());
      final format = assistant.responseFormat! as JsonSchemaResponseFormat;
      expect(format.name, 'response');
      expect(format.strict, isTrue);
    });

    test('toJson serializes correctly', () {
      const assistant = Assistant(
        id: 'asst_abc123',
        object: 'assistant',
        createdAt: 1699472000,
        model: 'gpt-4o',
        name: 'Test Assistant',
        tools: [CodeInterpreterTool()],
        metadata: {'key': 'value'},
        responseFormat: JsonObjectResponseFormat(),
      );

      final json = assistant.toJson();

      expect(json['id'], 'asst_abc123');
      expect(json['name'], 'Test Assistant');
      expect(((json['tools'] as List)[0] as Map)['type'], 'code_interpreter');
      expect((json['response_format'] as Map)['type'], 'json_object');
    });

    test('helper methods work correctly', () {
      const assistant = Assistant(
        id: 'asst_abc123',
        object: 'assistant',
        createdAt: 1699472000,
        model: 'gpt-4o',
        tools: [
          CodeInterpreterTool(),
          FileSearchTool(),
          FunctionTool(name: 'test', description: 'Test function'),
        ],
        metadata: {},
      );

      expect(assistant.hasCodeInterpreter, isTrue);
      expect(assistant.hasFileSearch, isTrue);
      expect(assistant.hasFunctions, isTrue);
      expect(assistant.createdAtDateTime, isA<DateTime>());
    });
  });

  group('CreateAssistantRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'model': 'gpt-4o',
        'name': 'Test',
        'instructions': 'Be helpful',
        'tools': [
          {'type': 'code_interpreter'},
        ],
        'temperature': 0.8,
        'response_format': {'type': 'json_object'},
      };

      final request = CreateAssistantRequest.fromJson(json);

      expect(request.model, 'gpt-4o');
      expect(request.name, 'Test');
      expect(request.instructions, 'Be helpful');
      expect(request.tools?.length, 1);
      expect(request.temperature, 0.8);
      expect(request.responseFormat, isA<JsonObjectResponseFormat>());
    });

    test('toJson serializes correctly', () {
      const request = CreateAssistantRequest(
        model: 'gpt-4o',
        name: 'Test',
        responseFormat: TextResponseFormat(),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-4o');
      expect(json['name'], 'Test');
      expect((json['response_format'] as Map)['type'], 'text');
    });
  });

  group('ModifyAssistantRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'Updated Name',
        'instructions': 'New instructions',
        'response_format': {'type': 'text'},
      };

      final request = ModifyAssistantRequest.fromJson(json);

      expect(request.name, 'Updated Name');
      expect(request.instructions, 'New instructions');
      expect(request.responseFormat, isA<TextResponseFormat>());
    });

    test('toJson serializes only provided fields', () {
      const request = ModifyAssistantRequest(name: 'New Name');

      final json = request.toJson();

      expect(json['name'], 'New Name');
      expect(json.containsKey('model'), isFalse);
      expect(json.containsKey('response_format'), isFalse);
    });
  });

  group('DeleteAssistantResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'asst_abc123',
        'object': 'assistant.deleted',
        'deleted': true,
      };

      final response = DeleteAssistantResponse.fromJson(json);

      expect(response.id, 'asst_abc123');
      expect(response.object, 'assistant.deleted');
      expect(response.deleted, isTrue);
    });

    test('toJson serializes correctly', () {
      const response = DeleteAssistantResponse(
        id: 'asst_abc123',
        object: 'assistant.deleted',
        deleted: true,
      );

      final json = response.toJson();

      expect(json['id'], 'asst_abc123');
      expect(json['deleted'], isTrue);
    });
  });
}
