import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EvalGrader', () {
    test('fromJson parses label_model type', () {
      final json = {
        'type': 'label_model',
        'name': 'sentiment',
        'model': 'gpt-4o-mini',
        'labels': ['positive', 'negative'],
        'passing_labels': ['positive'],
        'input': [
          {'role': 'user', 'content': 'Classify: {{sample.output_text}}'},
        ],
      };

      final grader = EvalGrader.fromJson(json);

      expect(grader, isA<LabelModelGrader>());
      final label = grader as LabelModelGrader;
      expect(label.type, 'label_model');
      expect(label.name, 'sentiment');
      expect(label.model, 'gpt-4o-mini');
      expect(label.labels, ['positive', 'negative']);
      expect(label.passingLabels, ['positive']);
      expect(label.input, hasLength(1));
    });

    test('fromJson parses string_check type', () {
      final json = {
        'type': 'string_check',
        'name': 'matches_hello',
        'input': '{{sample.output_text}}',
        'operation': 'ilike',
        'reference': '%hello%',
      };

      final grader = EvalGrader.fromJson(json);

      expect(grader, isA<StringCheckGrader>());
      final check = grader as StringCheckGrader;
      expect(check.type, 'string_check');
      expect(check.name, 'matches_hello');
      expect(check.input, '{{sample.output_text}}');
      expect(check.operation, StringCheckOperation.ilike);
      expect(check.reference, '%hello%');
    });

    test('fromJson parses text_similarity type', () {
      final json = {
        'type': 'text_similarity',
        'name': 'similarity',
        'input': '{{sample.output_text}}',
        'reference': '{{item.expected}}',
        'evaluation_metric': 'cosine',
        'pass_threshold': 0.8,
      };

      final grader = EvalGrader.fromJson(json);

      expect(grader, isA<TextSimilarityGrader>());
      final sim = grader as TextSimilarityGrader;
      expect(sim.type, 'text_similarity');
      expect(sim.name, 'similarity');
      expect(sim.evaluationMetric, TextSimilarityMetric.cosine);
      expect(sim.passThreshold, 0.8);
    });

    test('fromJson parses python type', () {
      final json = {
        'type': 'python',
        'name': 'custom_check',
        'source': 'def grade(item, sample): return 1.0',
        'pass_threshold': 0.5,
      };

      final grader = EvalGrader.fromJson(json);

      expect(grader, isA<PythonGrader>());
      final py = grader as PythonGrader;
      expect(py.type, 'python');
      expect(py.name, 'custom_check');
      expect(py.source, 'def grade(item, sample): return 1.0');
      expect(py.passThreshold, 0.5);
    });

    test('fromJson parses score_model type', () {
      final json = {
        'type': 'score_model',
        'name': 'quality_score',
        'model': 'gpt-4o-mini',
        'input': [
          {'role': 'system', 'content': 'Rate the quality from 0-10.'},
        ],
        'pass_threshold': 7.0,
      };

      final grader = EvalGrader.fromJson(json);

      expect(grader, isA<ScoreModelGrader>());
      final score = grader as ScoreModelGrader;
      expect(score.type, 'score_model');
      expect(score.name, 'quality_score');
      expect(score.model, 'gpt-4o-mini');
      expect(score.passThreshold, 7.0);
    });

    test('fromJson throws on unknown type', () {
      final json = {'type': 'unknown', 'name': 'test'};

      expect(() => EvalGrader.fromJson(json), throwsA(isA<FormatException>()));
    });
  });

  group('LabelModelGrader', () {
    test('static factory creates correctly', () {
      final grader = EvalGrader.labelModel(
        name: 'test',
        model: 'gpt-4o-mini',
        labels: ['yes', 'no'],
        passingLabels: ['yes'],
        input: [const LabelModelInput.user('Classify this')],
      );

      expect(grader.name, 'test');
      expect(grader.model, 'gpt-4o-mini');
      expect(grader.labels, ['yes', 'no']);
      expect(grader.passingLabels, ['yes']);
    });

    test('toJson serializes correctly', () {
      const grader = LabelModelGrader(
        name: 'test',
        model: 'gpt-4o-mini',
        labels: ['a', 'b'],
        passingLabels: ['a'],
        input: [
          LabelModelInput.system('You are a classifier'),
          LabelModelInput.user('Classify: {{sample.output_text}}'),
        ],
      );

      final json = grader.toJson();

      expect(json['type'], 'label_model');
      expect(json['name'], 'test');
      expect(json['model'], 'gpt-4o-mini');
      expect(json['labels'], ['a', 'b']);
      expect(json['passing_labels'], ['a']);
      expect(json['input'], hasLength(2));
    });
  });

  group('StringCheckGrader', () {
    test('static factory creates correctly', () {
      final grader = EvalGrader.stringCheck(
        name: 'check',
        input: '{{sample.output_text}}',
        operation: StringCheckOperation.ilike,
        reference: '%hello%',
      );

      expect(grader.name, 'check');
      expect(grader.input, '{{sample.output_text}}');
      expect(grader.operation, StringCheckOperation.ilike);
      expect(grader.reference, '%hello%');
    });

    test('toJson serializes correctly', () {
      const grader = StringCheckGrader(
        name: 'test',
        input: '{{sample.output_text}}',
        operation: StringCheckOperation.equals,
        reference: 'expected',
      );

      final json = grader.toJson();

      expect(json['type'], 'string_check');
      expect(json['name'], 'test');
      expect(json['operation'], 'eq');
      expect(json['reference'], 'expected');
    });
  });

  group('StringCheckOperation', () {
    test('fromJson parses all operations', () {
      expect(StringCheckOperation.fromJson('eq'), StringCheckOperation.equals);
      expect(
        StringCheckOperation.fromJson('ne'),
        StringCheckOperation.notEquals,
      );
      expect(StringCheckOperation.fromJson('like'), StringCheckOperation.like);
      expect(
        StringCheckOperation.fromJson('ilike'),
        StringCheckOperation.ilike,
      );
    });

    test('toJson returns correct values', () {
      expect(StringCheckOperation.equals.toJson(), 'eq');
      expect(StringCheckOperation.notEquals.toJson(), 'ne');
      expect(StringCheckOperation.like.toJson(), 'like');
      expect(StringCheckOperation.ilike.toJson(), 'ilike');
    });
  });

  group('TextSimilarityGrader', () {
    test('static factory creates correctly', () {
      final grader = EvalGrader.textSimilarity(
        name: 'similarity',
        input: '{{sample.output_text}}',
        reference: '{{item.expected}}',
        evaluationMetric: TextSimilarityMetric.cosine,
        passThreshold: 0.9,
      );

      expect(grader.name, 'similarity');
      expect(grader.evaluationMetric, TextSimilarityMetric.cosine);
      expect(grader.passThreshold, 0.9);
    });

    test('toJson serializes correctly', () {
      const grader = TextSimilarityGrader(
        name: 'test',
        input: '{{sample.output_text}}',
        reference: '{{item.expected}}',
        evaluationMetric: TextSimilarityMetric.bleu,
        passThreshold: 0.7,
      );

      final json = grader.toJson();

      expect(json['type'], 'text_similarity');
      expect(json['evaluation_metric'], 'bleu');
      expect(json['pass_threshold'], 0.7);
    });
  });

  group('TextSimilarityMetric', () {
    test('fromJson parses all metrics', () {
      expect(
        TextSimilarityMetric.fromJson('cosine'),
        TextSimilarityMetric.cosine,
      );
      expect(
        TextSimilarityMetric.fromJson('fuzzy_match'),
        TextSimilarityMetric.fuzzyMatch,
      );
      expect(
        TextSimilarityMetric.fromJson('levenshtein'),
        TextSimilarityMetric.levenshtein,
      );
      expect(TextSimilarityMetric.fromJson('bleu'), TextSimilarityMetric.bleu);
    });
  });

  group('PythonGrader', () {
    test('static factory creates correctly', () {
      final grader = EvalGrader.python(
        name: 'custom',
        source: 'def grade(item, sample): return 1.0',
        passThreshold: 0.5,
      );

      expect(grader.name, 'custom');
      expect(grader.source, 'def grade(item, sample): return 1.0');
      expect(grader.passThreshold, 0.5);
    });

    test('toJson serializes correctly', () {
      const grader = PythonGrader(
        name: 'test',
        source: 'return 1.0',
        passThreshold: 0.9,
      );

      final json = grader.toJson();

      expect(json['type'], 'python');
      expect(json['name'], 'test');
      expect(json['source'], 'return 1.0');
      expect(json['pass_threshold'], 0.9);
    });
  });

  group('ScoreModelGrader', () {
    test('static factory creates correctly', () {
      final grader = EvalGrader.scoreModel(
        name: 'quality',
        model: 'gpt-4o-mini',
        input: [const ScoreModelInput.system('Rate from 0-10')],
        passThreshold: 7.0,
      );

      expect(grader.name, 'quality');
      expect(grader.model, 'gpt-4o-mini');
      expect(grader.passThreshold, 7.0);
    });

    test('toJson serializes correctly', () {
      const grader = ScoreModelGrader(
        name: 'test',
        model: 'gpt-4o-mini',
        input: [
          ScoreModelInput.system('Rate quality'),
          ScoreModelInput.user('Text: {{sample.output_text}}'),
        ],
        passThreshold: 5.0,
      );

      final json = grader.toJson();

      expect(json['type'], 'score_model');
      expect(json['model'], 'gpt-4o-mini');
      expect(json['input'], hasLength(2));
      expect(json['pass_threshold'], 5.0);
    });
  });

  group('LabelModelInput', () {
    test('fromJson parses correctly', () {
      final json = {'role': 'user', 'content': 'Test message'};

      final input = LabelModelInput.fromJson(json);

      expect(input.role, 'user');
      expect(input.content, 'Test message');
    });

    test('static factories create correct roles', () {
      expect(const LabelModelInput.system('test').role, 'system');
      expect(const LabelModelInput.user('test').role, 'user');
      expect(const LabelModelInput.assistant('test').role, 'assistant');
    });
  });
}
