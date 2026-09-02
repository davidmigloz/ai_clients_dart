import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

/// Maps a simple tool type discriminator to a matcher for its concrete
/// response-side config class.
final _responseConfigTypeMatcher = <String, Matcher>{
  'bash': isA<BashToolConfig>(),
  'edit': isA<EditToolConfig>(),
  'read': isA<ReadToolConfig>(),
  'write': isA<WriteToolConfig>(),
  'glob': isA<GlobToolConfig>(),
  'grep': isA<GrepToolConfig>(),
};

/// Maps a simple tool type discriminator to a matcher for its concrete
/// request-side config params class.
final _paramsConfigTypeMatcher = <String, Matcher>{
  'bash': isA<BashToolConfigParams>(),
  'edit': isA<EditToolConfigParams>(),
  'read': isA<ReadToolConfigParams>(),
  'write': isA<WriteToolConfigParams>(),
  'glob': isA<GlobToolConfigParams>(),
  'grep': isA<GrepToolConfigParams>(),
};

void main() {
  group('AgentToolConfig (response union)', () {
    test('dispatches all six simple tool configs', () {
      const types = ['bash', 'edit', 'read', 'write', 'glob', 'grep'];
      for (final type in types) {
        final json = {
          'type': type,
          'name': type,
          'enabled': true,
          'permission_policy': {'type': 'always_ask'},
        };
        final config = AgentToolConfig.fromJson(json);
        expect(config, _responseConfigTypeMatcher[type]);
        expect(config.name, AgentToolName.fromJson(type));
        expect(config.enabled, isTrue);
        expect(config.permissionPolicy, isA<AlwaysAskPolicy>());
        expect(config.toJson(), json);
      }
    });

    test('dispatches by name when type is absent', () {
      final config = AgentToolConfig.fromJson(const {
        'name': 'read',
        'enabled': true,
        'permission_policy': {'type': 'always_ask'},
      });
      expect(config, isA<ReadToolConfig>());
    });

    test('web_fetch config round-trips with domain filters', () {
      final json = {
        'type': 'web_fetch',
        'name': 'web_fetch',
        'enabled': true,
        'permission_policy': {'type': 'always_allow'},
        'allowed_domains': ['docs.example.com'],
        'max_content_tokens': 4096,
      };
      final config = AgentToolConfig.fromJson(json) as WebFetchToolConfig;
      expect(config.allowedDomains, ['docs.example.com']);
      expect(config.blockedDomains, isNull);
      expect(config.maxContentTokens, 4096);
      expect(config.toJson(), json);
    });

    test('web_search config round-trips with user location', () {
      final json = {
        'type': 'web_search',
        'name': 'web_search',
        'enabled': true,
        'permission_policy': {'type': 'always_ask'},
        'blocked_domains': ['ads.example.com'],
        'user_location': {'type': 'approximate', 'city': 'San Francisco'},
      };
      final config = AgentToolConfig.fromJson(json) as WebSearchToolConfig;
      expect(config.blockedDomains, ['ads.example.com']);
      expect(config.userLocation?.city, 'San Francisco');
      expect(config.toJson(), json);
    });

    test('unknown tool type falls back to UnknownAgentToolConfig', () {
      final json = {'type': 'mystery', 'name': 'mystery', 'enabled': true};
      final config = AgentToolConfig.fromJson(json);
      expect(config, isA<UnknownAgentToolConfig>());
      expect(config.toJson(), json);
    });

    test('copyWith replaces fields on a simple tool config', () {
      const config = BashToolConfig(
        enabled: true,
        permissionPolicy: AlwaysAskPolicy(),
      );
      final updated = config.copyWith(enabled: false);
      expect(updated.enabled, isFalse);
      expect(updated, isNot(config));
    });

    test('equality and hashCode', () {
      const a = BashToolConfig(
        enabled: true,
        permissionPolicy: AlwaysAskPolicy(),
      );
      const b = BashToolConfig(
        enabled: true,
        permissionPolicy: AlwaysAskPolicy(),
      );
      const c = BashToolConfig(
        enabled: false,
        permissionPolicy: AlwaysAskPolicy(),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('AgentToolConfigParams (request union)', () {
    test('dispatches all six simple tool config params', () {
      const types = ['bash', 'edit', 'read', 'write', 'glob', 'grep'];
      for (final type in types) {
        final json = {'name': type, 'enabled': false};
        final config = AgentToolConfigParams.fromJson(json);
        expect(config, _paramsConfigTypeMatcher[type]);
        expect(config.name, AgentToolName.fromJson(type));
        expect(config.enabled, isFalse);
        expect(config.permissionPolicy, isNull);
        expect(config.toJson(), {'type': type, 'name': type, 'enabled': false});
      }
    });

    test('name is a fixed constant, not a settable field', () {
      const a = BashToolConfigParams();
      const b = BashToolConfigParams();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.name, AgentToolName.bash);
      expect(a.toJson(), {'type': 'bash', 'name': 'bash'});
    });

    test('fromJson throws FormatException when name disagrees with type', () {
      expect(
        () => BashToolConfigParams.fromJson(const {'name': 'edit'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => AgentToolConfigParams.fromJson(const {
          'type': 'bash',
          'name': 'edit',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('dispatches by name when type is absent (params fromJson input)', () {
      final config = AgentToolConfigParams.fromJson(const {'name': 'read'});
      expect(config, isA<ReadToolConfigParams>());
    });

    test('web_fetch params round-trip with a content-token cap', () {
      final config = AgentToolConfigParams.webFetch(
        allowedDomains: ['docs.example.com'],
        maxContentTokens: 2048,
      );
      expect(config.toJson(), {
        'type': 'web_fetch',
        'name': 'web_fetch',
        'allowed_domains': ['docs.example.com'],
        'max_content_tokens': 2048,
      });
      final decoded = AgentToolConfigParams.fromJson(config.toJson());
      expect(decoded, isA<WebFetchToolConfigParams>());
    });

    test('web_search params round-trip with a user location', () {
      final config = AgentToolConfigParams.webSearch(
        blockedDomains: ['ads.example.com'],
        userLocation: const UserLocation(country: 'US'),
      );
      final json = config.toJson();
      expect(json['blocked_domains'], ['ads.example.com']);
      expect(json['user_location'], {'type': 'approximate', 'country': 'US'});
    });

    test('bare factory constructors build the expected variant', () {
      expect(AgentToolConfigParams.bash(), isA<BashToolConfigParams>());
      expect(AgentToolConfigParams.edit(), isA<EditToolConfigParams>());
      expect(AgentToolConfigParams.read(), isA<ReadToolConfigParams>());
      expect(AgentToolConfigParams.write(), isA<WriteToolConfigParams>());
      expect(AgentToolConfigParams.glob(), isA<GlobToolConfigParams>());
      expect(AgentToolConfigParams.grep(), isA<GrepToolConfigParams>());
    });

    test('unknown tool type falls back to UnknownAgentToolConfigParams', () {
      final json = {'type': 'mystery', 'name': 'mystery'};
      final config = AgentToolConfigParams.fromJson(json);
      expect(config, isA<UnknownAgentToolConfigParams>());
      expect(config.toJson(), json);
    });

    test('copyWith replaces fields on a simple tool config', () {
      const config = ReadToolConfigParams(enabled: true);
      final updated = config.copyWith(enabled: false);
      expect(updated.enabled, isFalse);
    });
  });

  group('AgentToolset20260401(Params) with typed configs', () {
    test('response toolset round-trips a mix of tool config variants', () {
      final json = {
        'type': 'agent_toolset_20260401',
        'default_config': {
          'enabled': true,
          'permission_policy': {'type': 'always_ask'},
        },
        'configs': [
          {
            'type': 'bash',
            'name': 'bash',
            'enabled': true,
            'permission_policy': {'type': 'always_allow'},
          },
          {
            'type': 'web_search',
            'name': 'web_search',
            'enabled': true,
            'permission_policy': {'type': 'always_ask'},
            'allowed_domains': ['docs.anthropic.com'],
          },
        ],
      };
      final toolset = AgentToolset20260401.fromJson(json);
      expect(toolset.configs[0], isA<BashToolConfig>());
      expect(toolset.configs[1], isA<WebSearchToolConfig>());
      expect(toolset.toJson(), json);
    });

    test('params toolset round-trips typed per-tool overrides', () {
      final params = AgentToolset20260401Params(
        configs: [
          AgentToolConfigParams.webSearch(
            allowedDomains: ['docs.anthropic.com'],
          ),
        ],
      );
      final json = params.toJson();
      expect(json['configs'], [
        {
          'type': 'web_search',
          'name': 'web_search',
          'allowed_domains': ['docs.anthropic.com'],
        },
      ]);
      final decoded = AgentToolset20260401Params.fromJson(json);
      expect(decoded.configs!.single, isA<WebSearchToolConfigParams>());
    });
  });

  group('WebSearchToolConfig(Params) reuse the shared UserLocation type', () {
    test('response userLocation is the built-in-tools UserLocation', () {
      const config = WebSearchToolConfig(
        enabled: true,
        permissionPolicy: AlwaysAskPolicy(),
        userLocation: UserLocation(city: 'San Francisco'),
      );
      expect(config.userLocation, isA<UserLocation>());
      expect(config.toJson()['user_location'], {
        'type': 'approximate',
        'city': 'San Francisco',
      });
    });

    test('params userLocation is the built-in-tools UserLocation', () {
      const config = WebSearchToolConfigParams(
        userLocation: UserLocation(city: 'San Francisco'),
      );
      expect(config.userLocation, isA<UserLocation>());
      expect(config.toJson()['user_location'], {
        'type': 'approximate',
        'city': 'San Francisco',
      });
    });
  });
}
