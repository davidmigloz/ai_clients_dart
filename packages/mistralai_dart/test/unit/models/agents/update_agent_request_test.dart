import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateAgentRequest', () {
    group('constructor', () {
      test('creates with no parameters', () {
        const request = UpdateAgentRequest();
        expect(request.name, isNull);
        expect(request.description, isNull);
        expect(request.model, isNull);
        expect(request.instructions, isNull);
        expect(request.tools, isNull);
        expect(request.metadata, isNull);
        expect(request.guardrails, isNull);
        expect(request.versionMessage, isNull);
      });

      test('creates with all parameters', () {
        const request = UpdateAgentRequest(
          name: 'Updated Name',
          description: 'Updated description',
          model: 'mistral-large-latest',
          instructions: 'Updated instructions',
          tools: [Tool.webSearch()],
          metadata: {'updated': true},
          guardrails: [
            GuardrailConfig(
              blockOnError: true,
              moderationLlmV1: ModerationLLMV1Config(
                action: ModerationLLMAction.block,
              ),
            ),
          ],
          versionMessage: 'Updated guardrails',
        );
        expect(request.name, 'Updated Name');
        expect(request.description, 'Updated description');
        expect(request.model, 'mistral-large-latest');
        expect(request.instructions, 'Updated instructions');
        expect(request.tools, hasLength(1));
        expect(request.metadata?['updated'], true);
        expect(request.guardrails, isNotNull);
        expect(request.guardrails!.first.blockOnError, isTrue);
        expect(
          request.guardrails!.first.moderationLlmV1!.action,
          ModerationLLMAction.block,
        );
        expect(request.versionMessage, 'Updated guardrails');
      });
    });

    group('toJson', () {
      test('serializes empty request', () {
        const request = UpdateAgentRequest();
        final json = request.toJson();
        expect(json, isEmpty);
      });

      test('serializes only set fields', () {
        const request = UpdateAgentRequest(
          name: 'New Name',
          model: 'new-model',
        );
        final json = request.toJson();
        expect(json['name'], 'New Name');
        expect(json['model'], 'new-model');
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('instructions'), isFalse);
        expect(json.containsKey('tools'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
        expect(json.containsKey('guardrails'), isFalse);
        expect(json.containsKey('version_message'), isFalse);
      });

      test('serializes all fields', () {
        const request = UpdateAgentRequest(
          name: 'Full Update',
          description: 'Full description',
          model: 'full-model',
          instructions: 'Full instructions',
          tools: [Tool.codeInterpreter()],
          metadata: {'all': 'fields'},
          guardrails: [GuardrailConfig(blockOnError: true)],
          versionMessage: 'Full update',
        );
        final json = request.toJson();
        expect(json['name'], 'Full Update');
        expect(json['description'], 'Full description');
        expect(json['model'], 'full-model');
        expect(json['instructions'], 'Full instructions');
        expect(json['tools'], isList);
        expect(json['metadata'], {'all': 'fields'});
        expect(json['guardrails'], isList);
        final guardrail =
            (json['guardrails'] as List).first as Map<String, dynamic>;
        expect(guardrail['block_on_error'], true);
        expect(json['version_message'], 'Full update');
      });
    });

    group('fromJson', () {
      test('deserializes empty JSON', () {
        final json = <String, dynamic>{};
        final request = UpdateAgentRequest.fromJson(json);
        expect(request.name, isNull);
        expect(request.description, isNull);
        expect(request.model, isNull);
        expect(request.instructions, isNull);
        expect(request.tools, isNull);
        expect(request.metadata, isNull);
        expect(request.guardrails, isNull);
        expect(request.versionMessage, isNull);
      });

      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'name': 'Deserialized',
          'description': 'Deserialized desc',
          'model': 'deserialized-model',
          'instructions': 'Deserialized instructions',
          'tools': [
            {'type': 'code_interpreter'},
          ],
          'metadata': {'from': 'json'},
          'guardrails': [
            {
              'block_on_error': true,
              'moderation_llm_v1': {'action': 'block'},
            },
          ],
          'version_message': 'Deserialized version',
        };
        final request = UpdateAgentRequest.fromJson(json);
        expect(request.name, 'Deserialized');
        expect(request.description, 'Deserialized desc');
        expect(request.model, 'deserialized-model');
        expect(request.instructions, 'Deserialized instructions');
        expect(request.tools, hasLength(1));
        expect(request.metadata?['from'], 'json');
        expect(request.guardrails, isNotNull);
        expect(request.guardrails!.first.blockOnError, isTrue);
        expect(
          request.guardrails!.first.moderationLlmV1!.action,
          ModerationLLMAction.block,
        );
        expect(request.versionMessage, 'Deserialized version');
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const original = UpdateAgentRequest(
          name: 'Original',
          model: 'original-model',
        );
        final copy = original.copyWith();
        expect(copy.name, 'Original');
        expect(copy.model, 'original-model');
      });

      test('copies with all changes', () {
        const original = UpdateAgentRequest(
          name: 'Original',
          model: 'original-model',
        );
        final copy = original.copyWith(
          name: 'New',
          description: 'New desc',
          model: 'new-model',
          instructions: 'New instructions',
          metadata: {'new': true},
          guardrails: const [GuardrailConfig(blockOnError: true)],
          versionMessage: 'Copied update',
        );
        expect(copy.name, 'New');
        expect(copy.description, 'New desc');
        expect(copy.model, 'new-model');
        expect(copy.instructions, 'New instructions');
        expect(copy.metadata?['new'], true);
        expect(copy.guardrails?.first.blockOnError, isTrue);
        expect(copy.versionMessage, 'Copied update');
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const request = UpdateAgentRequest(
          name: 'Updated',
          model: 'new-model',
          instructions: 'These are the new instructions for the agent.',
        );
        expect(
          request.toString(),
          'UpdateAgentRequest(name: Updated, model: new-model, instructions: 45 chars)',
        );
      });

      test('handles null values', () {
        const request = UpdateAgentRequest();
        expect(
          request.toString(),
          'UpdateAgentRequest(name: null, model: null, instructions: 0 chars)',
        );
      });
    });
  });
}
