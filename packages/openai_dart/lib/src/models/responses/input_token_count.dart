import 'package:meta/meta.dart';

/// Response from the input tokens count endpoint.
///
/// This allows you to calculate token usage before actually sending a request.
@immutable
class InputTokenCountResponse {
  /// The number of input tokens.
  final int inputTokens;

  /// The object type, always 'response.input_tokens'.
  final String object;

  /// Creates an [InputTokenCountResponse].
  const InputTokenCountResponse({
    required this.inputTokens,
    this.object = 'response.input_tokens',
  });

  /// Creates an [InputTokenCountResponse] from JSON.
  factory InputTokenCountResponse.fromJson(Map<String, dynamic> json) {
    return InputTokenCountResponse(
      inputTokens: json['input_tokens'] as int,
      object: json['object'] as String? ?? 'response.input_tokens',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_tokens': inputTokens,
    'object': object,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputTokenCountResponse &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          object == other.object;

  @override
  int get hashCode => Object.hash(inputTokens, object);

  @override
  String toString() =>
      'InputTokenCountResponse(inputTokens: $inputTokens, object: $object)';
}
