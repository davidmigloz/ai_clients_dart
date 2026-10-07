// ignore_for_file: avoid_print

/// Select access programs and inspect synthetic effective server selections.
///
/// This local example requires no API key or Daybreak provisioning. Explicit
/// selection does not grant access; live eligibility depends on the model and
/// organization/project approval. No client model allowlist is introduced.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const baseRequest = CreateResponseRequest(
    model: 'gpt-6-sol',
    input: ResponseInput.text(
      'Explain how to validate a patch in a test setup.',
    ),
  );
  final scenarios = [
    (
      label: 'Omitted selection, synthetic implicit Standard',
      request: baseRequest,
      effective: null,
    ),
    (
      label: 'Empty selection, synthetic server-selected Blue',
      request: baseRequest.copyWith(
        accessPrograms: const AccessProgramsParam(),
      ),
      effective: const AccessProgramsBody(
        cyber: CyberAccessProgram.daybreakBlue,
      ),
    ),
    (
      label: 'Explicit Standard',
      request: baseRequest.copyWith(
        accessPrograms: const AccessProgramsParam(
          cyber: CyberAccessProgram.standard,
        ),
      ),
      effective: const AccessProgramsBody(cyber: CyberAccessProgram.standard),
    ),
    (
      label: 'Explicit Blue',
      request: baseRequest.copyWith(
        accessPrograms: const AccessProgramsParam(
          cyber: CyberAccessProgram.daybreakBlue,
        ),
      ),
      effective: const AccessProgramsBody(
        cyber: CyberAccessProgram.daybreakBlue,
      ),
    ),
    (
      label: 'Explicit Red on a synthetic cyber model',
      request: baseRequest.copyWith(
        model: 'gpt-5.6-cyber',
        accessPrograms: const AccessProgramsParam(
          cyber: CyberAccessProgram.daybreakRed,
        ),
      ),
      effective: const AccessProgramsBody(
        cyber: CyberAccessProgram.daybreakRed,
      ),
    ),
  ];
  var sends = 0;
  final transport = MockClient((sent) async {
    final scenario = scenarios[sends++];
    if (sent.method != 'POST' ||
        sent.url.path != '/v1/responses' ||
        jsonEncode(jsonDecode(sent.body)) !=
            jsonEncode(scenario.request.toJson())) {
      throw StateError('Unexpected local demonstration request.');
    }
    return http.Response(
      jsonEncode({
        'id': 'resp_local_$sends',
        'object': 'response',
        'created_at': 1,
        'status': 'completed',
        'model': scenario.request.model,
        'output': <dynamic>[],
        'access_programs': scenario.effective?.toJson(),
        'error': null,
        'incomplete_details': null,
        'instructions': null,
        'tools': <dynamic>[],
        'parallel_tool_calls': false,
        'metadata': <String, dynamic>{},
        'tool_choice': 'auto',
        'temperature': 1.0,
        'top_p': 1.0,
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  try {
    for (final scenario in scenarios) {
      final response = await client.responses.create(scenario.request);
      if (response.accessPrograms != scenario.effective) {
        throw StateError('Effective access program was not preserved.');
      }
      final effective = response.accessPrograms?.cyber.toJson() ?? 'null';
      print('${scenario.label}: access_programs.cyber = $effective');
    }
    if (sends != scenarios.length || baseRequest.accessPrograms != null) {
      throw StateError('Unexpected request count or modified base request.');
    }
    print('Five local requests; no API charges or Daybreak provisioning.');
  } finally {
    client.close();
    transport.close();
  }
}
