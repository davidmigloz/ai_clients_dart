import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolCall', () {
    test('creates with required fields', () {
      const call = ToolCall(toolType: ToolType.googleSearchWeb);
      expect(call.toolType, ToolType.googleSearchWeb);
      expect(call.args, isNull);
      expect(call.id, isNull);
    });

    test('creates with all fields', () {
      const call = ToolCall(
        toolType: ToolType.fileSearch,
        args: {'query': 'test'},
        id: 'call-123',
      );
      expect(call.toolType, ToolType.fileSearch);
      expect(call.args, {'query': 'test'});
      expect(call.id, 'call-123');
    });

    test('serializes to JSON', () {
      const call = ToolCall(
        toolType: ToolType.googleMaps,
        args: {'q': 'pizza'},
        id: 'tc-1',
      );
      final json = call.toJson();
      expect(json['toolType'], 'GOOGLE_MAPS');
      expect(json['args'], {'q': 'pizza'});
      expect(json['id'], 'tc-1');
    });

    test('omits null fields from JSON', () {
      const call = ToolCall(toolType: ToolType.urlContext);
      final json = call.toJson();
      expect(json.containsKey('args'), isFalse);
      expect(json.containsKey('id'), isFalse);
      expect(json['toolType'], 'URL_CONTEXT');
    });

    test('deserializes from JSON', () {
      final json = {
        'toolType': 'GOOGLE_SEARCH_WEB',
        'args': {'q': 'weather'},
        'id': 'call-456',
      };
      final call = ToolCall.fromJson(json);
      expect(call.toolType, ToolType.googleSearchWeb);
      expect(call.args, {'q': 'weather'});
      expect(call.id, 'call-456');
    });

    test('roundtrip serialization', () {
      const original = ToolCall(
        toolType: ToolType.fileSearch,
        args: {'query': 'dart'},
        id: 'tc-round',
      );
      final json = original.toJson();
      final restored = ToolCall.fromJson(json);
      expect(restored.toolType, original.toolType);
      expect(restored.args, original.args);
      expect(restored.id, original.id);
    });

    test('copyWith replaces values', () {
      const original = ToolCall(toolType: ToolType.googleMaps, id: 'old');
      final copy = original.copyWith(toolType: ToolType.urlContext, id: 'new');
      expect(copy.toolType, ToolType.urlContext);
      expect(copy.id, 'new');
    });

    test('copyWith preserves values by default', () {
      const original = ToolCall(
        toolType: ToolType.fileSearch,
        args: {'a': 1},
        id: 'keep',
      );
      final copy = original.copyWith();
      expect(copy.toolType, original.toolType);
      expect(copy.args, original.args);
      expect(copy.id, original.id);
    });
  });
}
