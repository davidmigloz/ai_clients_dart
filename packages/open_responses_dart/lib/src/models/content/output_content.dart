import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'annotation.dart';
import 'logprob.dart';

/// Output content from model.
sealed class OutputContent {
  /// Creates an [OutputContent].
  const OutputContent();

  /// Creates an [OutputContent] from JSON.
  factory OutputContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'output_text' => OutputTextContent.fromJson(json),
      'reasoning_text' => ReasoningTextContent.fromJson(json),
      'summary_text' => SummaryTextContent.fromJson(json),
      'refusal' => RefusalContent.fromJson(json),
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
  const ReasoningTextContent({required this.text});

  /// Creates a [ReasoningTextContent] from JSON.
  factory ReasoningTextContent.fromJson(Map<String, dynamic> json) {
    return ReasoningTextContent(text: json['text'] as String);
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

/// Refusal content when model declines to respond.
@immutable
class RefusalContent extends OutputContent {
  /// The refusal message.
  final String refusal;

  /// Creates a [RefusalContent].
  const RefusalContent({required this.refusal});

  /// Creates a [RefusalContent] from JSON.
  factory RefusalContent.fromJson(Map<String, dynamic> json) {
    return RefusalContent(refusal: json['refusal'] as String);
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

/// Summary text content from reasoning models.
@immutable
class SummaryTextContent extends OutputContent {
  /// The summary text from the reasoning output.
  final String text;

  /// Creates a [SummaryTextContent].
  const SummaryTextContent({required this.text});

  /// Creates a [SummaryTextContent] from JSON.
  factory SummaryTextContent.fromJson(Map<String, dynamic> json) {
    return SummaryTextContent(text: json['text'] as String);
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
