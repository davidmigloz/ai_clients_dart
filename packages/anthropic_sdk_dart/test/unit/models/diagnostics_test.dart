import 'package:anthropic_sdk_dart/src/models/content/content_block.dart';
import 'package:anthropic_sdk_dart/src/models/messages/cache_miss_reason.dart';
import 'package:anthropic_sdk_dart/src/models/messages/diagnostics.dart';
import 'package:anthropic_sdk_dart/src/models/messages/diagnostics_param.dart';
import 'package:anthropic_sdk_dart/src/models/messages/input_message.dart';
import 'package:anthropic_sdk_dart/src/models/messages/message.dart';
import 'package:anthropic_sdk_dart/src/models/messages/message_create_request.dart';
import 'package:anthropic_sdk_dart/src/models/metadata/usage.dart';
import 'package:test/test.dart';

void main() {
  group('DiagnosticsParam', () {
    test('fromJson/toJson round-trip', () {
      final json = {'previous_message_id': 'msg_123'};
      final param = DiagnosticsParam.fromJson(json);

      expect(param.previousMessageId, 'msg_123');
      expect(param.toJson(), json);
    });

    test('omits previous_message_id when absent', () {
      final param = DiagnosticsParam.fromJson(const <String, dynamic>{});

      expect(param.previousMessageId, isNull);
      expect(param.toJson(), isEmpty);
    });

    test('toJson omits key when null', () {
      const param = DiagnosticsParam();

      expect(param.toJson().containsKey('previous_message_id'), isFalse);
    });

    test('copyWith replaces value', () {
      const original = DiagnosticsParam(previousMessageId: 'msg_1');
      final modified = original.copyWith(previousMessageId: 'msg_2');

      expect(modified.previousMessageId, 'msg_2');
    });

    test('copyWith can clear value to null', () {
      const original = DiagnosticsParam(previousMessageId: 'msg_1');
      final cleared = original.copyWith(previousMessageId: null);

      expect(cleared.previousMessageId, isNull);
    });

    test('copyWith without args keeps original', () {
      const original = DiagnosticsParam(previousMessageId: 'msg_1');
      final copy = original.copyWith();

      expect(copy.previousMessageId, 'msg_1');
    });

    test('equality and hashCode', () {
      const a = DiagnosticsParam(previousMessageId: 'msg_1');
      const b = DiagnosticsParam(previousMessageId: 'msg_1');
      const c = DiagnosticsParam(previousMessageId: 'msg_2');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('toString includes field', () {
      const param = DiagnosticsParam(previousMessageId: 'msg_1');

      expect(param.toString(), contains('previousMessageId'));
      expect(param.toString(), contains('msg_1'));
    });
  });

  group('CacheMissReason', () {
    group('token-bearing variants', () {
      final cases = <String, CacheMissReason Function(int)>{
        'model_changed': (t) =>
            CacheMissModelChanged(cacheMissedInputTokens: t),
        'system_changed': (t) =>
            CacheMissSystemChanged(cacheMissedInputTokens: t),
        'tools_changed': (t) =>
            CacheMissToolsChanged(cacheMissedInputTokens: t),
        'messages_changed': (t) =>
            CacheMissMessagesChanged(cacheMissedInputTokens: t),
      };

      for (final entry in cases.entries) {
        final type = entry.key;
        final build = entry.value;

        test('$type fromJson/toJson round-trip', () {
          final json = {'type': type, 'cache_missed_input_tokens': 42};
          final reason = CacheMissReason.fromJson(json);

          expect(reason, build(42));
          expect(reason.toJson(), json);
        });

        test('$type equality and hashCode', () {
          final a = build(10);
          final b = build(10);
          final c = build(20);

          expect(a, b);
          expect(a.hashCode, b.hashCode);
          expect(a, isNot(c));
        });

        test('$type discriminator-mismatch throws', () {
          expect(
            () => _fromJsonFor(build(0)).call(<String, dynamic>{
              'type': 'wrong',
              'cache_missed_input_tokens': 1,
            }),
            throwsFormatException,
          );
        });
      }

      test('copyWith replaces cacheMissedInputTokens on each variant', () {
        expect(
          const CacheMissModelChanged(
            cacheMissedInputTokens: 1,
          ).copyWith(cacheMissedInputTokens: 9),
          const CacheMissModelChanged(cacheMissedInputTokens: 9),
        );
        expect(
          const CacheMissSystemChanged(
            cacheMissedInputTokens: 1,
          ).copyWith(cacheMissedInputTokens: 9),
          const CacheMissSystemChanged(cacheMissedInputTokens: 9),
        );
        expect(
          const CacheMissToolsChanged(
            cacheMissedInputTokens: 1,
          ).copyWith(cacheMissedInputTokens: 9),
          const CacheMissToolsChanged(cacheMissedInputTokens: 9),
        );
        expect(
          const CacheMissMessagesChanged(
            cacheMissedInputTokens: 1,
          ).copyWith(cacheMissedInputTokens: 9),
          const CacheMissMessagesChanged(cacheMissedInputTokens: 9),
        );
        // No-arg copyWith preserves the original value.
        expect(
          const CacheMissModelChanged(cacheMissedInputTokens: 5).copyWith(),
          const CacheMissModelChanged(cacheMissedInputTokens: 5),
        );
      });

      test('const factory constructors build the right variants', () {
        expect(
          const CacheMissReason.modelChanged(cacheMissedInputTokens: 1),
          const CacheMissModelChanged(cacheMissedInputTokens: 1),
        );
        expect(
          const CacheMissReason.systemChanged(cacheMissedInputTokens: 2),
          const CacheMissSystemChanged(cacheMissedInputTokens: 2),
        );
        expect(
          const CacheMissReason.toolsChanged(cacheMissedInputTokens: 3),
          const CacheMissToolsChanged(cacheMissedInputTokens: 3),
        );
        expect(
          const CacheMissReason.messagesChanged(cacheMissedInputTokens: 4),
          const CacheMissMessagesChanged(cacheMissedInputTokens: 4),
        );
      });
    });

    group('type-only variants', () {
      test('previous_message_not_found round-trips', () {
        final json = {'type': 'previous_message_not_found'};
        final reason = CacheMissReason.fromJson(json);

        expect(reason, const CacheMissPreviousMessageNotFound());
        expect(reason, isA<CacheMissPreviousMessageNotFound>());
        expect(reason.toJson(), json);
      });

      test('unavailable round-trips', () {
        final json = {'type': 'unavailable'};
        final reason = CacheMissReason.fromJson(json);

        expect(reason, const CacheMissUnavailable());
        expect(reason, isA<CacheMissUnavailable>());
        expect(reason.toJson(), json);
      });

      test('const factory constructors build the right variants', () {
        expect(
          const CacheMissReason.previousMessageNotFound(),
          const CacheMissPreviousMessageNotFound(),
        );
        expect(
          const CacheMissReason.unavailable(),
          const CacheMissUnavailable(),
        );
      });

      test('previous_message_not_found discriminator-mismatch throws', () {
        expect(
          () => CacheMissPreviousMessageNotFound.fromJson(
            const <String, dynamic>{'type': 'unavailable'},
          ),
          throwsFormatException,
        );
      });

      test('unavailable discriminator-mismatch throws', () {
        expect(
          () => CacheMissUnavailable.fromJson(const <String, dynamic>{
            'type': 'previous_message_not_found',
          }),
          throwsFormatException,
        );
      });

      test('equality and hashCode', () {
        expect(
          const CacheMissPreviousMessageNotFound(),
          const CacheMissPreviousMessageNotFound(),
        );
        expect(
          const CacheMissPreviousMessageNotFound().hashCode,
          const CacheMissPreviousMessageNotFound().hashCode,
        );
        expect(
          const CacheMissUnavailable(),
          isNot(const CacheMissPreviousMessageNotFound()),
        );
      });
    });

    group('UnknownCacheMissReason', () {
      test('unknown type falls back and preserves raw JSON', () {
        final json = {'type': 'something_new', 'extra': 'value'};
        final reason = CacheMissReason.fromJson(json);

        expect(reason, isA<UnknownCacheMissReason>());
        expect((reason as UnknownCacheMissReason).rawJson, json);
        expect(reason.toJson(), json);
      });

      test('round-trips raw JSON', () {
        final json = {
          'type': 'future_reason',
          'nested': {'a': 1},
          'list': [1, 2, 3],
        };
        final reason = CacheMissReason.fromJson(json);

        expect(reason.toJson(), json);
      });

      test('equality and hashCode based on deep map content', () {
        const a = UnknownCacheMissReason(
          rawJson: {
            'type': 'x',
            'nested': {'a': 1},
          },
        );
        const b = UnknownCacheMissReason(
          rawJson: {
            'type': 'x',
            'nested': {'a': 1},
          },
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });
    });
  });

  group('Diagnostics', () {
    test('round-trip with populated reason', () {
      final json = {
        'cache_miss_reason': {
          'type': 'model_changed',
          'cache_missed_input_tokens': 7,
        },
      };
      final diagnostics = Diagnostics.fromJson(json);

      expect(
        diagnostics.cacheMissReason,
        const CacheMissModelChanged(cacheMissedInputTokens: 7),
      );
      expect(diagnostics.toJson(), json);
    });

    test('round-trip with cache_miss_reason: null (key present)', () {
      final json = <String, dynamic>{'cache_miss_reason': null};
      final diagnostics = Diagnostics.fromJson(json);

      expect(diagnostics.cacheMissReason, isNull);
      final out = diagnostics.toJson();
      expect(out.containsKey('cache_miss_reason'), isTrue);
      expect(out['cache_miss_reason'], isNull);
    });

    test('toJson always emits cache_miss_reason key', () {
      const diagnostics = Diagnostics();

      expect(diagnostics.toJson().containsKey('cache_miss_reason'), isTrue);
      expect(diagnostics.toJson()['cache_miss_reason'], isNull);
    });

    test('copyWith replaces reason', () {
      const original = Diagnostics(cacheMissReason: CacheMissUnavailable());
      final modified = original.copyWith(
        cacheMissReason: const CacheMissModelChanged(cacheMissedInputTokens: 1),
      );

      expect(
        modified.cacheMissReason,
        const CacheMissModelChanged(cacheMissedInputTokens: 1),
      );
    });

    test('copyWith can clear reason to null', () {
      const original = Diagnostics(cacheMissReason: CacheMissUnavailable());
      final cleared = original.copyWith(cacheMissReason: null);

      expect(cleared.cacheMissReason, isNull);
    });

    test('equality and hashCode', () {
      const a = Diagnostics(cacheMissReason: CacheMissUnavailable());
      const b = Diagnostics(cacheMissReason: CacheMissUnavailable());
      const c = Diagnostics();

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('toString includes field', () {
      const diagnostics = Diagnostics(cacheMissReason: CacheMissUnavailable());

      expect(diagnostics.toString(), contains('cacheMissReason'));
    });
  });

  group('Message.diagnostics', () {
    Message buildMessage({Diagnostics? diagnostics}) => Message(
      id: 'msg_1',
      content: const [TextBlock(text: 'hi')],
      model: 'claude-sonnet-4-6',
      usage: const Usage(inputTokens: 1, outputTokens: 1),
      diagnostics: diagnostics,
    );

    test('round-trip with diagnostics', () {
      final message = buildMessage(
        diagnostics: const Diagnostics(
          cacheMissReason: CacheMissModelChanged(cacheMissedInputTokens: 3),
        ),
      );
      final restored = Message.fromJson(message.toJson());

      expect(restored.diagnostics, message.diagnostics);
    });

    test('omits diagnostics when null', () {
      final message = buildMessage();

      expect(message.toJson().containsKey('diagnostics'), isFalse);
      expect(message.diagnostics, isNull);
    });

    test('copyWith replaces and clears diagnostics', () {
      final message = buildMessage(
        diagnostics: const Diagnostics(cacheMissReason: CacheMissUnavailable()),
      );
      final replaced = message.copyWith(
        diagnostics: const Diagnostics(
          cacheMissReason: CacheMissModelChanged(cacheMissedInputTokens: 9),
        ),
      );
      final cleared = message.copyWith(diagnostics: null);

      expect(
        replaced.diagnostics,
        const Diagnostics(
          cacheMissReason: CacheMissModelChanged(cacheMissedInputTokens: 9),
        ),
      );
      expect(cleared.diagnostics, isNull);
    });

    test('toString includes diagnostics', () {
      final message = buildMessage(
        diagnostics: const Diagnostics(cacheMissReason: CacheMissUnavailable()),
      );

      expect(message.toString(), contains('diagnostics'));
    });
  });

  group('MessageCreateRequest.diagnostics', () {
    MessageCreateRequest buildRequest({DiagnosticsParam? diagnostics}) =>
        MessageCreateRequest(
          model: 'claude-sonnet-4-6',
          maxTokens: 1024,
          messages: [InputMessage.user('hi')],
          diagnostics: diagnostics,
        );

    test('round-trip with diagnostics', () {
      final request = buildRequest(
        diagnostics: const DiagnosticsParam(previousMessageId: 'msg_prev'),
      );
      final restored = MessageCreateRequest.fromJson(request.toJson());

      expect(restored.diagnostics, request.diagnostics);
      expect(request.toJson()['diagnostics'], {
        'previous_message_id': 'msg_prev',
      });
    });

    test('omits diagnostics when null', () {
      final request = buildRequest();

      expect(request.toJson().containsKey('diagnostics'), isFalse);
      expect(request.diagnostics, isNull);
    });

    test('copyWith replaces and clears diagnostics', () {
      final request = buildRequest(
        diagnostics: const DiagnosticsParam(previousMessageId: 'a'),
      );
      final replaced = request.copyWith(
        diagnostics: const DiagnosticsParam(previousMessageId: 'b'),
      );
      final cleared = request.copyWith(diagnostics: null);

      expect(
        replaced.diagnostics,
        const DiagnosticsParam(previousMessageId: 'b'),
      );
      expect(cleared.diagnostics, isNull);
    });

    test('toString includes diagnostics', () {
      final request = buildRequest(
        diagnostics: const DiagnosticsParam(previousMessageId: 'a'),
      );

      expect(request.toString(), contains('diagnostics'));
    });
  });
}

/// Returns the variant-specific [fromJson] for the discriminator-mismatch
/// test, so each token-bearing variant validates its own discriminator.
Map<String, dynamic> Function(Map<String, dynamic>) _fromJsonFor(
  CacheMissReason reason,
) {
  return switch (reason) {
    CacheMissModelChanged() => (j) => CacheMissModelChanged.fromJson(
      j,
    ).toJson(),
    CacheMissSystemChanged() => (j) => CacheMissSystemChanged.fromJson(
      j,
    ).toJson(),
    CacheMissToolsChanged() => (j) => CacheMissToolsChanged.fromJson(
      j,
    ).toJson(),
    CacheMissMessagesChanged() => (j) => CacheMissMessagesChanged.fromJson(
      j,
    ).toJson(),
    _ => (j) => CacheMissReason.fromJson(j).toJson(),
  };
}
