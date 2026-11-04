/// Exercises scheduled Agent configuration and explicit delivery inspection.
/// Every request uses a synthetic HTTP peer: no API key or real schedules.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final peer = _AutomationPeer();
  final transport = MockClient(peer.handle);
  final client = OpenAIClient(httpClient: transport);
  try {
    final automations = client.agents.automations;
    final followUp = await automations.create(
      CreateAgentAutomationRequest.once(
        name: 'Follow up on the existing conversation',
        runAt: 2000000000, // A future Unix timestamp in seconds.
        target: AgentAutomationTarget.existingSession(
          sessionId: 'session_demo',
          instructions: 'Check whether the pending report is available.',
        ),
      ),
    );
    final daily = await automations.create(
      CreateAgentAutomationRequest.periodic(
        name: 'Daily independent report',
        expression: '0 10 * * MON-FRI',
        timezone: 'Europe/Madrid',
        target: AgentAutomationTarget.newSession(
          agentId: 'agent_demo',
          environment: AgentSessionEnvironment.none(),
          input: [
            AgentSessionInputMessage(
              content: [
                AgentSessionInputContent.inputText(
                  text: 'Prepare a brief report from the available context.',
                ),
              ],
            ),
          ],
        ),
        metadata: const {'project': 'demo'},
      ),
    );
    if (followUp is! AgentAutomationOnce || daily is! AgentAutomationPeriodic) {
      throw StateError('The synthetic schedule variants were lost.');
    }
    // Creating, updating, pausing and resuming configure scheduling only.
    // Add AgentTool.automations() to a saved Agent (or the session equivalent)
    // when the Agent itself should be able to schedule future follow-ups.
    final stored = await automations.retrieve(daily.id);
    if (stored != daily || peer.invocations != 0) {
      throw StateError('Saving a schedule must not invoke it immediately.');
    }

    final page = await automations.list(
      sessionId: 'session_demo',
      limit: 10,
      order: AgentListOrder.asc,
    );
    if (page.data.single.id != followUp.id) {
      throw StateError('The existing-session filter was lost.');
    }
    // Pagination is explicit. Retain filters and stop if a cursor cannot advance.
    if (page.hasMore) {
      final after = page.lastId;
      if (after == null || after.isEmpty) {
        throw StateError('The next page needs an advancing cursor.');
      }
      final next = await automations.list(
        sessionId: 'session_demo',
        limit: 10,
        order: AgentListOrder.asc,
        after: after,
      );
      if (next.hasMore && (next.lastId == null || next.lastId == after)) {
        throw StateError('The next-page cursor did not advance.');
      }
    }

    final updated = await automations.update(
      daily.id,
      UpdateAgentAutomationRequest(
        expression: '0 11 * * MON-FRI',
        metadata: const {},
      ),
    );
    if (updated is! AgentAutomationPeriodic || updated.metadata.isNotEmpty) {
      throw StateError('Supplied metadata must replace the complete map.');
    }
    await automations.pause(daily.id);
    // Manual delivery also works while paused; it does not change the schedule.
    final queued = await automations.invocations.create(daily.id);
    if (queued.status.value != 'queued' || queued.sessionId != null) {
      throw StateError('Expected a queued delivery without a session yet.');
    }
    await automations.resume(daily.id);
    final delivered = await automations.invocations.retrieve(
      daily.id,
      queued.id,
    );
    if (delivered.status.value != 'completed' || delivered.sessionId == null) {
      throw StateError('Expected a delivered notification with a session ID.');
    }
    // Delivery completion is not Agent-work completion. In a live application,
    // follow client.agents.sessions.events with delivered.sessionId separately.
    final history = await automations.invocations.list(daily.id, limit: 10);
    if (history.data.length != 2 ||
        history.data.first.skipReason != 'pending_delivery' ||
        history.data.last.error?.code != 'delivery_failed') {
      throw StateError('Scheduled invocation history lost skip/error details.');
    }
    await automations.delete(followUp.id);
    await automations.delete(daily.id);
    // Deleting the schedules leaves their target sessions and accepted work.
    stdout.writeln(
      'Offline automation lifecycle: ${peer.requests} mock requests, '
      '${peer.invocations} explicit manual invocation; no real jobs or charges.',
    );
  } finally {
    client.close();
    transport.close();
  }
}

class _AutomationPeer {
  final Map<String, Map<String, dynamic>> _automations = {};
  int requests = 0;
  int invocations = 0;

  Future<http.Response> handle(http.Request request) async {
    requests++;
    if (request.headers['openai-beta'] != 'agents=v1') {
      throw StateError('Missing Agents opt-in header.');
    }
    final segments = request.url.pathSegments;
    final isCollection = segments.length == 3;
    final isInvocation = segments.contains('invocations');
    final id = isCollection ? null : segments[3];
    final body = request.bodyBytes.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
    var status = 200;
    Object wire;
    if (isInvocation) {
      if (request.method == 'POST') {
        if (request.bodyBytes.isNotEmpty) {
          throw StateError('Manual invocation must have no request body.');
        }
        invocations++;
        wire = _invocation(id!, 'queued');
      } else if (segments.length == 6) {
        wire = _invocation(id!, 'completed', sessionId: 'session_new');
      } else {
        wire = _page([
          {
            ..._invocation(id!, 'skipped'),
            'id': 'invocation_skipped',
            'source': {'type': 'automation', 'automation': _automations[id]},
            'scheduled_at': 2000000000,
            'skip_reason': 'pending_delivery',
          },
          {
            ..._invocation(id, 'failed'),
            'id': 'invocation_failed',
            'source': {'type': 'automation', 'automation': _automations[id]},
            'scheduled_at': 2000000001,
            'error': {
              'code': 'delivery_failed',
              'message': 'Synthetic failure',
            },
          },
        ]);
      }
    } else if (request.method == 'DELETE') {
      _automations.remove(id);
      wire = {'id': id, 'object': 'agent.automation.deleted', 'deleted': true};
    } else if (isCollection && request.method == 'POST') {
      status = 201;
      final newId = 'automation_${_automations.length + 1}';
      final target = Map<String, dynamic>.of(
        body['target'] as Map<String, dynamic>,
      );
      if (target['type'] == 'new_session') {
        target.addAll({
          'agent': null,
          'vault_ids': <String>[],
          'metadata': <String, String>{},
        });
      }
      final automation = <String, dynamic>{
        ...body,
        'id': newId,
        'object': 'agent.automation',
        'created_at': 1,
        'target': target,
        'metadata': body['metadata'] ?? <String, String>{},
        'created_by': {'type': 'developer'},
        'status': 'active',
      };
      _automations[newId] = automation;
      wire = automation;
    } else if (isCollection) {
      final query = request.url.queryParameters;
      if (query['session_id'] != 'session_demo' || query['order'] != 'asc') {
        throw StateError('List options must remain stable between pages.');
      }
      wire = query.containsKey('after')
          ? _page([])
          : _page([_automations.values.first], hasMore: true);
    } else if (request.method == 'POST') {
      final current = _automations[id]!;
      if (segments.last == 'pause' || segments.last == 'resume') {
        if (request.bodyBytes.isNotEmpty) {
          throw StateError('Pause/resume must have no request body.');
        }
        current['status'] = segments.last == 'pause' ? 'paused' : 'active';
      } else {
        current.addAll(body);
      }
      wire = current;
    } else {
      wire = _automations[id]!;
    }
    return http.Response.bytes(
      utf8.encode(jsonEncode(wire)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  Map<String, dynamic> _invocation(
    String automationId,
    String status, {
    String? sessionId,
  }) => {
    'id': 'invocation_manual',
    'object': 'agent.automation.invocation',
    'automation_id': automationId,
    'created_at': 1,
    'source': {'type': 'manual'},
    'scheduled_at': null,
    'session_id': sessionId,
    'status': status,
    'skip_reason': null,
    'error': null,
  };

  Map<String, dynamic> _page(
    List<Map<String, dynamic>> data, {
    bool hasMore = false,
  }) => {
    'object': 'list',
    'data': data,
    'first_id': data.isEmpty ? null : data.first['id'],
    'last_id': data.isEmpty ? null : data.last['id'],
    'has_more': hasMore,
  };
}
