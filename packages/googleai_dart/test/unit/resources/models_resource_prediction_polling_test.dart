import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _model = 'veo-3.1-generate-001';
const _resource =
    'projects/123456/locations/us-central1/publishers/google/models/$_model';
const _operation = '$_resource/operations/fixture';

GoogleAIClient _client(
  Future<http.Response> Function(http.Request) send, {
  GoogleAIConfig config = const GoogleAIConfig(),
}) {
  final transport = MockClient(send);
  final client = GoogleAIClient(config: config, httpClient: transport);
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

void main() {
  test('starts and polls Vertex Veo using its server-issued resource', () async {
    const result = {
      '@type':
          'type.googleapis.com/cloud.ai.large_models.vision.GenerateVideoResponse',
      'videos': [
        {'gcsUri': 'gs://fixture/video.mp4', 'mimeType': 'video/mp4'},
        {'bytesBase64Encoded': 'AQI=', 'mimeType': 'video/mp4'},
      ],
      'raiMediaFilteredCount': 1,
      'raiMediaFilteredReasons': ['Exemple filtré'],
    };
    final paths = <String>[];
    final client = _client(
      (request) async {
        expect(request.method, 'POST');
        expect(request.url.host, 'us-central1-aiplatform.googleapis.com');
        expect(request.headers['authorization'], 'Bearer fixture-token');
        expect(request.url.queryParameters, {'gateway': 'fixture'});
        paths.add(request.url.path);
        if (paths.length == 1) {
          expect(jsonDecode(request.body), {
            'instances': [
              {'prompt': 'A coastal lighthouse.'},
            ],
          });
          return http.Response(jsonEncode({'name': _operation}), 200);
        }
        expect(request.headers['content-type'], startsWith('application/json'));
        expect(jsonDecode(request.body), {'operationName': _operation});
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'name': _operation,
              if (paths.length == 3) 'done': true,
              if (paths.length == 3) 'response': result,
            }),
          ),
          200,
          headers: const {'content-type': 'application/json'},
        );
      },
      config: GoogleAIConfig.vertexAI(
        projectId: 'project-alias',
        location: 'us-central1',
        authProvider: const BearerTokenProvider('fixture-token'),
        defaultQueryParams: const {'gateway': 'fixture'},
      ),
    );

    final start = await client.models.predictLongRunning(
      model: _model,
      instances: const [
        {'prompt': 'A coastal lighthouse.'},
      ],
    );
    expect(start.name, _operation);
    expect(start.done, isFalse);
    final pending = await client.models.fetchPredictOperation(
      operationName: start.name!,
    );
    expect(pending.done, isFalse);
    expect(pending.response, isNull);
    final complete = await client.models.fetchPredictOperation(
      operationName: pending.name!,
    );
    expect(complete.done, isTrue);
    expect(complete.response?.generateVideoResponse, isNull);
    final videos = complete.response!.videos!;
    expect(videos.first.uri, 'gs://fixture/video.mp4');
    expect(videos.first.mimeType, 'video/mp4');
    expect(videos.last.video, 'AQI=');
    expect(complete.response?.raiMediaFilteredCount, 1);
    expect(complete.response?.raiMediaFilteredReasons, ['Exemple filtré']);
    expect(complete.response?.toJson(), result);
    expect(paths, [
      '/v1/projects/project-alias/locations/us-central1/publishers/google/models/$_model:predictLongRunning',
      '/v1/$_resource:fetchPredictOperation',
      '/v1/$_resource:fetchPredictOperation',
    ]);
  });

  test(
    'uses ordinary Developer operation GET paths and guards Vertex polling',
    () async {
      var calls = 0;
      final client = _client((request) async {
        calls++;
        expect(request.method, 'GET');
        expect(request.url.path, '/v1beta/operations/fixture');
        return http.Response('{"name":"operations/fixture","done":true}', 200);
      });
      await expectLater(
        client.models.fetchPredictOperation(operationName: _operation),
        throwsUnsupportedError,
      );
      expect(
        (await client.getOperation(name: 'operations/fixture')).done,
        isTrue,
      );
      expect(calls, 1);
    },
  );

  test('rejects incomplete and ambiguous publisher operation names', () async {
    final client = _client(
      (_) async => fail('Unexpected request'),
      config: GoogleAIConfig.vertexAI(
        projectId: 'fixture-project',
        authProvider: const BearerTokenProvider('fixture-token'),
      ),
    );
    for (final name in [
      '',
      'operations/fixture',
      '$_resource/operations/',
      '$_resource/operations/..',
      '$_operation/extra',
    ]) {
      await expectLater(
        client.models.fetchPredictOperation(operationName: name),
        throwsArgumentError,
      );
    }
  });
}
