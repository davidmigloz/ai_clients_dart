// ignore_for_file: avoid_print
/// Offline signed safety notices followed by explicitly scoped detail lookups.
/// Run: dart run example/safety_example.dart
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const signingKey = 'synthetic-safety-example-signing-key';
  const verifier = WebhookVerifier(secret: signingKey);
  const alertId = 'alert_00000000000000000000000000000000';
  const caseId = 'case_local_example';
  var alertRequests = 0;
  var caseRequests = 0;
  final projectTransport = MockClient((request) async {
    alertRequests++;
    if (request.method != 'GET' ||
        request.url.path != '/v1/safety/alerts/$alertId' ||
        request.headers['Authorization'] != 'Bearer synthetic-project-key' ||
        request.body.isNotEmpty ||
        request.url.hasQuery) {
      throw StateError('Unexpected project alert lookup.');
    }
    return http.Response(
      jsonEncode({
        'id': alertId,
        'object': 'safety.alert',
        'created_at': 1,
        'request_id': 'request_local_example',
        'response_id': 'response_local_example',
        'model': 'synthetic-model',
        'request_paused': false,
        'error_type': 'potentially_unintended_data_transfer',
        'reason': null,
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final organizationTransport = MockClient((request) async {
    caseRequests++;
    if (request.method != 'GET' ||
        request.url.path != '/v1/safety/cases/$caseId' ||
        request.headers['Authorization'] !=
            'Bearer synthetic-organization-key' ||
        request.body.isNotEmpty ||
        request.url.hasQuery) {
      throw StateError('Unexpected organization case lookup.');
    }
    return http.Response(
      jsonEncode({
        'id': caseId,
        'object': 'safety.case',
        'created_at': 2,
        'entity_identifier': 'application-safety-identifier',
        'reason': 'Synthetic private investigation details.',
        'notice': {'type': 'warning'},
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });

  // Production: inject separately scoped keys from trusted secret storage.
  // Alerts: notified project + api.safety.alerts.read.
  // Cases: notified organization + api.safety.read.
  final projectClient = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('synthetic-project-key'),
    ),
    httpClient: projectTransport,
  );
  final organizationClient = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('synthetic-organization-key'),
    ),
    httpClient: organizationTransport,
  );
  final handled = <String>{}; // Persist delivery deduplication in production.
  Future<void> investigate(
    List<int> originalBytes,
    Map<String, String> headers,
  ) async {
    final event = verifier.unwrapBytes(originalBytes, headers);
    // Production receivers persist/queue verified work and acknowledge promptly.
    if (!handled.add(headers['webhook-id']!)) return;
    if (event case SafetyAlertCreatedWebhookEvent()) {
      // event.id identifies the notice; data.id identifies the alert to retrieve.
      final alert = await projectClient.safety.alerts.retrieve(event.data.id);
      if (alert.requestPaused || alert.reason != null) {
        throw StateError('Unexpected synthetic alert details.');
      }
      // requestPaused reports successful block registration. It does not prove
      // execution stopped or that prior effects were reversed.
      print(
        'Project alert retrieved; block registered: ${alert.requestPaused}.',
      );
    } else if (event
        case SafetyWarningIssuedWebhookEvent(:final data) ||
            SafetyDeactivationIssuedWebhookEvent(:final data)) {
      final safetyCase = await organizationClient.safety.cases.retrieve(
        data.id,
      );
      if (safetyCase.notice.type != SafetyCaseNoticeType.warning ||
          safetyCase.entityIdentifier == safetyCase.id ||
          safetyCase.reason == null) {
        throw StateError('Unexpected synthetic case details.');
      }
      // entityIdentifier is the application's safety identifier, not a case ID
      // or notification ID. Reason and identifiers stay out of printed output.
      print(
        'Organization case retrieved; notice: ${safetyCase.notice.type.name}.',
      );
    } else if (event is SafetyOrgAlertCreatedWebhookEvent) {
      // Workspace alerts use api.chatgpt.com/v1/safety/alerts/{id} and a workspace
      // administrator key with chatgpt.enterprise.safety_alerts.read. That lookup
      // remains Phase 7; never route this notice through the project client.
      print(
        'Workspace notice requires its separately scoped administrator lookup.',
      );
    }
  }

  Map<String, String> signedHeaders(List<int> bytes, String deliveryId) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final signature = Hmac(
      sha256,
      utf8.encode(signingKey),
    ).convert([...utf8.encode('$deliveryId.$timestamp.'), ...bytes]);
    return {
      'webhook-id': deliveryId,
      'webhook-timestamp': timestamp,
      'webhook-signature': 'v1,${base64.encode(signature.bytes)}',
    };
  }

  try {
    for (final (type, id) in [
      ('safety.alert.created', alertId),
      ('safety.warning_issued', caseId),
      ('safety.org_alert.created', alertId),
    ]) {
      final bytes = utf8.encode(
        jsonEncode({
          'id': 'evt_local_$type',
          'object': 'event',
          'created_at': 1,
          'type': type,
          'data': {'id': id},
        }),
      );
      final headers = signedHeaders(bytes, 'delivery_local_$type');
      await investigate(bytes, headers);
      await investigate(bytes, headers); // Duplicate makes no additional GET.
    }
    final original = utf8.encode('synthetic original body');
    var tamperingRejected = false;
    try {
      await investigate(
        utf8.encode('tampered body'),
        signedHeaders(original, 'bad'),
      );
    } on InvalidWebhookSignatureException {
      tamperingRejected = true;
    }
    if (!tamperingRejected || alertRequests != 1 || caseRequests != 1) {
      throw StateError('Expected rejection and exactly two scoped mock GETs.');
    }
    print(
      'PASS: two scoped mock GETs; duplicate, workspace and tampered notices made no extra lookup.',
    );
  } finally {
    projectClient.close();
    organizationClient.close();
    // Custom transports are caller-owned.
    projectTransport.close();
    organizationTransport.close();
  }
}
