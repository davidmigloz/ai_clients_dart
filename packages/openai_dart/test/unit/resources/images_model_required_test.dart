import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  // These IDs and option combinations only test lossless local serialization.
  // They do not claim that a live model supports every optional parameter.
  for (final model in ['future-image-fixture', '']) {
    for (final streaming in [false, true]) {
      for (final populated in [false, true]) {
        test(
          'generation preserves model "$model", stream=$streaming, populated=$populated (IMG-01)',
          () async {
            var sends = 0;
            final expected = <String, dynamic>{
              'model': model,
              'prompt': 'Fixture generation',
              if (populated) ...{
                'n': 0,
                'quality': 'max',
                'response_format': 'b64_json',
                'size': '1536x864',
                'style': 'natural',
                'user': 'fixture-user',
                'background': 'transparent',
                'moderation': 'low',
                'output_format': 'webp',
                'output_compression': 0,
                'partial_images': 0,
                'stream': false,
              },
              if (streaming) 'stream': true,
            };
            final transport = MockClient.streaming((request, body) async {
              sends++;
              _expectHeaders(request, '/images/generations', streaming);
              expect(request, isA<http.Request>());
              expect(request.headers['content-type'], 'application/json');
              expect(jsonDecode(await body.bytesToString()), expected);
              return _response(streaming, 'image_generation');
            });
            final client = _client(transport);
            addTearDown(client.close);
            addTearDown(transport.close);
            final request = ImageGenerationRequest(
              model: model,
              prompt: 'Fixture generation',
              n: populated ? 0 : null,
              quality: populated ? ImageQuality.max : null,
              responseFormat: populated ? ImageResponseFormat.b64Json : null,
              size: populated ? const ImageSize.custom('1536x864') : null,
              style: populated ? ImageStyle.natural : null,
              user: populated ? 'fixture-user' : null,
              background: populated ? ImageBackground.transparent : null,
              moderation: populated ? ImageModerationLevel.low : null,
              outputFormat: populated ? ImageOutputFormat.webp : null,
              outputCompression: populated ? 0 : null,
              partialImages: populated ? 0 : null,
              stream: populated ? false : null,
            );
            if (streaming) {
              final events = await client.images
                  .generateStream(request)
                  .toList();
              _expectGenerationEvents(events);
            } else {
              _expectImageResponse(await client.images.generate(request));
            }
            expect(sends, 1);
          },
        );

        test(
          'multipart edit preserves model "$model", stream=$streaming, populated=$populated (IMG-02)',
          () async {
            var sends = 0;
            final image = Uint8List.fromList([0, 128, 255, 1]);
            final mask = Uint8List.fromList([255, 0, 127, 2]);
            final expected = <String, String>{
              'model': model,
              'prompt': 'Fixture edit',
              if (populated) ...{
                'n': '0',
                'size': '1536x864',
                'response_format': 'b64_json',
                'user': 'fixture-user',
                'background': 'transparent',
                'input_fidelity': 'high',
                'quality': 'max',
                'output_format': 'webp',
                'output_compression': '0',
                'moderation': 'low',
                'partial_images': '0',
                'stream': 'false',
              },
              if (streaming) 'stream': 'true',
            };
            final transport = MockClient.streaming((request, body) async {
              sends++;
              _expectHeaders(request, '/images/edits', streaming);
              expect(request, isA<http.MultipartRequest>());
              final multipart = request as http.MultipartRequest;
              expect(multipart.fields, expected);
              expect(
                request.headers['content-type'],
                startsWith('multipart/form-data; boundary='),
              );
              final wire = latin1.decode(await body.toBytes());
              for (final field in expected.entries) {
                _expectMultipartField(wire, field.key, field.value);
              }
              _expectMultipartFile(
                wire,
                multipart,
                'image',
                'source.JPEG',
                'image/jpeg',
                image,
              );
              expect(multipart.files, hasLength(populated ? 2 : 1));
              if (populated) {
                _expectMultipartFile(
                  wire,
                  multipart,
                  'mask',
                  'mask.WEBP',
                  'image/webp',
                  mask,
                );
              } else {
                expect(wire, isNot(contains('name="mask"')));
              }
              return _response(streaming, 'image_edit');
            });
            final client = _client(transport);
            addTearDown(client.close);
            addTearDown(transport.close);
            final request = ImageEditRequest(
              model: model,
              image: image,
              imageFilename: 'source.JPEG',
              prompt: 'Fixture edit',
              mask: populated ? mask : null,
              maskFilename: populated ? 'mask.WEBP' : null,
              n: populated ? 0 : null,
              size: populated ? const ImageSize.custom('1536x864') : null,
              responseFormat: populated ? ImageResponseFormat.b64Json : null,
              user: populated ? 'fixture-user' : null,
              background: populated ? ImageBackground.transparent : null,
              inputFidelity: populated ? ImageInputFidelity.high : null,
              quality: populated ? ImageQuality.max : null,
              outputFormat: populated ? ImageOutputFormat.webp : null,
              outputCompression: populated ? 0 : null,
              moderation: populated ? ImageModerationLevel.low : null,
              partialImages: populated ? 0 : null,
              stream: populated ? false : null,
            );
            if (streaming) {
              _expectEditEvents(
                await client.images.editStream(request).toList(),
              );
            } else {
              _expectImageResponse(await client.images.edit(request));
            }
            expect(sends, 1);
          },
        );
      }
    }
  }

  for (final modelState in ['omitted', 'null', 'future-image-fixture', '']) {
    for (final streaming in [false, true]) {
      test(
        'JSON edit keeps model "$modelState", stream=$streaming (IMG-03)',
        () async {
          var sends = 0;
          final model = modelState == 'omitted' || modelState == 'null'
              ? null
              : modelState;
          final json = <String, dynamic>{
            'images': [
              {'file_id': 'file-fixture'},
              {'image_url': 'https://example.invalid/source.png'},
            ],
            'prompt': 'Fixture JSON edit',
            'mask': {'file_id': 'file-mask'},
            if (modelState != 'omitted') 'model': model,
            'n': 1,
            'quality': 'high',
            'input_fidelity': 'high',
            'size': '1024x1024',
            'user': 'fixture-user',
            'output_format': 'png',
            'output_compression': 0,
            'moderation': 'low',
            'background': 'transparent',
            'stream': false,
            'partial_images': 0,
          };
          final expected = <String, dynamic>{
            ...json,
            if (streaming) 'stream': true,
          };
          if (model == null) expected.remove('model');
          final transport = MockClient.streaming((request, body) async {
            sends++;
            _expectHeaders(request, '/images/edits', streaming);
            expect(request, isA<http.Request>());
            expect(request.headers['content-type'], 'application/json');
            expect(jsonDecode(await body.bytesToString()), expected);
            return _response(streaming, 'image_edit');
          });
          final client = _client(transport);
          addTearDown(client.close);
          addTearDown(transport.close);
          final request = ImageEditJsonRequest.fromJson(json);
          expect(request.model, model);
          if (streaming) {
            _expectEditEvents(
              await client.images.editJsonStream(request).toList(),
            );
          } else {
            _expectImageResponse(await client.images.editJson(request));
          }
          expect(sends, 1);
        },
      );
    }
  }

  for (final model in <String?>[null, 'future-variation-fixture', '']) {
    test('variation model "$model" remains optional (IMG-04)', () async {
      var sends = 0;
      final image = Uint8List.fromList([0, 255, 128]);
      final transport = MockClient.streaming((request, body) async {
        sends++;
        _expectHeaders(request, '/images/variations', false);
        expect(request, isA<http.MultipartRequest>());
        final multipart = request as http.MultipartRequest;
        expect(multipart.fields, {'model': ?model});
        final wire = latin1.decode(await body.toBytes());
        if (model == null) {
          expect(wire, isNot(contains('name="model"')));
        } else {
          _expectMultipartField(wire, 'model', model);
        }
        expect(multipart.files, hasLength(1));
        _expectMultipartFile(
          wire,
          multipart,
          'image',
          'variation.PNG',
          'image/png',
          image,
        );
        return _response(false, 'image_edit');
      });
      final client = _client(transport);
      addTearDown(client.close);
      addTearDown(transport.close);
      _expectImageResponse(
        await client.images.createVariation(
          ImageVariationRequest(
            image: image,
            imageFilename: 'variation.PNG',
            model: model,
          ),
        ),
      );
      expect(sends, 1);
    });
  }
}

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    authProvider: ApiKeyProvider('sk-fixture'),
    baseUrl: 'https://api.example.invalid/v1',
    organization: 'org-fixture',
    project: 'proj-fixture',
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);

void _expectHeaders(http.BaseRequest request, String path, bool streaming) {
  expect(request.method, 'POST');
  expect(request.url.path, '/v1$path');
  expect(request.url.queryParameters, isEmpty);
  expect(request.headers['authorization'], 'Bearer sk-fixture');
  expect(request.headers['openai-organization'], 'org-fixture');
  expect(request.headers['openai-project'], 'proj-fixture');
  expect(request.headers['x-request-id'], isNotEmpty);
  expect(request.headers['accept'], streaming ? 'text/event-stream' : isNull);
}

void _expectMultipartField(String wire, String field, String value) => expect(
  wire,
  matches(
    RegExp(
      'name="${RegExp.escape(field)}"\r\n'
      '(?:[^\r\n]+\r\n)*\r\n${RegExp.escape(value)}\r\n',
    ),
  ),
  reason: 'multipart field "$field" must carry its exact value',
);

void _expectMultipartFile(
  String wire,
  http.MultipartRequest request,
  String field,
  String filename,
  String mime,
  Uint8List bytes,
) {
  final file = request.files.singleWhere((file) => file.field == field);
  expect(file.filename, filename);
  expect(file.contentType.toString(), mime);
  expect(file.length, bytes.length);
  expect(
    wire,
    contains(
      'content-type: $mime\r\n'
      'content-disposition: form-data; name="$field"; filename="$filename"\r\n\r\n'
      '${latin1.decode(bytes)}\r\n',
    ),
    reason: 'multipart file "$field" must preserve MIME, filename and bytes',
  );
}

Map<String, dynamic> _usage() => const {
  'input_tokens': 3,
  'output_tokens': 4,
  'total_tokens': 7,
  'input_tokens_details': {'text_tokens': 1, 'image_tokens': 2},
  'output_tokens_details': {'text_tokens': 0, 'image_tokens': 4},
};

Map<String, dynamic> _metadata() => const {
  'size': '1024x1024',
  'quality': 'high',
  'background': 'transparent',
  'output_format': 'png',
};

Map<String, dynamic> _imageResponseJson() => {
  'created': 123,
  'data': [
    {'b64_json': 'AP8B'},
  ],
  ..._metadata(),
  'usage': _usage(),
};

Map<String, dynamic> _partialJson(String prefix) => {
  'type': '$prefix.partial_image',
  'created_at': 122,
  'b64_json': 'AA==',
  'partial_image_index': 0,
  ..._metadata(),
  'size': '1254x1254',
};

Map<String, dynamic> _completedJson(String prefix) => {
  'type': '$prefix.completed',
  'created_at': 123,
  'b64_json': 'AP8B',
  ..._metadata(),
  'usage': _usage(),
};

http.StreamedResponse _response(bool streaming, String prefix) =>
    http.StreamedResponse(
      Stream.value(
        utf8.encode(
          streaming
              ? 'data: ${jsonEncode(_partialJson(prefix))}\n\n'
                    'data: ${jsonEncode(_completedJson(prefix))}\n\n'
                    'data: [DONE]\n\n'
              : jsonEncode(_imageResponseJson()),
        ),
      ),
      200,
      headers: {
        'content-type': streaming ? 'text/event-stream' : 'application/json',
      },
    );

void _expectImageResponse(ImageResponse response) {
  expect(response.created, 123);
  expect(response.data, hasLength(1));
  expect(base64Decode(response.firstBase64!), [0, 255, 1]);
  expect(response.size, ImageSize.size1024x1024);
  expect(response.quality, ImageQuality.high);
  expect(response.background, ImageBackground.transparent);
  expect(response.outputFormat, ImageOutputFormat.png);
  expect(response.usage?.inputTokensDetails.textTokens, 1);
  expect(response.usage?.inputTokensDetails.imageTokens, 2);
  expect(response.usage?.outputTokensDetails?.imageTokens, 4);
  expect(response.toJson(), _imageResponseJson());
}

void _expectGenerationEvents(List<ImageGenStreamEvent> events) {
  expect(events, hasLength(2));
  expect(events.first, isA<ImageGenPartialImageEvent>());
  expect(events.last, isA<ImageGenCompletedEvent>());
  final partial = events.first as ImageGenPartialImageEvent;
  final complete = events.last as ImageGenCompletedEvent;
  expect(partial.partialImageIndex, 0);
  expect(partial.size, const ImageSize.custom('1254x1254'));
  expect(base64Decode(complete.b64Json), [0, 255, 1]);
  expect(complete.usage.toJson(), _usage());
  expect(partial.toJson(), _partialJson('image_generation'));
  expect(complete.toJson(), _completedJson('image_generation'));
}

void _expectEditEvents(List<ImageEditStreamEvent> events) {
  expect(events, hasLength(2));
  expect(events.first, isA<ImageEditPartialImageEvent>());
  expect(events.last, isA<ImageEditCompletedEvent>());
  final partial = events.first as ImageEditPartialImageEvent;
  final complete = events.last as ImageEditCompletedEvent;
  expect(partial.partialImageIndex, 0);
  expect(partial.size, const ImageSize.custom('1254x1254'));
  expect(base64Decode(complete.b64Json), [0, 255, 1]);
  expect(complete.usage.toJson(), _usage());
  expect(partial.toJson(), _partialJson('image_edit'));
  expect(complete.toJson(), _completedJson('image_edit'));
}
