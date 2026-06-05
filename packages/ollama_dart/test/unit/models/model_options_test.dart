import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ModelOptions', () {
    test('serializes and deserializes core options', () {
      const options = ModelOptions(temperature: 0.7, topK: 40, numPredict: 128);

      final json = options.toJson();
      expect(json['temperature'], 0.7);
      expect(json['top_k'], 40);
      expect(json['num_predict'], 128);

      final restored = ModelOptions.fromJson(json);
      expect(restored.temperature, 0.7);
      expect(restored.topK, 40);
      expect(restored.numPredict, 128);
    });

    test('draftNumPredict serializes, deserializes, copyWith, toString', () {
      const options = ModelOptions(draftNumPredict: 4);

      final json = options.toJson();
      expect(json['draft_num_predict'], 4);

      final restored = ModelOptions.fromJson(json);
      expect(restored.draftNumPredict, 4);

      // 0 disables speculative drafting and must still serialize.
      final disabled = options.copyWith(draftNumPredict: 0);
      expect(disabled.draftNumPredict, 0);
      expect(disabled.toJson()['draft_num_predict'], 0);

      // copyWith can clear the value back to null.
      expect(options.copyWith(draftNumPredict: null).draftNumPredict, isNull);

      expect(options.toString(), contains('draftNumPredict: 4'));
    });

    test('draftNumPredict omitted when absent', () {
      const options = ModelOptions(temperature: 0.5);

      expect(options.toJson().containsKey('draft_num_predict'), isFalse);
      expect(options.draftNumPredict, isNull);
    });
  });
}
