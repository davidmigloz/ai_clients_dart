import 'package:meta/meta.dart';

/// Metadata from an API response.
///
/// Contains information extracted from response headers that can be
/// useful for debugging, monitoring, and rate limiting.
///
/// ## Example
///
/// ```dart
/// final response = await client.chat.create(...);
/// print('Request ID: ${response.metadata?.requestId}');
/// print('Processing time: ${response.metadata?.processingMs}ms');
/// ```
@immutable
class ResponseMetadata {
  /// Creates a [ResponseMetadata].
  const ResponseMetadata({
    this.requestId,
    this.model,
    this.processingMs,
    this.organization,
    this.rateLimitRequests,
    this.rateLimitTokens,
    this.remainingRequests,
    this.remainingTokens,
    this.resetRequests,
    this.resetTokens,
  });

  /// Creates a [ResponseMetadata] from response headers.
  factory ResponseMetadata.fromHeaders(Map<String, String> headers) {
    return ResponseMetadata(
      requestId: headers['x-request-id'],
      model: headers['openai-model'],
      processingMs: _parseInt(headers['openai-processing-ms']),
      organization: headers['openai-organization'],
      rateLimitRequests: _parseInt(headers['x-ratelimit-limit-requests']),
      rateLimitTokens: _parseInt(headers['x-ratelimit-limit-tokens']),
      remainingRequests: _parseInt(headers['x-ratelimit-remaining-requests']),
      remainingTokens: _parseInt(headers['x-ratelimit-remaining-tokens']),
      resetRequests: headers['x-ratelimit-reset-requests'],
      resetTokens: headers['x-ratelimit-reset-tokens'],
    );
  }

  /// The unique request identifier.
  ///
  /// Useful for debugging and contacting support.
  final String? requestId;

  /// The model that processed the request.
  final String? model;

  /// The processing time in milliseconds.
  final int? processingMs;

  /// The organization ID that owns the API key.
  final String? organization;

  /// The rate limit for requests per time period.
  final int? rateLimitRequests;

  /// The rate limit for tokens per time period.
  final int? rateLimitTokens;

  /// The number of requests remaining in the current period.
  final int? remainingRequests;

  /// The number of tokens remaining in the current period.
  final int? remainingTokens;

  /// When the request rate limit resets (e.g., "1s", "1m").
  final String? resetRequests;

  /// When the token rate limit resets (e.g., "1s", "1m").
  final String? resetTokens;

  /// Whether the request is approaching the rate limit.
  bool get isNearRateLimit {
    if (remainingRequests != null && rateLimitRequests != null) {
      return remainingRequests! < rateLimitRequests! * 0.1;
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseMetadata &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId;

  @override
  int get hashCode => requestId.hashCode;

  @override
  String toString() =>
      'ResponseMetadata(requestId: $requestId, processingMs: $processingMs)';

  static int? _parseInt(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }
}
