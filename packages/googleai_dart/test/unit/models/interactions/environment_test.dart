import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Source', () {
    test('round-trips with snake_case type enum', () {
      const source = Source(
        type: SourceType.gcs,
        source: 'gs://bucket/path',
        target: '/mnt/data',
      );
      final json = source.toJson();
      expect(json['type'], 'gcs');
      expect(json['source'], 'gs://bucket/path');

      final restored = Source.fromJson(json);
      expect(restored.type, SourceType.gcs);

      final skill = Source.fromJson({'type': 'skill_registry'});
      expect(skill.type, SourceType.skillRegistry);
    });
  });

  group('AllowlistEntry', () {
    test('round-trips domain and transform headers', () {
      const entry = AllowlistEntry(
        domain: 'api.example.com',
        transform: [
          {'x-goog-api-key': 'k'},
        ],
      );
      final json = entry.toJson();
      expect(json['domain'], 'api.example.com');
      expect(json['transform'], [
        {'x-goog-api-key': 'k'},
      ]);

      final restored = AllowlistEntry.fromJson(json);
      expect(restored.domain, 'api.example.com');
      expect(restored.transform!.first['x-goog-api-key'], 'k');
    });
  });

  group('EnvironmentNetworkEgressAllowlist', () {
    test('allowlist object form round-trips', () {
      const network = EnvironmentNetworkAllowlist(
        allowlist: [AllowlistEntry(domain: 'wikipedia.org')],
      );
      final json = network.toJson() as Map<String, dynamic>;
      expect(json['allowlist'] as List, hasLength(1));

      final restored = EnvironmentNetworkEgressAllowlist.fromJson(json);
      expect(restored, isA<EnvironmentNetworkAllowlist>());
      expect(
        (restored as EnvironmentNetworkAllowlist).allowlist!.first.domain,
        'wikipedia.org',
      );
    });

    test('"disabled" string form round-trips', () {
      const network = EnvironmentNetworkDisabled();
      expect(network.toJson(), 'disabled');

      final restored = EnvironmentNetworkEgressAllowlist.fromJson('disabled');
      expect(restored, isA<EnvironmentNetworkDisabled>());
    });

    test('rejects string values other than "disabled"', () {
      expect(
        () => EnvironmentNetworkEgressAllowlist.fromJson('enabled'),
        throwsArgumentError,
      );
    });
  });

  group('EnvironmentConfig', () {
    test('round-trips type/network/sources', () {
      const config = EnvironmentConfig(
        network: EnvironmentNetworkAllowlist(
          allowlist: [AllowlistEntry(domain: '*')],
        ),
        sources: [Source(type: SourceType.inline, content: 'hello')],
      );
      final json = config.toJson();
      expect(json['type'], 'remote');
      expect(json['network'], isA<Map<String, dynamic>>());
      expect(json['sources'], hasLength(1));

      final restored = EnvironmentConfig.fromJson(json);
      expect(restored.type, 'remote');
      expect(restored.network, isA<EnvironmentNetworkAllowlist>());
      expect(restored.sources!.first.content, 'hello');
    });

    test('network "disabled" inside EnvironmentConfig round-trips', () {
      const config = EnvironmentConfig(network: EnvironmentNetworkDisabled());
      final json = config.toJson();
      expect(json['network'], 'disabled');
      final restored = EnvironmentConfig.fromJson(json);
      expect(restored.network, isA<EnvironmentNetworkDisabled>());
    });
  });

  group('EnvironmentConfigOrId', () {
    test('config variant round-trips', () {
      const value = EnvironmentConfigOrId.config(EnvironmentConfig());
      expect(value.toJson(), isA<Map<String, dynamic>>());
      final restored = EnvironmentConfigOrId.fromJson(value.toJson());
      expect(restored, isA<InlineEnvironmentConfig>());
    });

    test('id variant round-trips', () {
      const value = EnvironmentConfigOrId.id('env_42');
      expect(value.toJson(), 'env_42');
      final restored = EnvironmentConfigOrId.fromJson('env_42');
      expect(restored, isA<EnvironmentIdRef>());
      expect((restored as EnvironmentIdRef).id, 'env_42');
    });
  });

  group('environment wiring on interaction models', () {
    test('CreateModelInteractionParams serializes environment', () {
      const params = CreateModelInteractionParams(
        model: 'gemini-3.5-flash',
        environment: EnvironmentConfigOrId.config(
          EnvironmentConfig(network: EnvironmentNetworkDisabled()),
        ),
      );
      final json = params.toJson();
      expect((json['environment'] as Map)['network'], 'disabled');
      // environment_id is output-only; it is never sent in a create request.
      expect(json.containsKey('environment_id'), isFalse);

      final restored = CreateModelInteractionParams.fromJson(json);
      expect(restored.environment, isA<InlineEnvironmentConfig>());
    });

    test('Interaction parses environment_id (output-only)', () {
      final interaction = Interaction.fromJson({
        'id': 'i',
        'status': 'completed',
        'environment': 'env_9',
        'environment_id': 'env_9',
      });
      expect(interaction.environment, isA<EnvironmentIdRef>());
      expect(interaction.environmentId, 'env_9');
      expect(interaction.toJson()['environment_id'], 'env_9');
    });
  });
}
