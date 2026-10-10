import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_subagent_wire_fixtures.dart';

Map<String, dynamic> wire(String n) =>
    jsonDecode(
          jsonEncode(
            subagentWireFixtures.singleWhere((f) => f.schema == n).full,
          ),
        )
        as Map<String, dynamic>;
void main() {
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable parse rejects double.nan',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionCommandExecutionItemResource.fromJson({
          ...body,
          'duration_ms': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable copy rejects double.nan',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(durationMs: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable construct rejects double.nan',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionCommandExecutionItemResource(
          id: original.id,
          turnId: original.turnId,
          command: original.command,
          cwd: original.cwd,
          status: original.status,
          output: original.output,
          exitCode: original.exitCode,
          durationMs: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable parse rejects double.infinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionCommandExecutionItemResource.fromJson({
          ...body,
          'duration_ms': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable copy rejects double.infinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(durationMs: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable construct rejects double.infinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionCommandExecutionItemResource(
          id: original.id,
          turnId: original.turnId,
          command: original.command,
          cwd: original.cwd,
          status: original.status,
          output: original.output,
          exitCode: original.exitCode,
          durationMs: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable parse rejects double.negativeInfinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionCommandExecutionItemResource.fromJson({
          ...body,
          'duration_ms': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable copy rejects double.negativeInfinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(durationMs: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.durationMs: nullable construct rejects double.negativeInfinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionCommandExecutionItemResource(
          id: original.id,
          turnId: original.turnId,
          command: original.command,
          cwd: original.cwd,
          status: original.status,
          output: original.output,
          exitCode: original.exitCode,
          durationMs: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable parse rejects double.nan',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionCommandExecutionItemResource.fromJson({
          ...body,
          'exit_code': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable copy rejects double.nan',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(exitCode: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable construct rejects double.nan',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionCommandExecutionItemResource(
          id: original.id,
          turnId: original.turnId,
          command: original.command,
          cwd: original.cwd,
          status: original.status,
          output: original.output,
          durationMs: original.durationMs,
          exitCode: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable parse rejects double.infinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionCommandExecutionItemResource.fromJson({
          ...body,
          'exit_code': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable copy rejects double.infinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(exitCode: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable construct rejects double.infinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionCommandExecutionItemResource(
          id: original.id,
          turnId: original.turnId,
          command: original.command,
          cwd: original.cwd,
          status: original.status,
          output: original.output,
          durationMs: original.durationMs,
          exitCode: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable parse rejects double.negativeInfinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionCommandExecutionItemResource.fromJson({
          ...body,
          'exit_code': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable copy rejects double.negativeInfinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(exitCode: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionCommandExecutionItemResource.exitCode: nullable construct rejects double.negativeInfinity',
    () {
      final body = wire('CommandExecutionItemResource');
      final original = AgentSessionCommandExecutionItemResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionCommandExecutionItemResource(
          id: original.id,
          turnId: original.turnId,
          command: original.command,
          cwd: original.cwd,
          status: original.status,
          output: original.output,
          durationMs: original.durationMs,
          exitCode: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionSubagent.closedAt: nullable parse rejects double.nan', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionSubagent.fromJson({...body, 'closed_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionSubagent.closedAt: nullable copy rejects double.nan', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(closedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionSubagent.closedAt: nullable construct rejects double.nan',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionSubagent(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          name: original.name,
          instructions: original.instructions,
          parentAgentId: original.parentAgentId,
          status: original.status,
          openedAt: original.openedAt,
          closedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.closedAt: nullable parse rejects double.infinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionSubagent.fromJson({...body, 'closed_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.closedAt: nullable copy rejects double.infinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(closedAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.closedAt: nullable construct rejects double.infinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionSubagent(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          name: original.name,
          instructions: original.instructions,
          parentAgentId: original.parentAgentId,
          status: original.status,
          openedAt: original.openedAt,
          closedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.closedAt: nullable parse rejects double.negativeInfinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionSubagent.fromJson({...body, 'closed_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.closedAt: nullable copy rejects double.negativeInfinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(closedAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.closedAt: nullable construct rejects double.negativeInfinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionSubagent(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          name: original.name,
          instructions: original.instructions,
          parentAgentId: original.parentAgentId,
          status: original.status,
          openedAt: original.openedAt,
          closedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionTurn.completedAt: nullable parse rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionTurn.fromJson({...body, 'completed_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.completedAt: nullable copy rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(completedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionTurn.completedAt: nullable construct rejects double.nan',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionTurn(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          agentId: original.agentId,
          subagentId: original.subagentId,
          status: original.status,
          createdAt: original.createdAt,
          startedAt: original.startedAt,
          error: original.error,
          usage: original.usage,
          completedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.completedAt: nullable parse rejects double.infinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTurn.fromJson({...body, 'completed_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.completedAt: nullable copy rejects double.infinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(completedAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.completedAt: nullable construct rejects double.infinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTurn(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          agentId: original.agentId,
          subagentId: original.subagentId,
          status: original.status,
          createdAt: original.createdAt,
          startedAt: original.startedAt,
          error: original.error,
          usage: original.usage,
          completedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.completedAt: nullable parse rejects double.negativeInfinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTurn.fromJson({...body, 'completed_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.completedAt: nullable copy rejects double.negativeInfinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(completedAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.completedAt: nullable construct rejects double.negativeInfinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTurn(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          agentId: original.agentId,
          subagentId: original.subagentId,
          status: original.status,
          createdAt: original.createdAt,
          startedAt: original.startedAt,
          error: original.error,
          usage: original.usage,
          completedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionTurn.startedAt: nullable parse rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionTurn.fromJson({...body, 'started_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.startedAt: nullable copy rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(startedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.startedAt: nullable construct rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionTurn(
        id: original.id,
        object: original.object,
        sessionId: original.sessionId,
        agentId: original.agentId,
        subagentId: original.subagentId,
        status: original.status,
        createdAt: original.createdAt,
        completedAt: original.completedAt,
        error: original.error,
        usage: original.usage,
        startedAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionTurn.startedAt: nullable parse rejects double.infinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTurn.fromJson({...body, 'started_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionTurn.startedAt: nullable copy rejects double.infinity', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(startedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionTurn.startedAt: nullable construct rejects double.infinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTurn(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          agentId: original.agentId,
          subagentId: original.subagentId,
          status: original.status,
          createdAt: original.createdAt,
          completedAt: original.completedAt,
          error: original.error,
          usage: original.usage,
          startedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.startedAt: nullable parse rejects double.negativeInfinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTurn.fromJson({...body, 'started_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.startedAt: nullable copy rejects double.negativeInfinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(startedAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTurn.startedAt: nullable construct rejects double.negativeInfinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTurn(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          agentId: original.agentId,
          subagentId: original.subagentId,
          status: original.status,
          createdAt: original.createdAt,
          completedAt: original.completedAt,
          error: original.error,
          usage: original.usage,
          startedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );

  test('AgentMessageItemResource.content: canonical maximum rejection', () {
    final body = wire('AgentMessageItemResource');
    body['content'] = List<Object?>.filled(
      2001,
      (body['content'] as List).isEmpty ? '' : (body['content'] as List).first,
    );
    expect(
      () => subagentWireFixtures
          .singleWhere((f) => f.schema == 'AgentMessageItemResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fields: canonical maximum rejection',
    () {
      final body = wire(
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
      );
      body['fields'] = List<Object?>.filled(
        2001,
        (body['fields'] as List).isEmpty ? '' : (body['fields'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere(
              (f) =>
                  f.schema ==
                  'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.options: canonical maximum rejection',
    () {
      final body = wire(
        'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
      );
      body['options'] = List<Object?>.filled(
        2001,
        (body['options'] as List).isEmpty
            ? ''
            : (body['options'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere(
              (f) =>
                  f.schema ==
                  'BrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'BrowserAuthenticationOptionResource.field_ids: canonical maximum rejection',
    () {
      final body = wire('BrowserAuthenticationOptionResource');
      body['field_ids'] = List<Object?>.filled(
        2001,
        (body['field_ids'] as List).isEmpty
            ? ''
            : (body['field_ids'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere(
              (f) => f.schema == 'BrowserAuthenticationOptionResource',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateSubagentCallItemResource.content: canonical maximum rejection',
    () {
      final body = wire('CreateSubagentCallItemResource');
      body['content'] = List<Object?>.filled(
        2001,
        (body['content'] as List).isEmpty
            ? ''
            : (body['content'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere((f) => f.schema == 'CreateSubagentCallItemResource')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('MessageItemResource.content: canonical maximum rejection', () {
    final body = wire('MessageItemResource');
    body['content'] = List<Object?>.filled(
      2001,
      (body['content'] as List).isEmpty ? '' : (body['content'] as List).first,
    );
    expect(
      () => subagentWireFixtures
          .singleWhere((f) => f.schema == 'MessageItemResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('ReasoningItemResource.summary: canonical maximum rejection', () {
    final body = wire('ReasoningItemResource');
    body['summary'] = List<Object?>.filled(
      2001,
      (body['summary'] as List).isEmpty ? '' : (body['summary'] as List).first,
    );
    expect(
      () => subagentWireFixtures
          .singleWhere((f) => f.schema == 'ReasoningItemResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'SendSubagentInputCallItemResource.content: canonical maximum rejection',
    () {
      final body = wire('SendSubagentInputCallItemResource');
      body['content'] = List<Object?>.filled(
        2001,
        (body['content'] as List).isEmpty
            ? ''
            : (body['content'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere((f) => f.schema == 'SendSubagentInputCallItemResource')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('SessionItemListResource.data: canonical maximum rejection', () {
    final body = wire('SessionItemListResource');
    body['data'] = List<Object?>.filled(
      2001,
      (body['data'] as List).isEmpty ? '' : (body['data'] as List).first,
    );
    expect(
      () => subagentWireFixtures
          .singleWhere((f) => f.schema == 'SessionItemListResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('SessionTurnListResource.data: canonical maximum rejection', () {
    final body = wire('SessionTurnListResource');
    body['data'] = List<Object?>.filled(
      2001,
      (body['data'] as List).isEmpty ? '' : (body['data'] as List).first,
    );
    expect(
      () => subagentWireFixtures
          .singleWhere((f) => f.schema == 'SessionTurnListResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('SubagentResource.instructions: canonical maximum rejection', () {
    final body = wire('SubagentResource');
    body['instructions'] = List<Object?>.filled(
      2001,
      (body['instructions'] as List).isEmpty
          ? ''
          : (body['instructions'] as List).first,
    );
    expect(
      () => subagentWireFixtures
          .singleWhere((f) => f.schema == 'SubagentResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'WaitForSubagentsCallItemResource.recipient_agent_ids: canonical maximum rejection',
    () {
      final body = wire('WaitForSubagentsCallItemResource');
      body['recipient_agent_ids'] = List<Object?>.filled(
        2001,
        (body['recipient_agent_ids'] as List).isEmpty
            ? ''
            : (body['recipient_agent_ids'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere((f) => f.schema == 'WaitForSubagentsCallItemResource')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'WebSearchActionResourceSearch.queries: canonical maximum rejection',
    () {
      final body = wire('WebSearchActionResourceSearch');
      body['queries'] = List<Object?>.filled(
        2001,
        (body['queries'] as List).isEmpty
            ? ''
            : (body['queries'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere((f) => f.schema == 'WebSearchActionResourceSearch')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    '#/paths/~1agents~1sessions~1{session_id}~1subagents/get/responses/200/content/application~1json/schema.data: canonical maximum rejection',
    () {
      final body = wire(
        '#/paths/~1agents~1sessions~1{session_id}~1subagents/get/responses/200/content/application~1json/schema',
      );
      body['data'] = List<Object?>.filled(
        2001,
        (body['data'] as List).isEmpty ? '' : (body['data'] as List).first,
      );
      expect(
        () => subagentWireFixtures
            .singleWhere(
              (f) =>
                  f.schema ==
                  '#/paths/~1agents~1sessions~1{session_id}~1subagents/get/responses/200/content/application~1json/schema',
            )
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: parse rejects double.nan',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionInputTokensDetailsResourceDetails.fromJson({
          ...body,
          'cached_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: copy rejects double.nan',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(cachedTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: construct rejects double.nan',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionInputTokensDetailsResourceDetails(cachedTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: parse rejects double.infinity',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionInputTokensDetailsResourceDetails.fromJson({
          ...body,
          'cached_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: copy rejects double.infinity',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(cachedTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: construct rejects double.infinity',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionInputTokensDetailsResourceDetails(cachedTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: parse rejects double.negativeInfinity',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionInputTokensDetailsResourceDetails.fromJson({
          ...body,
          'cached_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: copy rejects double.negativeInfinity',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(cachedTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionInputTokensDetailsResourceDetails.cachedTokens: construct rejects double.negativeInfinity',
    () {
      final body = wire('InputTokensDetailsResource-2');
      final original = AgentSessionInputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionInputTokensDetailsResourceDetails(cachedTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: parse rejects double.nan',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionOutputTokensDetailsResourceDetails.fromJson({
          ...body,
          'reasoning_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: copy rejects double.nan',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(reasoningTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: construct rejects double.nan',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionOutputTokensDetailsResourceDetails(
          reasoningTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: parse rejects double.infinity',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionOutputTokensDetailsResourceDetails.fromJson({
          ...body,
          'reasoning_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: copy rejects double.infinity',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(reasoningTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: construct rejects double.infinity',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionOutputTokensDetailsResourceDetails(
          reasoningTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: parse rejects double.negativeInfinity',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionOutputTokensDetailsResourceDetails.fromJson({
          ...body,
          'reasoning_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: copy rejects double.negativeInfinity',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(reasoningTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionOutputTokensDetailsResourceDetails.reasoningTokens: construct rejects double.negativeInfinity',
    () {
      final body = wire('OutputTokensDetailsResource-2');
      final original = AgentSessionOutputTokensDetailsResourceDetails.fromJson(
        body,
      );
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionOutputTokensDetailsResourceDetails(
          reasoningTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionSubagent.openedAt: parse rejects double.nan', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionSubagent.fromJson({...body, 'opened_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionSubagent.openedAt: copy rejects double.nan', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(openedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionSubagent.openedAt: construct rejects double.nan', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionSubagent(
        id: original.id,
        object: original.object,
        sessionId: original.sessionId,
        name: original.name,
        instructions: original.instructions,
        parentAgentId: original.parentAgentId,
        status: original.status,
        closedAt: original.closedAt,
        openedAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionSubagent.openedAt: parse rejects double.infinity', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionSubagent.fromJson({...body, 'opened_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionSubagent.openedAt: copy rejects double.infinity', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(openedAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionSubagent.openedAt: construct rejects double.infinity', () {
    final body = wire('SubagentResource');
    final original = AgentSessionSubagent.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionSubagent(
        id: original.id,
        object: original.object,
        sessionId: original.sessionId,
        name: original.name,
        instructions: original.instructions,
        parentAgentId: original.parentAgentId,
        status: original.status,
        closedAt: original.closedAt,
        openedAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionSubagent.openedAt: parse rejects double.negativeInfinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionSubagent.fromJson({...body, 'opened_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.openedAt: copy rejects double.negativeInfinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(openedAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionSubagent.openedAt: construct rejects double.negativeInfinity',
    () {
      final body = wire('SubagentResource');
      final original = AgentSessionSubagent.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionSubagent(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          name: original.name,
          instructions: original.instructions,
          parentAgentId: original.parentAgentId,
          status: original.status,
          closedAt: original.closedAt,
          openedAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: parse rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'input_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: copy rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(inputTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: construct rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokensDetails: original.inputTokensDetails,
          outputTokens: original.outputTokens,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: original.totalTokens,
          inputTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: parse rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'input_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: copy rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(inputTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: construct rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokensDetails: original.inputTokensDetails,
          outputTokens: original.outputTokens,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: original.totalTokens,
          inputTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: parse rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'input_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: copy rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(inputTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.inputTokens: construct rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokensDetails: original.inputTokensDetails,
          outputTokens: original.outputTokens,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: original.totalTokens,
          inputTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: parse rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'output_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: copy rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(outputTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: construct rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokens: original.inputTokens,
          inputTokensDetails: original.inputTokensDetails,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: original.totalTokens,
          outputTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: parse rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'output_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: copy rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(outputTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: construct rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokens: original.inputTokens,
          inputTokensDetails: original.inputTokensDetails,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: original.totalTokens,
          outputTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: parse rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'output_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: copy rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(outputTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.outputTokens: construct rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokens: original.inputTokens,
          inputTokensDetails: original.inputTokensDetails,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: original.totalTokens,
          outputTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: parse rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'total_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: copy rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => original.copyWith(totalTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: construct rejects double.nan',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.nan;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokens: original.inputTokens,
          inputTokensDetails: original.inputTokensDetails,
          outputTokens: original.outputTokens,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: parse rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'total_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: copy rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => original.copyWith(totalTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: construct rejects double.infinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.infinity;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokens: original.inputTokens,
          inputTokensDetails: original.inputTokensDetails,
          outputTokens: original.outputTokens,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: parse rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTokenUsageResource.fromJson({
          ...body,
          'total_tokens': bad,
        }),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: copy rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(totalTokens: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionTokenUsageResource.totalTokens: construct rejects double.negativeInfinity',
    () {
      final body = wire('TokenUsageResource');
      final original = AgentSessionTokenUsageResource.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTokenUsageResource(
          inputTokens: original.inputTokens,
          inputTokensDetails: original.inputTokensDetails,
          outputTokens: original.outputTokens,
          outputTokensDetails: original.outputTokensDetails,
          totalTokens: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionTurn.createdAt: parse rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionTurn.fromJson({...body, 'created_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.createdAt: copy rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(createdAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.createdAt: construct rejects double.nan', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionTurn(
        id: original.id,
        object: original.object,
        sessionId: original.sessionId,
        agentId: original.agentId,
        subagentId: original.subagentId,
        status: original.status,
        startedAt: original.startedAt,
        completedAt: original.completedAt,
        error: original.error,
        usage: original.usage,
        createdAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.createdAt: parse rejects double.infinity', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionTurn.fromJson({...body, 'created_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.createdAt: copy rejects double.infinity', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(createdAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.createdAt: construct rejects double.infinity', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionTurn(
        id: original.id,
        object: original.object,
        sessionId: original.sessionId,
        agentId: original.agentId,
        subagentId: original.subagentId,
        status: original.status,
        startedAt: original.startedAt,
        completedAt: original.completedAt,
        error: original.error,
        usage: original.usage,
        createdAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.createdAt: parse rejects double.negativeInfinity', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.negativeInfinity;
    expect(
      () => AgentSessionTurn.fromJson({...body, 'created_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionTurn.createdAt: copy rejects double.negativeInfinity', () {
    final body = wire('TurnResource');
    final original = AgentSessionTurn.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.negativeInfinity;
    expect(
      () => original.copyWith(createdAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionTurn.createdAt: construct rejects double.negativeInfinity',
    () {
      final body = wire('TurnResource');
      final original = AgentSessionTurn.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionTurn(
          id: original.id,
          object: original.object,
          sessionId: original.sessionId,
          agentId: original.agentId,
          subagentId: original.subagentId,
          status: original.status,
          startedAt: original.startedAt,
          completedAt: original.completedAt,
          error: original.error,
          usage: original.usage,
          createdAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentContentResource: known encrypted_content source variant', () {
    final body =
        jsonDecode(
              r'''{"encrypted_content": "PRIVATE-encrypted-opaque", "type": "encrypted_content"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionContent.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionContent.fromJson({
        ...body,
        'type': 'encrypted_content',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('AgentContentResource: known output_text source variant', () {
    final body =
        jsonDecode(
              r'''{"text": "PRIVATE-task-caf\u00e9\ud83d\ude80 [image preview] [audio preview]", "type": "output_text"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionContent.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionContent.fromJson({
        ...body,
        'type': 'output_text',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('AgentContentResource: unknown privately owned received fallback', () {
    final value = AgentSessionContent.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
  });
  test(
    'BrowserAuthenticationHistoryRequestKindResource: known browser_authentication source variant',
    () {
      final body =
          jsonDecode(
                r'''{"credential_origin": "https://private.example.test/login", "fields": [{"id": "item_synthetic", "label": "PRIVATE-field-caf\u00e9\ud83d\ude80", "required": true, "type": "PRIVATE-field-caf\u00e9\ud83d\ude80"}], "options": [{"field_ids": ["PRIVATE-field-caf\u00e9\ud83d\ude80"], "id": "item_synthetic", "label": "PRIVATE-field-caf\u00e9\ud83d\ude80"}], "reason": "PRIVATE-field-caf\u00e9\ud83d\ude80", "type": "browser_authentication"}''',
              )
              as Map<String, dynamic>;
      final value =
          AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
            body,
          );
      expect(value.toJson(), body);
      expect(
        () =>
            AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
              {
                ...body,
                'type': 'browser_authentication',
                'PRIVATE-required': null,
              },
            ),
        returnsNormally,
      );
    },
  );
  test(
    'BrowserAuthenticationHistoryRequestKindResource: unknown privately owned received fallback',
    () {
      final value =
          AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
            const {'type': 'future', 'opaque': 'PRIVATE'},
          );
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
    },
  );
  test(
    'ComputerUseApprovalResponseKindResource: known cancel source variant',
    () {
      final body =
          jsonDecode(
                r'''{"action": "cancel", "type": "browser_authentication"}''',
              )
              as Map<String, dynamic>;
      final value = AgentSessionBrowserAuthenticationResponseResource.fromJson(
        body,
      );
      expect(value.toJson(), body);
      expect(
        () => AgentSessionBrowserAuthenticationResponseResource.fromJson({
          ...body,
          'action': 'cancel',
          'PRIVATE-required': null,
        }),
        returnsNormally,
      );
    },
  );
  test(
    'ComputerUseApprovalResponseKindResource: known submit source variant',
    () {
      final body =
          jsonDecode(
                r'''{"action": "submit", "selected_option": "PRIVATE-field-caf\u00e9\ud83d\ude80", "type": "browser_authentication"}''',
              )
              as Map<String, dynamic>;
      final value = AgentSessionBrowserAuthenticationResponseResource.fromJson(
        body,
      );
      expect(value.toJson(), body);
      expect(
        () => AgentSessionBrowserAuthenticationResponseResource.fromJson({
          ...body,
          'action': 'submit',
          'PRIVATE-required': null,
        }),
        returnsNormally,
      );
    },
  );
  test(
    'ComputerUseApprovalResponseKindResource: unknown privately owned received fallback',
    () {
      final value = AgentSessionBrowserAuthenticationResponseResource.fromJson(
        const {
          'type': 'browser_authentication',
          'action': 'future',
          'opaque': 'PRIVATE',
        },
      );
      expect(value.toJson(), {
        'type': 'browser_authentication',
        'action': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toString(), isNot(contains('PRIVATE')));
    },
  );
  test('FunctionCallStatusResource: in_progress', () {
    final v = AgentSessionFunctionCallStatusResource.fromJson('in_progress');
    expect(v.toJson(), 'in_progress');
  });
  test('FunctionCallStatusResource: completed', () {
    final v = AgentSessionFunctionCallStatusResource.fromJson('completed');
    expect(v.toJson(), 'completed');
  });
  test('FunctionCallStatusResource: failed', () {
    final v = AgentSessionFunctionCallStatusResource.fromJson('failed');
    expect(v.toJson(), 'failed');
  });
  test('FunctionCallStatusResource: incomplete', () {
    final v = AgentSessionFunctionCallStatusResource.fromJson('incomplete');
    expect(v.toJson(), 'incomplete');
  });
  test('InputContentResource: known input_image source variant', () {
    final body =
        jsonDecode(
              r'''{"image_url": "data:image/jpeg;base64,UFJJVkFURQ==", "type": "input_image"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionInputContentResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionInputContentResource.fromJson({
        ...body,
        'type': 'input_image',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('InputContentResource: known input_text source variant', () {
    final body =
        jsonDecode(
              r'''{"text": "PRIVATE-task-caf\u00e9\ud83d\ude80 [image preview] [audio preview]", "type": "input_text"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionInputContentResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionInputContentResource.fromJson({
        ...body,
        'type': 'input_text',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('InputContentResource: unknown privately owned received fallback', () {
    final value = AgentSessionInputContentResource.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
  });
  test('ListOrderParam: asc', () {
    final v = AgentListOrder.fromJson('asc');
    expect(v.toJson(), 'asc');
  });
  test('ListOrderParam: desc', () {
    final v = AgentListOrder.fromJson('desc');
    expect(v.toJson(), 'desc');
  });
  test('MessageContentResource: known input_image source variant', () {
    final body =
        jsonDecode(
              r'''{"image_url": "data:image/jpeg;base64,UFJJVkFURQ==", "type": "input_image"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionMessageContent.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionMessageContent.fromJson({
        ...body,
        'type': 'input_image',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('MessageContentResource: known input_text source variant', () {
    final body =
        jsonDecode(
              r'''{"text": "PRIVATE-task-caf\u00e9\ud83d\ude80 [image preview] [audio preview]", "type": "input_text"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionMessageContent.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionMessageContent.fromJson({
        ...body,
        'type': 'input_text',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('MessageContentResource: known output_text source variant', () {
    final body =
        jsonDecode(
              r'''{"text": "PRIVATE-task-caf\u00e9\ud83d\ude80 [image preview] [audio preview]", "type": "output_text"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionMessageContent.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionMessageContent.fromJson({
        ...body,
        'type': 'output_text',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('MessageContentResource: unknown privately owned received fallback', () {
    final value = AgentSessionMessageContent.fromJson(const {
      'type': 'future',
      'opaque': 'PRIVATE',
    });
    expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
    expect(value.toString(), isNot(contains('PRIVATE')));
  });
  test('MessagePhaseResource: commentary', () {
    final v = AgentSessionMessagePhaseResource.fromJson('commentary');
    expect(v.toJson(), 'commentary');
  });
  test('MessagePhaseResource: final_answer', () {
    final v = AgentSessionMessagePhaseResource.fromJson('final_answer');
    expect(v.toJson(), 'final_answer');
  });
  test('OutputItemStatusResource: in_progress', () {
    final v = AgentSessionOutputItemStatusResource.fromJson('in_progress');
    expect(v.toJson(), 'in_progress');
  });
  test('OutputItemStatusResource: completed', () {
    final v = AgentSessionOutputItemStatusResource.fromJson('completed');
    expect(v.toJson(), 'completed');
  });
  test('OutputItemStatusResource: incomplete', () {
    final v = AgentSessionOutputItemStatusResource.fromJson('incomplete');
    expect(v.toJson(), 'incomplete');
  });
  test('SessionMessageRoleResource: user', () {
    final v = AgentSessionMessageRoleResource.fromJson('user');
    expect(v.toJson(), 'user');
  });
  test('SessionMessageRoleResource: assistant', () {
    final v = AgentSessionMessageRoleResource.fromJson('assistant');
    expect(v.toJson(), 'assistant');
  });
  test('SessionTurnErrorCodeResource: context_length_exceeded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'context_length_exceeded',
    );
    expect(v.toJson(), 'context_length_exceeded');
  });
  test('SessionTurnErrorCodeResource: session_budget_exceeded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'session_budget_exceeded',
    );
    expect(v.toJson(), 'session_budget_exceeded');
  });
  test('SessionTurnErrorCodeResource: usage_limit_exceeded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'usage_limit_exceeded',
    );
    expect(v.toJson(), 'usage_limit_exceeded');
  });
  test('SessionTurnErrorCodeResource: project_spend_limit_exceeded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'project_spend_limit_exceeded',
    );
    expect(v.toJson(), 'project_spend_limit_exceeded');
  });
  test('SessionTurnErrorCodeResource: organization_spend_limit_exceeded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'organization_spend_limit_exceeded',
    );
    expect(v.toJson(), 'organization_spend_limit_exceeded');
  });
  test('SessionTurnErrorCodeResource: organization_usage_limit_exceeded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'organization_usage_limit_exceeded',
    );
    expect(v.toJson(), 'organization_usage_limit_exceeded');
  });
  test('SessionTurnErrorCodeResource: billing_not_active', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('billing_not_active');
    expect(v.toJson(), 'billing_not_active');
  });
  test('SessionTurnErrorCodeResource: credit_balance_exhausted', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'credit_balance_exhausted',
    );
    expect(v.toJson(), 'credit_balance_exhausted');
  });
  test('SessionTurnErrorCodeResource: rate_limit_exceeded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('rate_limit_exceeded');
    expect(v.toJson(), 'rate_limit_exceeded');
  });
  test('SessionTurnErrorCodeResource: flex_unavailable', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('flex_unavailable');
    expect(v.toJson(), 'flex_unavailable');
  });
  test('SessionTurnErrorCodeResource: server_overloaded', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('server_overloaded');
    expect(v.toJson(), 'server_overloaded');
  });
  test('SessionTurnErrorCodeResource: cyber_policy', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('cyber_policy');
    expect(v.toJson(), 'cyber_policy');
  });
  test('SessionTurnErrorCodeResource: misalignment_policy_violation', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'misalignment_policy_violation',
    );
    expect(v.toJson(), 'misalignment_policy_violation');
  });
  test('SessionTurnErrorCodeResource: connection_failed', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('connection_failed');
    expect(v.toJson(), 'connection_failed');
  });
  test('SessionTurnErrorCodeResource: server_error', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('server_error');
    expect(v.toJson(), 'server_error');
  });
  test('SessionTurnErrorCodeResource: authentication_error', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'authentication_error',
    );
    expect(v.toJson(), 'authentication_error');
  });
  test('SessionTurnErrorCodeResource: invalid_request', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('invalid_request');
    expect(v.toJson(), 'invalid_request');
  });
  test('SessionTurnErrorCodeResource: resource_not_found', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('resource_not_found');
    expect(v.toJson(), 'resource_not_found');
  });
  test('SessionTurnErrorCodeResource: sandbox_error', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('sandbox_error');
    expect(v.toJson(), 'sandbox_error');
  });
  test('SessionTurnErrorCodeResource: executor_version_incompatible', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'executor_version_incompatible',
    );
    expect(v.toJson(), 'executor_version_incompatible');
  });
  test('SessionTurnErrorCodeResource: active_turn_not_steerable', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson(
      'active_turn_not_steerable',
    );
    expect(v.toJson(), 'active_turn_not_steerable');
  });
  test('SessionTurnErrorCodeResource: request_timeout', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('request_timeout');
    expect(v.toJson(), 'request_timeout');
  });
  test('SessionTurnErrorCodeResource: internal_error', () {
    final v = AgentSessionTurnErrorCodeResource.fromJson('internal_error');
    expect(v.toJson(), 'internal_error');
  });
  test('SessionTurnItemResource: known agent_message source variant', () {
    final body =
        jsonDecode(
              r'''{"content": [{"encrypted_content": "PRIVATE-encrypted-opaque", "type": "encrypted_content"}], "id": "item_synthetic", "recipient_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "sender_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "turn_id": "turn_child", "type": "agent_message"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'agent_message',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known close_subagent_call source variant', () {
    final body =
        jsonDecode(
              r'''{"id": "item_synthetic", "recipient_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "sender_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "close_subagent_call"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'close_subagent_call',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known command_execution source variant', () {
    final body =
        jsonDecode(
              r'''{"command": "PRIVATE-field-caf\u00e9\ud83d\ude80", "cwd": "PRIVATE-field-caf\u00e9\ud83d\ude80", "duration_ms": 2, "exit_code": 2, "id": "item_synthetic", "output": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "command_execution"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'command_execution',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'SessionTurnItemResource: known computer_use_approval_request source variant',
    () {
      final body =
          jsonDecode(
                r'''{"id": "item_synthetic", "request": {"credential_origin": "https://private.example.test/login", "fields": [{"id": "item_synthetic", "label": "PRIVATE-field-caf\u00e9\ud83d\ude80", "required": true, "type": "PRIVATE-field-caf\u00e9\ud83d\ude80"}], "options": [{"field_ids": ["PRIVATE-field-caf\u00e9\ud83d\ude80"], "id": "item_synthetic", "label": "PRIVATE-field-caf\u00e9\ud83d\ude80"}], "reason": "PRIVATE-field-caf\u00e9\ud83d\ude80", "type": "browser_authentication"}, "request_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "turn_id": "turn_child", "type": "computer_use_approval_request"}''',
              )
              as Map<String, dynamic>;
      final value = AgentSessionTurnItem.fromJson(body);
      expect(value.toJson(), body);
      expect(
        () => AgentSessionTurnItem.fromJson({
          ...body,
          'type': 'computer_use_approval_request',
          'PRIVATE-required': null,
        }),
        returnsNormally,
      );
    },
  );
  test(
    'SessionTurnItemResource: known computer_use_approval_request_result source variant',
    () {
      final body =
          jsonDecode(
                r'''{"id": "item_synthetic", "request_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "response": {"action": "cancel", "type": "browser_authentication"}, "turn_id": "turn_child", "type": "computer_use_approval_request_result"}''',
              )
              as Map<String, dynamic>;
      final value = AgentSessionTurnItem.fromJson(body);
      expect(value.toJson(), body);
      expect(
        () => AgentSessionTurnItem.fromJson({
          ...body,
          'type': 'computer_use_approval_request_result',
          'PRIVATE-required': null,
        }),
        returnsNormally,
      );
    },
  );
  test('SessionTurnItemResource: known computer_use_call source variant', () {
    final body =
        jsonDecode(
              r'''{"id": "item_synthetic", "output": {"image_url": "data:image/jpeg;base64,UFJJVkFURQ==", "type": "computer_screenshot"}, "status": "incomplete", "title": "PRIVATE-field-caf\u00e9\ud83d\ude80", "turn_id": "turn_child", "type": "computer_use_call"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'computer_use_call',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known create_subagent_call source variant', () {
    final body =
        jsonDecode(
              r'''{"agent_id": "subagent_child", "content": [{"encrypted_content": "PRIVATE-encrypted-opaque", "type": "encrypted_content"}], "id": "item_synthetic", "model": "PRIVATE-field-caf\u00e9\ud83d\ude80", "reasoning_effort": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "create_subagent_call"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'create_subagent_call',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known function_call source variant', () {
    final body =
        jsonDecode(
              r'''{"arguments": "{\"PRIVATE\":\"synthetic\"}", "call_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "id": "item_synthetic", "name": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "function_call"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'function_call',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known function_call_output source variant', () {
    final body =
        jsonDecode(
              r'''{"call_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "error": "PRIVATE-field-caf\u00e9\ud83d\ude80", "id": "item_synthetic", "output": [{"image_url": "data:image/jpeg;base64,UFJJVkFURQ==", "type": "input_image"}], "status": "incomplete", "turn_id": "turn_child", "type": "function_call_output"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'function_call_output',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'SessionTurnItemResource: known interrupt_subagent_call source variant',
    () {
      final body =
          jsonDecode(
                r'''{"id": "item_synthetic", "recipient_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "sender_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "interrupt_subagent_call"}''',
              )
              as Map<String, dynamic>;
      final value = AgentSessionTurnItem.fromJson(body);
      expect(value.toJson(), body);
      expect(
        () => AgentSessionTurnItem.fromJson({
          ...body,
          'type': 'interrupt_subagent_call',
          'PRIVATE-required': null,
        }),
        returnsNormally,
      );
    },
  );
  test('SessionTurnItemResource: known mcp_call source variant', () {
    final body =
        jsonDecode(
              r'''{"arguments": "{\"PRIVATE\":\"synthetic\"}", "error": "PRIVATE-field-caf\u00e9\ud83d\ude80", "id": "item_synthetic", "name": "PRIVATE-field-caf\u00e9\ud83d\ude80", "output": "PRIVATE-field-caf\u00e9\ud83d\ude80", "server_label": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "mcp_call"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'mcp_call',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known message source variant', () {
    final body =
        jsonDecode(
              r'''{"content": [{"text": "PRIVATE-task-caf\u00e9\ud83d\ude80 [image preview] [audio preview]", "type": "output_text"}], "id": "item_synthetic", "phase": "final_answer", "role": "assistant", "status": "incomplete", "turn_id": "turn_child", "type": "message"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'message',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known reasoning source variant', () {
    final body =
        jsonDecode(
              r'''{"id": "item_synthetic", "status": "incomplete", "summary": [{"text": "PRIVATE-task-caf\u00e9\ud83d\ude80 [image preview] [audio preview]", "type": "summary_text"}], "turn_id": "turn_child", "type": "reasoning"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'reasoning',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('SessionTurnItemResource: known resume_subagent_call source variant', () {
    final body =
        jsonDecode(
              r'''{"id": "item_synthetic", "recipient_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "sender_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "resume_subagent_call"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'resume_subagent_call',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'SessionTurnItemResource: known send_subagent_input_call source variant',
    () {
      final body =
          jsonDecode(
                r'''{"content": [{"encrypted_content": "PRIVATE-encrypted-opaque", "type": "encrypted_content"}], "id": "item_synthetic", "recipient_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "sender_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "send_subagent_input_call"}''',
              )
              as Map<String, dynamic>;
      final value = AgentSessionTurnItem.fromJson(body);
      expect(value.toJson(), body);
      expect(
        () => AgentSessionTurnItem.fromJson({
          ...body,
          'type': 'send_subagent_input_call',
          'PRIVATE-required': null,
        }),
        returnsNormally,
      );
    },
  );
  test(
    'SessionTurnItemResource: known wait_for_subagents_call source variant',
    () {
      final body =
          jsonDecode(
                r'''{"id": "item_synthetic", "recipient_agent_ids": ["PRIVATE-field-caf\u00e9\ud83d\ude80"], "sender_agent_id": "PRIVATE-field-caf\u00e9\ud83d\ude80", "status": "incomplete", "turn_id": "turn_child", "type": "wait_for_subagents_call"}''',
              )
              as Map<String, dynamic>;
      final value = AgentSessionTurnItem.fromJson(body);
      expect(value.toJson(), body);
      expect(
        () => AgentSessionTurnItem.fromJson({
          ...body,
          'type': 'wait_for_subagents_call',
          'PRIVATE-required': null,
        }),
        returnsNormally,
      );
    },
  );
  test('SessionTurnItemResource: known web_search_call source variant', () {
    final body =
        jsonDecode(
              r'''{"action": {"type": "other"}, "id": "item_synthetic", "status": "incomplete", "turn_id": "turn_child", "type": "web_search_call"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionTurnItem.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionTurnItem.fromJson({
        ...body,
        'type': 'web_search_call',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'SessionTurnItemResource: unknown privately owned received fallback',
    () {
      final value = AgentSessionTurnItem.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
    },
  );
  test('SubagentObjectResource: agent.session.subagent', () {
    final v = AgentSessionSubagentObjectResource.fromJson(
      'agent.session.subagent',
    );
    expect(v.toJson(), 'agent.session.subagent');
  });
  test('SubagentStatusResource: active', () {
    final v = AgentSessionSubagentStatusResource.fromJson('active');
    expect(v.toJson(), 'active');
  });
  test('SubagentStatusResource: closed', () {
    final v = AgentSessionSubagentStatusResource.fromJson('closed');
    expect(v.toJson(), 'closed');
  });
  test('TurnObjectResource: agent.session.turn', () {
    final v = AgentSessionTurnObjectResource.fromJson('agent.session.turn');
    expect(v.toJson(), 'agent.session.turn');
  });
  test('TurnStatusResource: queued', () {
    final v = AgentSessionTurnStatusResource.fromJson('queued');
    expect(v.toJson(), 'queued');
  });
  test('TurnStatusResource: in_progress', () {
    final v = AgentSessionTurnStatusResource.fromJson('in_progress');
    expect(v.toJson(), 'in_progress');
  });
  test('TurnStatusResource: waiting', () {
    final v = AgentSessionTurnStatusResource.fromJson('waiting');
    expect(v.toJson(), 'waiting');
  });
  test('TurnStatusResource: completed', () {
    final v = AgentSessionTurnStatusResource.fromJson('completed');
    expect(v.toJson(), 'completed');
  });
  test('TurnStatusResource: failed', () {
    final v = AgentSessionTurnStatusResource.fromJson('failed');
    expect(v.toJson(), 'failed');
  });
  test('TurnStatusResource: cancelled', () {
    final v = AgentSessionTurnStatusResource.fromJson('cancelled');
    expect(v.toJson(), 'cancelled');
  });
  test('WebSearchActionResource: known find_in_page source variant', () {
    final body =
        jsonDecode(
              r'''{"pattern": "PRIVATE-field-caf\u00e9\ud83d\ude80", "type": "find_in_page", "url": "https://private.example.test/login"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionWebSearchActionResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionWebSearchActionResource.fromJson({
        ...body,
        'type': 'find_in_page',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('WebSearchActionResource: known open_page source variant', () {
    final body =
        jsonDecode(
              r'''{"type": "open_page", "url": "https://private.example.test/login"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionWebSearchActionResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionWebSearchActionResource.fromJson({
        ...body,
        'type': 'open_page',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('WebSearchActionResource: known other source variant', () {
    final body = jsonDecode(r'''{"type": "other"}''') as Map<String, dynamic>;
    final value = AgentSessionWebSearchActionResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionWebSearchActionResource.fromJson({
        ...body,
        'type': 'other',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test('WebSearchActionResource: known search source variant', () {
    final body =
        jsonDecode(
              r'''{"queries": ["PRIVATE-field-caf\u00e9\ud83d\ude80"], "query": "PRIVATE-field-caf\u00e9\ud83d\ude80", "type": "search"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionWebSearchActionResource.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionWebSearchActionResource.fromJson({
        ...body,
        'type': 'search',
        'PRIVATE-required': null,
      }),
      returnsNormally,
    );
  });
  test(
    'WebSearchActionResource: unknown privately owned received fallback',
    () {
      final value = AgentSessionWebSearchActionResource.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
    },
  );
}
