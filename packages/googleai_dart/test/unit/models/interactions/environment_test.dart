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

    test('accepts a single dict form for transform', () {
      final entry = AllowlistEntry.fromJson({
        'domain': 'api.example.com',
        'transform': {'x-goog-api-key': 'k'},
      });

      expect(entry.transform, hasLength(1));
      expect(entry.transform!.first['x-goog-api-key'], 'k');
    });

    test('accepts a list of dicts form for transform', () {
      final entry = AllowlistEntry.fromJson({
        'domain': 'api.example.com',
        'transform': [
          {'x-goog-api-key': 'k1'},
          {'x-goog-api-key': 'k2'},
        ],
      });

      expect(entry.transform, hasLength(2));
      expect(entry.transform![1]['x-goog-api-key'], 'k2');
    });

    test('transform is null when absent', () {
      final entry = AllowlistEntry.fromJson({'domain': 'api.example.com'});
      expect(entry.transform, isNull);
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

    test('round-trips environmentId', () {
      const config = EnvironmentConfig(environmentId: 'env-123');
      final json = config.toJson();
      expect(json['environment_id'], 'env-123');

      final restored = EnvironmentConfig.fromJson(json);
      expect(restored.environmentId, 'env-123');
    });

    test('environmentId is omitted from JSON when null', () {
      expect(
        const EnvironmentConfig().toJson().containsKey('environment_id'),
        isFalse,
      );
    });

    test('type is the constant "remote" and is always serialized', () {
      expect(const EnvironmentConfig().type, 'remote');
      expect(const EnvironmentConfig().toJson()['type'], 'remote');
      // A "remote" type in JSON is accepted; any other value is rejected.
      expect(EnvironmentConfig.fromJson({'type': 'remote'}).type, 'remote');
      expect(
        () => EnvironmentConfig.fromJson({'type': 'local'}),
        throwsFormatException,
      );
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

  group('Environment', () {
    test('creates with only required id', () {
      const environment = Environment(id: 'env_1');
      expect(environment.id, 'env_1');
      expect(environment.status, isNull);
    });

    test('round-trips all fields', () {
      final environment = Environment(
        id: 'env_1',
        created: DateTime.utc(2026, 1, 1),
        updated: DateTime.utc(2026, 1, 2),
        lastAccessed: DateTime.utc(2026, 1, 3),
        fileCount: '5',
        sizeBytes: '1024',
        network: const EnvironmentNetworkAllowlist(
          allowlist: [AllowlistEntry(domain: 'example.com')],
        ),
        sources: const [Source(type: SourceType.inline, content: 'hi')],
        status: EnvironmentStatus.active,
      );

      final json = environment.toJson();
      expect(json['id'], 'env_1');
      expect(json['created'], '2026-01-01T00:00:00.000Z');
      expect(json['updated'], '2026-01-02T00:00:00.000Z');
      expect(json['last_accessed'], '2026-01-03T00:00:00.000Z');
      expect(json['file_count'], '5');
      expect(json['size_bytes'], '1024');
      expect(json['network'], isA<Map<String, dynamic>>());
      expect(json['sources'], hasLength(1));
      expect(json['status'], 'active');

      final restored = Environment.fromJson(json);
      expect(restored.id, environment.id);
      expect(restored.created, environment.created);
      expect(restored.updated, environment.updated);
      expect(restored.lastAccessed, environment.lastAccessed);
      expect(restored.fileCount, environment.fileCount);
      expect(restored.sizeBytes, environment.sizeBytes);
      expect(restored.network, isA<EnvironmentNetworkAllowlist>());
      expect(restored.sources!.first.content, 'hi');
      expect(restored.status, EnvironmentStatus.active);
    });

    test('network "disabled" string form round-trips', () {
      const environment = Environment(
        id: 'env_1',
        network: EnvironmentNetworkDisabled(),
      );
      final json = environment.toJson();
      expect(json['network'], 'disabled');

      final restored = Environment.fromJson(json);
      expect(restored.network, isA<EnvironmentNetworkDisabled>());
    });

    test('omits null optional fields from JSON', () {
      const environment = Environment(id: 'env_1');
      final json = environment.toJson();
      expect(json.containsKey('created'), isFalse);
      expect(json.containsKey('updated'), isFalse);
      expect(json.containsKey('last_accessed'), isFalse);
      expect(json.containsKey('file_count'), isFalse);
      expect(json.containsKey('size_bytes'), isFalse);
      expect(json.containsKey('network'), isFalse);
      expect(json.containsKey('sources'), isFalse);
      expect(json.containsKey('status'), isFalse);
    });

    test('unknown status parses to null', () {
      final environment = Environment.fromJson({
        'id': 'env_1',
        'status': 'something_new',
      });
      expect(environment.status, isNull);
    });

    test('copyWith replaces and preserves values', () {
      const environment = Environment(id: 'env_1', fileCount: '1');
      final replaced = environment.copyWith(
        id: 'env_2',
        status: EnvironmentStatus.expired,
      );
      expect(replaced.id, 'env_2');
      expect(replaced.status, EnvironmentStatus.expired);
      expect(replaced.fileCount, '1');

      final unchanged = environment.copyWith();
      expect(unchanged.id, environment.id);
      expect(unchanged.fileCount, environment.fileCount);
    });
  });

  group('CreateEnvironmentRequest', () {
    test('round-trips network and sources', () {
      const request = CreateEnvironmentRequest(
        network: EnvironmentNetworkDisabled(),
        sources: [Source(type: SourceType.gcs, source: 'gs://bucket')],
      );
      final json = request.toJson();
      expect(json['network'], 'disabled');
      expect(json['sources'], hasLength(1));

      final restored = CreateEnvironmentRequest.fromJson(json);
      expect(restored.network, isA<EnvironmentNetworkDisabled>());
      expect(restored.sources!.first.source, 'gs://bucket');
    });

    test('omits null fields from JSON', () {
      expect(const CreateEnvironmentRequest().toJson(), isEmpty);
    });

    test('copyWith replaces and preserves values', () {
      const request = CreateEnvironmentRequest(
        network: EnvironmentNetworkDisabled(),
      );
      final replaced = request.copyWith(network: null);
      expect(replaced.network, isNull);

      final unchanged = request.copyWith();
      expect(unchanged.network, request.network);
    });
  });

  group('ListEnvironmentsResponse', () {
    test('round-trips environments and nextPageToken', () {
      const response = ListEnvironmentsResponse(
        environments: [Environment(id: 'env_1')],
        nextPageToken: 'tok',
      );
      final json = response.toJson();
      expect(json['environments'], hasLength(1));
      expect(json['next_page_token'], 'tok');

      final restored = ListEnvironmentsResponse.fromJson(json);
      expect(restored.environments!.single.id, 'env_1');
      expect(restored.nextPageToken, 'tok');
    });

    test('omits null fields from JSON', () {
      expect(const ListEnvironmentsResponse().toJson(), isEmpty);
    });

    test('copyWith replaces and preserves values', () {
      const response = ListEnvironmentsResponse(nextPageToken: 'tok');
      final replaced = response.copyWith(nextPageToken: 'tok2');
      expect(replaced.nextPageToken, 'tok2');

      final unchanged = response.copyWith();
      expect(unchanged.nextPageToken, response.nextPageToken);
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
