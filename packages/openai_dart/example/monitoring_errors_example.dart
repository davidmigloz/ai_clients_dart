// ignore_for_file: avoid_print
/// Inspect synthetic monitoring failures before explicit scoped investigation.
/// Run: dart run example/monitoring_errors_example.dart
/// MockClient only: no API key, live request, tool execution, or API charges.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

const _alertId = 'alert_00000000000000000000000000000000';
const _caseId = 'case_local_monitoring';
const _signingKey = 'synthetic-monitoring-example-signing-key';

Map<String, dynamic> _details() => {
  'detailed_explanation': 'Synthetic private explanation.',
  'error_type': 'potentially_unintended_data_transfer',
  'review_target': 'opaque_review_target:fixture',
  'steer': {'message': 'Synthetic opaque instruction; do not execute.'},
};

CreateResponseRequest _request(String scenario) => CreateResponseRequest(
  model: 'synthetic-model',
  input: ResponseInput.text(scenario),
);

Future<void> main() async {
  final responseAttempts = <String, int>{};
  var alertRequests = 0;
  var caseRequests = 0;
  final projectTransport = MockClient((request) async {
    if (request.url.host != 'example.invalid' ||
        request.headers['Authorization'] != 'Bearer synthetic-project-key') {
      throw StateError('Unexpected project scope.');
    }
    if (request.method == 'GET' &&
        request.url.path == '/v1/safety/alerts/$_alertId' &&
        request.body.isEmpty &&
        !request.url.hasQuery) {
      alertRequests++;
      return http.Response(
        jsonEncode({
          'id': _alertId,
          'object': 'safety.alert',
          'created_at': 1,
          'request_id': 'synthetic-request-id',
          'response_id': 'synthetic-response-id',
          'model': 'synthetic-model',
          'request_paused': true,
          'error_type': 'potentially_unintended_data_transfer',
          'reason': null,
        }),
        200,
      );
    }
    if (request.method != 'POST' || request.url.path != '/v1/responses') {
      throw StateError('Unexpected project operation.');
    }
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final scenario = body['input'] as String;
    responseAttempts.update(scenario, (count) => count + 1, ifAbsent: () => 1);
    if (body['stream'] != true || responseAttempts[scenario] != 1) {
      throw StateError('Unexpected replay or nonstreaming demonstration.');
    }
    if (scenario == 'http-block') {
      return http.Response(
        jsonEncode({
          'error': {
            'type': 'invalid_request_error',
            'message': 'Synthetic private failure message.',
            'code': 'misalignment_policy_violation',
            'param': null,
            'misalignment': _details(),
          },
        }),
        403,
        headers: {'x-request-id': 'synthetic-request-id'},
      );
    }
    final Map<String, dynamic> failure;
    if (scenario == 'flat-stream') {
      failure = {
        'type': 'error',
        'code': null,
        'param': null,
        'message': 'Synthetic private stream error.',
        'sequence_number': 2,
      };
    } else if (scenario == 'failed-stream') {
      failure = {
        'type': 'response.failed',
        'sequence_number': 2,
        'response': {
          'id': 'synthetic-response-id',
          'object': 'response',
          'created_at': 1,
          'status': 'failed',
          'model': 'synthetic-model',
          'output': <dynamic>[],
          'error': {
            'code': 'misalignment_policy_violation',
            'message': 'Synthetic private failure message.',
            'misalignment': _details(),
          },
          'incomplete_details': null,
          'instructions': null,
          'tools': <dynamic>[],
          'parallel_tool_calls': false,
          'metadata': <String, dynamic>{},
          'tool_choice': 'auto',
          'temperature': 1.0,
          'top_p': 1.0,
        },
      };
    } else {
      throw StateError('Unexpected synthetic scenario.');
    }
    return http.Response(
      'data: ${jsonEncode({'type': 'response.output_text.delta', 'item_id': 'synthetic-output-id', 'output_index': 0, 'content_index': 0, 'delta': 'Synthetic partial output.', 'sequence_number': 1, 'logprobs': <dynamic>[]})}\n\n'
      'data: ${jsonEncode(failure)}\n\n'
      'data: [DONE]\n\n',
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  });
  final organizationTransport = MockClient((request) async {
    caseRequests++;
    if (request.method != 'GET' ||
        request.url.host != 'example.invalid' ||
        request.url.path != '/v1/safety/cases/$_caseId' ||
        request.headers['Authorization'] !=
            'Bearer synthetic-organization-key' ||
        request.body.isNotEmpty ||
        request.url.hasQuery) {
      throw StateError('Unexpected organization case lookup.');
    }
    return http.Response(
      jsonEncode({
        'id': _caseId,
        'object': 'safety.case',
        'created_at': 2,
        'entity_identifier': 'synthetic-private-application-identifier',
        'reason': 'Synthetic private investigation details.',
        'notice': {'type': 'warning'},
      }),
      200,
    );
  });

  // Production: load scoped keys on trusted infrastructure. The project key
  // needs Responses access plus api.safety.alerts.read. The organization key
  // needs api.safety.read on the organization named by its trusted notice.
  final projectClient = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      authProvider: ApiKeyProvider('synthetic-project-key'),
      retryPolicy: RetryPolicy(maxRetries: 2),
    ),
    httpClient: projectTransport,
  );
  final organizationClient = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      authProvider: ApiKeyProvider('synthetic-organization-key'),
    ),
    httpClient: organizationTransport,
  );
  try {
    var blocked = false;
    try {
      await projectClient.responses
          .createStream(_request('http-block'))
          .toList();
    } on PermissionDeniedException catch (error) {
      blocked = true;
      if (error.statusCode != 403 ||
          error.code != 'misalignment_policy_violation' ||
          error.requestId != 'synthetic-request-id' ||
          error.body == null ||
          error.misalignment == null) {
        throw StateError('Original HTTP failure context was lost.');
      }
      _reportDetails('HTTP 403 before output', error.misalignment!);
    }
    if (!blocked) throw StateError('Expected a synthetic HTTP 403.');

    var outputChunks = 0;
    var flatErrors = 0;
    var failedResponses = 0;
    // These are two independent demo requests, not replay or continuation.
    for (final scenario in ['flat-stream', 'failed-stream']) {
      await for (final event in projectClient.responses.createStream(
        _request(scenario),
      )) {
        switch (event) {
          case OutputTextDeltaEvent():
            outputChunks++;
          case ErrorEvent():
            flatErrors++;
            if (event.code != null ||
                !event.hasCode ||
                event.param != null ||
                !event.hasParam ||
                event.sequenceNumber != 2 ||
                event.toJson().containsKey('error')) {
              throw StateError(
                'Canonical flat nullable error fields were lost.',
              );
            }
            print('Flat SSE error after output: code and param remain null.');
          case ResponseFailedEvent(:final response):
            failedResponses++;
            final error = response.error;
            if (error?.code != 'misalignment_policy_violation' ||
                error?.misalignment == null) {
              throw StateError('Failed response monitoring details were lost.');
            }
            _reportDetails(
              'Failed response after output',
              error!.misalignment!,
            );
          default:
            break;
        }
      }
    }
    if (outputChunks != 2 ||
        flatErrors != 1 ||
        failedResponses != 1 ||
        alertRequests != 0 ||
        caseRequests != 0) {
      throw StateError('Unexpected implicit lookup or missing failure.');
    }

    // Investigation is explicit, using IDs from verified notifications.
    // review_target and steer are opaque passive values, never lookup IDs or
    // executable instructions. The API offers no generic resume/unblock method
    // or monitoring configuration parameter.
    const verifier = WebhookVerifier(secret: _signingKey);
    for (final (type, id) in [
      ('safety.alert.created', _alertId),
      ('safety.warning_issued', _caseId),
    ]) {
      final bytes = utf8.encode(
        jsonEncode({
          'id': 'evt_synthetic_$type',
          'object': 'event',
          'created_at': 1,
          'type': type,
          'data': {'id': id},
        }),
      );
      final event = verifier.unwrapBytes(bytes, _signedHeaders(bytes, type));
      switch (event) {
        case SafetyAlertCreatedWebhookEvent():
          final alert = await projectClient.safety.alerts.retrieve(
            event.data.id,
          );
          // Block registration does not prove execution stopped or prior effects
          // were reversed. Do not print private reasons or identifiers.
          print(
            'Explicit project alert lookup: block registered=${alert.requestPaused}.',
          );
        case SafetyWarningIssuedWebhookEvent():
          final safetyCase = await organizationClient.safety.cases.retrieve(
            event.data.id,
          );
          print(
            'Explicit organization case lookup: notice=${safetyCase.notice.type.name}.',
          );
        default:
          throw StateError('Unexpected synthetic verified notice.');
      }
    }
    if (responseAttempts.length != 3 ||
        responseAttempts.values.any((count) => count != 1) ||
        alertRequests != 1 ||
        caseRequests != 1) {
      throw StateError('Expected three mock POSTs and two scoped mock GETs.');
    }
    print(
      'PASS: five mocked requests; no retry, replay, tool execution, or API charges.',
    );
  } finally {
    projectClient.close();
    organizationClient.close();
    // Injected transports are caller-owned.
    projectTransport.close();
    organizationTransport.close();
  }
}

void _reportDetails(String context, ResponsesMisalignmentDetails details) {
  // Print only an allowlisted classification and presence, not sensitive text,
  // opaque tokens, instructions, future provider strings, or raw error bodies.
  final classification = switch (details.errorType) {
    'potentially_unintended_data_transfer' =>
      'potentially_unintended_data_transfer',
    'potentially_unintended_data_access' =>
      'potentially_unintended_data_access',
    'potentially_unintended_destructive_activity' =>
      'potentially_unintended_destructive_activity',
    'other' => 'other',
    _ => 'unrecognized',
  };
  print(
    '$context: classification=$classification; '
    'explanation=${details.detailedExplanation != null}, '
    'review target=${details.reviewTarget != null}, steer=${details.steer != null}.',
  );
}

Map<String, String> _signedHeaders(List<int> bytes, String deliveryId) {
  final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  final signature = Hmac(
    sha256,
    utf8.encode(_signingKey),
  ).convert([...utf8.encode('$deliveryId.$timestamp.'), ...bytes]);
  return {
    'webhook-id': deliveryId,
    'webhook-timestamp': timestamp,
    'webhook-signature': 'v1,${base64.encode(signature.bytes)}',
  };
}
