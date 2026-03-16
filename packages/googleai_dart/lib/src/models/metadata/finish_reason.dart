/// Why generation stopped.
enum FinishReason {
  /// Unknown reason.
  unspecified,

  /// Natural stop (e.g., stop sequence, EOS token).
  stop,

  /// Hit max output tokens.
  maxTokens,

  /// Blocked by safety filters.
  safety,

  /// Blocked due to recitation/citation issues.
  recitation,

  /// Other reason.
  other,

  /// Blocked by custom blocklist.
  blocklist,

  /// Prohibited content detected.
  prohibitedContent,

  /// Sensitive PII detected.
  spii,

  /// Malformed function call.
  malformedFunctionCall,

  /// Blocked due to language.
  language,

  /// Blocked due to image safety.
  imageSafety,

  /// Blocked due to prohibited image content.
  imageProhibitedContent,

  /// Blocked due to other image issue.
  imageOther,

  /// No image generated.
  noImage,

  /// Blocked due to image recitation.
  imageRecitation,

  /// Unexpected tool call.
  unexpectedToolCall,

  /// Too many tool calls.
  tooManyToolCalls,

  /// Missing thought signature.
  missingThoughtSignature,

  /// Malformed response.
  malformedResponse,
}

/// Converts string to FinishReason enum.
FinishReason finishReasonFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'STOP' => FinishReason.stop,
    'MAX_TOKENS' => FinishReason.maxTokens,
    'SAFETY' => FinishReason.safety,
    'RECITATION' => FinishReason.recitation,
    'OTHER' => FinishReason.other,
    'BLOCKLIST' => FinishReason.blocklist,
    'PROHIBITED_CONTENT' => FinishReason.prohibitedContent,
    'SPII' => FinishReason.spii,
    'MALFORMED_FUNCTION_CALL' => FinishReason.malformedFunctionCall,
    'LANGUAGE' => FinishReason.language,
    'IMAGE_SAFETY' => FinishReason.imageSafety,
    'IMAGE_PROHIBITED_CONTENT' => FinishReason.imageProhibitedContent,
    'IMAGE_OTHER' => FinishReason.imageOther,
    'NO_IMAGE' => FinishReason.noImage,
    'IMAGE_RECITATION' => FinishReason.imageRecitation,
    'UNEXPECTED_TOOL_CALL' => FinishReason.unexpectedToolCall,
    'TOO_MANY_TOOL_CALLS' => FinishReason.tooManyToolCalls,
    'MISSING_THOUGHT_SIGNATURE' => FinishReason.missingThoughtSignature,
    'MALFORMED_RESPONSE' => FinishReason.malformedResponse,
    _ => FinishReason.unspecified,
  };
}

/// Converts FinishReason enum to string.
String finishReasonToString(FinishReason reason) {
  return switch (reason) {
    FinishReason.stop => 'STOP',
    FinishReason.maxTokens => 'MAX_TOKENS',
    FinishReason.safety => 'SAFETY',
    FinishReason.recitation => 'RECITATION',
    FinishReason.other => 'OTHER',
    FinishReason.blocklist => 'BLOCKLIST',
    FinishReason.prohibitedContent => 'PROHIBITED_CONTENT',
    FinishReason.spii => 'SPII',
    FinishReason.malformedFunctionCall => 'MALFORMED_FUNCTION_CALL',
    FinishReason.language => 'LANGUAGE',
    FinishReason.imageSafety => 'IMAGE_SAFETY',
    FinishReason.imageProhibitedContent => 'IMAGE_PROHIBITED_CONTENT',
    FinishReason.imageOther => 'IMAGE_OTHER',
    FinishReason.noImage => 'NO_IMAGE',
    FinishReason.imageRecitation => 'IMAGE_RECITATION',
    FinishReason.unexpectedToolCall => 'UNEXPECTED_TOOL_CALL',
    FinishReason.tooManyToolCalls => 'TOO_MANY_TOOL_CALLS',
    FinishReason.missingThoughtSignature => 'MISSING_THOUGHT_SIGNATURE',
    FinishReason.malformedResponse => 'MALFORMED_RESPONSE',
    FinishReason.unspecified => 'FINISH_REASON_UNSPECIFIED',
  };
}
