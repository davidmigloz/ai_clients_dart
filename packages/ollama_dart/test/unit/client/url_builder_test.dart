import 'package:ollama_dart/ollama_dart.dart';
import 'package:ollama_dart/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBuilder.buildUrl', () {
    test('builds URL with the default base URL', () {
      const builder = RequestBuilder(config: OllamaConfig());

      final url = builder.buildUrl('/api/chat');

      expect(url.scheme, equals('http'));
      expect(url.host, equals('localhost'));
      expect(url.port, equals(11434));
      expect(url.path, equals('/api/chat'));
      expect(url.query, isEmpty);
    });

    test('normalizes a trailing slash in the base URL (no double slash)', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'http://localhost:11434/'),
      );

      final url = builder.buildUrl('/api/chat');

      // Should be /api/chat, not //api/chat.
      expect(url.path, equals('/api/chat'));
      expect(url.toString(), equals('http://localhost:11434/api/chat'));
    });

    test('preserves a base URL sub-path with a trailing slash', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://proxy.example.com/ollama/'),
      );

      final url = builder.buildUrl('/api/chat');

      expect(url.path, equals('/ollama/api/chat'));
    });

    test('handles an endpoint path without a leading slash', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'http://localhost:11434/'),
      );

      final url = builder.buildUrl('api/chat');

      expect(url.path, equals('/api/chat'));
    });

    test('handles a base URL with no path', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://ollama.example.com'),
      );

      final url = builder.buildUrl('/api/chat');

      expect(url.path, equals('/api/chat'));
    });

    test('handles a base URL with multiple path segments', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://proxy.example.com/api/v1/x'),
      );

      final url = builder.buildUrl('/api/chat');

      expect(url.path, equals('/api/v1/x/api/chat'));
    });

    test('preserves query params carried by the base URL', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://proxy.example.com/?token=abc'),
      );

      final url = builder.buildUrl('/api/chat');

      expect(url.path, equals('/api/chat'));
      expect(url.queryParameters['token'], equals('abc'));
    });

    test('merges default and per-request query params', () {
      const builder = RequestBuilder(
        config: OllamaConfig(
          baseUrl: 'http://localhost:11434/',
          defaultQueryParams: {'beta': 'true'},
        ),
      );

      final url = builder.buildUrl('/api/tags', queryParams: {'limit': '20'});

      expect(url.path, equals('/api/tags'));
      expect(url.queryParameters['beta'], equals('true'));
      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override defaults on conflict', () {
      const builder = RequestBuilder(
        config: OllamaConfig(defaultQueryParams: {'limit': '10'}),
      );

      final url = builder.buildUrl('/api/tags', queryParams: {'limit': '20'});

      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://proxy.example.com/?token=old'),
      );

      final url = builder.buildUrl('/api/tags', queryParams: {'token': 'new'});

      expect(url.queryParameters['token'], equals('new'));
    });

    test('default params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: OllamaConfig(
          baseUrl: 'https://proxy.example.com/?token=old',
          defaultQueryParams: {'token': 'new'},
        ),
      );

      final url = builder.buildUrl('/api/tags');

      expect(url.queryParameters['token'], equals('new'));
    });

    test('preserves repeated query keys carried by the base URL', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://proxy.example.com/?k=a&k=b'),
      );

      final url = builder.buildUrl('/api/tags');

      expect(url.queryParametersAll['k'], equals(['a', 'b']));
      expect(url.toString(), contains('k=a&k=b'));
    });

    test('per-request params replace the whole repeated-key list', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://proxy.example.com/?k=a&k=b'),
      );

      final url = builder.buildUrl('/api/tags', queryParams: {'k': 'c'});

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('default params replace repeated base-URL keys', () {
      const builder = RequestBuilder(
        config: OllamaConfig(
          baseUrl: 'https://proxy.example.com/?k=a&k=b',
          defaultQueryParams: {'k': 'c'},
        ),
      );

      final url = builder.buildUrl('/api/tags');

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('renders Iterable query param values as repeated keys', () {
      const builder = RequestBuilder(config: OllamaConfig());

      final url = builder.buildUrl(
        '/api/tags',
        queryParams: {
          'status': ['queued', 'running'],
        },
      );

      expect(url.queryParametersAll['status'], equals(['queued', 'running']));
      expect(url.toString(), contains('status=queued&status=running'));
    });

    test('preserves a non-standard port in the base URL', () {
      const builder = RequestBuilder(
        config: OllamaConfig(baseUrl: 'https://ollama.example.com:8443'),
      );

      final url = builder.buildUrl('/api/tags');

      expect(url.port, equals(8443));
      expect(url.path, equals('/api/tags'));
    });

    test('preserves userInfo and fragment from the base URL', () {
      const builder = RequestBuilder(
        config: OllamaConfig(
          baseUrl: 'https://user:pass@ollama.example.com/base#frag',
        ),
      );

      final url = builder.buildUrl('/api/tags');

      expect(url.userInfo, equals('user:pass'));
      expect(url.path, equals('/base/api/tags'));
      expect(url.fragment, equals('frag'));
    });
  });
}
