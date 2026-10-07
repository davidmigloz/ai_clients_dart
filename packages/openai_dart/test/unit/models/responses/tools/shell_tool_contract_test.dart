import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  Matcher formatError(String field) => throwsA(
    isA<FormatException>().having(
      (error) => error.message,
      'field context',
      contains(field),
    ),
  );

  Map<String, dynamic> autoJson() => {
    'type': 'container_auto',
    'file_ids': ['file-1', 'file-2'],
    'memory_limit': '4g',
    'network_policy': {
      'type': 'allowlist',
      'allowed_domains': ['example.invalid'],
      'domain_secrets': [
        {'domain': 'example.invalid', 'name': 'token', 'value': 'secret-value'},
      ],
    },
    'skills': [
      {'type': 'skill_reference', 'skill_id': 'skill-1', 'version': 'latest'},
      {
        'type': 'inline',
        'name': 'summary',
        'description': 'Summarize reports',
        'source': {
          'type': 'base64',
          'media_type': 'application/zip',
          'data': 'bundle-data',
        },
      },
    ],
  };

  Map<String, dynamic> localJson() => {
    'type': 'local',
    'skills': [
      {
        'name': 'summary',
        'description': 'Summarize reports',
        'path': '/private/skills/summary',
      },
    ],
  };

  const referenceJson = {
    'type': 'container_reference',
    'container_id': 'cntr-1',
  };

  group('Shell tool definition', () {
    test('const and no-argument convenience remain available', () {
      const tool = ShellTool();
      expect(tool.type, 'shell');
      expect(tool.toJson(), {'type': 'shell'});
      expect(ResponseTool.shell(), tool);
      expect(tool.copyWith(), tool);
      expect(tool.copyWith().hashCode, tool.hashCode);
      expect(
        tool.toString(),
        'ShellTool(environment: null, allowedCallers: null)',
      );
    });

    test('const with existing callers and new reference environment', () {
      const tool = ShellTool(
        environment: ShellToolEnvironment.containerReference(
          containerId: 'cntr-1',
        ),
        allowedCallers: [CallableToolAllowedCaller.direct],
      );
      expect(tool.toJson(), {
        'type': 'shell',
        'environment': referenceJson,
        'allowed_callers': ['direct'],
      });
    });

    test(
      'existing caller-owned lists are retained by constructor and copy',
      () {
        final callers = [CallableToolAllowedCaller.direct];
        final tool = ShellTool(allowedCallers: callers);
        expect(identical(tool.allowedCallers, callers), isTrue);
        expect(identical(tool.copyWith().allowedCallers, callers), isTrue);
        expect(
          identical(
            ResponseTool.shell(allowedCallers: callers).allowedCallers,
            callers,
          ),
          isTrue,
        );
      },
    );

    for (final environment in [autoJson(), localJson(), referenceJson]) {
      test('${environment['type']} survives public dispatch and factory', () {
        final json = {
          'type': 'shell',
          'environment': environment,
          'allowed_callers': ['direct', 'programmatic'],
        };
        final tool = ResponseTool.fromJson(json) as ShellTool;
        final equivalent = ResponseTool.shell(
          environment: ShellToolEnvironment.fromJson(environment),
          allowedCallers: const [
            CallableToolAllowedCaller.direct,
            CallableToolAllowedCaller.programmatic,
          ],
        );
        expect(tool.toJson(), json);
        expect(jsonDecode(jsonEncode(tool)), json);
        expect(tool, equivalent);
        expect(tool.hashCode, equivalent.hashCode);
        expect(tool.copyWith(), tool);
        expect(tool.copyWith().hashCode, tool.hashCode);
        expect(tool.toString(), contains('environment:'));
        expect(tool.toString(), contains('allowedCallers: 2 items'));
        expect(tool.toString(), isNot(contains('secret-value')));
        expect(tool.toString(), isNot(contains('bundle-data')));
        expect(tool.toString(), isNot(contains('/private/skills/summary')));
      });
    }

    test('optional nullable definition fields normalize null to omission', () {
      final tool = ShellTool.fromJson(const {
        'type': 'shell',
        'environment': null,
        'allowed_callers': null,
      });
      expect(tool, const ShellTool());
      expect(tool.toJson(), {'type': 'shell'});
    });

    test('empty caller list and empty environment fields remain present', () {
      final json = {
        'type': 'shell',
        'environment': {'type': 'local', 'skills': <Object>[]},
        'allowed_callers': <String>[],
      };
      expect(ShellTool.fromJson(json).toJson(), json);
    });

    test('parsed caller list is immutable', () {
      final json = {
        'type': 'shell',
        'allowed_callers': ['direct'],
      };
      final tool = ShellTool.fromJson(json);
      (json['allowed_callers']! as List).add('programmatic');
      expect(tool.allowedCallers, [CallableToolAllowedCaller.direct]);
      expect(() => tool.allowedCallers!.clear(), throwsUnsupportedError);
    });

    test('unknown existing allowed-caller strings use enum fallback', () {
      final tool = ShellTool.fromJson(const {
        'type': 'shell',
        'allowed_callers': ['future-caller'],
      });
      expect(tool.allowedCallers, [CallableToolAllowedCaller.unknown]);
      expect(tool.toJson()['allowed_callers'], ['unknown']);
    });

    test('copy changes and clears every definition field', () {
      final tool = ShellTool.fromJson({
        'type': 'shell',
        'environment': autoJson(),
        'allowed_callers': const ['direct'],
      });
      final changed = tool.copyWith(
        environment: LocalShellToolEnvironment(),
        allowedCallers: const [CallableToolAllowedCaller.programmatic],
      );
      expect(changed.environment, LocalShellToolEnvironment());
      expect(changed.allowedCallers, [CallableToolAllowedCaller.programmatic]);
      expect(changed, isNot(tool));
      expect(
        tool.copyWith(environment: null, allowedCallers: null),
        const ShellTool(),
      );
      expect(
        tool.copyWith(environment: null).allowedCallers,
        tool.allowedCallers,
      );
      expect(tool.copyWith(allowedCallers: null).environment, tool.environment);
      expect(
        tool.copyWith(environment: LocalShellToolEnvironment()),
        isNot(tool),
      );
      expect(tool.copyWith(allowedCallers: const []), isNot(tool));
    });

    for (final value in <Object?>[null, 'other', 3, [], {}]) {
      test('direct factory rejects invalid discriminator $value', () {
        expect(
          () => ShellTool.fromJson({'type': value}),
          formatError('ShellTool.type'),
        );
      });
    }
    test('direct factory rejects missing discriminator', () {
      expect(() => ShellTool.fromJson(const {}), formatError('ShellTool.type'));
    });
    for (final value in <Object>[3, 'bad', false, []]) {
      test('environment rejects malformed container $value', () {
        expect(
          () => ShellTool.fromJson({'type': 'shell', 'environment': value}),
          formatError('ShellTool.environment'),
        );
      });
    }
    for (final value in <Object>[3, 'bad', false, {}]) {
      test('allowed callers reject malformed container $value', () {
        expect(
          () => ShellTool.fromJson({'type': 'shell', 'allowed_callers': value}),
          formatError('ShellTool.allowed_callers'),
        );
      });
    }
    for (final value in <Object?>[null, 3, false, {}, []]) {
      test('allowed callers reject malformed element $value', () {
        expect(
          () => ShellTool.fromJson({
            'type': 'shell',
            'allowed_callers': [value],
          }),
          formatError('ShellTool.allowed_callers[0]'),
        );
      });
    }
    test('nested environment errors retain definition context', () {
      expect(
        () => ShellTool.fromJson(const {
          'type': 'shell',
          'environment': {'type': 'container_reference'},
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'nested context',
            allOf(contains('ShellTool.environment'), contains('container_id')),
          ),
        ),
      );
    });
  });

  group('Automatic shell tool environment', () {
    test(
      'round-trips reused memory/network and both hosted skill variants',
      () {
        final json = autoJson();
        final value =
            ShellToolEnvironment.fromJson(json)
                as ContainerAutoShellToolEnvironment;
        expect(value.type, 'container_auto');
        expect(value.fileIds, ['file-1', 'file-2']);
        expect(value.memoryLimit, ContainerMemoryLimit.gb4);
        expect(value.networkPolicy, isA<ContainerNetworkPolicyAllowlist>());
        expect(value.skills![0], isA<ContainerSkillReference>());
        expect(value.skills![1], isA<InlineContainerSkill>());
        expect(value.toJson(), json);
        expect(jsonDecode(jsonEncode(value)), json);
        expect(value.copyWith(), value);
        expect(value.copyWith().hashCode, value.hashCode);
        expect(
          ShellToolEnvironment.containerAuto(
            fileIds: value.fileIds,
            memoryLimit: value.memoryLimit,
            networkPolicy: value.networkPolicy,
            skills: value.skills,
          ),
          value,
        );
      },
    );

    test('minimal and explicitly empty configurations remain distinct', () {
      final minimal = ContainerAutoShellToolEnvironment();
      final empty = ContainerAutoShellToolEnvironment(
        fileIds: const [],
        skills: const [],
      );
      expect(minimal.toJson(), {'type': 'container_auto'});
      expect(empty.toJson(), {
        'type': 'container_auto',
        'file_ids': <String>[],
        'skills': <Object>[],
      });
      expect(minimal, isNot(empty));
      expect(minimal.toString(), contains('fileIds: null'));
      expect(minimal.toString(), contains('skills: null'));
      expect(empty.toString(), contains('fileIds: 0 items'));
      expect(empty.toString(), contains('skills: 0 items'));
    });

    test(
      'explicit nullable memory normalizes to omission and preserves future values',
      () {
        expect(
          ContainerAutoShellToolEnvironment.fromJson(const {
            'type': 'container_auto',
            'memory_limit': null,
          }).toJson(),
          {'type': 'container_auto'},
        );
        final future = ContainerAutoShellToolEnvironment.fromJson(const {
          'type': 'container_auto',
          'memory_limit': '128g',
        });
        expect(future.memoryLimit, const ContainerMemoryLimit('128g'));
        expect(future.toJson()['memory_limit'], '128g');
      },
    );

    test('constructor and parser freeze file and skill lists', () {
      final files = ['file-1'];
      final skills = <ContainerSkill>[
        const ContainerSkill.reference(skillId: 'skill-1'),
      ];
      final value = ContainerAutoShellToolEnvironment(
        fileIds: files,
        skills: skills,
      );
      files.add('file-2');
      skills.clear();
      expect(value.fileIds, ['file-1']);
      expect(value.skills, [
        const ContainerSkill.reference(skillId: 'skill-1'),
      ]);
      expect(() => value.fileIds!.clear(), throwsUnsupportedError);
      expect(() => value.skills!.clear(), throwsUnsupportedError);
      final json = autoJson();
      final parsed = ContainerAutoShellToolEnvironment.fromJson(json);
      (json['file_ids'] as List).clear();
      (json['skills'] as List).clear();
      expect(parsed.fileIds, ['file-1', 'file-2']);
      expect(parsed.skills, hasLength(2));
      expect(() => parsed.fileIds!.clear(), throwsUnsupportedError);
      expect(() => parsed.skills!.clear(), throwsUnsupportedError);
    });

    test('copy replaces and clears each optional setting', () {
      final value = ContainerAutoShellToolEnvironment.fromJson(autoJson());
      final changed = value.copyWith(
        fileIds: const ['file-3'],
        memoryLimit: ContainerMemoryLimit.gb16,
        networkPolicy: ContainerNetworkPolicy.disabled,
        skills: const [ContainerSkill.reference(skillId: 'skill-2')],
      );
      expect(changed.fileIds, ['file-3']);
      expect(changed.memoryLimit, ContainerMemoryLimit.gb16);
      expect(changed.networkPolicy, ContainerNetworkPolicy.disabled);
      expect(changed.skills, [
        const ContainerSkill.reference(skillId: 'skill-2'),
      ]);
      expect(changed, isNot(value));
      expect(
        value.copyWith(
          fileIds: null,
          memoryLimit: null,
          networkPolicy: null,
          skills: null,
        ),
        ContainerAutoShellToolEnvironment(),
      );
      expect(value.copyWith(fileIds: null).fileIds, isNull);
      expect(value.copyWith(memoryLimit: null).memoryLimit, isNull);
      expect(value.copyWith(networkPolicy: null).networkPolicy, isNull);
      expect(value.copyWith(skills: null).skills, isNull);
      expect(value.copyWith(fileIds: const ['different']), isNot(value));
      expect(
        value.copyWith(memoryLimit: ContainerMemoryLimit.gb1),
        isNot(value),
      );
      expect(
        value.copyWith(networkPolicy: ContainerNetworkPolicy.disabled),
        isNot(value),
      );
      expect(value.copyWith(skills: const []), isNot(value));
      final equivalent = ContainerAutoShellToolEnvironment.fromJson(autoJson());
      expect(value, equivalent);
      expect(value.hashCode, equivalent.hashCode);
    });

    test('diagnostics show every field without nested secrets or bundles', () {
      final value = ContainerAutoShellToolEnvironment.fromJson(autoJson());
      final text = value.toString();
      for (final field in [
        'fileIds:',
        'memoryLimit:',
        'networkPolicy:',
        'skills:',
      ]) {
        expect(text, contains(field));
      }
      expect(text, isNot(contains('secret-value')));
      expect(text, isNot(contains('bundle-data')));
      expect(text, isNot(contains('Summarize reports')));
    });

    for (final field in ['file_ids', 'skills', 'network_policy']) {
      for (final value in <Object?>[null, 3, 'bad', false]) {
        test('rejects malformed nonnullable $field $value', () {
          expect(
            () => ContainerAutoShellToolEnvironment.fromJson({
              'type': 'container_auto',
              field: value,
            }),
            formatError('ContainerAutoShellToolEnvironment.$field'),
          );
        });
      }
    }
    for (final field in ['file_ids', 'skills']) {
      test('rejects object instead of $field array', () {
        expect(
          () => ContainerAutoShellToolEnvironment.fromJson({
            'type': 'container_auto',
            field: const <String, dynamic>{},
          }),
          formatError('ContainerAutoShellToolEnvironment.$field'),
        );
      });
    }
    for (final value in <Object?>[null, 3, false, [], {}]) {
      test('rejects malformed file element $value', () {
        expect(
          () => ContainerAutoShellToolEnvironment.fromJson({
            'type': 'container_auto',
            'file_ids': [value],
          }),
          formatError('ContainerAutoShellToolEnvironment.file_ids[0]'),
        );
      });
    }
    for (final value in <Object?>[null, 3, false, [], 'bad']) {
      test('rejects malformed skill element $value', () {
        expect(
          () => ContainerAutoShellToolEnvironment.fromJson({
            'type': 'container_auto',
            'skills': [value],
          }),
          formatError('ContainerAutoShellToolEnvironment.skills[0]'),
        );
      });
    }
    for (final value in <Object>[3, false, [], {}]) {
      test('rejects malformed nullable memory $value', () {
        expect(
          () => ContainerAutoShellToolEnvironment.fromJson({
            'type': 'container_auto',
            'memory_limit': value,
          }),
          formatError('ContainerAutoShellToolEnvironment.memory_limit'),
        );
      });
    }
    test('malformed known hosted skill retains parent element context', () {
      expect(
        () => ContainerAutoShellToolEnvironment.fromJson(const {
          'type': 'container_auto',
          'skills': [
            {'type': 'skill_reference'},
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'nested context',
            allOf(
              contains('ContainerAutoShellToolEnvironment.skills[0]'),
              contains('skill_id'),
            ),
          ),
        ),
      );
    });
    test('malformed known network policy retains parent context', () {
      expect(
        () => ContainerAutoShellToolEnvironment.fromJson(const {
          'type': 'container_auto',
          'network_policy': {'type': 'allowlist'},
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'nested context',
            allOf(
              contains('ContainerAutoShellToolEnvironment.network_policy'),
              contains('allowed_domains'),
            ),
          ),
        ),
      );
    });
    test('future nested hosted skill and policy remain lossless', () {
      const json = {
        'type': 'container_auto',
        'network_policy': {
          'type': 'future-policy',
          'nested': {
            'secret': ['opaque'],
          },
        },
        'skills': [
          {
            'type': 'future-skill',
            'nested': {
              'bundle': ['opaque'],
            },
          },
        ],
      };
      final value = ContainerAutoShellToolEnvironment.fromJson(json);
      expect(value.toJson(), json);
      expect(value.networkPolicy, isA<UnknownContainerNetworkPolicy>());
      expect(value.skills!.single, isA<UnknownContainerSkill>());
      expect(value.toString(), isNot(contains('opaque')));
    });
  });

  group('Local shell tool environment and skill', () {
    test('round-trips local skills without hosted discriminators', () {
      final json = localJson();
      final value =
          ShellToolEnvironment.fromJson(json) as LocalShellToolEnvironment;
      expect(value.type, 'local');
      expect(value.toJson(), json);
      expect(jsonDecode(jsonEncode(value)), json);
      expect(value, ShellToolEnvironment.local(skills: value.skills));
      expect(value.copyWith(), value);
      expect(value.copyWith().hashCode, value.hashCode);
      expect(value.toJson()['skills'], [
        {
          'name': 'summary',
          'description': 'Summarize reports',
          'path': '/private/skills/summary',
        },
      ]);
    });
    test('minimal/empty skills and nullable copy clear stay distinct', () {
      final minimal = LocalShellToolEnvironment();
      final empty = LocalShellToolEnvironment(skills: const []);
      expect(minimal.toJson(), {'type': 'local'});
      expect(empty.toJson(), {'type': 'local', 'skills': <Object>[]});
      expect(minimal, isNot(empty));
      expect(empty.copyWith(skills: null), minimal);
      expect(empty.toString(), 'LocalShellToolEnvironment(skills: 0 items)');
      expect(minimal.toString(), 'LocalShellToolEnvironment(skills: null)');
    });
    test('constructor and parser snapshot the local skill list', () {
      const skill = ShellLocalSkill(name: 'n', description: 'd', path: 'p');
      final skills = [skill];
      final value = LocalShellToolEnvironment(skills: skills);
      skills.clear();
      expect(value.skills, [skill]);
      expect(() => value.skills!.clear(), throwsUnsupportedError);
      final json = localJson();
      final parsed = LocalShellToolEnvironment.fromJson(json);
      (json['skills'] as List).clear();
      expect(parsed.skills, hasLength(1));
      expect(() => parsed.skills!.clear(), throwsUnsupportedError);
      expect(value.copyWith(skills: const []).skills, isEmpty);
      expect(value.copyWith(skills: const []), isNot(value));
      expect(value.copyWith(skills: null).skills, isNull);
    });
    test(
      'local skill has complete copy, equality/hash and safe diagnostics',
      () {
        const skill = ShellLocalSkill(
          name: 'private-name',
          description: 'private-description',
          path: '/private/path',
        );
        expect(ShellLocalSkill.fromJson(skill.toJson()), skill);
        expect(
          ShellLocalSkill.fromJson(skill.toJson()).hashCode,
          skill.hashCode,
        );
        expect(skill.copyWith(), skill);
        expect(skill.copyWith(name: 'other').name, 'other');
        expect(skill.copyWith(description: 'other').description, 'other');
        expect(skill.copyWith(path: 'other').path, 'other');
        expect(skill.copyWith(name: 'other'), isNot(skill));
        expect(skill.copyWith(description: 'other'), isNot(skill));
        expect(skill.copyWith(path: 'other'), isNot(skill));
        final text = skill.toString();
        for (final field in ['name:', 'description:', 'path:']) {
          expect(text, contains(field));
        }
        for (final content in [
          'private-name',
          'private-description',
          '/private/path',
        ]) {
          expect(text, isNot(contains(content)));
        }
      },
    );
    for (final value in <Object?>[null, 3, 'bad', false, {}]) {
      test('rejects malformed nonnullable local skills $value', () {
        expect(
          () => LocalShellToolEnvironment.fromJson({
            'type': 'local',
            'skills': value,
          }),
          formatError('LocalShellToolEnvironment.skills'),
        );
      });
    }
    for (final value in <Object?>[null, 3, 'bad', false, []]) {
      test('rejects malformed local skill element $value', () {
        expect(
          () => LocalShellToolEnvironment.fromJson({
            'type': 'local',
            'skills': [value],
          }),
          formatError('LocalShellToolEnvironment.skills[0]'),
        );
      });
    }
    for (final field in ['name', 'description', 'path']) {
      test('local skill rejects omitted required $field', () {
        final json = {'name': 'n', 'description': 'd', 'path': 'p'}
          ..remove(field);
        expect(
          () => ShellLocalSkill.fromJson(json),
          formatError('ShellLocalSkill.$field'),
        );
      });
      for (final value in <Object?>[null, 3, false, [], {}]) {
        test('local skill rejects malformed required $field $value', () {
          final json = <String, dynamic>{
            'name': 'n',
            'description': 'd',
            'path': 'p',
            field: value,
          };
          expect(
            () => ShellLocalSkill.fromJson(json),
            formatError('ShellLocalSkill.$field'),
          );
        });
      }
    }
    test(
      'malformed known local skill preserves environment element context',
      () {
        expect(
          () => LocalShellToolEnvironment.fromJson(const {
            'type': 'local',
            'skills': [
              {'name': 'n'},
            ],
          }),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'nested context',
              allOf(
                contains('LocalShellToolEnvironment.skills[0]'),
                contains('description'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Container reference environment', () {
    test('const factory, parser and copies preserve reference field', () {
      const value = ShellToolEnvironment.containerReference(
        containerId: 'cntr-1',
      );
      final parsed =
          ShellToolEnvironment.fromJson(referenceJson)
              as ContainerReferenceShellToolEnvironment;
      expect(value, parsed);
      expect(value.hashCode, parsed.hashCode);
      expect(parsed.toJson(), referenceJson);
      expect(parsed.copyWith(), parsed);
      expect(parsed.copyWith().hashCode, parsed.hashCode);
      expect(parsed.copyWith(containerId: 'cntr-2').containerId, 'cntr-2');
      expect(parsed.copyWith(containerId: 'cntr-2'), isNot(parsed));
      expect(parsed.toString(), contains('containerId: [6 chars]'));
      expect(parsed.toString(), isNot(contains('cntr-1')));
    });
    test('missing container ID is rejected', () {
      expect(
        () => ContainerReferenceShellToolEnvironment.fromJson(const {
          'type': 'container_reference',
        }),
        formatError('container_id'),
      );
    });
    for (final value in <Object?>[null, 3, false, [], {}]) {
      test('malformed container ID $value is rejected', () {
        expect(
          () => ContainerReferenceShellToolEnvironment.fromJson({
            'type': 'container_reference',
            'container_id': value,
          }),
          formatError('container_id'),
        );
      });
    }
  });

  group('Environment dispatch and future compatibility', () {
    for (final value in <Object?>[null, 3, false, [], {}]) {
      test('parent rejects malformed type $value', () {
        expect(
          () => ShellToolEnvironment.fromJson({'type': value}),
          formatError('ShellToolEnvironment.type'),
        );
      });
    }
    test('parent rejects missing type', () {
      expect(
        () => ShellToolEnvironment.fromJson(const {}),
        formatError('ShellToolEnvironment.type'),
      );
    });
    final parsers =
        <String, ShellToolEnvironment Function(Map<String, dynamic>)>{
          'container_auto': ContainerAutoShellToolEnvironment.fromJson,
          'local': LocalShellToolEnvironment.fromJson,
          'container_reference':
              ContainerReferenceShellToolEnvironment.fromJson,
        };
    for (final entry in parsers.entries) {
      for (final value in <Object?>[null, 'wrong', 3, false, [], {}]) {
        test('direct ${entry.key} parser rejects discriminator $value', () {
          expect(
            () => entry.value({'type': value, 'container_id': 'cntr-1'}),
            formatError('.type'),
          );
        });
      }
      test('direct ${entry.key} parser rejects missing discriminator', () {
        expect(() => entry.value(const {}), formatError('.type'));
      });
    }
    test('Code Interpreter auto is retained as an unknown shell variant', () {
      final value = ShellToolEnvironment.fromJson(const {'type': 'auto'});
      expect(value, isA<UnknownShellToolEnvironment>());
      expect(value.toJson(), {'type': 'auto'});
      expect(ContainerAutoShellToolEnvironment().type, 'container_auto');
    });
    test(
      'unknown environment snapshots deeply and uses insertion-order-independent equality',
      () {
        final raw = <String, dynamic>{
          'type': 'future-environment',
          'nested': <String, dynamic>{
            'b': <Object?>[
              1,
              {'secret': 'private'},
            ],
            'a': null,
          },
        };
        final value =
            ShellToolEnvironment.fromJson(raw) as UnknownShellToolEnvironment;
        final equivalent = UnknownShellToolEnvironment(const {
          'nested': {
            'a': null,
            'b': <Object?>[
              1,
              {'secret': 'private'},
            ],
          },
          'type': 'future-environment',
        });
        expect(value, equivalent);
        expect(value.hashCode, equivalent.hashCode);
        expect(ShellToolEnvironment.fromJson(value.toJson()), value);
        expect(value.copyWith(), value);
        expect(value.copyWith().hashCode, value.hashCode);
        (raw['nested'] as Map)['a'] = 'changed';
        ((raw['nested'] as Map)['b'] as List).clear();
        expect(value, equivalent);
        expect(value.rawJson.clear, throwsUnsupportedError);
        expect(
          () => (value.rawJson['nested'] as Map).clear(),
          throwsUnsupportedError,
        );
        expect(
          () => ((value.rawJson['nested'] as Map)['b'] as List).clear(),
          throwsUnsupportedError,
        );
        final nestedLeaf =
            ((value.rawJson['nested'] as Map)['b'] as List)[1] as Map;
        expect(nestedLeaf.clear, throwsUnsupportedError);
        expect(value.toString(), contains('type: future-environment'));
        expect(value.toString(), contains('rawJson: 2 entries'));
        expect(value.toString(), isNot(contains('private')));
        final changed = value.copyWith(
          rawJson: {'type': 'next-environment', 'extra': true},
        );
        expect(changed.type, 'next-environment');
        expect(changed.toJson(), {'type': 'next-environment', 'extra': true});
        expect(changed, isNot(value));
      },
    );
    test(
      'unknown definition environment survives public ResponseTool round-trip',
      () {
        const json = {
          'type': 'shell',
          'environment': {
            'type': 'future-environment',
            'nested': {
              'values': [1, null],
            },
          },
        };
        final tool = ResponseTool.fromJson(json) as ShellTool;
        expect(tool.environment, isA<UnknownShellToolEnvironment>());
        expect(tool.toJson(), json);
        expect(ResponseTool.fromJson(tool.toJson()), tool);
        expect(ResponseTool.fromJson(tool.toJson()).hashCode, tool.hashCode);
      },
    );
  });
}
