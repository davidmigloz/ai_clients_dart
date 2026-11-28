import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _model = 'gemini-3.8-flash';
const _request = GenerateContentRequest(
  contents: [
    Content(role: 'user', parts: [TextPart('Set the light to 50 percent.')]),
  ],
  tools: [
    Tool(
      functionDeclarations: [
        FunctionDeclaration(
          name: 'controlLight',
          description: 'Adjusts the light.',
        ),
      ],
    ),
  ],
  toolConfig: ToolConfig(
    functionCallingConfig: FunctionCallingConfig(
      streamFunctionCallArguments: true,
    ),
  ),
);

Map<String, Object?> _chunk(Map<String, Object?> call) => {
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'functionCall': call},
        ],
      },
    },
  ],
};

GoogleAIConfig _vertex(ApiVersion version) => GoogleAIConfig.vertexAI(
  projectId: 'project',
  location: 'us-central1',
  authProvider: const BearerTokenProvider('fixture'),
).copyWith(apiVersion: version);

void main() {
  for (final version in [ApiVersion.v1, ApiVersion.v1beta1]) {
    test(
      'streams partial function arguments on Vertex ${version.value}',
      () async {
        const initial = {
          'name': 'controlLight',
          'id': 'call_1',
          'partialArgs': [
            {'jsonPath': r'$.brightness', 'numberValue': 50},
          ],
          'willContinue': true,
        };
        const namedString = {
          'partialArgs': [
            {
              'jsonPath': r'$.colorTemperature',
              'stringValue': 'warm',
              'willContinue': true,
            },
          ],
          'willContinue': true,
        };
        const remaining = {
          'partialArgs': [
            {
              'jsonPath': r'$.colorTemperature',
              'stringValue': ' white',
              'willContinue': false,
            },
            {'jsonPath': r'$.reset', 'boolValue': false},
            {'jsonPath': r'$.label', 'nullValue': 'NULL_VALUE'},
            {'jsonPath': r'$.fallback', 'nullValue': null},
          ],
          'willContinue': true,
        };
        const finalMarker = <String, Object?>{};
        final client = GoogleAIClient(
          config: _vertex(version),
          httpClient: MockClient((request) async {
            expect(
              request.url.path,
              '/${version.value}/projects/project/locations/us-central1/'
              'publishers/google/models/$_model:streamGenerateContent',
            );
            expect(request.url.queryParameters, {'alt': 'sse'});
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body, _request.toJson());
            expect(body['toolConfig'], {
              'functionCallingConfig': {'streamFunctionCallArguments': true},
            });
            final data = [
              initial,
              namedString,
              remaining,
              finalMarker,
            ].map((call) => 'data: ${jsonEncode(_chunk(call))}\n\n').join();
            return http.Response(
              data,
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          }),
        );
        addTearDown(client.close);

        final frames = await client.models
            .streamGenerateContent(model: _model, request: _request)
            .toList();
        final calls = frames
            .map((frame) => frame.functionCalls.single)
            .toList();
        expect(calls.map((call) => call.toJson()), [
          initial,
          namedString,
          remaining,
          finalMarker,
        ]);
        expect(calls.map((call) => call.name), ['controlLight', '', '', '']);
        expect(calls.map((call) => call.willContinue), [
          true,
          true,
          true,
          null,
        ]);
        expect(calls.first.partialArgs!.single.numberValue, 50);
        expect(calls[1].partialArgs!.single.willContinue, isTrue);
        final rest = calls[2].partialArgs!;
        expect(rest[0].stringValue, ' white');
        expect(rest[0].willContinue, isFalse);
        expect(rest[1].boolValue, isFalse);
        expect(rest[2].hasNullValue, isTrue);
        expect(rest[3].hasNullValue, isTrue);
        expect(rest[3].nullValue, isNull);
      },
    );
  }

  test(
    'rejects the Vertex option on Developer streams before transport',
    () async {
      final client = GoogleAIClient(
        config: const GoogleAIConfig(),
        httpClient: MockClient(
          (_) async => throw StateError('Unexpected transport'),
        ),
      );
      addTearDown(client.close);
      await expectLater(
        client.models.streamGenerateContent(model: _model, request: _request),
        emitsError(isA<UnsupportedError>()),
      );
    },
  );

  test(
    'rejects enabled streaming arguments on Vertex unary before transport',
    () async {
      final client = GoogleAIClient(
        config: _vertex(ApiVersion.v1),
        httpClient: MockClient(
          (_) async => throw StateError('Unexpected transport'),
        ),
      );
      addTearDown(client.close);
      await expectLater(
        client.models.generateContent(model: _model, request: _request),
        throwsUnsupportedError,
      );
    },
  );

  test('retains the configured flag through request decode and copy', () {
    final parsed = GenerateContentRequest.fromJson(_request.toJson());
    final config = parsed.toolConfig!.functionCallingConfig!;
    expect(config.streamFunctionCallArguments, isTrue);
    expect(config.copyWith().toJson(), {'streamFunctionCallArguments': true});
    expect(config.copyWith(streamFunctionCallArguments: false).toJson(), {
      'streamFunctionCallArguments': false,
    });
    expect(
      config.copyWith(streamFunctionCallArguments: null).toJson(),
      isEmpty,
    );
  });
}
