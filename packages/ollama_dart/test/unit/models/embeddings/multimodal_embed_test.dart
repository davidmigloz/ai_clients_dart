import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Multimodal EmbedInput', () {
    test('round trips each supported media shape', () {
      final shapes = <Map<String, dynamic>>[
        {'text': 'A picture of a cat'},
        {'image': 'iVBORw=='},
        {'audio': 'UklGRg=='},
        {'text': 'A cat', 'image': 'iVBORw==', 'audio': 'UklGRg=='},
      ];
      for (final json in shapes) {
        final input = EmbedInput.fromJson(json);
        expect(input, isA<EmbedInputMultimodal>());
        expect(input.toJson(), json);
        expect(input, EmbedInput.fromJson(json));
        expect(input.hashCode, EmbedInput.fromJson(json).hashCode);
      }
    });

    test('omits absent media and supports replacing and clearing fields', () {
      const input = EmbedInputMultimodal(
        text: 'Original',
        image: 'image',
        audio: 'audio',
      );
      expect(input.copyWith(), input);
      expect(input.copyWith(text: 'Updated').text, 'Updated');
      expect(input.copyWith(image: 'replacement').image, 'replacement');
      expect(input.copyWith(audio: 'replacement').audio, 'replacement');
      expect(input.copyWith(text: null).toJson(), {
        'image': 'image',
        'audio': 'audio',
      });
      expect(input.copyWith(image: null, audio: null).toJson(), {
        'text': 'Original',
      });
      expect(input.toString(), contains('text: Original'));
      expect(input.toString(), contains('image: 5 chars'));
      expect(input.toString(), contains('audio: 5 chars'));
      expect(const EmbedInput.multimodal().toString(), contains('image: null'));
      expect(const EmbedInput.multimodal().toJson(), isEmpty);
    });

    test('equality detects every changed field', () {
      const input = EmbedInputMultimodal(
        text: 'text',
        image: 'im',
        audio: 'au',
      );
      expect(input, isNot(input.copyWith(text: 'changed')));
      expect(input, isNot(input.copyWith(image: 'changed')));
      expect(input, isNot(input.copyWith(audio: 'changed')));
    });

    test('preserves existing string and string-list variants', () {
      expect(EmbedInput.fromJson('text'), const EmbedInput.string('text'));
      expect(
        EmbedInput.fromJson(const ['a', 'b']),
        const EmbedInput.list(['a', 'b']),
      );
      expect(EmbedInput.fromJson(const []), const EmbedInput.list([]));
    });

    test('round trips a mixed batch without pairing media across items', () {
      final json = [
        'plain text',
        {'image': 'aW1hZ2U='},
        {'text': 'sound', 'audio': 'YXVkaW8='},
      ];
      final batch = EmbedInput.fromJson(json) as EmbedInputBatch;
      expect(batch.values, hasLength(3));
      expect(batch.values[0], const EmbedInput.string('plain text'));
      expect(batch.values[1], const EmbedInput.multimodal(image: 'aW1hZ2U='));
      expect(batch.toJson(), json);
      expect(batch, EmbedInput.fromJson(json));
      expect(batch.hashCode, EmbedInput.fromJson(json).hashCode);
      expect(batch.copyWith(), batch);
      expect(batch.toString(), contains('values: 3 items'));
      expect(batch.copyWith(values: []).values, isEmpty);
      expect(batch, isNot(batch.copyWith(values: [])));
    });

    test('copies and freezes a batch list', () {
      final values = <EmbedInput>[const EmbedInput.multimodal(image: 'aW0=')];
      final batch = EmbedInput.batch(values) as EmbedInputBatch;
      values.clear();
      expect(batch.values, hasLength(1));
      expect(batch.values.clear, throwsUnsupportedError);
    });

    test('rejects malformed shapes and unsupported media fields', () {
      for (final json in <Object>[
        42,
        true,
        {'text': 42},
        {'image': null},
        {
          'audio': <int>[1, 2],
        },
        {'video': 'dmlkZW8='},
        {'unknown': 'value'},
        ['text', 42],
        [
          <String>['nested'],
        ],
      ]) {
        expect(() => EmbedInput.fromJson(json), throwsFormatException);
      }
      expect(
        () => EmbedInput.batch(const [
          EmbedInput.list(['nested']),
        ]),
        throwsArgumentError,
      );
      expect(
        () => EmbedInput.batch([EmbedInput.batch(const [])]),
        throwsArgumentError,
      );
    });
  });

  group('EmbedRequest runner', () {
    test('round trips runner and preserves multimodal input', () {
      final json = {
        'model': 'embedding-model',
        'runner': 'mlx',
        'input': {'text': 'A cat', 'image': 'aW0='},
      };
      final request = EmbedRequest.fromJson(json);
      expect(request.runner, 'mlx');
      expect(request.toJson(), json);
      expect(request.copyWith(), request);
      expect(request.copyWith(runner: 'ggml').runner, 'ggml');
      expect(
        request.copyWith(runner: null).toJson(),
        isNot(contains('runner')),
      );
      expect(request, EmbedRequest.fromJson(json));
      expect(request.hashCode, EmbedRequest.fromJson(json).hashCode);
      expect(request, isNot(request.copyWith(runner: 'ggml')));
      expect(request.toString(), contains('runner: mlx'));
    });

    test('omits an unset runner for older servers', () {
      final request = EmbedRequest.fromJson(const {
        'model': 'embedding-model',
        'input': 'text',
      });
      expect(request.runner, isNull);
      expect(request.toJson(), isNot(contains('runner')));
    });
  });

  test(
    'embeddings resource sends media, runner, and normal authentication',
    () async {
      final transport = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/embed');
        expect(request.headers['content-type'], contains('application/json'));
        expect(request.headers['authorization'], 'Bearer test-token');
        expect(jsonDecode(request.body), {
          'model': 'embedding-model',
          'runner': 'mlx',
          'input': [
            'plain text',
            {'image': 'aW1hZ2U='},
            {'text': 'sound', 'audio': 'YXVkaW8='},
          ],
        });
        return http.Response(
          jsonEncode({
            'model': 'embedding-model',
            'embeddings': [
              [0.1, 0.2],
              [0.3, 0.4],
              [0.5, 0.6],
            ],
          }),
          200,
        );
      });
      final client = OllamaClient(
        config: const OllamaConfig(
          authProvider: BearerTokenProvider('test-token'),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      final response = await client.embeddings.create(
        request: EmbedRequest(
          model: 'embedding-model',
          runner: 'mlx',
          input: EmbedInput.batch(const [
            EmbedInput.string('plain text'),
            EmbedInput.multimodal(image: 'aW1hZ2U='),
            EmbedInput.multimodal(text: 'sound', audio: 'YXVkaW8='),
          ]),
        ),
      );
      expect(response.embeddings, hasLength(3));
      expect(response.embeddings!.last, [0.5, 0.6]);
    },
  );
}
