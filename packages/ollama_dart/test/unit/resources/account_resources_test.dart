import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  final balanceJson = <String, dynamic>{
    'included': {
      'balance_usd': 72.5,
      'allowance_usd': 100,
      'period': {
        'from': '2026-10-01T00:00:00Z',
        'until': '2026-11-01T00:00:00Z',
      },
    },
    'purchased': {'balance_usd': 25},
  };
  final usageJson = <String, dynamic>{
    'range': '7d',
    'scope': 'self',
    'granularity': 'day',
    'from': '2026-10-01T00:00:00Z',
    'until': '2026-10-08T02:30:00Z',
    'totals': {'request_count': 2, 'usage_usd': 0.01},
    'buckets': [
      {
        'from': '2026-10-01T00:00:00Z',
        'until': '2026-10-02T00:00:00Z',
        'request_count': 0,
      },
      {
        'from': '2026-10-08T00:00:00Z',
        'until': '2026-10-08T02:30:00Z',
        'partial': true,
        'request_count': 2,
        'usage_usd': 0.01,
      },
    ],
  };

  for (final isBalance in [true, false]) {
    final name = isBalance ? 'balance' : 'usage';
    final responseJson = isBalance ? balanceJson : usageJson;
    Future<Object> get(OllamaClient client, {Future<void>? abortTrigger}) =>
        isBalance
        ? client.balance.get(abortTrigger: abortTrigger)
        : client.usage.get(abortTrigger: abortTrigger);

    group('Account $name resource', () {
      test(
        'requests local proxy without invented selectors or authorization',
        () async {
          final transport = MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.toString(), 'http://localhost:11434/api/$name');
            expect(request.url.hasQuery, isFalse);
            expect(request.headers['authorization'], isNull);
            expect(request.bodyBytes, isEmpty);
            return http.Response(jsonEncode(responseJson), 200);
          });
          final client = OllamaClient(httpClient: transport);
          addTearDown(client.close);
          addTearDown(transport.close);
          final response = await get(client);
          if (response is BalanceResponse) {
            expect((response.included as IncludedBalance).balanceUsd, 72.5);
            expect(response.purchased.balanceUsd, 25);
          } else {
            final usage = response as UsageResponse;
            expect(usage.totals.requestCount, 2);
            expect(usage.buckets.first.requestCount, 0);
            expect(usage.buckets.last.partial, isTrue);
            expect(usage.from.isUtc, isTrue);
          }
        },
      );

      test('uses explicit cloud URL and bearer authentication', () async {
        final transport = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.toString(), 'https://ollama.com/api/$name');
          expect(request.headers['authorization'], 'Bearer cloud-key');
          expect(request.headers['x-custom'], 'value');
          expect(request.bodyBytes, isEmpty);
          return http.Response(jsonEncode(responseJson), 200);
        });
        final client = OllamaClient(
          config: const OllamaConfig(
            baseUrl: 'https://ollama.com',
            authProvider: BearerTokenProvider('cloud-key'),
            defaultHeaders: {'X-Custom': 'value'},
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        addTearDown(transport.close);
        await get(client);
      });

      test(
        'preserves proxy subpaths and configured query parameters',
        () async {
          final transport = MockClient((request) async {
            expect(request.url.path, '/proxy/ollama/api/$name');
            expect(request.url.queryParameters, {'tenant': 'a', 'mode': 'new'});
            return http.Response(jsonEncode(responseJson), 200);
          });
          final client = OllamaClient(
            config: const OllamaConfig(
              baseUrl: 'https://example.test/proxy/ollama/?tenant=a&mode=old',
              defaultQueryParams: {'mode': 'new'},
            ),
            httpClient: transport,
          );
          addTearDown(client.close);
          addTearDown(transport.close);
          await get(client);
        },
      );

      for (final status in [400, 403, 503]) {
        test('maps $status errors through the shared transport', () async {
          final transport = MockClient(
            (_) async => http.Response(
              jsonEncode({'error': 'report unavailable'}),
              status,
            ),
          );
          final client = OllamaClient(
            config: const OllamaConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
            httpClient: transport,
          );
          addTearDown(client.close);
          addTearDown(transport.close);
          await expectLater(
            get(client),
            throwsA(
              isA<ApiException>()
                  .having((e) => e.statusCode, 'status', status)
                  .having((e) => e.message, 'message', 'report unavailable'),
            ),
          );
        });
      }

      test('maps authentication failures and rate limits', () async {
        for (final status in [401, 429]) {
          final transport = MockClient(
            (_) async => http.Response(
              jsonEncode({'error': 'denied'}),
              status,
              headers: {'retry-after': '10'},
            ),
          );
          final client = OllamaClient(
            config: const OllamaConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
            httpClient: transport,
          );
          addTearDown(client.close);
          addTearDown(transport.close);
          await expectLater(
            get(client),
            throwsA(
              status == 401
                  ? isA<AuthenticationException>()
                  : isA<RateLimitException>().having(
                      (e) => e.retryAfter,
                      'retryAfter',
                      isNotNull,
                    ),
            ),
          );
        }
      });

      test(
        'rejects malformed response roots and missing required fields',
        () async {
          for (final body in ['[]', '{}']) {
            final transport = MockClient((_) async => http.Response(body, 200));
            final client = OllamaClient(httpClient: transport);
            addTearDown(client.close);
            addTearDown(transport.close);
            await expectLater(get(client), throwsFormatException);
          }
        },
      );

      test('rejects requests after client closure without sending', () async {
        var sent = false;
        final transport = MockClient((_) async {
          sent = true;
          return http.Response(jsonEncode(responseJson), 200);
        });
        final client = OllamaClient(httpClient: transport)..close();
        addTearDown(transport.close);
        await expectLater(get(client), throwsStateError);
        expect(sent, isFalse);
      });

      test('forwards abortTrigger and maps cancellation', () async {
        final abort = Completer<void>();
        final transport = _AbortingClient(abort.future);
        final client = OllamaClient(httpClient: transport);
        addTearDown(client.close);
        addTearDown(transport.close);
        final result = get(client, abortTrigger: abort.future);
        await transport.started.future;
        final expectation = expectLater(
          result,
          throwsA(isA<AbortedException>()),
        );
        abort.complete();
        await expectation;
      });
    });
  }

  test(
    'usage selectors override defaults and use only documented wire names',
    () async {
      final transport = MockClient((request) async {
        expect(request.url.queryParameters, {
          'tenant': 'a',
          'range': '24h',
          'scope': 'team',
          'group_by': 'model',
        });
        expect(request.method, 'GET');
        expect(request.url.path, '/api/usage');
        return http.Response(
          jsonEncode({
            ...usageJson,
            'range': '24h',
            'scope': 'team',
            'granularity': 'hour',
            'group_by': 'model',
          }),
          200,
        );
      });
      final client = OllamaClient(
        config: const OllamaConfig(
          baseUrl: 'https://ollama.com?tenant=a&range=7d',
          defaultQueryParams: {'range': '30d', 'scope': 'self'},
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      addTearDown(transport.close);
      final usage = await client.usage.get(
        range: UsageRange.hours24,
        scope: UsageScope.team,
        groupBy: UsageGroupBy.model,
      );
      expect(usage.range, UsageRange.hours24);
      expect(usage.scope, UsageScope.team);
      expect(usage.granularity, UsageGranularity.hour);
      expect(usage.groupBy, UsageGroupBy.model);
    },
  );

  test(
    'unknown response selector fallbacks cannot be sent as query values',
    () async {
      var sent = false;
      final transport = MockClient((_) async {
        sent = true;
        return http.Response(jsonEncode(usageJson), 200);
      });
      final client = OllamaClient(httpClient: transport);
      addTearDown(client.close);
      addTearDown(transport.close);
      await expectLater(
        client.usage.get(range: UsageRange.unknown),
        throwsArgumentError,
      );
      await expectLater(
        client.usage.get(scope: UsageScope.unknown),
        throwsArgumentError,
      );
      await expectLater(
        client.usage.get(groupBy: UsageGroupBy.unknown),
        throwsArgumentError,
      );
      expect(sent, isFalse);
    },
  );
}

class _AbortingClient extends http.BaseClient {
  _AbortingClient(this.expectedTrigger);
  final Future<void> expectedTrigger;
  final Completer<void> started = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    expect(request, isA<http.Abortable>());
    final abortable = request as http.Abortable;
    expect(abortable.abortTrigger, same(expectedTrigger));
    started.complete();
    await abortable.abortTrigger;
    throw http.RequestAbortedException(request.url);
  }
}
