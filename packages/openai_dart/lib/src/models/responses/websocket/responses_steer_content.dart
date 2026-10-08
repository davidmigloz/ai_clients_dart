import 'package:meta/meta.dart';
import '../../chat/content_part.dart' show ImageDetail;
import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../../common/prompt_cache_breakpoint.dart';
import '../content/input_content.dart';
import 'websocket_json_helpers.dart';

/// Steering user content: [ResponsesSteerTextPart], [ResponsesSteerImagePart],
/// and [ResponsesSteerFilePart]. Request locators are optional; no image/file
/// locator or detail default is invented from the returned content shape.
@immutable
sealed class ResponsesSteerContentPart {
  /// Creates a content part.
  const ResponsesSteerContentPart();

  /// Creates user text content.
  const factory ResponsesSteerContentPart.text(
    String text, {
    PromptCacheBreakpointConfig? promptCacheBreakpoint,
  }) = ResponsesSteerTextPart;

  /// Creates image request content without defaulting its locator or detail.
  const factory ResponsesSteerContentPart.image({
    String? imageUrl,
    String? fileId,
    ImageDetail? detail,
    PromptCacheBreakpointConfig? promptCacheBreakpoint,
  }) = ResponsesSteerImagePart;

  /// Creates file content. File data must already use its documented data URL;
  /// this factory does not encode or execute the content.
  const factory ResponsesSteerContentPart.file({
    String? fileData,
    String? fileId,
    String? fileUrl,
    String? filename,
    FileInputDetail? detail,
    PromptCacheBreakpointConfig? promptCacheBreakpoint,
  }) = ResponsesSteerFilePart;

  /// The fixed discriminator.
  String get type;

  /// Original deeply immutable JSON after parsing, including future fields.
  Map<String, dynamic> get rawJson;

  /// Parses a supported request content part with contextual errors.
  factory ResponsesSteerContentPart.fromJson(Map<String, dynamic> json) {
    final type = requireJsonString(
      json['type'],
      'ResponsesSteerContentPart.type',
    );
    return switch (type) {
      'input_text' => ResponsesSteerTextPart.fromJson(json),
      'input_image' => ResponsesSteerImagePart.fromJson(json),
      'input_file' => ResponsesSteerFilePart.fromJson(json),
      _ => throw const FormatException(
        'ResponsesSteerContentPart.type: unsupported steering content',
      ),
    };
  }

  /// Projects existing text/image/file content. Other content kinds fail.
  factory ResponsesSteerContentPart.fromInputContent(InputContent content) =>
      ResponsesSteerContentPart.fromJson(content.toJson());

  /// Converts to JSON, omitting optional nulls and retaining future fields.
  Map<String, dynamic> toJson();
}

/// A `input_text` steering request part.
@immutable
class ResponsesSteerTextPart extends ResponsesSteerContentPart {
  /// The `text` request member.
  final String text;

  /// The `prompt_cache_breakpoint` request member (omitted when null).
  final PromptCacheBreakpointConfig? promptCacheBreakpoint;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates a [ResponsesSteerTextPart], preserving const caller-owned JSON.
  const ResponsesSteerTextPart(
    this.text, {
    this.promptCacheBreakpoint,
    this.rawJson = const {},
  });
  @override
  String get type => 'input_text';

  /// Parses known fields and snapshots future JSON.
  factory ResponsesSteerTextPart.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerTextPart';
    requireJsonType(json, 'input_text', context);
    final snapshot = snapshotResponsesJson(json, context);
    return ResponsesSteerTextPart(
      requireJsonString(snapshot['text'], '$context.text'),
      promptCacheBreakpoint: _steerBreakpoint(snapshot, context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'text', 'prompt_cache_breakpoint'},
    {
      'type': type,
      'text': text,
      if (promptCacheBreakpoint != null)
        'prompt_cache_breakpoint': _steerBreakpointJson(
          rawJson,
          promptCacheBreakpoint!,
        ),
    },
  );

  /// Copies all fields; explicit null clears optional members.
  ResponsesSteerTextPart copyWith({
    String? text,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponsesSteerTextPart(
    text ?? this.text,
    promptCacheBreakpoint: identical(promptCacheBreakpoint, unsetCopyWithValue)
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as PromptCacheBreakpointConfig?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerTextPart &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));
  @override
  String toString() =>
      'ResponsesSteerTextPart(text: [REDACTED], promptCacheBreakpoint: ${promptCacheBreakpoint == null ? 'null' : '[REDACTED]'}, rawJson: ${rawJson.length} entries)';
}

/// A `input_image` steering request part.
@immutable
class ResponsesSteerImagePart extends ResponsesSteerContentPart {
  /// The `image_url` request member (omitted when null).
  final String? imageUrl;

  /// The `file_id` request member (omitted when null).
  final String? fileId;

  /// The `detail` request member (omitted when null).
  final ImageDetail? detail;

  /// The `prompt_cache_breakpoint` request member (omitted when null).
  final PromptCacheBreakpointConfig? promptCacheBreakpoint;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates a [ResponsesSteerImagePart], preserving const caller-owned JSON.
  const ResponsesSteerImagePart({
    this.imageUrl,
    this.fileId,
    this.detail,
    this.promptCacheBreakpoint,
    this.rawJson = const {},
  });
  @override
  String get type => 'input_image';

  /// Parses known fields and snapshots future JSON.
  factory ResponsesSteerImagePart.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerImagePart';
    requireJsonType(json, 'input_image', context);
    final snapshot = snapshotResponsesJson(json, context);
    return ResponsesSteerImagePart(
      imageUrl: optionalJsonString(
        snapshot,
        'image_url',
        context,
        nullable: true,
      ),
      fileId: optionalJsonString(snapshot, 'file_id', context, nullable: true),
      detail: _steerImageDetail(snapshot, context),
      promptCacheBreakpoint: _steerBreakpoint(snapshot, context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() => mergeResponsesJson(
    rawJson,
    const {'type', 'image_url', 'file_id', 'detail', 'prompt_cache_breakpoint'},
    {
      'type': type,
      if (imageUrl != null) 'image_url': imageUrl,
      if (fileId != null) 'file_id': fileId,
      if (detail != null) 'detail': detail!.toJson(),
      if (promptCacheBreakpoint != null)
        'prompt_cache_breakpoint': _steerBreakpointJson(
          rawJson,
          promptCacheBreakpoint!,
        ),
    },
  );

  /// Copies all fields; explicit null clears optional members.
  ResponsesSteerImagePart copyWith({
    Object? imageUrl = unsetCopyWithValue,
    Object? fileId = unsetCopyWithValue,
    Object? detail = unsetCopyWithValue,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponsesSteerImagePart(
    imageUrl: identical(imageUrl, unsetCopyWithValue)
        ? this.imageUrl
        : imageUrl as String?,
    fileId: identical(fileId, unsetCopyWithValue)
        ? this.fileId
        : fileId as String?,
    detail: identical(detail, unsetCopyWithValue)
        ? this.detail
        : detail as ImageDetail?,
    promptCacheBreakpoint: identical(promptCacheBreakpoint, unsetCopyWithValue)
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as PromptCacheBreakpointConfig?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerImagePart &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));
  @override
  String toString() =>
      'ResponsesSteerImagePart(imageUrl: ${imageUrl == null ? 'null' : '[REDACTED]'}, fileId: ${fileId == null ? 'null' : '[REDACTED]'}, detail: ${detail == null ? 'null' : '[REDACTED]'}, promptCacheBreakpoint: ${promptCacheBreakpoint == null ? 'null' : '[REDACTED]'}, rawJson: ${rawJson.length} entries)';
}

/// A `input_file` steering request part.
@immutable
class ResponsesSteerFilePart extends ResponsesSteerContentPart {
  /// The `file_data` request member (omitted when null).
  final String? fileData;

  /// The `file_id` request member (omitted when null).
  final String? fileId;

  /// The `file_url` request member (omitted when null).
  final String? fileUrl;

  /// The `filename` request member (omitted when null).
  final String? filename;

  /// The `detail` request member (omitted when null).
  final FileInputDetail? detail;

  /// The `prompt_cache_breakpoint` request member (omitted when null).
  final PromptCacheBreakpointConfig? promptCacheBreakpoint;
  @override
  final Map<String, dynamic> rawJson;

  /// Creates a [ResponsesSteerFilePart], preserving const caller-owned JSON.
  const ResponsesSteerFilePart({
    this.fileData,
    this.fileId,
    this.fileUrl,
    this.filename,
    this.detail,
    this.promptCacheBreakpoint,
    this.rawJson = const {},
  });
  @override
  String get type => 'input_file';

  /// Parses known fields and snapshots future JSON.
  factory ResponsesSteerFilePart.fromJson(Map<String, dynamic> json) {
    const context = 'ResponsesSteerFilePart';
    requireJsonType(json, 'input_file', context);
    final snapshot = snapshotResponsesJson(json, context);
    return ResponsesSteerFilePart(
      fileData: optionalJsonString(
        snapshot,
        'file_data',
        context,
        nullable: true,
      ),
      fileId: optionalJsonString(snapshot, 'file_id', context, nullable: true),
      fileUrl: optionalJsonString(
        snapshot,
        'file_url',
        context,
        nullable: true,
      ),
      filename: optionalJsonString(
        snapshot,
        'filename',
        context,
        nullable: true,
      ),
      detail: _steerFileDetail(snapshot, context),
      promptCacheBreakpoint: _steerBreakpoint(snapshot, context),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> toJson() => mergeResponsesJson(
    rawJson,
    const {
      'type',
      'file_data',
      'file_id',
      'file_url',
      'filename',
      'detail',
      'prompt_cache_breakpoint',
    },
    {
      'type': type,
      if (fileData != null) 'file_data': fileData,
      if (fileId != null) 'file_id': fileId,
      if (fileUrl != null) 'file_url': fileUrl,
      if (filename != null) 'filename': filename,
      if (detail != null) 'detail': detail!.toJson(),
      if (promptCacheBreakpoint != null)
        'prompt_cache_breakpoint': _steerBreakpointJson(
          rawJson,
          promptCacheBreakpoint!,
        ),
    },
  );

  /// Copies all fields; explicit null clears optional members.
  ResponsesSteerFilePart copyWith({
    Object? fileData = unsetCopyWithValue,
    Object? fileId = unsetCopyWithValue,
    Object? fileUrl = unsetCopyWithValue,
    Object? filename = unsetCopyWithValue,
    Object? detail = unsetCopyWithValue,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponsesSteerFilePart(
    fileData: identical(fileData, unsetCopyWithValue)
        ? this.fileData
        : fileData as String?,
    fileId: identical(fileId, unsetCopyWithValue)
        ? this.fileId
        : fileId as String?,
    fileUrl: identical(fileUrl, unsetCopyWithValue)
        ? this.fileUrl
        : fileUrl as String?,
    filename: identical(filename, unsetCopyWithValue)
        ? this.filename
        : filename as String?,
    detail: identical(detail, unsetCopyWithValue)
        ? this.detail
        : detail as FileInputDetail?,
    promptCacheBreakpoint: identical(promptCacheBreakpoint, unsetCopyWithValue)
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as PromptCacheBreakpointConfig?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsesSteerFilePart &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));
  @override
  String toString() =>
      'ResponsesSteerFilePart(fileData: ${fileData == null ? 'null' : '[REDACTED]'}, fileId: ${fileId == null ? 'null' : '[REDACTED]'}, fileUrl: ${fileUrl == null ? 'null' : '[REDACTED]'}, filename: ${filename == null ? 'null' : '[REDACTED]'}, detail: ${detail == null ? 'null' : '[REDACTED]'}, promptCacheBreakpoint: ${promptCacheBreakpoint == null ? 'null' : '[REDACTED]'}, rawJson: ${rawJson.length} entries)';
}

PromptCacheBreakpointConfig? _steerBreakpoint(
  Map<String, dynamic> json,
  String context,
) {
  if (json['prompt_cache_breakpoint'] == null) return null;
  final object = requireJsonObject(
    json['prompt_cache_breakpoint'],
    '$context.prompt_cache_breakpoint',
  );
  if (object['mode'] != 'explicit') {
    throw FormatException(
      '$context.prompt_cache_breakpoint.mode: expected explicit',
    );
  }
  return const PromptCacheBreakpointConfig();
}

ImageDetail? _steerImageDetail(Map<String, dynamic> json, String context) {
  final value = optionalJsonString(json, 'detail', context, nullable: true);
  if (value == null) return null;
  if (!const {'auto', 'low', 'high', 'original'}.contains(value)) {
    throw FormatException('$context.detail: unsupported image detail');
  }
  return ImageDetail.fromJson(value);
}

FileInputDetail? _steerFileDetail(Map<String, dynamic> json, String context) {
  final value = optionalJsonString(json, 'detail', context);
  if (value == null) return null;
  if (!const {'auto', 'low', 'high'}.contains(value)) {
    throw FormatException('$context.detail: unsupported file detail');
  }
  return FileInputDetail.fromJson(value);
}

Map<String, dynamic> _steerBreakpointJson(
  Map<String, dynamic> rawJson,
  PromptCacheBreakpointConfig value,
) => overlayResponsesJson(
  rawJson['prompt_cache_breakpoint'] is Map<String, dynamic>
      ? rawJson['prompt_cache_breakpoint'] as Map<String, dynamic>
      : const {},
  value.toJson(),
);
