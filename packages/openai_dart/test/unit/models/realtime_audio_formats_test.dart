import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('RealtimeAudioFormats', () {
    test('AudioPcm with rate roundtrips', () {
      const format = AudioPcm(rate: 24000);
      expect(format.toJson(), {'type': 'audio/pcm', 'rate': 24000});

      final parsed = RealtimeAudioFormats.fromJson(format.toJson());
      expect(parsed, isA<AudioPcm>());
      expect((parsed as AudioPcm).rate, 24000);
      expect(parsed, format);
    });

    test('AudioPcm with null rate roundtrips and omits the field', () {
      const format = AudioPcm();
      expect(format.toJson(), {'type': 'audio/pcm'});
      final parsed = RealtimeAudioFormats.fromJson(format.toJson());
      expect(parsed, isA<AudioPcm>());
      expect((parsed as AudioPcm).rate, isNull);
    });

    test('AudioPcmu roundtrips', () {
      const format = AudioPcmu();
      expect(format.toJson(), {'type': 'audio/pcmu'});
      final parsed = RealtimeAudioFormats.fromJson(format.toJson());
      expect(parsed, isA<AudioPcmu>());
    });

    test('AudioPcma roundtrips', () {
      const format = AudioPcma();
      expect(format.toJson(), {'type': 'audio/pcma'});
      final parsed = RealtimeAudioFormats.fromJson(format.toJson());
      expect(parsed, isA<AudioPcma>());
    });

    test('discriminator dispatch returns correct subclass', () {
      expect(
        RealtimeAudioFormats.fromJson({'type': 'audio/pcm', 'rate': 24000}),
        isA<AudioPcm>(),
      );
      expect(
        RealtimeAudioFormats.fromJson({'type': 'audio/pcmu'}),
        isA<AudioPcmu>(),
      );
      expect(
        RealtimeAudioFormats.fromJson({'type': 'audio/pcma'}),
        isA<AudioPcma>(),
      );
    });

    test('unknown type round-trips through UnknownRealtimeAudioFormats', () {
      final json = <String, dynamic>{'type': 'audio/future', 'extra': 42};
      final parsed = RealtimeAudioFormats.fromJson(json);
      expect(parsed, isA<UnknownRealtimeAudioFormats>());
      expect(parsed.type, 'audio/future');
      final encoded = parsed.toJson();
      expect(encoded['type'], 'audio/future');
      expect(encoded['extra'], 42);

      // Round-trip preserves the raw payload byte-for-byte.
      expect(
        RealtimeAudioFormats.fromJson(encoded),
        isA<UnknownRealtimeAudioFormats>(),
      );
    });

    test('factory constructors produce correct subclasses', () {
      expect(
        const RealtimeAudioFormats.pcm(rate: 24000),
        const AudioPcm(rate: 24000),
      );
      expect(const RealtimeAudioFormats.pcmu(), const AudioPcmu());
      expect(const RealtimeAudioFormats.pcma(), const AudioPcma());
    });

    test('AudioPcm copyWith updates and clears rate', () {
      const format = AudioPcm(rate: 24000);
      expect(format.copyWith(rate: 16000).rate, 16000);
      expect(format.copyWith(rate: null).rate, isNull);
      expect(format.copyWith().rate, 24000);
    });

    test('AudioPcm equality and hashCode are content-based', () {
      const a = AudioPcm(rate: 24000);
      const b = AudioPcm(rate: 24000);
      const c = AudioPcm(rate: 16000);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('subclass fromJson rejects mismatched type', () {
      final pcmuJson = <String, dynamic>{'type': 'audio/pcmu'};
      final pcmJson = <String, dynamic>{'type': 'audio/pcm'};
      expect(() => AudioPcm.fromJson(pcmuJson), throwsFormatException);
      expect(() => AudioPcmu.fromJson(pcmJson), throwsFormatException);
    });
  });
}
