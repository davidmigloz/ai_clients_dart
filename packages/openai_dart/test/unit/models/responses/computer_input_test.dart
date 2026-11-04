import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('computer call ownership', () {
    test('captures constructor collections and keeps hash lookup stable', () {
      final keys = ['ctrl'];
      final coordinates = <Map<String, dynamic>>[
        {'x': 10, 'y': 20},
      ];
      final actions = <ComputerAction>[
        DragAction(path: coordinates, keys: keys),
      ];
      final checks = <Map<String, dynamic>>[
        {
          'id': 'check_original',
          'details': {
            'labels': ['original'],
          },
        },
      ];
      final call = ComputerCallInputItem(
        id: 'cu_1',
        callId: 'call_1',
        action: KeyPressAction(keys: keys),
        actions: actions,
        pendingSafetyChecks: checks,
        status: ItemStatus.completed,
      );
      final equivalent = Item.fromJson(call.toJson());
      final originalHash = call.hashCode;
      final calls = {call};

      keys.add('shift');
      coordinates.first['x'] = 99;
      coordinates.clear();
      actions.clear();
      checks.first['id'] = 'check_replaced';
      final details = checks.first['details'] as Map<String, dynamic>;
      (details['labels'] as List<String>).add('replaced');
      checks.clear();

      expect(call, equivalent);
      expect(call.hashCode, originalHash);
      expect(calls.contains(call), isTrue);
      expect((call.action! as KeyPressAction).keys, ['ctrl']);
      final drag = call.actions!.single as DragAction;
      expect(drag.path, [
        {'x': 10, 'y': 20},
      ]);
      expect(drag.keys, ['ctrl']);
      expect(call.pendingSafetyChecks.single['id'], 'check_original');
    });

    test('parsed and copied actions and checks are unmodifiable snapshots', () {
      final json = <String, dynamic>{
        'type': 'computer_call',
        'id': 'cu_1',
        'call_id': 'call_1',
        'status': 'completed',
        'actions': [
          {
            'type': 'keypress',
            'keys': ['ctrl'],
          },
        ],
        'pending_safety_checks': [
          {'id': 'check_original'},
        ],
      };
      final call = Item.fromJson(json) as ComputerCallInputItem;
      final replacementChecks = <Map<String, dynamic>>[
        {'id': 'check_copy'},
      ];
      final copy = call.copyWith(pendingSafetyChecks: replacementChecks);
      replacementChecks.first['id'] = 'check_replaced';
      final sourceChecks = json['pending_safety_checks'] as List;
      (sourceChecks.single as Map<String, dynamic>)['id'] = 'check_replaced';
      final sourceActions = json['actions'] as List;
      final sourceAction = sourceActions.single as Map<String, dynamic>;
      (sourceAction['keys'] as List<String>).add('shift');

      expect(call.pendingSafetyChecks.single['id'], 'check_original');
      expect(copy.pendingSafetyChecks.single['id'], 'check_copy');
      expect((call.actions!.single as KeyPressAction).keys, ['ctrl']);
      expect(call.actions!.clear, throwsUnsupportedError);
      expect(call.pendingSafetyChecks.clear, throwsUnsupportedError);
      expect(
        () => call.pendingSafetyChecks.single['id'] = 'check_replaced',
        throwsUnsupportedError,
      );
      expect(
        (call.actions!.single as KeyPressAction).keys.clear,
        throwsUnsupportedError,
      );
      final serializedChecks = call.toJson()['pending_safety_checks'] as List;
      expect(serializedChecks.clear, throwsUnsupportedError);
      expect(call, Item.fromJson(call.toJson()));
    });

    test('snapshots every action variant without changing its wire fields', () {
      final keys = ['ctrl'];
      final path = <Map<String, dynamic>>[
        {'x': 10, 'y': 20},
      ];
      final actions = <ComputerAction>[
        ClickAction(button: ClickButton.left, x: 1, y: 2, keys: keys),
        DoubleClickAction(x: 1, y: 2, keys: keys),
        DragAction(path: path, keys: keys),
        KeyPressAction(keys: keys),
        MoveAction(x: 1, y: 2, keys: keys),
        ScrollAction(x: 1, y: 2, scrollX: 3, scrollY: 4, keys: keys),
        const ScreenshotAction(),
        const TypeAction(text: 'hello'),
        const WaitAction(),
      ];
      final call = ComputerCallInputItem(
        id: 'cu_1',
        callId: 'call_1',
        actions: actions,
        pendingSafetyChecks: const [],
        status: ItemStatus.completed,
      );
      final before = Item.fromJson(call.toJson());
      keys.clear();
      path.first['x'] = 99;
      actions.clear();

      expect(call, before);
      final drag = call.actions![2] as DragAction;
      expect(drag.path.clear, throwsUnsupportedError);
      expect(() => drag.path.single['x'] = 99, throwsUnsupportedError);
    });
  });

  test('input and stored results snapshot safety acknowledgments', () {
    final checks = [const ComputerSafetyCheck(id: 'check_1')];
    final input = ComputerCallOutputInputItem(
      callId: 'call_1',
      output: const ComputerScreenshotContent.file('file_1'),
      acknowledgedSafetyChecks: checks,
    );
    final resource = ComputerCallOutputResourceItem(
      id: 'out_1',
      callId: 'call_1',
      output: const ComputerScreenshotOutputContent(fileId: 'file_1'),
      status: ComputerCallOutputStatus.completed,
      acknowledgedSafetyChecks: checks,
    );
    final request = CreateResponseRequest(
      model: 'computer-model',
      input: ResponseInput.items([input]),
    );
    final inputHash = input.hashCode;
    final resourceHash = resource.hashCode;
    checks.clear();

    expect(input.acknowledgedSafetyChecks, hasLength(1));
    expect(resource.acknowledgedSafetyChecks, hasLength(1));
    expect(input.hashCode, inputHash);
    expect(resource.hashCode, resourceHash);
    final serializedInput = request.toJson()['input'] as List;
    final serializedItem = serializedInput.single as Map<String, dynamic>;
    expect(serializedItem['acknowledged_safety_checks'], [
      {'id': 'check_1'},
    ]);
    expect(input.acknowledgedSafetyChecks!.clear, throwsUnsupportedError);
    expect(resource.acknowledgedSafetyChecks!.clear, throwsUnsupportedError);

    final replacements = [const ComputerSafetyCheck(id: 'check_2')];
    final inputCopy = input.copyWith(acknowledgedSafetyChecks: replacements);
    final resourceCopy = resource.copyWith(
      acknowledgedSafetyChecks: replacements,
    );
    replacements.clear();
    expect(inputCopy.acknowledgedSafetyChecks!.single.id, 'check_2');
    expect(resourceCopy.acknowledgedSafetyChecks!.single.id, 'check_2');
    final replay = resourceCopy.toInputItem();
    expect(replay.acknowledgedSafetyChecks!.single.id, 'check_2');
    expect(replay.acknowledgedSafetyChecks!.clear, throwsUnsupportedError);
    expect(
      inputCopy
          .copyWith(acknowledgedSafetyChecks: null)
          .acknowledgedSafetyChecks,
      isNull,
    );
    expect(
      resourceCopy
          .copyWith(acknowledgedSafetyChecks: null)
          .acknowledgedSafetyChecks,
      isNull,
    );
  });

  test('replays singular and batched double-clicks with nullable keys', () {
    for (final keys in <List<String>?>[
      null,
      [],
      ['ctrl'],
    ]) {
      final action = <String, dynamic>{
        'type': 'double_click',
        'x': 10,
        'y': 20,
        'keys': keys,
      };
      for (final actionFields in [
        {'action': action},
        {
          'actions': [action],
        },
      ]) {
        final json = <String, dynamic>{
          'type': 'computer_call',
          'id': 'cu_1',
          'call_id': 'call_1',
          'status': 'completed',
          'pending_safety_checks': <Object?>[],
          ...actionFields,
        };
        expect(Item.fromJson(json).toJson(), json);
        expect(OutputItem.fromJson(json).toJson(), json);
      }
    }
  });

  test('resource statuses round-trip and map only valid input values', () {
    final base = {
      'type': 'computer_call_output',
      'id': 'out_1',
      'call_id': 'call_1',
      'output': {'type': 'computer_screenshot', 'file_id': 'file_1'},
    };
    for (final status in ['in_progress', 'completed', 'incomplete']) {
      final json = {...base, 'status': status};
      final item =
          Item.fromResourceJson(json) as ComputerCallOutputResourceItem;
      expect(item.toJson(), json);
      expect(item.toInputItem().toJson()['status'], status);
    }
    final failed =
        Item.fromResourceJson({...base, 'status': 'failed'})
            as ComputerCallOutputResourceItem;
    expect(failed.toJson()['status'], 'failed');
    expect(failed.toInputItem, throwsStateError);
    expect(
      failed.copyWith(status: ComputerCallOutputStatus.unknown).toInputItem,
      throwsStateError,
    );
  });

  test('round-trips complete computer history in a response request', () {
    final request = CreateResponseRequest(
      model: 'computer-model',
      input: ResponseInput.items([
        ComputerCallInputItem(
          id: 'cu_1',
          callId: 'call_1',
          pendingSafetyChecks: const [
            {'id': 'check_1', 'code': 'warning'},
          ],
          status: ItemStatus.completed,
          actions: const [
            ScreenshotAction(),
            TypeAction(text: 'hello'),
          ],
        ),
        ComputerCallOutputInputItem(
          callId: 'call_1',
          output: const ComputerScreenshotContent.url(
            'data:image/png;base64,AA==',
            detail: ImageDetail.original,
            promptCacheBreakpoint: PromptCacheBreakpointConfig(),
          ),
          acknowledgedSafetyChecks: const [
            ComputerSafetyCheck(id: 'check_1', code: 'warning'),
          ],
        ),
      ]),
    );
    final json = request.toJson();
    expect(CreateResponseRequest.fromJson(json).toJson(), json);
  });

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
    final item = ComputerCallOutputInputItem(
      callId: 'call_1',
      output: const ComputerScreenshotContent.url('data:image/png;base64,AA=='),
      acknowledgedSafetyChecks: const [
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
    expect(replayable.toInputItem().id, replayable.id);
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
