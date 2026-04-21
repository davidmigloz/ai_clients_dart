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
      // Scoped field=value assertions — guard against a value matching
      // a different part (e.g. "high" is emitted for both quality and
      // input_fidelity, so a bare contains() check isn't sufficient).
      void expectMultipartField(String name, String value) {
        expect(
          body,
          matches(
            RegExp(
              'name="${RegExp.escape(name)}"\\r\\n\\r\\n'
              '${RegExp.escape(value)}\\r\\n',
            ),
          ),
          reason: 'multipart field $name should carry value "$value"',
        );
      }

      expectMultipartField('model', 'gpt-image-2');
      expectMultipartField('background', 'transparent');
      expectMultipartField('input_fidelity', 'high');
      expectMultipartField('quality', 'high');
      expectMultipartField('output_format', 'webp');
      expectMultipartField('output_compression', '75');
      expectMultipartField('moderation', 'low');
      expectMultipartField('stream', 'true');
      expectMultipartField('partial_images', '2');
      expectMultipartField('size', '1536x1024');

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
