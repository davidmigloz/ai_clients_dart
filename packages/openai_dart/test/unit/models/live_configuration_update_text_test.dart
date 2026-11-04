import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Live configuration updates expose typed text and preserve future data',
    () {
      final wire = <String, dynamic>{
        'type': 'configuration_update',
        'id': null,
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'answer',
            'schema': {
              'type': 'object',
              'required': ['answer'],
            },
            'strict': null,
            'future_format': {'keep': true},
          },
          'future_text': [1, 2],
        },
        'future_item': {'keep': true},
      };
      final item =
          LiveInputItem.fromJson(wire)
              as LiveInputResponseConfigurationUpdateItemParam;
      expect(item.hasText, isTrue);
      expect(item.text!.format, isA<JsonSchemaFormat>());
      expect((item.text!.format as JsonSchemaFormat).name, 'answer');
      expect(item.toJson(), wire);
      expect(item, LiveInputItem.fromJson(wire));
      expect(item.hashCode, LiveInputItem.fromJson(wire).hashCode);
      expect(item.copyWith().toJson(), wire);
      expect(item.copyWith(clearText: true).hasText, isFalse);
      expect(item.copyWith(clearText: true).toJson(), {
        'type': 'configuration_update',
        'id': null,
        'future_item': {'keep': true},
      });
      final replaced = item.copyWith(
        text: const ConfigurationUpdateText.plainText(),
      );
      expect(replaced.text, const ConfigurationUpdateText.plainText());
      expect(replaced, isNot(item));
      expect(replaced.toJson(), {
        'type': 'configuration_update',
        'id': null,
        'text': {
          'format': {'type': 'text'},
        },
        'future_item': {'keep': true},
      });
      expect(replaced.toString(), contains('text: [REDACTED]'));
      expect(() => item.rawJson['text'] = null, throwsUnsupportedError);
    },
  );
  test(
    'Live conversion from Responses input retains the typed text update',
    () {
      const source = ConfigurationUpdateItem(
        text: ConfigurationUpdateText.plainText(),
      );
      final item =
          LiveInputItem.fromItem(source)
              as LiveInputResponseConfigurationUpdateItemParam;
      expect(item.text, source.text);
      expect(item.toJson(), source.toJson());
    },
  );
  test(
    'Live compact snapshots validate configuration updates in instructions',
    () {
      final wire = {
        'instructions': [
          {
            'type': 'configuration_update',
            'text': {
              'format': {'type': 'text'},
              'future_text': true,
            },
          },
        ],
      };
      expect(LiveCompactResponse.fromJson(wire).toJson(), wire);
      // Receive-only compact snapshots retain future discriminated branches;
      // the writable LiveInputItem adapter below still rejects legacy JSON mode.
      final future = {
        'instructions': [
          {
            'type': 'configuration_update',
            'text': {
              'format': {'type': 'future_format'},
            },
          },
        ],
      };
      expect(LiveCompactResponse.fromJson(future).toJson(), future);
      for (final bad in <Object?>[null, {}]) {
        expect(
          () => LiveCompactResponse.fromJson({
            'instructions': [
              {'type': 'configuration_update', 'text': bad},
            ],
          }),
          throwsFormatException,
        );
      }
    },
  );
  for (final bad in <Object?>[
    null,
    'private value',
    {},
    {'format': null},
    {
      'format': {'type': 'json_object'},
    },
    {
      'format': {'type': 'json_schema', 'name': 'answer'},
    },
    {
      'format': {
        'type': 'json_schema',
        'name': 'answer',
        'schema': <String, dynamic>{},
        'strict': 'private value',
      },
    },
  ]) {
    test('Live rejects malformed configuration text $bad before sending', () {
      expect(
        () => LiveInputItem.fromJson({
          'type': 'configuration_update',
          'text': bad,
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe field context',
            allOf(
              contains('LiveInputResponseConfigurationUpdateItemParam.text'),
              isNot(contains('private value')),
            ),
          ),
        ),
      );
      final item = LiveInputResponseConfigurationUpdateItemParam.fromJson(
        const {'type': 'configuration_update'},
      );
      expect(item.hasText, isFalse);
      expect(item.text, isNull);
      expect(() => item.copyWith(text: bad), throwsFormatException);
    });
  }
}
