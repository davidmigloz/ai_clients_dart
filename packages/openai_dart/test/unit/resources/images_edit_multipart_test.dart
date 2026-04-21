import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Images Edit Multipart Fields', () {
    test('emits all GPT Image 2 fields in multipart body', () async {
      String? body;

      final mockClient = MockClient((request) async {
        body = request.body;
        return http.Response(
          '{"created":1776808255,"data":[{"b64_json":"xxx"}]}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.images.edit(
        ImageEditRequest(
          image: Uint8List.fromList([1, 2, 3, 4]),
          imageFilename: 'original.png',
          prompt: 'Add a rainbow',
          model: ImageModels.gptImage2,
          background: ImageBackground.transparent,
          inputFidelity: ImageInputFidelity.high,
          quality: ImageQuality.high,
          outputFormat: ImageOutputFormat.webp,
          outputCompression: 75,
          moderation: ImageModerationLevel.low,
          stream: true,
          partialImages: 2,
          size: ImageSize.size1536x1024,
          n: 1,
        ),
      );

      expect(body, isNotNull);
      expect(body, contains('name="model"'));
      expect(body, contains('gpt-image-2'));
      expect(body, contains('name="background"'));
      expect(body, contains('\r\ntransparent\r\n'));
      expect(body, contains('name="input_fidelity"'));
      expect(body, contains('\r\nhigh\r\n'));
      expect(body, contains('name="quality"'));
      expect(body, contains('name="output_format"'));
      expect(body, contains('\r\nwebp\r\n'));
      expect(body, contains('name="output_compression"'));
      expect(body, contains('\r\n75\r\n'));
      expect(body, contains('name="moderation"'));
      expect(body, contains('\r\nlow\r\n'));
      expect(body, contains('name="stream"'));
      expect(body, contains('\r\ntrue\r\n'));
      expect(body, contains('name="partial_images"'));
      expect(body, contains('\r\n2\r\n'));
      expect(body, contains('name="size"'));
      expect(body, contains('\r\n1536x1024\r\n'));

      client.close();
    });

    test('omits new fields when unset', () async {
      String? body;

      final mockClient = MockClient((request) async {
        body = request.body;
        return http.Response(
          '{"created":0,"data":[{"url":"https://example.com/x.png"}]}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.images.edit(
        ImageEditRequest(
          image: Uint8List.fromList([1, 2, 3, 4]),
          imageFilename: 'original.png',
          prompt: 'edit',
          model: 'dall-e-2',
        ),
      );

      expect(body, isNotNull);
      for (final key in const [
        'background',
        'input_fidelity',
        'output_format',
        'output_compression',
        'moderation',
        'stream',
        'partial_images',
        'quality',
      ]) {
        expect(
          body,
          isNot(contains('name="$key"')),
          reason: '$key should not be present when unset',
        );
      }

      client.close();
    });
  });
}
