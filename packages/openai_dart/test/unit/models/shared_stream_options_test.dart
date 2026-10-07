import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final enabled in [true, false]) {
    test('existing Responses holder forwards shared obfuscation=$enabled', () {
      final request = CreateResponseRequest(
        model: 'fixture-model',
        input: const ResponseInput.text('Hello'),
        streamOptions: StreamOptions(includeObfuscation: enabled),
      );
      expect(request.toJson()['stream_options'], {
        'include_obfuscation': enabled,
      });
      final parsed = CreateResponseRequest.fromJson(request.toJson());
      expect(parsed.streamOptions?.includeObfuscation, enabled);
      expect(parsed.streamOptions?.includeUsage, isNull);
      expect(parsed, request);
      expect(parsed.hashCode, request.hashCode);
      expect(
        request.copyWith(
          streamOptions: request.streamOptions!.copyWith(
            includeObfuscation: !enabled,
          ),
        ),
        isNot(request),
      );
      expect(
        request
            .copyWith(
              streamOptions: request.streamOptions!.copyWith(
                includeObfuscation: null,
              ),
            )
            .toJson()['stream_options'],
        isEmpty,
      );
      expect(
        request
            .copyWith(streamOptions: null)
            .toJson()
            .containsKey('stream_options'),
        isFalse,
      );
    });
  }
}
