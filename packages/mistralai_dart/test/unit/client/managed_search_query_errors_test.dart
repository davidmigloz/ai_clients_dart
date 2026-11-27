import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _query = ManagedSearchRequest(
  retriever: KeywordRetriever(query: 'release checklist', topK: 200),
);

void main() {
  test(
    'decodes every validation variant in order and preserves HTTP metadata',
    () async {
      const body = [
        {'type': 'embedding_mismatch', 'expected': 1024, 'received': 128},
        {
          'type': 'incorrect_field_type',
          'name': 'category',
          'expected_type': 'keyword',
          'received_type': 'text',
        },
        {'type': 'max_candidates_too_small', 'max_candidates': 10, 'top_k': 20},
        {'type': 'missing_embedding'},
        {'type': 'missing_field', 'name': 'department'},
        {'type': 'top_k_too_large', 'limit': 100, 'top_k': 200},
        {
          'type': 'future_query_error',
          'metadata': {
            'limits': [1, 2],
            'related': null,
          },
        },
      ];
      final raw = jsonEncode(body);
      final transport = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/v1/context/search-indexes/team-notes/search',
        );
        expect(jsonDecode(request.body), {
          'retriever': {
            'type': 'keyword',
            'query': 'release checklist',
            'top_k': 200,
          },
        });
        return http.Response(
          raw,
          400,
          headers: {'content-type': 'application/json', 'x-fixture': 'search'},
        );
      });
      addTearDown(transport.close);
      final client = MistralClient.withApiKey('fixture', httpClient: transport);
      addTearDown(client.close);

      await expectLater(
        client.managedSearchIndexes.search(
          indexName: 'team-notes',
          request: _query,
        ),
        throwsA(
          isA<ManagedSearchQueryException>().having(
            (error) {
              final ApiException compatible = error;
              expect(compatible.statusCode, 400);
              expect(compatible.message, raw);
              expect(compatible.details, isEmpty);
              expect(compatible.requestMetadata?.method, 'POST');
              expect(
                compatible.responseMetadata?.headers['x-fixture'],
                'search',
              );
              expect(
                compatible.responseMetadata!.bodyExcerpt.length,
                lessThan(raw.length),
              );
              final errors = error.errors;
              expect(errors, [
                const SearchEmbeddingMismatch(expected: 1024, received: 128),
                const SearchIncorrectFieldType(
                  name: 'category',
                  expectedType: 'keyword',
                  receivedType: 'text',
                ),
                const SearchMaxCandidatesTooSmall(maxCandidates: 10, topK: 20),
                const SearchMissingEmbedding(),
                const SearchMissingField(name: 'department'),
                const SearchTopKTooLarge(limit: 100, topK: 200),
                isA<UnknownManagedSearchQueryError>(),
              ]);
              expect(errors.map((issue) => issue.toJson()), body);
              expect(errors.clear, throwsUnsupportedError);
              return errors.length;
            },
            'typed issues',
            7,
          ),
        ),
      );
    },
  );

  test(
    'malformed arrays and generic error bodies preserve ApiException',
    () async {
      for (final body in [
        'proxy response',
        '{"message":"bad query"}',
        jsonEncode({
          'message': '[{"type":"missing_field","name":"embedded array"}]',
        }),
        '[{"type":"missing_field"}]',
        '[{"name":"not tagged"}]',
        '["missing_field"]',
        '[{"type":"missing_field","name":42},{"type":"future","value":1}]',
      ]) {
        final transport = MockClient((_) async => http.Response(body, 400));
        final client = MistralClient.withApiKey(
          'fixture',
          httpClient: transport,
        );
        try {
          await expectLater(
            client.managedSearchIndexes.search(
              indexName: 'team-notes',
              request: _query,
            ),
            throwsA(
              isA<ApiException>()
                  .having(
                    (error) => error,
                    'generic',
                    isNot(isA<ManagedSearchQueryException>()),
                  )
                  .having((error) => error.statusCode, 'status', 400),
            ),
          );
        } finally {
          client.close();
          transport.close();
        }
      }
    },
  );

  test('typing applies only to search HTTP 400 responses', () async {
    const body = '[{"type":"missing_field","name":"category"}]';
    final transport = MockClient(
      (request) async =>
          http.Response(body, request.method == 'POST' ? 422 : 400),
    );
    addTearDown(transport.close);
    final client = MistralClient.withApiKey('fixture', httpClient: transport);
    addTearDown(client.close);

    await expectLater(
      client.managedSearchIndexes.search(
        indexName: 'team-notes',
        request: _query,
      ),
      throwsA(
        isA<ApiException>()
            .having(
              (error) => error,
              'generic',
              isNot(isA<ManagedSearchQueryException>()),
            )
            .having((error) => error.statusCode, 'status', 422),
      ),
    );
    await expectLater(
      client.managedSearchIndexes.get(indexName: 'team-notes'),
      throwsA(
        isA<ApiException>()
            .having(
              (error) => error,
              'generic',
              isNot(isA<ManagedSearchQueryException>()),
            )
            .having((error) => error.statusCode, 'status', 400),
      ),
    );
  });
}
