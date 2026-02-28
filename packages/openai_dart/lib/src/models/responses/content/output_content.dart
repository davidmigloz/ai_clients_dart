import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'annotation.dart';
import 'logprob.dart';

/// Output content from model.
sealed class OutputContent {
  /// Creates an [OutputContent].
  const OutputContent();

  /// Creates an [OutputTextContent].
  const factory OutputContent.text({
    required String text,
    List<Annotation>? annotations,
    List<LogProb>? logprobs,
  }) = OutputTextContent;

  /// Creates a [ReasoningTextContent] with the given [text].
  const factory OutputContent.reasoning(String text) = ReasoningTextContent;

  /// Creates a [SummaryTextContent] with the given [text].
  const factory OutputContent.summary(String text) = SummaryTextContent;

  /// Creates a [RefusalContent] with the given [refusal] message.
  const factory OutputContent.refusal(String refusal) = RefusalContent;

  /// Creates an [InputTextOutputContent] with the given [text].
  ///
  /// This type appears in compact output when user messages are preserved.
  const factory OutputContent.inputText(String text) = InputTextOutputContent;

  /// Creates an [OutputContent] from JSON.
  factory OutputContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'output_text' => OutputTextContent.fromJson(json),
      'reasoning_text' => ReasoningTextContent.fromJson(json),
      'summary_text' => SummaryTextContent.fromJson(json),
      'refusal' => RefusalContent.fromJson(json),
      'input_text' => InputTextOutputContent.fromJson(json),
      _ => throw FormatException('Unknown OutputContent type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text output content.
@immutable
class OutputTextContent extends OutputContent {
  /// The text content.
  final String text;

  /// Optional annotations (citations, etc.).
  final List<Annotation>? annotations;

  /// Optional log probabilities.
  final List<LogProb>? logprobs;

  /// Creates an [OutputTextContent].
  const OutputTextContent({
    required this.text,
    this.annotations,
    this.logprobs,
  });

  /// Creates an [OutputTextContent] from JSON.
  factory OutputTextContent.fromJson(Map<String, dynamic> json) {
    return OutputTextContent(
      text: json['text'] as String,
      annotations: (json['annotations'] as List?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
      logprobs: (json['logprobs'] as List?)
          ?.map((e) => LogProb.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'output_text',
    'text': text,
    if (annotations != null)
      'annotations': annotations!.map((e) => e.toJson()).toList(),
    if (logprobs != null) 'logprobs': logprobs!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  OutputTextContent copyWith({
    String? text,
    Object? annotations = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
  }) {
    return OutputTextContent(
      text: text ?? this.text,
      annotations: annotations == unsetCopyWithValue
          ? this.annotations
          : annotations as List<Annotation>?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<LogProb>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          listsEqual(annotations, other.annotations) &&
          listsEqual(logprobs, other.logprobs);

  @override
  int get hashCode => Object.hash(text, annotations, logprobs);

  @override
  String toString() =>
      'OutputTextContent(text: $text, annotations: $annotations, logprobs: $logprobs)';
}

/// Reasoning text content from reasoning models.
@immutable
class ReasoningTextContent extends OutputContent {
  /// The reasoning text content.
  final String text;

  /// Creates a [ReasoningTextContent].
  const ReasoningTextContent(this.text);

  /// Creates a [ReasoningTextContent] from JSON.
  factory ReasoningTextContent.fromJson(Map<String, dynamic> json) {
    return ReasoningTextContent(json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'reasoning_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ReasoningTextContent(text: $text)';
}

/// Summary text content from reasoning models.
@immutable
class SummaryTextContent extends OutputContent {
  /// The summary text from the reasoning output.
  final String text;

  /// Creates a [SummaryTextContent].
  const SummaryTextContent(this.text);

  /// Creates a [SummaryTextContent] from JSON.
  factory SummaryTextContent.fromJson(Map<String, dynamic> json) {
    return SummaryTextContent(json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'summary_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'SummaryTextContent(text: $text)';
}

/// Refusal content when model declines to respond.
@immutable
class RefusalContent extends OutputContent {
  /// The refusal message.
  final String refusal;

  /// Creates a [RefusalContent].
  const RefusalContent(this.refusal);

  /// Creates a [RefusalContent] from JSON.
  factory RefusalContent.fromJson(Map<String, dynamic> json) {
    return RefusalContent(json['refusal'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'refusal', 'refusal': refusal};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalContent &&
          runtimeType == other.runtimeType &&
          refusal == other.refusal;

  @override
  int get hashCode => refusal.hashCode;

  @override
  String toString() => 'RefusalContent(refusal: $refusal)';
}

/// Input text content preserved in compact output.
///
/// When a response is compacted via `responses.compact`, user messages
/// may appear in the output with `input_text` type content. This class
/// preserves that type so it round-trips correctly when fed back as input.
@immutable
class InputTextOutputContent extends OutputContent {
  /// The text content.
  final String text;

  /// Creates an [InputTextOutputContent].
  const InputTextOutputContent(this.text);

  /// Creates an [InputTextOutputContent] from JSON.
  factory InputTextOutputContent.fromJson(Map<String, dynamic> json) {
    return InputTextOutputContent(json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'input_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputTextOutputContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'InputTextOutputContent(text: $text)';
}
