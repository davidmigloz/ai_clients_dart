import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_wire_fixtures.dart';

void main() {
  group('Frozen saved-agent source corpus', () {
    for (final fixture in agentWireFixtures) {
      for (final wireValue in fixture.knownValues) {
        test('${fixture.schema} enum member $wireValue and future copying', () {
          final value = fixture.parse(wireValue);
          expect(value.toJson(), wireValue);
          expect((value as dynamic).isKnown, true);
          final copied = (value as dynamic).copyWith() as AgentJsonModel;
          expect(copied, value);
          expect(copied.hashCode, value.hashCode);
          final future = fixture.parse('PRIVATE-future-enum');
          expect((future as dynamic).isKnown, false);
          expect(future.toJson(), 'PRIVATE-future-enum');
          expect(future.toString(), isNot(contains('PRIVATE')));
          final futureCopy = (future as dynamic).copyWith() as AgentJsonModel;
          expect(futureCopy.toJson(), 'PRIVATE-future-enum');
        });
      }
      for (final (label, source) in [
        ('minimal', fixture.minimal),
        ('full', fixture.full),
      ]) {
        test(
          '${fixture.schema} $label round-trip and full value semantics',
          () {
            final json = jsonDecode(jsonEncode(source));
            final value = fixture.parse(json);
            expect(value.toJson(), source);
            final roundTrip = fixture.parse(
              jsonDecode(jsonEncode(value.toJson())),
            );
            expect(roundTrip, value);
            expect(roundTrip.hashCode, value.hashCode);
            expect(value.toString(), isNot(contains('PRIVATE')));
            if (json is Map<String, dynamic>) {
              // All actual object/variant types expose a public copy operation.
              final copy = (value as dynamic).copyWith() as AgentJsonModel;
              expect(copy.toJson(), source);
              expect(copy, value);
              expect(copy.hashCode, value.hashCode);
            }
          },
        );
      }
      for (final key in fixture.requiredKeys) {
        test('${fixture.schema} requires $key even if nullable', () {
          final json =
              jsonDecode(jsonEncode(fixture.full)) as Map<String, dynamic>
                ..remove(key);
          expect(() => fixture.parse(json), throwsA(isA<FormatException>()));
        });
      }
      if (fixture.full is Map<String, dynamic>) {
        final source = fixture.full! as Map<String, dynamic>;
        for (final key in source.keys) {
          test('${fixture.schema} malformed $key fails safely', () {
            final json = jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
            final old = json[key];
            json[key] = switch (old) {
              String() => <String, dynamic>{'PRIVATE-malformed': true},
              bool() || num() => 'PRIVATE-malformed',
              _ => false,
            };
            expect(
              () => fixture.parse(json),
              throwsA(
                isA<FormatException>().having(
                  (error) => error.toString(),
                  'private field values',
                  isNot(contains('PRIVATE-malformed')),
                ),
              ),
            );
          });
          if (!fixture.nullableKeys.contains(key)) {
            test('${fixture.schema} rejects explicit null for $key', () {
              final json =
                  jsonDecode(jsonEncode(source)) as Map<String, dynamic>
                    ..[key] = null;
              expect(
                () => fixture.parse(json),
                throwsA(isA<FormatException>()),
              );
            });
          }
        }
        if (fixture.writable) {
          test('${fixture.schema} is a closed writable object', () {
            final json = jsonDecode(jsonEncode(source)) as Map<String, dynamic>
              ..['PRIVATE-extra-key'] = 'PRIVATE-extra-value';
            expect(
              () => fixture.parse(json),
              throwsA(
                isA<FormatException>().having(
                  (error) => error.toString(),
                  'private extras',
                  isNot(contains('PRIVATE-extra')),
                ),
              ),
            );
          });
        }
      }
    }
  });

  test('Every optional nullable update field keeps all three states', () {
    final omitted = UpdateAgentRequest();
    final cleared = UpdateAgentRequest(
      clearInstructions: true,
      clearMetadata: true,
      clearMultiAgent: true,
      clearName: true,
      clearReasoning: true,
      clearServiceTier: true,
      clearText: true,
      clearTools: true,
    );
    expect(omitted.toJson(), isEmpty);
    expect(cleared.toJson(), {
      'instructions': null,
      'metadata': null,
      'multi_agent': null,
      'name': null,
      'reasoning': null,
      'service_tier': null,
      'text': null,
      'tools': null,
    });
    expect(cleared, isNot(omitted));
    expect(cleared.copyWith(), cleared);
    expect(UpdateAgentRequest.fromJson(cleared.toJson()), cleared);
    expect(
      cleared.copyWith(name: 'replacement').toJson()['name'],
      'replacement',
    );
    expect(
      cleared.copyWith(clearName: false).toJson().containsKey('name'),
      false,
    );
    final named = UpdateAgentRequest(name: 'PRIVATE-name');
    expect(named.copyWith().toJson(), {'name': 'PRIVATE-name'});
    expect(named.copyWith(name: null).toJson(), {'name': null});
    expect(named.copyWith(name: null, clearName: false).toJson(), isEmpty);
    expect(
      () => UpdateAgentRequest.fromJson(const {'model': null}),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'Copies own replacement maps and preserve explicit clear precedence',
    () {
      final metadata = <String, String>{'PRIVATE-key': 'PRIVATE-value'};
      final original = UpdateAgentRequest(metadata: metadata, name: 'named');
      metadata.clear();
      expect(original.metadata, {'PRIVATE-key': 'PRIVATE-value'});
      expect(() => original.metadata!.clear(), throwsUnsupportedError);
      final replacement = <String, String>{'replacement': 'value'};
      final copy = original.copyWith(metadata: replacement, name: null);
      replacement.clear();
      expect(copy.metadata, {'replacement': 'value'});
      expect(copy.toJson()['name'], null);
      final cleared = original.copyWith(clearMetadata: true);
      expect(cleared.metadata, null);
      expect(cleared.toJson()['metadata'], null);
      expect(cleared, UpdateAgentRequest(name: 'named', clearMetadata: true));
      expect(
        cleared.hashCode,
        UpdateAgentRequest(name: 'named', clearMetadata: true).hashCode,
      );
    },
  );

  test('Function parameters and MCP metadata own finite nested JSON', () {
    final values = <Object?>['PRIVATE-value', false, null];
    final nested = <String, dynamic>{'values': values};
    final parameters = <String, dynamic>{'nested': nested};
    final tool =
        AgentTool.function(
              name: 'function',
              description: 'description',
              parameters: parameters,
            )
            as AgentFunctionTool;
    final mcp =
        AgentTool.mcp(
              serverLabel: 'server',
              transport: AgentMcpTransport.http(
                serverUrl: 'https://fixture.invalid',
              ),
              requestMetadata: parameters,
            )
            as AgentMcpTool;
    values.clear();
    nested.clear();
    parameters.clear();
    expect(tool.parameters['nested'], {
      'values': ['PRIVATE-value', false, null],
    });
    expect(mcp.requestMetadata, tool.parameters);
    expect(
      () => (tool.parameters['nested'] as Map).clear(),
      throwsUnsupportedError,
    );
    expect(
      () => ((mcp.requestMetadata!['nested'] as Map)['values'] as List).clear(),
      throwsUnsupportedError,
    );
    expect(tool.toString(), isNot(contains('PRIVATE')));
    expect(mcp.toString(), isNot(contains('PRIVATE')));
    final equivalent = AgentFunctionTool.fromJson(tool.toJson());
    expect(equivalent, tool);
    expect(equivalent.hashCode, tool.hashCode);
    expect(tool.copyWith(parameters: {'different': true}), isNot(tool));
  });

  test(
    'Future received variants retain private detached JSON; known cannot bypass',
    () {
      final values = <Object?>['PRIVATE-value'];
      final raw = <String, dynamic>{
        'type': 'future',
        'nested': {'items': values},
      };
      final tool = AgentToolResource.fromJson(raw) as UnknownAgentToolResource;
      final transport =
          AgentMcpTransportResource.fromJson(raw)
              as UnknownAgentMcpTransportResource;
      final format =
          AgentTextFormatResource.fromJson(raw)
              as UnknownAgentTextFormatResource;
      values.clear();
      raw.clear();
      for (final value in [tool, transport, format]) {
        expect(value.toJson(), {
          'type': 'future',
          'nested': {
            'items': ['PRIVATE-value'],
          },
        });
        expect(value.toString(), isNot(contains('PRIVATE')));
      }
      expect(tool.copyWith(), tool);
      expect(tool.copyWith().hashCode, tool.hashCode);
      expect(
        () => UnknownAgentToolResource.fromJson(const {'type': 'function'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UnknownAgentMcpTransportResource.fromJson(const {'type': 'http'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UnknownAgentTextFormatResource.fromJson(const {'type': 'text'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => AgentToolResource.fromJson(const {'type': 'function'}),
        throwsA(isA<FormatException>()),
      );
      final writable = AgentTool.fromJson(const {
        'type': 'future',
        'private': ['PRIVATE'],
      });
      expect(
        () => CreateAgentRequest(model: 'model', tools: [writable]),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test('Finite JSON rejects cycles, non-string keys and nonfinite numbers', () {
    final cycle = <String, dynamic>{};
    cycle['private'] = cycle;
    for (final parameters in <Map<String, dynamic>>[
      cycle,
      {'private': double.nan},
      {'private': double.infinity},
      {
        'private': {7: 'PRIVATE'},
      },
      {'private': Object()},
    ]) {
      expect(
        () => AgentFunctionTool(
          name: 'function',
          description: '',
          parameters: parameters,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UnknownAgentToolResource.fromJson({
          'type': 'future',
          ...parameters,
        }),
        throwsA(isA<FormatException>()),
      );
    }
  });

  test(
    'Unicode request boundaries count characters rather than UTF-16 units',
    () {
      final name = List.filled(128, '🚀').join();
      expect(CreateAgentRequest(model: '', name: name).name, name);
      expect(
        () => CreateAgentRequest(model: '', name: '$name🚀'),
        throwsA(isA<FormatException>()),
      );
      final key = List.filled(64, '🚀').join();
      final value = List.filled(512, '🚀').join();
      expect(UpdateAgentRequest(metadata: {key: value}).metadata, {key: value});
      expect(
        () => UpdateAgentRequest(metadata: {'$key🚀': value}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UpdateAgentRequest(metadata: {key: '$value🚀'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UpdateAgentRequest(metadata: const {'': ''}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UpdateAgentRequest(
          metadata: {for (var i = 0; i < 17; i++) '$i': ''},
        ),
        throwsA(isA<FormatException>()),
      );
      final instructions = List.filled(1048576, 'a').join();
      expect(
        CreateAgentRequest(
          model: instructions,
          instructions: instructions,
        ).instructions,
        instructions,
      );
      expect(
        () => CreateAgentRequest(model: '$instructions!'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => UpdateAgentRequest(instructions: '$instructions!'),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test(
    'Tool count and compact UTF-8 budget include nested JSON and escaping',
    () {
      const tool = AgentTool.toolSearch();
      expect(
        CreateAgentRequest(
          model: 'model',
          tools: List.filled(2000, tool),
        ).tools,
        hasLength(2000),
      );
      expect(
        () => UpdateAgentRequest(tools: List.filled(2001, tool)),
        throwsA(isA<FormatException>()),
      );
      final empty = AgentTool.function(
        name: '',
        description: '',
        parameters: const {'value': ''},
      );
      final overhead = utf8.encode(jsonEncode([empty.toJson()])).length;
      const budget = 3145728;
      final payload = List.filled(budget - overhead, 'a').join();
      final fitting = AgentTool.function(
        name: '',
        description: '',
        parameters: {'value': payload},
      );
      expect(utf8.encode(jsonEncode([fitting.toJson()])), hasLength(budget));
      expect(
        CreateAgentRequest(model: 'model', tools: [fitting]).tools,
        hasLength(1),
      );
      expect(
        () => UpdateAgentRequest(
          tools: [
            AgentTool.function(
              name: '',
              description: '',
              parameters: {'value': '$payload!'},
            ),
          ],
        ),
        throwsA(isA<FormatException>()),
      );
      final multiByte = List.filled((budget - overhead) ~/ 4 + 1, '🚀').join();
      expect(multiByte.length, lessThan(budget));
      expect(
        () => CreateAgentRequest(
          model: 'model',
          tools: [
            AgentTool.function(
              name: '',
              description: '',
              parameters: {'value': multiByte},
            ),
          ],
        ),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test('Persisted request limits differ from returned resource limits', () {
    final arguments = List.filled(16384, '');
    expect(
      AgentMcpStdioTransport(command: '', cwd: '', args: arguments).args,
      hasLength(16384),
    );
    expect(
      () => AgentMcpStdioTransport(
        command: '',
        cwd: '',
        args: [...arguments, ''],
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => AgentMcpStdioTransportResource(
        command: '',
        cwd: '',
        args: List.filled(2001, ''),
        envVars: const [],
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      AgentServiceTierResource.fromJson('future-tier').toJson(),
      'future-tier',
    );
    expect(
      () => CreateAgentRequest(
        model: 'model',
        serviceTier: AgentServiceTierParam.fromJson('ultrafast'),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      CreateAgentRequest(
        model: 'model',
        serviceTier: AgentServiceTierParam.fast,
      ).toJson()['service_tier'],
      'fast',
    );
    expect(
      () => AgentMultiAgentConfig(enabled: true, maxConcurrentSubagents: 0),
      throwsA(isA<FormatException>()),
    );
    expect(
      AgentMultiAgentConfig(
        enabled: true,
        maxConcurrentSubagents: 4294967295,
      ).maxConcurrentSubagents,
      4294967295,
    );
    expect(
      () => AgentMultiAgentConfig(
        enabled: true,
        maxConcurrentSubagents: 4294967296,
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
