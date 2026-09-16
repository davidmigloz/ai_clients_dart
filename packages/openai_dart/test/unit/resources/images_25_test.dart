import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const models = {
    ImageModels.gptImage25Flare: 'gpt-image-2.5-flare',
    ImageModels.gptImage25Sunburst: 'gpt-image-2.5-sunburst',
    ImageModels.gptImage25Flare20260908: 'gpt-image-2.5-flare-2026-09-08',
    ImageModels.gptImage25Sunburst20260908: 'gpt-image-2.5-sunburst-2026-09-08',
  };
  const qualities = {ImageQuality.xhigh: 'xhigh', ImageQuality.max: 'max'};
  const size = ImageSize.custom('1536x864');
  const usage = {
    'input_tokens': 10,
    'output_tokens': 20,
    'total_tokens': 30,
    'input_tokens_details': {'text_tokens': 3, 'image_tokens': 7},
  };

  for (final model in models.entries) {
    for (final quality in qualities.entries) {
      for (final operation in ['generate', 'edit', 'editJson']) {
        for (final streaming in [false, true]) {
          test(
            '${model.value} ${quality.value} $operation stream=$streaming',
            () async {
              final isEdit = operation != 'generate';
              final eventPrefix = isEdit ? 'image_edit' : 'image_generation';
              final metadata = {
                'size': '1536x864',
                'quality': quality.value,
                'background': 'transparent',
                'output_format': 'webp',
              };
              final partial = {
                'type': '$eventPrefix.partial_image',
                'b64_json': 'AAAA',
                'created_at': 1,
                // Streaming sizes need not satisfy final-image constraints.
                ...metadata,
                'size': '1254x1254',
                'partial_image_index': 0,
              };
              final completed = {
                'type': '$eventPrefix.completed',
                'b64_json': 'BBBB',
                'created_at': 2,
                ...metadata,
                'usage': usage,
              };
              var requestCount = 0;
              final mock = MockClient.streaming((request, body) async {
                requestCount++;
                expect(request.method, 'POST');
                expect(
                  request.url.path,
                  isEdit ? '/v1/images/edits' : '/v1/images/generations',
                );
                expect(request.headers['Authorization'], 'Bearer test-key');
                if (streaming) {
                  expect(request.headers['Accept'], 'text/event-stream');
                }
                final wire = await body.bytesToString();
                if (operation == 'edit') {
                  expect(
                    request.headers['content-type'],
                    startsWith('multipart/form-data;'),
                  );
                  for (final field in {
                    'model': model.value,
                    'quality': quality.value,
                    'size': '1536x864',
                    'background': 'transparent',
                    'output_format': 'webp',
                    if (streaming) 'stream': 'true',
                    if (streaming) 'partial_images': '1',
                  }.entries) {
                    expect(
                      wire,
                      contains('name="${field.key}"\r\n\r\n${field.value}\r\n'),
                    );
                  }
                  expect(wire, contains('name="image"; filename="source.png"'));
                } else {
                  final json = jsonDecode(wire) as Map<String, dynamic>;
                  expect(json['model'], model.value);
                  expect(json['quality'], quality.value);
                  expect(json['size'], '1536x864');
                  expect(json['background'], 'transparent');
                  expect(json['output_format'], 'webp');
                  expect(json['stream'], streaming ? isTrue : isNull);
                  if (streaming) expect(json['partial_images'], 1);
                  if (isEdit) {
                    expect(json['images'], [
                      {'image_url': 'https://example.com/source.png'},
                      {'file_id': 'file-reference'},
                    ]);
                    expect(json['mask'], {'file_id': 'file-mask'});
                  }
                }
                final response = streaming
                    ? 'data: ${jsonEncode(partial)}\n\n'
                          'data: ${jsonEncode(completed)}\n\n'
                          'data: [DONE]\n\n'
                    : jsonEncode({
                        'created': 2,
                        'data': [
                          {'b64_json': 'BBBB'},
                        ],
                        ...metadata,
                        'usage': usage,
                      });
                return http.StreamedResponse(
                  Stream.value(utf8.encode(response)),
                  200,
                  headers: {
                    'content-type': streaming
                        ? 'text/event-stream'
                        : 'application/json',
                  },
                );
              });
              final client = OpenAIClient(
                config: const OpenAIConfig(
                  authProvider: ApiKeyProvider('test-key'),
                ),
                httpClient: mock,
              );
              addTearDown(client.close);
              final generation = ImageGenerationRequest(
                prompt: 'A robot with a flower',
                model: model.key,
                quality: quality.key,
                size: size,
                background: ImageBackground.transparent,
                outputFormat: ImageOutputFormat.webp,
                partialImages: streaming ? 1 : null,
              );
              final edit = ImageEditRequest(
                prompt: 'Change only the flower',
                image: Uint8List.fromList([1, 2, 3]),
                imageFilename: 'source.png',
                model: model.key,
                quality: quality.key,
                size: size,
                background: ImageBackground.transparent,
                outputFormat: ImageOutputFormat.webp,
                partialImages: streaming ? 1 : null,
              );
              final editJson = ImageEditJsonRequest(
                prompt: 'Change only the flower',
                images: const [
                  ImageReference.url('https://example.com/source.png'),
                  ImageReference.file('file-reference'),
                ],
                mask: const ImageReference.file('file-mask'),
                model: model.key,
                quality: quality.key,
                size: size,
                background: ImageBackground.transparent,
                outputFormat: ImageOutputFormat.webp,
                partialImages: streaming ? 1 : null,
              );

              if (!streaming) {
                final response = await switch (operation) {
                  'generate' => client.images.generate(generation),
                  'edit' => client.images.edit(edit),
                  _ => client.images.editJson(editJson),
                };
                expect(response.quality, quality.key);
                expect(response.size, size);
                expect(response.data.single.b64Json, 'BBBB');
                expect(response.toJson()['size'], '1536x864');
                expect(response.toJson()['quality'], quality.value);
                expect(response.usage?.totalTokens, 30);
              } else if (!isEdit) {
                final events = await client.images
                    .generateStream(generation)
                    .toList();
                expect(events, hasLength(2));
                final first = events.first as ImageGenPartialImageEvent;
                final last = events.last as ImageGenCompletedEvent;
                expect(first.toJson(), partial);
                expect(last.toJson(), completed);
                expect(first.size, const ImageSize.custom('1254x1254'));
                expect(last.size, size);
                expect(first.quality, quality.key);
                expect(last.quality, quality.key);
              } else {
                final events =
                    await (operation == 'edit'
                            ? client.images.editStream(edit)
                            : client.images.editJsonStream(editJson))
                        .toList();
                expect(events, hasLength(2));
                final first = events.first as ImageEditPartialImageEvent;
                final last = events.last as ImageEditCompletedEvent;
                expect(first.toJson(), partial);
                expect(last.toJson(), completed);
                expect(first.size, const ImageSize.custom('1254x1254'));
                expect(last.size, size);
                expect(first.quality, quality.key);
                expect(last.quality, quality.key);
              }
              expect(requestCount, 1);
            },
          );
        }
      }
    }
  }

  test('custom sizes round-trip without collapsing into unknown', () {
    for (final wire in ['1536x864', '3840x2160', '2160x3840', 'future-size']) {
      final size = ImageSize.fromJson(wire);
      expect(size.toJson(), wire);
      expect(size, ImageSize.custom(wire));
      expect(size.hashCode, ImageSize.custom(wire).hashCode);
      expect(size, isNot(ImageSize.unknown));
    }
    // Verify that custom and preset construction have the same value semantics.
    // ignore: use_named_constants
    expect(const ImageSize.custom('1024x1024'), ImageSize.size1024x1024);
    expect(
      // ignore: use_named_constants
      const ImageSize.custom('1024x1024').hashCode,
      ImageSize.size1024x1024.hashCode,
    );
    expect(ImageSize.fromJson('auto'), same(ImageSize.auto));
  });

  test('JSON parsing and copyWith preserve custom sizes and new quality', () {
    const json = {
      'prompt': 'A flower',
      'model': 'gpt-image-2.5-flare',
      'size': '1536x864',
      'quality': 'max',
    };
    final generation = ImageGenerationRequest.fromJson(json);
    expect(generation.toJson(), json);
    expect(generation.copyWith().size, size);
    expect(generation.copyWith(size: null).size, isNull);
    expect(
      generation.copyWith(quality: ImageQuality.xhigh).toJson()['quality'],
      'xhigh',
    );
    final editJson = {
      ...json,
      'images': [
        {'file_id': 'file-source'},
      ],
    };
    expect(ImageEditJsonRequest.fromJson(editJson).toJson(), editJson);
    final edit = ImageEditRequest(
      image: Uint8List(0),
      imageFilename: 'source.png',
      prompt: 'A flower',
      size: size,
      quality: ImageQuality.max,
    );
    expect(edit.copyWith().size, size);
    expect(edit.copyWith().quality, ImageQuality.max);
    expect(edit.copyWith(size: null).size, isNull);
  });
}
