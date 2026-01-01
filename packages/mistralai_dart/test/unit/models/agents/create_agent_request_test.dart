import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateAgentRequest', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const request = CreateAgentRequest(
          name: 'My Agent',
          model: 'mistral-large-latest',
        );
        expect(request.name, 'My Agent');
        expect(request.model, 'mistral-large-latest');
        expect(request.description, isNull);
        expect(request.instructions, isNull);
        expect(request.tools, isNull);
        expect(request.metadata, isNull);
      });

      test('creates with all parameters', () {
        const request = CreateAgentRequest(
          name: 'Full Agent',
          description: 'A comprehensive agent',
          model: 'codestral-latest',
          instructions: 'You are a coding expert.',
          tools: [Tool.codeInterpreter(), Tool.webSearch()],
          metadata: {'team': 'dev'},
        );
        expect(request.name, 'Full Agent');
        expect(request.description, 'A comprehensive agent');
        expect(request.model, 'codestral-latest');
        expect(request.instructions, 'You are a coding expert.');
        expect(request.tools, hasLength(2));
        expect(request.metadata?['team'], 'dev');
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const request = CreateAgentRequest(
          name: 'Test Agent',
          model: 'mistral-small-latest',
        );
        final json = request.toJson();
        expect(json['name'], 'Test Agent');
        expect(json['model'], 'mistral-small-latest');
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('instructions'), isFalse);
        expect(json.containsKey('tools'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
      });

      test('serializes all fields', () {
        const request = CreateAgentRequest(
          name: 'Full Agent',
          description: 'Full description',
          model: 'mistral-large-latest',
          instructions: 'Be helpful.',
          tools: [Tool.codeInterpreter()],
          metadata: {'key': 'value'},
        );
        final json = request.toJson();
        expect(json['name'], 'Full Agent');
        expect(json['description'], 'Full description');
        expect(json['model'], 'mistral-large-latest');
        expect(json['instructions'], 'Be helpful.');
        expect(json['tools'], isList);
        expect(json['metadata'], {'key': 'value'});
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{
          'name': 'JSON Agent',
          'model': 'mistral-small-latest',
        };
        final request = CreateAgentRequest.fromJson(json);
        expect(request.name, 'JSON Agent');
        expect(request.model, 'mistral-small-latest');
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'name': 'Complete Agent',
          'description': 'Complete description',
          'model': 'mistral-large-latest',
          'instructions': 'Complete instructions',
          'tools': [
            {'type': 'web_search'},
          ],
          'metadata': {'env': 'test'},
        };
        final request = CreateAgentRequest.fromJson(json);
        expect(request.name, 'Complete Agent');
        expect(request.description, 'Complete description');
        expect(request.model, 'mistral-large-latest');
        expect(request.instructions, 'Complete instructions');
        expect(request.tools, hasLength(1));
        expect(request.metadata?['env'], 'test');
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const original = CreateAgentRequest(
          name: 'Original',
          model: 'mistral-small-latest',
          description: 'Original desc',
        );
        final copy = original.copyWith();
        expect(copy.name, 'Original');
        expect(copy.model, 'mistral-small-latest');
        expect(copy.description, 'Original desc');
      });

      test('copies with all changes', () {
        const original = CreateAgentRequest(
          name: 'Original',
          description: 'Original desc',
          model: 'mistral-small-latest',
          instructions: 'Original instructions',
          metadata: {'key': 'old'},
        );
        final copy = original.copyWith(
          name: 'New Name',
          description: 'New desc',
          model: 'mistral-large-latest',
          instructions: 'New instructions',
          metadata: {'key': 'new'},
        );
        expect(copy.name, 'New Name');
        expect(copy.description, 'New desc');
        expect(copy.model, 'mistral-large-latest');
        expect(copy.instructions, 'New instructions');
        expect(copy.metadata?['key'], 'new');
      });

      test('copies with partial changes', () {
        const original = CreateAgentRequest(
          name: 'Original',
          model: 'mistral-small-latest',
          instructions: 'Keep these',
        );
        final copy = original.copyWith(name: 'New Name');
        expect(copy.name, 'New Name');
        expect(copy.model, 'mistral-small-latest');
        expect(copy.instructions, 'Keep these');
      });
    });

    group('equality', () {
      test('equals with same name and model', () {
        const request1 = CreateAgentRequest(name: 'Agent', model: 'model');
        const request2 = CreateAgentRequest(name: 'Agent', model: 'model');
        expect(request1, equals(request2));
        expect(request1.hashCode, request2.hashCode);
      });

      test('not equals with different name', () {
        const request1 = CreateAgentRequest(name: 'Agent A', model: 'model');
        const request2 = CreateAgentRequest(name: 'Agent B', model: 'model');
        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const request = CreateAgentRequest(
          name: 'My Agent',
          model: 'mistral-large-latest',
        );
        expect(
          request.toString(),
          'CreateAgentRequest(name: My Agent, model: mistral-large-latest)',
        );
      });
    });
  });
}
