import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Responses image-generation tool contract', () {
    for (final mask in [
      const ImageGenerationMask(imageUrl: 'https://example.com/mask.png'),
      const ImageGenerationMask(fileId: 'file-mask'),
    ]) {
      test(
        'factory and complete request round-trip a ${mask.toJson()} mask',
        () {
          final tool = ResponseTool.imageGeneration(
            action: 'edit',
            inputFidelity: ImageInputFidelity.high,
            inputImageMask: mask,
            moderation: ImageModerationLevel.low,
            outputCompression: 72,
            outputFormat: 'webp',
            partialImages: 2,
            background: 'transparent',
            model: 'gpt-image-1.5',
            quality: 'high',
            size: '1536x1024',
          );
          final json = tool.toJson();
          expect(json, {
            'type': 'image_generation',
            'action': 'edit',
            'input_fidelity': 'high',
            'input_image_mask': mask.toJson(),
            'moderation': 'low',
            'output_compression': 72,
            'output_format': 'webp',
            'partial_images': 2,
            'background': 'transparent',
            'model': 'gpt-image-1.5',
            'quality': 'high',
            'size': '1536x1024',
          });
          final restored = ResponseTool.fromJson(json);
          expect(restored, tool);
          expect(restored.hashCode, tool.hashCode);
          final request = CreateResponseRequest(
            model: 'fixture',
            input: const ResponseInput.text('Edit this image'),
            tools: [tool],
          );
          final decoded = CreateResponseRequest.fromJson(request.toJson());
          expect(decoded.tools!.single, tool);
          expect(decoded.toJson()['tools'], [json]);
        },
      );
    }
    test(
      'omitted and nullable options normalize without invented defaults',
      () {
        expect(const ImageGenerationTool().toJson(), {
          'type': 'image_generation',
        });
        final json = {
          'type': 'image_generation',
          'action': null,
          'input_fidelity': null,
          'input_image_mask': null,
          'moderation': null,
          'output_compression': null,
        };
        expect(ResponseTool.fromJson(json).toJson(), {
          'type': 'image_generation',
        });
        expect(
          const ImageGenerationTool(
            moderation: ImageModerationLevel.auto,
          ).toJson()['moderation'],
          'auto',
        );
      },
    );
    test('old incorrect wire types and invalid masks fail at decoding', () {
      for (final extra in <Map<String, dynamic>>[
        {'moderation': true},
        {'output_compression': '72'},
        {'output_compression': 1.5},
        {'input_image_mask': 'file-mask'},
        {
          'input_image_mask': {'file_id': 42},
        },
        {'input_fidelity': false},
        {'action': true},
      ]) {
        expect(
          () => ResponseTool.fromJson({'type': 'image_generation', ...extra}),
          throwsA(isA<FormatException>()),
        );
      }
      expect(
        () => ImageGenerationTool.fromJson(const {'type': 'other'}),
        throwsFormatException,
      );
    });
    test('new fields participate in value identity', () {
      const base = ImageGenerationTool(
        action: 'generate',
        inputFidelity: ImageInputFidelity.low,
      );
      expect(
        base,
        isNot(
          const ImageGenerationTool(
            action: 'edit',
            inputFidelity: ImageInputFidelity.low,
          ),
        ),
      );
      expect(
        base,
        isNot(
          const ImageGenerationTool(
            action: 'generate',
            inputFidelity: ImageInputFidelity.high,
          ),
        ),
      );
      expect(base.toString(), contains('inputFidelity:'));
      expect(base.toString(), contains('action: generate'));
    });
    test(
      'mask optional fields follow Responses rather than Images edit constraints',
      () {
        for (final json in <Map<String, dynamic>>[
          {},
          {'image_url': 'url', 'file_id': 'file'},
        ]) {
          final mask = ImageGenerationMask.fromJson(json);
          expect(mask.toJson(), json);
          expect(ImageGenerationMask.fromJson(mask.toJson()), mask);
        }
      },
    );
    test('unknown enum request values are never rewritten to unknown', () {
      for (final field in ['moderation', 'input_fidelity']) {
        expect(
          () => ImageGenerationTool.fromJson({
            'type': 'image_generation',
            field: 'future',
          }),
          throwsFormatException,
        );
      }
      expect(
        () => const ImageGenerationTool(
          moderation: ImageModerationLevel.unknown,
        ).toJson(),
        throwsArgumentError,
      );
      expect(
        () => const ImageGenerationTool(
          inputFidelity: ImageInputFidelity.unknown,
        ).toJson(),
        throwsArgumentError,
      );
    });
  });
}
