import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const plain = ConfigurationUpdateText.plainText();
  final schema = ConfigurationUpdateText(
    format: const JsonSchemaFormat(
      name: 'answer',
      description: 'Return an answer',
      schema: {
        'type': 'object',
        'properties': {
          'answer': {'type': 'string'},
        },
        'required': ['answer'],
        'additionalProperties': false,
      },
      strict: true,
    ),
  );
  final parsers =
      <(String, Map<String, dynamic>, Object Function(Map<String, dynamic>))>[
        (
          'ConfigurationUpdateItem',
          {'type': 'configuration_update'},
          ConfigurationUpdateItem.fromJson,
        ),
        (
          'ConfigurationUpdateItemResponse',
          {'type': 'configuration_update', 'id': 'cfg'},
          ConfigurationUpdateItemResponse.fromJson,
        ),
        (
          'ConversationConfigurationUpdateItem',
          {'type': 'configuration_update', 'id': 'cfg'},
          ConversationConfigurationUpdateItem.fromJson,
        ),
      ];
  for (final (name, base, parse) in parsers) {
    group(name, () {
      for (final config in [plain, schema]) {
        for (final beta in [false, true]) {
          test('retains ${config.format.runtimeType} with beta=$beta', () {
            final wire = {
              ...base,
              'text': config.toJson(),
              if (beta) 'agent': {'agent_name': 'worker'},
            };
            final parsed = parse(wire);
            expect(_json(parsed), wire);
            expect(_text(parsed), config);
            expect(parsed, parse(wire));
            expect(parsed.hashCode, parse(wire).hashCode);
            expect(parsed.toString(), contains('text: $config'));
            expect(_json(_copyText(parsed, null)), baseWithAgent(wire));
            expect(_copyText(parsed, null), isNot(parsed));
            final changed = _copyText(parsed, config == plain ? schema : plain);
            expect(changed, isNot(parsed));
            expect(changed, parse(_json(changed)));
            expect(changed.hashCode, parse(_json(changed)).hashCode);
          });
        }
      }
      test('omits absent text and restores plain output explicitly', () {
        final omitted = parse(base);
        expect(_text(omitted), isNull);
        expect(_json(omitted), base);
        expect(_json(_copyText(omitted, plain)), {
          ...base,
          'text': {
            'format': {'type': 'text'},
          },
        });
      });
      for (final bad in <Object?>[
        null,
        'text',
        [],
        {},
        {'format': null},
        {'format': 'text'},
        {'format': <String, dynamic>{}},
        {
          'format': {'type': 'json_object'},
        },
        {
          'format': {'type': 'private-future-kind'},
        },
        {
          'format': {'type': 'json_schema', 'schema': <String, dynamic>{}},
        },
        {
          'format': {'type': 'json_schema', 'name': 'answer'},
        },
        {
          'format': {
            'type': 'json_schema',
            'name': 'answer',
            'schema': <String, dynamic>{},
            'strict': 'private-invalid-boolean',
          },
        },
      ]) {
        test('rejects malformed text $bad contextually', () {
          expect(
            () => parse({...base, 'text': bad}),
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'field context',
                allOf(contains('$name.text'), isNot(contains('private-'))),
              ),
            ),
          );
        });
      }
    });
  }
  test(
    'schema is an immutable snapshot across constructor, parse and copy',
    () {
      final owned = <String, dynamic>{
        'required': ['answer'],
        'properties': {
          'answer': {'type': 'string'},
        },
      };
      final config = ConfigurationUpdateText(
        format: JsonSchemaFormat(name: 'answer', schema: owned),
      );
      final hash = config.hashCode;
      (owned['required'] as List).add('later');
      owned['properties'] = null;
      final format = config.format as JsonSchemaFormat;
      expect(format.schema['required'], ['answer']);
      expect(format.schema['properties'], isA<Map<String, dynamic>>());
      expect(() => format.schema['later'] = true, throwsUnsupportedError);
      expect(
        () => (format.schema['required'] as List).add('later'),
        throwsUnsupportedError,
      );
      final parsed = ConfigurationUpdateText.fromJson(config.toJson());
      expect(parsed, config);
      expect(parsed.hashCode, hash);
      expect(config.copyWith(), same(config));
      expect(config.copyWith(format: const PlainTextFormat()), plain);
      expect(config.copyWith(format: const PlainTextFormat()), isNot(config));
      expect(config.toString(), 'ConfigurationUpdateText(format: json_schema)');
      expect(config.toString(), isNot(contains('answer')));
    },
  );
  test(
    'strict null is accepted and normalized; local metadata stays local',
    () {
      final config = ConfigurationUpdateText.fromJson(const {
        'format': {
          'type': 'json_schema',
          'name': 'answer',
          'schema': <String, dynamic>{},
          'strict': null,
          'parser': 'local marker',
        },
        'output_type': 'local marker',
      });
      expect(config.toJson(), {
        'format': {
          'type': 'json_schema',
          'name': 'answer',
          'schema': <String, dynamic>{},
        },
      });
    },
  );
  test(
    'constructor rejects legacy JSON mode and snapshots copy replacement',
    () {
      expect(
        () => ConfigurationUpdateText(format: const JsonObjectFormat()),
        throwsFormatException,
      );
      final owned = <String, dynamic>{'type': 'object'};
      final changed = plain.copyWith(
        format: JsonSchemaFormat(name: 'answer', schema: owned),
      );
      owned['type'] = 'string';
      expect((changed.format as JsonSchemaFormat).schema['type'], 'object');
    },
  );
  test('stored configuration conversion preserves text and beta metadata', () {
    final wire = {
      'type': 'configuration_update',
      'id': 'cfg',
      'reasoning': {'effort': 'high'},
      'text': schema.toJson(),
      'agent': {'agent_name': 'worker'},
    };
    final input = Item.fromJson(wire) as ConfigurationUpdateItem;
    final resource =
        Item.fromResourceJson(wire) as ConfigurationUpdateItemResponse;
    final conversation =
        ConversationItem.fromJson(wire) as ConversationConfigurationUpdateItem;
    expect(resource.toConfigurationUpdateItem(), input);
    expect(conversation.toConfigurationUpdateItem(), input);
    expect(resource.toConfigurationUpdateItem().toJson(), wire);
    expect(conversation.toConfigurationUpdateItem().toJson(), wire);
    const constant = ConfigurationUpdateItem(text: plain);
    expect(constant.text, plain);
  });
}

Map<String, dynamic> _json(Object value) => switch (value) {
  final Item item => item.toJson(),
  final ConversationItem item => item.toJson(),
  _ => throw StateError('unsupported fixture'),
};

Map<String, dynamic> baseWithAgent(Map<String, dynamic> wire) =>
    Map<String, dynamic>.from(wire)..remove('text');

ConfigurationUpdateText? _text(Object value) => switch (value) {
  final ConfigurationUpdateItem item => item.text,
  final ConfigurationUpdateItemResponse item => item.text,
  final ConversationConfigurationUpdateItem item => item.text,
  _ => throw StateError('unsupported fixture'),
};

Object _copyText(Object value, ConfigurationUpdateText? text) =>
    switch (value) {
      final ConfigurationUpdateItem item => item.copyWith(text: text),
      final ConfigurationUpdateItemResponse item => item.copyWith(text: text),
      final ConversationConfigurationUpdateItem item => item.copyWith(
        text: text,
      ),
      _ => throw StateError('unsupported fixture'),
    };
