import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _questions = {
  'route': DecisionQuestion.choice(
    instructions: DecisionInstructions.text('Pick the delivery route.'),
    criteria: {'courier': '', 'post': 'Delivers by post.'},
  ),
};

Future<CreateDecisionResponse> _create(
  GoogleAIClient client, {
  Future<void>? abortTrigger,
}) => client.decisions.create(
  model: 'gemini-decision-1',
  input: const DecisionInput.contentList([
    TextContent(text: 'Examine the attached report.'),
    DocumentContent(
      mimeType: 'application/pdf',
      uri: 'https://example.com/report.pdf',
    ),
  ]),
  questions: _questions,
  abortTrigger: abortTrigger,
);

GoogleAIClient _client(http.Client transport, {GoogleAIConfig? config}) {
  addTearDown(transport.close);
  final client = GoogleAIClient(
    config:
        config ??
        const GoogleAIConfig.googleAI(
          authProvider: ApiKeyProvider(
            'test-api-key',
            placement: AuthPlacement.header,
          ),
          apiVersion: ApiVersion.v1beta,
        ),
    httpClient: transport,
  );
  addTearDown(client.close);
  return client;
}

void main() {
  test('public client sends the documented route, key, and JSON', () async {
    final client = _client(
      MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://generativelanguage.googleapis.com/v1beta/decisions',
        );
        expect(request.headers['x-goog-api-key'], 'test-api-key');
        expect(request.headers['content-type'], contains('application/json'));
        expect(jsonDecode(request.body), {
          'model': 'gemini-decision-1',
          'input': [
            {'type': 'text', 'text': 'Examine the attached report.'},
            {
              'type': 'document',
              'mime_type': 'application/pdf',
              'uri': 'https://example.com/report.pdf',
            },
          ],
          'questions': {
            'route': {
              'type': 'choice',
              'instructions': 'Pick the delivery route.',
              'criteria': {'courier': '', 'post': 'Delivers by post.'},
            },
          },
        });

        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'answers': {
                'route': {
                  'type': 'choice',
                  'choice': 'courier',
                  'probabilities': {'courier': 0.8, 'post': 0.2},
                  'confidence': 0.8,
                },
              },
              'usage': {'total_input_tokens': 12, 'total_output_tokens': 0},
              'prompt_feedback': {
                'block_reason_message': 'Message in español.',
              },
            }),
          ),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      }),
    );

    final response = await _create(client);
    expect(
      response.answers?['route'],
      isA<ChoiceAnswer>().having(
        (answer) => answer.choice,
        'choice',
        'courier',
      ),
    );
    expect(response.usage?.totalInputTokens, 12);
    expect(response.promptFeedback?.blockReasonMessage, 'Message in español.');
  });

  test('reports a blocked HTTP request as an API error', () async {
    final client = _client(
      MockClient(
        (_) async => http.Response(
          '{"error":{"code":"safety","message":"Prompt blocked"}}',
          400,
        ),
      ),
    );

    await expectLater(
      _create(client),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 400)
            .having((error) => error.message, 'message', 'Prompt blocked'),
      ),
    );
  });

  test('rejects stable Developer API and Vertex before sending', () async {
    final stable = _client(
      MockClient((_) => throw StateError('Unexpected HTTP request')),
      config: const GoogleAIConfig.googleAI(
        authProvider: ApiKeyProvider('test-api-key'),
        apiVersion: ApiVersion.v1,
      ),
    );
    final vertex = _client(
      MockClient((_) => throw StateError('Unexpected HTTP request')),
      config: GoogleAIConfig.vertexAI(
        projectId: 'project',
        location: 'eu',
        apiVersion: ApiVersion.v1beta,
        authProvider: const ApiKeyProvider('test-api-key'),
      ),
    );

    await expectLater(_create(stable), throwsUnsupportedError);
    await expectLater(_create(vertex), throwsUnsupportedError);
  });

  test('rejects empty question batches before sending', () async {
    final client = _client(
      MockClient((_) => throw StateError('Unexpected HTTP request')),
    );

    await expectLater(
      client.decisions.create(
        model: 'gemini-decision-1',
        input: const DecisionInput.text('Input'),
        questions: const {},
      ),
      throwsArgumentError,
    );
  });

  test('rejects requests after closing the client', () async {
    final client = _client(
      MockClient((_) => throw StateError('Unexpected HTTP request')),
    )..close();

    await expectLater(_create(client), throwsA(isA<StateError>()));
  });

  test('forwards cancellation to the active HTTP request', () async {
    final transport = _AbortableClient();
    final client = _client(transport);
    final abort = Completer<void>();
    final result = _create(client, abortTrigger: abort.future);
    final assertion = expectLater(result, throwsA(isA<AbortedException>()));

    await transport.requestStarted.future;
    abort.complete();
    await assertion;
  });
}

class _AbortableClient extends http.BaseClient {
  final requestStarted = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestStarted.complete();
    expect(request, isA<http.Abortable>());
    await (request as http.Abortable).abortTrigger;
    throw http.RequestAbortedException(request.url);
  }
}
