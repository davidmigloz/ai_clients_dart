import 'package:meta/meta.dart';

import '../responses/common/equality_helpers.dart';
import '../responses/content/annotation.dart';

/// Content within a conversation item.
///
/// This sealed class hierarchy represents the different types of content
/// that can appear in conversation items, including types specific to
/// conversations that aren't available in the Responses API.
sealed class ConversationContent {
  /// Creates a [ConversationContent].
  const ConversationContent();

  /// Creates a [ConversationContent] from JSON.
  factory ConversationContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'input_text' => ConversationInputTextContent.fromJson(json),
      'input_image' => ConversationInputImageContent.fromJson(json),
      'input_file' => ConversationInputFileContent.fromJson(json),
      'output_text' => ConversationOutputTextContent.fromJson(json),
      'refusal' => ConversationRefusalContent.fromJson(json),
      'text' => ConversationTextContent.fromJson(json),
      'summary_text' => ConversationSummaryTextContent.fromJson(json),
      'reasoning_text' => ConversationReasoningTextContent.fromJson(json),
      'image_url' => ConversationImageUrlContent.fromJson(json),
      _ => ConversationUnknownContent(type: type, data: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Input text content in a conversation.
@immutable
class ConversationInputTextContent extends ConversationContent {
  /// The text content.
  final String text;

  /// Creates a [ConversationInputTextContent].
  const ConversationInputTextContent({required this.text});

  /// Creates a [ConversationInputTextContent] from JSON.
  factory ConversationInputTextContent.fromJson(Map<String, dynamic> json) {
    return ConversationInputTextContent(text: json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'input_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationInputTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ConversationInputTextContent(text: $text)';
}

/// Input image content in a conversation.
@immutable
class ConversationInputImageContent extends ConversationContent {
  /// The image URL.
  final String? imageUrl;

  /// The file ID for the image.
  final String? fileId;

  /// The detail level for the image.
  final String? detail;

  /// Creates a [ConversationInputImageContent].
  const ConversationInputImageContent({
    this.imageUrl,
    this.fileId,
    this.detail,
  });

  /// Creates a [ConversationInputImageContent] from JSON.
  factory ConversationInputImageContent.fromJson(Map<String, dynamic> json) {
    return ConversationInputImageContent(
      imageUrl: json['image_url'] as String?,
      fileId: json['file_id'] as String?,
      detail: json['detail'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_image',
    if (imageUrl != null) 'image_url': imageUrl,
    if (fileId != null) 'file_id': fileId,
    if (detail != null) 'detail': detail,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationInputImageContent &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          fileId == other.fileId &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(imageUrl, fileId, detail);

  @override
  String toString() =>
      'ConversationInputImageContent(imageUrl: $imageUrl, fileId: $fileId, detail: $detail)';
}

/// Input file content in a conversation.
@immutable
class ConversationInputFileContent extends ConversationContent {
  /// The file ID.
  final String? fileId;

  /// The filename.
  final String? filename;

  /// The file data (base64 encoded).
  final String? fileData;

  /// Creates a [ConversationInputFileContent].
  const ConversationInputFileContent({
    this.fileId,
    this.filename,
    this.fileData,
  });

  /// Creates a [ConversationInputFileContent] from JSON.
  factory ConversationInputFileContent.fromJson(Map<String, dynamic> json) {
    return ConversationInputFileContent(
      fileId: json['file_id'] as String?,
      filename: json['filename'] as String?,
      fileData: json['file_data'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_file',
    if (fileId != null) 'file_id': fileId,
    if (filename != null) 'filename': filename,
    if (fileData != null) 'file_data': fileData,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationInputFileContent &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId &&
          filename == other.filename &&
          fileData == other.fileData;

  @override
  int get hashCode => Object.hash(fileId, filename, fileData);

  @override
  String toString() =>
      'ConversationInputFileContent(fileId: $fileId, filename: $filename)';
}

/// Output text content in a conversation.
@immutable
class ConversationOutputTextContent extends ConversationContent {
  /// The text content.
  final String text;

  /// Annotations for the text.
  final List<Annotation>? annotations;

  /// Creates a [ConversationOutputTextContent].
  const ConversationOutputTextContent({required this.text, this.annotations});

  /// Creates a [ConversationOutputTextContent] from JSON.
  factory ConversationOutputTextContent.fromJson(Map<String, dynamic> json) {
    return ConversationOutputTextContent(
      text: json['text'] as String,
      annotations: (json['annotations'] as List?)
          ?.map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'output_text',
    'text': text,
    if (annotations != null)
      'annotations': annotations!.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationOutputTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          listsEqual(annotations, other.annotations);

  @override
  int get hashCode => Object.hash(text, annotations);

  @override
  String toString() =>
      'ConversationOutputTextContent(text: $text, annotations: $annotations)';
}

/// Refusal content in a conversation.
@immutable
class ConversationRefusalContent extends ConversationContent {
  /// The refusal message.
  final String refusal;

  /// Creates a [ConversationRefusalContent].
  const ConversationRefusalContent({required this.refusal});

  /// Creates a [ConversationRefusalContent] from JSON.
  factory ConversationRefusalContent.fromJson(Map<String, dynamic> json) {
    return ConversationRefusalContent(refusal: json['refusal'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'refusal', 'refusal': refusal};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationRefusalContent &&
          runtimeType == other.runtimeType &&
          refusal == other.refusal;

  @override
  int get hashCode => refusal.hashCode;

  @override
  String toString() => 'ConversationRefusalContent(refusal: $refusal)';
}

/// Simple text content (used in some conversation contexts).
@immutable
class ConversationTextContent extends ConversationContent {
  /// The text content.
  final String text;

  /// Creates a [ConversationTextContent].
  const ConversationTextContent({required this.text});

  /// Creates a [ConversationTextContent] from JSON.
  factory ConversationTextContent.fromJson(Map<String, dynamic> json) {
    return ConversationTextContent(text: json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ConversationTextContent(text: $text)';
}

/// Summary text content from reasoning output.
@immutable
class ConversationSummaryTextContent extends ConversationContent {
  /// The summary text.
  final String text;

  /// Creates a [ConversationSummaryTextContent].
  const ConversationSummaryTextContent({required this.text});

  /// Creates a [ConversationSummaryTextContent] from JSON.
  factory ConversationSummaryTextContent.fromJson(Map<String, dynamic> json) {
    return ConversationSummaryTextContent(text: json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'summary_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationSummaryTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ConversationSummaryTextContent(text: $text)';
}

/// Reasoning text content from reasoning models.
@immutable
class ConversationReasoningTextContent extends ConversationContent {
  /// The reasoning text.
  final String text;

  /// Creates a [ConversationReasoningTextContent].
  const ConversationReasoningTextContent({required this.text});

  /// Creates a [ConversationReasoningTextContent] from JSON.
  factory ConversationReasoningTextContent.fromJson(Map<String, dynamic> json) {
    return ConversationReasoningTextContent(text: json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'reasoning_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationReasoningTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ConversationReasoningTextContent(text: $text)';
}

/// Image URL content for conversation items.
@immutable
class ConversationImageUrlContent extends ConversationContent {
  /// The image URL.
  final String url;

  /// The detail level for the image.
  final String? detail;

  /// Creates a [ConversationImageUrlContent].
  const ConversationImageUrlContent({required this.url, this.detail});

  /// Creates a [ConversationImageUrlContent] from JSON.
  factory ConversationImageUrlContent.fromJson(Map<String, dynamic> json) {
    return ConversationImageUrlContent(
      url: json['url'] as String,
      detail: json['detail'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_url',
    'url': url,
    if (detail != null) 'detail': detail,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationImageUrlContent &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(url, detail);

  @override
  String toString() =>
      'ConversationImageUrlContent(url: $url, detail: $detail)';
}

/// Unknown content type (for forward compatibility).
@immutable
class ConversationUnknownContent extends ConversationContent {
  /// The content type.
  final String type;

  /// The raw JSON data.
  final Map<String, dynamic> data;

  /// Creates a [ConversationUnknownContent].
  const ConversationUnknownContent({required this.type, required this.data});

  @override
  Map<String, dynamic> toJson() => data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationUnknownContent &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ConversationUnknownContent(type: $type)';
}
