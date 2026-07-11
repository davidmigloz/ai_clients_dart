import 'package:meta/meta.dart';

import '../../chat/content_part.dart' show ImageDetail;
import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/prompt_cache_breakpoint.dart';
import 'annotation.dart';
import 'input_content.dart' show FileInputDetail;
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
      'text' => TextOutputContent.fromJson(json),
      'input_image' => InputImageOutputContent.fromJson(json),
      'computer_screenshot' => ComputerScreenshotOutputContent.fromJson(json),
      'input_file' => InputFileOutputContent.fromJson(json),
      'encrypted_content' => EncryptedOutputContent.fromJson(json),
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
  int get hashCode => Object.hash(
    text,
    annotations != null ? Object.hashAll(annotations!) : null,
    logprobs != null ? Object.hashAll(logprobs!) : null,
  );

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

/// Plain text content.
///
/// Appears in the beta multi-agent protocol's agent message content union
/// (`OpenAI-Beta: responses_multi_agent=v1`).
@immutable
class TextOutputContent extends OutputContent {
  /// The text content.
  final String text;

  /// Creates a [TextOutputContent].
  const TextOutputContent(this.text);

  /// Creates a [TextOutputContent] from JSON.
  factory TextOutputContent.fromJson(Map<String, dynamic> json) {
    return TextOutputContent(json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextOutputContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextOutputContent(text: $text)';
}

/// Image content echoed as output.
///
/// Mirrors [InputImageContent] but appears in output contexts such as the
/// beta multi-agent protocol's agent message content union
/// (`OpenAI-Beta: responses_multi_agent=v1`).
@immutable
class InputImageOutputContent extends OutputContent {
  /// The image URL.
  final String? imageUrl;

  /// The file ID (for uploaded files).
  final String? fileId;

  /// Optional detail level.
  final ImageDetail? detail;

  /// Cache breakpoint marker for this content block.
  final PromptCacheBreakpointConfig? promptCacheBreakpoint;

  /// Creates an [InputImageOutputContent].
  const InputImageOutputContent({
    this.imageUrl,
    this.fileId,
    this.detail,
    this.promptCacheBreakpoint,
  });

  /// Creates an [InputImageOutputContent] from JSON.
  factory InputImageOutputContent.fromJson(Map<String, dynamic> json) {
    return InputImageOutputContent(
      imageUrl: json['image_url'] as String?,
      fileId: json['file_id'] as String?,
      detail: json['detail'] != null
          ? ImageDetail.fromJson(json['detail'] as String)
          : null,
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] != null
          ? PromptCacheBreakpointConfig.fromJson(
              json['prompt_cache_breakpoint'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_image',
    if (imageUrl != null) 'image_url': imageUrl,
    if (fileId != null) 'file_id': fileId,
    if (detail != null) 'detail': detail!.toJson(),
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputImageOutputContent &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          fileId == other.fileId &&
          detail == other.detail &&
          promptCacheBreakpoint == other.promptCacheBreakpoint;

  @override
  int get hashCode =>
      Object.hash(imageUrl, fileId, detail, promptCacheBreakpoint);

  @override
  String toString() =>
      'InputImageOutputContent(imageUrl: $imageUrl, fileId: $fileId, detail: $detail, promptCacheBreakpoint: $promptCacheBreakpoint)';
}

/// A screenshot of a computer, echoed as output.
///
/// Mirrors [ComputerScreenshotContent] but appears in output contexts such as
/// the beta multi-agent protocol's agent message content union
/// (`OpenAI-Beta: responses_multi_agent=v1`).
@immutable
class ComputerScreenshotOutputContent extends OutputContent {
  /// The URL of the screenshot image.
  final String? imageUrl;

  /// The identifier of an uploaded file that contains the screenshot.
  final String? fileId;

  /// The detail level of the screenshot image to be sent to the model.
  final ImageDetail? detail;

  /// Cache breakpoint marker for this content block.
  final PromptCacheBreakpointConfig? promptCacheBreakpoint;

  /// Creates a [ComputerScreenshotOutputContent].
  const ComputerScreenshotOutputContent({
    this.imageUrl,
    this.fileId,
    this.detail,
    this.promptCacheBreakpoint,
  });

  /// Creates a [ComputerScreenshotOutputContent] from JSON.
  factory ComputerScreenshotOutputContent.fromJson(Map<String, dynamic> json) {
    return ComputerScreenshotOutputContent(
      imageUrl: json['image_url'] as String?,
      fileId: json['file_id'] as String?,
      detail: json['detail'] != null
          ? ImageDetail.fromJson(json['detail'] as String)
          : null,
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] != null
          ? PromptCacheBreakpointConfig.fromJson(
              json['prompt_cache_breakpoint'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'computer_screenshot',
    if (imageUrl != null) 'image_url': imageUrl,
    if (fileId != null) 'file_id': fileId,
    if (detail != null) 'detail': detail!.toJson(),
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerScreenshotOutputContent &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          fileId == other.fileId &&
          detail == other.detail &&
          promptCacheBreakpoint == other.promptCacheBreakpoint;

  @override
  int get hashCode =>
      Object.hash(imageUrl, fileId, detail, promptCacheBreakpoint);

  @override
  String toString() =>
      'ComputerScreenshotOutputContent(imageUrl: $imageUrl, fileId: $fileId, detail: $detail, promptCacheBreakpoint: $promptCacheBreakpoint)';
}

/// File content echoed as output.
///
/// Mirrors [InputFileContent] but appears in output contexts such as the
/// beta multi-agent protocol's agent message content union
/// (`OpenAI-Beta: responses_multi_agent=v1`).
@immutable
class InputFileOutputContent extends OutputContent {
  /// The file URL.
  final String? fileUrl;

  /// The file ID.
  final String? fileId;

  /// The file data as a data URL (e.g., `data:application/pdf;base64,<data>`).
  final String? fileData;

  /// The filename.
  final String? filename;

  /// Optional detail level for file processing.
  final FileInputDetail? detail;

  /// Cache breakpoint marker for this content block.
  final PromptCacheBreakpointConfig? promptCacheBreakpoint;

  /// Creates an [InputFileOutputContent].
  const InputFileOutputContent({
    this.fileUrl,
    this.fileId,
    this.fileData,
    this.filename,
    this.detail,
    this.promptCacheBreakpoint,
  });

  /// Creates an [InputFileOutputContent] from JSON.
  factory InputFileOutputContent.fromJson(Map<String, dynamic> json) {
    return InputFileOutputContent(
      fileUrl: json['file_url'] as String?,
      fileId: json['file_id'] as String?,
      fileData: json['file_data'] as String?,
      filename: json['filename'] as String?,
      detail: json['detail'] != null
          ? FileInputDetail.fromJson(json['detail'] as String)
          : null,
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] != null
          ? PromptCacheBreakpointConfig.fromJson(
              json['prompt_cache_breakpoint'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_file',
    if (fileUrl != null) 'file_url': fileUrl,
    if (fileId != null) 'file_id': fileId,
    if (fileData != null) 'file_data': fileData,
    if (filename != null) 'filename': filename,
    if (detail != null) 'detail': detail!.toJson(),
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputFileOutputContent &&
          runtimeType == other.runtimeType &&
          fileUrl == other.fileUrl &&
          fileId == other.fileId &&
          fileData == other.fileData &&
          filename == other.filename &&
          detail == other.detail &&
          promptCacheBreakpoint == other.promptCacheBreakpoint;

  @override
  int get hashCode => Object.hash(
    fileUrl,
    fileId,
    fileData,
    filename,
    detail,
    promptCacheBreakpoint,
  );

  @override
  String toString() =>
      'InputFileOutputContent(fileUrl: $fileUrl, fileId: $fileId, fileData: $fileData, filename: $filename, detail: $detail, promptCacheBreakpoint: $promptCacheBreakpoint)';
}

/// Opaque encrypted content, echoed as output.
///
/// Mirrors [EncryptedContent] but appears in output contexts such as the
/// beta multi-agent protocol's agent message content union
/// (`OpenAI-Beta: responses_multi_agent=v1`).
@immutable
class EncryptedOutputContent extends OutputContent {
  /// Opaque encrypted content.
  final String encryptedContent;

  /// Creates an [EncryptedOutputContent].
  const EncryptedOutputContent(this.encryptedContent);

  /// Creates an [EncryptedOutputContent] from JSON.
  factory EncryptedOutputContent.fromJson(Map<String, dynamic> json) {
    return EncryptedOutputContent(json['encrypted_content'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'encrypted_content',
    'encrypted_content': encryptedContent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedOutputContent &&
          runtimeType == other.runtimeType &&
          encryptedContent == other.encryptedContent;

  @override
  int get hashCode => encryptedContent.hashCode;

  @override
  String toString() =>
      'EncryptedOutputContent(encryptedContent: $encryptedContent)';
}
