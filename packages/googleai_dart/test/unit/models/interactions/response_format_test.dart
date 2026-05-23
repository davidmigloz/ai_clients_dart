import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseFormat snake_case wire keys', () {
    test('TextResponseFormat uses mime_type + schema', () {
      final text =
          ResponseFormat.fromJson({
                'type': 'text',
                'mime_type': 'application/json',
                'schema': {'type': 'object'},
              })
              as TextResponseFormat;
      expect(text.mimeType, isNotNull);
      expect(text.schema, {'type': 'object'});

      final json = text.toJson();
      expect(json['mime_type'], 'application/json');
      expect(json.containsKey('mimeType'), isFalse);
      expect(json['schema'], {'type': 'object'});
    });

    test('AudioResponseFormat uses bit_rate/sample_rate/mime_type', () {
      final audio =
          ResponseFormat.fromJson({
                'type': 'audio',
                'mime_type': 'audio/mp3',
                'bit_rate': 128000,
                'sample_rate': 24000,
                'delivery': 'inline',
              })
              as AudioResponseFormat;
      expect(audio.bitRate, 128000);
      expect(audio.sampleRate, 24000);

      final json = audio.toJson();
      expect(json['bit_rate'], 128000);
      expect(json['sample_rate'], 24000);
      expect(json['mime_type'], 'audio/mp3');
      expect(json.containsKey('bitRate'), isFalse);
      expect(json.containsKey('mimeType'), isFalse);
    });

    test('ImageResponseFormat uses aspect_ratio/image_size/mime_type', () {
      final image =
          ResponseFormat.fromJson({
                'type': 'image',
                'aspect_ratio': '16:9',
                'image_size': '2K',
                'mime_type': 'image/jpeg',
                'delivery': 'inline',
              })
              as ImageResponseFormat;

      final json = image.toJson();
      expect(json['aspect_ratio'], '16:9');
      expect(json['image_size'], '2K');
      expect(json['mime_type'], 'image/jpeg');
      expect(json.containsKey('aspectRatio'), isFalse);
      expect(json.containsKey('imageSize'), isFalse);
    });
  });

  group('ResponseFormat dispatch', () {
    test('dispatches the four typed variants', () {
      expect(
        ResponseFormat.fromJson({'type': 'audio'}),
        isA<AudioResponseFormat>(),
      );
      expect(
        ResponseFormat.fromJson({'type': 'text'}),
        isA<TextResponseFormat>(),
      );
      expect(
        ResponseFormat.fromJson({'type': 'image'}),
        isA<ImageResponseFormat>(),
      );
      expect(
        ResponseFormat.fromJson({'type': 'video'}),
        isA<VideoResponseFormat>(),
      );
    });

    test('unknown type parses as UnknownResponseFormat (raw preserved)', () {
      final unknown = ResponseFormat.fromJson({
        'type': 'object',
        'properties': {
          'x': {'type': 'string'},
        },
      });
      expect(unknown, isA<UnknownResponseFormat>());
      expect((unknown as UnknownResponseFormat).type, 'object');
      expect(unknown.toJson()['properties'], {
        'x': {'type': 'string'},
      });
    });
  });

  group('ResponseFormatConfig (single-or-list)', () {
    test('fromJson with single object -> SingleResponseFormat', () {
      final config = ResponseFormatConfig.fromJson({
        'type': 'text',
        'mime_type': 'text/plain',
      });
      expect(config, isA<SingleResponseFormat>());
      expect(
        (config as SingleResponseFormat).format,
        isA<TextResponseFormat>(),
      );
      expect(config.toJson(), isA<Map<String, dynamic>>());
    });

    test('fromJson with list -> ResponseFormatList', () {
      final config = ResponseFormatConfig.fromJson([
        {'type': 'text'},
        {'type': 'audio'},
      ]);
      expect(config, isA<ResponseFormatList>());
      final list = config as ResponseFormatList;
      expect(list.formats, hasLength(2));
      expect(list.formats[0], isA<TextResponseFormat>());
      expect(list.formats[1], isA<AudioResponseFormat>());

      final json = config.toJson() as List<dynamic>;
      expect(json, hasLength(2));
      expect((json[0] as Map<String, dynamic>)['type'], 'text');
    });

    test('factory constructors', () {
      const single = ResponseFormatConfig.single(TextResponseFormat());
      expect(single, isA<SingleResponseFormat>());

      const multi = ResponseFormatConfig.list([
        TextResponseFormat(),
        VideoResponseFormat(),
      ]);
      expect(multi, isA<ResponseFormatList>());
      expect((multi as ResponseFormatList).formats, hasLength(2));
    });

    test('round-trips through a single object', () {
      const original = ResponseFormatConfig.single(
        TextResponseFormat(schema: {'type': 'object'}),
      );
      final restored = ResponseFormatConfig.fromJson(original.toJson());
      expect(restored, isA<SingleResponseFormat>());
      final format = (restored as SingleResponseFormat).format;
      expect((format as TextResponseFormat).schema, {'type': 'object'});
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
      expect(params.responseFormat, isA<SingleResponseFormat>());

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
      expect(interaction.responseFormat, isA<ResponseFormatList>());
      expect(
        (interaction.responseFormat! as ResponseFormatList).formats,
        hasLength(2),
      );

      final copy = interaction.copyWith();
      expect(copy.responseFormat, isA<ResponseFormatList>());

      final body = interaction.toJson();
      expect(body['response_format'], isA<List<dynamic>>());
    });

    test('CreateAgentInteractionParams round-trips response_format', () {
      const params = CreateAgentInteractionParams(
        agent: 'deep-research',
        responseFormat: ResponseFormatConfig.single(
          TextResponseFormat(schema: {'type': 'object'}),
        ),
      );
      final restored = CreateAgentInteractionParams.fromJson(params.toJson());
      expect(restored.responseFormat, isA<SingleResponseFormat>());
    });
  });
}
