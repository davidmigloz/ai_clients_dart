import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Prediction', () {
    group('ContentPrediction', () {
      test('creates with content factory', () {
        const prediction = Prediction.content('expected output');

        expect(prediction, isA<ContentPrediction>());
        expect((prediction as ContentPrediction).content, 'expected output');
      });

      test('creates directly', () {
        const prediction = ContentPrediction('some code');

        expect(prediction.content, 'some code');
      });

      test('serializes to JSON', () {
        const prediction = ContentPrediction('function test() {}');
        final json = prediction.toJson();

        expect(json, {'type': 'content', 'content': 'function test() {}'});
      });

      test('deserializes from JSON', () {
        final json = {'type': 'content', 'content': 'predicted text'};
        final prediction = Prediction.fromJson(json);

        expect(prediction, isA<ContentPrediction>());
        expect((prediction as ContentPrediction).content, 'predicted text');
      });

      test('equality works correctly', () {
        const pred1 = ContentPrediction('abc');
        const pred2 = ContentPrediction('abc');
        const pred3 = ContentPrediction('xyz');

        expect(pred1, equals(pred2));
        expect(pred1.hashCode, equals(pred2.hashCode));
        expect(pred1, isNot(equals(pred3)));
      });

      test('toString returns readable format', () {
        const prediction = ContentPrediction('hello world');

        expect(prediction.toString(), contains('11 chars'));
      });
    });

    group('fromJson', () {
      test('throws for unknown type', () {
        final json = {'type': 'unknown', 'content': 'test'};

        expect(() => Prediction.fromJson(json), throwsA(isA<ArgumentError>()));
      });

      test('handles empty content', () {
        final json = {'type': 'content', 'content': ''};
        final prediction = Prediction.fromJson(json);

        expect((prediction as ContentPrediction).content, '');
      });
    });
  });
}
