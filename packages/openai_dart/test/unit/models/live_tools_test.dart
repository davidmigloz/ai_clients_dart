import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _secret = 'PRIVATE-LIVE-TOOL-CONTENT';

void main() {
  for (final fixture in _fixtures) {
    group(fixture.schema, () {
      test('minimal and complete canonical fields round trip', () {
        for (final json in [fixture.minimal, fixture.complete]) {
          final value = fixture.parse(json);
          expect(value.toJson(), json);
          expect(fixture.copy(value), value);
          expect(fixture.copy(value).hashCode, value.hashCode);
          expect(fixture.parse(_json(value)), value);
          value.validate();
        }
      });
      for (final key in fixture.required) {
        test('required $key absent is rejected safely', () {
          final json = {...fixture.minimal}..remove(key);
          _expectSafeFailure(() => fixture.parse(json), key);
        });
        test('required $key null is rejected safely', () {
          _expectSafeFailure(
            () => fixture.parse({...fixture.minimal, key: null}),
            key,
          );
        });
        test('required $key wrong type is rejected safely', () {
          _expectSafeFailure(
            () => fixture.parse({...fixture.minimal, key: true}),
            key,
          );
        });
      }
      if (fixture.minimal.containsKey('type')) {
        test('fixed discriminator rejects unsupported secret', () {
          _expectSafeFailure(
            () => fixture.parse({...fixture.minimal, 'type': _secret}),
            'type',
          );
        });
      }
      test('immutable open extras survive copy, equality and JSON', () {
        final nested = <String, dynamic>{
          'values': <Object?>[_secret, null, true, 1, 1.5],
        };
        final json = {...fixture.complete, 'private-unknown-key': nested};
        final value = fixture.parse(json);
        final expected = {
          ...fixture.complete,
          'private-unknown-key': {
            'values': [_secret, null, true, 1, 1.5],
          },
        };
        nested['values'] = <Object?>[];
        json['private-unknown-key'] = false;
        expect(value.toJson(), expected);
        final raw = (value as dynamic).rawJson as Map<String, dynamic>;
        expect(() => raw['mutate'] = true, throwsUnsupportedError);
        expect(
          () => (raw['private-unknown-key'] as Map)['mutate'] = true,
          throwsUnsupportedError,
        );
        expect(
          () => ((raw['private-unknown-key'] as Map)['values'] as List).add(
            false,
          ),
          throwsUnsupportedError,
        );
        expect(fixture.copy(value), value);
        expect(fixture.copy(value).hashCode, value.hashCode);
        expect(value.toString(), isNot(contains(_secret)));
        expect(value.toString(), isNot(contains('private-unknown-key')));
        expect(value.toString(), isNot(contains('private-typed-value')));
      });
      test('typed fields override stale raw known fields', () {
        final value = fixture.parse(fixture.complete);
        final stale = <String, dynamic>{
          for (final key in fixture.complete.keys) key: _secret,
          'future': [_secret],
        };
        final copied = fixture.copyRaw(value, stale);
        expect(copied.toJson(), {
          ...fixture.complete,
          'future': [_secret],
        });
        expect((copied as dynamic).rawJson, stale);
        stale['future'] = true;
        expect(copied.toJson(), {
          ...fixture.complete,
          'future': [_secret],
        });
      });
      for (final invalid in <Object>[
        double.nan,
        double.infinity,
        double.negativeInfinity,
        Object(),
      ]) {
        test(
          'non JSON or nonfinite extra ${invalid.runtimeType} is rejected',
          () {
            _expectSafeFailure(
              () => fixture.parse({...fixture.minimal, _secret: invalid}),
            );
          },
        );
      }
      test('cyclic extras are rejected without disclosing unknown keys', () {
        final cycle = <String, dynamic>{};
        cycle[_secret] = cycle;
        _expectSafeFailure(
          () => fixture.parse({...fixture.minimal, _secret: cycle}),
        );
      });
      test('cyclic arrays are rejected without disclosing unknown keys', () {
        final cycle = <Object?>[];
        cycle.add(cycle);
        _expectSafeFailure(
          () => fixture.parse({...fixture.minimal, _secret: cycle}),
        );
      });
      test('non string nested object keys are rejected safely', () {
        _expectSafeFailure(
          () => fixture.parse({
            ...fixture.minimal,
            _secret: <Object, Object>{1: _secret},
          }),
        );
      });
    });
  }

  group('exact writable union admission', () {
    final inputs = _fixtures.where((f) => f.schema.endsWith('ToolInputParam'));
    final specific = _fixtures.where(
      (f) =>
          f.schema.contains('Specific') ||
          f.schema == 'LiveFunctionToolChoiceParam' ||
          f.schema == 'LiveMCPToolChoiceParam',
    );
    for (final f in inputs) {
      test('tool union admits ${f.schema}', () {
        expect(LiveTool.fromJson(f.complete), f.parse(f.complete));
      });
    }
    for (final f in specific) {
      test('specific and general choice admit ${f.schema}', () {
        expect(
          LiveSpecificToolChoice.fromJson(f.complete),
          f.parse(f.complete),
        );
        expect(LiveToolChoice.fromJson(f.complete), f.parse(f.complete));
      });
    }
    for (final value in LiveToolChoiceEnum.values) {
      test('scalar choice ${value.toJson()}', () {
        final choice = LiveToolChoice.mode(value);
        expect(choice.toJson(), value.toJson());
        expect(LiveToolChoice.fromJson(value.toJson()), choice);
        expect((choice as LiveToolChoiceMode).copyWith(), choice);
        expect(choice.toString(), isNot(contains(value.toJson())));
      });
    }
    for (final value in <Object?>[
      null,
      true,
      1,
      [],
      _secret,
      {'type': _secret},
      {'type': 'namespace'},
      {'type': 'tool_search'},
    ]) {
      test(
        'general choice rejects invalid ${value.runtimeType}',
        () => _expectSafeFailure(() => LiveToolChoice.fromJson(value)),
      );
    }
    for (final union in <LiveJsonModel Function(Map<String, dynamic>)>[
      LiveTool.fromJson,
      LiveShellEnvironment.fromJson,
      LiveContainerNetworkPolicy.fromJson,
      LiveHostedSkill.fromJson,
      LiveSpecificToolChoice.fromJson,
    ]) {
      for (final type in <Object?>[null, true, 1, [], _secret]) {
        test(
          'union rejects missing or unsupported discriminator ${type.runtimeType}',
          () => _expectSafeFailure(() => union({'type': type}), 'type'),
        );
      }
    }
    test('preview exists only in choice and namespace only in input', () {
      expect(
        LiveToolChoice.fromJson(const {'type': 'web_search_preview'}),
        isA<LiveSpecificWebSearchPreview>(),
      );
      _expectSafeFailure(
        () => LiveTool.fromJson(const {'type': 'web_search_preview'}),
      );
      expect(LiveTool.namespace().toJson(), {'type': 'namespace'});
      _expectSafeFailure(
        () => LiveToolChoice.fromJson(const {'type': 'namespace'}),
      );
    });
    test('13 factory branches match canonical discriminators', () {
      final tools = <LiveTool>[
        LiveTool.function(name: ''),
        LiveTool.webSearch(),
        LiveTool.fileSearch(),
        LiveTool.codeInterpreter(),
        LiveTool.shell(),
        LiveTool.imageGeneration(),
        LiveTool.mcp(),
        LiveTool.custom(),
        LiveTool.namespace(),
        LiveTool.toolSearch(),
        LiveTool.programmatic(),
        LiveTool.computer(),
        LiveTool.applyPatch(),
      ];
      expect(
        tools.map((v) => v.type).toSet(),
        inputs.map((f) => f.minimal['type']).toSet(),
      );
      for (final value in tools) {
        expect(LiveTool.fromJson(value.toJson()), value);
      }
      expect((tools.first as LiveFunctionTool).hasDescription, isFalse);
      expect((tools[4] as LiveHostedShellTool).hasEnvironment, isFalse);
    });
    test(
      'type only input branches retain arbitrary finite future configuration',
      () {
        for (final type in [
          'namespace',
          'programmatic_tool_calling',
          'custom',
          'mcp',
          'tool_search',
        ]) {
          final value = LiveTool.fromJson({
            'type': type,
            'name': '',
            'tools': const [_secret, null],
            'configuration': const {'unknown': false},
          });
          expect(value.toJson(), {
            'type': type,
            'name': '',
            'tools': [_secret, null],
            'configuration': {'unknown': false},
          });
        }
      },
    );
  });

  group('nullable presence and clear behavior', () {
    test(
      'function description, parameters and strict preserve absent/null/value',
      () {
        final omitted = LiveFunctionTool(name: '');
        expect(omitted.toJson(), {'type': 'function', 'name': ''});
        expect(omitted.hasDescription, isFalse);
        expect(omitted.hasParameters, isFalse);
        expect(omitted.hasStrict, isFalse);
        final nulls = omitted.copyWith(
          description: null,
          parameters: null,
          strict: null,
        );
        expect(nulls.toJson(), {
          'type': 'function',
          'name': '',
          'description': null,
          'parameters': null,
          'strict': null,
        });
        expect(nulls, isNot(omitted));
        final populated = nulls.copyWith(
          description: _secret,
          parameters: {
            'properties': {_secret: false},
          },
          strict: false,
        );
        expect(populated.description, _secret);
        expect(populated.strict, isFalse);
        expect(populated.copyWith().toJson(), populated.toJson());
        expect(
          populated.copyWith(
            hasDescription: false,
            hasParameters: false,
            hasStrict: false,
          ),
          omitted,
        );
        expect(
          omitted.copyWith(hasDescription: true).toJson()['description'],
          isNull,
        );
        expect(omitted.copyWith(hasDescription: true).hasDescription, isTrue);
        for (final key in ['description', 'parameters', 'strict']) {
          _expectSafeFailure(
            () => LiveFunctionTool.fromJson({
              'type': 'function',
              'name': '',
              key: 1,
            }),
            key,
          );
        }
      },
    );
    test(
      'function parameters preserve arbitrary finite schema JSON without inspection',
      () {
        final parameters = <String, dynamic>{
          'properties': {_secret: false},
          'required': [null, 1],
          'unknown': 1.25,
        };
        final value = LiveFunctionTool(name: '', parameters: parameters);
        parameters['unknown'] = true;
        expect(value.parameters!['unknown'], 1.25);
        expect(() => value.parameters!['add'] = true, throwsUnsupportedError);
        expect(
          () => (value.parameters!['properties'] as Map)['add'] = true,
          throwsUnsupportedError,
        );
        _expectSafeFailure(
          () => LiveFunctionTool(
            name: '',
            parameters: const {_secret: double.nan},
          ),
        );
      },
    );
    test('shell environment absence/null/value', () {
      final omitted = LiveHostedShellTool();
      final nullValue = omitted.copyWith(environment: null);
      expect(omitted.hasEnvironment, isFalse);
      expect(nullValue.hasEnvironment, isTrue);
      expect(nullValue.toJson(), {'type': 'shell', 'environment': null});
      final value = nullValue.copyWith(
        environment: LiveContainerReference(containerId: ' /%秘密 '),
      );
      expect(value.environment, isA<LiveContainerReference>());
      expect(value.copyWith(hasEnvironment: false), omitted);
      _expectSafeFailure(
        () => LiveHostedShellTool(environment: const {'type': 'local'}),
        'environment',
      );
      _expectSafeFailure(
        () => LiveHostedShellTool.fromJson(const {
          'type': 'shell',
          'environment': {'type': _secret},
        }),
        'environment',
      );
    });
    test(
      'container auto preserves all four optional fields and explicit clears',
      () {
        final omitted = LiveHostedShellContainerAuto();
        final nulls = omitted.copyWith(
          fileIds: null,
          memoryLimit: null,
          networkPolicy: null,
          skills: null,
        );
        expect(nulls.toJson(), {
          'type': 'container_auto',
          'file_ids': null,
          'memory_limit': null,
          'network_policy': null,
          'skills': null,
        });
        final populated = nulls.copyWith(
          fileIds: [''],
          memoryLimit: LiveContainerMemoryLimit.g4,
          networkPolicy: LiveContainerNetworkPolicyDisabled(),
          skills: [LiveSkillReference(skillId: 'x')],
        );
        expect(populated.copyWith(), populated);
        expect(
          populated.copyWith(
            hasFileIds: false,
            hasMemoryLimit: false,
            hasNetworkPolicy: false,
            hasSkills: false,
          ),
          omitted,
        );
        for (final field in [
          'file_ids',
          'memory_limit',
          'network_policy',
          'skills',
        ]) {
          _expectSafeFailure(
            () => LiveHostedShellContainerAuto.fromJson({
              'type': 'container_auto',
              field: _secret,
            }),
            field,
          );
        }
      },
    );
    test(
      'local skills, skill version, MCP name and allowed mode preserve null',
      () {
        expect(LiveLocalEnvironment(skills: null).toJson(), {
          'type': 'local',
          'skills': null,
        });
        expect(
          LiveLocalEnvironment(skills: null).copyWith(hasSkills: false),
          LiveLocalEnvironment(),
        );
        expect(LiveSkillReference(skillId: 'x', version: null).toJson(), {
          'type': 'skill_reference',
          'skill_id': 'x',
          'version': null,
        });
        expect(
          LiveSkillReference(
            skillId: 'x',
            version: 'not constrained by description',
          ).copyWith(hasVersion: false),
          LiveSkillReference(skillId: 'x'),
        );
        expect(
          LiveMCPToolChoice(
            serverLabel: '',
            name: null,
          ).copyWith(hasName: false),
          LiveMCPToolChoice(serverLabel: ''),
        );
        final entry = LiveSpecificWebSearchPreview();
        expect(
          LiveAllowedToolsChoice(
            tools: [entry],
            mode: null,
          ).copyWith(hasMode: false),
          LiveAllowedToolsChoice(tools: [entry]),
        );
        expect(
          LiveAllowedToolsChoice(
            tools: [entry],
            mode: LiveToolChoiceValueEnum.none,
          ).copyWith(mode: null).toJson()['mode'],
          isNull,
        );
      },
    );
  });

  group('runtime nonfinite tool admission across numeric backends', () {
    for (final literal in ['Infinity', '-Infinity', 'NaN']) {
      test('runtime $literal cannot replace the nullable string version', () {
        final dynamic value = num.parse(literal);
        expect((value as num).isFinite, isFalse);
        _expectSafeFailure(
          () => LiveSkillReference(skillId: 'x', version: value),
          'version',
        );
        _expectSafeFailure(
          () => LiveSkillReference.fromJson({
            'type': 'skill_reference',
            'skill_id': 'x',
            'version': value,
          }),
          'version',
        );
        _expectSafeFailure(
          () => LiveSkillReference(skillId: 'x').copyWith(version: value),
          'version',
        );
      });
      test('runtime $literal cannot replace typed nullable tool controls', () {
        final dynamic value = num.parse(literal);
        <void Function()>[
          () => LiveFunctionTool(name: '', description: value),
          () => LiveFunctionTool(name: '').copyWith(description: value),
          () => LiveFunctionTool(name: '', strict: value),
          () => LiveFunctionTool(name: '').copyWith(strict: value),
          () => LiveFunctionTool(name: '', parameters: value),
          () => LiveFunctionTool(name: '').copyWith(parameters: value),
          () => LiveHostedShellTool(environment: value),
          () => LiveHostedShellTool().copyWith(environment: value),
          () => LiveHostedShellContainerAuto(fileIds: value),
          () => LiveHostedShellContainerAuto().copyWith(fileIds: value),
          () => LiveHostedShellContainerAuto(memoryLimit: value),
          () => LiveHostedShellContainerAuto().copyWith(memoryLimit: value),
          () => LiveHostedShellContainerAuto(networkPolicy: value),
          () => LiveHostedShellContainerAuto().copyWith(networkPolicy: value),
          () => LiveHostedShellContainerAuto(skills: value),
          () => LiveHostedShellContainerAuto().copyWith(skills: value),
          () => LiveLocalEnvironment(skills: value),
          () => LiveLocalEnvironment().copyWith(skills: value),
          () => LiveMCPToolChoice(serverLabel: '', name: value),
          () => LiveMCPToolChoice(serverLabel: '').copyWith(name: value),
          () => LiveAllowedToolsChoice(
            tools: [LiveSpecificFileSearch()],
            mode: value,
          ),
          () => LiveAllowedToolsChoice(
            tools: [LiveSpecificFileSearch()],
          ).copyWith(mode: value),
        ].forEach(_expectSafeFailure);
      });
      test('runtime $literal cannot enter any open tool snapshot by copy', () {
        final dynamic value = num.parse(literal);
        for (final fixture in _fixtures) {
          _expectSafeFailure(
            () => fixture.copyRaw(fixture.parse(fixture.complete), {
              _secret: value,
            }),
          );
        }
        _expectSafeFailure(
          () => LiveFunctionTool(name: '', parameters: {_secret: value}),
          'parameters',
        );
        _expectSafeFailure(
          () =>
              LiveFunctionTool(name: '').copyWith(parameters: {_secret: value}),
          'parameters',
        );
      });
    }
  });

  group('exact container and choice boundaries', () {
    for (final length in [0, 1, 50]) {
      test('file ids accepts $length immutable entries', () {
        final source = List<String>.filled(length, _secret, growable: true);
        final value = LiveHostedShellContainerAuto(fileIds: source);
        source.add('later');
        expect(value.fileIds, hasLength(length));
        expect(() => value.fileIds!.add('later'), throwsUnsupportedError);
      });
    }
    test('file ids rejects 51 and malformed items with index', () {
      _expectSafeFailure(
        () => LiveHostedShellContainerAuto(
          fileIds: List<String>.filled(51, _secret),
        ),
        'fileIds',
      );
      _expectSafeFailure(
        () => LiveHostedShellContainerAuto.fromJson(const {
          'type': 'container_auto',
          'file_ids': [_secret, null],
        }),
        'file_ids[1]',
      );
    });
    for (final length in [0, 1, 200]) {
      test('hosted and local skills accept $length immutable entries', () {
        final hosted = List<LiveHostedSkill>.filled(
          length,
          LiveSkillReference(skillId: 'x'),
          growable: true,
        );
        final local = List<LiveLocalSkill>.filled(
          length,
          LiveLocalSkill(name: '', description: '', path: ''),
          growable: true,
        );
        final a = LiveHostedShellContainerAuto(skills: hosted);
        final b = LiveLocalEnvironment(skills: local);
        hosted.add(LiveSkillReference(skillId: 'y'));
        local.add(LiveLocalSkill(name: '', description: '', path: ''));
        expect(a.skills, hasLength(length));
        expect(b.skills, hasLength(length));
        expect(() => a.skills!.clear(), throwsUnsupportedError);
        expect(() => b.skills!.clear(), throwsUnsupportedError);
      });
    }
    test('skills rejects 201 and wrong nested branch with index', () {
      _expectSafeFailure(
        () => LiveHostedShellContainerAuto(
          skills: List<LiveHostedSkill>.filled(
            201,
            LiveSkillReference(skillId: 'x'),
          ),
        ),
        'skills',
      );
      _expectSafeFailure(
        () => LiveLocalEnvironment(
          skills: List<LiveLocalSkill>.filled(
            201,
            LiveLocalSkill(name: '', description: '', path: ''),
          ),
        ),
        'skills',
      );
      _expectSafeFailure(
        () => LiveHostedShellContainerAuto.fromJson(const {
          'type': 'container_auto',
          'skills': [
            {'type': 'skill_reference', 'skill_id': 'x'},
            {'type': _secret},
          ],
        }),
        'skills[1]',
      );
      _expectSafeFailure(
        () => LiveLocalEnvironment.fromJson(const {
          'type': 'local',
          'skills': [null],
        }),
        'skills[0]',
      );
    });
    for (final length in [1, 64]) {
      test(
        'skill id accepts $length Unicode code points',
        () => expect(
          LiveSkillReference(
            skillId: List.filled(length, '🦄').join(),
          ).skillId.runes,
          hasLength(length),
        ),
      );
    }
    for (final length in [0, 65]) {
      test(
        'skill id rejects $length code points',
        () => _expectSafeFailure(
          () => LiveSkillReference(skillId: List.filled(length, '🦄').join()),
          'skillId',
        ),
      );
    }
    test(
      'inline data enforces canonical minimum without decoding opaque bytes',
      () {
        expect(LiveInlineSkillSource(data: _secret).toJson(), {
          'type': 'base64',
          'media_type': 'application/zip',
          'data': _secret,
        });
        _expectSafeFailure(() => LiveInlineSkillSource(data: ''), 'data');
        _expectSafeFailure(
          () => LiveInlineSkillSource.fromJson(const {
            'type': 'base64',
            'media_type': _secret,
            'data': _secret,
          }),
          'media_type',
        );
      },
    );
    test('inline data enforces the exact canonical maximum', () {
      const maximum = 70254592;
      final accepted = String.fromCharCodes(
        Uint8List(maximum)..fillRange(0, maximum, 0x61),
      );
      expect(LiveInlineSkillSource(data: accepted).data.length, maximum);
      _expectSafeFailure(
        () => LiveInlineSkillSource(data: '$accepted!'),
        'data',
      );
    });
    test(
      'allowlist requires a domain entry without inventing domain grammar',
      () {
        final domains = <String>['', ' https:///%秘密 ', _secret];
        final value = LiveHostedShellNetworkPolicyAllowlist(
          allowedDomains: domains,
        );
        domains.clear();
        expect(value.allowedDomains, hasLength(3));
        expect(value.allowedDomains.clear, throwsUnsupportedError);
        _expectSafeFailure(
          () => LiveHostedShellNetworkPolicyAllowlist(allowedDomains: const []),
          'allowedDomains',
        );
        _expectSafeFailure(
          () => LiveHostedShellNetworkPolicyAllowlist.fromJson(const {
            'type': 'allowlist',
            'allowed_domains': [null],
          }),
          'allowed_domains[0]',
        );
      },
    );
    for (final length in [1, 128]) {
      test('allowed tools accepts $length exact specific choices', () {
        final entries = List<LiveSpecificToolChoice>.filled(
          length,
          LiveSpecificWebSearchPreview(),
          growable: true,
        );
        final value = LiveAllowedToolsChoice(tools: entries);
        entries.clear();
        expect(value.tools, hasLength(length));
        expect(value.tools.clear, throwsUnsupportedError);
        expect(LiveToolChoice.fromJson(value.toJson()), value);
      });
    }
    for (final length in [0, 129]) {
      test(
        'allowed tools rejects $length entries',
        () => _expectSafeFailure(
          () => LiveAllowedToolsChoice(
            tools: List<LiveSpecificToolChoice>.filled(
              length,
              LiveSpecificFileSearch(),
            ),
          ),
          'tools',
        ),
      );
    }
    for (final entry in <Object?>[
      'auto',
      {
        'type': 'allowed_tools',
        'tools': [
          {'type': 'file_search'},
        ],
      },
      {'type': 'namespace'},
      {'type': 'tool_search'},
      null,
      {'type': _secret},
    ]) {
      test(
        'allowed tools rejects scalar, recursive or unknown ${entry.runtimeType}',
        () => _expectSafeFailure(
          () => LiveAllowedToolsChoice.fromJson({
            'type': 'allowed_tools',
            'tools': [
              const {'type': 'file_search'},
              entry,
            ],
          }),
          'tools[1]',
        ),
      );
    }
    for (final value in LiveContainerMemoryLimit.values) {
      test('memory ${value.value} is exact', () {
        expect(LiveContainerMemoryLimit.fromJson(value.toJson()), value);
        expect(
          LiveHostedShellContainerAuto.fromJson({
            'type': 'container_auto',
            'memory_limit': value.value,
          }).memoryLimit,
          value,
        );
      });
    }
    for (final value in LiveToolChoiceValueEnum.values) {
      test('allowed mode ${value.value} is exact', () {
        expect(LiveToolChoiceValueEnum.fromJson(value.toJson()), value);
        expect(
          LiveAllowedToolsChoice.fromJson({
            'type': 'allowed_tools',
            'tools': const [
              {'type': 'file_search'},
            ],
            'mode': value.value,
          }).mode,
          value,
        );
      });
    }
    for (final value in <Object?>[null, true, 4, '', _secret, '8g', 'AUTO']) {
      test('enum malformed ${value.runtimeType} safely rejected', () {
        _expectSafeFailure(() => LiveContainerMemoryLimit.fromJson(value));
        _expectSafeFailure(() => LiveToolChoiceValueEnum.fromJson(value));
      });
    }
  });
}

Map<String, dynamic> _json(LiveJsonModel value) =>
    value.toJson() as Map<String, dynamic>;

void _expectSafeFailure(void Function() action, [String? context]) {
  try {
    action();
    fail('Expected a safe FormatException');
  } on FormatException catch (error) {
    if (context != null) expect(error.message, contains(context));
    expect(error.message, isNot(contains(_secret)));
    expect(error.toString(), isNot(contains(_secret)));
    expect(error.source, isNull);
    expect(error.offset, isNull);
  }
}

final class _Fixture {
  const _Fixture(
    this.schema,
    this.minimal,
    this.complete,
    this.required,
    this.parse,
    this.copy,
    this.copyRaw,
  );
  final String schema;
  final Map<String, dynamic> minimal;
  final Map<String, dynamic> complete;
  final List<String> required;
  final LiveJsonModel Function(Map<String, dynamic>) parse;
  final LiveJsonModel Function(LiveJsonModel) copy;
  final LiveJsonModel Function(LiveJsonModel, Map<String, dynamic>) copyRaw;
}

final _fixtures = <_Fixture>[
  _Fixture(
    'LiveFunctionToolInputParam',
    {'name': 'private-typed-value', 'type': 'function'},
    {
      'description': 'private-typed-value',
      'name': 'private-typed-value',
      'parameters': <String, dynamic>{},
      'strict': false,
      'type': 'function',
    },
    ['type', 'name'],
    LiveFunctionTool.fromJson,
    (value) => (value as LiveFunctionTool).copyWith(),
    (value, raw) => (value as LiveFunctionTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveWebSearchToolInputParam',
    {'type': 'web_search'},
    {'type': 'web_search'},
    ['type'],
    LiveWebSearchTool.fromJson,
    (value) => (value as LiveWebSearchTool).copyWith(),
    (value, raw) => (value as LiveWebSearchTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveFileSearchToolInputParam',
    {'type': 'file_search'},
    {'type': 'file_search'},
    ['type'],
    LiveFileSearchTool.fromJson,
    (value) => (value as LiveFileSearchTool).copyWith(),
    (value, raw) => (value as LiveFileSearchTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveCodeInterpreterToolInputParam',
    {'type': 'code_interpreter'},
    {'type': 'code_interpreter'},
    ['type'],
    LiveCodeInterpreterTool.fromJson,
    (value) => (value as LiveCodeInterpreterTool).copyWith(),
    (value, raw) => (value as LiveCodeInterpreterTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveHostedShellToolInputParam',
    {'type': 'shell'},
    {
      'environment': {
        'file_ids': ['private-typed-value'],
        'memory_limit': '1g',
        'network_policy': {'type': 'disabled'},
        'skills': [
          {
            'skill_id': 'private-typed-value',
            'type': 'skill_reference',
            'version': 'private-typed-value',
          },
        ],
        'type': 'container_auto',
      },
      'type': 'shell',
    },
    ['type'],
    LiveHostedShellTool.fromJson,
    (value) => (value as LiveHostedShellTool).copyWith(),
    (value, raw) => (value as LiveHostedShellTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveImageGenerationToolInputParam',
    {'type': 'image_generation'},
    {'type': 'image_generation'},
    ['type'],
    LiveImageGenerationTool.fromJson,
    (value) => (value as LiveImageGenerationTool).copyWith(),
    (value, raw) => (value as LiveImageGenerationTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveMCPToolInputParam',
    {'type': 'mcp'},
    {'type': 'mcp'},
    ['type'],
    LiveMCPTool.fromJson,
    (value) => (value as LiveMCPTool).copyWith(),
    (value, raw) => (value as LiveMCPTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveCustomToolInputParam',
    {'type': 'custom'},
    {'type': 'custom'},
    ['type'],
    LiveCustomTool.fromJson,
    (value) => (value as LiveCustomTool).copyWith(),
    (value, raw) => (value as LiveCustomTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveNamespaceToolInputParam',
    {'type': 'namespace'},
    {'type': 'namespace'},
    ['type'],
    LiveNamespaceTool.fromJson,
    (value) => (value as LiveNamespaceTool).copyWith(),
    (value, raw) => (value as LiveNamespaceTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveToolSearchToolInputParam',
    {'type': 'tool_search'},
    {'type': 'tool_search'},
    ['type'],
    LiveToolSearchTool.fromJson,
    (value) => (value as LiveToolSearchTool).copyWith(),
    (value, raw) => (value as LiveToolSearchTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveProgrammaticToolInputParam',
    {'type': 'programmatic_tool_calling'},
    {'type': 'programmatic_tool_calling'},
    ['type'],
    LiveProgrammaticTool.fromJson,
    (value) => (value as LiveProgrammaticTool).copyWith(),
    (value, raw) => (value as LiveProgrammaticTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveComputerToolInputParam',
    {'type': 'computer'},
    {'type': 'computer'},
    ['type'],
    LiveComputerTool.fromJson,
    (value) => (value as LiveComputerTool).copyWith(),
    (value, raw) => (value as LiveComputerTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveApplyPatchToolInputParam',
    {'type': 'apply_patch'},
    {'type': 'apply_patch'},
    ['type'],
    LiveApplyPatchTool.fromJson,
    (value) => (value as LiveApplyPatchTool).copyWith(),
    (value, raw) => (value as LiveApplyPatchTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveHostedShellContainerAutoParam',
    {'type': 'container_auto'},
    {
      'file_ids': ['private-typed-value'],
      'memory_limit': '1g',
      'network_policy': {'type': 'disabled'},
      'skills': [
        {
          'skill_id': 'private-typed-value',
          'type': 'skill_reference',
          'version': 'private-typed-value',
        },
      ],
      'type': 'container_auto',
    },
    ['type'],
    LiveHostedShellContainerAuto.fromJson,
    (value) => (value as LiveHostedShellContainerAuto).copyWith(),
    (value, raw) =>
        (value as LiveHostedShellContainerAuto).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveContainerReferenceParam',
    {'container_id': 'private-typed-value', 'type': 'container_reference'},
    {'container_id': 'private-typed-value', 'type': 'container_reference'},
    ['type', 'container_id'],
    LiveContainerReference.fromJson,
    (value) => (value as LiveContainerReference).copyWith(),
    (value, raw) => (value as LiveContainerReference).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveLocalEnvironmentParam',
    {'type': 'local'},
    {
      'skills': [
        {
          'description': 'private-typed-value',
          'name': 'private-typed-value',
          'path': 'private-typed-value',
        },
      ],
      'type': 'local',
    },
    ['type'],
    LiveLocalEnvironment.fromJson,
    (value) => (value as LiveLocalEnvironment).copyWith(),
    (value, raw) => (value as LiveLocalEnvironment).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveContainerNetworkPolicyDisabledParam',
    {'type': 'disabled'},
    {'type': 'disabled'},
    ['type'],
    LiveContainerNetworkPolicyDisabled.fromJson,
    (value) => (value as LiveContainerNetworkPolicyDisabled).copyWith(),
    (value, raw) =>
        (value as LiveContainerNetworkPolicyDisabled).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveHostedShellNetworkPolicyAllowlistParam',
    {
      'allowed_domains': ['private-typed-value'],
      'type': 'allowlist',
    },
    {
      'allowed_domains': ['private-typed-value'],
      'type': 'allowlist',
    },
    ['type', 'allowed_domains'],
    LiveHostedShellNetworkPolicyAllowlist.fromJson,
    (value) => (value as LiveHostedShellNetworkPolicyAllowlist).copyWith(),
    (value, raw) =>
        (value as LiveHostedShellNetworkPolicyAllowlist).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSkillReferenceParam',
    {'skill_id': 'private-typed-value', 'type': 'skill_reference'},
    {
      'skill_id': 'private-typed-value',
      'type': 'skill_reference',
      'version': 'private-typed-value',
    },
    ['type', 'skill_id'],
    LiveSkillReference.fromJson,
    (value) => (value as LiveSkillReference).copyWith(),
    (value, raw) => (value as LiveSkillReference).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveInlineSkillParam',
    {
      'description': 'private-typed-value',
      'name': 'private-typed-value',
      'source': {
        'data': 'private-typed-value',
        'media_type': 'application/zip',
        'type': 'base64',
      },
      'type': 'inline',
    },
    {
      'description': 'private-typed-value',
      'name': 'private-typed-value',
      'source': {
        'data': 'private-typed-value',
        'media_type': 'application/zip',
        'type': 'base64',
      },
      'type': 'inline',
    },
    ['type', 'name', 'description', 'source'],
    LiveInlineSkill.fromJson,
    (value) => (value as LiveInlineSkill).copyWith(),
    (value, raw) => (value as LiveInlineSkill).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveInlineSkillSourceParam',
    {
      'data': 'private-typed-value',
      'media_type': 'application/zip',
      'type': 'base64',
    },
    {
      'data': 'private-typed-value',
      'media_type': 'application/zip',
      'type': 'base64',
    },
    ['type', 'media_type', 'data'],
    LiveInlineSkillSource.fromJson,
    (value) => (value as LiveInlineSkillSource).copyWith(),
    (value, raw) => (value as LiveInlineSkillSource).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveLocalSkillParam',
    {
      'description': 'private-typed-value',
      'name': 'private-typed-value',
      'path': 'private-typed-value',
    },
    {
      'description': 'private-typed-value',
      'name': 'private-typed-value',
      'path': 'private-typed-value',
    },
    ['name', 'description', 'path'],
    LiveLocalSkill.fromJson,
    (value) => (value as LiveLocalSkill).copyWith(),
    (value, raw) => (value as LiveLocalSkill).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveFunctionToolChoiceParam',
    {'name': 'private-typed-value', 'type': 'function'},
    {'name': 'private-typed-value', 'type': 'function'},
    ['type', 'name'],
    LiveFunctionToolChoice.fromJson,
    (value) => (value as LiveFunctionToolChoice).copyWith(),
    (value, raw) => (value as LiveFunctionToolChoice).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveMCPToolChoiceParam',
    {'server_label': 'private-typed-value', 'type': 'mcp'},
    {
      'name': 'private-typed-value',
      'server_label': 'private-typed-value',
      'type': 'mcp',
    },
    ['type', 'server_label'],
    LiveMCPToolChoice.fromJson,
    (value) => (value as LiveMCPToolChoice).copyWith(),
    (value, raw) => (value as LiveMCPToolChoice).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificCustomToolParam',
    {'name': 'private-typed-value', 'type': 'custom'},
    {'name': 'private-typed-value', 'type': 'custom'},
    ['type', 'name'],
    LiveSpecificCustomTool.fromJson,
    (value) => (value as LiveSpecificCustomTool).copyWith(),
    (value, raw) => (value as LiveSpecificCustomTool).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveAllowedToolsChoiceParam',
    {
      'tools': [
        {'name': 'private-typed-value', 'type': 'function'},
      ],
      'type': 'allowed_tools',
    },
    {
      'mode': 'none',
      'tools': [
        {'name': 'private-typed-value', 'type': 'function'},
      ],
      'type': 'allowed_tools',
    },
    ['type', 'tools'],
    LiveAllowedToolsChoice.fromJson,
    (value) => (value as LiveAllowedToolsChoice).copyWith(),
    (value, raw) => (value as LiveAllowedToolsChoice).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificApplyPatchParam',
    {'type': 'apply_patch'},
    {'type': 'apply_patch'},
    ['type'],
    LiveSpecificApplyPatch.fromJson,
    (value) => (value as LiveSpecificApplyPatch).copyWith(),
    (value, raw) => (value as LiveSpecificApplyPatch).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificCodeInterpreterParam',
    {'type': 'code_interpreter'},
    {'type': 'code_interpreter'},
    ['type'],
    LiveSpecificCodeInterpreter.fromJson,
    (value) => (value as LiveSpecificCodeInterpreter).copyWith(),
    (value, raw) =>
        (value as LiveSpecificCodeInterpreter).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificComputerParam',
    {'type': 'computer'},
    {'type': 'computer'},
    ['type'],
    LiveSpecificComputer.fromJson,
    (value) => (value as LiveSpecificComputer).copyWith(),
    (value, raw) => (value as LiveSpecificComputer).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificFileSearchParam',
    {'type': 'file_search'},
    {'type': 'file_search'},
    ['type'],
    LiveSpecificFileSearch.fromJson,
    (value) => (value as LiveSpecificFileSearch).copyWith(),
    (value, raw) => (value as LiveSpecificFileSearch).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificFunctionShellParam',
    {'type': 'shell'},
    {'type': 'shell'},
    ['type'],
    LiveSpecificFunctionShell.fromJson,
    (value) => (value as LiveSpecificFunctionShell).copyWith(),
    (value, raw) => (value as LiveSpecificFunctionShell).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificImageGenParam',
    {'type': 'image_generation'},
    {'type': 'image_generation'},
    ['type'],
    LiveSpecificImageGen.fromJson,
    (value) => (value as LiveSpecificImageGen).copyWith(),
    (value, raw) => (value as LiveSpecificImageGen).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificProgrammaticToolCallingParam',
    {'type': 'programmatic_tool_calling'},
    {'type': 'programmatic_tool_calling'},
    ['type'],
    LiveSpecificProgrammaticToolCalling.fromJson,
    (value) => (value as LiveSpecificProgrammaticToolCalling).copyWith(),
    (value, raw) =>
        (value as LiveSpecificProgrammaticToolCalling).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificWebSearchParam',
    {'type': 'web_search'},
    {'type': 'web_search'},
    ['type'],
    LiveSpecificWebSearch.fromJson,
    (value) => (value as LiveSpecificWebSearch).copyWith(),
    (value, raw) => (value as LiveSpecificWebSearch).copyWith(rawJson: raw),
  ),
  _Fixture(
    'LiveSpecificWebSearchPreviewParam',
    {'type': 'web_search_preview'},
    {'type': 'web_search_preview'},
    ['type'],
    LiveSpecificWebSearchPreview.fromJson,
    (value) => (value as LiveSpecificWebSearchPreview).copyWith(),
    (value, raw) =>
        (value as LiveSpecificWebSearchPreview).copyWith(rawJson: raw),
  ),
];
