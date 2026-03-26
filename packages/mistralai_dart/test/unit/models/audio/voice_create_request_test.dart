import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('VoiceCreateRequest', () {
    group('constructor', () {
      test('creates with required fields', () {
        const request = VoiceCreateRequest(
          name: 'My Voice',
          sampleAudio: 'base64encodedaudio==',
        );
        expect(request.name, 'My Voice');
        expect(request.sampleAudio, 'base64encodedaudio==');
        expect(request.slug, isNull);
        expect(request.gender, isNull);
        expect(request.age, isNull);
        expect(request.color, isNull);
        expect(request.languages, isNull);
        expect(request.tags, isNull);
        expect(request.retentionNotice, isNull);
        expect(request.sampleFilename, isNull);
      });

      test('creates with all fields', () {
        const request = VoiceCreateRequest(
          name: 'Custom Voice',
          sampleAudio: 'dGVzdGF1ZGlv',
          slug: 'custom-voice-v1',
          gender: 'female',
          age: 28,
          color: '#E74C3C',
          languages: ['en', 'es'],
          tags: ['premium', 'warm'],
          retentionNotice: 90,
          sampleFilename: 'sample.wav',
        );
        expect(request.name, 'Custom Voice');
        expect(request.sampleAudio, 'dGVzdGF1ZGlv');
        expect(request.slug, 'custom-voice-v1');
        expect(request.gender, 'female');
        expect(request.age, 28);
        expect(request.color, '#E74C3C');
        expect(request.languages, ['en', 'es']);
        expect(request.tags, ['premium', 'warm']);
        expect(request.retentionNotice, 90);
        expect(request.sampleFilename, 'sample.wav');
      });
    });

    group('fromJson', () {
      test('deserializes all fields with snake_case keys', () {
        final json = <String, dynamic>{
          'name': 'Voice From JSON',
          'sample_audio': 'YXVkaW9kYXRh',
          'slug': 'json-voice',
          'gender': 'male',
          'age': 35,
          'color': '#3498DB',
          'languages': ['en', 'de'],
          'tags': ['test'],
          'retention_notice': 60,
          'sample_filename': 'recording.mp3',
        };
        final request = VoiceCreateRequest.fromJson(json);
        expect(request.name, 'Voice From JSON');
        expect(request.sampleAudio, 'YXVkaW9kYXRh');
        expect(request.slug, 'json-voice');
        expect(request.gender, 'male');
        expect(request.age, 35);
        expect(request.color, '#3498DB');
        expect(request.languages, ['en', 'de']);
        expect(request.tags, ['test']);
        expect(request.retentionNotice, 60);
        expect(request.sampleFilename, 'recording.mp3');
      });

      test('deserializes required fields only', () {
        final json = <String, dynamic>{
          'name': 'Minimal Voice',
          'sample_audio': 'c2FtcGxl',
        };
        final request = VoiceCreateRequest.fromJson(json);
        expect(request.name, 'Minimal Voice');
        expect(request.sampleAudio, 'c2FtcGxl');
        expect(request.slug, isNull);
        expect(request.gender, isNull);
        expect(request.age, isNull);
        expect(request.color, isNull);
        expect(request.languages, isNull);
        expect(request.tags, isNull);
        expect(request.retentionNotice, isNull);
        expect(request.sampleFilename, isNull);
      });
    });

    group('toJson', () {
      test('produces correct snake_case keys', () {
        const request = VoiceCreateRequest(
          name: 'ToJson Voice',
          sampleAudio: 'dG9qc29u',
          slug: 'tojson',
          gender: 'female',
          age: 22,
          color: '#2ECC71',
          languages: ['fr'],
          tags: ['new'],
          retentionNotice: 14,
          sampleFilename: 'voice.ogg',
        );
        final json = request.toJson();
        expect(json['name'], 'ToJson Voice');
        expect(json['sample_audio'], 'dG9qc29u');
        expect(json['slug'], 'tojson');
        expect(json['gender'], 'female');
        expect(json['age'], 22);
        expect(json['color'], '#2ECC71');
        expect(json['languages'], ['fr']);
        expect(json['tags'], ['new']);
        expect(json['retention_notice'], 14);
        expect(json['sample_filename'], 'voice.ogg');
      });

      test('omits null optional fields', () {
        const request = VoiceCreateRequest(
          name: 'Sparse',
          sampleAudio: 'c3BhcnNl',
        );
        final json = request.toJson();
        expect(json['name'], 'Sparse');
        expect(json['sample_audio'], 'c3BhcnNl');
        expect(json.containsKey('slug'), isFalse);
        expect(json.containsKey('gender'), isFalse);
        expect(json.containsKey('age'), isFalse);
        expect(json.containsKey('color'), isFalse);
        expect(json.containsKey('languages'), isFalse);
        expect(json.containsKey('tags'), isFalse);
        expect(json.containsKey('retention_notice'), isFalse);
        expect(json.containsKey('sample_filename'), isFalse);
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = VoiceCreateRequest(
          name: 'RoundTrip Voice',
          sampleAudio: 'cm91bmR0cmlw',
          slug: 'roundtrip',
          gender: 'male',
          age: 40,
          color: '#F1C40F',
          languages: ['en', 'ja', 'ko'],
          tags: ['verified', 'hd'],
          retentionNotice: 365,
          sampleFilename: 'rt_sample.flac',
        );
        final json = original.toJson();
        final restored = VoiceCreateRequest.fromJson(json);
        expect(restored, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with updated required fields', () {
        const original = VoiceCreateRequest(
          name: 'Original',
          sampleAudio: 'b3JpZ2luYWw=',
        );
        final updated = original.copyWith(
          name: 'Updated',
          sampleAudio: 'dXBkYXRlZA==',
        );
        expect(updated.name, 'Updated');
        expect(updated.sampleAudio, 'dXBkYXRlZA==');
      });

      test('copies with new optional fields', () {
        const original = VoiceCreateRequest(
          name: 'Base',
          sampleAudio: 'YmFzZQ==',
        );
        final updated = original.copyWith(
          slug: 'new-slug',
          gender: 'female',
          age: 30,
          languages: ['en'],
          retentionNotice: 7,
          sampleFilename: 'new.wav',
        );
        expect(updated.name, 'Base');
        expect(updated.sampleAudio, 'YmFzZQ==');
        expect(updated.slug, 'new-slug');
        expect(updated.gender, 'female');
        expect(updated.age, 30);
        expect(updated.languages, ['en']);
        expect(updated.retentionNotice, 7);
        expect(updated.sampleFilename, 'new.wav');
      });

      test('sets optional fields to null using sentinel', () {
        const original = VoiceCreateRequest(
          name: 'With Fields',
          sampleAudio: 'd2l0aA==',
          slug: 'has-slug',
          gender: 'male',
          age: 25,
          languages: ['en'],
          tags: ['tag'],
          retentionNotice: 30,
          sampleFilename: 'file.wav',
        );
        final updated = original.copyWith(
          slug: null,
          gender: null,
          age: null,
          languages: null,
          tags: null,
          retentionNotice: null,
          sampleFilename: null,
        );
        expect(updated.name, 'With Fields');
        expect(updated.sampleAudio, 'd2l0aA==');
        expect(updated.slug, isNull);
        expect(updated.gender, isNull);
        expect(updated.age, isNull);
        expect(updated.languages, isNull);
        expect(updated.tags, isNull);
        expect(updated.retentionNotice, isNull);
        expect(updated.sampleFilename, isNull);
      });

      test('preserves fields when not specified', () {
        const original = VoiceCreateRequest(
          name: 'Preserve',
          sampleAudio: 'cHJlc2VydmU=',
          slug: 'keep-this',
          gender: 'female',
        );
        final updated = original.copyWith(name: 'New Name');
        expect(updated.name, 'New Name');
        expect(updated.sampleAudio, 'cHJlc2VydmU=');
        expect(updated.slug, 'keep-this');
        expect(updated.gender, 'female');
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const request1 = VoiceCreateRequest(
          name: 'Same',
          sampleAudio: 'c2FtZQ==',
          slug: 'same-slug',
          age: 20,
        );
        const request2 = VoiceCreateRequest(
          name: 'Same',
          sampleAudio: 'c2FtZQ==',
          slug: 'same-slug',
          age: 20,
        );
        expect(request1, equals(request2));
        expect(request1.hashCode, request2.hashCode);
      });

      test('not equal when fields differ', () {
        const request1 = VoiceCreateRequest(
          name: 'Voice A',
          sampleAudio: 'YQ==',
        );
        const request2 = VoiceCreateRequest(
          name: 'Voice B',
          sampleAudio: 'Yg==',
        );
        expect(request1, isNot(equals(request2)));
      });
    });
  });
}
