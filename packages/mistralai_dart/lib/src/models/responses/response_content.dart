import 'package:meta/meta.dart';

import '../../utils/additional_json_fields.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A ResponseInputPart variant.
///
/// [ResponseInputTextPart], [ResponseInputImagePart], [ResponseInputFilePart], or [UnknownResponseInputPart].
@immutable
sealed class ResponseInputPart {
  const ResponseInputPart();

  /// Parses an API payload.
  factory ResponseInputPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'input_text' => ResponseInputTextPart.fromJson(json),
        'input_image' => ResponseInputImagePart.fromJson(json),
        'input_file' => ResponseInputFilePart.fromJson(json),
        _ => UnknownResponseInputPart(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseInputPart value.
@immutable
final class UnknownResponseInputPart extends ResponseInputPart {
  /// Creates a fallback from the original payload.
  UnknownResponseInputPart(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseInputPart && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A ResponseFunctionPart variant.
///
/// [ResponseInputTextPart], [ResponseFunctionImagePart], [ResponseInputFilePart], or [UnknownResponseFunctionPart].
@immutable
sealed class ResponseFunctionPart {
  const ResponseFunctionPart();

  /// Parses an API payload.
  factory ResponseFunctionPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'input_text' => ResponseInputTextPart.fromJson(json),
        'input_image' => ResponseFunctionImagePart.fromJson(json),
        'input_file' => ResponseInputFilePart.fromJson(json),
        _ => UnknownResponseFunctionPart(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseFunctionPart value.
@immutable
final class UnknownResponseFunctionPart extends ResponseFunctionPart {
  /// Creates a fallback from the original payload.
  UnknownResponseFunctionPart(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseFunctionPart && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A ResponseOutputPart variant.
///
/// [ResponseOutputText], [ResponseOutputRefusal], [ResponseReasoningText], or [UnknownResponseOutputPart].
@immutable
sealed class ResponseOutputPart {
  const ResponseOutputPart();

  /// Parses an API payload.
  factory ResponseOutputPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'output_text' => ResponseOutputText.fromJson(json),
        'refusal' => ResponseOutputRefusal.fromJson(json),
        'reasoning_text' => ResponseReasoningText.fromJson(json),
        _ => UnknownResponseOutputPart(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseOutputPart value.
@immutable
final class UnknownResponseOutputPart extends ResponseOutputPart {
  /// Creates a fallback from the original payload.
  UnknownResponseOutputPart(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseOutputPart && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A ResponseAnnotation variant.
///
/// [ResponseContainerFileCitation], [ResponseFileCitation], [ResponseFilePath], [ResponseUrlCitation], or [UnknownResponseAnnotation].
@immutable
sealed class ResponseAnnotation {
  const ResponseAnnotation();

  /// Parses an API payload.
  factory ResponseAnnotation.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'container_file_citation' => ResponseContainerFileCitation.fromJson(
          json,
        ),
        'file_citation' => ResponseFileCitation.fromJson(json),
        'file_path' => ResponseFilePath.fromJson(json),
        'url_citation' => ResponseUrlCitation.fromJson(json),
        _ => UnknownResponseAnnotation(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseAnnotation value.
@immutable
final class UnknownResponseAnnotation extends ResponseAnnotation {
  /// Creates a fallback from the original payload.
  UnknownResponseAnnotation(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseAnnotation && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The ResponsesInputText wire payload.
@immutable
class ResponseInputTextPart extends ResponseInputPart
    implements ResponseFunctionPart {
  /// Creates a [ResponseInputTextPart].
  const ResponseInputTextPart({
    this.promptCacheBreakpoint,
    required this.text,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'input_text';

  /// The prompt_cache_breakpoint field.
  final ResponsePromptCacheBreakpoint? promptCacheBreakpoint;

  /// The text field.
  final String text;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseInputTextPart] from JSON.
  factory ResponseInputTextPart.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'input_text') {
      throw FormatException('ResponseInputTextPart: unexpected type $value');
    }
    if (json['text'] == null) {
      throw const FormatException('ResponseInputTextPart: missing text');
    }
    return ResponseInputTextPart(
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] == null
          ? null
          : ResponsePromptCacheBreakpoint.fromJson(
              json['prompt_cache_breakpoint'] as Map<String, dynamic>,
            ),
      text: json['text'] as String,
      extra: additionalJsonFields(json, const {
        'prompt_cache_breakpoint',
        'text',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
    'text': text,
  };

  /// Creates a copy with the given fields replaced.
  ResponseInputTextPart copyWith({
    Object? promptCacheBreakpoint = unsetCopyWithValue,
    String? text,
    Object? extra = unsetCopyWithValue,
  }) => ResponseInputTextPart(
    promptCacheBreakpoint: promptCacheBreakpoint == unsetCopyWithValue
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as ResponsePromptCacheBreakpoint?,
    text: text ?? this.text,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputTextPart &&
          runtimeType == other.runtimeType &&
          promptCacheBreakpoint == other.promptCacheBreakpoint &&
          text == other.text &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([promptCacheBreakpoint, text, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseInputTextPart('
      'promptCacheBreakpoint: $promptCacheBreakpoint, '
      'text: $text, '
      'extra: ${extra?.length})';
}

/// The ResponsesInputImage wire payload.
@immutable
class ResponseInputImagePart extends ResponseInputPart {
  /// Creates a [ResponseInputImagePart].
  const ResponseInputImagePart({
    required this.detail,
    this.fileId,
    this.imageUrl,
    this.promptCacheBreakpoint,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'input_image';

  /// The detail field.
  final String detail;

  /// The file_id field.
  final String? fileId;

  /// The image_url field.
  final String? imageUrl;

  /// The prompt_cache_breakpoint field.
  final ResponsePromptCacheBreakpoint? promptCacheBreakpoint;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseInputImagePart] from JSON.
  factory ResponseInputImagePart.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'input_image') {
      throw FormatException('ResponseInputImagePart: unexpected type $value');
    }
    if (json['detail'] == null) {
      throw const FormatException('ResponseInputImagePart: missing detail');
    }
    return ResponseInputImagePart(
      detail: json['detail'] as String,
      fileId: json['file_id'] == null ? null : json['file_id'] as String,
      imageUrl: json['image_url'] == null ? null : json['image_url'] as String,
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] == null
          ? null
          : ResponsePromptCacheBreakpoint.fromJson(
              json['prompt_cache_breakpoint'] as Map<String, dynamic>,
            ),
      extra: additionalJsonFields(json, const {
        'detail',
        'file_id',
        'image_url',
        'prompt_cache_breakpoint',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'detail': detail,
    'file_id': ?fileId,
    'image_url': ?imageUrl,
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseInputImagePart copyWith({
    String? detail,
    Object? fileId = unsetCopyWithValue,
    Object? imageUrl = unsetCopyWithValue,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseInputImagePart(
    detail: detail ?? this.detail,
    fileId: fileId == unsetCopyWithValue ? this.fileId : fileId as String?,
    imageUrl: imageUrl == unsetCopyWithValue
        ? this.imageUrl
        : imageUrl as String?,
    promptCacheBreakpoint: promptCacheBreakpoint == unsetCopyWithValue
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as ResponsePromptCacheBreakpoint?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputImagePart &&
          runtimeType == other.runtimeType &&
          detail == other.detail &&
          fileId == other.fileId &&
          imageUrl == other.imageUrl &&
          promptCacheBreakpoint == other.promptCacheBreakpoint &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    detail,
    fileId,
    imageUrl,
    promptCacheBreakpoint,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseInputImagePart('
      'detail: $detail, '
      'fileId: $fileId, '
      'imageUrl: $imageUrl, '
      'promptCacheBreakpoint: $promptCacheBreakpoint, '
      'extra: ${extra?.length})';
}

/// The ResponsesInputFile wire payload.
@immutable
class ResponseInputFilePart extends ResponseInputPart
    implements ResponseFunctionPart {
  /// Creates a [ResponseInputFilePart].
  const ResponseInputFilePart({
    this.detail,
    this.fileData,
    this.fileId,
    this.fileUrl,
    this.filename,
    this.promptCacheBreakpoint,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'input_file';

  /// The detail field.
  final String? detail;

  /// The file_data field.
  final String? fileData;

  /// The file_id field.
  final String? fileId;

  /// The file_url field.
  final String? fileUrl;

  /// The filename field.
  final String? filename;

  /// The prompt_cache_breakpoint field.
  final ResponsePromptCacheBreakpoint? promptCacheBreakpoint;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseInputFilePart] from JSON.
  factory ResponseInputFilePart.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'input_file') {
      throw FormatException('ResponseInputFilePart: unexpected type $value');
    }
    return ResponseInputFilePart(
      detail: json['detail'] == null ? null : json['detail'] as String,
      fileData: json['file_data'] == null ? null : json['file_data'] as String,
      fileId: json['file_id'] == null ? null : json['file_id'] as String,
      fileUrl: json['file_url'] == null ? null : json['file_url'] as String,
      filename: json['filename'] == null ? null : json['filename'] as String,
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] == null
          ? null
          : ResponsePromptCacheBreakpoint.fromJson(
              json['prompt_cache_breakpoint'] as Map<String, dynamic>,
            ),
      extra: additionalJsonFields(json, const {
        'detail',
        'file_data',
        'file_id',
        'file_url',
        'filename',
        'prompt_cache_breakpoint',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'detail': ?detail,
    'file_data': ?fileData,
    'file_id': ?fileId,
    'file_url': ?fileUrl,
    'filename': ?filename,
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseInputFilePart copyWith({
    Object? detail = unsetCopyWithValue,
    Object? fileData = unsetCopyWithValue,
    Object? fileId = unsetCopyWithValue,
    Object? fileUrl = unsetCopyWithValue,
    Object? filename = unsetCopyWithValue,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseInputFilePart(
    detail: detail == unsetCopyWithValue ? this.detail : detail as String?,
    fileData: fileData == unsetCopyWithValue
        ? this.fileData
        : fileData as String?,
    fileId: fileId == unsetCopyWithValue ? this.fileId : fileId as String?,
    fileUrl: fileUrl == unsetCopyWithValue ? this.fileUrl : fileUrl as String?,
    filename: filename == unsetCopyWithValue
        ? this.filename
        : filename as String?,
    promptCacheBreakpoint: promptCacheBreakpoint == unsetCopyWithValue
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as ResponsePromptCacheBreakpoint?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputFilePart &&
          runtimeType == other.runtimeType &&
          detail == other.detail &&
          fileData == other.fileData &&
          fileId == other.fileId &&
          fileUrl == other.fileUrl &&
          filename == other.filename &&
          promptCacheBreakpoint == other.promptCacheBreakpoint &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    detail,
    fileData,
    fileId,
    fileUrl,
    filename,
    promptCacheBreakpoint,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseInputFilePart('
      'detail: $detail, '
      'fileData: $fileData, '
      'fileId: $fileId, '
      'fileUrl: $fileUrl, '
      'filename: $filename, '
      'promptCacheBreakpoint: $promptCacheBreakpoint, '
      'extra: ${extra?.length})';
}

/// The ResponsesPromptCacheBreakpoint wire payload.
@immutable
class ResponsePromptCacheBreakpoint {
  /// Creates a [ResponsePromptCacheBreakpoint].
  const ResponsePromptCacheBreakpoint({this.ttl, this.extra});

  /// The fixed mode discriminator.
  String get mode => 'explicit';

  /// The ttl field.
  final String? ttl;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponsePromptCacheBreakpoint] from JSON.
  factory ResponsePromptCacheBreakpoint.fromJson(Map<String, dynamic> json) {
    if (json['mode'] case final value? when value != 'explicit') {
      throw FormatException(
        'ResponsePromptCacheBreakpoint: unexpected mode $value',
      );
    }
    return ResponsePromptCacheBreakpoint(
      ttl: json['ttl'] == null ? null : json['ttl'] as String,
      extra: additionalJsonFields(json, const {'ttl', 'mode'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {...?extra, 'mode': mode, 'ttl': ?ttl};

  /// Creates a copy with the given fields replaced.
  ResponsePromptCacheBreakpoint copyWith({
    Object? ttl = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponsePromptCacheBreakpoint(
    ttl: ttl == unsetCopyWithValue ? this.ttl : ttl as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponsePromptCacheBreakpoint &&
          runtimeType == other.runtimeType &&
          ttl == other.ttl &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([ttl, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponsePromptCacheBreakpoint('
      'ttl: $ttl, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputText wire payload.
@immutable
class ResponseOutputText extends ResponseOutputPart {
  /// Creates a [ResponseOutputText].
  const ResponseOutputText({
    required this.annotations,
    this.logprobs,
    required this.text,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'output_text';

  /// The annotations field.
  final List<ResponseAnnotation> annotations;

  /// The logprobs field.
  final List<ResponseOutputTokenLogprob>? logprobs;

  /// The text field.
  final String text;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputText] from JSON.
  factory ResponseOutputText.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'output_text') {
      throw FormatException('ResponseOutputText: unexpected type $value');
    }
    if (json['annotations'] == null) {
      throw const FormatException('ResponseOutputText: missing annotations');
    }
    if (json['text'] == null) {
      throw const FormatException('ResponseOutputText: missing text');
    }
    return ResponseOutputText(
      annotations: (json['annotations'] as List)
          .map(
            (item) => ResponseAnnotation.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      logprobs: json['logprobs'] == null
          ? null
          : (json['logprobs'] as List)
                .map(
                  (item) => ResponseOutputTokenLogprob.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      text: json['text'] as String,
      extra: additionalJsonFields(json, const {
        'annotations',
        'logprobs',
        'text',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'annotations': annotations.map((item) => item.toJson()).toList(),
    if (logprobs != null)
      'logprobs': logprobs!.map((item) => item.toJson()).toList(),
    'text': text,
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputText copyWith({
    List<ResponseAnnotation>? annotations,
    Object? logprobs = unsetCopyWithValue,
    String? text,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputText(
    annotations: annotations ?? this.annotations,
    logprobs: logprobs == unsetCopyWithValue
        ? this.logprobs
        : (logprobs as List?)?.cast<ResponseOutputTokenLogprob>(),
    text: text ?? this.text,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputText &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(annotations, other.annotations) &&
          valuesDeepEqual(logprobs, other.logprobs) &&
          text == other.text &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(annotations),
    valueDeepHashCode(logprobs),
    text,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseOutputText('
      'annotations: ${annotations.length}, '
      'logprobs: ${logprobs?.length}, '
      'text: $text, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputRefusal wire payload.
@immutable
class ResponseOutputRefusal extends ResponseOutputPart {
  /// Creates a [ResponseOutputRefusal].
  const ResponseOutputRefusal({required this.refusal, this.extra});

  /// The fixed type discriminator.
  String get type => 'refusal';

  /// The refusal field.
  final String refusal;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputRefusal] from JSON.
  factory ResponseOutputRefusal.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'refusal') {
      throw FormatException('ResponseOutputRefusal: unexpected type $value');
    }
    if (json['refusal'] == null) {
      throw const FormatException('ResponseOutputRefusal: missing refusal');
    }
    return ResponseOutputRefusal(
      refusal: json['refusal'] as String,
      extra: additionalJsonFields(json, const {'refusal', 'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'refusal': refusal,
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputRefusal copyWith({
    String? refusal,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputRefusal(
    refusal: refusal ?? this.refusal,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputRefusal &&
          runtimeType == other.runtimeType &&
          refusal == other.refusal &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([refusal, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseOutputRefusal('
      'refusal: $refusal, '
      'extra: ${extra?.length})';
}

/// The ResponsesPartReasoningText wire payload.
@immutable
class ResponseReasoningText extends ResponseOutputPart {
  /// Creates a [ResponseReasoningText].
  const ResponseReasoningText({required this.text, this.extra});

  /// The fixed type discriminator.
  String get type => 'reasoning_text';

  /// The text field.
  final String text;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseReasoningText] from JSON.
  factory ResponseReasoningText.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'reasoning_text') {
      throw FormatException('ResponseReasoningText: unexpected type $value');
    }
    if (json['text'] == null) {
      throw const FormatException('ResponseReasoningText: missing text');
    }
    return ResponseReasoningText(
      text: json['text'] as String,
      extra: additionalJsonFields(json, const {'text', 'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {...?extra, 'type': type, 'text': text};

  /// Creates a copy with the given fields replaced.
  ResponseReasoningText copyWith({
    String? text,
    Object? extra = unsetCopyWithValue,
  }) => ResponseReasoningText(
    text: text ?? this.text,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseReasoningText &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([text, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseReasoningText('
      'text: $text, '
      'extra: ${extra?.length})';
}

/// The ResponsesSummary wire payload.
@immutable
class ResponseReasoningSummary {
  /// Creates a [ResponseReasoningSummary].
  const ResponseReasoningSummary({required this.text, this.extra});

  /// The fixed type discriminator.
  String get type => 'summary_text';

  /// The text field.
  final String text;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseReasoningSummary] from JSON.
  factory ResponseReasoningSummary.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'summary_text') {
      throw FormatException('ResponseReasoningSummary: unexpected type $value');
    }
    if (json['text'] == null) {
      throw const FormatException('ResponseReasoningSummary: missing text');
    }
    return ResponseReasoningSummary(
      text: json['text'] as String,
      extra: additionalJsonFields(json, const {'text', 'type'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {...?extra, 'type': type, 'text': text};

  /// Creates a copy with the given fields replaced.
  ResponseReasoningSummary copyWith({
    String? text,
    Object? extra = unsetCopyWithValue,
  }) => ResponseReasoningSummary(
    text: text ?? this.text,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseReasoningSummary &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([text, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseReasoningSummary('
      'text: $text, '
      'extra: ${extra?.length})';
}

/// The ResponsesAnnotationContainerFileCitation wire payload.
@immutable
class ResponseContainerFileCitation extends ResponseAnnotation {
  /// Creates a [ResponseContainerFileCitation].
  const ResponseContainerFileCitation({
    required this.containerId,
    required this.endIndex,
    required this.fileId,
    required this.filename,
    required this.startIndex,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'container_file_citation';

  /// The container_id field.
  final String containerId;

  /// The end_index field.
  final int endIndex;

  /// The file_id field.
  final String fileId;

  /// The filename field.
  final String filename;

  /// The start_index field.
  final int startIndex;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseContainerFileCitation] from JSON.
  factory ResponseContainerFileCitation.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'container_file_citation') {
      throw FormatException(
        'ResponseContainerFileCitation: unexpected type $value',
      );
    }
    if (json['container_id'] == null) {
      throw const FormatException(
        'ResponseContainerFileCitation: missing container_id',
      );
    }
    if (json['end_index'] == null) {
      throw const FormatException(
        'ResponseContainerFileCitation: missing end_index',
      );
    }
    if (json['file_id'] == null) {
      throw const FormatException(
        'ResponseContainerFileCitation: missing file_id',
      );
    }
    if (json['filename'] == null) {
      throw const FormatException(
        'ResponseContainerFileCitation: missing filename',
      );
    }
    if (json['start_index'] == null) {
      throw const FormatException(
        'ResponseContainerFileCitation: missing start_index',
      );
    }
    return ResponseContainerFileCitation(
      containerId: json['container_id'] as String,
      endIndex: json['end_index'] as int,
      fileId: json['file_id'] as String,
      filename: json['filename'] as String,
      startIndex: json['start_index'] as int,
      extra: additionalJsonFields(json, const {
        'container_id',
        'end_index',
        'file_id',
        'filename',
        'start_index',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'container_id': containerId,
    'end_index': endIndex,
    'file_id': fileId,
    'filename': filename,
    'start_index': startIndex,
  };

  /// Creates a copy with the given fields replaced.
  ResponseContainerFileCitation copyWith({
    String? containerId,
    int? endIndex,
    String? fileId,
    String? filename,
    int? startIndex,
    Object? extra = unsetCopyWithValue,
  }) => ResponseContainerFileCitation(
    containerId: containerId ?? this.containerId,
    endIndex: endIndex ?? this.endIndex,
    fileId: fileId ?? this.fileId,
    filename: filename ?? this.filename,
    startIndex: startIndex ?? this.startIndex,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseContainerFileCitation &&
          runtimeType == other.runtimeType &&
          containerId == other.containerId &&
          endIndex == other.endIndex &&
          fileId == other.fileId &&
          filename == other.filename &&
          startIndex == other.startIndex &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    containerId,
    endIndex,
    fileId,
    filename,
    startIndex,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseContainerFileCitation('
      'containerId: $containerId, '
      'endIndex: $endIndex, '
      'fileId: $fileId, '
      'filename: $filename, '
      'startIndex: $startIndex, '
      'extra: ${extra?.length})';
}

/// The ResponsesAnnotationFileCitation wire payload.
@immutable
class ResponseFileCitation extends ResponseAnnotation {
  /// Creates a [ResponseFileCitation].
  const ResponseFileCitation({
    required this.fileId,
    required this.filename,
    required this.index,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'file_citation';

  /// The file_id field.
  final String fileId;

  /// The filename field.
  final String filename;

  /// The index field.
  final int index;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFileCitation] from JSON.
  factory ResponseFileCitation.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'file_citation') {
      throw FormatException('ResponseFileCitation: unexpected type $value');
    }
    if (json['file_id'] == null) {
      throw const FormatException('ResponseFileCitation: missing file_id');
    }
    if (json['filename'] == null) {
      throw const FormatException('ResponseFileCitation: missing filename');
    }
    if (json['index'] == null) {
      throw const FormatException('ResponseFileCitation: missing index');
    }
    return ResponseFileCitation(
      fileId: json['file_id'] as String,
      filename: json['filename'] as String,
      index: json['index'] as int,
      extra: additionalJsonFields(json, const {
        'file_id',
        'filename',
        'index',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'file_id': fileId,
    'filename': filename,
    'index': index,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFileCitation copyWith({
    String? fileId,
    String? filename,
    int? index,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFileCitation(
    fileId: fileId ?? this.fileId,
    filename: filename ?? this.filename,
    index: index ?? this.index,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFileCitation &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId &&
          filename == other.filename &&
          index == other.index &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([fileId, filename, index, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseFileCitation('
      'fileId: $fileId, '
      'filename: $filename, '
      'index: $index, '
      'extra: ${extra?.length})';
}

/// The ResponsesAnnotationFilePath wire payload.
@immutable
class ResponseFilePath extends ResponseAnnotation {
  /// Creates a [ResponseFilePath].
  const ResponseFilePath({
    required this.fileId,
    required this.index,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'file_path';

  /// The file_id field.
  final String fileId;

  /// The index field.
  final int index;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFilePath] from JSON.
  factory ResponseFilePath.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'file_path') {
      throw FormatException('ResponseFilePath: unexpected type $value');
    }
    if (json['file_id'] == null) {
      throw const FormatException('ResponseFilePath: missing file_id');
    }
    if (json['index'] == null) {
      throw const FormatException('ResponseFilePath: missing index');
    }
    return ResponseFilePath(
      fileId: json['file_id'] as String,
      index: json['index'] as int,
      extra: additionalJsonFields(json, const {'file_id', 'index', 'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'file_id': fileId,
    'index': index,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFilePath copyWith({
    String? fileId,
    int? index,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFilePath(
    fileId: fileId ?? this.fileId,
    index: index ?? this.index,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFilePath &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId &&
          index == other.index &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([fileId, index, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseFilePath('
      'fileId: $fileId, '
      'index: $index, '
      'extra: ${extra?.length})';
}

/// The ResponsesAnnotationURLCitation wire payload.
@immutable
class ResponseUrlCitation extends ResponseAnnotation {
  /// Creates a [ResponseUrlCitation].
  const ResponseUrlCitation({
    required this.endIndex,
    required this.startIndex,
    required this.title,
    required this.url,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'url_citation';

  /// The end_index field.
  final int endIndex;

  /// The start_index field.
  final int startIndex;

  /// The title field.
  final String title;

  /// The url field.
  final String url;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseUrlCitation] from JSON.
  factory ResponseUrlCitation.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'url_citation') {
      throw FormatException('ResponseUrlCitation: unexpected type $value');
    }
    if (json['end_index'] == null) {
      throw const FormatException('ResponseUrlCitation: missing end_index');
    }
    if (json['start_index'] == null) {
      throw const FormatException('ResponseUrlCitation: missing start_index');
    }
    if (json['title'] == null) {
      throw const FormatException('ResponseUrlCitation: missing title');
    }
    if (json['url'] == null) {
      throw const FormatException('ResponseUrlCitation: missing url');
    }
    return ResponseUrlCitation(
      endIndex: json['end_index'] as int,
      startIndex: json['start_index'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      extra: additionalJsonFields(json, const {
        'end_index',
        'start_index',
        'title',
        'url',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'end_index': endIndex,
    'start_index': startIndex,
    'title': title,
    'url': url,
  };

  /// Creates a copy with the given fields replaced.
  ResponseUrlCitation copyWith({
    int? endIndex,
    int? startIndex,
    String? title,
    String? url,
    Object? extra = unsetCopyWithValue,
  }) => ResponseUrlCitation(
    endIndex: endIndex ?? this.endIndex,
    startIndex: startIndex ?? this.startIndex,
    title: title ?? this.title,
    url: url ?? this.url,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseUrlCitation &&
          runtimeType == other.runtimeType &&
          endIndex == other.endIndex &&
          startIndex == other.startIndex &&
          title == other.title &&
          url == other.url &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    endIndex,
    startIndex,
    title,
    url,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseUrlCitation('
      'endIndex: $endIndex, '
      'startIndex: $startIndex, '
      'title: $title, '
      'url: $url, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputTextLogprob wire payload.
@immutable
class ResponseOutputTokenLogprob {
  /// Creates a [ResponseOutputTokenLogprob].
  const ResponseOutputTokenLogprob({
    required this.bytes,
    required this.logprob,
    required this.token,
    required this.topLogprobs,
    this.extra,
  });

  /// The bytes field.
  final List<int> bytes;

  /// The logprob field.
  final double logprob;

  /// The token field.
  final String token;

  /// The top_logprobs field.
  final List<ResponseOutputTopLogprob> topLogprobs;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputTokenLogprob] from JSON.
  factory ResponseOutputTokenLogprob.fromJson(Map<String, dynamic> json) {
    if (json['bytes'] == null) {
      throw const FormatException('ResponseOutputTokenLogprob: missing bytes');
    }
    if (json['logprob'] == null) {
      throw const FormatException(
        'ResponseOutputTokenLogprob: missing logprob',
      );
    }
    if (json['token'] == null) {
      throw const FormatException('ResponseOutputTokenLogprob: missing token');
    }
    if (json['top_logprobs'] == null) {
      throw const FormatException(
        'ResponseOutputTokenLogprob: missing top_logprobs',
      );
    }
    return ResponseOutputTokenLogprob(
      bytes: (json['bytes'] as List).map((item) => item as int).toList(),
      logprob: (json['logprob'] as num).toDouble(),
      token: json['token'] as String,
      topLogprobs: (json['top_logprobs'] as List)
          .map(
            (item) =>
                ResponseOutputTopLogprob.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      extra: additionalJsonFields(json, const {
        'bytes',
        'logprob',
        'token',
        'top_logprobs',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'bytes': bytes,
    'logprob': logprob,
    'token': token,
    'top_logprobs': topLogprobs.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputTokenLogprob copyWith({
    List<int>? bytes,
    double? logprob,
    String? token,
    List<ResponseOutputTopLogprob>? topLogprobs,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputTokenLogprob(
    bytes: bytes ?? this.bytes,
    logprob: logprob ?? this.logprob,
    token: token ?? this.token,
    topLogprobs: topLogprobs ?? this.topLogprobs,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputTokenLogprob &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(bytes, other.bytes) &&
          logprob == other.logprob &&
          token == other.token &&
          valuesDeepEqual(topLogprobs, other.topLogprobs) &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(bytes),
    logprob,
    token,
    valueDeepHashCode(topLogprobs),
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseOutputTokenLogprob('
      'bytes: ${bytes.length}, '
      'logprob: $logprob, '
      'token: $token, '
      'topLogprobs: ${topLogprobs.length}, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputTextLogprobTopLogprob wire payload.
@immutable
class ResponseOutputTopLogprob {
  /// Creates a [ResponseOutputTopLogprob].
  const ResponseOutputTopLogprob({
    required this.bytes,
    required this.logprob,
    required this.token,
    this.extra,
  });

  /// The bytes field.
  final List<int> bytes;

  /// The logprob field.
  final double logprob;

  /// The token field.
  final String token;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputTopLogprob] from JSON.
  factory ResponseOutputTopLogprob.fromJson(Map<String, dynamic> json) {
    if (json['bytes'] == null) {
      throw const FormatException('ResponseOutputTopLogprob: missing bytes');
    }
    if (json['logprob'] == null) {
      throw const FormatException('ResponseOutputTopLogprob: missing logprob');
    }
    if (json['token'] == null) {
      throw const FormatException('ResponseOutputTopLogprob: missing token');
    }
    return ResponseOutputTopLogprob(
      bytes: (json['bytes'] as List).map((item) => item as int).toList(),
      logprob: (json['logprob'] as num).toDouble(),
      token: json['token'] as String,
      extra: additionalJsonFields(json, const {'bytes', 'logprob', 'token'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'bytes': bytes,
    'logprob': logprob,
    'token': token,
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputTopLogprob copyWith({
    List<int>? bytes,
    double? logprob,
    String? token,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputTopLogprob(
    bytes: bytes ?? this.bytes,
    logprob: logprob ?? this.logprob,
    token: token ?? this.token,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputTopLogprob &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(bytes, other.bytes) &&
          logprob == other.logprob &&
          token == other.token &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(bytes),
    logprob,
    token,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseOutputTopLogprob('
      'bytes: ${bytes.length}, '
      'logprob: $logprob, '
      'token: $token, '
      'extra: ${extra?.length})';
}

/// The ResponsesTextDeltaEventLogprob wire payload.
@immutable
class ResponseStreamTokenLogprob {
  /// Creates a [ResponseStreamTokenLogprob].
  const ResponseStreamTokenLogprob({
    required this.logprob,
    required this.token,
    this.topLogprobs,
    this.extra,
  });

  /// The logprob field.
  final double logprob;

  /// The token field.
  final String token;

  /// The top_logprobs field.
  final List<ResponseStreamTopLogprob>? topLogprobs;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseStreamTokenLogprob] from JSON.
  factory ResponseStreamTokenLogprob.fromJson(Map<String, dynamic> json) {
    if (json['logprob'] == null) {
      throw const FormatException(
        'ResponseStreamTokenLogprob: missing logprob',
      );
    }
    if (json['token'] == null) {
      throw const FormatException('ResponseStreamTokenLogprob: missing token');
    }
    return ResponseStreamTokenLogprob(
      logprob: (json['logprob'] as num).toDouble(),
      token: json['token'] as String,
      topLogprobs: json['top_logprobs'] == null
          ? null
          : (json['top_logprobs'] as List)
                .map(
                  (item) => ResponseStreamTopLogprob.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList(),
      extra: additionalJsonFields(json, const {
        'logprob',
        'token',
        'top_logprobs',
      }),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'logprob': logprob,
    'token': token,
    if (topLogprobs != null)
      'top_logprobs': topLogprobs!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseStreamTokenLogprob copyWith({
    double? logprob,
    String? token,
    Object? topLogprobs = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseStreamTokenLogprob(
    logprob: logprob ?? this.logprob,
    token: token ?? this.token,
    topLogprobs: topLogprobs == unsetCopyWithValue
        ? this.topLogprobs
        : (topLogprobs as List?)?.cast<ResponseStreamTopLogprob>(),
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseStreamTokenLogprob &&
          runtimeType == other.runtimeType &&
          logprob == other.logprob &&
          token == other.token &&
          valuesDeepEqual(topLogprobs, other.topLogprobs) &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    logprob,
    token,
    valueDeepHashCode(topLogprobs),
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseStreamTokenLogprob('
      'logprob: $logprob, '
      'token: $token, '
      'topLogprobs: ${topLogprobs?.length}, '
      'extra: ${extra?.length})';
}

/// The ResponsesTextDeltaEventLogprobTopLogprob wire payload.
@immutable
class ResponseStreamTopLogprob {
  /// Creates a [ResponseStreamTopLogprob].
  const ResponseStreamTopLogprob({this.logprob, this.token, this.extra});

  /// The logprob field.
  final double? logprob;

  /// The token field.
  final String? token;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseStreamTopLogprob] from JSON.
  factory ResponseStreamTopLogprob.fromJson(Map<String, dynamic> json) {
    return ResponseStreamTopLogprob(
      logprob: json['logprob'] == null
          ? null
          : (json['logprob'] as num).toDouble(),
      token: json['token'] == null ? null : json['token'] as String,
      extra: additionalJsonFields(json, const {'logprob', 'token'}),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'logprob': ?logprob,
    'token': ?token,
  };

  /// Creates a copy with the given fields replaced.
  ResponseStreamTopLogprob copyWith({
    Object? logprob = unsetCopyWithValue,
    Object? token = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseStreamTopLogprob(
    logprob: logprob == unsetCopyWithValue
        ? this.logprob
        : (logprob as num?)?.toDouble(),
    token: token == unsetCopyWithValue ? this.token : token as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseStreamTopLogprob &&
          runtimeType == other.runtimeType &&
          logprob == other.logprob &&
          token == other.token &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([logprob, token, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseStreamTopLogprob('
      'logprob: $logprob, '
      'token: $token, '
      'extra: ${extra?.length})';
}

/// The ResponsesInputImageContent wire payload.
@immutable
class ResponseFunctionImagePart extends ResponseFunctionPart {
  /// Creates a [ResponseFunctionImagePart].
  const ResponseFunctionImagePart({
    this.detail,
    this.fileId,
    this.imageUrl,
    this.promptCacheBreakpoint,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'input_image';

  /// The detail field.
  final String? detail;

  /// The file_id field.
  final String? fileId;

  /// The image_url field.
  final String? imageUrl;

  /// The prompt_cache_breakpoint field.
  final ResponsePromptCacheBreakpoint? promptCacheBreakpoint;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFunctionImagePart] from JSON.
  factory ResponseFunctionImagePart.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'input_image') {
      throw FormatException(
        'ResponseFunctionImagePart: unexpected type $value',
      );
    }
    return ResponseFunctionImagePart(
      detail: json['detail'] == null ? null : json['detail'] as String,
      fileId: json['file_id'] == null ? null : json['file_id'] as String,
      imageUrl: json['image_url'] == null ? null : json['image_url'] as String,
      promptCacheBreakpoint: json['prompt_cache_breakpoint'] == null
          ? null
          : ResponsePromptCacheBreakpoint.fromJson(
              json['prompt_cache_breakpoint'] as Map<String, dynamic>,
            ),
      extra: additionalJsonFields(json, const {
        'detail',
        'file_id',
        'image_url',
        'prompt_cache_breakpoint',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'detail': ?detail,
    'file_id': ?fileId,
    'image_url': ?imageUrl,
    if (promptCacheBreakpoint != null)
      'prompt_cache_breakpoint': promptCacheBreakpoint!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseFunctionImagePart copyWith({
    Object? detail = unsetCopyWithValue,
    Object? fileId = unsetCopyWithValue,
    Object? imageUrl = unsetCopyWithValue,
    Object? promptCacheBreakpoint = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFunctionImagePart(
    detail: detail == unsetCopyWithValue ? this.detail : detail as String?,
    fileId: fileId == unsetCopyWithValue ? this.fileId : fileId as String?,
    imageUrl: imageUrl == unsetCopyWithValue
        ? this.imageUrl
        : imageUrl as String?,
    promptCacheBreakpoint: promptCacheBreakpoint == unsetCopyWithValue
        ? this.promptCacheBreakpoint
        : promptCacheBreakpoint as ResponsePromptCacheBreakpoint?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionImagePart &&
          runtimeType == other.runtimeType &&
          detail == other.detail &&
          fileId == other.fileId &&
          imageUrl == other.imageUrl &&
          promptCacheBreakpoint == other.promptCacheBreakpoint &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    detail,
    fileId,
    imageUrl,
    promptCacheBreakpoint,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseFunctionImagePart('
      'detail: $detail, '
      'fileId: $fileId, '
      'imageUrl: $imageUrl, '
      'promptCacheBreakpoint: $promptCacheBreakpoint, '
      'extra: ${extra?.length})';
}

/// The content of a Responses input message.
///
/// [ResponseMessageText] contains plain text. [ResponseMessageParts] combines
/// text, images and files.
@immutable
sealed class ResponseMessageContent {
  const ResponseMessageContent();

  /// Creates plain text content.
  const factory ResponseMessageContent.text(String text) = ResponseMessageText;

  /// Creates multimodal content.
  const factory ResponseMessageContent.parts(List<ResponseInputPart> parts) =
      ResponseMessageParts;

  /// Parses a string or an array of input parts.
  factory ResponseMessageContent.fromJson(Object json) => switch (json) {
    final String text => ResponseMessageText(text),
    final List<Object?> parts => ResponseMessageParts(
      parts
          .map(
            (part) => ResponseInputPart.fromJson(part! as Map<String, dynamic>),
          )
          .toList(),
    ),
    _ => throw const FormatException(
      'Expected Responses message text or content parts',
    ),
  };

  /// Encodes the message content.
  Object toJson();
}

/// A Responses input message containing plain text.
@immutable
final class ResponseMessageText extends ResponseMessageContent {
  /// Creates plain text content.
  const ResponseMessageText(this.text);

  /// The input text.
  final String text;

  @override
  String toJson() => text;

  @override
  bool operator ==(Object other) =>
      other is ResponseMessageText && text == other.text;

  @override
  int get hashCode => text.hashCode;
}

/// A Responses input message containing content parts.
@immutable
final class ResponseMessageParts extends ResponseMessageContent {
  /// Creates multimodal content.
  const ResponseMessageParts(this.parts);

  /// The input parts in order.
  final List<ResponseInputPart> parts;

  @override
  List<Map<String, dynamic>> toJson() =>
      parts.map((part) => part.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      other is ResponseMessageParts && listsEqual(parts, other.parts);

  @override
  int get hashCode => listHash(parts);
}

/// Text or multimodal output from a client-executed function.
///
/// The wire variants are [ResponseFunctionOutputText] and
/// [ResponseFunctionOutputParts].
@immutable
sealed class ResponseFunctionOutput {
  const ResponseFunctionOutput();

  /// Supplies a text result.
  const factory ResponseFunctionOutput.text(String text) =
      ResponseFunctionOutputText;

  /// Supplies multimodal result parts.
  const factory ResponseFunctionOutput.parts(List<ResponseFunctionPart> parts) =
      ResponseFunctionOutputParts;

  /// Decodes a function result from its wire shape.
  factory ResponseFunctionOutput.fromJson(Object json) => switch (json) {
    final String text => ResponseFunctionOutputText(text),
    final List<Object?> parts => ResponseFunctionOutputParts(
      parts
          .map(
            (part) =>
                ResponseFunctionPart.fromJson(part! as Map<String, dynamic>),
          )
          .toList(),
    ),
    _ => throw const FormatException(
      'Expected function output text or content parts',
    ),
  };

  /// Encodes the function output.
  Object toJson();
}

/// The text result of a client-executed function.
@immutable
final class ResponseFunctionOutputText extends ResponseFunctionOutput {
  /// Creates a text result.
  const ResponseFunctionOutputText(this.text);

  /// The function result text.
  final String text;

  @override
  String toJson() => text;

  @override
  bool operator ==(Object other) =>
      other is ResponseFunctionOutputText && text == other.text;

  @override
  int get hashCode => text.hashCode;
}

/// The multimodal result of a client-executed function.
@immutable
final class ResponseFunctionOutputParts extends ResponseFunctionOutput {
  /// Creates a result with content parts.
  const ResponseFunctionOutputParts(this.parts);

  /// The result parts.
  final List<ResponseFunctionPart> parts;

  @override
  List<Map<String, dynamic>> toJson() =>
      parts.map((part) => part.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      other is ResponseFunctionOutputParts && listsEqual(parts, other.parts);

  @override
  int get hashCode => listHash(parts);
}
