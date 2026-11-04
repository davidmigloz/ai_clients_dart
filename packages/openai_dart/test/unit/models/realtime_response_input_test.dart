import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('native GA response input', () {
    test('all item and role branches round-trip exact wire payloads', () {
      final examples = <Map<String, dynamic>>[
        {'type': 'item_reference', 'id': 'item_1'},
        for (final role in ['system', 'developer'])
          {
            'type': 'message',
            'role': role,
            'content': [
              {'type': 'input_text', 'text': ''},
            ],
          },
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'hello'},
            {'type': 'input_audio', 'audio': 'AA==', 'transcript': null},
            {
              'type': 'input_image',
              'image_url': 'data:image/png;base64,AA==',
              'detail': null,
            },
          ],
          'id': null,
          'status': null,
        },
        {
          'type': 'message',
          'role': 'assistant',
          'content': [
            {'type': 'output_text', 'text': 'answer'},
          ],
          'id': 'assistant_1',
          'status': 'incomplete',
        },
        {
          'type': 'function_call',
          'call_id': 'call_1',
          'name': 'root',
          'arguments': '{ unnormalized ',
          'id': null,
          'status': 'completed',
        },
        {
          'type': 'function_call_output',
          'call_id': 'call_1',
          'output': '',
          'id': 'output_1',
          'status': null,
        },
      ];
      for (final json in examples) {
        final item = RealtimeResponseInputItem.fromJson(json);
        expect(item.toJson(), json);
        expect(RealtimeResponseInputItem.fromJson(item.toJson()), item);
        expect(
          RealtimeResponseInputItem.fromJson(item.toJson()).hashCode,
          item.hashCode,
        );
      }
    });

    test(
      'reference IDs apply exact length, alphabet and reserved-name rules',
      () {
        expect(RealtimeResponseItemReference(id: 'a' * 32).id.length, 32);
        for (final id in [
          '',
          'a' * 33,
          'root',
          'with space',
          'item.dot',
          'é',
          'a\n',
        ]) {
          expect(
            () => RealtimeResponseItemReference(id: id),
            throwsFormatException,
          );
          expect(
            () => RealtimeResponseInputItem.fromJson({
              'type': 'item_reference',
              'id': id,
            }),
            throwsFormatException,
          );
        }
        expect(RealtimeResponseItemReference(id: 'ROOT_-09').id, 'ROOT_-09');
      },
    );

    test('references cannot absorb full conversation-item fields', () {
      for (final json in <Map<String, dynamic>>[
        {'type': 'item_reference'},
        {'type': 'item_reference', 'id': null},
        {'type': 'item_reference', 'id': 1},
        {'type': 'item_reference', 'id': 'item_1', 'status': 'completed'},
        {'type': 'other', 'id': 'item_1'},
      ]) {
        expect(
          () => RealtimeResponseInputItem.fromJson(json),
          throwsFormatException,
        );
      }
    });

    test('role-specific input content has native bounds', () {
      final input = RealtimeResponseInputText(text: 'x');
      final output = RealtimeResponseInputOutputText(text: 'x');
      for (final role in ['system', 'developer']) {
        expect(
          () =>
              RealtimeResponseInputMessage(role: role, content: [input, input]),
          throwsFormatException,
        );
        expect(
          () => RealtimeResponseInputMessage(role: role, content: [output]),
          throwsFormatException,
        );
      }
      expect(
        () => RealtimeResponseInputMessage(role: 'assistant', content: [input]),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputMessage(role: 'user', content: [output]),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputMessage(role: 'tool', content: [input]),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputMessage(role: 'user', content: const []),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputItem.fromJson(const {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'x'},
          ],
        }),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputItem.fromJson(const {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 1},
          ],
        }),
        throwsFormatException,
      );
    });

    test('text maxima count Unicode code points', () {
      expect(
        RealtimeResponseInputText(text: '😀' * 256000).text.runes.length,
        256000,
      );
      expect(RealtimeResponseInputOutputText(text: '').text, '');
      expect(
        () => RealtimeResponseInputText(text: '😀' * 256001),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputOutputText(text: 'a' * 256001),
        throwsFormatException,
      );
    });

    test(
      'audio follows session format without adding unrelated fixture limits',
      () {
        final audio = RealtimeResponseInputAudio(audio: 'AA==');
        expect(audio.toJson(), {'type': 'input_audio', 'audio': 'AA=='});
        expect(
          () => RealtimeResponseInputAudio(audio: ''),
          throwsFormatException,
        );
        expect(
          () => RealtimeResponseInputContentPart.fromJson(const {
            'type': 'input_audio',
            'audio': 'AA==',
            'transcript': 1,
          }),
          throwsFormatException,
        );
        expect(
          () => RealtimeResponseInputContentPart.fromJson(const {
            'type': 'input_audio',
            'audio': 'AA==',
            'format': 'pcm16',
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'image input requires the canonical image data URL and detail enum',
      () {
        for (final detail in ['low', 'high', 'auto']) {
          expect(
            RealtimeResponseInputImage(
              imageUrl: 'data:image/jpeg;base64,AA==',
              detail: detail,
            ).detail,
            detail,
          );
        }
        for (final image in [
          'https://example.com/image.png',
          'file_1',
          'data:text/plain;base64,AA==',
          'data:image/png;base64,',
          'data:image/png,abc',
        ]) {
          expect(
            () => RealtimeResponseInputImage(imageUrl: image),
            throwsFormatException,
          );
        }
        expect(
          () => RealtimeResponseInputImage(
            imageUrl: 'data:image/png;base64,AA==',
            detail: 'original',
          ),
          throwsFormatException,
        );
      },
    );

    test('tool fields are exact strings with independent native bounds', () {
      expect(
        RealtimeResponseInputFunctionCall(
          callId: 'c',
          name: 'x' * 64,
          arguments: '😀' * 1048576,
        ).arguments.runes.length,
        1048576,
      );
      expect(
        RealtimeResponseInputFunctionCallOutput(
          callId: 'c',
          output: '😀' * 1048576,
        ).output.runes.length,
        1048576,
      );
      for (final callId in ['root', 'x' * 33, '', 'x.dot']) {
        expect(
          () => RealtimeResponseInputFunctionCall(
            callId: callId,
            name: 'f',
            arguments: '',
          ),
          throwsFormatException,
        );
        expect(
          () => RealtimeResponseInputFunctionCallOutput(
            callId: callId,
            output: '',
          ),
          throwsFormatException,
        );
      }
      for (final name in ['', 'x' * 65, 'f.dot']) {
        expect(
          () => RealtimeResponseInputFunctionCall(
            callId: 'c',
            name: name,
            arguments: '',
          ),
          throwsFormatException,
        );
      }
      expect(
        () => RealtimeResponseInputFunctionCall(
          callId: 'c',
          name: 'f',
          arguments: 'a' * 1048577,
        ),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputFunctionCallOutput(
          callId: 'c',
          output: 'a' * 1048577,
        ),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputItem.fromJson(const {
          'type': 'function_call_output',
          'call_id': 'c',
          'output': <Object?>[],
        }),
        throwsFormatException,
      );
      expect(
        () => RealtimeResponseInputItem.fromJson(const {
          'type': 'function_call',
          'call_id': 'c',
          'name': 'f',
          'arguments': '{}',
          'namespace': 'ns',
        }),
        throwsFormatException,
      );
    });

    test('nullable fields retain absent, null and value through copy', () {
      final message = RealtimeResponseInputMessage(
        role: 'user',
        content: [RealtimeResponseInputText(text: 'x')],
      );
      expect(message.toJson().containsKey('id'), isFalse);
      final nulled = message.copyWith(id: null, status: null);
      expect(nulled.toJson()['id'], isNull);
      expect(nulled.hasId && nulled.hasStatus, isTrue);
      expect(nulled, isNot(message));
      expect(nulled.copyWith(clearId: true, clearStatus: true), message);
      final call = RealtimeResponseInputFunctionCall(
        callId: 'c',
        name: 'f',
        arguments: '',
        id: 'i',
        status: 'completed',
      );
      expect(call.copyWith(id: null).toJson().containsKey('id'), isTrue);
      expect(call.copyWith(clearId: true, clearStatus: true).toJson(), {
        'type': 'function_call',
        'call_id': 'c',
        'name': 'f',
        'arguments': '',
      });
      final result = RealtimeResponseInputFunctionCallOutput(
        callId: 'c',
        output: '',
        hasId: true,
        hasStatus: true,
      );
      expect(result.copyWith().toJson(), result.toJson());
      expect(
        result
            .copyWith(clearId: true, clearStatus: true)
            .toJson()
            .containsKey('id'),
        isFalse,
      );
      final audio = RealtimeResponseInputAudio(audio: 'AA==');
      expect(audio.copyWith(transcript: null).hasTranscript, isTrue);
      expect(
        audio.copyWith(transcript: '').copyWith(clearTranscript: true),
        audio,
      );
      final image = RealtimeResponseInputImage(
        imageUrl: 'data:image/png;base64,AA==',
      );
      expect(image.copyWith(detail: null).hasDetail, isTrue);
      expect(image.copyWith(detail: 'high').copyWith(clearDetail: true), image);
      expect(() => message.copyWith(id: 1), throwsFormatException);
      expect(
        () => message.copyWith(status: 'in_progress'),
        throwsFormatException,
      );
      expect(() => message.copyWith(id: 'root'), throwsFormatException);
    });

    test('message snapshots caller-owned lists and redacts diagnostics', () {
      const secret = 'PRIVATE_INPUT';
      final parts = <RealtimeResponseInputContentPart>[
        RealtimeResponseInputText(text: secret),
      ];
      final message = RealtimeResponseInputMessage(
        role: 'user',
        content: parts,
      );
      parts.clear();
      expect(message.content.length, 1);
      expect(message.content.clear, throwsUnsupportedError);
      expect(message.toString(), isNot(contains(secret)));
      expect(message.content.single.toString(), isNot(contains(secret)));
      expect(message.copyWith(), message);
    });
  });
}
