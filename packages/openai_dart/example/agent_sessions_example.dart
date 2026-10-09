// ignore_for_file: avoid_print

// Run: dart run example/agent_sessions_example.dart
// Offline mock HTTP/SSE; no key, model execution or hosted compute ($0).
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final transport = _SessionTransport();
  final client = OpenAIClient.withApiKey(
    'synthetic-offline',
    httpClient: transport,
  );
  try {
    final sessions = client.agents.sessions;
    final session = await sessions.create(
      CreateAgentSessionRequest(
        agent: AgentSessionAgentConfig(
          model: 'literal-model',
          tools: [
            AgentSessionTool.function(
              name: 'lookup',
              description: 'Local example lookup',
              parameters: const {
                'type': 'object',
                'properties': {
                  'city': {'type': 'string'},
                },
              },
            ),
          ],
        ),
        environment: AgentSessionEnvironment.none(),
        input: AgentSessionInitialInput.text('Look up Paris.'),
      ),
    );
    // Optional alternatives: agentId:'saved_agent' attaches saved configuration;
    // AgentSessionEnvironment.openaiHosted(environmentId:'existing_environment')
    // attaches hosted compute. Neither is a prerequisite for this inline example.
    final idleObserved = Completer<void>();
    final observer = sessions.events
        .stream(session.id)
        .listen(
          (event) async {
            try {
              if (event is AgentSessionRequiresActionEvent) {
                for (final action in event.session.requiredActions) {
                  if (action is AgentSessionFunctionCallRequiredAction &&
                      action.name == 'lookup') {
                    // Application-controlled dispatch: inspect arguments and choose a result.
                    await sessions.events.create(
                      session.id,
                      CreateAgentSessionEventsRequest(
                        events: [
                          AgentSessionInput.toolResult(
                            callId: action.callId,
                            turnId: action.turnId,
                            success: true,
                            output: AgentSessionFunctionOutput.text(
                              'Paris: 18°C',
                            ),
                          ),
                        ],
                      ),
                      idempotencyKey: 'lookup-result-1',
                    );
                  }
                }
              }
              if (event is AgentSessionIdleEvent && !idleObserved.isCompleted) {
                idleObserved.complete();
              }
            } catch (error, stack) {
              if (!idleObserved.isCompleted) {
                idleObserved.completeError(error, stack);
              }
            }
          },
          onError: (Object error) {
            if (!idleObserved.isCompleted) idleObserved.completeError(error);
          },
          onDone: () {
            if (!idleObserved.isCompleted) {
              idleObserved.completeError(
                StateError(
                  'Observation ended; retrieve current state before continuing',
                ),
              );
            }
          },
        );
    // Observe before new submissions. HTTP 202 confirms acceptance, not completion.
    await sessions.events.create(
      session.id,
      CreateAgentSessionEventsRequest(
        events: [
          AgentSessionInput.message(
            input: [
              AgentSessionInputMessage(
                content: [
                  AgentSessionInputContent.inputText(
                    text: 'Continue the lookup.',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      idempotencyKey: 'message-1',
    );
    await idleObserved
        .future; // Idle observed; this does not prove successful completion.
    await observer.cancel(); // Local observer only; no backend cancellation.
    await sessions.update(
      session.id,
      UpdateAgentSessionRequest(
        spendControl: AgentSessionSpendControlConfig(limit: 100),
      ),
    );
    await sessions.update(
      session.id,
      UpdateAgentSessionRequest(clearSpendControl: true),
    ); // Does not reset recorded spend.
    await sessions.list(limit: 10, order: AgentListOrder.desc);
    await sessions.events.create(
      session.id,
      CreateAgentSessionEventsRequest(events: [AgentSessionInput.cancel()]),
    );
    // Real applications retrieve/observe until execution cancellation is confirmed.
    await sessions.retrieve(session.id);
    await sessions.delete(
      session.id,
    ); // Separate lifecycle action after cancellation.
    print(
      'Offline session workflow complete: ${transport.requests} mock requests; cost \$0.',
    );
  } finally {
    client.close();
    transport.close();
  }
}

class _SessionTransport extends http.BaseClient {
  final body = StreamController<List<int>>();
  int requests = 0;
  final Map<String, dynamic> session = {
    'agent': {
      'id': 'inline_agent',
      'instructions': null,
      'model': 'literal-model',
      'multi_agent': {'enabled': false, 'max_concurrent_subagents': null},
      'name': null,
      'reasoning': {'effort': null, 'summary': null},
      'service_tier': 'auto',
      'text': {
        'format': {'type': 'text'},
        'verbosity': 'low',
      },
      'tools': <Object?>[],
    },
    'created_at': 1,
    'environment': {'type': 'none'},
    'error': null,
    'id': 'session_example',
    'last_active_at': 1,
    'metadata': <String, dynamic>{},
    'object': 'agent.session',
    'required_actions': <Object?>[],
    'status': 'idle',
    'usage': null,
    'vault_ids': <String>[],
  };
  void emit(Map<String, dynamic> event) {
    body.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests++;
    final bytes = await request.finalize().toBytes();
    if (request.headers['accept'] == 'text/event-stream') {
      scheduleMicrotask(
        () => emit({
          'type': 'agent.session.requires_action',
          'event_id': 'event_action',
          'session': {
            ...session,
            'status': 'requires_action',
            'required_actions': [
              {
                'type': 'function_call',
                'call_id': 'call_example',
                'turn_id': 'turn_example',
                'name': 'lookup',
                'arguments': {'city': 'Paris'},
              },
            ],
          },
        }),
      );
      return http.StreamedResponse(
        body.stream,
        200,
        request: request,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (request.url.path.endsWith('/events')) {
      final input = jsonDecode(utf8.decode(bytes)) as Map;
      final events = input['events'] as List;
      if (events.any(
        (dynamic e) => (e as Map)['type'] == 'agent.session.input.tool_result',
      )) {
        emit({
          'type': 'agent.session.idle',
          'event_id': 'event_idle',
          'session': session,
        });
      }
      return http.StreamedResponse(
        Stream.value(<int>[]),
        202,
        request: request,
      );
    }
    final Object response = request.method == 'DELETE'
        ? {
            'id': session['id'],
            'object': 'agent.session.deleted',
            'deleted': true,
          }
        : request.method == 'GET' && request.url.path.endsWith('/sessions')
        ? {
            'object': 'list',
            'data': [session],
            'has_more': false,
            'first_id': session['id'],
            'last_id': session['id'],
          }
        : session;
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(response))),
      request.method == 'POST' && request.url.path.endsWith('/sessions')
          ? 201
          : 200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  void close() {
    unawaited(body.close());
  }
}
