import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_wire_fixtures.dart';

Map<String, dynamic> _session({
  String requestId = 'current',
  String status = 'requires_action',
}) {
  final wire =
      jsonDecode(
            jsonEncode(
              agentSessionWireFixtures
                  .singleWhere((f) => f.schema == 'SessionResource')
                  .minimal,
            ),
          )
          as Map<String, dynamic>;
  return wire
    ..['id'] = 'session'
    ..['status'] = status
    ..['required_actions'] = [
      {
        'type': 'computer_use_approval_request',
        'turn_id': 'turn',
        'request_id': requestId,
        'request': {
          'type': 'browser_authentication',
          'credential_origin': 'https://site.invalid',
          'reason': null,
          'fields': [
            {
              'id': 'current-field',
              'label': 'Code',
              'required': true,
              'type': 'password',
            },
          ],
          'options': <Object?>[],
        },
      },
    ];
}

http.StreamedResponse _json(Object body, [int status = 200]) =>
    http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      status,
      headers: {'content-type': 'application/json'},
    );
List<int> _sse(Object event) => utf8.encode('data: ${jsonEncode(event)}\n\n');
Map<String, dynamic> _delta(String eventId, String itemId, String delta) => {
  'type': 'agent.session.turn.output_text.delta',
  'event_id': eventId,
  'session_id': 'session',
  'turn_id': 'turn',
  'item_id': itemId,
  'output_index': 0,
  'content_index': 0,
  'delta': delta,
};
Map<String, dynamic> _item(String id, String text) => {
  'type': 'message',
  'role': 'assistant',
  'id': id,
  'turn_id': 'turn',
  'phase': null,
  'status': 'completed',
  'content': [
    {'type': 'output_text', 'text': text},
  ],
};

void main() {
  test(
    'readiness follows validated headers and precedes first event',
    () async {
      final response = Completer<http.StreamedResponse>();
      final body = StreamController<List<int>>();
      var ready = false;
      final transport = MockClient.streaming((_, _) => response.future);
      final client = OpenAIClient(httpClient: transport);
      final events = <AgentSessionEvent>[];
      final subscription = client.agents.sessions.events
          .stream('session', onReady: () => ready = true)
          .listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(ready, isFalse);
      response.complete(
        http.StreamedResponse(
          body.stream,
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        ),
      );
      await _until(() => ready);
      expect(events, isEmpty);
      body.add(_sse(_delta('event', 'item', 'first')));
      await _until(() => events.isNotEmpty);
      await subscription.cancel();
      await body.close();
      client.close();
      transport.close();
    },
  );

  test(
    'readiness callback can cancel reentrantly without retaining the body',
    () async {
      var canceled = false;
      var callbacks = 0;
      final body = StreamController<List<int>>(onCancel: () => canceled = true);
      final transport = MockClient.streaming(
        (_, _) async => http.StreamedResponse(
          body.stream,
          200,
          headers: {'content-type': 'text/event-stream'},
        ),
      );
      final client = OpenAIClient(httpClient: transport);
      late StreamSubscription<AgentSessionEvent> sub;
      sub = client.agents.sessions.events
          .stream(
            'session',
            onReady: () {
              callbacks++;
              unawaited(sub.cancel());
            },
          )
          .listen((_) => fail('No bytes may be delivered after cancellation'));
      await _until(() => canceled);
      expect(callbacks, 1);
      await body.close();
      client.close();
      transport.close();
    },
  );

  for (final scenario in ['status', 'media', 'callback', 'callback-private']) {
    test('failed $scenario setup never leaves a response subscribed', () async {
      var ready = 0;
      var canceled = false;
      final callbackError = scenario == 'callback-private'
          ? const ApiException(message: 'PRIVATE-callback', statusCode: 400)
          : StateError('PRIVATE-application-callback');
      final body = StreamController<List<int>>(onCancel: () => canceled = true);
      final transport = MockClient.streaming(
        (_, _) async => http.StreamedResponse(
          body.stream,
          scenario == 'status' ? 201 : 200,
          headers: {
            'content-type': scenario == 'media'
                ? 'application/json'
                : 'text/event-stream',
          },
        ),
      );
      final client = OpenAIClient(httpClient: transport);
      final observed = client.agents.sessions.events
          .stream(
            'session',
            onReady: () {
              ready++;
              if (scenario.startsWith('callback')) {
                Error.throwWithStackTrace(callbackError, StackTrace.current);
              }
            },
          )
          .drain<void>();
      await expectLater(
        observed,
        throwsA(
          scenario.startsWith('callback')
              ? isA<ConnectionException>()
                    .having(
                      (error) => error.cause,
                      'explicit original cause',
                      same(callbackError),
                    )
                    .having(
                      (error) => error.toString(),
                      'private callback diagnostics',
                      isNot(contains('PRIVATE')),
                    )
              : isA<ParseException>(),
        ),
      );
      expect(ready, scenario.startsWith('callback') ? 1 : 0);
      expect(canceled, isTrue);
      await body.close();
      client.close();
      transport.close();
    });
  }

  test(
    'cancel pending headers suppresses readiness and disposes late body',
    () async {
      final response = Completer<http.StreamedResponse>();
      var ready = false;
      var sent = false;
      var canceled = false;
      final body = StreamController<List<int>>(onCancel: () => canceled = true);
      final transport = MockClient.streaming((_, _) {
        sent = true;
        return response.future;
      });
      final client = OpenAIClient(httpClient: transport);
      final sub = client.agents.sessions.events
          .stream('session', onReady: () => ready = true)
          .listen((_) {});
      await _until(() => sent);
      await sub.cancel();
      response.complete(
        http.StreamedResponse(
          body.stream,
          200,
          headers: {'content-type': 'text/event-stream'},
        ),
      );
      await _until(() => canceled);
      expect(ready, isFalse);
      await body.close();
      client.close();
      transport.close();
    },
  );

  test(
    'subscribe and buffer before history; reconcile final IDs and refresh current actions without replay',
    () async {
      final body = StreamController<List<int>>();
      final ready = Completer<void>();
      final receivedDuringRetrieval = Completer<void>();
      final buffer = <AgentSessionEvent>[];
      final seen = <String>{};
      final text = <String, String>{};
      final finals = <String, Map<String, dynamic>>{};
      final calls = <String>[];
      var retrieves = 0;
      var buffering = true;
      var bytes = 0;
      void apply(AgentSessionEvent event) {
        final id = event.toJson()['event_id'] as String;
        if (!seen.add(id)) return;
        if (event case final AgentSessionTurnOutputTextDeltaEvent delta) {
          if (!finals.containsKey(delta.itemId)) {
            text.update(
              delta.itemId,
              (s) => s + delta.delta,
              ifAbsent: () => delta.delta,
            );
          }
        }
      }

      final transport = MockClient.streaming((request, _) async {
        calls.add('${request.method} ${request.url.path}');
        expect(request.headers['openai-beta'], 'agents=v1');
        if (request.url.path.endsWith('/events')) {
          expect(request.method, 'GET');
          return http.StreamedResponse(
            body.stream,
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        if (request.url.path.endsWith('/items')) {
          expect(request.url.queryParameters['order'], 'asc');
          final nextPage = request.url.queryParameters['after'] == 'saved';
          final id = nextPage ? 'second' : 'saved';
          return _json({
            'object': 'list',
            'data': [_item(id, 'Final $id')],
            'first_id': id,
            'last_id': id,
            'has_more': !nextPage,
          });
        }
        retrieves++;
        if (retrieves == 1) {
          body
            ..add(_sse(_delta('same', 'saved', 'obsolete')))
            ..add(_sse(_delta('same', 'saved', 'obsolete')))
            ..add(_sse(_delta('fresh', 'live', 'new text')))
            ..add(
              _sse({
                'type': 'agent.session.requires_action',
                'event_id': 'action',
                'session': _session(requestId: 'stale'),
              }),
            );
          await receivedDuringRetrieval.future;
        }
        return _json(_session(requestId: retrieves == 1 ? 'stale' : 'current'));
      });
      final client = OpenAIClient(httpClient: transport);
      final sessions = client.agents.sessions;
      final subscription = sessions.events
          .stream('session', onReady: ready.complete)
          .listen((event) {
            if (buffering) {
              bytes += utf8.encode(jsonEncode(event.toJson())).length;
              if (buffer.length >= 256 || bytes > 1024 * 1024) {
                throw StateError('Application recovery buffer exceeded');
              }
              buffer.add(event);
              if (buffer.length == 4) receivedDuringRetrieval.complete();
            } else {
              apply(event);
            }
          });
      try {
        await ready.future;
        var current = await sessions.retrieve('session');
        String? cursor;
        do {
          final page = await sessions.items.list(
            'session',
            order: AgentListOrder.asc,
            after: cursor,
          );
          for (final item in page.data) {
            final wire = item.toJson();
            finals[wire['id'] as String] = wire;
          }
          if (!page.hasMore) break;
          if (page.lastId == null || page.lastId == cursor) {
            throw StateError('Invalid history cursor');
          }
          cursor = page.lastId;
        } while (true);
        buffer
          ..forEach(apply)
          ..clear();
        bytes = 0;
        buffering = false;
        // Current actions are authoritative; historical/buffered request IDs never
        // authorize a response. Refresh again before presenting/submitting a form.
        current = await sessions.retrieve('session');
        expect(
          (current.requiredActions.single
                  as AgentSessionComputerUseApprovalRequiredAction)
              .requestId,
          'current',
        );
        expect(finals.keys, ['saved', 'second']);
        expect(text, {'live': 'new text'});
        body.add(_sse(_delta('later', 'live', ' continued')));
        await _until(() => text['live'] == 'new text continued');
        expect(calls.first, 'GET /v1/agents/sessions/session/events');
        expect(calls.where((call) => !call.startsWith('GET ')), isEmpty);
      } finally {
        await subscription.cancel();
        await body.close();
        client.close();
        transport.close();
      }
      expect(buffer, isEmpty);
    },
  );

  for (final decision in [
    AgentSessionBrowserOriginAccessDecision.approve,
    AgentSessionBrowserOriginAccessDecision.deny,
    AgentSessionBrowserOriginAccessDecision.cancel,
  ]) {
    test(
      'origin ${decision.value} targets current request without a turn ID',
      () async {
        final sent = <Map<String, dynamic>>[];
        final transport = MockClient((request) async {
          sent.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response('', 202);
        });
        final client = OpenAIClient(httpClient: transport);
        await client.agents.sessions.events.create(
          'session',
          CreateAgentSessionEventsRequest(
            events: [
              AgentSessionApprovalResultInput(
                requestId: 'current',
                response: AgentSessionBrowserOriginAccessResponse(
                  decision: decision,
                ),
              ),
            ],
          ),
        );
        expect(sent.single, {
          'events': [
            {
              'type':
                  'agent.session.input.computer_use_approval_request_result',
              'request_id': 'current',
              'response': {
                'type': 'browser_origin_access',
                'decision': decision.value,
              },
            },
          ],
        });
        client.close();
        transport.close();
      },
    );
  }

  for (final failure in ['status', 'transport']) {
    test(
      'private authentication is sent once on uncertain $failure and current state is explicitly refreshed',
      () async {
        final previousHierarchy = hierarchicalLoggingEnabled;
        hierarchicalLoggingEnabled = true;
        final records = <String>[];
        final logging = Logger.root.onRecord.listen((record) {
          records.add('${record.message} ${record.error ?? ''}');
        });
        addTearDown(() async {
          await logging.cancel();
          hierarchicalLoggingEnabled = previousHierarchy;
        });
        var attempts = 0;
        var gets = 0;
        final transport = MockClient((request) async {
          if (request.method == 'GET') {
            gets++;
            return http.Response(
              jsonEncode(_session(requestId: 'new-current')),
              200,
            );
          }
          attempts++;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final event = (body['events'] as List).single as Map;
          expect(event.containsKey('turn_id'), isFalse);
          expect(event['response'], {
            'type': 'browser_authentication',
            'action': 'submit',
            'fields': [
              {'field_id': 'current-field', 'value': 'PRIVATE-one-use'},
            ],
          });
          if (failure == 'transport') {
            throw http.ClientException('PRIVATE-transport');
          }
          return http.Response('{"error":{"message":"PRIVATE-server"}}', 503);
        });
        final client = OpenAIClient(
          config: const OpenAIConfig(
            logLevel: Level.FINEST,
            retryPolicy: RetryPolicy(
              maxRetries: 3,
              initialDelay: Duration(milliseconds: 1),
            ),
          ),
          httpClient: transport,
        );
        final response = AgentSessionBrowserAuthenticationResponse.submit(
          fields: [
            AgentSessionBrowserAuthenticationFieldValue(
              fieldId: 'current-field',
              value: 'PRIVATE-one-use',
            ),
          ],
        );
        expect(response.toString(), isNot(contains('PRIVATE')));
        await expectLater(
          client.agents.sessions.events.create(
            'session',
            CreateAgentSessionEventsRequest(
              events: [
                AgentSessionApprovalResultInput(
                  requestId: 'old-current',
                  response: response,
                ),
              ],
            ),
          ),
          throwsA(
            isA<OpenAIException>().having(
              (error) => error.toString(),
              'private diagnostics',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
        expect(attempts, 1);
        expect(
          gets,
          0,
        ); // Refresh is explicit, not automatic credential replay.
        final current = await client.agents.sessions.retrieve('session');
        expect(
          (current.requiredActions.single
                  as AgentSessionComputerUseApprovalRequiredAction)
              .requestId,
          'new-current',
        );
        expect(attempts, 1);
        expect(records, isNotEmpty);
        expect(records.join('\n'), isNot(contains('PRIVATE')));
        expect(records.join('\n'), contains('[REDACTED Agents request]'));
        client.close();
        transport.close();
      },
    );
  }

  test(
    'authentication cancel omits fields and selected option, acceptance is not completion',
    () async {
      final transport = MockClient((request) async {
        final body = jsonDecode(request.body) as Map;
        expect(((body['events'] as List).single as Map)['response'], {
          'type': 'browser_authentication',
          'action': 'cancel',
        });
        return http.Response('', 202);
      });
      final client = OpenAIClient(httpClient: transport);
      await client.agents.sessions.events.create(
        'session',
        CreateAgentSessionEventsRequest(
          events: [
            AgentSessionApprovalResultInput(
              requestId: 'current',
              response: AgentSessionBrowserAuthenticationResponse.cancel(),
            ),
          ],
        ),
      );
      client.close();
      transport.close();
    },
  );
}

Future<void> _until(bool Function() test) async {
  for (var n = 0; n < 1000; n++) {
    if (test()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  throw StateError('Local fixture did not settle');
}
