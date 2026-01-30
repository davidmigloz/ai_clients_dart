import 'package:meta/meta.dart';

/// Details about model reasoning, returned by some providers.
///
/// **OpenRouter only.** Not part of the official OpenAI API.
///
/// This is returned by OpenRouter when using models that support reasoning
/// (e.g., DeepSeek R1). Different types indicate different content:
///
/// - `reasoning.summary`: A summary of the reasoning process
/// - `reasoning.text`: The full reasoning text
/// - `reasoning.encrypted`: Encrypted reasoning data (base64 encoded)
///
/// ## Example
///
/// ```dart
/// final message = response.firstChoice?.message;
/// if (message?.reasoningDetails != null) {
///   for (final detail in message!.reasoningDetails!) {
///     if (detail.type == 'reasoning.summary') {
///       print('Summary: ${detail.text}');
///     }
///   }
/// }
/// ```
@immutable
class ReasoningDetail {
  /// Creates a [ReasoningDetail].
  const ReasoningDetail({required this.type, this.text, this.data});

  /// Creates a [ReasoningDetail] from JSON.
  factory ReasoningDetail.fromJson(Map<String, dynamic> json) {
    return ReasoningDetail(
      type: json['type'] as String,
      text: json['text'] as String?,
      data: json['data'] as String?,
    );
  }

  /// The type of reasoning detail.
  ///
  /// Common values:
  /// - `reasoning.summary`: A summary of the reasoning process
  /// - `reasoning.text`: The full reasoning text
  /// - `reasoning.encrypted`: Encrypted reasoning data (base64 encoded)
  final String type;

  /// The text content (for summary and text types).
  final String? text;

  /// Encrypted data (for encrypted type, base64 encoded).
  final String? data;

  /// Whether this is a summary detail.
  bool get isSummary => type == 'reasoning.summary';

  /// Whether this is a text detail.
  bool get isText => type == 'reasoning.text';

  /// Whether this is encrypted data.
  bool get isEncrypted => type == 'reasoning.encrypted';

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (text != null) 'text': text,
    if (data != null) 'data': data,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningDetail &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          text == other.text &&
          data == other.data;

  @override
  int get hashCode => Object.hash(type, text, data);

  @override
  String toString() {
    if (isSummary || isText) {
      return 'ReasoningDetail(type: $type, text: ${text?.length ?? 0} chars)';
    }
    return 'ReasoningDetail(type: $type)';
  }
}
