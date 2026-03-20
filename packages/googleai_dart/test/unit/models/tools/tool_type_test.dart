import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolType', () {
    test('toolTypeFromString converts known values', () {
      expect(toolTypeFromString('FILE_SEARCH'), ToolType.fileSearch);
      expect(toolTypeFromString('GOOGLE_MAPS'), ToolType.googleMaps);
      expect(
        toolTypeFromString('GOOGLE_SEARCH_IMAGE'),
        ToolType.googleSearchImage,
      );
      expect(toolTypeFromString('GOOGLE_SEARCH_WEB'), ToolType.googleSearchWeb);
      expect(toolTypeFromString('URL_CONTEXT'), ToolType.urlContext);
      expect(toolTypeFromString('TOOL_TYPE_UNSPECIFIED'), ToolType.unspecified);
    });

    test('toolTypeFromString returns unspecified for unknown values', () {
      expect(toolTypeFromString('UNKNOWN'), ToolType.unspecified);
      expect(toolTypeFromString(null), ToolType.unspecified);
    });

    test('toolTypeToString converts all values', () {
      expect(toolTypeToString(ToolType.fileSearch), 'FILE_SEARCH');
      expect(toolTypeToString(ToolType.googleMaps), 'GOOGLE_MAPS');
      expect(
        toolTypeToString(ToolType.googleSearchImage),
        'GOOGLE_SEARCH_IMAGE',
      );
      expect(toolTypeToString(ToolType.googleSearchWeb), 'GOOGLE_SEARCH_WEB');
      expect(toolTypeToString(ToolType.urlContext), 'URL_CONTEXT');
      expect(toolTypeToString(ToolType.unspecified), 'TOOL_TYPE_UNSPECIFIED');
    });

    test('roundtrip conversion', () {
      for (final type in ToolType.values) {
        expect(toolTypeFromString(toolTypeToString(type)), type);
      }
    });
  });
}
