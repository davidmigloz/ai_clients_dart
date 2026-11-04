import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const base = <String, dynamic>{
    'type': 'reasoning',
    'id': 'rs_fixture',
    'summary': <dynamic>[],
  };
  final full = <String, dynamic>{
    ...base,
    'summary': [
      {'type': 'summary_text', 'text': 'Synthetic summary'},
    ],
    'content': [
      {
        'type': 'reasoning_text',
        'text': 'Synthetic reasoning context',
        'future_metadata': {'sequence': 1},
      },
    ],
    'encrypted_content': 'opaque-fixture',
    'status': 'completed',
    'agent': {'agent_name': 'worker'},
  };
  test('all public input dispatchers retain canonical reasoning fields', () {
    final item = ReasoningInputItem.fromJson(full);
    expect(item.toJson(), full);
    expect(Item.fromJson(full), item);
    expect(Item.fromResourceJson(full), item);
    final input = ResponseInput.fromJson([full]) as ResponseInputItems;
    expect(input.items.single, item);
    expect(input.toJson(), [full]);
    expect(ReasoningInputItem.fromJson(item.toJson()), item);
    expect(ReasoningInputItem.fromJson(full).hashCode, item.hashCode);
    expect(item.type, 'reasoning');
  });

  test('constructor and copies own all nested collection data', () {
    final summary = <ReasoningSummaryContent>[
      const ReasoningSummaryContent(text: 'Owned summary'),
    ];
    final content = <Map<String, dynamic>>[
      {
        'type': 'reasoning_text',
        'text': 'Owned context',
        'future_metadata': <dynamic>[1],
      },
    ];
    final item = ReasoningInputItem(
      id: 'rs_fixture',
      summary: summary,
      content: content,
    );
    final hash = item.hashCode;
    summary.clear();
    (content.single['future_metadata'] as List).add(2);
    content.clear();
    expect(item.summary.single.text, 'Owned summary');
    expect(item.content!.single['future_metadata'], [1]);
    expect(item.hashCode, hash);
    expect(item.summary.clear, throwsUnsupportedError);
    expect(item.content!.clear, throwsUnsupportedError);
    expect(
      () => item.content!.single['text'] = 'changed',
      throwsUnsupportedError,
    );
    final replacement = <Map<String, dynamic>>[
      {'type': 'reasoning_text', 'text': 'Replacement'},
    ];
    final copied = item.copyWith(content: replacement);
    replacement.single['text'] = 'Caller edit';
    expect(copied.content!.single['text'], 'Replacement');
    expect(copied, isNot(item));
    expect(copied, ReasoningInputItem.fromJson(copied.toJson()));
    expect(item.copyWith(), item);
    expect(item.copyWith().hashCode, item.hashCode);
  });

  for (final value in <String?>[null, '', 'opaque-fixture']) {
    test('encrypted content retains explicit nullable value $value', () {
      final wire = {...base, 'encrypted_content': value};
      final item = ReasoningInputItem.fromJson(wire);
      expect(item.hasEncryptedContent, isTrue);
      expect(item.encryptedContent, value);
      expect(item.toJson(), wire);
      final omitted = item.copyWith(
        encryptedContent: null,
        hasEncryptedContent: false,
      );
      expect(omitted.toJson(), base);
      expect(omitted.hasEncryptedContent, isFalse);
      final cleared = item.copyWith(encryptedContent: null);
      expect(cleared.hasEncryptedContent, isTrue);
      expect(cleared.toJson(), {...base, 'encrypted_content': null});
      expect(omitted, isNot(cleared));
    });
  }

  test('copies update every field and clear optional metadata', () {
    final item = ReasoningInputItem.fromJson(full);
    final changed = item.copyWith(
      id: 'rs_next',
      summary: const [],
      content: null,
      encryptedContent: 'next-opaque',
      status: ItemStatus.incomplete,
      agent: const AgentTag(agentName: 'other'),
    );
    expect(changed.toJson(), {
      ...base,
      'id': 'rs_next',
      'encrypted_content': 'next-opaque',
      'status': 'incomplete',
      'agent': {'agent_name': 'other'},
    });
    expect(changed, isNot(item));
    final cleared = item.copyWith(
      content: null,
      encryptedContent: null,
      hasEncryptedContent: false,
      status: null,
      agent: null,
    );
    expect(cleared.toJson(), {...base, 'summary': full['summary']});
    expect(
      item.copyWith(content: const []),
      isNot(item.copyWith(content: null)),
    );
    expect(item.copyWith(summary: const []), isNot(item));
    expect(item.copyWith(status: ItemStatus.incomplete), isNot(item));
  });

  for (final bad in <Map<String, dynamic>>[
    {'type': 'reasoning', 'summary': <dynamic>[]},
    {'type': 'reasoning', 'id': 'rs_fixture'},
    {...base, 'type': 'PRIVATE'},
    {...base, 'id': null},
    {...base, 'summary': null},
    {
      ...base,
      'summary': <dynamic>[
        {'type': 'summary_text'},
      ],
    },
    {
      ...base,
      'summary': <dynamic>[
        {'type': 'PRIVATE', 'text': 'PRIVATE'},
      ],
    },
    {...base, 'content': null},
    {...base, 'content': 'PRIVATE'},
    {
      ...base,
      'content': <dynamic>[
        {'type': 'reasoning_text'},
      ],
    },
    {
      ...base,
      'content': <dynamic>[
        {'type': 'PRIVATE', 'text': 'PRIVATE'},
      ],
    },
    {...base, 'status': null},
    {...base, 'status': 1},
    {...base, 'encrypted_content': 1},
    {...base, 'agent': <String, dynamic>{}},
  ]) {
    test('malformed canonical input fails with safe context: $bad', () {
      expect(
        () => ReasoningInputItem.fromJson(bad),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'context',
            allOf(contains('ReasoningInputItem'), isNot(contains('PRIVATE'))),
          ),
        ),
      );
    });
  }

  test('invalid JSON is rejected without disclosing payloads', () {
    final cycle = <dynamic>[];
    cycle.add(cycle);
    for (final bad in <Object?>[double.nan, cycle, DateTime.utc(2026)]) {
      expect(
        () => ReasoningInputItem.fromJson({
          ...base,
          'content': [
            {'type': 'reasoning_text', 'text': 'PRIVATE', 'PRIVATE': bad},
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe error',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
    }
  });

  test('diagnostics do not expose reasoning, identifiers or agent names', () {
    final item = ReasoningInputItem(
      id: 'PRIVATE_ID',
      summary: const [ReasoningSummaryContent(text: 'PRIVATE_SUMMARY')],
      content: const [
        {'type': 'reasoning_text', 'text': 'PRIVATE_CONTENT'},
      ],
      encryptedContent: 'PRIVATE_ENCRYPTED',
      agent: const AgentTag(agentName: 'PRIVATE_AGENT'),
    );
    expect(item.toString(), isNot(contains('PRIVATE')));
    expect(item.toString(), contains('summary: 1 parts'));
    expect(
      ReasoningInputItem.fromJson(base).toString(),
      contains('content: null'),
    );
  });
}
