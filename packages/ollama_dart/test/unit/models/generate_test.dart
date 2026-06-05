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
        format: JsonFormat(),
        system: 'You are helpful',
        stream: true,
        think: ThinkEnabled(true),
        raw: false,
        keepAlive: KeepAlive.duration('5m'),
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
      expect(
        json['keep_alive'],
        '5m',
      ); // KeepAliveDuration serializes to string
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

    test('template field serializes and deserializes correctly', () {
      const request = GenerateRequest(
        model: 'llama3.2',
        prompt: 'Hello',
        template: '{{ .System }}\n{{ .Prompt }}',
      );

      final json = request.toJson();
      expect(json['template'], '{{ .System }}\n{{ .Prompt }}');

      final restored = GenerateRequest.fromJson(json);
      expect(restored.template, '{{ .System }}\n{{ .Prompt }}');
    });

    test('context field serializes and deserializes correctly', () {
      const request = GenerateRequest(
        model: 'llama3.2',
        prompt: 'Hello',
        context: [1, 2, 3, 4, 5],
      );

      final json = request.toJson();
      expect(json['context'], [1, 2, 3, 4, 5]);

      final restored = GenerateRequest.fromJson(json);
      expect(restored.context, [1, 2, 3, 4, 5]);
    });

    test('context field handles empty list', () {
      const request = GenerateRequest(
        model: 'llama3.2',
        prompt: 'Hello',
        context: <int>[],
      );

      final json = request.toJson();
      expect(json['context'], <int>[]);

      final restored = GenerateRequest.fromJson(json);
      expect(restored.context, <int>[]);
    });

    test('context field handles null', () {
      final json = {'model': 'llama3.2', 'prompt': 'Hello'};

      final request = GenerateRequest.fromJson(json);
      expect(request.context, isNull);

      final outputJson = request.toJson();
      expect(outputJson.containsKey('context'), isFalse);
    });

    test(
      'image generation params serialize, deserialize, copyWith, toString',
      () {
        const request = GenerateRequest(
          model: 'x/z-image-turbo',
          prompt: 'a sunset over mountains',
          width: 1024,
          height: 768,
          steps: 20,
        );

        final json = request.toJson();
        expect(json['width'], 1024);
        expect(json['height'], 768);
        expect(json['steps'], 20);

        final restored = GenerateRequest.fromJson(json);
        expect(restored.width, 1024);
        expect(restored.height, 768);
        expect(restored.steps, 20);

        expect(restored.copyWith(width: 512).width, 512);
        expect(restored.copyWith(steps: null).steps, isNull);
        expect(request.toString(), contains('width: 1024'));
      },
    );

    test('image generation params omitted when absent', () {
      const request = GenerateRequest(model: 'llama3.2', prompt: 'Hello');

      final json = request.toJson();
      expect(json.containsKey('width'), isFalse);
      expect(json.containsKey('height'), isFalse);
      expect(json.containsKey('steps'), isFalse);
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

    test('context field deserializes correctly', () {
      final json = {
        'model': 'llama3.2',
        'response': 'Hello there!',
        'done': true,
        'context': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      };

      final response = GenerateResponse.fromJson(json);

      expect(response.context, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('context field serializes correctly', () {
      const response = GenerateResponse(
        model: 'llama3.2',
        response: 'Hello!',
        done: true,
        context: [1, 2, 3],
      );

      final json = response.toJson();

      expect(json['context'], [1, 2, 3]);
    });

    test('context field handles null', () {
      final json = {
        'model': 'llama3.2',
        'response': 'Hello there!',
        'done': true,
      };

      final response = GenerateResponse.fromJson(json);
      expect(response.context, isNull);

      final outputJson = response.toJson();
      expect(outputJson.containsKey('context'), isFalse);
    });

    test('context can be used for multi-turn conversations', () {
      // Simulate first response with context
      final firstResponse = GenerateResponse.fromJson(const {
        'model': 'llama3.2',
        'response': 'Hello!',
        'done': true,
        'context': [100, 200, 300],
      });

      // Use context in next request
      final nextRequest = GenerateRequest(
        model: 'llama3.2',
        prompt: 'How are you?',
        context: firstResponse.context,
      );

      expect(nextRequest.context, [100, 200, 300]);
      expect(nextRequest.toJson()['context'], [100, 200, 300]);
    });

    test('image generation fields serialize and deserialize', () {
      final json = {
        'model': 'x/z-image-turbo',
        'done': true,
        'image': 'aW1hZ2VkYXRh', // base64 of "imagedata" (12 chars)
        'completed': 20,
        'total': 20,
      };

      final response = GenerateResponse.fromJson(json);
      expect(response.image, 'aW1hZ2VkYXRh');
      expect(response.completed, 20);
      expect(response.total, 20);

      final roundTrip = response.toJson();
      expect(roundTrip['image'], 'aW1hZ2VkYXRh');
      expect(roundTrip['completed'], 20);
      expect(roundTrip['total'], 20);
    });

    test('image field is summarized in toString, not dumped raw', () {
      const response = GenerateResponse(
        model: 'x/z-image-turbo',
        done: true,
        image: 'aW1hZ2VkYXRh',
      );

      final str = response.toString();
      expect(str, contains('image: [12 chars]'));
      expect(str, isNot(contains('aW1hZ2VkYXRh')));
    });

    test('image generation fields omitted when absent; copyWith clears', () {
      const response = GenerateResponse(
        model: 'llama3.2',
        response: 'Hi',
        done: true,
      );

      final json = response.toJson();
      expect(json.containsKey('image'), isFalse);
      expect(json.containsKey('completed'), isFalse);
      expect(json.containsKey('total'), isFalse);

      final withImage = response.copyWith(image: 'abc', completed: 1, total: 2);
      expect(withImage.image, 'abc');
      expect(withImage.copyWith(image: null).image, isNull);
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
      expect(event.doneReason, DoneReason.stop);
      expect(event.totalDuration, 5000000000);
      expect(event.evalCount, 50);
    });

    test('image generation progress and final events round-trip', () {
      final progress = GenerateStreamEvent.fromJson(const {
        'model': 'x/z-image-turbo',
        'completed': 5,
        'total': 20,
        'done': false,
      });
      expect(progress.completed, 5);
      expect(progress.total, 20);
      expect(progress.done, false);

      final finalEvent = GenerateStreamEvent.fromJson(const {
        'model': 'x/z-image-turbo',
        'image': 'aW1hZ2VkYXRh',
        'done': true,
      });
      expect(finalEvent.image, 'aW1hZ2VkYXRh');
      expect(finalEvent.toJson()['image'], 'aW1hZ2VkYXRh');
      expect(finalEvent.toString(), contains('image: [12 chars]'));
    });

    test('equality compares all fields, not just model/response/done', () {
      const a = GenerateStreamEvent(
        model: 'llama3.2',
        response: 'Hi',
        done: true,
        totalDuration: 1000,
      );
      const b = GenerateStreamEvent(
        model: 'llama3.2',
        response: 'Hi',
        done: true,
        totalDuration: 2000,
      );

      // Previously these compared equal (totalDuration was ignored).
      expect(a, isNot(equals(b)));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });
}
