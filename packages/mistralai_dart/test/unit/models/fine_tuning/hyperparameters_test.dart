import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Hyperparameters', () {
    group('fromJson', () {
      test('should parse all fields', () {
        final json = <String, dynamic>{
          'training_steps': 100,
          'learning_rate': 0.0001,
          'warmup_fraction': 0.1,
          'weight_decay': 0.01,
        };

        final params = Hyperparameters.fromJson(json);

        expect(params.trainingSteps, 100);
        expect(params.learningRate, 0.0001);
        expect(params.warmupFraction, 0.1);
        expect(params.weightDecay, 0.01);
      });

      test('should handle missing fields', () {
        final json = <String, dynamic>{};

        final params = Hyperparameters.fromJson(json);

        expect(params.trainingSteps, isNull);
        expect(params.learningRate, isNull);
        expect(params.warmupFraction, isNull);
        expect(params.weightDecay, isNull);
      });

      test('should handle partial fields', () {
        final json = <String, dynamic>{'training_steps': 50};

        final params = Hyperparameters.fromJson(json);

        expect(params.trainingSteps, 50);
        expect(params.learningRate, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields', () {
        const params = Hyperparameters(
          trainingSteps: 100,
          learningRate: 0.0001,
          warmupFraction: 0.1,
          weightDecay: 0.01,
        );

        final json = params.toJson();

        expect(json['training_steps'], 100);
        expect(json['learning_rate'], 0.0001);
        expect(json['warmup_fraction'], 0.1);
        expect(json['weight_decay'], 0.01);
      });

      test('should not include null fields', () {
        const params = Hyperparameters(trainingSteps: 100);

        final json = params.toJson();

        expect(json['training_steps'], 100);
        expect(json.containsKey('learning_rate'), isFalse);
        expect(json.containsKey('warmup_fraction'), isFalse);
        expect(json.containsKey('weight_decay'), isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        const params1 = Hyperparameters(
          trainingSteps: 100,
          learningRate: 0.0001,
        );
        const params2 = Hyperparameters(
          trainingSteps: 100,
          learningRate: 0.0001,
        );

        expect(params1, equals(params2));
        expect(params1.hashCode, equals(params2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const params1 = Hyperparameters(trainingSteps: 100);
        const params2 = Hyperparameters(trainingSteps: 200);

        expect(params1, isNot(equals(params2)));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        const params = Hyperparameters(
          trainingSteps: 100,
          learningRate: 0.0001,
        );

        expect(params.toString(), contains('Hyperparameters'));
        expect(params.toString(), contains('100'));
      });
    });
  });
}
