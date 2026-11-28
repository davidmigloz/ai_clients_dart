import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  for (final vertex in [false, true]) {
    test(
      'prediction labels use the ${vertex ? 'Vertex' : 'Developer'} routes',
      () async {
        const labels = {'safety_identifier': 'fixture-user'};
        const instances = [
          {'prompt': 'A fictional lighthouse.'},
        ];
        const parameters = {'sampleCount': 1};
        final config = vertex
            ? GoogleAIConfig.vertexAI(
                projectId: 'fixture-project',
                location: 'us-central1',
                authProvider: const BearerTokenProvider('fixture-token'),
              )
            : const GoogleAIConfig(
                authProvider: ApiKeyProvider(
                  'fixture-key',
                  placement: AuthPlacement.header,
                ),
              );
        final prefix = vertex
            ? '/v1/projects/fixture-project/locations/us-central1/publishers/google/models'
            : '/v1beta/models';
        final paths = <String>[];
        final bodies = <Map<String, dynamic>>[];
        final transport = MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.host,
            vertex
                ? 'us-central1-aiplatform.googleapis.com'
                : 'generativelanguage.googleapis.com',
          );
          expect(
            request.headers['content-type'],
            startsWith('application/json'),
          );
          if (vertex) {
            expect(request.headers['authorization'], 'Bearer fixture-token');
          } else {
            expect(request.headers['x-goog-api-key'], 'fixture-key');
          }
          paths.add(request.url.path);
          bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response(
            request.url.path.endsWith(':predictLongRunning')
                ? '{"name":"models/video-fixture/operations/123"}'
                : '{"predictions":["fixture"]}',
            200,
          );
        });
        addTearDown(transport.close);
        final client = GoogleAIClient(config: config, httpClient: transport);
        addTearDown(client.close);

        for (final metadata in <Map<String, String>?>[labels, null]) {
          final prediction = await client.models.predict(
            model: 'prediction-fixture',
            instances: instances,
            parameters: parameters,
            labels: metadata,
          );
          final operation = await client.models.predictLongRunning(
            model: 'video-fixture',
            instances: instances,
            parameters: parameters,
            labels: metadata,
          );
          expect(prediction.predictions, ['fixture']);
          expect(operation.name, 'models/video-fixture/operations/123');
        }
        final unlabelled = {'instances': instances, 'parameters': parameters};
        final labelled = {...unlabelled, 'labels': labels};
        expect(paths, [
          '$prefix/prediction-fixture:predict',
          '$prefix/video-fixture:predictLongRunning',
          '$prefix/prediction-fixture:predict',
          '$prefix/video-fixture:predictLongRunning',
        ]);
        expect(bodies, [labelled, labelled, unlabelled, unlabelled]);
      },
    );
  }
}
