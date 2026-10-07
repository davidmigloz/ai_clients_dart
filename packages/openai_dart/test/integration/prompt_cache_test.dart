@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final apiKey = Platform.environment['OPENAI_API_KEY'];
  test(
    'prewarms and compares two bounded Responses requests',
    () async {
      final transport = _CaptureResponseIdsClient(http.Client());
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider(apiKey!),
          retryPolicy: const RetryPolicy(maxRetries: 0),
          timeout: const Duration(seconds: 60),
        ),
        httpClient: transport,
      );
      addTearDown(() async {
        final errors = <Object>[];
        for (final id in transport.responseIds) {
          try {
            await client.responses.delete(id);
          } catch (error) {
            errors.add(error);
          }
        }
        client.close();
        transport.close();
        expect(
          errors,
          isEmpty,
          reason: 'Every stored response should be deleted.',
        );
      });

      final prefix = List.generate(
        80,
        (i) =>
            'Reference entry $i: Keep the model, tools, settings, and prefix '
            'unchanged for cache reuse.',
      ).join('\n');
      final request = CreateResponseRequest(
        model: 'gpt-6-luna',
        input: ResponseInput.text('$prefix\nReply with only OK.'),
        reasoning: const ReasoningConfig(effort: ReasoningEffort.none),
        serviceTier: ServiceTier.defaultTier,
        maxOutputTokens: 16,
        store: true,
        promptCacheOptions: const ResponsePromptCacheOptionsParam(
          mode: PromptCacheMode.implicit,
          ttl: PromptCacheTtl.minutes30,
          prewarm: true,
        ),
      );
      final baseline = await client.responses.create(request);
      expect(baseline.status, ResponseStatus.completed);
      expect(baseline.output, isEmpty);
      expect(baseline.usage, isNotNull);
      expect(baseline.usage!.inputTokens, greaterThanOrEqualTo(1024));
      expect(baseline.usage!.outputTokens, 0);
      if (baseline.promptCacheOptions case final options?) {
        expect(options.mode, PromptCacheMode.implicit);
        expect(options.ttl, PromptCacheTtl.minutes30);
      }

      final compared = await client.responses.create(
        request.copyWith(
          promptCacheOptions: ResponsePromptCacheOptionsParam(
            mode: PromptCacheMode.implicit,
            ttl: PromptCacheTtl.minutes30,
            comparisonResponseId: baseline.id,
            prewarm: false,
          ),
        ),
      );
      expect(
        compared.status,
        anyOf(ResponseStatus.completed, ResponseStatus.incomplete),
      );
      if (compared.promptCacheOptions case final options?) {
        expect(options.mode, PromptCacheMode.implicit);
        expect(options.ttl, PromptCacheTtl.minutes30);
        if (options.comparisonResponseId != null) {
          expect(options.comparisonResponseId, baseline.id);
        }
      }
      expect(compared.usage, isNotNull);
      expect(compared.usage!.outputTokens, lessThanOrEqualTo(16));
      final diagnostic = compared.promptCacheDiagnostics;
      // Outcomes depend on server state. Absence, unavailable, expired comparison,
      // misses and hits are all legitimate; validate any returned typed payload.
      if (diagnostic != null) {
        expect(
          PromptCacheDiagnostics.fromJson(diagnostic.toJson()),
          diagnostic,
        );
      }
      if (diagnostic is PromptCacheMissDiagnostics) {
        expect(diagnostic.reason.value, isNotEmpty);
      }
      expect(transport.creationCount, 2);
      final input = baseline.usage!.inputTokens + compared.usage!.inputTokens;
      final output =
          baseline.usage!.outputTokens + compared.usage!.outputTokens;
      // Conservative Standard estimate: bill every input at the cache-write rate.
      final estimate = input * 0.125 / 1000000 + output * 0.50 / 1000000;
      // Only counters and the diagnostic discriminator are logged.
      // ignore: avoid_print
      print(
        'Cache smoke usage: input=$input, output=$output, '
        'diagnostic=${diagnostic?.type}, conservative_USD=$estimate',
      );
    },
    skip: apiKey == null || apiKey.trim().isEmpty
        ? 'OPENAI_API_KEY is not set.'
        : false,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

/// Captures IDs before SDK parsing so cleanup also runs on a parsing failure.
class _CaptureResponseIdsClient extends http.BaseClient {
  final http.Client _inner;
  final responseIds = <String>[];
  int creationCount = 0;

  _CaptureResponseIdsClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final creation =
        request.method == 'POST' && request.url.path.endsWith('/responses');
    if (creation && ++creationCount > 2) {
      throw StateError('Smoke test permits at most two paid requests.');
    }
    final response = await _inner.send(request);
    if (!creation) return response;
    final bytes = await response.stream.toBytes();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final id = json['id'];
      if (id is String) responseIds.add(id);
    }
    return http.StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      headers: response.headers,
      request: response.request,
      reasonPhrase: response.reasonPhrase,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      contentLength: bytes.length,
    );
  }

  @override
  void close() => _inner.close();
}
