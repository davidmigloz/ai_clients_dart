import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _author = SvgOptions(
  model: 'fixture-author',
  reasoning: SvgReasoning(effort: ReasoningEffort.high),
);

const _svgUsage = SvgUsage(
  model: 'fixture-author',
  inputTokens: 5,
  outputTokens: 6,
  totalTokens: 11,
  reasoningTokens: 2,
);

Map<String, Object?> _call({bool beta = false, String format = 'svg'}) => {
  'type': 'image_generation_call',
  'id': 'image_fixture',
  'status': 'completed',
  'result': 'AA==',
  'output_format': format,
  if (format == 'svg') 'svg_usage': _svgUsage.toJson(),
  if (beta) 'agent': {'agent_name': 'fixture'},
};

Map<String, Object?> _response({bool beta = false, String format = 'svg'}) => {
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 1,
  'status': 'completed',
  'image': {'context_compression': 'enabled'},
  'output': [_call(beta: beta, format: format)],
};

http.Response _json(Object data) => http.Response(
  jsonEncode(data),
  200,
  headers: {'content-type': 'application/json'},
);

http.Response _images(String format) => _json({
  'created': 1,
  'data': [
    {'b64_json': 'AA=='},
  ],
  'output_format': format,
  'usage': {
    'input_tokens': 1,
    'output_tokens': 2,
    'total_tokens': 3,
    'input_tokens_details': {'text_tokens': 1, 'image_tokens': 0},
  },
  if (format == 'svg') 'svg_usage': _svgUsage.toJson(),
});

void main() {
  test(
    'standalone SVG sends author settings and decodes separate usage',
    () async {
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/v1/images/generations');
          expect(jsonDecode(request.body), {
            'model': ImageModels.gptImage26Flare,
            'prompt': 'Draw a simple flower logo',
            'complexity': 'high',
            'output_format': 'svg',
            'svg': {
              'model': 'fixture-author',
              'reasoning': {'effort': 'high'},
            },
          });
          return _images('svg');
        }),
      );
      addTearDown(client.close);
      const request = ImageGenerationRequest(
        model: ImageModels.gptImage26Flare,
        prompt: 'Draw a simple flower logo',
        outputFormat: ImageOutputFormat.svg,
        complexity: ImageComplexity.high,
        svg: _author,
      );

      expect(ImageGenerationRequest.fromJson(request.toJson()), request);
      expect(request.copyWith(complexity: null, svg: null).svg, isNull);
      final result = await client.images.generate(request);
      expect(result.outputFormat, ImageOutputFormat.svg);
      expect(result.usage?.totalTokens, 3);
      expect(result.svgUsage, _svgUsage);
      final roundTrip = ImageResponse.fromJson(result.toJson());
      expect(roundTrip, result);
      expect(roundTrip.hashCode, result.hashCode);
      expect(
        result.copyWith(svgUsage: null).toJson(),
        isNot(contains('svg_usage')),
      );
    },
  );

  test(
    'JSON edit sends GIF frame controls without inserting defaults',
    () async {
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          expect(request.url.path, '/v1/images/edits');
          expect(jsonDecode(request.body), {
            'images': [
              {'file_id': 'file_fixture'},
            ],
            'prompt': 'Animate a flower moving in the breeze',
            'model': ImageModels.gptImage26Sunburst,
            'output_format': 'gif',
            'frame_duration_ms': 2500,
          });
          return _images('gif');
        }),
      );
      addTearDown(client.close);
      final request = ImageEditJsonRequest.fromJson(const {
        'images': [
          {'file_id': 'file_fixture'},
        ],
        'prompt': 'Animate a flower moving in the breeze',
        'model': ImageModels.gptImage26Sunburst,
        'output_format': 'gif',
        'frame_count': null,
        'frame_duration_ms': 2500,
        'complexity': null,
        'svg': null,
      });
      expect(request.copyWith(frameCount: 4).frameCount, 4);
      final result = await client.images.editJson(request);
      expect(result.outputFormat, ImageOutputFormat.gif);
      expect(result.svgUsage, isNull);
    },
  );

  for (final format in [ImageOutputFormat.svg, ImageOutputFormat.gif]) {
    test('multipart edit dispatches ${format.name} fields', () async {
      final client = OpenAIClient(
        httpClient: MockClient.streaming((request, body) async {
          expect(request.url.path, '/v1/images/edits');
          final wire = await body.bytesToString();
          expect(wire, contains('name="complexity"\r\n\r\nlow'));
          expect(wire, contains('name="output_format"\r\n\r\n${format.name}'));
          expect(wire, isNot(contains('name="svg"')));
          if (format == ImageOutputFormat.svg) {
            expect(wire, contains('name="svg[model]"\r\n\r\nfixture-author'));
            expect(wire, contains('name="svg[reasoning][effort]"\r\n\r\nhigh'));
          } else {
            expect(wire, contains('name="frame_count"\r\n\r\n4'));
            expect(wire, contains('name="frame_duration_ms"\r\n\r\n120'));
          }
          final response = _images(format.name);
          return http.StreamedResponse(
            Stream.value(response.bodyBytes),
            200,
            headers: response.headers,
          );
        }),
      );
      addTearDown(client.close);
      final request = ImageEditRequest(
        image: Uint8List.fromList([0]),
        imageFilename: 'sample.png',
        model: ImageModels.gptImage26Flare,
        prompt: 'Edit the sample',
        outputFormat: format,
        complexity: ImageComplexity.low,
        svg: format == ImageOutputFormat.svg ? _author : null,
        frameCount: format == ImageOutputFormat.gif ? 4 : null,
        frameDurationMs: format == ImageOutputFormat.gif ? 120 : null,
      );
      expect(request.copyWith(), request);
      expect(request.copyWith().hashCode, request.hashCode);
      expect((await client.images.edit(request)).outputFormat, format);
    });
    test('standalone ${format.name} is rejected on streaming entry points', () {
      final client = OpenAIClient(
        httpClient: MockClient(
          (_) async => throw StateError('unexpected dispatch'),
        ),
      );
      addTearDown(client.close);
      expect(
        () => client.images.generateStream(
          ImageGenerationRequest(
            model: ImageModels.gptImage26Flare,
            prompt: 'Draw a flower',
            outputFormat: format,
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => client.images.editJsonStream(
          ImageEditJsonRequest(
            images: const [ImageReference.file('file_fixture')],
            prompt: 'Edit the flower',
            outputFormat: format,
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => client.images.editStream(
          ImageEditRequest(
            image: Uint8List.fromList([0]),
            imageFilename: 'sample.png',
            prompt: 'Edit the flower',
            model: ImageModels.gptImage26Flare,
            outputFormat: format,
          ),
        ),
        throwsFormatException,
      );
    });
  }

  test(
    'format-specific constraints preserve reversible request configuration',
    () {
      const base = ImageGenerationRequest(
        model: ImageModels.gptImage26Flare,
        prompt: 'Draw a flower',
      );
      expect(base.copyWith(frameCount: 2).toJson, throwsFormatException);
      expect(
        base
            .copyWith(outputFormat: ImageOutputFormat.gif, frameCount: 17)
            .toJson,
        throwsFormatException,
      );
      expect(
        base.copyWith(outputFormat: ImageOutputFormat.svg, n: 2).toJson,
        throwsFormatException,
      );
      expect(
        base
            .copyWith(
              outputFormat: ImageOutputFormat.svg,
              svg: const SvgOptions(),
            )
            .toJson,
        throwsFormatException,
      );
      expect(
        () => ImageEditJsonRequest(
          images: const [ImageReference.file('file_fixture')],
          mask: const ImageReference.file('file_mask'),
          prompt: 'Edit the flower',
          outputFormat: ImageOutputFormat.gif,
        ),
        throwsFormatException,
      );
      const tool = ImageGenerationTool(
        outputFormat: 'gif',
        frameDurationMs: 2001,
      );
      expect(tool.toJson, throwsFormatException);
    },
  );

  for (final beta in [false, true]) {
    test(
      'Responses beta=$beta sends and resolves image context on create and compact',
      () async {
        final client = OpenAIClient(
          httpClient: MockClient((request) async {
            final json = jsonDecode(request.body) as Map<String, dynamic>;
            expect(json['image'], {'context_compression': 'enabled'});
            expect(
              request.headers['openai-beta'],
              beta ? 'responses_multi_agent=v1' : isNull,
            );
            final compact = request.url.path.endsWith('/compact');
            if (!compact) {
              expect((json['tools'] as List).single, {
                'type': 'image_generation',
                'output_format': 'svg',
                'complexity': 'medium',
                'svg': _author.toJson(),
              });
            }
            return _json({
              ..._response(beta: beta),
              if (compact) ...{
                'object': 'response.compaction',
                'output': <Object>[],
                'usage': {
                  'input_tokens': 2,
                  'output_tokens': 1,
                  'total_tokens': 3,
                },
              },
            });
          }),
        );
        addTearDown(client.close);
        const image = ImageOptions(
          contextCompression: ImageContextCompression.enabled,
        );
        final request = CreateResponseRequest(
          model: 'fixture',
          input: const ResponseInput.text('Draw a flower'),
          image: image,
          tools: [
            ResponseTool.imageGeneration(
              outputFormat: 'svg',
              complexity: ImageComplexity.medium,
              svg: _author,
            ),
          ],
        );
        expect(CreateResponseRequest.fromJson(request.toJson()), request);
        expect(
          ResponsesCreateEvent.fromJson(
            ResponsesCreateEvent(request: request).toJson(),
          ).request.image,
          image,
        );
        final result = await client.responses.create(request, beta: beta);
        expect(
          result.image?.contextCompression,
          ResolvedImageContextCompression.enabled,
        );
        expect(result.imageGenerationCalls.single.svgUsage, _svgUsage);
        expect(
          result.imageGenerationCalls.single.outputFormat,
          ImageOutputFormat.svg,
        );
        expect(Response.fromJson(result.toJson()), result);
        expect(result.copyWith(image: null).toJson(), isNot(contains('image')));

        final compactRequest = CompactResponseRequest.fromJson({
          'model': 'fixture',
          'image': image.toJson(),
        });
        expect(compactRequest.copyWith(image: null).image, isNull);
        final compact = await client.responses.compact(
          compactRequest,
          beta: beta,
        );
        expect(compact.image, result.image);
        expect(ResponseCompaction.fromJson(compact.toJson()), compact);
      },
    );
  }

  test(
    'Responses lifecycle streaming remains available for GIF tools',
    () async {
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          final json = jsonDecode(request.body) as Map<String, dynamic>;
          expect(json['stream'], isTrue);
          expect((json['tools'] as List).single, {
            'type': 'image_generation',
            'output_format': 'gif',
            'frame_count': 5,
            'frame_duration_ms': 220,
            'partial_images': 0,
          });
          final completed = jsonEncode({
            'type': 'response.completed',
            'sequence_number': 1,
            'response': _response(format: 'gif'),
          });
          return http.Response(
            'data: $completed\n\ndata: [DONE]\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }),
      );
      addTearDown(client.close);
      final events = await client.responses
          .createStream(
            const CreateResponseRequest(
              model: 'fixture',
              input: ResponseInput.text('Draw an animation'),
              tools: [
                ImageGenerationTool(
                  outputFormat: 'gif',
                  frameCount: 5,
                  frameDurationMs: 220,
                  partialImages: 0,
                ),
              ],
            ),
          )
          .toList();
      final result = events.whereType<ResponseCompletedEvent>().single.response;
      expect(
        result.imageGenerationCalls.single.outputFormat,
        ImageOutputFormat.gif,
      );
    },
  );

  test('Conversation retrieval preserves SVG output metadata', () async {
    final client = OpenAIClient(
      httpClient: MockClient((request) async {
        expect(
          request.url.path,
          '/v1/conversations/conv_fixture/items/image_fixture',
        );
        return _json(_call());
      }),
    );
    addTearDown(client.close);
    final item =
        await client.conversations.items.retrieve(
              'conv_fixture',
              'image_fixture',
            )
            as ConversationImageGenerationCallItem;
    expect(item.outputFormat, ImageOutputFormat.svg);
    expect(item.svgUsage, _svgUsage);
    final recreated = ConversationItem.fromJson(item.toJson());
    expect(recreated, item);
    expect(recreated.hashCode, item.hashCode);
  });

  test('Conversation image calls retain status and nullable result', () {
    for (final status in [
      ImageGenerationCallStatus.generating,
      ImageGenerationCallStatus.failed,
    ]) {
      final json = _call()
        ..['status'] = status.toJson()
        ..['result'] = null;
      if (status == ImageGenerationCallStatus.failed) {
        json['error'] = {
          'code': 'moderation_blocked',
          'type': 'image_generation_error',
          'message': 'Fixture rejection',
          'param': null,
          'moderation_details': {
            'moderation_stage': 'output',
            'categories': ['fixture_category'],
          },
        };
      }
      final item =
          ConversationItem.fromJson(json)
              as ConversationImageGenerationCallItem;
      expect(item.status, status);
      expect(item.result, isNull);
      expect(
        item.error?.code,
        status == ImageGenerationCallStatus.failed
            ? 'moderation_blocked'
            : null,
      );
      expect(item.toJson(), json);
      final rebuilt = ConversationItem.fromJson(item.toJson());
      expect(rebuilt, item);
      expect(rebuilt.hashCode, item.hashCode);
    }
  });

  test('stored GIF tools preserve their default compression', () {
    const data = {
      'type': 'additional_tools',
      'id': 'item_tools',
      'role': 'user',
      'tools': [
        {
          'type': 'image_generation',
          'output_format': 'gif',
          'output_compression': 100,
        },
      ],
    };
    expect(OutputItem.fromJson(data).toJson(), data);
    expect(
      const ImageGenerationTool(
        outputFormat: 'gif',
        outputCompression: 80,
      ).toJson,
      throwsFormatException,
    );
    expect(
      const ImageGenerationRequest(
        model: ImageModels.gptImage26Sunburst,
        prompt: 'Draw an animation',
        outputFormat: ImageOutputFormat.gif,
        outputCompression: 100,
      ).toJson,
      throwsFormatException,
    );
  });

  test('Responses input history preserves the same SVG image call', () async {
    final client = OpenAIClient(
      httpClient: MockClient((request) async {
        expect(request.url.path, '/v1/responses/resp_fixture/input_items');
        expect(request.headers['openai-beta'], 'responses_multi_agent=v1');
        return _json({
          'object': 'list',
          'data': [_call(beta: true)],
          'has_more': false,
        });
      }),
    );
    addTearDown(client.close);
    final list = await client.responses.inputItems.list(
      'resp_fixture',
      beta: true,
    );
    final item = list.data.single as ImageGenerationCallItem;
    expect(item.call.svgUsage, _svgUsage);
    expect(item.toJson(), _call(beta: true));
    expect(
      ResponseInput.fromJson(ResponseInput.items([item]).toJson()),
      ResponseInput.items([item]),
    );
  });

  test(
    'context options distinguish omitted settings and a resolved policy',
    () {
      expect(
        CreateResponseRequest.fromJson(const {
          'model': 'fixture',
          'input': 'fixture',
          'image': null,
        }).toJson(),
        isNot(contains('image')),
      );
      expect(
        CreateResponseRequest.fromJson(const {
          'model': 'fixture',
          'input': 'fixture',
          'image': <String, dynamic>{},
        }).toJson()['image'],
        isEmpty,
      );
      expect(
        () => ImageOptions.fromJson(const {'context_compression': null}),
        throwsFormatException,
      );
      expect(
        () => ResolvedImageOptions.fromJson(const <String, dynamic>{}),
        throwsFormatException,
      );
      expect(
        () => ResolvedImageOptions.fromJson(const {
          'context_compression': 'auto',
        }),
        throwsFormatException,
      );
    },
  );
}
