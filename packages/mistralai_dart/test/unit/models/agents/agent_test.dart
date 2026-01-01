import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Agent', () {
    group('constructor', () {
      test('creates with required parameters', () {
        const agent = Agent(
          id: 'agent-123',
          name: 'Test Agent',
          model: 'mistral-large-latest',
        );
        expect(agent.id, 'agent-123');
        expect(agent.name, 'Test Agent');
        expect(agent.model, 'mistral-large-latest');
        expect(agent.object, 'agent');
        expect(agent.version, 1);
        expect(agent.description, isNull);
        expect(agent.instructions, isNull);
        expect(agent.tools, isNull);
        expect(agent.metadata, isNull);
        expect(agent.createdAt, isNull);
        expect(agent.updatedAt, isNull);
      });

      test('creates with all parameters', () {
        final createdAt = DateTime(2024, 1, 15);
        final updatedAt = DateTime(2024, 1, 16);
        final agent = Agent(
          id: 'agent-456',
          object: 'agent',
          name: 'Code Assistant',
          description: 'Helps with coding tasks',
          model: 'codestral-latest',
          instructions: 'You are a helpful coding assistant.',
          tools: const [Tool.codeInterpreter()],
          metadata: const {'team': 'engineering'},
          version: 2,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(agent.id, 'agent-456');
        expect(agent.name, 'Code Assistant');
        expect(agent.description, 'Helps with coding tasks');
        expect(agent.model, 'codestral-latest');
        expect(agent.instructions, 'You are a helpful coding assistant.');
        expect(agent.tools, hasLength(1));
        expect(agent.metadata?['team'], 'engineering');
        expect(agent.version, 2);
        expect(agent.createdAt, createdAt);
        expect(agent.updatedAt, updatedAt);
      });
    });

    group('toJson', () {
      test('serializes required fields', () {
        const agent = Agent(
          id: 'agent-123',
          name: 'Test Agent',
          model: 'mistral-large-latest',
        );
        final json = agent.toJson();
        expect(json['id'], 'agent-123');
        expect(json['object'], 'agent');
        expect(json['name'], 'Test Agent');
        expect(json['model'], 'mistral-large-latest');
        expect(json['version'], 1);
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('instructions'), isFalse);
        expect(json.containsKey('tools'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
      });

      test('serializes all fields', () {
        final createdAt = DateTime.fromMillisecondsSinceEpoch(1705312800000);
        final agent = Agent(
          id: 'agent-456',
          name: 'Full Agent',
          description: 'A fully configured agent',
          model: 'mistral-large-latest',
          instructions: 'Be helpful.',
          tools: const [Tool.webSearch()],
          metadata: const {'key': 'value'},
          version: 3,
          createdAt: createdAt,
        );
        final json = agent.toJson();
        expect(json['id'], 'agent-456');
        expect(json['name'], 'Full Agent');
        expect(json['description'], 'A fully configured agent');
        expect(json['model'], 'mistral-large-latest');
        expect(json['instructions'], 'Be helpful.');
        expect(json['tools'], isList);
        expect(json['metadata'], {'key': 'value'});
        expect(json['version'], 3);
        expect(json['created_at'], 1705312800);
      });
    });

    group('fromJson', () {
      test('deserializes required fields', () {
        final json = <String, dynamic>{
          'id': 'agent-789',
          'name': 'JSON Agent',
          'model': 'mistral-small-latest',
        };
        final agent = Agent.fromJson(json);
        expect(agent.id, 'agent-789');
        expect(agent.name, 'JSON Agent');
        expect(agent.model, 'mistral-small-latest');
        expect(agent.version, 1);
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'id': 'agent-full',
          'object': 'agent',
          'name': 'Complete Agent',
          'description': 'Full description',
          'model': 'mistral-large-latest',
          'instructions': 'Complete instructions',
          'tools': [
            {'type': 'code_interpreter'},
          ],
          'metadata': {'env': 'production'},
          'version': 5,
          'created_at': 1705312800,
          'updated_at': 1705399200,
        };
        final agent = Agent.fromJson(json);
        expect(agent.id, 'agent-full');
        expect(agent.object, 'agent');
        expect(agent.name, 'Complete Agent');
        expect(agent.description, 'Full description');
        expect(agent.model, 'mistral-large-latest');
        expect(agent.instructions, 'Complete instructions');
        expect(agent.tools, hasLength(1));
        expect(agent.metadata?['env'], 'production');
        expect(agent.version, 5);
        expect(agent.createdAt?.year, 2024);
        expect(agent.updatedAt?.year, 2024);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{
          'id': 'minimal',
          'name': 'Minimal',
          'model': 'mistral-small-latest',
        };
        final agent = Agent.fromJson(json);
        expect(agent.description, isNull);
        expect(agent.instructions, isNull);
        expect(agent.tools, isNull);
        expect(agent.metadata, isNull);
        expect(agent.createdAt, isNull);
        expect(agent.updatedAt, isNull);
      });

      test('handles empty JSON with defaults', () {
        final json = <String, dynamic>{};
        final agent = Agent.fromJson(json);
        expect(agent.id, '');
        expect(agent.name, '');
        expect(agent.model, '');
        expect(agent.object, 'agent');
        expect(agent.version, 1);
      });
    });

    group('equality', () {
      test('equals with same id', () {
        const agent1 = Agent(
          id: 'agent-123',
          name: 'Agent A',
          model: 'model-a',
        );
        const agent2 = Agent(
          id: 'agent-123',
          name: 'Agent B',
          model: 'model-b',
        );
        expect(agent1, equals(agent2));
        expect(agent1.hashCode, agent2.hashCode);
      });

      test('not equals with different id', () {
        const agent1 = Agent(id: 'agent-123', name: 'Agent', model: 'model');
        const agent2 = Agent(id: 'agent-456', name: 'Agent', model: 'model');
        expect(agent1, isNot(equals(agent2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const agent = Agent(
          id: 'agent-123',
          name: 'My Agent',
          model: 'mistral-large-latest',
        );
        expect(
          agent.toString(),
          'Agent(id: agent-123, name: My Agent, model: mistral-large-latest)',
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        final original = Agent(
          id: 'agent-roundtrip',
          name: 'Round-trip Agent',
          description: 'Testing serialization',
          model: 'mistral-large-latest',
          instructions: 'Be thorough.',
          tools: const [Tool.codeInterpreter()],
          metadata: const {'test': true},
          version: 7,
          createdAt: DateTime.fromMillisecondsSinceEpoch(1705312800000),
        );
        final json = original.toJson();
        final restored = Agent.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.description, original.description);
        expect(restored.model, original.model);
        expect(restored.instructions, original.instructions);
        expect(restored.tools?.length, original.tools?.length);
        expect(restored.metadata?['test'], original.metadata?['test']);
        expect(restored.version, original.version);
      });
    });
  });
}
