import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _modelId = 'ft:mistral-small:workspace:model-1';

void main() {
  for (final type in ['completion', 'classifier']) {
    test('updates a $type model without a fine-tuning job ID', () async {
      final transport = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.pathSegments, [
          'v1',
          'fine_tuning',
          'models',
          _modelId,
        ]);
        expect(request.headers['authorization'], 'Bearer fake-key');
        expect(jsonDecode(request.body), {
          'name': 'Customer assistant',
          'description': 'Support',
        });
        return http.Response(
          jsonEncode({
            'id': _modelId,
            'created': 1795766400,
            'owned_by': 'mistral',
            'workspace_id': 'workspace-1',
            'root': 'mistral-small',
            'root_version': '2506',
            'archived': false,
            'capabilities': {'classification': type == 'classifier'},
            'name': 'Customer assistant',
            'description': 'Support',
            'model_type': type,
            if (type == 'classifier')
              'classifier_targets': [
                {
                  'name': 'category',
                  'labels': ['general', 'account'],
                  'weight': 1,
                  'loss_function': 'single_class',
                },
              ]
            else
              'job': null,
          }),
          200,
        );
      });
      addTearDown(transport.close);
      final client = MistralClient.withApiKey(
        'fake-key',
        httpClient: transport,
      );
      addTearDown(client.close);

      final model = await client.fineTuning.models.update(
        modelId: _modelId,
        name: 'Customer assistant',
        description: 'Support',
      );
      expect(model.job, isNull);
      expect(model.modelType, type);
      expect(model.name, 'Customer assistant');
      expect(model.capabilities.classification, type == 'classifier');
      if (type == 'classifier') {
        expect(
          (model as ClassifierFTModelOut).classifierTargets.single.labels,
          ['general', 'account'],
        );
      } else {
        expect(model, isA<CompletionFTModelOut>());
      }
    });
  }

  test(
    'archive and unarchive choose the operation-specific server default',
    () async {
      final methods = <String>[];
      final transport = MockClient((request) async {
        methods.add(request.method);
        expect(request.url.pathSegments, [
          'v1',
          'fine_tuning',
          'models',
          _modelId,
          'archive',
        ]);
        return http.Response(jsonEncode({'id': _modelId}), 200);
      });
      addTearDown(transport.close);
      final client = MistralClient.withApiKey(
        'fake-key',
        httpClient: transport,
      );
      addTearDown(client.close);

      final archived = await client.fineTuning.models.archive(
        modelId: _modelId,
      );
      final restored = await client.fineTuning.models.unarchive(
        modelId: _modelId,
      );
      expect(archived.archived, isTrue);
      expect(restored.archived, isFalse);
      expect(methods, ['POST', 'DELETE']);
    },
  );
}
