import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const oldNames = [
    'alloy',
    'ash',
    'ballad',
    'coral',
    'echo',
    'fable',
    'nova',
    'onyx',
    'sage',
    'shimmer',
    'verse',
  ];
  const oldFormats = ['wav', 'mp3', 'flac', 'opus', 'pcm16'];
  test('old const calls, enum names and indices stay usable', () {
    const config = ChatAudioConfig(
      voice: ChatAudioVoice.alloy,
      format: ChatAudioFormat.pcm16,
    );
    expect(config.toJson(), {'voice': 'alloy', 'format': 'pcm16'});
    expect(ChatAudioVoice.values.map((v) => v.name), [
      ...oldNames,
      'marin',
      'cedar',
    ]);
    expect(ChatAudioFormat.values.map((v) => v.name), [...oldFormats, 'aac']);
    for (var i = 0; i < oldNames.length; i++) {
      expect(ChatAudioVoice.values[i].index, i);
      expect(ChatAudioVoice.values[i].toJson(), oldNames[i]);
    }
    for (var i = 0; i < oldFormats.length; i++) {
      expect(ChatAudioFormat.values[i].index, i);
      expect(ChatAudioFormat.values[i].toJson(), oldFormats[i]);
    }
    expect(SpeechResponseFormat.pcm.toJson(), 'pcm');
    expect(ChatAudioFormat.pcm16.toJson(), 'pcm16');
  });
  for (final voice in ChatAudioVoice.values) {
    for (final format in ChatAudioFormat.values) {
      test('${voice.name}/${format.name} round-trip and wire identity', () {
        final value = ChatAudioConfig(voice: voice, format: format);
        final json = {'voice': voice.toJson(), 'format': format.toJson()};
        final parsed = ChatAudioConfig.fromJson(json);
        final open = ChatAudioConfig(
          voice: AudioVoice.named(voice.toJson()),
          format: format,
        );
        expect(value.toJson(), json);
        expect(parsed.voice, voice);
        expect(parsed, value);
        expect(parsed.hashCode, value.hashCode);
        expect(open, value);
        expect(open.hashCode, value.hashCode);
        expect({parsed, open, value}, hasLength(1));
        expect(value.copyWith(), value);
      });
    }
  }
  for (final name in ['', 'future-private-name', 'Voice 🦊', 'ALLOY']) {
    test('open name retains exact provider spelling: ${name.length} chars', () {
      final config = ChatAudioConfig(
        voice: AudioVoice.named(name),
        format: ChatAudioFormat.aac,
      );
      expect(config.toJson(), {'voice': name, 'format': 'aac'});
      final parsed = ChatAudioConfig.fromJson(config.toJson());
      expect(parsed.voice, AudioVoice.named(name));
      expect(parsed, config);
      expect(parsed.hashCode, config.hashCode);
      expect(
        parsed.toString(),
        isNot(contains(name.isEmpty ? 'voice: ,' : name)),
      );
    });
  }
  for (final id in ['', 'private-id', 'unprefixed 🦊', 'x' * 500]) {
    test('custom reference uses closed ID shape: ${id.length} chars', () {
      final config = ChatAudioConfig(
        voice: AudioVoice.custom(id),
        format: ChatAudioFormat.aac,
      );
      final wire = {
        'voice': {'id': id},
        'format': 'aac',
      };
      expect(config.toJson(), wire);
      final parsed = ChatAudioConfig.fromJson(wire);
      expect(parsed, config);
      expect(parsed.hashCode, config.hashCode);
      expect(parsed.voice, AudioVoice.custom(id));
      if (id.isNotEmpty) expect(parsed.toString(), isNot(contains(id)));
    });
  }
  test('copy replaces both typed fields and retains effective identity', () {
    const old = ChatAudioConfig(
      voice: ChatAudioVoice.alloy,
      format: ChatAudioFormat.wav,
    );
    final named = old.copyWith(
      voice: const AudioVoice.named('new-private-name'),
    );
    final custom = old.copyWith(
      voice: const AudioVoice.custom('new-private-id'),
    );
    final format = old.copyWith(format: ChatAudioFormat.aac);
    for (final changed in [named, custom, format]) {
      expect(changed, isNot(old));
      expect(changed.hashCode, isNot(old.hashCode));
      expect(ChatAudioConfig.fromJson(changed.toJson()), changed);
    }
    expect(named.toString(), 'ChatAudioConfig(voice: [REDACTED], format: wav)');
    expect(custom.toString(), isNot(contains('new-private-id')));
    expect(format.toString(), contains('format: aac'));
  });
  for (final key in ['voice', 'format']) {
    test('$key is required and nonnull with controlled diagnostics', () {
      final valid = {'voice': 'alloy', 'format': 'aac'};
      final missing = {...valid}..remove(key);
      expect(
        () => ChatAudioConfig.fromJson(missing),
        throwsA(isA<FormatException>()),
      );
      for (final value in <Object?>[
        null,
        false,
        1,
        <Object?>[],
        {'private': Object()},
      ]) {
        expect(
          () => ChatAudioConfig.fromJson({...valid, key: value}),
          throwsA(isA<FormatException>()),
        );
      }
    });
  }
  for (final value in <Object?>[
    <String, dynamic>{},
    {'id': null},
    {'id': 1},
    {'id': 'private-id', 'private-extra-key': 'private-extra-value'},
    {1: 'private-id'},
  ]) {
    test(
      'malformed custom voice rejects without leaking ${value.runtimeType}',
      () {
        try {
          ChatAudioConfig.fromJson({'voice': value, 'format': 'aac'});
          fail('Expected malformed custom reference rejection');
        } on FormatException catch (error) {
          for (final marker in [
            'private-id',
            'private-extra-key',
            'private-extra-value',
          ]) {
            expect(error.toString(), isNot(contains(marker)));
          }
        }
      },
    );
  }
  test('caller-defined voices still require canonical writable branches', () {
    for (final invalid in <Object>[
      false,
      1,
      Object(),
      <Object?>[],
      {'id': 'private', 'future': true},
      {'id': double.nan},
    ]) {
      final config = ChatAudioConfig(
        voice: _Voice(invalid),
        format: ChatAudioFormat.aac,
      );
      expect(config.toJson, throwsA(isA<FormatException>()));
    }
    expect(
      const ChatAudioConfig(
        voice: _Voice('future-name'),
        format: ChatAudioFormat.aac,
      ).toJson(),
      {'voice': 'future-name', 'format': 'aac'},
    );
  });
  test('invalid formats are closed without echoing private values', () {
    for (final invalid in ['pcm', 'unknown', 'private-format']) {
      expect(
        () => ChatAudioConfig.fromJson({'voice': 'alloy', 'format': invalid}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.toString(),
            'safe text',
            isNot(contains(invalid)),
          ),
        ),
      );
    }
  });
  test(
    'canonical inline audio permits extra keys without inventing closure',
    () {
      final config = ChatAudioConfig.fromJson(const {
        'voice': 'alloy',
        'format': 'aac',
        'future-provider-option': true,
      });
      expect(config.toJson(), {'voice': 'alloy', 'format': 'aac'});
    },
  );
  for (final streamed in [false, true]) {
    for (final voice in <AudioVoice>[
      ChatAudioVoice.marin,
      ChatAudioVoice.cedar,
      const AudioVoice.named('future-name'),
      const AudioVoice.custom('existing-private-id'),
    ]) {
      test(
        'public ${streamed ? 'stream' : 'create'} forwards ${voice.runtimeType}',
        () async {
          var sends = 0;
          final transport = MockClient((request) async {
            sends++;
            expect(request.method, 'POST');
            expect(request.url.path, '/v1/chat/completions');
            final wire = jsonDecode(request.body) as Map<String, dynamic>;
            expect(wire['audio'], {
              'voice': voice.toJson(),
              'format': streamed ? 'pcm16' : 'aac',
            });
            expect(wire['modalities'], ['text', 'audio']);
            if (streamed) {
              expect(wire['stream'], true);
              return http.Response(
                'data: [DONE]\n\n',
                200,
                headers: {'content-type': 'text/event-stream'},
              );
            }
            return http.Response(
              jsonEncode({
                'id': 'mock',
                'object': 'chat.completion',
                'created': 0,
                'model': 'gpt-audio-1.5',
                'choices': [
                  {
                    'index': 0,
                    'message': {'role': 'assistant', 'content': 'mock'},
                    'finish_reason': 'stop',
                  },
                ],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          });
          final client = OpenAIClient(
            config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
            httpClient: transport,
          );
          addTearDown(client.close);
          addTearDown(transport.close);
          final request = ChatCompletionCreateRequest(
            model: 'gpt-audio-1.5',
            messages: [ChatMessage.user('Mock input')],
            modalities: const [ChatModality.text, ChatModality.audio],
            audio: ChatAudioConfig(
              voice: voice,
              format: streamed ? ChatAudioFormat.pcm16 : ChatAudioFormat.aac,
            ),
          );
          if (streamed) {
            expect(
              await client.chat.completions.createStream(request).toList(),
              isEmpty,
            );
          } else {
            expect(
              (await client.chat.completions.create(request)).text,
              'mock',
            );
          }
          expect(sends, 1);
        },
      );
    }
  }
}

class _Voice implements AudioVoice {
  const _Voice(this.value);
  final Object value;
  @override
  Object toJson() => value;
}
