import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const agent = AgentTag(agentName: 'worker');
  const secretCommand = 'echo secret-command';
  const secretStdout = 'secret-stdout';
  const secretStderr = 'secret-stderr';
  const secretPadding = 'secret-padding';
  const types = [
    'response.shell_call_command.added',
    'response.shell_call_command.delta',
    'response.shell_call_command.done',
    'response.shell_call_output_content.delta',
    'response.shell_call_output_content.done',
  ];

  Map<String, dynamic> contentJson() => {
    'stdout': secretStdout,
    'stderr': secretStderr,
    'outcome': {'type': 'exit', 'exit_code': 7},
    'created_by': 'worker',
  };

  Map<String, dynamic> fixture(String type) => {
    'type': type,
    'sequence_number': 1,
    'output_index': 2,
    'command_index': 3,
    if (type.startsWith('response.shell_call_command.') &&
        !type.endsWith('.delta'))
      'command': secretCommand,
    if (type == 'response.shell_call_command.delta') ...{
      'delta': secretCommand,
      'obfuscation': secretPadding,
    },
    if (type.startsWith('response.shell_call_output_content.'))
      'item_id': 'shell-output',
    if (type == 'response.shell_call_output_content.delta')
      'delta': {'stdout': secretStdout, 'stderr': secretStderr},
    if (type == 'response.shell_call_output_content.done')
      'output': [contentJson()],
    'agent': agent.toJson(),
  };

  Matcher formatError(String context) => throwsA(
    isA<FormatException>().having(
      (error) => error.message,
      'context',
      contains(context),
    ),
  );

  for (final type in types) {
    group(type, () {
      test(
        'public dispatcher and direct parser retain complete beta payload',
        () {
          final json = fixture(type);
          final event = ResponseStreamEvent.fromJson(json);
          final direct = _parseKnown(type, json);
          expect(event.type, type);
          expect(event.sequenceNumber, 1);
          expect(event, direct);
          expect(event.hashCode, direct.hashCode);
          expect(event.toJson(), json);
          expect(event.isFinal, isFalse);
          expect(
            ResponseStreamEvent.fromJson(
              jsonDecode(jsonEncode(event.toJson())) as Map<String, dynamic>,
            ),
            event,
          );
        },
      );

      test('canonical payload omits beta agent', () {
        final json = fixture(type)..remove('agent');
        final event = ResponseStreamEvent.fromJson(json);
        expect(event.toJson(), json);
        expect(event.toString(), contains('agent: null'));
      });

      test('copy retains every field and can clear beta agent', () {
        final event = ResponseStreamEvent.fromJson(fixture(type));
        final copied = _copyField(event, 'unchanged');
        expect(copied, event);
        expect(copied.hashCode, event.hashCode);
        final cleared = _copyField(event, 'clear_agent');
        expect(cleared.toJson(), fixture(type)..remove('agent'));
        expect(cleared, isNot(event));
      });

      test('diagnostics enumerate metadata and redact shell payloads', () {
        final description = ResponseStreamEvent.fromJson(
          fixture(type),
        ).toString();
        for (final field in [
          'sequenceNumber',
          'outputIndex',
          'commandIndex',
          'agent',
        ]) {
          expect(description, contains('$field:'));
        }
        for (final secret in [
          secretCommand,
          secretStdout,
          secretStderr,
          secretPadding,
        ]) {
          expect(description, isNot(contains(secret)));
        }
        if (type.startsWith('response.shell_call_command.')) {
          expect(description, isNot(contains('itemId:')));
        } else {
          expect(description, contains('itemId: shell-output'));
        }
        final payloadField = type.endsWith('.delta')
            ? 'delta'
            : type.startsWith('response.shell_call_command.')
            ? 'command'
            : 'output';
        expect(description, contains('$payloadField:'));
        if (type == 'response.shell_call_command.delta') {
          expect(description, contains('obfuscation:'));
        }
      });

      test('diagnostics redact private beta agent names', () {
        const name = 'private-shell-agent';
        final event = ResponseStreamEvent.fromJson({
          ...fixture(type),
          'agent': {'agent_name': name},
        });
        expect(event.toString(), isNot(contains(name)));
        expect(event.toString(), contains('agent: [${name.length} chars]'));
        expect(event.toJson()['agent'], {'agent_name': name});
      });

      for (final value in [
        null,
        1,
        <String, dynamic>{},
        {'agent_name': null},
        {'agent_name': 1},
      ]) {
        test('rejects malformed beta agent $value', () {
          expect(
            () => ResponseStreamEvent.fromJson({
              ...fixture(type),
              'agent': value,
            }),
            formatError('agent'),
          );
        });
      }

      for (final invalidType in [null, 1, 'response.future_shell_event']) {
        test('direct parser rejects wrong discriminator $invalidType', () {
          expect(
            () => _parseKnown(type, {...fixture(type), 'type': invalidType}),
            formatError('type'),
          );
        });
      }
      test('direct parser rejects absent discriminator', () {
        expect(
          () => _parseKnown(type, fixture(type)..remove('type')),
          formatError('type'),
        );
      });

      final json = fixture(type);
      for (final key in json.keys.where(
        (key) => key != 'type' && key != 'agent' && key != 'obfuscation',
      )) {
        final wrong = switch (key) {
          'sequence_number' || 'output_index' || 'command_index' => 0.5,
          'output' => <String, dynamic>{},
          'delta' when type.endsWith('output_content.delta') => '',
          _ => 1,
        };
        test('requires $key', () {
          expect(
            () => ResponseStreamEvent.fromJson(fixture(type)..remove(key)),
            formatError(key),
          );
        });
        test('rejects null $key', () {
          expect(
            () => ResponseStreamEvent.fromJson({...fixture(type), key: null}),
            formatError(key),
          );
        });
        test('rejects invalid $key', () {
          expect(
            () => ResponseStreamEvent.fromJson({...fixture(type), key: wrong}),
            formatError(key),
          );
        });
        test('copy and equality include $key', () {
          final original = ResponseStreamEvent.fromJson(fixture(type));
          final updated = _copyField(original, key);
          final expected = fixture(type);
          expected[key] = updated.toJson()[key];
          final parsed = ResponseStreamEvent.fromJson(expected);
          expect(updated, isNot(original));
          expect(updated, parsed);
          expect(updated.hashCode, parsed.hashCode);
          expect(updated.toJson(), expected);
        });
      }
      test('copy and equality include beta agent', () {
        final original = ResponseStreamEvent.fromJson(fixture(type));
        final updated = _copyField(original, 'agent');
        final expected = {
          ...fixture(type),
          'agent': {'agent_name': 'other'},
        };
        final parsed = ResponseStreamEvent.fromJson(expected);
        expect(updated, isNot(original));
        expect(updated, parsed);
        expect(updated.hashCode, parsed.hashCode);
        expect(updated.toJson(), expected);
      });
    });
  }

  group('shell command progress', () {
    test('command events accept empty text without introducing item_id', () {
      for (final type in types.take(3)) {
        final field = type.endsWith('.delta') ? 'delta' : 'command';
        final json = {...fixture(type), field: ''};
        final event = ResponseStreamEvent.fromJson(json);
        expect(event.toJson(), json);
        expect(event.toJson().containsKey('item_id'), isFalse);
      }
    });

    test('obfuscation is preserved, optional and independently clearable', () {
      final json = fixture('response.shell_call_command.delta');
      final event = ResponseShellCallCommandDeltaEvent.fromJson(json);
      final copied = event.copyWith(obfuscation: 'new padding');
      expect(copied.obfuscation, 'new padding');
      expect(copied.delta, event.delta);
      expect(copied, isNot(event));
      final parsed = ResponseShellCallCommandDeltaEvent.fromJson(
        copied.toJson(),
      );
      expect(copied, parsed);
      expect(copied.hashCode, parsed.hashCode);
      final cleared = event.copyWith(obfuscation: null);
      expect(cleared.toJson(), json..remove('obfuscation'));
      expect(cleared.toString(), contains('obfuscation: null'));
      final empty = cleared.copyWith(obfuscation: '');
      expect(empty.toJson()['obfuscation'], '');
    });

    for (final value in [null, 1, <Object>[]]) {
      test('obfuscation rejects supplied nonstring $value', () {
        expect(
          () => ResponseStreamEvent.fromJson({
            ...fixture('response.shell_call_command.delta'),
            'obfuscation': value,
          }),
          formatError('ResponseShellCallCommandDeltaEvent.obfuscation'),
        );
      });
    }

    test('new command event constructors remain const', () {
      const added = ResponseShellCallCommandAddedEvent(
        sequenceNumber: 1,
        outputIndex: 0,
        commandIndex: 0,
        command: '',
      );
      const delta = ResponseShellCallCommandDeltaEvent(
        sequenceNumber: 2,
        outputIndex: 0,
        commandIndex: 0,
        delta: '',
      );
      const done = ResponseShellCallCommandDoneEvent(
        sequenceNumber: 3,
        outputIndex: 0,
        commandIndex: 0,
        command: '',
      );
      expect(added.command, '');
      expect(delta.delta, '');
      expect(done.command, '');
    });
  });

  group('ShellCallOutputDelta', () {
    for (final json in [
      <String, dynamic>{},
      {'stdout': ''},
      {'stderr': ''},
      {'stdout': secretStdout},
      {'stderr': secretStderr},
      {'stdout': secretStdout, 'stderr': secretStderr},
    ]) {
      test('retains independent fragments $json', () {
        final delta = ShellCallOutputDelta.fromJson(json);
        expect(delta.toJson(), json);
        expect(delta.copyWith(), delta);
        expect(delta.copyWith().hashCode, delta.hashCode);
        final jsonEvent = {
          ...fixture('response.shell_call_output_content.delta'),
          'delta': json,
        };
        final event = ResponseShellCallOutputContentDeltaEvent.fromJson(
          jsonEvent,
        );
        expect(event.delta, delta);
        expect(event.toJson(), jsonEvent);
      });
    }

    for (final field in ['stdout', 'stderr']) {
      for (final value in [null, 1, <String, dynamic>{}, <Object>[]]) {
        test('$field rejects supplied nonstring $value at leaf and event', () {
          expect(
            () => ShellCallOutputDelta.fromJson({field: value}),
            formatError('ShellCallOutputDelta.$field'),
          );
          expect(
            () => ResponseStreamEvent.fromJson({
              ...fixture('response.shell_call_output_content.delta'),
              'delta': {field: value},
            }),
            formatError(
              'ResponseShellCallOutputContentDeltaEvent.delta.$field',
            ),
          );
        });
      }
    }

    test('copy updates or removes each stream independently', () {
      const delta = ShellCallOutputDelta(
        stdout: secretStdout,
        stderr: secretStderr,
      );
      final stdout = delta.copyWith(stdout: 'other');
      expect(stdout.stdout, 'other');
      expect(stdout.stderr, delta.stderr);
      final stderr = delta.copyWith(stderr: 'other');
      expect(stderr.stderr, 'other');
      expect(stderr.stdout, delta.stdout);
      expect(stdout, isNot(delta));
      expect(stderr, isNot(delta));
      expect(delta.copyWith(stdout: null).toJson(), {'stderr': secretStderr});
      expect(delta.copyWith(stderr: null).toJson(), {'stdout': secretStdout});
      expect(delta.copyWith(stdout: null, stderr: null).toJson(), isEmpty);
      for (final changed in [stdout, stderr]) {
        final parsed = ShellCallOutputDelta.fromJson(changed.toJson());
        expect(parsed, changed);
        expect(parsed.hashCode, changed.hashCode);
      }
      expect(delta.toString(), isNot(contains(secretStdout)));
      expect(delta.toString(), isNot(contains(secretStderr)));
      expect(delta.toString(), contains('stdout:'));
      expect(delta.toString(), contains('stderr:'));
      expect(
        const ShellCallOutputDelta().toString(),
        contains('stdout: null, stderr: null'),
      );
    });

    test('output delta event constructor remains const', () {
      const event = ResponseShellCallOutputContentDeltaEvent(
        sequenceNumber: 1,
        outputIndex: 0,
        commandIndex: 0,
        itemId: 'shell',
        delta: ShellCallOutputDelta(),
      );
      expect(event.delta.toJson(), isEmpty);
    });
  });

  group('completed shell output', () {
    test('accepts an empty output array', () {
      final json = {
        ...fixture('response.shell_call_output_content.done'),
        'output': <Object>[],
      };
      final event = ResponseShellCallOutputContentDoneEvent.fromJson(json);
      expect(event.output, isEmpty);
      expect(event.toJson(), json);
    });

    test(
      'snapshots constructor and parsed lists, including nested metadata',
      () {
        final content = ShellCallOutputContent.fromJson(contentJson());
        final source = [content];
        final event = ResponseShellCallOutputContentDoneEvent(
          sequenceNumber: 1,
          outputIndex: 0,
          commandIndex: 0,
          itemId: 'shell',
          output: source,
        );
        source.clear();
        expect(event.output, [content]);
        expect(event.output.clear, throwsUnsupportedError);
        final raw = fixture('response.shell_call_output_content.done');
        final parsed = ResponseShellCallOutputContentDoneEvent.fromJson(raw);
        (raw['output'] as List<dynamic>).clear();
        expect(parsed.output, hasLength(1));
        expect(parsed.output.single.createdBy, 'worker');
        expect(
          parsed.output.single.outcome,
          const ShellCallExitOutcome(exitCode: 7),
        );
        expect(() => parsed.output.add(content), throwsUnsupportedError);
        final copiedSource = [content];
        final copied = parsed.copyWith(output: copiedSource);
        copiedSource.clear();
        expect(copied.output, [content]);
      },
    );

    test('retains timeout as a distinct outcome', () {
      final json = {
        ...fixture('response.shell_call_output_content.done'),
        'output': [
          {
            ...contentJson(),
            'outcome': {'type': 'timeout'},
          },
        ],
      };
      final event = ResponseShellCallOutputContentDoneEvent.fromJson(json);
      expect(event.output.single.outcome, isA<ShellCallTimeoutOutcome>());
      expect(event.toJson(), json);
    });

    for (final value in [null, 1, 'not-an-object']) {
      test('rejects malformed output array element $value', () {
        expect(
          () => ResponseStreamEvent.fromJson({
            ...fixture('response.shell_call_output_content.done'),
            'output': [value],
          }),
          formatError('ResponseShellCallOutputContentDoneEvent.output[0]'),
        );
      });
    }
    for (final field in ['stdout', 'stderr', 'outcome']) {
      test('rejects absent output element $field with event context', () {
        expect(
          () => ResponseStreamEvent.fromJson({
            ...fixture('response.shell_call_output_content.done'),
            'output': [contentJson()..remove(field)],
          }),
          formatError(
            'ResponseShellCallOutputContentDoneEvent.output[0].$field',
          ),
        );
      });
    }
    for (final value in [null, 1]) {
      test('rejects malformed created_by $value with event context', () {
        expect(
          () => ResponseStreamEvent.fromJson({
            ...fixture('response.shell_call_output_content.done'),
            'output': [
              {...contentJson(), 'created_by': value},
            ],
          }),
          formatError(
            'ResponseShellCallOutputContentDoneEvent.output[0].created_by',
          ),
        );
      });
    }
  });

  test('unknown event types continue through the existing fallback', () {
    final json = <String, dynamic>{
      'type': 'response.shell_future.progress',
      'sequence_number': 1,
      'future': {
        'nested': [1, 2],
      },
    };
    final event = ResponseStreamEvent.fromJson(json);
    expect(event, isA<UnknownEvent>());
    expect(event.type, json['type']);
    expect(event.toJson(), json);
  });
}

ResponseStreamEvent _parseKnown(String type, Map<String, dynamic> json) =>
    switch (type) {
      'response.shell_call_command.added' =>
        ResponseShellCallCommandAddedEvent.fromJson(json),
      'response.shell_call_command.delta' =>
        ResponseShellCallCommandDeltaEvent.fromJson(json),
      'response.shell_call_command.done' =>
        ResponseShellCallCommandDoneEvent.fromJson(json),
      'response.shell_call_output_content.delta' =>
        ResponseShellCallOutputContentDeltaEvent.fromJson(json),
      'response.shell_call_output_content.done' =>
        ResponseShellCallOutputContentDoneEvent.fromJson(json),
      _ => throw StateError('Unknown test fixture type'),
    };

ResponseStreamEvent _copyField(
  ResponseStreamEvent value,
  String field,
) => switch ((value, field)) {
  (final ResponseShellCallCommandAddedEvent event, 'unchanged') =>
    event.copyWith(),
  (final ResponseShellCallCommandAddedEvent event, 'clear_agent') =>
    event.copyWith(agent: null),
  (final ResponseShellCallCommandAddedEvent event, 'sequence_number') =>
    event.copyWith(sequenceNumber: 10),
  (final ResponseShellCallCommandAddedEvent event, 'output_index') =>
    event.copyWith(outputIndex: 10),
  (final ResponseShellCallCommandAddedEvent event, 'command_index') =>
    event.copyWith(commandIndex: 10),
  (final ResponseShellCallCommandAddedEvent event, 'agent') => event.copyWith(
    agent: const AgentTag(agentName: 'other'),
  ),
  (final ResponseShellCallCommandAddedEvent event, 'command') => event.copyWith(
    command: 'other',
  ),
  (final ResponseShellCallCommandDeltaEvent event, 'unchanged') =>
    event.copyWith(),
  (final ResponseShellCallCommandDeltaEvent event, 'clear_agent') =>
    event.copyWith(agent: null),
  (final ResponseShellCallCommandDeltaEvent event, 'sequence_number') =>
    event.copyWith(sequenceNumber: 10),
  (final ResponseShellCallCommandDeltaEvent event, 'output_index') =>
    event.copyWith(outputIndex: 10),
  (final ResponseShellCallCommandDeltaEvent event, 'command_index') =>
    event.copyWith(commandIndex: 10),
  (final ResponseShellCallCommandDeltaEvent event, 'agent') => event.copyWith(
    agent: const AgentTag(agentName: 'other'),
  ),
  (final ResponseShellCallCommandDeltaEvent event, 'delta') => event.copyWith(
    delta: 'other',
  ),
  (final ResponseShellCallCommandDoneEvent event, 'unchanged') =>
    event.copyWith(),
  (final ResponseShellCallCommandDoneEvent event, 'clear_agent') =>
    event.copyWith(agent: null),
  (final ResponseShellCallCommandDoneEvent event, 'sequence_number') =>
    event.copyWith(sequenceNumber: 10),
  (final ResponseShellCallCommandDoneEvent event, 'output_index') =>
    event.copyWith(outputIndex: 10),
  (final ResponseShellCallCommandDoneEvent event, 'command_index') =>
    event.copyWith(commandIndex: 10),
  (final ResponseShellCallCommandDoneEvent event, 'agent') => event.copyWith(
    agent: const AgentTag(agentName: 'other'),
  ),
  (final ResponseShellCallCommandDoneEvent event, 'command') => event.copyWith(
    command: 'other',
  ),
  (final ResponseShellCallOutputContentDeltaEvent event, 'unchanged') =>
    event.copyWith(),
  (final ResponseShellCallOutputContentDeltaEvent event, 'clear_agent') =>
    event.copyWith(agent: null),
  (final ResponseShellCallOutputContentDeltaEvent event, 'sequence_number') =>
    event.copyWith(sequenceNumber: 10),
  (final ResponseShellCallOutputContentDeltaEvent event, 'output_index') =>
    event.copyWith(outputIndex: 10),
  (final ResponseShellCallOutputContentDeltaEvent event, 'command_index') =>
    event.copyWith(commandIndex: 10),
  (final ResponseShellCallOutputContentDeltaEvent event, 'agent') =>
    event.copyWith(agent: const AgentTag(agentName: 'other')),
  (final ResponseShellCallOutputContentDeltaEvent event, 'item_id') =>
    event.copyWith(itemId: 'other'),
  (final ResponseShellCallOutputContentDeltaEvent event, 'delta') =>
    event.copyWith(delta: event.delta.copyWith(stdout: 'other')),
  (final ResponseShellCallOutputContentDoneEvent event, 'unchanged') =>
    event.copyWith(),
  (final ResponseShellCallOutputContentDoneEvent event, 'clear_agent') =>
    event.copyWith(agent: null),
  (final ResponseShellCallOutputContentDoneEvent event, 'sequence_number') =>
    event.copyWith(sequenceNumber: 10),
  (final ResponseShellCallOutputContentDoneEvent event, 'output_index') =>
    event.copyWith(outputIndex: 10),
  (final ResponseShellCallOutputContentDoneEvent event, 'command_index') =>
    event.copyWith(commandIndex: 10),
  (final ResponseShellCallOutputContentDoneEvent event, 'agent') =>
    event.copyWith(agent: const AgentTag(agentName: 'other')),
  (final ResponseShellCallOutputContentDoneEvent event, 'item_id') =>
    event.copyWith(itemId: 'other'),
  (final ResponseShellCallOutputContentDoneEvent event, 'output') =>
    event.copyWith(output: [event.output.single.copyWith(stdout: 'other')]),
  _ => throw StateError('Unknown test copy field'),
};
