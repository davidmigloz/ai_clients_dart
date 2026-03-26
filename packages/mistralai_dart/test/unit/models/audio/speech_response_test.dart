import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SpeechResponse', () {
    test('constructor sets audioData', () {
      const response = SpeechResponse(audioData: 'base64data');
      expect(response.audioData, 'base64data');
    });

    test('fromJson parses audio_data', () {
      final response = SpeechResponse.fromJson(const {'audio_data': 'data'});
      expect(response.audioData, 'data');
    });

    test('toJson produces correct map', () {
      const response = SpeechResponse(audioData: 'data');
      expect(response.toJson(), {'audio_data': 'data'});
    });

    test('equality', () {
      const a = SpeechResponse(audioData: 'data');
      const b = SpeechResponse(audioData: 'data');
      const c = SpeechResponse(audioData: 'other');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString mentions char count', () {
      const response = SpeechResponse(audioData: 'abcdef');
      final str = response.toString();
      expect(str, contains('6 chars'));
    });
  });
}
