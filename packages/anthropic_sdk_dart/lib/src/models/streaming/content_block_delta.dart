import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../content/content_block.dart';

/// Delta content for streaming content block updates.
sealed class ContentBlockDelta {
  const ContentBlockDelta();

  /// Creates a text delta.
  factory ContentBlockDelta.text(String text) = TextDelta;

  /// Creates an input JSON delta.
  factory ContentBlockDelta.inputJson(String partialJson) = InputJsonDelta;

  /// Creates a thinking delta.
  factory ContentBlockDelta.thinking(String thinking) = ThinkingDelta;

  /// Creates a signature delta.
  factory ContentBlockDelta.signature(String signature) = SignatureDelta;

  /// Creates a citations delta.
  factory ContentBlockDelta.citations(Citation citation) = CitationsDelta;

  /// Creates a compaction delta.
  factory ContentBlockDelta.compaction(String? content) = CompactionDelta;

  /// Creates a [ContentBlockDelta] from JSON.
  factory ContentBlockDelta.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text_delta' => TextDelta.fromJson(json),
      'input_json_delta' => InputJsonDelta.fromJson(json),
      'thinking_delta' => ThinkingDelta.fromJson(json),
      'signature_delta' => SignatureDelta.fromJson(json),
      'citations_delta' => CitationsDelta.fromJson(json),
      'compaction_delta' => CompactionDelta.fromJson(json),
      _ => throw FormatException('Unknown ContentBlockDelta type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Delta for text content updates.
@immutable
class TextDelta extends ContentBlockDelta {
  /// The text content.
  final String text;

  /// Creates a [TextDelta].
  const TextDelta(this.text);

  /// Creates a [TextDelta] from JSON.
  factory TextDelta.fromJson(Map<String, dynamic> json) {
    return TextDelta(json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'text_delta', 'text': text};

  /// Creates a copy with replaced values.
  TextDelta copyWith({String? text}) {
    return TextDelta(text ?? this.text);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextDelta &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextDelta(text: [${text.length} chars])';
}

/// Delta for input JSON content updates (tool use).
@immutable
class InputJsonDelta extends ContentBlockDelta {
  /// The partial JSON string.
  final String partialJson;

  /// Creates an [InputJsonDelta].
  const InputJsonDelta(this.partialJson);

  /// Creates an [InputJsonDelta] from JSON.
  factory InputJsonDelta.fromJson(Map<String, dynamic> json) {
    return InputJsonDelta(json['partial_json'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_json_delta',
    'partial_json': partialJson,
  };

  /// Creates a copy with replaced values.
  InputJsonDelta copyWith({String? partialJson}) {
    return InputJsonDelta(partialJson ?? this.partialJson);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputJsonDelta &&
          runtimeType == other.runtimeType &&
          partialJson == other.partialJson;

  @override
  int get hashCode => partialJson.hashCode;

  @override
  String toString() =>
      'InputJsonDelta(partialJson: [${partialJson.length} chars])';
}

/// Delta for thinking content updates.
@immutable
class ThinkingDelta extends ContentBlockDelta {
  /// The thinking content.
  final String thinking;

  /// Creates a [ThinkingDelta].
  const ThinkingDelta(this.thinking);

  /// Creates a [ThinkingDelta] from JSON.
  factory ThinkingDelta.fromJson(Map<String, dynamic> json) {
    return ThinkingDelta(json['thinking'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'thinking_delta',
    'thinking': thinking,
  };

  /// Creates a copy with replaced values.
  ThinkingDelta copyWith({String? thinking}) {
    return ThinkingDelta(thinking ?? this.thinking);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingDelta &&
          runtimeType == other.runtimeType &&
          thinking == other.thinking;

  @override
  int get hashCode => thinking.hashCode;

  @override
  String toString() => 'ThinkingDelta(thinking: [${thinking.length} chars])';
}

/// Delta for compaction content updates (beta).
@immutable
class CompactionDelta extends ContentBlockDelta {
  /// The partial or final compaction summary content.
  final String? content;

  /// Creates a [CompactionDelta].
  const CompactionDelta(this.content);

  /// Creates a [CompactionDelta] from JSON.
  factory CompactionDelta.fromJson(Map<String, dynamic> json) {
    return CompactionDelta(json['content'] as String?);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction_delta',
    'content': content,
  };

  /// Creates a copy with replaced values.
  CompactionDelta copyWith({Object? content = unsetCopyWithValue}) {
    return CompactionDelta(
      content == unsetCopyWithValue ? this.content : content as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionDelta &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'CompactionDelta(content: $content)';
}

/// Delta for signature content updates (extended thinking verification).
@immutable
class SignatureDelta extends ContentBlockDelta {
  /// The signature content.
  final String signature;

  /// Creates a [SignatureDelta].
  const SignatureDelta(this.signature);

  /// Creates a [SignatureDelta] from JSON.
  factory SignatureDelta.fromJson(Map<String, dynamic> json) {
    return SignatureDelta(json['signature'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'signature_delta',
    'signature': signature,
  };

  /// Creates a copy with replaced values.
  SignatureDelta copyWith({String? signature}) {
    return SignatureDelta(signature ?? this.signature);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignatureDelta &&
          runtimeType == other.runtimeType &&
          signature == other.signature;

  @override
  int get hashCode => signature.hashCode;

  @override
  String toString() => 'SignatureDelta(signature: [${signature.length} chars])';
}

/// Delta for citation content updates.
@immutable
class CitationsDelta extends ContentBlockDelta {
  /// The citation being added.
  final Citation citation;

  /// Creates a [CitationsDelta].
  const CitationsDelta(this.citation);

  /// Creates a [CitationsDelta] from JSON.
  factory CitationsDelta.fromJson(Map<String, dynamic> json) {
    return CitationsDelta(
      Citation.fromJson(json['citation'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'citations_delta',
    'citation': citation.toJson(),
  };

  /// Creates a copy with replaced values.
  CitationsDelta copyWith({Citation? citation}) {
    return CitationsDelta(citation ?? this.citation);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CitationsDelta &&
          runtimeType == other.runtimeType &&
          citation == other.citation;

  @override
  int get hashCode => citation.hashCode;

  @override
  String toString() => 'CitationsDelta(citation: $citation)';
}
