import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/models/responses/tools/code_interpreter_container.dart'
    as legacy;
import 'package:test/test.dart';

void main() {
  group('Container memory (CONT-01/07)', () {
    final limits = {
      ContainerMemoryLimit.gb1: '1g',
      ContainerMemoryLimit.gb4: '4g',
      ContainerMemoryLimit.gb16: '16g',
      ContainerMemoryLimit.gb64: '64g',
      const ContainerMemoryLimit('128g'): '128g',
    };
    for (final entry in limits.entries) {
      test('${entry.value} is shared by auto, creation, and response', () {
        final parsed = ContainerMemoryLimit.fromJson(entry.value);
        expect(parsed, entry.key);
        expect(parsed.hashCode, entry.key.hashCode);
        expect(parsed.copyWith(), parsed);
        expect(
          parsed.copyWith(value: 'future-memory').toJson(),
          'future-memory',
        );
        expect(parsed.toJson(), entry.value);
        expect(parsed.toString(), contains(entry.value));
        expect(CodeInterpreterContainer.auto(memoryLimit: parsed).toJson(), {
          'type': 'auto',
          'memory_limit': entry.value,
        });
        expect(
          CreateContainerRequest(name: 'fixture', memoryLimit: parsed).toJson(),
          {'name': 'fixture', 'memory_limit': entry.value},
        );
        final response = Container.fromJson({
          ..._responseJson(),
          'memory_limit': entry.value,
        });
        expect(response.memoryLimit, parsed);
        expect(response.copyWith().toJson()['memory_limit'], entry.value);
      });
    }

    test('existing Code Interpreter import re-exports shared types', () {
      expect(legacy.ContainerMemoryLimit.gb4, ContainerMemoryLimit.gb4);
      expect(
        legacy.ContainerNetworkPolicy.allowlist(['example.com']).toJson(),
        {
          'type': 'allowlist',
          'allowed_domains': ['example.com'],
        },
      );
    });

    test('automatic null memory normalizes to omission without a default', () {
      final auto = CodeInterpreterContainerAuto.fromJson(const {
        'type': 'auto',
        'memory_limit': null,
      });
      expect(auto.memoryLimit, isNull);
      expect(auto.toJson(), {'type': 'auto'});
      expect(CreateContainerRequest(name: 'fixture').toJson(), {
        'name': 'fixture',
      });
      expect(Container.fromJson(_responseJson()).memoryLimit, isNull);
    });

    test('wire memory rejects integer MB and other malformed values', () {
      for (final value in [1024, true, <String>[], <String, dynamic>{}]) {
        expect(
          () => ContainerMemoryLimit.fromJson(value),
          throwsFormatException,
          reason: '$value is not a memory string',
        );
        expect(
          () => CodeInterpreterContainerAuto.fromJson({
            'type': 'auto',
            'memory_limit': value,
          }),
          throwsFormatException,
        );
      }
    });
  });

  group('Network policy and secrets (CONT-02/03)', () {
    test('disabled equality respects subtype hash contracts', () {
      const base = ContainerNetworkPolicyDisabled();
      const subtype = _OtherDisabledPolicy();
      expect(base, isNot(subtype));
      expect(subtype, isNot(base));
      expect(subtype, const _OtherDisabledPolicy());
      expect(subtype.hashCode, const _OtherDisabledPolicy().hashCode);
    });

    test('allowlist uses canonical domains and ordered secrets', () {
      final policy = ContainerNetworkPolicy.allowlist(
        ['api.example.com', 'cdn.example.com'],
        domainSecrets: const [
          ContainerNetworkPolicyDomainSecret(
            domain: 'api.example.com',
            name: 'API_TOKEN',
            value: 'fixture-secret',
          ),
          ContainerNetworkPolicyDomainSecret(
            domain: 'cdn.example.com',
            name: 'CDN_TOKEN',
            value: 'second-secret',
          ),
        ],
      );
      final expected = {
        'type': 'allowlist',
        'allowed_domains': ['api.example.com', 'cdn.example.com'],
        'domain_secrets': [
          {
            'domain': 'api.example.com',
            'name': 'API_TOKEN',
            'value': 'fixture-secret',
          },
          {
            'domain': 'cdn.example.com',
            'name': 'CDN_TOKEN',
            'value': 'second-secret',
          },
        ],
      };
      expect(policy.toJson(), expected);
      expect(policy.allowedDomains, ['api.example.com', 'cdn.example.com']);
      expect(policy.toJson(), isNot(contains('allowed_hosts')));
      final restored = ContainerNetworkPolicy.fromJson(expected);
      expect(restored, policy);
      expect(restored.hashCode, policy.hashCode);
      expect(policy.copyWith(domainSecrets: null).toJson(), {
        'type': 'allowlist',
        'allowed_domains': ['api.example.com', 'cdn.example.com'],
      });
      expect(
        policy.copyWith(allowedDomains: ['different.example.com']),
        isNot(policy),
      );
      expect(policy.copyWith(domainSecrets: []), isNot(policy));
    });

    test('policy lists are snapshots and unmodifiable', () {
      final domains = ['api.example.com'];
      final secrets = <ContainerNetworkPolicyDomainSecret>[
        const ContainerNetworkPolicyDomainSecret(
          domain: 'api.example.com',
          name: 'TOKEN',
          value: 'fixture-secret',
        ),
      ];
      final policy = ContainerNetworkPolicyAllowlist(
        allowedDomains: domains,
        domainSecrets: secrets,
      );
      final hash = policy.hashCode;
      domains.add('mutated.example.com');
      secrets.clear();
      expect(policy.allowedDomains, ['api.example.com']);
      expect(policy.domainSecrets, hasLength(1));
      expect(policy.hashCode, hash);
      expect(() => policy.allowedDomains.add('other'), throwsUnsupportedError);
      expect(() => policy.domainSecrets!.clear(), throwsUnsupportedError);
    });

    test('domain secret copy, equality, and diagnostics cover every field', () {
      const secret = ContainerNetworkPolicyDomainSecret(
        domain: 'api.example.com',
        name: 'API_TOKEN',
        value: 'fixture-secret',
      );
      final restored = ContainerNetworkPolicyDomainSecret.fromJson(
        secret.toJson(),
      );
      expect(restored, secret);
      expect(restored.hashCode, secret.hashCode);
      expect(secret.copyWith(), secret);
      expect(secret.copyWith(domain: 'other'), isNot(secret));
      expect(secret.copyWith(name: 'OTHER'), isNot(secret));
      expect(secret.copyWith(value: 'different'), isNot(secret));
      expect(secret.toString(), isNot(contains('fixture-secret')));
      expect(secret.toJson()['value'], 'fixture-secret');
    });

    test('known policy discriminators and required fields are strict', () {
      for (final json in <Map<String, dynamic>>[
        {},
        {'type': null},
        {'type': 3},
        {'type': 'allowlist'},
        {'type': 'allowlist', 'allowed_domains': null},
        {'type': 'allowlist', 'allowed_domains': 'api.example.com'},
        {
          'type': 'allowlist',
          'allowed_domains': [7],
        },
        {
          'type': 'allowlist',
          'allowed_hosts': ['api.example.com'],
        },
        {
          'type': 'allowlist',
          'allowed_domains': <String>[],
          'domain_secrets': null,
        },
        {
          'type': 'allowlist',
          'allowed_domains': <String>[],
          'domain_secrets': [7],
        },
      ]) {
        expect(
          () => ContainerNetworkPolicy.fromJson(json),
          throwsFormatException,
        );
      }
      expect(
        () => ContainerNetworkPolicyAllowlist.fromJson(const {
          'type': 'disabled',
          'allowed_domains': <String>[],
        }),
        throwsFormatException,
      );
      expect(
        () => ContainerNetworkPolicyDisabled.fromJson(const {
          'type': 'allowlist',
        }),
        throwsFormatException,
      );
    });

    for (final field in ['domain', 'name', 'value']) {
      test('secret $field is a required nonnullable string', () {
        final valid = <String, dynamic>{
          'domain': 'api.example.com',
          'name': 'TOKEN',
          'value': 'fixture-secret',
        };
        expect(
          () => ContainerNetworkPolicyDomainSecret.fromJson(
            {...valid}..remove(field),
          ),
          throwsFormatException,
        );
        for (final invalid in [null, 1, true]) {
          expect(
            () => ContainerNetworkPolicyDomainSecret.fromJson({
              ...valid,
              field: invalid,
            }),
            throwsFormatException,
          );
        }
      });
    }
  });

  group('Skills (CONT-05)', () {
    test('reference versions preserve omission and numeric strings', () {
      for (final version in [null, 'latest', '7']) {
        final skill = ContainerSkill.reference(
          skillId: 'skill_fixture',
          version: version,
        );
        final expected = {
          'type': 'skill_reference',
          'skill_id': 'skill_fixture',
          'version': ?version,
        };
        expect(skill.toJson(), expected);
        final restored = ContainerSkill.fromJson(expected);
        expect(restored, skill);
        expect(restored.hashCode, skill.hashCode);
      }
      const reference = ContainerSkillReference(
        skillId: 'skill_fixture',
        version: '7',
      );
      expect(reference.copyWith(version: null).toJson(), {
        'type': 'skill_reference',
        'skill_id': 'skill_fixture',
      });
      expect(reference.copyWith(skillId: 'other'), isNot(reference));
    });

    test('inline source emits ZIP discriminator and unchanged raw base64', () {
      const source = Base64ContainerSkillSource(data: _bundle);
      const skill = InlineContainerSkill(
        name: 'wire-fixture',
        description: 'Serialization fixture',
        source: source,
      );
      final expected = {
        'type': 'inline',
        'name': 'wire-fixture',
        'description': 'Serialization fixture',
        'source': {
          'type': 'base64',
          'media_type': 'application/zip',
          'data': _bundle,
        },
      };
      expect(skill.toJson(), expected);
      expect(const ContainerSkillSource.base64(data: _bundle), source);
      final restored = ContainerSkill.fromJson(expected);
      expect(restored, skill);
      expect(restored.hashCode, skill.hashCode);
      expect(source.copyWith(data: 'different'), isNot(source));
      expect(skill.copyWith(name: 'different'), isNot(skill));
      expect(skill.copyWith(description: 'different'), isNot(skill));
      expect(
        skill.copyWith(source: source.copyWith(data: 'different')),
        isNot(skill),
      );
      expect(source.toString(), isNot(contains(_bundle)));
      expect(skill.toString(), isNot(contains(_bundle)));
    });

    test('known skill/source malformed fields and fixed values fail', () {
      for (final json in <Map<String, dynamic>>[
        {},
        {'type': null},
        {'type': 7},
        {'type': 'skill_reference'},
        {'type': 'skill_reference', 'skill_id': null},
        {'type': 'skill_reference', 'skill_id': 'skill_fixture', 'version': 7},
        {
          'type': 'skill_reference',
          'skill_id': 'skill_fixture',
          'version': null,
        },
        {'type': 'inline', 'name': 'n', 'description': 'd'},
        {
          'type': 'inline',
          'name': null,
          'description': 'd',
          'source': _sourceJson(),
        },
        {
          'type': 'inline',
          'name': 'n',
          'description': null,
          'source': _sourceJson(),
        },
        {'type': 'inline', 'name': 'n', 'description': 'd', 'source': null},
      ]) {
        expect(() => ContainerSkill.fromJson(json), throwsFormatException);
      }
      for (final json in <Map<String, dynamic>>[
        {},
        {'type': 'base64'},
        {'type': 'base64', 'media_type': 'application/zip'},
        {'type': 'base64', 'media_type': 'application/zip', 'data': null},
        {'type': 'base64', 'media_type': 'application/zip', 'data': 7},
        {'type': 'base64', 'media_type': 'text/plain', 'data': _bundle},
        {'type': 'base64', 'media_type': null, 'data': _bundle},
      ]) {
        expect(
          () => ContainerSkillSource.fromJson(json),
          throwsFormatException,
        );
      }
      expect(
        () => ContainerSkillReference.fromJson(const {
          'type': 'inline',
          'skill_id': 's',
        }),
        throwsFormatException,
      );
      expect(
        () => InlineContainerSkill.fromJson({
          'type': 'skill_reference',
          'name': 'n',
          'description': 'd',
          'source': _sourceJson(),
        }),
        throwsFormatException,
      );
      expect(
        () => Base64ContainerSkillSource.fromJson({
          ..._sourceJson(),
          'type': 'different',
        }),
        throwsFormatException,
      );
    });
  });

  group('Creation and automatic config (CONT-04/08)', () {
    test('full creation round-trips exact independent wire fixture', () {
      final request = CreateContainerRequest.fromJson(_creationJson());
      expect(request.toJson(), _creationJson());
      expect(request.memoryLimit, ContainerMemoryLimit.gb4);
      expect(request.skills![0], isA<ContainerSkillReference>());
      expect(request.skills![1], isA<InlineContainerSkill>());
      final duplicate = CreateContainerRequest.fromJson(_creationJson());
      expect(duplicate, request);
      expect(duplicate.hashCode, request.hashCode);
      expect(request.copyWith(), request);
      expect(request.toString(), isNot(contains('fixture-secret')));
      expect(request.toString(), isNot(contains(_bundle)));
    });

    test('empty name is allowed and omission does not invent defaults', () {
      expect(CreateContainerRequest(name: '').toJson(), {'name': ''});
      expect(
        CreateContainerRequest.fromJson(const {'name': 'fixture'}).toJson(),
        {'name': 'fixture'},
      );
      for (final json in <Map<String, dynamic>>[
        {},
        {'name': null},
        {'name': 7},
      ]) {
        expect(
          () => CreateContainerRequest.fromJson(json),
          throwsFormatException,
        );
      }
    });

    for (final field in [
      'file_ids',
      'expires_after',
      'memory_limit',
      'network_policy',
      'skills',
    ]) {
      test('creation rejects explicit null in $field', () {
        expect(
          () =>
              CreateContainerRequest.fromJson({'name': 'fixture', field: null}),
          throwsFormatException,
        );
      });
    }

    test('creation rejects malformed optional member types', () {
      for (final entry in <String, Object>{
        'file_ids': [7],
        'expires_after': 7,
        'memory_limit': 1024,
        'network_policy': [],
        'skills': [7],
      }.entries) {
        expect(
          () => CreateContainerRequest.fromJson({
            'name': 'fixture',
            entry.key: entry.value,
          }),
          throwsFormatException,
        );
      }
    });

    test('expiration request requires anchor and integer minutes', () {
      expect(
        ContainerExpiration.fromJson(const {
          'anchor': 'last_active_at',
          'minutes': 20,
        }).toJson(),
        {'anchor': 'last_active_at', 'minutes': 20},
      );
      for (final json in <Map<String, dynamic>>[
        {},
        {'anchor': 'last_active_at'},
        {'minutes': 20},
        {'anchor': null, 'minutes': 20},
        {'anchor': 7, 'minutes': 20},
        {'anchor': 'created_at', 'minutes': 20},
        {'anchor': 'last_active_at', 'minutes': null},
        {'anchor': 'last_active_at', 'minutes': 1.5},
        {'anchor': 'last_active_at', 'minutes': '20'},
      ]) {
        expect(() => ContainerExpiration.fromJson(json), throwsFormatException);
      }
    });

    test(
      'creation equality includes every setting and copy can clear optionals',
      () {
        final request = CreateContainerRequest.fromJson(_creationJson());
        for (final changed in [
          request.copyWith(name: 'different'),
          request.copyWith(fileIds: ['other']),
          request.copyWith(
            expiresAfter: const ContainerExpiration(
              anchor: 'last_active_at',
              minutes: 21,
            ),
          ),
          request.copyWith(memoryLimit: ContainerMemoryLimit.gb16),
          request.copyWith(networkPolicy: ContainerNetworkPolicy.disabled),
          request.copyWith(skills: []),
        ]) {
          expect(changed, isNot(request));
        }
        expect(
          request
              .copyWith(
                fileIds: null,
                expiresAfter: null,
                memoryLimit: null,
                networkPolicy: null,
                skills: null,
              )
              .toJson(),
          {'name': 'fixture-container'},
        );
      },
    );

    test('creation and auto snapshot file/skill lists', () {
      final files = ['file_fixture'];
      final skills = <ContainerSkill>[
        const ContainerSkillReference(skillId: 'skill_fixture'),
      ];
      final request = CreateContainerRequest(
        name: 'fixture',
        fileIds: files,
        skills: skills,
      );
      final auto = CodeInterpreterContainerAuto(fileIds: files);
      final requestHash = request.hashCode;
      final autoHash = auto.hashCode;
      files.clear();
      skills.clear();
      expect(request.fileIds, ['file_fixture']);
      expect(request.skills, hasLength(1));
      expect(auto.fileIds, ['file_fixture']);
      expect(request.hashCode, requestHash);
      expect(auto.hashCode, autoHash);
      expect(() => request.fileIds!.clear(), throwsUnsupportedError);
      expect(() => request.skills!.clear(), throwsUnsupportedError);
      expect(() => auto.fileIds!.clear(), throwsUnsupportedError);
    });

    test('nullable collection copies accept natural untyped empty lists', () {
      final request = CreateContainerRequest.fromJson(_creationJson());
      final emptyRequest = request.copyWith(fileIds: [], skills: []);
      expect(emptyRequest.fileIds, isEmpty);
      expect(emptyRequest.skills, isEmpty);
      expect(emptyRequest.toJson()['file_ids'], isEmpty);
      expect(emptyRequest.toJson()['skills'], isEmpty);
      expect(() => emptyRequest.fileIds!.add('other'), throwsUnsupportedError);
      expect(
        () => emptyRequest.skills!.add(
          const ContainerSkillReference(skillId: 'other'),
        ),
        throwsUnsupportedError,
      );

      final auto = CodeInterpreterContainerAuto(
        fileIds: const ['file_fixture'],
      );
      expect(auto.copyWith(fileIds: []).toJson(), {
        'type': 'auto',
        'file_ids': <String>[],
      });
      final policy = ContainerNetworkPolicyAllowlist(
        allowedDomains: const ['api.example.com'],
        domainSecrets: const [
          ContainerNetworkPolicyDomainSecret(
            domain: 'api.example.com',
            name: 'TOKEN',
            value: 'fixture-secret',
          ),
        ],
      );
      expect(policy.copyWith(domainSecrets: []).domainSecrets, isEmpty);
      final info = ContainerNetworkPolicyInfo(
        type: 'allowlist',
        allowedDomains: const ['api.example.com'],
      );
      expect(info.copyWith(allowedDomains: []).toJson(), {
        'type': 'allowlist',
        'allowed_domains': <String>[],
      });
    });

    test('auto copy clears settings and diagnostics redact nested secrets', () {
      final auto = CodeInterpreterContainerAuto.fromJson({
        'type': 'auto',
        'file_ids': const ['file_fixture'],
        'memory_limit': '4g',
        'network_policy': _creationJson()['network_policy'],
      });
      expect(auto.copyWith(), auto);
      expect(
        auto
            .copyWith(fileIds: null, memoryLimit: null, networkPolicy: null)
            .toJson(),
        {'type': 'auto'},
      );
      expect(auto.copyWith(fileIds: ['different']), isNot(auto));
      expect(
        auto.copyWith(memoryLimit: ContainerMemoryLimit.gb64),
        isNot(auto),
      );
      expect(
        auto.copyWith(networkPolicy: ContainerNetworkPolicy.disabled),
        isNot(auto),
      );
      expect(auto.toString(), isNot(contains('fixture-secret')));
      expect(
        ResponseTool.codeInterpreter(container: auto).toString(),
        isNot(contains('fixture-secret')),
      );
      expect(auto.toJson() as Map, isNot(contains('skills')));
      for (final json in <Map<String, dynamic>>[
        {},
        {'type': 'other'},
        {
          'type': 'auto',
          'file_ids': [7],
        },
        {'type': 'auto', 'file_ids': null},
        {'type': 'auto', 'network_policy': null},
      ]) {
        expect(
          () => CodeInterpreterContainerAuto.fromJson(json),
          throwsFormatException,
        );
      }
    });
  });

  group('Container response (CONT-06/08)', () {
    test(
      'response accepts independently optional expiration/policy members',
      () {
        for (final expiration in <Map<String, dynamic>>[
          {},
          {'anchor': 'last_active_at'},
          {'minutes': 20},
          {'anchor': 'last_active_at', 'minutes': 20},
        ]) {
          for (final policy in <Map<String, dynamic>>[
            {'type': 'allowlist'},
            {'type': 'allowlist', 'allowed_domains': <String>[]},
            {
              'type': 'allowlist',
              'allowed_domains': ['api.example.com'],
            },
            {'type': 'future_mode'},
          ]) {
            final json = {
              ..._responseJson(),
              'expires_after': expiration,
              'network_policy': policy,
            };
            final container = Container.fromJson(json);
            expect(container.toJson(), json);
            expect(container.expiresAfter, isA<ContainerExpirationInfo>());
            expect(container.networkPolicy, isA<ContainerNetworkPolicyInfo>());
            expect(container.toJson(), isNot(contains('skills')));
          }
        }
      },
    );

    test('zero timestamps and open status remain intact', () {
      final response = Container.fromJson({
        ..._responseJson(),
        'last_active_at': 0,
      });
      expect(response.createdAtDateTime.millisecondsSinceEpoch, 0);
      expect(response.lastActiveAtDateTime!.millisecondsSinceEpoch, 0);
      expect(response.isActive, isTrue);
      expect(response.copyWith(status: 'active').isActive, isTrue);
      expect(response.copyWith(status: 'future_status').isActive, isFalse);
      expect(
        response.copyWith(status: 'future_status').toJson()['status'],
        'future_status',
      );
    });

    for (final field in ['id', 'object', 'name', 'created_at', 'status']) {
      test('required $field does not receive a synthesized fallback', () {
        expect(
          () => Container.fromJson(_responseJson()..remove(field)),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains(field),
            ),
          ),
        );
        expect(
          () => Container.fromJson({..._responseJson(), field: null}),
          throwsFormatException,
        );
      });
    }

    test(
      'response optional members reject explicit null and malformed values',
      () {
        for (final field in [
          'last_active_at',
          'memory_limit',
          'expires_after',
          'network_policy',
        ]) {
          expect(
            () => Container.fromJson({..._responseJson(), field: null}),
            throwsFormatException,
          );
        }
        for (final json in <Map<String, dynamic>>[
          {'anchor': null},
          {'anchor': 'created_at'},
          {'minutes': null},
          {'minutes': 1.5},
          {'minutes': '20'},
        ]) {
          expect(
            () => ContainerExpirationInfo.fromJson(json),
            throwsFormatException,
          );
        }
        for (final json in <Map<String, dynamic>>[
          {},
          {'type': null},
          {'type': 7},
          {'type': 'allowlist', 'allowed_domains': null},
          {
            'type': 'allowlist',
            'allowed_domains': [7],
          },
        ]) {
          expect(
            () => ContainerNetworkPolicyInfo.fromJson(json),
            throwsFormatException,
          );
        }
      },
    );

    test('response full equality and nullable copy fields', () {
      final original = Container.fromJson({
        ..._responseJson(),
        'last_active_at': 0,
        'memory_limit': '4g',
        'expires_after': const {'anchor': 'last_active_at', 'minutes': 20},
        'network_policy': const {
          'type': 'allowlist',
          'allowed_domains': ['api.example.com'],
        },
      });
      expect(original.copyWith(), original);
      expect(original.copyWith().hashCode, original.hashCode);
      for (final changed in [
        original.copyWith(id: 'other'),
        original.copyWith(object: 'other'),
        original.copyWith(name: 'other'),
        original.copyWith(createdAt: 1),
        original.copyWith(status: 'other'),
        original.copyWith(lastActiveAt: 1),
        original.copyWith(memoryLimit: ContainerMemoryLimit.gb64),
        original.copyWith(
          expiresAfter: const ContainerExpirationInfo(minutes: 21),
        ),
        original.copyWith(
          networkPolicy: ContainerNetworkPolicyInfo(type: 'disabled'),
        ),
      ]) {
        expect(changed, isNot(original));
      }
      expect(
        original
            .copyWith(
              lastActiveAt: null,
              memoryLimit: null,
              expiresAfter: null,
              networkPolicy: null,
            )
            .toJson(),
        _responseJson(),
      );
      final expiration = original.expiresAfter!;
      expect(
        expiration.copyWith(anchor: null, minutes: null).toJson(),
        isEmpty,
      );
      final policy = original.networkPolicy!;
      expect(policy.copyWith(allowedDomains: null).toJson(), {
        'type': 'allowlist',
      });
      expect(policy.copyWith(type: 'other'), isNot(policy));
    });

    test('response policy snapshots domains', () {
      final domains = ['api.example.com'];
      final policy = ContainerNetworkPolicyInfo(
        type: 'allowlist',
        allowedDomains: domains,
      );
      final hash = policy.hashCode;
      domains.clear();
      expect(policy.allowedDomains, ['api.example.com']);
      expect(policy.hashCode, hash);
      expect(() => policy.allowedDomains!.clear(), throwsUnsupportedError);
    });

    test(
      'list required fields are strict and nullable cursors stay compatible',
      () {
        final valid = <String, dynamic>{
          'object': 'list',
          'data': <Object>[],
          'has_more': false,
        };
        for (final key in ['object', 'data', 'has_more']) {
          expect(
            () => ContainerList.fromJson({...valid}..remove(key)),
            throwsFormatException,
          );
          expect(
            () => ContainerList.fromJson({...valid, key: null}),
            throwsFormatException,
          );
        }
        for (final entry in <String, Object>{
          'object': 7,
          'data': [7],
          'has_more': 'false',
        }.entries) {
          expect(
            () => ContainerList.fromJson({...valid, entry.key: entry.value}),
            throwsFormatException,
          );
        }
        final list = ContainerList.fromJson({
          ...valid,
          'first_id': null,
          'last_id': null,
        });
        expect(list.firstId, isNull);
        expect(list.lastId, isNull);
        expect(list.toJson(), valid);
        expect(
          () => ContainerList.fromJson({...valid, 'object': 'container'}),
          throwsFormatException,
        );
      },
    );

    test(
      'list equality covers data and pagination with defensive snapshots',
      () {
        final container = Container.fromJson(_responseJson());
        final source = [container];
        final list = ContainerList(
          object: 'list',
          data: source,
          firstId: 'first',
          lastId: 'last',
          hasMore: false,
        );
        final restored = ContainerList.fromJson(list.toJson());
        expect(restored, list);
        expect(restored.hashCode, list.hashCode);
        final hash = list.hashCode;
        source.clear();
        expect(list.data, [container]);
        expect(list.hashCode, hash);
        expect(list.data.clear, throwsUnsupportedError);
        for (final changed in [
          list.copyWith(object: 'other'),
          list.copyWith(data: [container.copyWith(name: 'other')]),
          list.copyWith(firstId: 'other'),
          list.copyWith(lastId: 'other'),
          list.copyWith(hasMore: true),
        ]) {
          expect(changed, isNot(list));
        }
        expect(list.copyWith(firstId: null, lastId: null).toJson(), {
          'object': 'list',
          'data': [_responseJson()],
          'has_more': false,
        });
      },
    );
  });

  group('Unknown container variants (CONT-08)', () {
    test(
      'unknown Code Interpreter config is deeply immutable and equatable',
      () {
        _expectUnknownSnapshot<UnknownCodeInterpreterContainer>(
          parse: (json) =>
              CodeInterpreterContainer.fromJson(json)
                  as UnknownCodeInterpreterContainer,
          encode: (value) => value.toJson(),
          raw: (value) => value.rawJson,
          copy: (value, json) => value.copyWith(rawJson: json),
        );
      },
    );
    test('unknown network policy is deeply immutable and redacted', () {
      _expectUnknownSnapshot<UnknownContainerNetworkPolicy>(
        parse: (json) =>
            ContainerNetworkPolicy.fromJson(json)
                as UnknownContainerNetworkPolicy,
        encode: (value) => value.toJson(),
        raw: (value) => value.rawJson,
        copy: (value, json) => value.copyWith(rawJson: json),
      );
    });
    test('unknown skill is deeply immutable and redacted', () {
      _expectUnknownSnapshot<UnknownContainerSkill>(
        parse: (json) => ContainerSkill.fromJson(json) as UnknownContainerSkill,
        encode: (value) => value.toJson(),
        raw: (value) => value.rawJson,
        copy: (value, json) => value.copyWith(rawJson: json),
      );
    });
    test('unknown skill source is deeply immutable and redacted', () {
      _expectUnknownSnapshot<UnknownContainerSkillSource>(
        parse: (json) =>
            ContainerSkillSource.fromJson(json) as UnknownContainerSkillSource,
        encode: (value) => value.toJson(),
        raw: (value) => value.rawJson,
        copy: (value, json) => value.copyWith(rawJson: json),
      );
    });
  });
}

const _bundle = 'UEsFBgAAAAAAAAAAAAAAAAAAAAAAAA==';

Map<String, dynamic> _sourceJson() => {
  'type': 'base64',
  'media_type': 'application/zip',
  'data': _bundle,
};

Map<String, dynamic> _creationJson() => {
  'name': 'fixture-container',
  'file_ids': ['file_fixture'],
  'memory_limit': '4g',
  'expires_after': {'anchor': 'last_active_at', 'minutes': 20},
  'network_policy': {
    'type': 'allowlist',
    'allowed_domains': ['api.example.com'],
    'domain_secrets': [
      {
        'domain': 'api.example.com',
        'name': 'API_TOKEN',
        'value': 'fixture-secret',
      },
    ],
  },
  'skills': [
    {'type': 'skill_reference', 'skill_id': 'skill_fixture', 'version': '7'},
    {
      'type': 'inline',
      'name': 'wire-fixture',
      'description': 'Serialization fixture',
      'source': _sourceJson(),
    },
  ],
};

Map<String, dynamic> _responseJson() => {
  'id': 'cntr_fixture',
  'object': 'container',
  'name': 'fixture-container',
  'created_at': 0,
  'status': 'running',
};

void _expectUnknownSnapshot<T>({
  required T Function(Map<String, dynamic>) parse,
  required Object Function(T) encode,
  required Map<String, dynamic> Function(T) raw,
  required T Function(T, Map<String, dynamic>?) copy,
}) {
  final nested = <dynamic, dynamic>{
    'data': 'opaque-fixture-secret',
    'items': [
      1,
      <dynamic, dynamic>{'key': 'value'},
    ],
  };
  final source = <String, dynamic>{'type': 'future_variant', 'nested': nested};
  final expected = <String, dynamic>{
    'type': 'future_variant',
    'nested': {
      'data': 'opaque-fixture-secret',
      'items': [
        1,
        {'key': 'value'},
      ],
    },
  };
  final value = parse(source);
  final sameValue = parse({
    'nested': expected['nested'],
    'type': 'future_variant',
  });
  expect(value, sameValue);
  expect(value.hashCode, sameValue.hashCode);
  expect(copy(value, null), value);
  final different = parse({
    'type': 'future_variant',
    'nested': {'data': 'different'},
  });
  expect(different, isNot(value));
  final replacement = <String, dynamic>{
    'type': 'another_variant',
    'nested': {'data': 'replacement'},
  };
  final copied = copy(value, replacement);
  expect(encode(copied), replacement);
  expect(copied, isNot(value));
  (replacement['nested'] as Map<String, dynamic>)['data'] = 'mutated';
  expect(encode(copied), {
    'type': 'another_variant',
    'nested': {'data': 'replacement'},
  });
  final hash = value.hashCode;
  nested['data'] = 'mutated';
  (nested['items'] as List<Object?>).clear();
  source['type'] = 'mutated';
  expect(encode(value), expected);
  expect(value.hashCode, hash);
  expect(() => raw(value)['type'] = 'other', throwsUnsupportedError);
  final rawNested = raw(value)['nested'] as Map<String, dynamic>;
  expect(() => rawNested['data'] = 'other', throwsUnsupportedError);
  expect(
    () => (rawNested['items'] as List<Object?>).clear(),
    throwsUnsupportedError,
  );
  expect(value.toString(), isNot(contains('opaque-fixture-secret')));
  final encoded = encode(value) as Map<String, dynamic>;
  try {
    (encoded['nested'] as Map<String, dynamic>)['data'] = 'detached-mutation';
  } on UnsupportedError {
    // Returning an immutable snapshot or a mutable deep copy is valid.
  }
  expect(encode(value), expected);
  expect(
    () => parse({
      'type': 'future_variant',
      'nested': <dynamic, dynamic>{1: 'not a JSON key'},
    }),
    throwsFormatException,
  );
}

class _OtherDisabledPolicy extends ContainerNetworkPolicyDisabled {
  const _OtherDisabledPolicy();
}
