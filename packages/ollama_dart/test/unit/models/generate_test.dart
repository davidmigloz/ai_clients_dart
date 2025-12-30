import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('GenerateRequest', () {
    test('fromJson creates request correctly', () {
      final json = {'model': 'llama3.2', 'prompt': 'Hello'};

      final request = GenerateRequest.fromJson(json);

      expect(request.model, 'llama3.2');
      expect(request.prompt, 'Hello');
    });

    test('toJson converts request correctly', () {
      const request = GenerateRequest(model: 'llama3.2', prompt: 'Hello');

      final json = request.toJson();

      expect(json['model'], 'llama3.2');
      expect(json['prompt'], 'Hello');
    });

    test('handles all optional parameters', () {
      const request = GenerateRequest(
        model: 'llama3.2',
        prompt: 'Hello',
        suffix: ' world',
        images: ['base64data'],
        format: 'json',
        system: 'You are helpful',
        stream: true,
        think: true,
        raw: false,
        keepAlive: '5m',
        logprobs: true,
        topLogprobs: 5,
      );

      final json = request.toJson();

      expect(json['suffix'], ' world');
      expect(json['images'], ['base64data']);
      expect(json['format'], 'json');
      expect(json['system'], 'You are helpful');
      expect(json['stream'], true);
      expect(json['think'], true);
      expect(json['raw'], false);
      expect(json['keep_alive'], '5m');
      expect(json['logprobs'], true);
      expect(json['top_logprobs'], 5);
    });

    test('copyWith works correctly', () {
      const original = GenerateRequest(model: 'llama3.2', prompt: 'Hello');

      final copied = original.copyWith(prompt: 'Hi');

      expect(copied.model, 'llama3.2');
      expect(copied.prompt, 'Hi');
    });

    test('equality works correctly', () {
      const request1 = GenerateRequest(model: 'llama3.2', prompt: 'Hello');
      const request2 = GenerateRequest(model: 'llama3.2', prompt: 'Hello');

      expect(request1, equals(request2));
    });
  });

  group('GenerateResponse', () {
    test('fromJson creates response correctly', () {
      final json = {
        'model': 'llama3.2',
        'response': 'Hello there!',
        'done': true,
      };

      final response = GenerateResponse.fromJson(json);

      expect(response.model, 'llama3.2');
      expect(response.response, 'Hello there!');
      expect(response.done, true);
    });

    test('toJson converts response correctly', () {
      const response = GenerateResponse(
        model: 'llama3.2',
        response: 'Hello!',
        done: true,
      );

      final json = response.toJson();

      expect(json['model'], 'llama3.2');
      expect(json['response'], 'Hello!');
      expect(json['done'], true);
    });

    test('handles duration and token count fields', () {
      final json = {
        'model': 'llama3.2',
        'response': 'Hi',
        'done': true,
        'total_duration': 5000000000,
        'load_duration': 1000000000,
        'prompt_eval_count': 10,
        'prompt_eval_duration': 500000000,
        'eval_count': 20,
        'eval_duration': 2000000000,
      };

      final response = GenerateResponse.fromJson(json);

      expect(response.totalDuration, 5000000000);
      expect(response.loadDuration, 1000000000);
      expect(response.promptEvalCount, 10);
      expect(response.promptEvalDuration, 500000000);
      expect(response.evalCount, 20);
      expect(response.evalDuration, 2000000000);
    });

    test('handles thinking field', () {
      final json = {
        'model': 'llama3.2',
        'response': 'The answer is 42.',
        'thinking': 'Let me think about this...',
        'done': true,
      };

      final response = GenerateResponse.fromJson(json);

      expect(response.thinking, 'Let me think about this...');
    });

    test('handles logprobs', () {
      final json = {
        'model': 'llama3.2',
        'response': 'Hello',
        'done': true,
        'logprobs': [
          {
            'token': 'Hello',
            'logprob': -0.5,
            'top_logprobs': [
              {'token': 'Hello', 'logprob': -0.5},
              {'token': 'Hi', 'logprob': -1.2},
            ],
          },
        ],
      };

      final response = GenerateResponse.fromJson(json);

      expect(response.logprobs?.length, 1);
      expect(response.logprobs?.first.token, 'Hello');
      expect(response.logprobs?.first.topLogprobs?.length, 2);
    });
  });

  group('GenerateStreamEvent', () {
    test('fromJson creates event correctly', () {
      final json = {'model': 'llama3.2', 'response': 'Hello', 'done': false};

      final event = GenerateStreamEvent.fromJson(json);

      expect(event.model, 'llama3.2');
      expect(event.response, 'Hello');
      expect(event.done, false);
    });

    test('handles final event with statistics', () {
      final json = {
        'model': 'llama3.2',
        'response': '',
        'done': true,
        'done_reason': 'stop',
        'total_duration': 5000000000,
        'eval_count': 50,
      };

      final event = GenerateStreamEvent.fromJson(json);

      expect(event.done, true);
      expect(event.doneReason, 'stop');
      expect(event.totalDuration, 5000000000);
      expect(event.evalCount, 50);
    });
  });
}
