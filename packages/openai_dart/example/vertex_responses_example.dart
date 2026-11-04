// ignore_for_file: avoid_print

/// Injected Vertex credentials and Responses routing, entirely offline.
///
/// Replace MockClient with a production transport and the callback with your
/// application's Google credential refresh logic to contact Vertex. The package
/// does not load ADC or a native Google library. Tokens resolve on every attempt.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var tokens = 0;
  var requests = 0;
  final provider = VertexProvider(
    project: 'synthetic-project',
    location: 'global',
    tokenProvider: () => Future<String>.value('synthetic-token-${++tokens}'),
  );
  final transport = MockClient((request) async {
    requests++;
    if (request.url.origin != provider.root.origin ||
        !request.url.path.startsWith('${provider.root.path}/responses') ||
        request.headers['authorization'] !=
            'Bearer synthetic-token-$requests' ||
        request.followRedirects) {
      throw StateError(
        'The provider did not keep routing/authentication local.',
      );
    }
    final Map<String, Object?> payload;
    if (request.method == 'DELETE') {
      payload = {'id': 'resp_fixture', 'object': 'response', 'deleted': true};
    } else if (request.url.path.endsWith('/input_items')) {
      payload = {'object': 'list', 'data': <Object?>[], 'has_more': false};
    } else if (request.url.path.endsWith('/compact')) {
      payload = {
        'id': 'compact_fixture',
        'object': 'response.compaction',
        'created_at': 1,
        'output': <Object?>[],
        'usage': {'input_tokens': 1, 'output_tokens': 1, 'total_tokens': 2},
      };
    } else {
      payload = {
        'id': 'resp_fixture',
        'object': 'response',
        'created_at': 1,
        'status': request.url.path.endsWith('/cancel')
            ? 'cancelled'
            : 'in_progress',
        'output': <Object?>[],
      };
    }
    return http.Response(
      jsonEncode(payload),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: OpenAIConfig.vertex(
      provider: provider,
      retryPolicy: const RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  try {
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'fixture-model',
        input: ResponseInput.text('Reply with OK.'),
        background: true,
      ),
    );
    await client.responses.retrieve(response.id);
    await client.responses.inputItems.list(response.id);
    await client.responses.cancel(response.id);
    await client.responses.delete(response.id);
    await client.responses.compact(
      const CompactResponseRequest(
        model: 'fixture-model',
        input: ResponseInput.text('Synthetic history'),
      ),
    );
    print(
      '$requests synthetic lifecycle requests, $tokens request-local tokens, '
      'zero external API calls.',
    );
  } finally {
    client.close();
    transport.close(); // The injected shared transport remains caller-owned.
  }
}
