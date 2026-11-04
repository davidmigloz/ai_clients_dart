import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'response input union replays computer calls and screenshot results',
    () {
      final history = <Map<String, dynamic>>[
        {
          'type': 'computer_call',
          'id': 'cu_1',
          'call_id': 'call_1',
          'actions': [
            {'type': 'screenshot'},
          ],
          'pending_safety_checks': <Object?>[],
          'status': 'completed',
        },
        {
          'type': 'computer_call_output',
          'call_id': 'call_1',
          'output': {
            'type': 'computer_screenshot',
            'image_url': 'data:image/png;base64,AA==',
          },
          'acknowledged_safety_checks': [
            {'id': 'check_1', 'code': 'warning', 'message': 'Confirmed'},
          ],
        },
      ];
      final request = CreateResponseRequest.fromJson({
        'model': 'fixture',
        'input': history,
      });
      expect(request.toJson()['input'], history);
      expect(
        CreateResponseRequest.fromJson(request.toJson()).toJson(),
        request.toJson(),
      );
    },
  );
  test('replays legacy and batched computer calls', () {
    for (final action in [
      {
        'action': {'type': 'screenshot'},
      },
      {
        'actions': [
          {'type': 'screenshot'},
          {'type': 'type', 'text': 'hello'},
        ],
      },
    ]) {
      final json = <String, dynamic>{
        'type': 'computer_call',
        'id': 'cu_1',
        'call_id': 'call_1',
        'pending_safety_checks': [
          {'id': 'check_1', 'code': 'warning'},
        ],
        'status': 'completed',
        'agent': {'agent_name': 'worker'},
        ...action,
      };
      final call = Item.fromJson(json) as ComputerCallInputItem;
      expect(call.toJson(), json);
      expect(call, Item.fromJson(json));
      expect(call.hashCode, Item.fromJson(json).hashCode);
      expect(call.copyWith(agent: null).agent, isNull);
      expect(Item.fromResourceJson(json).toJson(), json);
    }
  });

  test('writes and reads screenshot results and safety acknowledgments', () {
    const item = ComputerCallOutputInputItem(
      callId: 'call_1',
      output: ComputerScreenshotContent.url('data:image/png;base64,AA=='),
      acknowledgedSafetyChecks: [
        ComputerSafetyCheck(id: 'check_1', code: 'warning', message: 'Confirm'),
      ],
    );
    final json = item.toJson();
    expect(json, {
      'type': 'computer_call_output',
      'call_id': 'call_1',
      'output': {
        'type': 'computer_screenshot',
        'image_url': 'data:image/png;base64,AA==',
      },
      'acknowledged_safety_checks': [
        {'id': 'check_1', 'code': 'warning', 'message': 'Confirm'},
      ],
    });
    expect(Item.fromJson(json).toJson(), json);
    final parsed = Item.fromJson(json) as ComputerCallOutputInputItem;
    expect(parsed, equals(Item.fromJson(json)));
    expect(parsed.hashCode, Item.fromJson(json).hashCode);
    expect(parsed.copyWith(id: 'out_1').copyWith(id: null), parsed);
    final redacted = {
      ...json,
      'id': 'out_2',
      'status': 'completed',
      'output': {'type': 'computer_screenshot'},
    };
    expect(Item.fromResourceJson(redacted).toJson(), redacted);
    final resource =
        Item.fromResourceJson({
              ...redacted,
              'created_by': 'actor',
              'agent': {'agent_name': 'worker'},
            })
            as ComputerCallOutputResourceItem;
    expect(resource, Item.fromResourceJson(resource.toJson()));
    expect(
      resource.hashCode,
      Item.fromResourceJson(resource.toJson()).hashCode,
    );
    expect(resource.copyWith(createdBy: null).createdBy, isNull);
    expect(resource.toInputItem, throwsStateError);
    final replayable =
        Item.fromResourceJson({
              ...resource.toJson(),
              'output': {'type': 'computer_screenshot', 'file_id': 'file_1'},
            })
            as ComputerCallOutputResourceItem;
    expect(
      replayable.toInputItem().toJson().containsKey('created_by'),
      isFalse,
    );
    expect(replayable.toInputItem().toJson()['agent'], {
      'agent_name': 'worker',
    });
    expect(replayable.toInputItem().output.fileId, 'file_1');
    expect(ComputerScreenshotContent.new, throwsA(isA<AssertionError>()));
    expect(
      const ComputerSafetyCheck(
        id: 'check',
      ).copyWith(code: 'x').copyWith(code: null),
      const ComputerSafetyCheck(id: 'check'),
    );
    expect(
      Item.fromJson({
        ...json,
        'output': {'type': 'computer_screenshot', 'file_id': 'file_1'},
      }).toJson()['output'],
      {'type': 'computer_screenshot', 'file_id': 'file_1'},
    );
    expect(
      Item.fromResourceJson({
        ...json,
        'id': 'out_1',
        'status': 'failed',
        'created_by': 'actor_1',
        'agent': {'agent_name': 'worker'},
      }).toJson(),
      {
        ...json,
        'id': 'out_1',
        'status': 'failed',
        'created_by': 'actor_1',
        'agent': {'agent_name': 'worker'},
      },
    );
    expect(
      () => Item.fromJson({
        ...json,
        'output': {'type': 'input_text', 'text': 'bad'},
      }),
      throwsFormatException,
    );
  });
}
