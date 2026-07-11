import 'package:openai_dart/src/models/responses/tools/tool_call_caller.dart';
import 'package:test/test.dart';

void main() {
  group('DirectToolCallCaller', () {
    test('round-trips toJson/fromJson', () {
      const caller = DirectToolCallCaller();
      final json = caller.toJson();

      expect(json, {'type': 'direct'});
      expect(ToolCallCaller.fromJson(json), caller);
    });

    test('defaults type to direct', () {
      const caller = DirectToolCallCaller();
      expect(caller.type, 'direct');
    });

    test('equality and hashCode', () {
      const a = DirectToolCallCaller();
      const b = DirectToolCallCaller();

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('ProgramToolCallCaller', () {
    test('round-trips toJson/fromJson', () {
      const caller = ProgramToolCallCaller(callerId: 'call_123');
      final json = caller.toJson();

      expect(json, {'type': 'program', 'caller_id': 'call_123'});
      expect(ToolCallCaller.fromJson(json), caller);
    });

    test('defaults type to program', () {
      const caller = ProgramToolCallCaller(callerId: 'call_123');
      expect(caller.type, 'program');
    });

    test('equality and hashCode', () {
      const a = ProgramToolCallCaller(callerId: 'call_123');
      const b = ProgramToolCallCaller(callerId: 'call_123');
      const c = ProgramToolCallCaller(callerId: 'call_456');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('ToolCallCaller.fromJson', () {
    test('dispatches to DirectToolCallCaller', () {
      final caller = ToolCallCaller.fromJson({'type': 'direct'});
      expect(caller, isA<DirectToolCallCaller>());
    });

    test('dispatches to ProgramToolCallCaller', () {
      final caller = ToolCallCaller.fromJson({
        'type': 'program',
        'caller_id': 'call_1',
      });
      expect(caller, isA<ProgramToolCallCaller>());
      expect((caller as ProgramToolCallCaller).callerId, 'call_1');
    });

    test('throws FormatException for unknown type', () {
      expect(
        () => ToolCallCaller.fromJson({'type': 'bogus'}),
        throwsFormatException,
      );
    });
  });

  group('CallableToolAllowedCaller', () {
    test('round-trips direct and programmatic', () {
      expect(
        CallableToolAllowedCaller.fromJson('direct'),
        CallableToolAllowedCaller.direct,
      );
      expect(
        CallableToolAllowedCaller.fromJson('programmatic'),
        CallableToolAllowedCaller.programmatic,
      );
      expect(CallableToolAllowedCaller.direct.toJson(), 'direct');
      expect(CallableToolAllowedCaller.programmatic.toJson(), 'programmatic');
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        CallableToolAllowedCaller.fromJson('whatever'),
        CallableToolAllowedCaller.unknown,
      );
    });
  });
}
