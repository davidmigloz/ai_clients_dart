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
  });

  group('ImageQuality', () {
    test('parses all values correctly', () {
      expect(ImageQuality.fromJson('standard'), ImageQuality.standard);
      expect(ImageQuality.fromJson('hd'), ImageQuality.hd);
    });

    test('toJson returns correct values', () {
      expect(ImageQuality.standard.toJson(), 'standard');
      expect(ImageQuality.hd.toJson(), 'hd');
    });
  });

  group('ImageSize', () {
    test('parses all values correctly', () {
      expect(ImageSize.fromJson('256x256'), ImageSize.size256x256);
      expect(ImageSize.fromJson('512x512'), ImageSize.size512x512);
      expect(ImageSize.fromJson('1024x1024'), ImageSize.size1024x1024);
      expect(ImageSize.fromJson('1792x1024'), ImageSize.size1792x1024);
      expect(ImageSize.fromJson('1024x1792'), ImageSize.size1024x1792);
    });

    test('toJson returns correct values', () {
      expect(ImageSize.size256x256.toJson(), '256x256');
      expect(ImageSize.size1024x1024.toJson(), '1024x1024');
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
