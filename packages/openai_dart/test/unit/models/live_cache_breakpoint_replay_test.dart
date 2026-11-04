import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_LIVE_CACHE_AND_FIND';

Map<String, dynamic> _command(Map<String, dynamic> item) => {
  'type': 'response.item.create',
  'item': item,
};

Map<String, dynamic> _message(Map<String, dynamic> breakpoint) => {
  'type': 'message',
  'role': 'user',
  'content': [
    {
      'type': 'input_text',
      'text': _private,
      'prompt_cache_breakpoint': breakpoint,
    },
  ],
};

List<LiveResponseItemCreateParam> _events(Map<String, dynamic> item) => [
  LiveClientEvent.fromJson(_command(item)) as LiveResponseItemCreateParam,
  LiveSidebandClientEvent.fromJson(_command(item))
      as LiveResponseItemCreateParam,
  LiveClientEvent.fromForkJson(_command(item)) as LiveResponseItemCreateParam,
];

Matcher _safe() => isA<FormatException>()
    .having((e) => e.source, 'source', isNull)
    .having((e) => e.offset, 'offset', isNull)
    .having((e) => e.toString(), 'privacy', isNot(contains(_private)));

void main() {
  for (final ttl in PromptCacheBreakpointTtl.values.where(
    (value) => value != PromptCacheBreakpointTtl.unknown,
  )) {
    test(
      'typed ${ttl.value} breakpoint replays on every Live command path',
      () {
        final wire = {'mode': 'explicit', 'ttl': ttl.toJson()};
        final config = LiveInputPromptCacheBreakpointConfig.fromJson(wire);
        final param = LiveInputPromptCacheBreakpointParam.fromJson(wire);
        expect(config.ttl, ttl);
        expect(param.ttl, ttl);
        expect(config.hasTtl, isTrue);
        expect(param.hasTtl, isTrue);
        final item = _message(wire);
        for (final event in _events(item)) {
          expect(event.toJson(), _command(item));
          expect(event.toString(), isNot(contains(_private)));
        }
        final configContent = LiveInputTextContent.fromJson(const {
          'type': 'input_text',
          'text': _private,
        }).copyWith(promptCacheBreakpoint: config);
        final paramContent = LiveInputTextContentParam.fromJson(const {
          'type': 'input_text',
          'text': _private,
        }).copyWith(promptCacheBreakpoint: param);
        expect(configContent.promptCacheBreakpoint!.ttl, ttl);
        expect(paramContent.promptCacheBreakpoint!.ttl, ttl);
        expect(configContent.toJson(), paramContent.toJson());
      },
    );
  }

  test('TTL omission inherits; clear wins; raw extras cannot shadow TTL', () {
    final config = LiveInputPromptCacheBreakpointConfig.fromJson(const {
      'mode': 'explicit',
    });
    final param = LiveInputPromptCacheBreakpointParam.fromJson(const {
      'mode': 'explicit',
    });
    expect(config.ttl, isNull);
    expect(param.ttl, isNull);
    expect(config.hasTtl, isFalse);
    expect(param.hasTtl, isFalse);
    final c = config.copyWith(ttl: PromptCacheBreakpointTtl.hours12);
    final p = param.copyWith(ttl: PromptCacheBreakpointTtl.hours12);
    expect(c.copyWith(), c);
    expect(p.copyWith(), p);
    expect(c.copyWith(clearTtl: true), config);
    expect(p.copyWith(clearTtl: true), param);
    expect(c.copyWith(ttl: null, clearTtl: true), config);
    expect(p.copyWith(ttl: null, clearTtl: true), param);
    expect(c.copyWith(rawJson: {'ttl': null}).ttl, c.ttl);
    expect(p.copyWith(rawJson: {'ttl': null}).ttl, p.ttl);
    for (final event in _events(_message(config.toJson()))) {
      expect(event.toJson(), _command(_message({'mode': 'explicit'})));
    }
  });

  test(
    'TTL copies retain owned finite metadata and complete value semantics',
    () {
      final source = {
        'mode': 'explicit',
        'future': {
          'nested': [_private],
        },
      };
      final config = LiveInputPromptCacheBreakpointConfig.fromJson(source);
      final param = LiveInputPromptCacheBreakpointParam.fromJson(source);
      ((source['future']! as Map)['nested'] as List).clear();
      for (final model in <LiveInputValue>[config, param]) {
        expect(model.toJson(), {
          'mode': 'explicit',
          'future': {
            'nested': [_private],
          },
        });
        expect(model.toString(), isNot(contains(_private)));
      }
      final c = config.copyWith(ttl: PromptCacheBreakpointTtl.minutes30);
      final p = param.copyWith(ttl: PromptCacheBreakpointTtl.minutes30);
      expect(c, isNot(config));
      expect(p, isNot(param));
      expect(c, LiveInputPromptCacheBreakpointConfig.fromJson(c.toJson()));
      expect(p, LiveInputPromptCacheBreakpointParam.fromJson(p.toJson()));
      expect(
        c.hashCode,
        LiveInputPromptCacheBreakpointConfig.fromJson(c.toJson()).hashCode,
      );
      expect(
        p.hashCode,
        LiveInputPromptCacheBreakpointParam.fromJson(p.toJson()).hashCode,
      );
      expect(
        () => (c.rawJson['future'] as Map).clear(),
        throwsUnsupportedError,
      );
      expect(
        () => (p.rawJson['future'] as Map).clear(),
        throwsUnsupportedError,
      );
    },
  );

  final invalidTtls = <String, Object?>{
    'null': null,
    'future string': _private,
    'wrong scalar': 3,
    'list': [_private],
    'fallback enum': PromptCacheBreakpointTtl.unknown,
  };
  for (final entry in invalidTtls.entries) {
    test('known TTL rejects ${entry.key} privately before replay', () {
      final wireValue = entry.value is PromptCacheBreakpointTtl
          ? (entry.value! as PromptCacheBreakpointTtl).toJson()
          : entry.value;
      expect(
        () => _events(_message({'mode': 'explicit', 'ttl': wireValue})),
        throwsA(_safe()),
      );
      expect(
        () => LiveInputPromptCacheBreakpointConfig.fromJson(const {
          'mode': 'explicit',
        }).copyWith(ttl: entry.value),
        throwsA(_safe()),
      );
      expect(
        () => LiveInputPromptCacheBreakpointParam.fromJson(const {
          'mode': 'explicit',
        }).copyWith(ttl: entry.value),
        throwsA(_safe()),
      );
    });
  }

  final absentFind = {'type': 'find_in_page', 'pattern': _private};
  for (final entry in <String, Map<String, dynamic>>{
    'omitted': absentFind,
    'null': {...absentFind, 'url': null},
    'string': {...absentFind, 'url': 'https://example.com/'},
  }.entries) {
    test('find URL ${entry.key} round-trips all Live command paths', () {
      final action = LiveInputWebSearchActionFind.fromJson(entry.value);
      expect(action.hasUrl, entry.value.containsKey('url'));
      expect(action.url, entry.value['url']);
      final item = {
        'type': 'web_search_call',
        'id': 'search-call',
        'status': 'completed',
        'action': entry.value,
      };
      for (final event in _events(item)) {
        expect(event.toJson(), _command(item));
      }
      expect(action, LiveInputWebSearchActionFind.fromJson(action.toJson()));
      expect(
        action.hashCode,
        LiveInputWebSearchActionFind.fromJson(action.toJson()).hashCode,
      );
      expect(action.toString(), isNot(contains(_private)));
    });
  }

  test('find URL copies distinguish omission, null, string and clear', () {
    final absent = LiveInputWebSearchActionFind.fromJson(absentFind);
    final explicitNull = absent.copyWith(url: null);
    final present = absent.copyWith(url: 'https://example.com/');
    expect(absent, isNot(explicitNull));
    expect(explicitNull.hasUrl, isTrue);
    expect(present.copyWith(), present);
    expect(present.copyWith(url: null), explicitNull);
    expect(present.copyWith(clearUrl: true), absent);
    expect(present.copyWith(url: _private, clearUrl: true), absent);
    expect(present.copyWith(rawJson: {'url': null}).url, present.url);
    expect(present.url, 'https://example.com/');
    expect(() => absent.copyWith(url: 3), throwsA(_safe()));
  });

  test(
    'configuration-update text adapter enforces the canonical Live path',
    () {
      for (final format in [
        {'type': 'text'},
        {
          'type': 'json_schema',
          'name': 'answer',
          'schema': {'type': 'object'},
        },
      ]) {
        final item = {
          'type': 'configuration_update',
          'text': {'format': format},
        };
        for (final event in _events(item)) {
          final typed =
              event.item as LiveInputResponseConfigurationUpdateItemParam;
          expect(typed.text, isA<ConfigurationUpdateText>());
          expect(event.toJson(), _command(item));
        }
      }
      for (final invalid in [
        null,
        <String, dynamic>{},
        {'format': null},
        {
          'format': {'type': _private},
        },
      ]) {
        expect(
          () => _events({'type': 'configuration_update', 'text': invalid}),
          throwsA(_safe()),
        );
      }
    },
  );
}
