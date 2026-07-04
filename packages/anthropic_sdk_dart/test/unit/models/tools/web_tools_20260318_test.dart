import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseInclusion enum', () {
    test('round-trips through JSON', () {
      expect(ResponseInclusion.fromJson('full'), ResponseInclusion.full);
      expect(
        ResponseInclusion.fromJson('excluded'),
        ResponseInclusion.excluded,
      );
      expect(ResponseInclusion.full.toJson(), 'full');
      expect(ResponseInclusion.excluded.toJson(), 'excluded');
    });

    test('throws on an unknown value', () {
      expect(
        () => ResponseInclusion.fromJson('partial'),
        throwsFormatException,
      );
    });
  });

  group('WebSearchTool web_search_20260318', () {
    test('round-trips response_inclusion', () {
      const tool = WebSearchTool(
        type: 'web_search_20260318',
        responseInclusion: ResponseInclusion.excluded,
      );
      expect(tool.responseInclusion, ResponseInclusion.excluded);
      final json = tool.toJson();
      expect(json['type'], 'web_search_20260318');
      expect(json['response_inclusion'], 'excluded');

      final parsed = WebSearchTool.fromJson(json);
      expect(parsed.responseInclusion, ResponseInclusion.excluded);
      expect(parsed.toJson(), json);
    });

    test('normalizes response_inclusion to null for older versions', () {
      const tool = WebSearchTool(
        type: 'web_search_20260209',
        responseInclusion: ResponseInclusion.full,
      );
      expect(tool.responseInclusion, isNull);
      expect(tool.toJson().containsKey('response_inclusion'), isFalse);
    });

    test('BuiltInTool.fromJson dispatches web_search_20260318', () {
      final tool = BuiltInTool.fromJson({
        'type': 'web_search_20260318',
        'name': 'web_search',
        'response_inclusion': 'full',
      });
      expect(tool, isA<WebSearchTool>());
      expect((tool as WebSearchTool).responseInclusion, ResponseInclusion.full);
    });

    test('BuiltInTool.webSearch factory forwards responseInclusion', () {
      final tool =
          BuiltInTool.webSearch(
                type: 'web_search_20260318',
                responseInclusion: ResponseInclusion.excluded,
              )
              as WebSearchTool;
      expect(tool.responseInclusion, ResponseInclusion.excluded);
    });
  });

  group('WebFetchTool web_fetch_20260318', () {
    test('round-trips response_inclusion and use_cache', () {
      const tool = WebFetchTool(
        type: 'web_fetch_20260318',
        responseInclusion: ResponseInclusion.excluded,
        useCache: false,
      );
      expect(tool.responseInclusion, ResponseInclusion.excluded);
      expect(tool.useCache, isFalse);
      final json = tool.toJson();
      expect(json['type'], 'web_fetch_20260318');
      expect(json['response_inclusion'], 'excluded');
      expect(json['use_cache'], false);

      final parsed = WebFetchTool.fromJson(json);
      expect(parsed.responseInclusion, ResponseInclusion.excluded);
      expect(parsed.useCache, isFalse);
      expect(parsed.toJson(), json);
    });

    test('use_cache still supported for web_fetch_20260309', () {
      const tool = WebFetchTool(type: 'web_fetch_20260309', useCache: false);
      expect(tool.useCache, isFalse);
      expect(tool.toJson()['use_cache'], false);
    });

    test('use_cache normalized to null for web_fetch_20260209', () {
      const tool = WebFetchTool(type: 'web_fetch_20260209', useCache: false);
      expect(tool.useCache, isNull);
      expect(tool.toJson().containsKey('use_cache'), isFalse);
    });

    test('response_inclusion normalized to null for web_fetch_20260309', () {
      const tool = WebFetchTool(
        type: 'web_fetch_20260309',
        responseInclusion: ResponseInclusion.full,
      );
      expect(tool.responseInclusion, isNull);
      expect(tool.toJson().containsKey('response_inclusion'), isFalse);
    });

    test('BuiltInTool.fromJson dispatches web_fetch_20260318', () {
      final tool = BuiltInTool.fromJson({
        'type': 'web_fetch_20260318',
        'name': 'web_fetch',
        'response_inclusion': 'excluded',
      });
      expect(tool, isA<WebFetchTool>());
      expect(
        (tool as WebFetchTool).responseInclusion,
        ResponseInclusion.excluded,
      );
    });

    test('BuiltInTool.webFetch factory forwards responseInclusion', () {
      final tool =
          BuiltInTool.webFetch(
                type: 'web_fetch_20260318',
                responseInclusion: ResponseInclusion.full,
              )
              as WebFetchTool;
      expect(tool.responseInclusion, ResponseInclusion.full);
    });
  });
}
