import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolResponse', () {
    test('creates with required fields', () {
      const resp = ToolResponse(toolType: ToolType.googleSearchWeb);
      expect(resp.toolType, ToolType.googleSearchWeb);
      expect(resp.response, isNull);
      expect(resp.id, isNull);
    });

    test('creates with all fields', () {
      const resp = ToolResponse(
        toolType: ToolType.fileSearch,
        response: {'results': <dynamic>[]},
        id: 'resp-123',
      );
      expect(resp.toolType, ToolType.fileSearch);
      expect(resp.response, {'results': <dynamic>[]});
      expect(resp.id, 'resp-123');
    });

    test('serializes to JSON', () {
      const resp = ToolResponse(
        toolType: ToolType.googleMaps,
        response: {'places': <dynamic>[]},
        id: 'tr-1',
      );
      final json = resp.toJson();
      expect(json['toolType'], 'GOOGLE_MAPS');
      expect(json['response'], {'places': <dynamic>[]});
      expect(json['id'], 'tr-1');
    });

    test('omits null fields from JSON', () {
      const resp = ToolResponse(toolType: ToolType.urlContext);
      final json = resp.toJson();
      expect(json.containsKey('response'), isFalse);
      expect(json.containsKey('id'), isFalse);
    });

    test('deserializes from JSON', () {
      final json = {
        'toolType': 'FILE_SEARCH',
        'response': {'data': 'test'},
        'id': 'resp-456',
      };
      final resp = ToolResponse.fromJson(json);
      expect(resp.toolType, ToolType.fileSearch);
      expect(resp.response, {'data': 'test'});
      expect(resp.id, 'resp-456');
    });

    test('roundtrip serialization', () {
      const original = ToolResponse(
        toolType: ToolType.googleSearchWeb,
        response: {'results': <dynamic>[]},
        id: 'tr-round',
      );
      final json = original.toJson();
      final restored = ToolResponse.fromJson(json);
      expect(restored.toolType, original.toolType);
      expect(restored.response, original.response);
      expect(restored.id, original.id);
    });

    test('copyWith replaces values', () {
      const original = ToolResponse(toolType: ToolType.googleMaps, id: 'old');
      final copy = original.copyWith(toolType: ToolType.urlContext, id: 'new');
      expect(copy.toolType, ToolType.urlContext);
      expect(copy.id, 'new');
    });

    test('copyWith preserves values by default', () {
      const original = ToolResponse(
        toolType: ToolType.fileSearch,
        response: {'a': 1},
        id: 'keep',
      );
      final copy = original.copyWith();
      expect(copy.toolType, original.toolType);
      expect(copy.response, original.response);
      expect(copy.id, original.id);
    });
  });
}
