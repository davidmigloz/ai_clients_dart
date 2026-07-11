import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionResponseFormat snake_case wire keys', () {
    test('InteractionTextResponseFormat uses mime_type + schema', () {
      final text =
          InteractionResponseFormat.fromJson({
                'type': 'text',
                'mime_type': 'application/json',
                'schema': {'type': 'object'},
              })
              as InteractionTextResponseFormat;
      expect(text.mimeType, isNotNull);
      expect(text.schema, {'type': 'object'});

      final json = text.toJson();
      expect(json['mime_type'], 'application/json');
      expect(json.containsKey('mimeType'), isFalse);
      expect(json['schema'], {'type': 'object'});
    });

    test(
      'InteractionAudioResponseFormat uses bit_rate/sample_rate/mime_type',
      () {
        final audio =
            InteractionResponseFormat.fromJson({
                  'type': 'audio',
                  'mime_type': 'audio/mp3',
                  'bit_rate': 128000,
                  'sample_rate': 24000,
                  'delivery': 'inline',
                })
                as InteractionAudioResponseFormat;
        expect(audio.bitRate, 128000);
        expect(audio.sampleRate, 24000);

        final json = audio.toJson();
        expect(json['bit_rate'], 128000);
        expect(json['sample_rate'], 24000);
        expect(json['mime_type'], 'audio/mp3');
        expect(json.containsKey('bitRate'), isFalse);
        expect(json.containsKey('mimeType'), isFalse);
      },
    );

    test(
      'InteractionImageResponseFormat uses aspect_ratio/image_size/mime_type',
      () {
        final image =
            InteractionResponseFormat.fromJson({
                  'type': 'image',
                  'aspect_ratio': '16:9',
                  'image_size': '2K',
                  'mime_type': 'image/jpeg',
                  'delivery': 'inline',
                })
                as InteractionImageResponseFormat;

        final json = image.toJson();
        expect(json['aspect_ratio'], '16:9');
        expect(json['image_size'], '2K');
        expect(json['mime_type'], 'image/jpeg');
        expect(json.containsKey('aspectRatio'), isFalse);
        expect(json.containsKey('imageSize'), isFalse);
      },
    );
  });

  group('InteractionResponseFormat delivery enum', () {
    test('audio/image delivery round-trips inline and uri', () {
      for (final delivery in ['inline', 'uri']) {
        final audio =
            InteractionResponseFormat.fromJson({
                  'type': 'audio',
                  'delivery': delivery,
                })
                as InteractionAudioResponseFormat;
        expect(audio.toJson()['delivery'], delivery);

        final image =
            InteractionResponseFormat.fromJson({
                  'type': 'image',
                  'delivery': delivery,
                })
                as InteractionImageResponseFormat;
        expect(image.toJson()['delivery'], delivery);
      }
    });
  });

  group('InteractionResponseFormat dispatch', () {
    test('dispatches the four typed variants', () {
      expect(
        InteractionResponseFormat.fromJson({'type': 'audio'}),
        isA<InteractionAudioResponseFormat>(),
      );
      expect(
        InteractionResponseFormat.fromJson({'type': 'text'}),
        isA<InteractionTextResponseFormat>(),
      );
      expect(
        InteractionResponseFormat.fromJson({'type': 'image'}),
        isA<InteractionImageResponseFormat>(),
      );
      expect(
        InteractionResponseFormat.fromJson({'type': 'video'}),
        isA<InteractionVideoResponseFormat>(),
      );
    });

    test('unknown type parses as UnknownInteractionResponseFormat', () {
      final unknown = InteractionResponseFormat.fromJson({
        'type': 'object',
        'properties': {
          'x': {'type': 'string'},
        },
      });
      expect(unknown, isA<UnknownInteractionResponseFormat>());
      expect((unknown as UnknownInteractionResponseFormat).type, 'object');
      expect(unknown.toJson()['properties'], {
        'x': {'type': 'string'},
      });
    });
  });

  group('InteractionVideoResponseFormat', () {
    test('round-trips aspect_ratio/delivery/duration/gcs_uri', () {
      final video =
          InteractionResponseFormat.fromJson({
                'type': 'video',
                'aspect_ratio': '16:9',
                'delivery': 'uri',
                'duration': '5s',
                'gcs_uri': 'gs://bucket/video.mp4',
              })
              as InteractionVideoResponseFormat;

      expect(
        video.aspectRatio,
        InteractionVideoResponseFormatAspectRatio.ratio16x9,
      );
      expect(video.delivery, InteractionVideoResponseFormatDelivery.uri);
      expect(video.duration, '5s');
      expect(video.gcsUri, 'gs://bucket/video.mp4');

      final json = video.toJson();
      expect(json['type'], 'video');
      expect(json['aspect_ratio'], '16:9');
      expect(json['delivery'], 'uri');
      expect(json['duration'], '5s');
      expect(json['gcs_uri'], 'gs://bucket/video.mp4');

      final restored =
          InteractionResponseFormat.fromJson(json)
              as InteractionVideoResponseFormat;
      expect(
        restored.aspectRatio,
        InteractionVideoResponseFormatAspectRatio.ratio16x9,
      );
    });

    test('omits null fields from JSON', () {
      const video = InteractionVideoResponseFormat();
      expect(video.toJson(), {'type': 'video'});
    });
  });

  group('InteractionResponseFormatConfig (single-or-list)', () {
    test('fromJson with single object -> InteractionSingleResponseFormat', () {
      final config = InteractionResponseFormatConfig.fromJson({
        'type': 'text',
        'mime_type': 'text/plain',
      });
      expect(config, isA<InteractionSingleResponseFormat>());
      expect(
        (config as InteractionSingleResponseFormat).format,
        isA<InteractionTextResponseFormat>(),
      );
      expect(config.toJson(), isA<Map<String, dynamic>>());
    });

    test('fromJson with list -> InteractionResponseFormatList', () {
      final config = InteractionResponseFormatConfig.fromJson([
        {'type': 'text'},
        {'type': 'audio'},
      ]);
      expect(config, isA<InteractionResponseFormatList>());
      final list = config as InteractionResponseFormatList;
      expect(list.formats, hasLength(2));
      expect(list.formats[0], isA<InteractionTextResponseFormat>());
      expect(list.formats[1], isA<InteractionAudioResponseFormat>());

      final json = config.toJson() as List<dynamic>;
      expect(json, hasLength(2));
      expect((json[0] as Map<String, dynamic>)['type'], 'text');
    });

    test('factory constructors', () {
      const single = InteractionResponseFormatConfig.single(
        InteractionTextResponseFormat(),
      );
      expect(single, isA<InteractionSingleResponseFormat>());

      const multi = InteractionResponseFormatConfig.list([
        InteractionTextResponseFormat(),
        InteractionImageResponseFormat(),
      ]);
      expect(multi, isA<InteractionResponseFormatList>());
      expect((multi as InteractionResponseFormatList).formats, hasLength(2));
    });

    test('round-trips through a single object', () {
      const original = InteractionResponseFormatConfig.single(
        InteractionTextResponseFormat(schema: {'type': 'object'}),
      );
      final restored = InteractionResponseFormatConfig.fromJson(
        original.toJson(),
      );
      expect(restored, isA<InteractionSingleResponseFormat>());
      final format = (restored as InteractionSingleResponseFormat).format;
      expect((format as InteractionTextResponseFormat).schema, {
        'type': 'object',
      });
    });
  });

  group('response_format wiring on models', () {
    test('CreateModelInteractionParams parses + serializes single format', () {
      final params = CreateModelInteractionParams.fromJson({
        'model': 'gemini-3.5-flash',
        'response_format': {
          'type': 'text',
          'mime_type': 'application/json',
          'schema': {'type': 'object'},
        },
      });
      expect(params.responseFormat, isA<InteractionSingleResponseFormat>());

      final body = params.toJson();
      final rf = body['response_format'] as Map<String, dynamic>;
      expect(rf['mime_type'], 'application/json');
      expect(rf['schema'], {'type': 'object'});
    });

    test('Interaction parses + copyWith preserves a list response_format', () {
      final interaction = Interaction.fromJson({
        'id': 'i_1',
        'status': 'completed',
        'response_format': [
          {'type': 'text'},
          {'type': 'image'},
        ],
      });
      expect(interaction.responseFormat, isA<InteractionResponseFormatList>());
      expect(
        (interaction.responseFormat! as InteractionResponseFormatList).formats,
        hasLength(2),
      );

      final copy = interaction.copyWith();
      expect(copy.responseFormat, isA<InteractionResponseFormatList>());

      final body = interaction.toJson();
      expect(body['response_format'], isA<List<dynamic>>());
    });

    test('CreateAgentInteractionParams round-trips response_format', () {
      const params = CreateAgentInteractionParams(
        agent: 'deep-research',
        responseFormat: InteractionResponseFormatConfig.single(
          InteractionTextResponseFormat(schema: {'type': 'object'}),
        ),
      );
      final restored = CreateAgentInteractionParams.fromJson(params.toJson());
      expect(restored.responseFormat, isA<InteractionSingleResponseFormat>());
    });
  });
}
