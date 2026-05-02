import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  // Regression tests for https://github.com/davidmigloz/ai_clients_dart/issues/208
  //
  // The OpenAI spec defines the FunctionCallStatus enum with values
  // ["in_progress", "completed", "incomplete"]. The Dart enum previously
  // shipped with ["completed", "failed"], which caused the API to reject
  // requests built with FunctionCallStatus.failed.
  group('FunctionCallStatus values match OpenAI spec', () {
    test('exposes in_progress, completed, incomplete', () {
      final wireValues = FunctionCallStatus.values
          .where((v) => v != FunctionCallStatus.unknown)
          .map((v) => v.toJson())
          .toSet();

      expect(wireValues, {'in_progress', 'completed', 'incomplete'});
    });

    test('does not expose failed', () {
      final names = FunctionCallStatus.values.map((v) => v.name).toSet();
      expect(names, isNot(contains('failed')));
    });

    test('round-trip all non-unknown values', () {
      for (final v in FunctionCallStatus.values.where(
        (v) => v != FunctionCallStatus.unknown,
      )) {
        expect(FunctionCallStatus.fromJson(v.toJson()), v);
      }
    });

    test('fromJson falls back to unknown for unrecognized values', () {
      expect(FunctionCallStatus.fromJson('failed'), FunctionCallStatus.unknown);
      expect(
        FunctionCallStatus.fromJson('whatever'),
        FunctionCallStatus.unknown,
      );
    });
  });

  group('FunctionCallOutputItem with status serializes valid wire value', () {
    test('serializes incomplete as "incomplete"', () {
      final item = FunctionCallOutputItem.string(
        callId: 'call_1',
        output: 'TOOL_CALL_ERROR: boom',
        status: FunctionCallStatus.incomplete,
      );

      expect(item.toJson()['status'], 'incomplete');
    });

    test('serializes in_progress as "in_progress"', () {
      final item = FunctionCallOutputItem.string(
        callId: 'call_1',
        output: 'partial',
        status: FunctionCallStatus.inProgress,
      );

      expect(item.toJson()['status'], 'in_progress');
    });

    test('serializes completed as "completed"', () {
      final item = FunctionCallOutputItem.string(
        callId: 'call_1',
        output: 'done',
        status: FunctionCallStatus.completed,
      );

      expect(item.toJson()['status'], 'completed');
    });
  });
}
