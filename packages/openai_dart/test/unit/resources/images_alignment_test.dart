import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_identifier😀';
Map<String, dynamic> _imageResponse() => {
  'created': 1,
  'data': [
    {'b64_json': 'AA=='},
  ],
  'safety_identifier': _private,
};
Map<String, dynamic> _completed(String type) => {
  'type': type,
  'b64_json': 'AA==',
  'created_at': 1,
  'size': '1024x1024',
  'quality': 'high',
  'background': 'transparent',
  'output_format': 'png',
  'safety_identifier': _private,
  'usage': {
    'input_tokens': 1,
    'output_tokens': 1,
    'total_tokens': 2,
    'input_tokens_details': {'text_tokens': 1, 'image_tokens': 0},
  },
};

class _Transport extends http.BaseClient {
  _Transport(this.handle);
  final Future<http.StreamedResponse> Function(http.BaseRequest, List<int>)
  handle;
  final requests = <http.BaseRequest>[];
  final bodies = <List<int>>[];
  int closes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final bytes = await request.finalize().toBytes();
    bodies.add(bytes);
    return handle(request, bytes);
  }

  @override
  void close() => closes++;
}

class _Auth implements AuthProvider {
  int calls = 0;
  int? failAt;
  @override
  Map<String, String> getHeaders() {
    calls++;
    if (calls == failAt) {
      throw const ApiException(message: _private, statusCode: 400);
    }
    return {
      'Authorization': 'Bearer synthetic-image',
      'Accept': 'provider-invalid',
      'Content-Type': 'application/json; charset=iso-8859-1',
    };
  }
}

http.StreamedResponse _json(
  http.BaseRequest request,
  Object value, [
  int status = 200,
]) => http.StreamedResponse(
  Stream.value(utf8.encode(jsonEncode(value))),
  status,
  headers: {'content-type': 'application/json'},
  request: request,
);
http.StreamedResponse _sse(http.BaseRequest request, String type) =>
    http.StreamedResponse(
      Stream.value(
        utf8.encode(
          'data: ${jsonEncode(_completed(type))}\n\ndata: [DONE]\n\n',
        ),
      ),
      200,
      headers: {'content-type': 'text/event-stream'},
      request: request,
    );
ImageGenerationRequest _generation({String? safetyIdentifier = _private}) =>
    ImageGenerationRequest(
      prompt: 'PRIVATE prompt',
      model: 'gpt-image-2.5-flare',
      safetyIdentifier: safetyIdentifier,
    );
ImageEditJsonRequest _jsonEdit() => ImageEditJsonRequest(
  images: const [ImageReference.file('file_original')],
  markup: const ImageReference.file('file_overlay'),
  prompt: 'PRIVATE edit',
  model: 'gpt-image-2.5-sunburst',
  safetyIdentifier: _private,
);
ImageEditRequest _multipartEdit() => ImageEditRequest(
  image: Uint8List.fromList([1, 2, 3]),
  imageFilename: 'original.png',
  markup: Uint8List.fromList([0, 255, 128, 1]),
  markupFilename: 'overlay.png',
  prompt: 'PRIVATE edit',
  model: 'gpt-image-2.5-sunburst',
  safetyIdentifier: _private,
);

String _part(String body, http.BaseRequest request, String name) {
  final boundary = request.headers['content-type']!.split('boundary=').last;
  return body
      .split('--$boundary')
      .singleWhere((part) => part.contains('name="$name"'));
}

String _partValue(String part) {
  final value = part.substring(part.indexOf('\r\n\r\n') + 4);
  return value.endsWith('\r\n') ? value.substring(0, value.length - 2) : value;
}

void main() {
  for (final beta in [false, true]) {
    test(
      'Responses beta=$beta keeps image failure/moderation details through public create',
      () async {
        final transport = _Transport(
          (request, _) async => _json(request, {
            'id': 'response_fixture',
            'object': 'response',
            'created_at': 1,
            'status': 'completed',
            'output': [
              {
                'type': 'image_generation_call',
                'id': 'call_fixture',
                'status': 'failed',
                'result': null,
                if (beta) 'agent': {'agent_name': 'main'},
                'error': {
                  'code': 'moderation_blocked',
                  'type': 'image_generation_error',
                  'message': 'PRIVATE explanation',
                  'param': null,
                  'moderation_details': {
                    'moderation_stage': 'output',
                    'categories': ['new_public_category'],
                  },
                },
              },
            ],
          }),
        );
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        final response = await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-6.1-sol',
            input: ResponseInput.text('Create an image'),
          ),
          beta: beta,
        );
        final call = response.imageGenerationCalls.single;
        expect(call.status, ImageGenerationCallStatus.failed);
        expect(call.error?.code, 'moderation_blocked');
        expect(
          call.error?.moderationDetails?.moderationStage,
          ImageModerationStage.output,
        );
        expect(call.error?.moderationDetails?.categories, [
          'new_public_category',
        ]);
        expect(call.toString(), isNot(contains('PRIVATE')));
        expect(transport.requests.single.url.path, '/v1/responses');
        expect(
          transport.requests.single.headers['openai-beta'],
          beta ? 'responses_multi_agent=v1' : isNull,
        );
        transport.close();
      },
    );
  }
  for (final kind in ['generate', 'json', 'multipart']) {
    test(
      '$kind sends exact safety/markup fields and receives effective identifier',
      () async {
        final transport = _Transport(
          (request, _) async => _json(request, _imageResponse()),
        );
        final auth = _Auth();
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/proxy/v1',
            authProvider: auth,
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        final result = switch (kind) {
          'generate' => await client.images.generate(_generation()),
          'json' => await client.images.editJson(_jsonEdit()),
          _ => await client.images.edit(_multipartEdit()),
        };
        expect(result.safetyIdentifier, _private);
        expect(transport.requests, hasLength(1));
        final request = transport.requests.single;
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/proxy/v1/images/${kind == 'generate' ? 'generations' : 'edits'}',
        );
        expect(request.headers['authorization'], 'Bearer synthetic-image');
        expect(request.headers['accept'], 'application/json');
        if (kind != 'multipart') {
          expect(request.headers['content-type'], contains('utf-8'));
          final body =
              jsonDecode(utf8.decode(transport.bodies.single))
                  as Map<String, dynamic>;
          expect(body['safety_identifier'], _private);
          if (kind == 'json') {
            expect(body['markup'], {'file_id': 'file_overlay'});
          }
        } else {
          expect(
            request.headers['content-type'],
            startsWith('multipart/form-data; boundary='),
          );
          final body = latin1.decode(transport.bodies.single);
          final markupPart = _part(body, request, 'markup');
          expect(markupPart, contains('name="markup"; filename="overlay.png"'));
          expect(markupPart, contains('content-type: image/png'));
          expect(_partValue(markupPart), latin1.decode([0, 255, 128, 1]));
          expect(
            _partValue(_part(body, request, 'safety_identifier')),
            latin1.decode(utf8.encode(_private)),
          );
          expect(body, isNot(contains('name="mask"')));
        }
        client.close();
        expect(transport.closes, 0);
        transport.close();
      },
    );

    test(
      '$kind streaming retains fields, forced SSE headers and completed echo',
      () async {
        final transport = _Transport(
          (request, _) async => _sse(
            request,
            kind == 'generate'
                ? 'image_generation.completed'
                : 'image_edit.completed',
          ),
        );
        final client = OpenAIClient(
          config: OpenAIConfig(authProvider: _Auth()),
          httpClient: transport,
        );
        addTearDown(client.close);
        if (kind == 'generate') {
          final values = await client.images
              .generateStream(_generation())
              .toList();
          expect(
            (values.single as ImageGenCompletedEvent).safetyIdentifier,
            _private,
          );
        } else {
          final values =
              await (kind == 'json'
                      ? client.images.editJsonStream(_jsonEdit())
                      : client.images.editStream(_multipartEdit()))
                  .toList();
          expect(
            (values.single as ImageEditCompletedEvent).safetyIdentifier,
            _private,
          );
        }
        final request = transport.requests.single;
        expect(request.headers['accept'], 'text/event-stream');
        if (kind == 'multipart') {
          final body = latin1.decode(transport.bodies.single);
          expect(body, contains('name="markup"'));
          expect(body, contains('name="safety_identifier"'));
          expect(body, contains('name="stream"\r\n\r\ntrue\r\n'));
        } else {
          final body =
              jsonDecode(utf8.decode(transport.bodies.single))
                  as Map<String, dynamic>;
          expect(body['stream'], isTrue);
          expect(body['safety_identifier'], _private);
          if (kind == 'json') {
            expect(body['markup'], {'file_id': 'file_overlay'});
          }
        }
        expect(transport.closes, 0);
        transport.close();
      },
    );
  }

  test(
    'invalid bounds and conflicting overlays fail before authentication',
    () {
      final auth = _Auth();
      final transport = _Transport(
        (request, _) async => _json(request, _imageResponse()),
      );
      final client = OpenAIClient(
        config: OpenAIConfig(authProvider: auth),
        httpClient: transport,
      );
      addTearDown(client.close);
      expect(
        () => client.images.generateStream(
          _generation(safetyIdentifier: 'x' * 129),
        ),
        throwsFormatException,
      );
      expect(
        () => _jsonEdit().copyWith(mask: const ImageReference.file('mask')),
        throwsFormatException,
      );
      expect(
        () => _multipartEdit().copyWith(mask: Uint8List(1)),
        throwsFormatException,
      );
      expect(auth.calls, 0);
      expect(transport.requests, isEmpty);
    },
  );

  for (final (streaming, mislabeled) in [
    (false, false),
    (true, false),
    (false, true),
    (true, true),
  ]) {
    test(
      'HTTP image failures remain private (stream=$streaming, mislabeled=$mislabeled)',
      () async {
        final transport = _Transport(
          (request, _) async => _json(
            mislabeled
                ? http.Request(
                    'GET',
                    Uri.parse('https://fixture.invalid/v1/models'),
                  )
                : request,
            {
              'error': {
                'message': _private,
                'type': 'bad_image',
                'code': 'moderation_blocked',
              },
            },
            400,
          ),
        );
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        try {
          if (streaming) {
            await client.images.generateStream(_generation()).toList();
          } else {
            await client.images.generate(_generation());
          }
          fail('Expected HTTP failure');
        } on BadRequestException catch (error) {
          expect(error.statusCode, 400);
          expect(error.code, 'moderation_blocked');
          expect(error.message, _private);
          expect(error.body?['error'], containsPair('message', _private));
          expect(error.toString(), isNot(contains('PRIVATE')));
          expect(error.cause, isA<http.Response>());
        }
        transport.close();
      },
    );
  }

  for (final status in [200, 400]) {
    test(
      'legacy image variation errors remain private (HTTP $status)',
      () async {
        final transport = _Transport(
          (request, _) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(
                status == 200
                    ? 'PRIVATE_response_payload'
                    : jsonEncode({
                        'error': {'message': _private},
                      }),
              ),
            ),
            status,
            request: request,
          ),
        );
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        try {
          await client.images.createVariation(
            ImageVariationRequest(
              image: Uint8List.fromList([1, 2, 3]),
              imageFilename: 'original.png',
            ),
          );
          fail('Expected private variation error');
        } on OpenAIException catch (error) {
          expect(
            error,
            status == 200 ? isA<ParseException>() : isA<BadRequestException>(),
          );
          expect(error.toString(), isNot(contains('PRIVATE')));
        }
        transport.close();
      },
    );
  }

  for (final failAt in [1, 2]) {
    test('typed provider failures are private at auth call $failAt', () async {
      final auth = _Auth()..failAt = failAt;
      final transport = _Transport(
        (request, _) async => _json(request, _imageResponse()),
      );
      final client = OpenAIClient(
        config: OpenAIConfig(authProvider: auth),
        httpClient: transport,
      );
      addTearDown(client.close);
      try {
        await client.images.generate(_generation());
        fail('Expected provider failure');
      } on ConnectionException catch (error) {
        expect(error.toString(), isNot(contains('PRIVATE')));
        expect(error.cause, isA<ApiException>());
      }
      expect(transport.requests, isEmpty);
      transport.close();
    });
  }

  test(
    'typed stream-body failures are privately wrapped at the external origin',
    () async {
      final transport = _Transport(
        (request, _) async => http.StreamedResponse(
          Stream.error(const ApiException(message: _private, statusCode: 400)),
          200,
          request: request,
        ),
      );
      final client = OpenAIClient(httpClient: transport);
      addTearDown(client.close);
      await expectLater(
        client.images.generateStream(_generation()).toList(),
        throwsA(
          isA<ConnectionException>()
              .having(
                (e) => e.toString(),
                'diagnostics',
                isNot(contains('PRIVATE')),
              )
              .having((e) => e.cause, 'original cause', isA<ApiException>()),
        ),
      );
      transport.close();
    },
  );

  test(
    'inline errors keep explicit payloads but redact error and logger strings',
    () async {
      final records = <String>[];
      final logger = Logger('OpenAIClient');
      final previousLevel = logger.level;
      final previousHierarchy = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      logger.level = Level.ALL;
      final tap = logger.onRecord.listen((event) => records.add(event.message));
      addTearDown(() async {
        await tap.cancel();
        logger.level = previousLevel;
        hierarchicalLoggingEnabled = previousHierarchy;
      });
      final transport = _Transport(
        (request, _) async => http.StreamedResponse(
          Stream.value(
            utf8.encode(
              'event: error\ndata: ${jsonEncode({
                'error': {'message': _private},
              })}\n\n',
            ),
          ),
          200,
          request: request,
        ),
      );
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/v1?token=PRIVATE',
          logLevel: Level.FINEST,
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      try {
        await client.images.generateStream(_generation()).toList();
        fail('Expected inline error');
      } on StreamException catch (error) {
        expect(error.message, _private);
        expect(error.partialData, contains(_private));
        expect(error.toString(), isNot(contains('PRIVATE')));
      }
      expect(records.join('\n'), isNot(contains('PRIVATE')));
      transport.close();
    },
  );
}
