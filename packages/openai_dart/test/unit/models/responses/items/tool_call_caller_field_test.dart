import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionCallItem.caller', () {
    test('round-trips through JSON', () {
      const item = FunctionCallItem(
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
        caller: ProgramToolCallCaller(callerId: 'call_program_1'),
      );

      final json = item.toJson();
      expect(json['caller'], {
        'type': 'program',
        'caller_id': 'call_program_1',
      });
      expect(Item.fromJson(json), item);
    });

    test('omits caller when null', () {
      const item = FunctionCallItem(
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
      );

      final json = item.toJson();
      expect(json.containsKey('caller'), isFalse);
      expect((Item.fromJson(json) as FunctionCallItem).caller, isNull);
    });
  });

  group('FunctionCallOutputItem.caller', () {
    test('round-trips through JSON', () {
      final item = FunctionCallOutputItem.string(
        callId: 'call_1',
        output: 'sunny',
        caller: const DirectToolCallCaller(),
      );

      final json = item.toJson();
      expect(json['caller'], {'type': 'direct'});
      expect(Item.fromJson(json), item);
    });

    test('omits caller when null', () {
      final item = FunctionCallOutputItem.string(
        callId: 'call_1',
        output: 'sunny',
      );

      final json = item.toJson();
      expect(json.containsKey('caller'), isFalse);
    });

    test('copyWith preserves and clears caller', () {
      final item = FunctionCallOutputItem.string(
        callId: 'call_1',
        output: 'sunny',
        caller: const DirectToolCallCaller(),
      );

      final cleared = item.copyWith(caller: null);
      expect(cleared.caller, isNull);

      final kept = item.copyWith();
      expect(kept.caller, item.caller);
    });
  });

  group('CustomToolCallOutputInputItem.caller', () {
    test('round-trips through JSON', () {
      final item = CustomToolCallOutputInputItem.string(
        callId: 'call_1',
        output: 'done',
        caller: const ProgramToolCallCaller(callerId: 'call_program_1'),
      );

      final json = item.toJson();
      expect(json['caller'], {
        'type': 'program',
        'caller_id': 'call_program_1',
      });
      expect(Item.fromJson(json), item);
    });

    test('omits caller when null', () {
      final item = CustomToolCallOutputInputItem.string(
        callId: 'call_1',
        output: 'done',
      );

      final json = item.toJson();
      expect(json.containsKey('caller'), isFalse);
    });
  });

  group('FunctionCallOutputItemResponse.caller', () {
    test('round-trips through JSON', () {
      const item = FunctionCallOutputItemResponse(
        id: 'fc_1',
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
        caller: DirectToolCallCaller(),
      );

      final json = item.toJson();
      expect(json['caller'], {'type': 'direct'});
      expect(OutputItem.fromJson(json), item);
    });

    test('omits caller when null and toFunctionCallItem preserves it', () {
      const item = FunctionCallOutputItemResponse(
        id: 'fc_1',
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
        caller: ProgramToolCallCaller(callerId: 'call_program_1'),
      );

      final asItem = item.toFunctionCallItem();
      expect(asItem.caller, item.caller);
    });
  });

  group('CustomToolCallItem.caller', () {
    test('round-trips through JSON', () {
      const item = CustomToolCallItem(
        id: 'ctc_1',
        callId: 'call_1',
        name: 'my_tool',
        input: '{}',
        caller: DirectToolCallCaller(),
      );

      final json = item.toJson();
      expect(json['caller'], {'type': 'direct'});
      expect(OutputItem.fromJson(json), item);
    });

    test('omits caller when null', () {
      const item = CustomToolCallItem(
        id: 'ctc_1',
        callId: 'call_1',
        name: 'my_tool',
        input: '{}',
      );

      final json = item.toJson();
      expect(json.containsKey('caller'), isFalse);
    });
  });

  group('ShellCallOutputItem.caller', () {
    test('round-trips through JSON', () {
      const item = ShellCallOutputItem(
        id: 'sc_1',
        callId: 'call_1',
        action: ShellCallAction(commands: ['ls']),
        status: ItemStatus.completed,
        caller: ProgramToolCallCaller(callerId: 'call_123'),
      );

      final json = item.toJson();
      expect(json['caller'], {'type': 'program', 'caller_id': 'call_123'});
      expect(OutputItem.fromJson(json), item);
    });

    test('omits caller when null', () {
      const item = ShellCallOutputItem(
        id: 'sc_1',
        callId: 'call_1',
        action: ShellCallAction(commands: ['ls']),
        status: ItemStatus.completed,
      );

      final json = item.toJson();
      expect(json.containsKey('caller'), isFalse);
      expect((OutputItem.fromJson(json) as ShellCallOutputItem).caller, isNull);
    });
  });

  group('ShellCallOutputResultItem.caller', () {
    test('round-trips through JSON', () {
      const item = ShellCallOutputResultItem(
        id: 'sco_1',
        callId: 'call_1',
        output: [],
        maxOutputLength: 1000,
        caller: ProgramToolCallCaller(callerId: 'call_123'),
      );

      final json = item.toJson();
      expect(json['caller'], {'type': 'program', 'caller_id': 'call_123'});
      expect(OutputItem.fromJson(json), item);
    });

    test('omits caller when null', () {
      const item = ShellCallOutputResultItem(
        id: 'sco_1',
        callId: 'call_1',
        output: [],
        maxOutputLength: 1000,
      );

      final json = item.toJson();
      expect(json.containsKey('caller'), isFalse);
      expect(
        (OutputItem.fromJson(json) as ShellCallOutputResultItem).caller,
        isNull,
      );
    });
  });

  group('CustomToolCallOutputItem.caller', () {
    test('round-trips through JSON', () {
      const item = CustomToolCallOutputItem(
        id: 'ctco_1',
        callId: 'call_1',
        output: FunctionCallOutputString('done'),
        caller: ProgramToolCallCaller(callerId: 'call_program_1'),
      );

      final json = item.toJson();
      expect(json['caller'], {
        'type': 'program',
        'caller_id': 'call_program_1',
      });
      expect(OutputItem.fromJson(json), item);
    });

    test('omits caller when null', () {
      const item = CustomToolCallOutputItem(
        id: 'ctco_1',
        callId: 'call_1',
        output: FunctionCallOutputString('done'),
      );

      final json = item.toJson();
      expect(json.containsKey('caller'), isFalse);
    });
  });
}
