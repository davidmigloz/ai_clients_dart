import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'breakpoint TTL is distinct from request and Decisions cache controls',
    () {
      for (final ttl in PromptCacheBreakpointTtl.values) {
        final marker = PromptCacheBreakpointConfig(ttl: ttl);
        final decoded = PromptCacheBreakpointConfig.fromJson(marker.toJson());
        expect(decoded, marker);
        expect(decoded.hashCode, marker.hashCode);
        expect(marker.copyWith(), marker);
        expect(marker.toString(), contains('ttl:'));
        expect(marker.copyWith(ttl: null).toJson(), {'mode': 'explicit'});
      }
      expect(const PromptCacheBreakpointConfig().toJson(), {
        'mode': 'explicit',
      });
      expect(PromptCacheTtl.fromJson('12h'), PromptCacheTtl.unknown);
      expect(
        () => DecisionPromptCacheOptions.fromJson(const {'ttl': '12h'}),
        throwsFormatException,
      );
      for (final marker in [
        <String, dynamic>{},
        {'mode': 'implicit'},
        {'mode': 'explicit', 'ttl': null},
        {'mode': 'explicit', 'ttl': 12},
      ]) {
        expect(
          () => PromptCacheBreakpointConfig.fromJson(marker),
          throwsFormatException,
        );
      }
      expect(
        PromptCacheBreakpointTtl.fromJson('future'),
        PromptCacheBreakpointTtl.unknown,
      );
    },
  );

  test('all shared input and echoed content parts retain TTL overrides', () {
    final parts = <Map<String, dynamic>>[
      {'type': 'input_text', 'text': 'shared'},
      {'type': 'input_image', 'image_url': 'https://example.invalid/a.png'},
      {'type': 'input_file', 'file_id': 'file_1'},
    ];
    for (final part in parts) {
      final json = {
        ...part,
        'prompt_cache_breakpoint': {'mode': 'explicit', 'ttl': '12h'},
      };
      expect(InputContent.fromJson(json).toJson(), json);
      final echoed = OutputContent.fromJson(json);
      expect(echoed.toJson(), json);
      if (echoed is InputTextOutputContent) {
        expect(echoed.copyWith(), echoed);
        expect(echoed.copyWith().hashCode, echoed.hashCode);
        expect(
          echoed
              .copyWith(promptCacheBreakpoint: null)
              .toJson()
              .containsKey('prompt_cache_breakpoint'),
          isFalse,
        );
        expect(echoed.toString(), contains('promptCacheBreakpoint:'));
      }
    }
  });

  test(
    'hosted usage has complete immutable value semantics and optional counts',
    () {
      final usage = ResponseToolUsage.fromJson(toolUsageJson());
      final restored = ResponseToolUsage.fromJson(usage.toJson());
      expect(restored, usage);
      expect(restored.hashCode, usage.hashCode);
      expect(usage.copyWith(), usage);
      expect(
        usage.copyWith(webSearch: const WebSearchUsage(numRequests: 2)),
        isNot(usage),
      );
      expect(usage.webSearch.copyWith(numRequests: 3).numRequests, 3);
      expect(
        usage.imageGen
            .copyWith(
              cachedTokens: null,
              cachedTokensDetails: null,
              outputTokensDetails: null,
            )
            .toJson(),
        {
          'input_tokens': 10,
          'output_tokens': 20,
          'total_tokens': 30,
          'input_tokens_details': {'text_tokens': 3, 'image_tokens': 7},
        },
      );
      expect(
        usage.imageGen.inputTokensDetails.copyWith(textTokens: 4).textTokens,
        4,
      );
      expect(
        usage.imageGen.outputTokensDetails!
            .copyWith(imageTokens: 99)
            .imageTokens,
        99,
      );
      expect(
        usage.imageGen.cachedTokensDetails!
            .copyWith(cachedTextTokens: 4)
            .cachedTextTokens,
        4,
      );
      final noCache = toolUsageJson();
      (noCache['image_gen'] as Map<String, dynamic>)
        ..remove('cached_tokens')
        ..remove('cached_tokens_details')
        ..remove('output_tokens_details');
      final incomplete = ResponseToolUsage.fromJson(noCache);
      expect(incomplete.imageGen.cachedTokens, isNull);
      expect(incomplete.imageGen.cachedTokensDetails, isNull);
      expect(incomplete.toJson(), noCache);
      expect(usage.toString(), contains('webSearch:'));
      expect(usage.imageGen.toString(), contains('cachedTokens: 2'));
      for (final malformed in [
        <String, dynamic>{},
        {...toolUsageJson(), 'web_search': <String, dynamic>{}},
        {...toolUsageJson(), 'image_gen': null},
        {
          ...toolUsageJson(),
          'web_search': {'num_requests': 1.5},
        },
      ]) {
        expect(
          () => ResponseToolUsage.fromJson(malformed),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'terminal error type preserves absent, null and text with copy clearing',
    () {
      for (final fields in [
        <String, dynamic>{},
        {'type': null, 'param': null},
        {'type': 'provider', 'param': 'input'},
      ]) {
        final json = {
          'code': 'server_error',
          'message': 'private',
          ...fields,
          'future': {
            'values': [1],
          },
        };
        final error = ResponseError.fromJson(json);
        expect(error.type, fields['type']);
        expect(error.toJson(), json);
        expect(error.copyWith().toJson(), json);
        expect(ResponseError.fromJson(error.toJson()), error);
        expect(ResponseError.fromJson(error.toJson()).hashCode, error.hashCode);
        expect(error.copyWith(type: null).toJson()['type'], isNull);
        expect(
          error
              .copyWith(type: null, hasType: false)
              .toJson()
              .containsKey('type'),
          isFalse,
        );
        expect(error.toString(), isNot(contains('private')));
      }
    },
  );

  test(
    'video Error-2 preserves nullable fields, retry headers and future details',
    () {
      final nested = <Object?>[1];
      final json = <String, dynamic>{
        'code': 'server_error',
        'message': 'private',
        'type': null,
        'param': null,
        'headers': {'retry-after': '1'},
        'misalignment': {'review_target': null, 'future': nested},
        'future': {'v': nested},
      };
      final sourceHeaders = <String, String>{'retry-after': '1'};
      final constructed = VideoError.withDetails(
        message: 'private',
        code: 'server_error',
        headers: sourceHeaders,
        rawJson: {
          'future': {'v': nested},
        },
      );
      sourceHeaders.clear();
      final error = VideoError.fromJson(json);
      nested.clear();
      expect(constructed.headers, {'retry-after': '1'});
      expect((constructed.rawJson['future'] as Map<String, dynamic>)['v'], [1]);
      expect(error.type, isNull);
      expect(error.param, isNull);
      expect(error.headers, {'retry-after': '1'});
      expect(error.headers!.clear, throwsUnsupportedError);
      expect(error.rawJson.clear, throwsUnsupportedError);
      expect((error.toJson()['future'] as Map<String, dynamic>)['v'], [1]);
      expect(VideoError.fromJson(error.toJson()), error);
      expect(VideoError.fromJson(error.toJson()).hashCode, error.hashCode);
      expect(error.copyWith(), error);
      expect(error.copyWith(type: 'provider', param: 'input').type, 'provider');
      expect(
        error.copyWith(type: null, hasType: false).toJson().containsKey('type'),
        isFalse,
      );
      expect(
        error
            .copyWith(headers: null, misalignment: null)
            .toJson()
            .containsKey('headers'),
        isFalse,
      );
      expect(
        error
            .copyWith(
              misalignment: const ResponsesMisalignmentDetails(
                errorType: 'other',
              ),
            )
            .toJson()['misalignment'],
        {'error_type': 'other'},
      );
      expect(error.toString(), isNot(contains('private')));
    },
  );

  test(
    'find action accepts optional nullable URL and clears it explicitly',
    () {
      for (final fields in [
        <String, dynamic>{},
        {'url': null},
        {'url': 'https://example.invalid'},
      ]) {
        final action =
            WebSearchAction.fromJson({
                  'type': 'find_in_page',
                  'pattern': 'text',
                  ...fields,
                })
                as WebSearchActionFind;
        expect(action.url, fields['url']);
        expect(action.copyWith(), action);
        expect(WebSearchAction.fromJson(action.toJson()), action);
        expect(
          WebSearchAction.fromJson(action.toJson()).hashCode,
          action.hashCode,
        );
        expect(action.copyWith(url: null).toJson().containsKey('url'), isFalse);
      }
    },
  );
}

Map<String, dynamic> toolUsageJson() => {
  'image_gen': {
    'input_tokens': 10,
    'output_tokens': 20,
    'total_tokens': 30,
    'input_tokens_details': {'text_tokens': 3, 'image_tokens': 7},
    'output_tokens_details': {'text_tokens': 1, 'image_tokens': 19},
    'cached_tokens': 2,
    'cached_tokens_details': {
      'cached_text_tokens': 1,
      'cached_image_tokens': 1,
    },
  },
  'web_search': {'num_requests': 1},
};
