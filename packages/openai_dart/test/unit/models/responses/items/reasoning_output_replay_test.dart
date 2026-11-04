import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Reasoning output replay', () {
    for (final beta in [false, true]) {
      for (final presence in ['omitted', 'null', 'value']) {
        test('preserves native fields and encrypted $presence, beta=$beta', () {
          final wire = _wire(beta: beta, encrypted: presence);
          final output = OutputItem.fromJson(wire) as ReasoningItem;
          expect(output.toJson(), wire);
          expect(output.status, ItemStatus.completed);
          expect(output.hasEncryptedContent, presence != 'omitted');
          expect(output, OutputItem.fromJson(wire));
          expect(output.hashCode, OutputItem.fromJson(wire).hashCode);
          expect(output.copyWith(), output);
          expect(output.copyWith().hashCode, output.hashCode);
          final replay = output.toInput();
          expect(replay, isA<ReasoningInputItem>());
          expect(replay.toJson(), wire);
          expect(Item.fromJson(replay.toJson()), replay);
          expect(ResponseInput.items([replay]).toJson(), [wire]);
        });
      }
    }

    test('old const construction remains available', () {
      const item = ReasoningItem(id: 'rs_const', summary: []);
      expect(item.toJson(), {
        'type': 'reasoning',
        'id': 'rs_const',
        'summary': <dynamic>[],
      });
      expect(item.hasEncryptedContent, isFalse);
      expect(item.status, isNull);
      expect(item.toInput().toJson(), item.toJson());
      const summary = ReasoningSummaryContent(text: 'Synthetic summary');
      expect(summary.copyWith(), summary);
      expect(summary.copyWith(text: 'Changed'), isNot(summary));
    });

    test('parsed content and summaries are independently immutable', () {
      final wire = _wire();
      final content = wire['content'] as List;
      (content.first as Map)['future_metadata'] = {
        'nested': <dynamic>['original'],
      };
      final item = ReasoningItem.fromJson(wire);
      final hash = item.hashCode;
      final expected = item.toJson();
      (content.first as Map)['text'] = 'Caller edit';
      ((content.first as Map)['future_metadata'] as Map)['nested'] = ['edit'];
      (wire['summary'] as List).clear();
      expect(item.content!.single['text'], 'Synthetic private reasoning');
      expect(item.summary.single.text, 'Synthetic private summary');
      expect(item.hashCode, hash);
      expect(item.toJson(), expected);
      expect(() => item.content!.clear(), throwsUnsupportedError);
      expect(
        () => item.content!.single['text'] = 'edit',
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((item.content!.single['future_metadata'] as Map)['nested'] as List)
                .add('edit'),
        throwsUnsupportedError,
      );
      expect(item.summary.clear, throwsUnsupportedError);
    });

    test('copy snapshots legacy caller-owned and replacement collections', () {
      final ownedContent = <Map<String, dynamic>>[
        {'type': 'reasoning_text', 'text': 'Original'},
      ];
      final ownedSummary = <ReasoningSummaryContent>[
        const ReasoningSummaryContent(text: 'Original summary'),
      ];
      final original = ReasoningItem(
        id: 'rs_owned',
        content: ownedContent,
        summary: ownedSummary,
      );
      final copy = original.copyWith();
      ownedContent.single['text'] = 'Caller edit';
      ownedSummary.clear();
      expect(copy.content!.single['text'], 'Original');
      expect(copy.summary.single.text, 'Original summary');
      final replacement = <Map<String, dynamic>>[
        {'type': 'reasoning_text', 'text': 'Replacement'},
      ];
      final changed = copy.copyWith(content: replacement);
      replacement.single['text'] = 'Caller replacement edit';
      expect(changed.content!.single['text'], 'Replacement');
      expect(changed, isNot(copy));
      expect(changed, ReasoningItem.fromJson(changed.toJson()));
    });

    test('value equality includes every replay field', () {
      final item = ReasoningItem.fromJson(_wire(beta: true));
      for (final changed in [
        item.copyWith(id: 'different'),
        item.copyWith(agent: null),
        item.copyWith(content: <Map<String, dynamic>>[]),
        item.copyWith(summary: []),
        item.copyWith(encryptedContent: 'different'),
        item.copyWith(encryptedContent: null),
        item.copyWith(status: ItemStatus.incomplete),
        item.copyWith(status: null),
      ]) {
        expect(changed, isNot(item));
        expect(changed, ReasoningItem.fromJson(changed.toJson()));
        expect(
          changed.hashCode,
          ReasoningItem.fromJson(changed.toJson()).hashCode,
        );
      }
      expect(
        ReasoningItem.fromJson(_wire(encrypted: 'omitted')),
        isNot(ReasoningItem.fromJson(_wire(encrypted: 'null'))),
      );
    });

    test('copy clearing preserves nullable encrypted presence explicitly', () {
      final item = ReasoningItem.fromJson(_wire(beta: true));
      final cleared = item.copyWith(
        agent: null,
        content: null,
        encryptedContent: null,
        status: null,
      );
      expect(cleared.toJson(), {
        'type': 'reasoning',
        'id': 'rs_synthetic',
        'summary': [
          {'type': 'summary_text', 'text': 'Synthetic private summary'},
        ],
        'encrypted_content': null,
      });
      expect(cleared.hasEncryptedContent, isTrue);
      expect(
        cleared
            .copyWith(hasEncryptedContent: false)
            .toJson()
            .containsKey('encrypted_content'),
        isFalse,
      );
      final omitted = ReasoningItem.fromJson(_wire(encrypted: 'omitted'));
      expect(
        omitted.copyWith(encryptedContent: null).hasEncryptedContent,
        isTrue,
      );
      expect(
        item.copyWith(hasEncryptedContent: false).hasEncryptedContent,
        isTrue,
      );
    });

    test('new statuses round trip and future statuses use the fallback', () {
      for (final status in ['in_progress', 'completed', 'incomplete']) {
        final item = ReasoningItem.fromJson({..._wire(), 'status': status});
        expect(item.toJson()['status'], status);
        expect(item.toInput().toJson()['status'], status);
      }
      final future = ReasoningItem.fromJson({..._wire(), 'status': 'future'});
      expect(future.status, ItemStatus.unknown);
      expect(future.toJson()['status'], 'unknown');
    });

    test('legacy null content/agent/status normalize to omission', () {
      final wire = _wire(encrypted: 'omitted')
        ..['content'] = null
        ..['agent'] = null
        ..['status'] = null;
      final item = ReasoningItem.fromJson(wire);
      expect(item.toJson().containsKey('content'), isFalse);
      expect(item.toJson().containsKey('agent'), isFalse);
      expect(item.toJson().containsKey('status'), isFalse);
      expect(item.toJson().containsKey('encrypted_content'), isFalse);
    });

    test(
      'diagnostics redact reasoning, summary, encrypted content and IDs',
      () {
        final item = ReasoningItem.fromJson(_wire(beta: true));
        final diagnostic = item.toString();
        for (final private in [
          'rs_synthetic',
          'Synthetic private reasoning',
          'Synthetic private summary',
          'encrypted_fixture',
          'private_agent',
        ]) {
          expect(diagnostic, isNot(contains(private)));
          expect(item.summary.single.toString(), isNot(contains(private)));
        }
        expect(diagnostic, contains('status: ItemStatus.completed'));
        expect(diagnostic, contains('hasEncryptedContent: true'));
        expect(diagnostic, contains('content: 1 parts'));
        expect(diagnostic, contains('summary: 1 parts'));
      },
    );

    for (final (field, value) in <(String, Object?)>[
      ('type', 'message'),
      ('id', null),
      ('id', 1),
      ('summary', null),
      ('summary', 'bad'),
      ('summary', [null]),
      (
        'summary',
        [
          {'type': 'summary_text'},
        ],
      ),
      (
        'summary',
        [
          {'type': 'reasoning_text', 'text': 'private'},
        ],
      ),
      ('content', 'bad'),
      ('content', [1]),
      ('encrypted_content', 1),
      ('status', 1),
      ('agent', 1),
    ]) {
      test('malformed $field is rejected contextually', () {
        expect(
          () => ReasoningItem.fromJson({..._wire(), field: value}),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'safe context',
              allOf(contains('Reasoning'), isNot(contains('private'))),
            ),
          ),
        );
      });
    }

    for (final missing in ['id', 'summary']) {
      test('missing required $missing is rejected', () {
        final wire = _wire()..remove(missing);
        expect(() => ReasoningItem.fromJson(wire), throwsFormatException);
      });
    }

    test('parsed and copied open content reject cyclic/non-JSON data', () {
      final cycle = <dynamic>[];
      cycle.add(cycle);
      for (final bad in [
        double.nan,
        double.infinity,
        cycle,
        DateTime.utc(2026),
      ]) {
        final wire = _wire();
        ((wire['content'] as List).single as Map)['future'] = bad;
        expect(() => ReasoningItem.fromJson(wire), throwsFormatException);
        expect(
          () => const ReasoningItem(id: 'rs', summary: []).copyWith(
            content: [
              {'type': 'reasoning_text', 'text': 'Synthetic', 'future': bad},
            ],
          ),
          throwsFormatException,
        );
      }
    });

    test('summary validates its own discriminator and required text', () {
      expect(
        () => ReasoningSummaryContent.fromJson(const {'text': 'Synthetic'}),
        throwsFormatException,
      );
      expect(
        () => ReasoningSummaryContent.fromJson(const {'type': 'summary_text'}),
        throwsFormatException,
      );
    });
  });
}

Map<String, dynamic> _wire({bool beta = false, String encrypted = 'value'}) => {
  'type': 'reasoning',
  'id': 'rs_synthetic',
  'summary': <Map<String, dynamic>>[
    {'type': 'summary_text', 'text': 'Synthetic private summary'},
  ],
  'content': <Map<String, dynamic>>[
    {'type': 'reasoning_text', 'text': 'Synthetic private reasoning'},
  ],
  if (encrypted != 'omitted')
    'encrypted_content': encrypted == 'null' ? null : 'encrypted_fixture',
  'status': 'completed',
  if (beta) 'agent': {'agent_name': 'private_agent'},
};
