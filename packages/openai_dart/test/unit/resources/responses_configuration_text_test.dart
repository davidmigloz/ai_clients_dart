import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final beta in [false, true]) {
    test(
      'Responses create and input-items retain schema text beta=$beta',
      () async {
        final input = ConfigurationUpdateItem(
          text: ConfigurationUpdateText(
            format: const JsonSchemaFormat(
              name: 'answer',
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
          ),
          agent: beta ? const AgentTag(agentName: 'writer') : null,
        );
        final expected = {
          'type': 'configuration_update',
          'text': _schemaText(),
          if (beta) 'agent': {'agent_name': 'writer'},
        };
        var requests = 0;
        final client = _client(
          MockClient((request) async {
            requests++;
            expect(request.headers['Authorization'], 'Bearer local-fixture');
            expect(
              request.headers['OpenAI-Beta'],
              beta ? 'responses_multi_agent=v1' : null,
            );
            expect(
              request.url.queryParameters,
              beta ? {'beta': 'true'} : isEmpty,
            );
            if (requests == 1) {
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses');
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': [expected],
              });
              return _json({
                'id': 'resp_format',
                'object': 'response',
                'created_at': 1,
                'status': 'completed',
                'output': <dynamic>[],
              });
            }
            expect(requests, 2);
            expect(request.method, 'GET');
            expect(request.url.path, '/v1/responses/resp_format/input_items');
            return _json(
              _page([
                {...expected, 'id': 'cu_format'},
              ]),
            );
          }),
        );

        final response = await client.responses.create(
          CreateResponseRequest(
            model: 'fixture-model',
            input: ResponseInput.items([input]),
          ),
          beta: beta,
        );
        final page = await client.responses.inputItems.list(
          response.id,
          beta: beta,
        );
        final stored = page.data.single as ConfigurationUpdateItemResponse;
        expect(stored.id, 'cu_format');
        expect(stored.text?.format, isA<JsonSchemaFormat>());
        expect(stored.text?.toJson(), _schemaText());
        expect(stored.agent?.agentName, beta ? 'writer' : null);
        expect(stored.toJson(), {...expected, 'id': 'cu_format'});
        expect(stored.toConfigurationUpdateItem().text, input.text);
        expect(requests, 2);
      },
    );
  }

  test(
    'Conversation list and retrieval expose typed text configuration',
    () async {
      var requests = 0;
      final schema = {
        'id': 'cu_format',
        'type': 'configuration_update',
        'text': _schemaText(),
      };
      final plainText = {
        'id': 'cu_plain',
        'type': 'configuration_update',
        'text': {
          'format': {'type': 'text'},
        },
      };
      final client = _client(
        MockClient((request) async {
          requests++;
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], 'Bearer local-fixture');
          expect(request.headers['OpenAI-Beta'], isNull);
          if (requests == 1) {
            expect(request.url.path, '/v1/conversations/conv_format/items');
            expect(request.url.queryParameters, {'limit': '2', 'order': 'asc'});
            return _json(_page([schema]));
          }
          expect(requests, 2);
          expect(
            request.url.path,
            '/v1/conversations/conv_format/items/cu_plain',
          );
          expect(request.url.queryParameters, isEmpty);
          return _json(plainText);
        }),
      );

      final listed = await client.conversations.items.list(
        'conv_format',
        limit: 2,
        order: 'asc',
      );
      final storedSchema =
          listed.data.single as ConversationConfigurationUpdateItem;
      expect(storedSchema.text?.format, isA<JsonSchemaFormat>());
      expect(storedSchema.toJson(), schema);
      final retrieved = await client.conversations.items.retrieve(
        'conv_format',
        'cu_plain',
      );
      final storedPlain = retrieved as ConversationConfigurationUpdateItem;
      expect(storedPlain.text?.format, isA<PlainTextFormat>());
      expect(
        storedPlain.toConfigurationUpdateItem().text,
        const ConfigurationUpdateText.plainText(),
      );
      expect(storedPlain.toJson(), plainText);
      expect(requests, 2);
    },
  );

  test(
    'public stored-item parsing rejects null text with model context',
    () async {
      var requests = 0;
      final client = _client(
        MockClient((request) async {
          requests++;
          expect(request.method, 'GET');
          expect(request.url.path, '/v1/responses/resp_format/input_items');
          expect(request.headers['Authorization'], 'Bearer local-fixture');
          return _json(
            _page([
              {
                'type': 'configuration_update',
                'id': 'cu_invalid',
                'text': null,
              },
            ]),
          );
        }),
      );
      await expectLater(
        client.responses.inputItems.list('resp_format'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('ConfigurationUpdateItemResponse.text'),
          ),
        ),
      );
      expect(requests, 1);
    },
  );
}

Map<String, dynamic> _schemaText() => {
  'format': {
    'type': 'json_schema',
    'name': 'answer',
    'schema': {
      'type': 'object',
      'properties': {
        'answer': {'type': 'string'},
      },
      'required': ['answer'],
      'additionalProperties': false,
    },
    'strict': true,
  },
};

Map<String, dynamic> _page(List<Map<String, dynamic>> data) => {
  'object': 'list',
  'data': data,
  'has_more': false,
  'first_id': data.first['id'],
  'last_id': data.last['id'],
};

OpenAIClient _client(http.Client mock) {
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('local-fixture'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: mock,
  );
  addTearDown(client.close);
  addTearDown(mock.close);
  return client;
}

http.Response _json(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: {'content-type': 'application/json'},
);
