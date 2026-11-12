/// Known error codes returned in a web fetch result block.
enum WebFetchToolResultErrorCode {
  /// The tool input failed validation.
  invalidToolInput('invalid_tool_input'),

  /// The URL exceeds the supported length.
  urlTooLong('url_too_long'),

  /// The URL is excluded by policy.
  urlNotAllowed('url_not_allowed'),

  /// The URL was absent from eligible earlier conversation content.
  urlNotInPriorContext('url_not_in_prior_context'),

  /// The URL could not be fetched.
  urlNotAccessible('url_not_accessible'),

  /// The response content type is unsupported.
  unsupportedContentType('unsupported_content_type'),

  /// The service rate limited the fetch.
  tooManyRequests('too_many_requests'),

  /// The request reached the tool's use limit.
  maxUsesExceeded('max_uses_exceeded'),

  /// The tool is temporarily unavailable.
  unavailable('unavailable'),

  /// The fetched PDF would exceed the request's page or size limit.
  contentTooLarge('content_too_large'),

  /// The server returned an unrecognized code. The block retains its raw value.
  unknown('unknown');

  const WebFetchToolResultErrorCode(this.value);

  /// The canonical wire spelling of this known code.
  final String value;

  /// Parses a known value with a fallback for future codes.
  factory WebFetchToolResultErrorCode.fromJson(String value) =>
      values.firstWhere((code) => code.value == value, orElse: () => unknown);

  /// Converts a known error code to its wire spelling.
  String toJson() => value;
}

/// Reads the error tag without changing the preserved result payload.
String? webFetchRawErrorCode(Map<String, dynamic> content) => switch (content) {
  {'type': 'web_fetch_tool_result_error', 'error_code': final String code} =>
    code,
  _ => null,
};
