import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ImageGenStreamEvent parsing', () {
    test('dispatches partial_image and completed variants', () {
      const partialJson = {
        'type': 'image_generation.partial_image',
        'b64_json': 'AAAA',
        'created_at': 111,
        'size': '1024x1024',
        'quality': 'high',
        'background': 'transparent',
        'output_format': 'png',
        'partial_image_index': 0,
      };
      const completedJson = {
        'type': 'image_generation.completed',
        'b64_json': 'BBBB',
        'created_at': 222,
        'size': '1536x1024',
        'quality': 'auto',
        'background': 'opaque',
        'output_format': 'webp',
        'usage': {
          'total_tokens': 10,
          'input_tokens': 3,
          'output_tokens': 7,
          'input_tokens_details': {'text_tokens': 3, 'image_tokens': 0},
          'output_tokens_details': {'text_tokens': 0, 'image_tokens': 7},
        },
      };

      final partial = ImageGenStreamEvent.fromJson(partialJson);
      expect(partial, isA<ImageGenPartialImageEvent>());
      final p = partial as ImageGenPartialImageEvent;
      expect(p.partialImageIndex, 0);
      expect(p.size, ImageSize.size1024x1024);
      expect(p.background, ImageBackground.transparent);

      final completed = ImageGenStreamEvent.fromJson(completedJson);
      expect(completed, isA<ImageGenCompletedEvent>());
      final c = completed as ImageGenCompletedEvent;
      expect(c.usage.totalTokens, 10);
      expect(c.size, ImageSize.size1536x1024);

      // Round-trip.
      expect(ImageGenStreamEvent.fromJson(partial.toJson()), equals(partial));
      expect(
        ImageGenStreamEvent.fromJson(completed.toJson()),
        equals(completed),
      );
    });

    test('unknown discriminator falls back without throwing', () {
      const json = {
        'type': 'image_generation.some_future_event',
        'something_new': 'value',
      };
      final event = ImageGenStreamEvent.fromJson(json);
      expect(event, isA<ImageGenUnknownEvent>());
      expect(event.type, 'image_generation.some_future_event');
      // Raw JSON preserved on round-trip.
      expect(event.toJson()['something_new'], 'value');
    });
  });

  group('ImageEditStreamEvent parsing', () {
    test('dispatches partial_image and completed variants', () {
      const partialJson = {
        'type': 'image_edit.partial_image',
        'b64_json': 'AAAA',
        'created_at': 111,
        'size': '1024x1536',
        'quality': 'medium',
        'background': 'auto',
        'output_format': 'jpeg',
        'partial_image_index': 1,
      };
      const completedJson = {
        'type': 'image_edit.completed',
        'b64_json': 'BBBB',
        'created_at': 222,
        'size': '1024x1024',
        'quality': 'high',
        'background': 'transparent',
        'output_format': 'png',
        'usage': {
          'total_tokens': 50,
          'input_tokens': 10,
          'output_tokens': 40,
          'input_tokens_details': {'text_tokens': 10, 'image_tokens': 0},
        },
      };

      final partial = ImageEditStreamEvent.fromJson(partialJson);
      expect(partial, isA<ImageEditPartialImageEvent>());
      final completed = ImageEditStreamEvent.fromJson(completedJson);
      expect(completed, isA<ImageEditCompletedEvent>());
      expect(
        (completed as ImageEditCompletedEvent).usage.outputTokensDetails,
        isNull,
      );

      expect(ImageEditStreamEvent.fromJson(partial.toJson()), equals(partial));
      expect(
        ImageEditStreamEvent.fromJson(completed.toJson()),
        equals(completed),
      );
    });

    test('unknown discriminator falls back without throwing', () {
      const json = {'type': 'image_edit.v3', 'foo': 'bar'};
      final event = ImageEditStreamEvent.fromJson(json);
      expect(event, isA<ImageEditUnknownEvent>());
    });
  });

  group('ImagesResource.generateStream', () {
    test('forces stream=true and yields typed SSE events', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final partialLine = jsonEncode({
        'type': 'image_generation.partial_image',
        'b64_json': 'AAAA',
        'created_at': 1,
        'size': '1024x1024',
        'quality': 'high',
        'background': 'transparent',
        'output_format': 'png',
        'partial_image_index': 0,
      });
      final completedLine = jsonEncode({
        'type': 'image_generation.completed',
        'b64_json': 'BBBB',
        'created_at': 2,
        'size': '1024x1024',
        'quality': 'high',
        'background': 'transparent',
        'output_format': 'png',
        'usage': {
          'total_tokens': 9,
          'input_tokens': 3,
          'output_tokens': 6,
          'input_tokens_details': {'text_tokens': 3, 'image_tokens': 0},
        },
      });

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode('data: $partialLine\n\n'),
            utf8.encode('data: $completedLine\n\n'),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final events = await client.images
          .generateStream(
            const ImageGenerationRequest(
              model: ImageModels.gptImage2,
              prompt: 'A red apple',
              partialImages: 1,
            ),
          )
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<ImageGenPartialImageEvent>());
      expect(events[1], isA<ImageGenCompletedEvent>());
      expect((events[1] as ImageGenCompletedEvent).usage.totalTokens, 9);

      final sentRequest = await requestCompleter.future as http.Request;
      final body = jsonDecode(sentRequest.body) as Map<String, dynamic>;
      expect(body['stream'], isTrue);
      expect(body['model'], 'gpt-image-2');
      expect(sentRequest.headers['Accept'], 'text/event-stream');

      client.close();
    });
  });
}
