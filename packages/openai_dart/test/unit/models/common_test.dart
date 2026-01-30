import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Usage', () {
    test('fromJson parses correctly', () {
      final json = {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
      };

      final usage = Usage.fromJson(json);

      expect(usage.promptTokens, 10);
      expect(usage.completionTokens, 20);
      expect(usage.totalTokens, 30);
    });

    test('toJson serializes correctly', () {
      const usage = Usage(
        promptTokens: 5,
        completionTokens: 15,
        totalTokens: 20,
      );

      final json = usage.toJson();

      expect(json['prompt_tokens'], 5);
      expect(json['completion_tokens'], 15);
      expect(json['total_tokens'], 20);
    });

    test('handles completion tokens details', () {
      final json = {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
        'completion_tokens_details': {'reasoning_tokens': 5},
      };

      final usage = Usage.fromJson(json);

      expect(usage.promptTokens, 10);
      expect(usage.completionTokens, 20);
      expect(usage.completionTokensDetails, isNotNull);
      expect(usage.completionTokensDetails!.reasoningTokens, 5);
    });
  });

  group('FinishReason', () {
    test('parses all valid values', () {
      expect(FinishReason.fromJson('stop'), FinishReason.stop);
      expect(FinishReason.fromJson('length'), FinishReason.length);
      expect(FinishReason.fromJson('tool_calls'), FinishReason.toolCalls);
      expect(
        FinishReason.fromJson('content_filter'),
        FinishReason.contentFilter,
      );
      expect(FinishReason.fromJson('function_call'), FinishReason.functionCall);
    });

    test('toJson returns correct values', () {
      expect(FinishReason.stop.toJson(), 'stop');
      expect(FinishReason.length.toJson(), 'length');
      expect(FinishReason.toolCalls.toJson(), 'tool_calls');
      expect(FinishReason.contentFilter.toJson(), 'content_filter');
    });
  });

  group('ResponseFormat', () {
    test('text format creates correctly', () {
      final format = ResponseFormat.text();
      final json = format.toJson();
      expect(json['type'], 'text');
    });

    test('json object format creates correctly', () {
      final format = ResponseFormat.jsonObject();
      final json = format.toJson();
      expect(json['type'], 'json_object');
    });

    test('json schema format creates correctly', () {
      final format = ResponseFormat.jsonSchema(
        name: 'my_schema',
        schema: {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
          },
        },
      );

      final json = format.toJson();
      final jsonSchema = json['json_schema'] as Map<String, dynamic>;

      expect(json['type'], 'json_schema');
      expect(jsonSchema['name'], 'my_schema');
      expect(jsonSchema['schema'], isNotNull);
    });

    test('json schema format supports strict mode', () {
      final format = ResponseFormat.jsonSchema(
        name: 'strict_schema',
        schema: {'type': 'object'},
        strict: true,
      );

      final json = format.toJson();
      final jsonSchema = json['json_schema'] as Map<String, dynamic>;

      expect(jsonSchema['strict'], true);
    });
  });

  group('Logprobs', () {
    test('fromJson parses correctly', () {
      final json = {
        'content': [
          {
            'token': 'Hello',
            'logprob': -0.5,
            'bytes': [72, 101, 108, 108, 111],
            'top_logprobs': <dynamic>[],
          },
        ],
      };

      final logprobs = Logprobs.fromJson(json);

      expect(logprobs.content, isNotNull);
      expect(logprobs.content!.length, 1);
      expect(logprobs.content!.first.token, 'Hello');
      expect(logprobs.content!.first.logprob, -0.5);
    });
  });

  group('CompletionTokensDetails', () {
    test('fromJson parses correctly', () {
      final json = {
        'reasoning_tokens': 10,
        'audio_tokens': 5,
        'accepted_prediction_tokens': 15,
        'rejected_prediction_tokens': 2,
      };

      final details = CompletionTokensDetails.fromJson(json);

      expect(details.reasoningTokens, 10);
      expect(details.audioTokens, 5);
      expect(details.acceptedPredictionTokens, 15);
      expect(details.rejectedPredictionTokens, 2);
    });

    test('handles partial data', () {
      final json = {'reasoning_tokens': 10};

      final details = CompletionTokensDetails.fromJson(json);

      expect(details.reasoningTokens, 10);
      expect(details.audioTokens, isNull);
    });
  });
}
