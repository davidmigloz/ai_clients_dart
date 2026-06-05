import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Agent', () {
    test('round-trips with environment and tools', () {
      const agent = Agent(
        id: 'agent_1',
        baseAgent: 'deep-research-pro-preview-12-2025',
        description: 'Research assistant',
        systemInstruction: 'Be precise.',
        baseEnvironment: EnvironmentConfigOrId.config(
          EnvironmentConfig(network: EnvironmentNetworkDisabled()),
        ),
        tools: [GoogleSearchTool(), UrlContextTool()],
      );

      final json = agent.toJson();
      expect(json['id'], 'agent_1');
      expect(json['base_agent'], 'deep-research-pro-preview-12-2025');
      expect(json['system_instruction'], 'Be precise.');
      expect(json['base_environment'], isA<Map<String, dynamic>>());
      expect(json['tools'], hasLength(2));

      final restored = Agent.fromJson(json);
      expect(restored.id, 'agent_1');
      expect(restored.baseEnvironment, isA<InlineEnvironmentConfig>());
      expect(restored.tools, hasLength(2));
      expect(restored.tools!.first, isA<GoogleSearchTool>());
    });

    test('base_environment as a string id parses to EnvironmentIdRef', () {
      final agent = Agent.fromJson({'id': 'a', 'base_environment': 'env_123'});
      expect(agent.baseEnvironment, isA<EnvironmentIdRef>());
      expect((agent.baseEnvironment! as EnvironmentIdRef).id, 'env_123');
      expect(agent.toJson()['base_environment'], 'env_123');
    });

    test('copyWith replaces description', () {
      const agent = Agent(id: 'a', description: 'old');
      expect(agent.copyWith(description: 'new').description, 'new');
      expect(agent.copyWith().description, 'old');
    });
  });

  group('ListAgentsResponse', () {
    test('round-trips agents and next_page_token', () {
      final response = ListAgentsResponse.fromJson({
        'agents': [
          {'id': 'a1'},
          {'id': 'a2'},
        ],
        'next_page_token': 'tok',
      });
      expect(response.agents, hasLength(2));
      expect(response.agents!.first.id, 'a1');
      expect(response.nextPageToken, 'tok');

      final json = response.toJson();
      expect(json['agents'], hasLength(2));
      expect(json['next_page_token'], 'tok');
    });
  });
}
