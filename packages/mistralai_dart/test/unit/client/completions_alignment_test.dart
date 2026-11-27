import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _model = 'zai-glm-5-3';
const _messages = [UserMessage(content: MessageContent.text('Hello'))];
const _chatRequest = ChatCompletionRequest(
  model: _model,
  messages: _messages,
  minTokens: 2,
  topK: 6,
  repetitionPenalty: 1.2,
  logprobs: true,
  topLogprobs: 2,
  promptLogprobs: true,
  topPromptLogprobs: 3,
  serviceTier: RequestedServiceTier.auto,
  reasoningEffort: ReasoningEffort.max,
);
const _agentRequest = AgentCompletionRequest(
  agentId: 'ag_test',
  messages: _messages,
  minTokens: 2,
  topK: 6,
  repetitionPenalty: 1.2,
  logprobs: true,
  topLogprobs: 2,
  promptLogprobs: true,
  topPromptLogprobs: 3,
  serviceTier: RequestedServiceTier.auto,
  reasoningEffort: ReasoningEffort.max,
);

const Map<String, Object?> _expectedControls = {
  'min_tokens': 2,
  'top_k': 6,
  'repetition_penalty': 1.2,
  'logprobs': true,
  'top_logprobs': 2,
  'prompt_logprobs': true,
  'top_prompt_logprobs': 3,
  'service_tier': 'auto',
  'reasoning_effort': 'max',
};

const Map<String, Object?> _outputLogprobs = {
  'content': [
    {
      'token': 'Hi',
      'logprob': -0.2,
      'bytes': [72, 105],
      'token_id': 42,
      'top_logprobs': [
        {
          'token': 'Hello',
          'logprob': -1.4,
          'bytes': [72, 101, 108, 108, 111],
          'token_id': 43,
        },
      ],
    },
  ],
};
const Map<String, Object?> _inputLogprobs = {
  'content': [
    {
      'token': 'Hello',
      'logprob': -0.1,
      'bytes': [72, 101, 108, 108, 111],
      'token_id': 43,
    },
  ],
};
const Map<String, Object?> _usage = {
  'prompt_tokens': 3,
  'completion_tokens': 4,
  'total_tokens': 7,
  'service_tier': 'priority',
  'prompt_tokens_details': {'cached_tokens': 2, 'audio_tokens': 1},
  'completion_tokens_details': {'reasoning_tokens': 3},
};

const Map<String, Object?> _jsonChoice = {
  'index': 0,
  'message': {'role': 'assistant', 'content': 'Hi'},
  'finish_reason': 'stop',
  'logprobs': _outputLogprobs,
  'prompt_logprobs': _inputLogprobs,
};
const Map<String, Object?> _streamChoice = {
  'index': 0,
  'delta': {
    'content': [
      {
        'type': 'thinking',
        'thinking': [
          {'type': 'text', 'text': 'Consider response'},
        ],
        'closed': true,
      },
      {'type': 'text', 'text': 'Hi'},
    ],
  },
  'finish_reason': null,
  'logprobs': _outputLogprobs,
  'prompt_logprobs': _inputLogprobs,
};

Map<String, dynamic> _completion({required bool stream}) => {
  'id': 'cmpl_test',
  'object': stream ? 'chat.completion.chunk' : 'chat.completion',
  'model': _model,
  'created': 1234,
  'choices': [if (stream) _streamChoice else _jsonChoice],
  'usage': _usage,
};

void main() {
  for (final isAgent in [false, true]) {
    final name = isAgent ? 'agents' : 'chat';
    group(name, () {
      Stream<ChatCompletionStreamResponse> stream(MistralClient client) =>
          isAgent
          ? client.agents.completeStream(request: _agentRequest)
          : client.chat.createStream(request: _chatRequest);

      void checkRequest(
        http.BaseRequest request,
        String body, {
        required bool stream,
      }) {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/$name/completions');
        expect(request.headers['authorization'], 'Bearer test-key');
        if (stream) {
          expect(request.headers['accept'], 'text/event-stream');
        }
        expect(request.headers['x-request-id'], isNull);
        expect(jsonDecode(body), {
          if (isAgent) 'agent_id': 'ag_test' else 'model': _model,
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
          'stream': stream,
          ..._expectedControls,
        });
      }

      test('sends controls and decodes JSON logprobs and tier', () async {
        final client = MistralClient.withApiKey(
          'test-key',
          httpClient: MockClient((request) async {
            checkRequest(request, request.body, stream: false);
            return http.Response(
              jsonEncode(_completion(stream: false)),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        addTearDown(client.close);
        final (choices, usage) = isAgent
            ? await client.agents
                  .complete(request: _agentRequest)
                  .then((r) => (r.choices, r.usage))
            : await client.chat
                  .create(request: _chatRequest)
                  .then((r) => (r.choices, r.usage));

        final choice = choices.single;
        expect(choice.message!.content!.toJson(), 'Hi');
        expect(choice.logprobs!.content.single.topLogprobs!.single.tokenId, 43);
        expect(choice.promptLogprobs!.content.single.bytes, [
          72,
          101,
          108,
          108,
          111,
        ]);
        expect(choice.toJson()['logprobs'], _outputLogprobs);
        expect(choice.toJson()['prompt_logprobs'], _inputLogprobs);
        expect(usage!.serviceTier, 'priority');
        expect(usage.promptTokensDetails!.cachedTokens, 2);
        expect(usage.promptTokensDetails!.audioTokens, 1);
        expect(usage.completionTokensDetails!.reasoningTokens, 3);
        expect(usage.toJson(), _usage);
      });

      test(
        'negotiates SSE with identical controls and typed choices',
        () async {
          final events = [
            'data: ${jsonEncode(_completion(stream: true))}\r\n\r\n',
            'data: [DONE]\r\n\r\n',
          ];
          final client = MistralClient.withApiKey(
            'test-key',
            httpClient: MockClient.streaming((request, body) async {
              checkRequest(request, await body.bytesToString(), stream: true);
              return http.StreamedResponse(
                Stream.fromIterable(events.map(utf8.encode)),
                200,
                headers: {'content-type': 'text/event-stream'},
              );
            }),
          );
          addTearDown(client.close);

          final chunk = await stream(client).single;
          final choice = chunk.choices.single;
          expect(chunk.text, 'Hi');
          expect(choice.delta.content, isA<MessagePartsContent>());
          expect(choice.logprobs!.content.single.logprob, -0.2);
          expect(choice.promptLogprobs!.content.single.topLogprobs, isNull);
          expect(choice.toJson(), _streamChoice);
          expect(chunk.usage!.serviceTier, 'priority');
        },
      );

      test('keeps HTTP and inline stream errors distinct', () async {
        final client = MistralClient.withApiKey(
          'test-key',
          httpClient: MockClient.streaming((_, _) async {
            const event =
                'event: error\ndata: {"error":{"message":"Interrupted"}}\n\n';
            return http.StreamedResponse(Stream.value(utf8.encode(event)), 200);
          }),
        );
        addTearDown(client.close);
        await expectLater(
          stream(client),
          emitsError(
            isA<StreamException>().having(
              (error) => error.message,
              'message',
              'Interrupted',
            ),
          ),
        );

        final httpErrorClient = MistralClient.withApiKey(
          'test-key',
          httpClient: MockClient(
            (_) async => http.Response('{"message":"No access"}', 401),
          ),
        );
        addTearDown(httpErrorClient.close);
        await expectLater(
          stream(httpErrorClient),
          emitsError(isA<AuthenticationException>()),
        );
      });
    });
  }

  test(
    'completion controls round-trip and nullable changes can be cleared',
    () {
      final chat = ChatCompletionRequest.fromJson(_chatRequest.toJson());
      final agent = AgentCompletionRequest.fromJson(_agentRequest.toJson());
      expect(chat, _chatRequest);
      expect(chat.hashCode, _chatRequest.hashCode);
      expect(agent, _agentRequest);
      expect(agent.hashCode, _agentRequest.hashCode);

      final clearedChat = chat.copyWith(
        minTokens: null,
        topK: null,
        repetitionPenalty: null,
        logprobs: false,
        topLogprobs: null,
        promptLogprobs: null,
        topPromptLogprobs: null,
        serviceTier: null,
        reasoningEffort: null,
      );
      final clearedAgent = agent.copyWith(
        minTokens: null,
        topK: null,
        repetitionPenalty: null,
        logprobs: false,
        topLogprobs: null,
        promptLogprobs: null,
        topPromptLogprobs: null,
        serviceTier: null,
        reasoningEffort: null,
      );
      for (final json in [clearedChat.toJson(), clearedAgent.toJson()]) {
        expect(json['logprobs'], isFalse);
        for (final key in _expectedControls.keys.where(
          (key) => key != 'logprobs',
        )) {
          expect(json, isNot(contains(key)));
        }
      }
      expect(clearedChat, isNot(chat));
      expect(clearedAgent, isNot(agent));
    },
  );

  test(
    'token log probabilities verify required fields and nested equality',
    () {
      final score = ChatChoiceLogprobs.fromJson(_outputLogprobs);
      final roundTrip = ChatChoiceLogprobs.fromJson(score.toJson());
      expect(roundTrip, score);
      expect(roundTrip.hashCode, score.hashCode);

      final token = score.content.single;
      final alternative = token.topLogprobs!.single;
      expect(
        token.copyWith(topLogprobs: [alternative.copyWith(tokenId: 44)]),
        isNot(token),
      );
      expect(
        token.copyWith(topLogprobs: null).toJson(),
        isNot(contains('top_logprobs')),
      );
      expect(
        () => ChatTokenLogprob.fromJson(const {
          'token': 'Hi',
          'logprob': -0.2,
          'bytes': [72, 105],
        }),
        throwsA(isA<FormatException>()),
      );
    },
  );
}
