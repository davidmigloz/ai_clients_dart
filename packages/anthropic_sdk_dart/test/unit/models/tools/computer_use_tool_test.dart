import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ComputerUseTool', () {
    test('toJson with minimal fields', () {
      const tool = ComputerUseTool(displayWidthPx: 1024, displayHeightPx: 768);
      final json = tool.toJson();

      expect(json['type'], 'computer_20251124');
      expect(json['name'], 'computer');
      expect(json['display_width_px'], 1024);
      expect(json['display_height_px'], 768);
      expect(json.containsKey('allowed_callers'), isFalse);
      expect(json.containsKey('defer_loading'), isFalse);
      expect(json.containsKey('strict'), isFalse);
      expect(json.containsKey('input_examples'), isFalse);
      expect(json.containsKey('enable_zoom'), isFalse);
    });

    test('toJson with all parity fields (computer_20251124)', () {
      const tool = ComputerUseTool(
        displayWidthPx: 1024,
        displayHeightPx: 768,
        displayNumber: 1,
        allowedCallers: ['direct', 'code_execution_20260120'],
        deferLoading: true,
        strict: true,
        inputExamples: [
          {'action': 'screenshot'},
        ],
        enableZoom: true,
      );
      final json = tool.toJson();

      expect(json['allowed_callers'], ['direct', 'code_execution_20260120']);
      expect(json['defer_loading'], true);
      expect(json['strict'], true);
      expect(json['input_examples'], [
        {'action': 'screenshot'},
      ]);
      expect(json['enable_zoom'], true);
    });

    test('fromJson round-trip with parity fields', () {
      final json = {
        'type': 'computer_20251124',
        'name': 'computer',
        'display_width_px': 1024,
        'display_height_px': 768,
        'allowed_callers': ['direct'],
        'defer_loading': false,
        'strict': true,
        'input_examples': [
          {'action': 'left_click'},
        ],
        'enable_zoom': true,
      };
      final tool = ComputerUseTool.fromJson(json);

      expect(tool.allowedCallers, ['direct']);
      expect(tool.deferLoading, false);
      expect(tool.strict, true);
      expect(tool.inputExamples, [
        {'action': 'left_click'},
      ]);
      expect(tool.enableZoom, true);
      expect(tool.toJson(), json);
    });

    test('BuiltInTool.fromJson dispatches to ComputerUseTool', () {
      final json = {
        'type': 'computer_20251124',
        'name': 'computer',
        'display_width_px': 1024,
        'display_height_px': 768,
      };
      final tool = BuiltInTool.fromJson(json);

      expect(tool, isA<ComputerUseTool>());
      expect((tool as ComputerUseTool).displayWidthPx, 1024);
    });

    test('BuiltInTool.computerUse forwards parity fields', () {
      final tool =
          BuiltInTool.computerUse(
                displayWidthPx: 1024,
                displayHeightPx: 768,
                allowedCallers: const ['direct'],
                deferLoading: true,
                strict: true,
                inputExamples: const [
                  {'action': 'screenshot'},
                ],
                enableZoom: true,
              )
              as ComputerUseTool;

      expect(tool.allowedCallers, ['direct']);
      expect(tool.deferLoading, true);
      expect(tool.strict, true);
      expect(tool.inputExamples, [
        {'action': 'screenshot'},
      ]);
      expect(tool.enableZoom, true);
    });

    test('v20241022 factory forwards parity fields', () {
      final tool = ComputerUseTool.v20241022(
        displayWidthPx: 1024,
        displayHeightPx: 768,
        allowedCallers: const ['direct'],
        deferLoading: true,
        strict: true,
        inputExamples: const [
          {'action': 'screenshot'},
        ],
      );

      expect(tool.type, 'computer_20241022');
      expect(tool.allowedCallers, ['direct']);
      expect(tool.deferLoading, true);
      expect(tool.strict, true);
      expect(tool.inputExamples, [
        {'action': 'screenshot'},
      ]);
      // Forwarded fields are serialized for the older version too...
      final json = tool.toJson();
      expect(json['allowed_callers'], ['direct']);
      expect(json['input_examples'], [
        {'action': 'screenshot'},
      ]);
    });

    test('v20250124 factory forwards parity fields', () {
      final tool = ComputerUseTool.v20250124(
        displayWidthPx: 1024,
        displayHeightPx: 768,
        allowedCallers: const ['direct'],
        deferLoading: true,
        strict: true,
        inputExamples: const [
          {'action': 'screenshot'},
        ],
      );

      expect(tool.type, 'computer_20250124');
      expect(tool.toJson()['strict'], true);
    });

    test('enable_zoom only serializes for computer_20251124', () {
      // Older version objects must never emit enable_zoom, even if the field
      // is set via copyWith / manual type override.
      final older = ComputerUseTool.v20250124(
        displayWidthPx: 1024,
        displayHeightPx: 768,
      ).copyWith(enableZoom: true);

      expect(older.enableZoom, true);
      expect(older.toJson().containsKey('enable_zoom'), isFalse);

      // The latest version serializes it.
      final latest = const ComputerUseTool(
        displayWidthPx: 1024,
        displayHeightPx: 768,
      ).copyWith(enableZoom: true);
      expect(latest.toJson()['enable_zoom'], true);
    });

    test('equality and copyWith include parity fields', () {
      const a = ComputerUseTool(
        displayWidthPx: 1024,
        displayHeightPx: 768,
        strict: true,
      );
      const b = ComputerUseTool(
        displayWidthPx: 1024,
        displayHeightPx: 768,
        strict: true,
      );
      const c = ComputerUseTool(
        displayWidthPx: 1024,
        displayHeightPx: 768,
        strict: false,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));

      final cleared = a.copyWith(strict: null);
      expect(cleared.strict, isNull);
    });

    test('toString includes parity fields', () {
      const tool = ComputerUseTool(displayWidthPx: 1024, displayHeightPx: 768);
      expect(tool.toString(), contains('ComputerUseTool'));
      expect(tool.toString(), contains('enableZoom'));
    });
  });
}
