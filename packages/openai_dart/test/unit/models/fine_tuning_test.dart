import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FineTuningJob', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'ftjob-abc123',
        'object': 'fine_tuning.job',
        'created_at': 1614807352,
        'fine_tuned_model': 'gpt-3.5-turbo-fine-tuned',
        'finished_at': 1614807600,
        'hyperparameters': {
          'n_epochs': 'auto',
          'batch_size': 4,
          'learning_rate_multiplier': 0.1,
        },
        'model': 'gpt-3.5-turbo',
        'organization_id': 'org-123',
        'result_files': ['file-abc'],
        'status': 'succeeded',
        'trained_tokens': 1000,
        'training_file': 'file-xyz',
        'validation_file': 'file-val',
        'seed': 42,
      };

      final job = FineTuningJob.fromJson(json);

      expect(job.id, 'ftjob-abc123');
      expect(job.object, 'fine_tuning.job');
      expect(job.createdAt, 1614807352);
      expect(job.fineTunedModel, 'gpt-3.5-turbo-fine-tuned');
      expect(job.finishedAt, 1614807600);
      expect(job.hyperparameters.nEpochs, isA<AutoOrIntAuto>());
      expect(job.hyperparameters.batchSize, isA<AutoOrIntValue>());
      expect((job.hyperparameters.batchSize! as AutoOrIntValue).value, 4);
      expect(
        job.hyperparameters.learningRateMultiplier,
        isA<AutoOrDoubleValue>(),
      );
      expect(job.model, 'gpt-3.5-turbo');
      expect(job.status, FineTuningStatus.succeeded);
      expect(job.isSucceeded, isTrue);
      expect(job.seed, 42);
    });

    test('toJson serializes correctly', () {
      const job = FineTuningJob(
        id: 'ftjob-abc123',
        object: 'fine_tuning.job',
        createdAt: 1614807352,
        fineTunedModel: 'gpt-3.5-turbo-fine-tuned',
        hyperparameters: Hyperparameters(
          nEpochs: AutoOrIntValue(5),
          batchSize: AutoOrIntAuto(),
        ),
        model: 'gpt-3.5-turbo',
        organizationId: 'org-123',
        resultFiles: ['file-abc'],
        status: FineTuningStatus.succeeded,
        trainingFile: 'file-xyz',
        seed: 42,
      );

      final json = job.toJson();

      expect(json['id'], 'ftjob-abc123');
      expect((json['hyperparameters'] as Map)['n_epochs'], 5);
      expect((json['hyperparameters'] as Map)['batch_size'], 'auto');
    });
  });

  group('Hyperparameters', () {
    test('fromJson parses auto values', () {
      final json = {
        'n_epochs': 'auto',
        'batch_size': 'auto',
        'learning_rate_multiplier': 'auto',
      };

      final params = Hyperparameters.fromJson(json);

      expect(params.nEpochs, isA<AutoOrIntAuto>());
      expect(params.batchSize, isA<AutoOrIntAuto>());
      expect(params.learningRateMultiplier, isA<AutoOrDoubleAuto>());
    });

    test('fromJson parses numeric values', () {
      final json = {
        'n_epochs': 10,
        'batch_size': 32,
        'learning_rate_multiplier': 0.05,
      };

      final params = Hyperparameters.fromJson(json);

      expect(params.nEpochs, isA<AutoOrIntValue>());
      expect((params.nEpochs! as AutoOrIntValue).value, 10);
      expect(params.batchSize, isA<AutoOrIntValue>());
      expect((params.batchSize! as AutoOrIntValue).value, 32);
      expect(params.learningRateMultiplier, isA<AutoOrDoubleValue>());
      expect(
        (params.learningRateMultiplier! as AutoOrDoubleValue).value,
        closeTo(0.05, 0.001),
      );
    });

    test('toJson serializes correctly', () {
      const params = Hyperparameters(
        nEpochs: AutoOrIntValue(5),
        batchSize: AutoOrIntAuto(),
        learningRateMultiplier: AutoOrDoubleValue(0.1),
      );

      final json = params.toJson();

      expect(json['n_epochs'], 5);
      expect(json['batch_size'], 'auto');
      expect(json['learning_rate_multiplier'], 0.1);
    });
  });

  group('HyperparametersRequest', () {
    test('fromJson parses correctly', () {
      final json = {'n_epochs': 3, 'batch_size': 'auto'};

      final params = HyperparametersRequest.fromJson(json);

      expect(params.nEpochs, isA<AutoOrIntValue>());
      expect(params.batchSize, isA<AutoOrIntAuto>());
    });

    test('toJson serializes correctly', () {
      const params = HyperparametersRequest(nEpochs: AutoOrIntValue(3));

      final json = params.toJson();

      expect(json['n_epochs'], 3);
      expect(json.containsKey('batch_size'), isFalse);
    });
  });

  group('FineTuningStatus', () {
    test('fromJson parses all values', () {
      expect(
        FineTuningStatus.fromJson('validating_files'),
        FineTuningStatus.validatingFiles,
      );
      expect(FineTuningStatus.fromJson('queued'), FineTuningStatus.queued);
      expect(FineTuningStatus.fromJson('running'), FineTuningStatus.running);
      expect(
        FineTuningStatus.fromJson('succeeded'),
        FineTuningStatus.succeeded,
      );
      expect(FineTuningStatus.fromJson('failed'), FineTuningStatus.failed);
      expect(
        FineTuningStatus.fromJson('cancelled'),
        FineTuningStatus.cancelled,
      );
    });

    test('toJson returns correct string', () {
      expect(FineTuningStatus.validatingFiles.toJson(), 'validating_files');
      expect(FineTuningStatus.succeeded.toJson(), 'succeeded');
    });

    test('fromJson throws on unknown value', () {
      expect(() => FineTuningStatus.fromJson('unknown'), throwsFormatException);
    });
  });

  group('CreateFineTuningJobRequest', () {
    test('toJson serializes correctly', () {
      const request = CreateFineTuningJobRequest(
        model: 'gpt-3.5-turbo',
        trainingFile: 'file-abc',
        hyperparameters: HyperparametersRequest(nEpochs: AutoOrIntValue(3)),
      );

      final json = request.toJson();

      expect(json['model'], 'gpt-3.5-turbo');
      expect(json['training_file'], 'file-abc');
      expect((json['hyperparameters'] as Map)['n_epochs'], 3);
    });
  });
}
