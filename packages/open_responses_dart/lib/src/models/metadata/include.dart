/// Additional data to include in the response.
enum Include {
  /// Unknown include option (fallback for unrecognized values).
  unknown('unknown'),

  /// Include encrypted reasoning content.
  reasoningEncryptedContent('reasoning.encrypted_content'),

  /// Include log probabilities for output text.
  messageOutputTextLogprobs('message.output_text.logprobs');

  /// The JSON value for this include option.
  final String value;

  const Include(this.value);

  /// Creates an [Include] from a JSON value.
  factory Include.fromJson(String json) {
    return Include.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Include.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
