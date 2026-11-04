/// Explicit browser decisions through dedicated typed inputs, fully offline.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

import 'agent_session_recovery_example.dart' show recoverySessionFixture;

Future<void> main() async {
  final bytes = StreamController<List<int>>();
  final ready = Completer<void>();
  final resumed = Completer<void>();
  final abort = Completer<void>();
  var observationFailed = false;
  var submitted = 0;
  var closing = false;
  final decisions = [
    AgentSessionBrowserOriginAccessDecision.approve,
    AgentSessionBrowserOriginAccessDecision.deny,
    AgentSessionBrowserOriginAccessDecision.cancel,
  ];
  Map<String, dynamic> currentSession() => recoverySessionFixture(
    requestId: 'request-$submitted',
    status: submitted == 5 ? 'in_progress' : 'requires_action',
    request: submitted < 3
        ? {
            'type': 'browser_origin_access',
            'origin': 'https://site.invalid',
            'reason': 'Read this site',
          }
        : {
            'type': 'browser_authentication',
            'credential_origin': 'https://site.invalid',
            'fields': [
              {
                'id': 'field-$submitted',
                'label': 'One-time code',
                'required': true,
                'type': 'password',
              },
            ],
            'options': <Object?>[],
            'reason': null,
          },
  );
  final transport = MockClient.streaming((request, body) async {
    if (request.method == 'GET' && request.url.path.endsWith('/events')) {
      return http.StreamedResponse(
        bytes.stream,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (request.method == 'GET') return _json(currentSession());
    if (request.method != 'POST' || !request.url.path.endsWith('/events')) {
      throw StateError('Only explicit approval inputs are expected');
    }
    final input =
        ((jsonDecode(utf8.decode(await body.expand((b) => b).toList()))
                        as Map)['events']
                    as List)
                .single
            as Map;
    if (input['request_id'] != 'request-$submitted' ||
        input.containsKey('turn_id')) {
      throw StateError(
        'The input must target the current request without a turn ID',
      );
    }
    if (input['type'] !=
        'agent.session.input.computer_use_approval_request_result') {
      throw StateError('Never put credentials in messages or tool results');
    }
    submitted++;
    bytes.add(
      utf8.encode(
        'data: ${jsonEncode({'type': submitted == 5 ? 'agent.session.in_progress' : 'agent.session.requires_action', 'event_id': 'state-$submitted', 'session': currentSession()})}\n\n',
      ),
    );
    return http.StreamedResponse(const Stream.empty(), 202);
  });
  final client = OpenAIClient(httpClient: transport);
  final sessions = client.agents.sessions;
  void failObservation() {
    observationFailed = true;
    if (!ready.isCompleted) ready.complete();
    if (!resumed.isCompleted) resumed.complete();
    if (!abort.isCompleted) abort.complete();
  }

  void checkObservation() {
    if (observationFailed) {
      throw StateError(
        'Observation lost; refresh current session before deciding.',
      );
    }
  }

  final subscription = sessions.events
      .stream('session', onReady: ready.complete, abortTrigger: abort.future)
      .listen(
        (event) {
          if (event is AgentSessionFailedEvent) failObservation();
          if (event is AgentSessionInProgressEvent && !resumed.isCompleted) {
            resumed.complete();
          }
        },
        onError: (Object _) => failObservation(),
        onDone: () {
          if (!closing) failObservation();
        },
      );
  try {
    // In a real application, render the origin/credential destination and collect
    // each person's explicit decision. These five selections are synthetic only.
    await ready.future;
    checkObservation();
    for (var choice = 0; choice < 5; choice++) {
      // A historical request ID is never sufficient authority to submit a form.
      final current = await sessions.retrieve(
        'session',
        abortTrigger: abort.future,
      );
      final action =
          current.requiredActions.single
              as AgentSessionComputerUseApprovalRequiredAction;
      checkObservation();
      final AgentSessionComputerUseApprovalResponse response;
      if (action.request is AgentSessionBrowserOriginAccessRequest) {
        response = AgentSessionBrowserOriginAccessResponse(
          decision: decisions[choice],
        );
      } else if (choice == 3) {
        response = AgentSessionBrowserAuthenticationResponse.cancel();
      } else {
        final form = action.request as AgentSessionBrowserAuthenticationRequest;
        // Use only this form's current field IDs. If options are offered, choose
        // one explicitly and submit only its fieldIds, plus selectedOption.
        response = AgentSessionBrowserAuthenticationResponse.submit(
          fields: [
            AgentSessionBrowserAuthenticationFieldValue(
              fieldId: form.fields.single.id,
              value: 'synthetic-one-use-value',
            ),
          ],
        );
      }
      try {
        checkObservation();
        await sessions.events.create(
          'session',
          CreateAgentSessionEventsRequest(
            events: [
              AgentSessionApprovalResultInput(
                requestId: action.requestId,
                response: response,
              ),
            ],
          ),
          abortTrigger: abort.future,
        );
      } on ApiException {
        // Authentication submission is transport-once even with a retry policy.
        // After uncertain delivery, refresh and ask the person again. Do not
        // resubmit this response, print it, or save its values in UI history.
        await sessions.retrieve('session', abortTrigger: abort.future);
        throw StateError(
          'Delivery uncertain; inspect current actions and request a fresh explicit decision.',
        );
      }
      // 202 means accepted only, never successful sign-in or turn completion.
    }
    await resumed.future;
    checkObservation();
    stdout
      ..writeln(
        'Submitted three distinct origin decisions and authentication cancel/submit.',
      )
      ..writeln(
        'Observed resumed work after acceptance; zero external API calls.',
      );
    // Origin approval neither changes network policy nor confirms each action.
    // Closing observation does not cancel the turn, delete the durable session,
    // remove published artifacts, or shut down self-hosted compute.
  } finally {
    closing = true;
    if (!abort.isCompleted) abort.complete();
    await subscription.cancel();
    await bytes.close();
    client.close();
    transport.close();
  }
}

http.StreamedResponse _json(Object value) => http.StreamedResponse(
  Stream.value(utf8.encode(jsonEncode(value))),
  200,
  headers: {'content-type': 'application/json'},
);
