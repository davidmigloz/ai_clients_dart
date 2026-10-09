// ignore_for_file: avoid_print
/// Offline project Safety alert explanations through four explicit mock GETs.
///
/// Run: dart run example/safety_explanations_example.dart
/// No API key, live API call or service-side alert generation is required.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const explanation = 'Synthetic explanation for this offline fixture.';
  final payloads = <String, Map<String, dynamic>>{
    'alert-absent': {},
    'alert-null': {'detailed_explanation': null},
    'alert-text': {'detailed_explanation': explanation},
    'alert-empty': {'detailed_explanation': ''},
  };
  var requests = 0;
  final transport = MockClient((request) async {
    requests++;
    final id = request.url.pathSegments.last;
    if (request.method != 'GET' ||
        request.url.toString() !=
            'https://example.invalid/v1/safety/alerts/$id' ||
        !payloads.containsKey(id) ||
        request.body.isNotEmpty) {
      throw StateError(
        'Only explicit mock project alert retrieval is expected.',
      );
    }
    return http.Response(
      jsonEncode({
        'id': id,
        'object': 'safety.alert',
        'created_at': 1787659200,
        'request_id': 'synthetic-request',
        'response_id': 'synthetic-response',
        'model': 'gpt-6-astra',
        'request_paused': false,
        'error_type': 'potentially_unintended_data_access',
        'reason': null,
        ...payloads[id]!,
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      authProvider: ApiKeyProvider('synthetic-safety-example-key'),
    ),
    httpClient: transport,
  );
  try {
    // These are response fixtures, not a prediction of service eligibility.
    // A null reason does not establish that an explanation is available.
    for (final entry in payloads.entries) {
      final alert = await client.safety.alerts.retrieve(entry.key);
      if (alert.hasDetailedExplanation !=
              entry.value.containsKey('detailed_explanation') ||
          alert.detailedExplanation != entry.value['detailed_explanation']) {
        throw StateError('Explanation value or presence changed on retrieval.');
      }
      if (alert.toJson().containsKey('detailed_explanation') !=
          alert.hasDetailedExplanation) {
        throw StateError('Explanation presence changed on serialization.');
      }
      if (entry.key == 'alert-text') {
        final explicitNull = alert.copyWith(detailedExplanation: null);
        final omitted = alert.copyWith(hasDetailedExplanation: false);
        if (!explicitNull.hasDetailedExplanation ||
            explicitNull.detailedExplanation != null ||
            !explicitNull.toJson().containsKey('detailed_explanation') ||
            omitted.hasDetailedExplanation ||
            omitted.toJson().containsKey('detailed_explanation') ||
            alert.toString().contains(explanation)) {
          throw StateError('Copy/clear or default privacy contract changed.');
        }
      }
    }
    if (requests != payloads.length) {
      throw StateError('Unexpected request count.');
    }
    print(
      'Absent, null, text and empty explanations preserved; four mock GETs.',
    );
    print(
      r'Explicit copy/clear and private diagnostics verified; API cost $0.',
    );
  } finally {
    client.close();
    transport.close();
  }
}
