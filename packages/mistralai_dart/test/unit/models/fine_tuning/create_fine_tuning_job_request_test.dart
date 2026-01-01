import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateFineTuningJobRequest', () {
    group('constructors', () {
      test('should create with required fields', () {
        const request = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
        );

        expect(request.model, 'mistral-small-latest');
        expect(request.trainingFiles, hasLength(1));
        expect(request.trainingFiles.first.fileId, 'file-abc');
      });

      test('should create with single factory', () {
        final request = CreateFineTuningJobRequest.single(
          model: 'mistral-small-latest',
          trainingFileId: 'file-abc',
          validationFileId: 'file-def',
          suffix: 'custom',
          autoStart: true,
        );

        expect(request.model, 'mistral-small-latest');
        expect(request.trainingFiles, hasLength(1));
        expect(request.trainingFiles.first.fileId, 'file-abc');
        expect(request.validationFiles, hasLength(1));
        expect(request.validationFiles!.first.fileId, 'file-def');
        expect(request.suffix, 'custom');
        expect(request.autoStart, isTrue);
      });

      test('should create with all options', () {
        const request = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [
            TrainingFile(fileId: 'file-1', weight: 0.5),
            TrainingFile(fileId: 'file-2', weight: 0.5),
          ],
          validationFiles: [TrainingFile(fileId: 'file-val')],
          hyperparameters: Hyperparameters(
            trainingSteps: 100,
            learningRate: 0.0001,
          ),
          suffix: 'my-model',
          integrations: [
            FineTuningIntegration(type: 'wandb', project: 'my-project'),
          ],
          autoStart: false,
          metadata: {'team': 'ml'},
        );

        expect(request.model, 'mistral-small-latest');
        expect(request.trainingFiles, hasLength(2));
        expect(request.validationFiles, hasLength(1));
        expect(request.hyperparameters?.trainingSteps, 100);
        expect(request.suffix, 'my-model');
        expect(request.integrations, hasLength(1));
        expect(request.autoStart, isFalse);
        expect(request.metadata?['team'], 'ml');
      });
    });

    group('fromJson', () {
      test('should parse complete request', () {
        final json = <String, dynamic>{
          'model': 'mistral-small-latest',
          'training_files': [
            {'file_id': 'file-abc', 'weight': 1.0},
          ],
          'validation_files': [
            {'file_id': 'file-def'},
          ],
          'hyperparameters': <String, dynamic>{'training_steps': 100},
          'suffix': 'custom',
          'integrations': [
            {'type': 'wandb', 'project': 'test'},
          ],
          'auto_start': true,
          'metadata': {'key': 'value'},
        };

        final request = CreateFineTuningJobRequest.fromJson(json);

        expect(request.model, 'mistral-small-latest');
        expect(request.trainingFiles, hasLength(1));
        expect(request.validationFiles, hasLength(1));
        expect(request.hyperparameters?.trainingSteps, 100);
        expect(request.suffix, 'custom');
        expect(request.integrations, hasLength(1));
        expect(request.autoStart, isTrue);
        expect(request.metadata?['key'], 'value');
      });

      test('should handle minimal request', () {
        final json = <String, dynamic>{
          'model': 'mistral-small-latest',
          'training_files': <Map<String, dynamic>>[],
        };

        final request = CreateFineTuningJobRequest.fromJson(json);

        expect(request.model, 'mistral-small-latest');
        expect(request.trainingFiles, isEmpty);
        expect(request.validationFiles, isNull);
        expect(request.hyperparameters, isNull);
      });
    });

    group('toJson', () {
      test('should serialize complete request', () {
        const request = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
          validationFiles: [TrainingFile(fileId: 'file-def')],
          hyperparameters: Hyperparameters(trainingSteps: 100),
          suffix: 'custom',
          integrations: [FineTuningIntegration(type: 'wandb', project: 'test')],
          autoStart: true,
          metadata: {'key': 'value'},
        );

        final json = request.toJson();

        expect(json['model'], 'mistral-small-latest');
        expect(json['training_files'], hasLength(1));
        expect(json['validation_files'], hasLength(1));
        expect(
          (json['hyperparameters'] as Map<String, dynamic>)['training_steps'],
          100,
        );
        expect(json['suffix'], 'custom');
        expect(json['integrations'], hasLength(1));
        expect(json['auto_start'], isTrue);
        expect((json['metadata'] as Map<String, dynamic>)['key'], 'value');
      });

      test('should not include null fields', () {
        const request = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
        );

        final json = request.toJson();

        expect(json['model'], 'mistral-small-latest');
        expect(json.containsKey('validation_files'), isFalse);
        expect(json.containsKey('hyperparameters'), isFalse);
        expect(json.containsKey('suffix'), isFalse);
        expect(json.containsKey('integrations'), isFalse);
        expect(json.containsKey('auto_start'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
      });
    });

    group('equality', () {
      test('should be equal when model and suffix are the same', () {
        const request1 = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
          suffix: 'custom',
        );
        const request2 = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
          suffix: 'custom',
        );

        expect(request1, equals(request2));
      });

      test('should not be equal when model differs', () {
        const request1 = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
        );
        const request2 = CreateFineTuningJobRequest(
          model: 'mistral-large-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
        );

        expect(request1, isNot(equals(request2)));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        const request = CreateFineTuningJobRequest(
          model: 'mistral-small-latest',
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
        );

        expect(request.toString(), contains('CreateFineTuningJobRequest'));
        expect(request.toString(), contains('mistral-small-latest'));
        expect(request.toString(), contains('1'));
      });
    });
  });
}
