import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ImageGenerationRequest', () {
    test('creates with minimal parameters', () {
      const request = ImageGenerationRequest(prompt: 'A beautiful sunset');

      expect(request.prompt, 'A beautiful sunset');
      expect(request.model, isNull);
      expect(request.n, isNull);
    });

    test('creates with all parameters', () {
      const request = ImageGenerationRequest(
        prompt: 'A cat wearing a hat',
        model: 'dall-e-3',
        n: 1,
        quality: ImageQuality.hd,
        size: ImageSize.size1024x1024,
        style: ImageStyle.vivid,
        responseFormat: ImageResponseFormat.url,
        user: 'user-123',
      );

      expect(request.prompt, 'A cat wearing a hat');
      expect(request.model, 'dall-e-3');
      expect(request.n, 1);
      expect(request.quality, ImageQuality.hd);
      expect(request.size, ImageSize.size1024x1024);
      expect(request.style, ImageStyle.vivid);
    });

    test('toJson serializes correctly', () {
      const request = ImageGenerationRequest(
        prompt: 'A dog',
        model: 'dall-e-3',
        size: ImageSize.size1792x1024,
      );

      final json = request.toJson();

      expect(json['prompt'], 'A dog');
      expect(json['model'], 'dall-e-3');
      expect(json['size'], '1792x1024');
    });

    test('toJson excludes null values', () {
      const request = ImageGenerationRequest(prompt: 'Simple prompt');

      final json = request.toJson();

      expect(json['prompt'], 'Simple prompt');
      expect(json.containsKey('model'), false);
      expect(json.containsKey('n'), false);
      expect(json.containsKey('quality'), false);
    });

    test('copyWith creates modified copy', () {
      const original = ImageGenerationRequest(
        prompt: 'Original',
        model: 'dall-e-2',
      );

      final modified = original.copyWith(
        prompt: 'Modified',
        size: ImageSize.size512x512,
      );

      expect(modified.prompt, 'Modified');
      expect(modified.model, 'dall-e-2'); // Preserved
      expect(modified.size, ImageSize.size512x512);
    });

    test('serializes GPT Image 2 fields', () {
      const request = ImageGenerationRequest(
        prompt: 'A red apple',
        model: ImageModels.gptImage2,
        size: ImageSize.size1536x1024,
        quality: ImageQuality.high,
        background: ImageBackground.transparent,
        moderation: ImageModerationLevel.low,
        outputFormat: ImageOutputFormat.webp,
        outputCompression: 80,
        stream: true,
        partialImages: 3,
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-image-2');
      expect(json['size'], '1536x1024');
      expect(json['quality'], 'high');
      expect(json['background'], 'transparent');
      expect(json['moderation'], 'low');
      expect(json['output_format'], 'webp');
      expect(json['output_compression'], 80);
      expect(json['stream'], true);
      expect(json['partial_images'], 3);
    });

    test('fromJson round-trips GPT Image 2 fields', () {
      final json = {
        'prompt': 'A red apple',
        'model': 'gpt-image-2',
        'size': '1024x1536',
        'quality': 'auto',
        'background': 'opaque',
        'moderation': 'auto',
        'output_format': 'png',
        'output_compression': 50,
        'stream': false,
        'partial_images': 0,
      };

      final request = ImageGenerationRequest.fromJson(json);

      expect(request.model, 'gpt-image-2');
      expect(request.size, ImageSize.size1024x1536);
      expect(request.quality, ImageQuality.auto);
      expect(request.background, ImageBackground.opaque);
      expect(request.moderation, ImageModerationLevel.auto);
      expect(request.outputFormat, ImageOutputFormat.png);
      expect(request.outputCompression, 50);
      expect(request.stream, false);
      expect(request.partialImages, 0);
    });

    test('omits new fields when unset', () {
      const request = ImageGenerationRequest(prompt: 'plain');
      final json = request.toJson();
      for (final key in const [
        'background',
        'moderation',
        'output_format',
        'output_compression',
        'stream',
        'partial_images',
      ]) {
        expect(json.containsKey(key), isFalse, reason: 'key $key');
      }
    });

    test('equality includes all fields', () {
      const a = ImageGenerationRequest(
        prompt: 'p',
        background: ImageBackground.transparent,
        outputFormat: ImageOutputFormat.webp,
      );
      const b = ImageGenerationRequest(
        prompt: 'p',
        background: ImageBackground.transparent,
        outputFormat: ImageOutputFormat.webp,
      );
      const c = ImageGenerationRequest(
        prompt: 'p',
        background: ImageBackground.opaque,
        outputFormat: ImageOutputFormat.webp,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('ImageEditRequest', () {
    final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

    test('copyWith overrides specified fields only', () {
      final original = ImageEditRequest(
        image: imageBytes,
        imageFilename: 'a.png',
        prompt: 'p',
        inputFidelity: ImageInputFidelity.low,
        quality: ImageQuality.medium,
      );
      final modified = original.copyWith(
        stream: true,
        quality: ImageQuality.high,
      );
      expect(modified.stream, isTrue);
      expect(modified.quality, ImageQuality.high);
      expect(modified.inputFidelity, ImageInputFidelity.low); // preserved
      expect(modified.prompt, 'p'); // preserved
    });

    test('== distinguishes requests that differ only in maskFilename', () {
      final a = ImageEditRequest(
        image: imageBytes,
        imageFilename: 'a.png',
        prompt: 'p',
        maskFilename: 'maskA.png',
      );
      final b = ImageEditRequest(
        image: imageBytes,
        imageFilename: 'a.png',
        prompt: 'p',
        maskFilename: 'maskB.png',
      );
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  group('ImageResponse', () {
    test('fromJson parses response correctly', () {
      final json = {
        'created': 1677649420,
        'data': [
          {
            'url': 'https://example.com/image.png',
            'revised_prompt': 'A beautiful sunset over the ocean',
          },
        ],
      };

      final response = ImageResponse.fromJson(json);

      expect(response.created, 1677649420);
      expect(response.data.length, 1);
      expect(response.data.first.url, 'https://example.com/image.png');
      expect(
        response.data.first.revisedPrompt,
        'A beautiful sunset over the ocean',
      );
    });

    test('firstUrl getter returns first image URL', () {
      final json = {
        'created': 1677649420,
        'data': [
          {'url': 'https://example.com/first.png'},
          {'url': 'https://example.com/second.png'},
        ],
      };

      final response = ImageResponse.fromJson(json);
      expect(response.firstUrl, 'https://example.com/first.png');
    });

    test('firstBase64 getter returns first base64 data', () {
      final json = {
        'created': 1677649420,
        'data': [
          {'b64_json': 'base64encodeddata'},
        ],
      };

      final response = ImageResponse.fromJson(json);
      expect(response.firstBase64, 'base64encodeddata');
    });

    test('parses GPT Image 2 payload with usage + metadata', () {
      final json = {
        'created': 1776808255,
        'background': 'opaque',
        'size': '1024x1024',
        'quality': 'low',
        'output_format': 'png',
        'usage': {
          'total_tokens': 209,
          'input_tokens': 13,
          'input_tokens_details': {'text_tokens': 13, 'image_tokens': 0},
          'output_tokens': 196,
          'output_tokens_details': {'text_tokens': 0, 'image_tokens': 196},
        },
        'data': [
          {'b64_json': 'iVBORw0KGgo='},
        ],
      };

      final response = ImageResponse.fromJson(json);

      expect(response.created, 1776808255);
      expect(response.background, ImageBackground.opaque);
      expect(response.size, ImageSize.size1024x1024);
      expect(response.quality, ImageQuality.low);
      expect(response.outputFormat, ImageOutputFormat.png);

      final usage = response.usage;
      expect(usage, isNotNull);
      expect(usage!.totalTokens, 209);
      expect(usage.inputTokens, 13);
      expect(usage.outputTokens, 196);
      expect(usage.inputTokensDetails.textTokens, 13);
      expect(usage.inputTokensDetails.imageTokens, 0);
      expect(usage.outputTokensDetails?.textTokens, 0);
      expect(usage.outputTokensDetails?.imageTokens, 196);

      // Round-trip: toJson should emit the new fields and re-parse.
      final parsed = ImageResponse.fromJson(response.toJson());
      expect(parsed, equals(response));
      expect(parsed.data, hasLength(1));
      expect(parsed.data.first.b64Json, 'iVBORw0KGgo=');
      expect(parsed.data.first.revisedPrompt, isNull);
    });

    test('fromJson throws FormatException when data is missing', () {
      expect(
        () => ImageResponse.fromJson(const {'created': 0}),
        throwsA(isA<FormatException>()),
      );
    });

    test('ImageResponse == compares data contents, not just length', () {
      const a = ImageResponse(
        created: 1,
        data: [GeneratedImage(b64Json: 'AAAA')],
      );
      const b = ImageResponse(
        created: 1,
        data: [GeneratedImage(b64Json: 'BBBB')],
      );
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('parses minimal DALL-E response (no usage, no metadata)', () {
      final json = {
        'created': 1677649420,
        'data': [
          {'url': 'https://example.com/image.png'},
        ],
      };

      final response = ImageResponse.fromJson(json);

      expect(response.data.length, 1);
      expect(response.background, isNull);
      expect(response.outputFormat, isNull);
      expect(response.quality, isNull);
      expect(response.size, isNull);
      expect(response.usage, isNull);
    });

    test('ImagesUsage without output_tokens_details parses', () {
      final usage = ImagesUsage.fromJson(const {
        'total_tokens': 50,
        'input_tokens': 10,
        'input_tokens_details': {'text_tokens': 10, 'image_tokens': 0},
        'output_tokens': 40,
      });
      expect(usage.outputTokensDetails, isNull);
      expect(usage.totalTokens, 50);
    });
  });

  group('ImageReference', () {
    test('fromJson throws when both imageUrl and fileId are present', () {
      expect(
        () => ImageReference.fromJson(const {
          'image_url': 'https://example.com/img.png',
          'file_id': 'file_123',
        }),
        throwsFormatException,
      );
    });

    test('fromJson throws when neither imageUrl nor fileId is present', () {
      expect(() => ImageReference.fromJson(const {}), throwsFormatException);
    });

    test('fromJson parses imageUrl correctly', () {
      final ref = ImageReference.fromJson(const {
        'image_url': 'https://example.com/img.png',
      });
      expect(ref.imageUrl, equals('https://example.com/img.png'));
      expect(ref.fileId, isNull);
    });

    test('fromJson parses fileId correctly', () {
      final ref = ImageReference.fromJson(const {'file_id': 'file_123'});
      expect(ref.fileId, equals('file_123'));
      expect(ref.imageUrl, isNull);
    });
  });

  group('ImageEditJsonRequest', () {
    test('serializes JSON edit payload', () {
      const request = ImageEditJsonRequest(
        model: 'gpt-image-1.5',
        images: [ImageReference.url('https://example.com/source.png')],
        prompt: 'Add a watercolor effect',
        quality: ImageEditJsonQuality.high,
        size: ImageEditJsonSize.size1024x1024,
        outputFormat: ImageOutputFormat.png,
      );

      final json = request.toJson();
      final images = json['images'] as List<dynamic>;
      final firstImage = images.first as Map<String, dynamic>;

      expect(json['model'], equals('gpt-image-1.5'));
      expect(firstImage['image_url'], isNotNull);
      expect(json['prompt'], equals('Add a watercolor effect'));
      expect(json['quality'], equals('high'));
      expect(json['size'], equals('1024x1024'));
      expect(json['output_format'], equals('png'));
    });

    test('deserializes JSON edit payload', () {
      final request = ImageEditJsonRequest.fromJson(const {
        'images': [
          {'file_id': 'file_123'},
        ],
        'prompt': 'Edit this image',
        'background': 'transparent',
      });

      expect(request.images.first.fileId, equals('file_123'));
      expect(request.prompt, equals('Edit this image'));
      expect(request.background, equals(ImageBackground.transparent));
    });
  });

  group('GeneratedImage', () {
    test('parses URL response', () {
      final json = {'url': 'https://example.com/image.png'};

      final image = GeneratedImage.fromJson(json);

      expect(image.url, 'https://example.com/image.png');
      expect(image.b64Json, isNull);
      expect(image.hasUrl, true);
      expect(image.hasBase64, false);
    });

    test('parses base64 response', () {
      final json = {'b64_json': 'SGVsbG8gV29ybGQ='};

      final image = GeneratedImage.fromJson(json);

      expect(image.url, isNull);
      expect(image.b64Json, 'SGVsbG8gV29ybGQ=');
      expect(image.hasUrl, false);
      expect(image.hasBase64, true);
    });

    test('parses revised prompt', () {
      final json = {
        'url': 'https://example.com/image.png',
        'revised_prompt': 'The revised prompt text',
      };

      final image = GeneratedImage.fromJson(json);
      expect(image.revisedPrompt, 'The revised prompt text');
    });

    test('== distinguishes images that differ only in revisedPrompt', () {
      const a = GeneratedImage(
        url: 'https://example.com/image.png',
        revisedPrompt: 'A',
      );
      const b = GeneratedImage(
        url: 'https://example.com/image.png',
        revisedPrompt: 'B',
      );
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  group('ImageQuality', () {
    test('parses all values correctly', () {
      expect(ImageQuality.fromJson('standard'), ImageQuality.standard);
      expect(ImageQuality.fromJson('hd'), ImageQuality.hd);
      expect(ImageQuality.fromJson('low'), ImageQuality.low);
      expect(ImageQuality.fromJson('medium'), ImageQuality.medium);
      expect(ImageQuality.fromJson('high'), ImageQuality.high);
      expect(ImageQuality.fromJson('auto'), ImageQuality.auto);
    });

    test('toJson returns correct values', () {
      expect(ImageQuality.standard.toJson(), 'standard');
      expect(ImageQuality.hd.toJson(), 'hd');
      expect(ImageQuality.low.toJson(), 'low');
      expect(ImageQuality.medium.toJson(), 'medium');
      expect(ImageQuality.high.toJson(), 'high');
      expect(ImageQuality.auto.toJson(), 'auto');
    });
  });

  group('ImageSize', () {
    test('parses all values correctly', () {
      expect(ImageSize.fromJson('256x256'), ImageSize.size256x256);
      expect(ImageSize.fromJson('512x512'), ImageSize.size512x512);
      expect(ImageSize.fromJson('1024x1024'), ImageSize.size1024x1024);
      expect(ImageSize.fromJson('1792x1024'), ImageSize.size1792x1024);
      expect(ImageSize.fromJson('1024x1792'), ImageSize.size1024x1792);
      expect(ImageSize.fromJson('1536x1024'), ImageSize.size1536x1024);
      expect(ImageSize.fromJson('1024x1536'), ImageSize.size1024x1536);
      expect(ImageSize.fromJson('auto'), ImageSize.auto);
    });

    test('toJson returns correct values', () {
      expect(ImageSize.size256x256.toJson(), '256x256');
      expect(ImageSize.size1024x1024.toJson(), '1024x1024');
      expect(ImageSize.size1536x1024.toJson(), '1536x1024');
      expect(ImageSize.size1024x1536.toJson(), '1024x1536');
      expect(ImageSize.auto.toJson(), 'auto');
    });
  });

  group('Image common enums', () {
    test('ImageBackground round-trips', () {
      for (final v in ImageBackground.values) {
        expect(ImageBackground.fromJson(v.toJson()), v);
      }
    });

    test('ImageOutputFormat round-trips', () {
      for (final v in ImageOutputFormat.values) {
        expect(ImageOutputFormat.fromJson(v.toJson()), v);
      }
    });

    test('ImageModerationLevel round-trips', () {
      for (final v in ImageModerationLevel.values) {
        expect(ImageModerationLevel.fromJson(v.toJson()), v);
      }
    });

    test('ImageInputFidelity round-trips', () {
      for (final v in ImageInputFidelity.values) {
        expect(ImageInputFidelity.fromJson(v.toJson()), v);
      }
    });
  });

  group('ImageModels constants', () {
    test('exposes well-known model ids', () {
      expect(ImageModels.gptImage2, 'gpt-image-2');
      expect(ImageModels.gptImage15, 'gpt-image-1.5');
      expect(ImageModels.gptImage1, 'gpt-image-1');
      expect(ImageModels.gptImage1Mini, 'gpt-image-1-mini');
      expect(ImageModels.chatgptImageLatest, 'chatgpt-image-latest');
      expect(ImageModels.dallE3, 'dall-e-3');
      expect(ImageModels.dallE2, 'dall-e-2');
    });
  });

  group('ImageStyle', () {
    test('parses all values correctly', () {
      expect(ImageStyle.fromJson('vivid'), ImageStyle.vivid);
      expect(ImageStyle.fromJson('natural'), ImageStyle.natural);
    });

    test('toJson returns correct values', () {
      expect(ImageStyle.vivid.toJson(), 'vivid');
      expect(ImageStyle.natural.toJson(), 'natural');
    });
  });

  group('ImageResponseFormat', () {
    test('parses all values correctly', () {
      expect(ImageResponseFormat.fromJson('url'), ImageResponseFormat.url);
      expect(
        ImageResponseFormat.fromJson('b64_json'),
        ImageResponseFormat.b64Json,
      );
    });

    test('toJson returns correct values', () {
      expect(ImageResponseFormat.url.toJson(), 'url');
      expect(ImageResponseFormat.b64Json.toJson(), 'b64_json');
    });
  });
}
