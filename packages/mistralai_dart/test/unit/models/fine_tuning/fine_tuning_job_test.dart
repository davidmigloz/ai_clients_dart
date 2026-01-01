import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FineTuningJob', () {
    group('fromJson', () {
      test('should parse complete job', () {
        final json = <String, dynamic>{
          'id': 'ft-123',
          'object': 'fine_tuning.job',
          'model': 'mistral-small-latest',
          'fine_tuned_model': 'ft:mistral-small-latest:custom',
          'status': 'SUCCESS',
          'hyperparameters': <String, dynamic>{
            'training_steps': 100,
            'learning_rate': 0.0001,
          },
          'training_files': [
            {'file_id': 'file-abc', 'weight': 1.0},
          ],
          'validation_files': [
            {'file_id': 'file-def'},
          ],
          'integrations': [
            {'type': 'wandb', 'project': 'my-project'},
          ],
          'suffix': 'custom',
          'auto_start': true,
          'trained_tokens': 50000,
          'total_tokens': 100000,
        };

        final job = FineTuningJob.fromJson(json);

        expect(job.id, 'ft-123');
        expect(job.object, 'fine_tuning.job');
        expect(job.model, 'mistral-small-latest');
        expect(job.fineTunedModel, 'ft:mistral-small-latest:custom');
        expect(job.status, FineTuningJobStatus.success);
        expect(job.hyperparameters?.trainingSteps, 100);
        expect(job.hyperparameters?.learningRate, 0.0001);
        expect(job.trainingFiles, hasLength(1));
        expect(job.trainingFiles.first.fileId, 'file-abc');
        expect(job.validationFiles, hasLength(1));
        expect(job.integrations, hasLength(1));
        expect(job.suffix, 'custom');
        expect(job.autoStart, isTrue);
        expect(job.trainedTokens, 50000);
        expect(job.totalTokens, 100000);
      });

      test('should parse minimal job', () {
        final json = <String, dynamic>{
          'id': 'ft-456',
          'model': 'mistral-small-latest',
          'status': 'QUEUED',
        };

        final job = FineTuningJob.fromJson(json);

        expect(job.id, 'ft-456');
        expect(job.model, 'mistral-small-latest');
        expect(job.status, FineTuningJobStatus.queued);
        expect(job.fineTunedModel, isNull);
        expect(job.trainingFiles, isEmpty);
      });

      test('should parse all status values', () {
        for (final status in FineTuningJobStatus.values) {
          final json = <String, dynamic>{
            'id': 'ft-test',
            'model': 'mistral-small-latest',
            'status': status.value,
          };

          final job = FineTuningJob.fromJson(json);
          expect(job.status, status);
        }
      });
    });

    group('toJson', () {
      test('should serialize complete job', () {
        const job = FineTuningJob(
          id: 'ft-123',
          model: 'mistral-small-latest',
          fineTunedModel: 'ft:custom',
          status: FineTuningJobStatus.success,
          hyperparameters: Hyperparameters(trainingSteps: 100),
          trainingFiles: [TrainingFile(fileId: 'file-abc')],
          suffix: 'custom',
          autoStart: true,
          trainedTokens: 50000,
        );

        final json = job.toJson();

        expect(json['id'], 'ft-123');
        expect(json['model'], 'mistral-small-latest');
        expect(json['fine_tuned_model'], 'ft:custom');
        expect(json['status'], 'SUCCESS');
        expect(
          (json['hyperparameters'] as Map<String, dynamic>)['training_steps'],
          100,
        );
        expect(json['training_files'], hasLength(1));
        expect(json['suffix'], 'custom');
        expect(json['auto_start'], isTrue);
        expect(json['trained_tokens'], 50000);
      });
    });

    group('status helpers', () {
      test('isRunning should return true for running statuses', () {
        const runningStatuses = [
          FineTuningJobStatus.queued,
          FineTuningJobStatus.started,
          FineTuningJobStatus.validating,
          FineTuningJobStatus.validated,
          FineTuningJobStatus.running,
        ];

        for (final status in runningStatuses) {
          final job = FineTuningJob(
            id: 'ft-test',
            model: 'mistral-small-latest',
            status: status,
          );
          expect(
            job.isRunning,
            isTrue,
            reason: '${status.value} should be running',
          );
        }
      });

      test('isComplete should return true for complete statuses', () {
        const completeStatuses = [
          FineTuningJobStatus.success,
          FineTuningJobStatus.failed,
          FineTuningJobStatus.cancelled,
        ];

        for (final status in completeStatuses) {
          final job = FineTuningJob(
            id: 'ft-test',
            model: 'mistral-small-latest',
            status: status,
          );
          expect(
            job.isComplete,
            isTrue,
            reason: '${status.value} should be complete',
          );
        }
      });

      test('isSuccess should return true only for success', () {
        const job = FineTuningJob(
          id: 'ft-test',
          model: 'mistral-small-latest',
          status: FineTuningJobStatus.success,
        );
        expect(job.isSuccess, isTrue);
        expect(job.isFailed, isFalse);
      });

      test('isFailed should return true only for failed', () {
        const job = FineTuningJob(
          id: 'ft-test',
          model: 'mistral-small-latest',
          status: FineTuningJobStatus.failed,
        );
        expect(job.isFailed, isTrue);
        expect(job.isSuccess, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when ids are the same', () {
        const job1 = FineTuningJob(
          id: 'ft-123',
          model: 'mistral-small-latest',
          status: FineTuningJobStatus.queued,
        );
        const job2 = FineTuningJob(
          id: 'ft-123',
          model: 'mistral-small-latest',
          status: FineTuningJobStatus.success,
        );

        expect(job1, equals(job2));
        expect(job1.hashCode, equals(job2.hashCode));
      });

      test('should not be equal when ids differ', () {
        const job1 = FineTuningJob(
          id: 'ft-123',
          model: 'mistral-small-latest',
          status: FineTuningJobStatus.queued,
        );
        const job2 = FineTuningJob(
          id: 'ft-456',
          model: 'mistral-small-latest',
          status: FineTuningJobStatus.queued,
        );

        expect(job1, isNot(equals(job2)));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        const job = FineTuningJob(
          id: 'ft-123',
          model: 'mistral-small-latest',
          status: FineTuningJobStatus.running,
        );

        expect(job.toString(), contains('FineTuningJob'));
        expect(job.toString(), contains('ft-123'));
        expect(job.toString(), contains('RUNNING'));
      });
    });
  });
}
