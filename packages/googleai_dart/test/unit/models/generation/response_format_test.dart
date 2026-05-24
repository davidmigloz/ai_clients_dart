import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Main spec ResponseFormatConfig', () {
    test('AudioResponseFormat round-trips with proto enum wire values', () {
      const audio = AudioResponseFormat(
        mimeType: AudioResponseFormatMimeType.audioMp3,
        bitRate: 128000,
        sampleRate: 24000,
        delivery: AudioResponseFormatDelivery.inline,
      );
      final json = audio.toJson();
      expect(json['mimeType'], 'AUDIO_MP3');
      expect(json['bitRate'], 128000);
      expect(json['sampleRate'], 24000);
      expect(json['delivery'], 'INLINE');

      final restored = AudioResponseFormat.fromJson(json);
      expect(restored.mimeType, AudioResponseFormatMimeType.audioMp3);
      expect(restored.delivery, AudioResponseFormatDelivery.inline);
      expect(restored.bitRate, 128000);
    });

    test('ImageResponseFormat round-trips', () {
      const image = ImageResponseFormat(
        mimeType: ImageResponseFormatMimeType.imageJpeg,
        aspectRatio: ImageResponseFormatAspectRatio.sixteenByNine,
        imageSize: ImageResponseFormatImageSize.twoK,
        delivery: ImageResponseFormatDelivery.uri,
      );
      final json = image.toJson();
      expect(json['mimeType'], 'IMAGE_JPEG');
      expect(json['aspectRatio'], 'ASPECT_RATIO_SIXTEEN_BY_NINE');
      expect(json['imageSize'], 'IMAGE_SIZE_TWO_K');
      expect(json['delivery'], 'URI');

      final restored = ImageResponseFormat.fromJson(json);
      expect(
        restored.aspectRatio,
        ImageResponseFormatAspectRatio.sixteenByNine,
      );
      expect(restored.imageSize, ImageResponseFormatImageSize.twoK);
    });

    test('TextResponseFormat round-trips with schema', () {
      const text = TextResponseFormat(
        mimeType: TextResponseFormatMimeType.applicationJson,
        schema: {'type': 'object'},
      );
      final json = text.toJson();
      expect(json['mimeType'], 'APPLICATION_JSON');
      expect(json['schema'], {'type': 'object'});

      final restored = TextResponseFormat.fromJson(json);
      expect(restored.mimeType, TextResponseFormatMimeType.applicationJson);
      expect(restored.schema, {'type': 'object'});
    });

    test('unknown enum value falls back to unspecified', () {
      final audio = AudioResponseFormat.fromJson({'mimeType': 'AUDIO_FUTURE'});
      expect(audio.mimeType, AudioResponseFormatMimeType.unspecified);
    });

    test(
      'ResponseFormatConfig aggregates text/audio/image and round-trips',
      () {
        const config = ResponseFormatConfig(
          text: TextResponseFormat(
            mimeType: TextResponseFormatMimeType.textPlain,
          ),
          audio: AudioResponseFormat(
            mimeType: AudioResponseFormatMimeType.audioWav,
          ),
          image: ImageResponseFormat(
            mimeType: ImageResponseFormatMimeType.imageJpeg,
          ),
        );
        final json = config.toJson();
        expect((json['text'] as Map)['mimeType'], 'TEXT_PLAIN');
        expect((json['audio'] as Map)['mimeType'], 'AUDIO_WAV');
        expect((json['image'] as Map)['mimeType'], 'IMAGE_JPEG');

        final restored = ResponseFormatConfig.fromJson(json);
        expect(restored.text, isNotNull);
        expect(restored.audio, isNotNull);
        expect(restored.image, isNotNull);
      },
    );

    test('copyWith replaces a single sub-format', () {
      const config = ResponseFormatConfig(
        text: TextResponseFormat(
          mimeType: TextResponseFormatMimeType.textPlain,
        ),
      );
      final updated = config.copyWith(
        audio: const AudioResponseFormat(
          mimeType: AudioResponseFormatMimeType.audioMp3,
        ),
      );
      expect(updated.text, isNotNull);
      expect(updated.audio?.mimeType, AudioResponseFormatMimeType.audioMp3);
    });
  });

  group('GenerationConfig.responseFormat', () {
    test('serializes and round-trips responseFormat', () {
      const config = GenerationConfig(
        responseFormat: ResponseFormatConfig(
          text: TextResponseFormat(
            mimeType: TextResponseFormatMimeType.applicationJson,
          ),
        ),
      );
      final json = config.toJson();
      expect(json.containsKey('responseFormat'), isTrue);

      final restored = GenerationConfig.fromJson(json);
      expect(restored.responseFormat, isNotNull);
      expect(
        restored.responseFormat!.text!.mimeType,
        TextResponseFormatMimeType.applicationJson,
      );
    });

    test('omits responseFormat when null', () {
      const config = GenerationConfig(temperature: 0.5);
      expect(config.toJson().containsKey('responseFormat'), isFalse);
    });

    test('copyWith preserves responseFormat', () {
      const config = GenerationConfig(
        responseFormat: ResponseFormatConfig(
          image: ImageResponseFormat(
            imageSize: ImageResponseFormatImageSize.fourK,
          ),
        ),
      );
      final copy = config.copyWith(temperature: 0.1);
      expect(
        copy.responseFormat?.image?.imageSize,
        ImageResponseFormatImageSize.fourK,
      );
    });
  });
}
