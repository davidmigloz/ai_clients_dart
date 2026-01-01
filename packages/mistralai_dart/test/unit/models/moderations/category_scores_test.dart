import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CategoryScores', () {
    group('fromJson', () {
      test('should parse all category scores', () {
        final json = <String, dynamic>{
          'sexual': 0.1,
          'hate': 0.2,
          'violence': 0.3,
          'self-harm': 0.4,
          'sexual/minors': 0.5,
          'hate/threatening': 0.6,
          'violence/graphic': 0.7,
          'self-harm/intent': 0.8,
          'self-harm/instructions': 0.85,
          'harassment': 0.9,
          'harassment/threatening': 0.95,
          'pii': 0.15,
        };

        final scores = CategoryScores.fromJson(json);

        expect(scores.sexual, 0.1);
        expect(scores.hate, 0.2);
        expect(scores.violence, 0.3);
        expect(scores.selfHarm, 0.4);
        expect(scores.sexualMinors, 0.5);
        expect(scores.hateThreatening, 0.6);
        expect(scores.violenceGraphic, 0.7);
        expect(scores.selfHarmIntent, 0.8);
        expect(scores.selfHarmInstructions, 0.85);
        expect(scores.harassment, 0.9);
        expect(scores.harassmentThreatening, 0.95);
        expect(scores.pii, 0.15);
      });

      test('should use default values for missing fields', () {
        final json = <String, dynamic>{};

        final scores = CategoryScores.fromJson(json);

        expect(scores.sexual, 0.0);
        expect(scores.hate, 0.0);
        expect(scores.violence, 0.0);
        expect(scores.selfHarm, 0.0);
        expect(scores.sexualMinors, 0.0);
        expect(scores.hateThreatening, 0.0);
        expect(scores.violenceGraphic, 0.0);
        expect(scores.selfHarmIntent, 0.0);
        expect(scores.selfHarmInstructions, 0.0);
        expect(scores.harassment, 0.0);
        expect(scores.harassmentThreatening, 0.0);
        expect(scores.pii, isNull);
      });

      test('should handle partial scores', () {
        final json = <String, dynamic>{'sexual': 0.5, 'pii': 0.8};

        final scores = CategoryScores.fromJson(json);

        expect(scores.sexual, 0.5);
        expect(scores.pii, 0.8);
        expect(scores.hate, 0.0);
      });
    });

    group('toJson', () {
      test('should serialize all category scores', () {
        const scores = CategoryScores(
          sexual: 0.1,
          hate: 0.2,
          violence: 0.3,
          selfHarm: 0.4,
          sexualMinors: 0.5,
          hateThreatening: 0.6,
          violenceGraphic: 0.7,
          selfHarmIntent: 0.8,
          selfHarmInstructions: 0.85,
          harassment: 0.9,
          harassmentThreatening: 0.95,
          pii: 0.15,
        );

        final json = scores.toJson();

        expect(json['sexual'], 0.1);
        expect(json['hate'], 0.2);
        expect(json['violence'], 0.3);
        expect(json['self-harm'], 0.4);
        expect(json['sexual/minors'], 0.5);
        expect(json['hate/threatening'], 0.6);
        expect(json['violence/graphic'], 0.7);
        expect(json['self-harm/intent'], 0.8);
        expect(json['self-harm/instructions'], 0.85);
        expect(json['harassment'], 0.9);
        expect(json['harassment/threatening'], 0.95);
        expect(json['pii'], 0.15);
      });

      test('should not include pii if null', () {
        const scores = CategoryScores(
          sexual: 0.0,
          hate: 0.0,
          violence: 0.0,
          selfHarm: 0.0,
          sexualMinors: 0.0,
          hateThreatening: 0.0,
          violenceGraphic: 0.0,
          selfHarmIntent: 0.0,
          selfHarmInstructions: 0.0,
          harassment: 0.0,
          harassmentThreatening: 0.0,
        );

        final json = scores.toJson();

        expect(json.containsKey('pii'), isFalse);
      });
    });

    group('equality', () {
      test('should be equal when core scores are the same', () {
        const scores1 = CategoryScores(
          sexual: 0.5,
          hate: 0.3,
          violence: 0.2,
          selfHarm: 0.1,
          sexualMinors: 0.0,
          hateThreatening: 0.0,
          violenceGraphic: 0.0,
          selfHarmIntent: 0.0,
          selfHarmInstructions: 0.0,
          harassment: 0.0,
          harassmentThreatening: 0.0,
        );
        const scores2 = CategoryScores(
          sexual: 0.5,
          hate: 0.3,
          violence: 0.2,
          selfHarm: 0.1,
          sexualMinors: 0.0,
          hateThreatening: 0.0,
          violenceGraphic: 0.0,
          selfHarmIntent: 0.0,
          selfHarmInstructions: 0.0,
          harassment: 0.0,
          harassmentThreatening: 0.0,
        );

        expect(scores1, equals(scores2));
        expect(scores1.hashCode, equals(scores2.hashCode));
      });

      test('should not be equal when scores differ', () {
        const scores1 = CategoryScores(
          sexual: 0.5,
          hate: 0.0,
          violence: 0.0,
          selfHarm: 0.0,
          sexualMinors: 0.0,
          hateThreatening: 0.0,
          violenceGraphic: 0.0,
          selfHarmIntent: 0.0,
          selfHarmInstructions: 0.0,
          harassment: 0.0,
          harassmentThreatening: 0.0,
        );
        const scores2 = CategoryScores(
          sexual: 0.6,
          hate: 0.0,
          violence: 0.0,
          selfHarm: 0.0,
          sexualMinors: 0.0,
          hateThreatening: 0.0,
          violenceGraphic: 0.0,
          selfHarmIntent: 0.0,
          selfHarmInstructions: 0.0,
          harassment: 0.0,
          harassmentThreatening: 0.0,
        );

        expect(scores1, isNot(equals(scores2)));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        const scores = CategoryScores(
          sexual: 0.5,
          hate: 0.3,
          violence: 0.2,
          selfHarm: 0.0,
          sexualMinors: 0.0,
          hateThreatening: 0.0,
          violenceGraphic: 0.0,
          selfHarmIntent: 0.0,
          selfHarmInstructions: 0.0,
          harassment: 0.4,
          harassmentThreatening: 0.0,
        );

        expect(scores.toString(), contains('CategoryScores'));
        expect(scores.toString(), contains('sexual: 0.5'));
        expect(scores.toString(), contains('hate: 0.3'));
        expect(scores.toString(), contains('violence: 0.2'));
        expect(scores.toString(), contains('harassment: 0.4'));
      });
    });
  });
}
