import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorInterceptor Retry-After Parsing', () {
    test('parses Retry-After as seconds', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
          headers: {'retry-after': '120'},
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        expect(e.retryAfter, equals(const Duration(seconds: 120)));
      }

      client.close();
    });

    test('parses Retry-After as IMF-fixdate', () async {
      // Use a future date
      final futureDate = DateTime.now().toUtc().add(const Duration(minutes: 5));
      final imfDate = _formatImfFixdate(futureDate);

      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
          headers: {'retry-after': imfDate},
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        // Should be approximately 5 minutes (with some tolerance for test execution time)
        expect(e.retryAfter, isNotNull);
        expect(e.retryAfter!.inSeconds, greaterThan(200));
        expect(e.retryAfter!.inSeconds, lessThan(350));
      }

      client.close();
    });

    test('handles Retry-After with leading/trailing whitespace', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
          headers: {'retry-after': '  60  '},
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        expect(e.retryAfter, equals(const Duration(seconds: 60)));
      }

      client.close();
    });

    test('returns null retryAfter for invalid Retry-After value', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
          headers: {'retry-after': 'invalid-value'},
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        expect(e.retryAfter, isNull);
      }

      client.close();
    });

    test('returns null retryAfter when header is missing', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        expect(e.retryAfter, isNull);
      }

      client.close();
    });

    test('returns null retryAfter for empty Retry-After header', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
          headers: {'retry-after': ''},
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        expect(e.retryAfter, isNull);
      }

      client.close();
    });

    test('returns null retryAfter for past HTTP date', () async {
      // Use a past date
      final pastDate = DateTime.now().toUtc().subtract(
        const Duration(hours: 1),
      );
      final imfDate = _formatImfFixdate(pastDate);

      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
          headers: {'retry-after': imfDate},
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        // Past dates should return null
        expect(e.retryAfter, isNull);
      }

      client.close();
    });

    test('handles zero seconds Retry-After', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"error":{"message":"Rate limited","type":"rate_limit_error"}}',
          429,
          headers: {'retry-after': '0'},
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RateLimitException');
      } on RateLimitException catch (e) {
        expect(e.retryAfter, equals(Duration.zero));
      }

      client.close();
    });
  });
}

/// Formats a DateTime as an IMF-fixdate string.
///
/// Example: "Sun, 06 Nov 1994 08:49:37 GMT"
String _formatImfFixdate(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final utc = date.toUtc();
  final dayName = days[utc.weekday - 1];
  final day = utc.day.toString().padLeft(2, '0');
  final month = months[utc.month - 1];
  final year = utc.year;
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  final second = utc.second.toString().padLeft(2, '0');

  return '$dayName, $day $month $year $hour:$minute:$second GMT';
}
