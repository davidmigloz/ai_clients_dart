import 'dart:convert';

import '../copy_with_sentinel.dart';
import '../files/video_metadata.dart';
import '../tools/code_execution_result.dart';
import '../tools/executable_code.dart';
import '../tools/function_call.dart';
import '../tools/function_response.dart';
import '../tools/tool_call.dart';
import '../tools/tool_response.dart';
import '../tools/tool_type.dart';
import 'blob.dart';
import 'file_data.dart';
import 'media_resolution.dart';

/// A single unit of content (text, media, function call, etc.).
///
/// Typed data parts contain one data field plus any common metadata fields.
/// Metadata can also appear without data in a [MetadataPart]. Unrecognized or
/// ambiguous wire representations are retained as [UnknownPart].
sealed class Part {
  /// Creates a [Part].
  const Part({
    this.thought,
    this.thoughtSignature,
    this.partMetadata,
    this.mediaResolution,
    this.videoMetadata,
    this.additionalProperties = const {},
  });

  /// Whether this part represents the model's thought process or reasoning.
  final bool? thought;

  /// Opaque thought signature bytes that must be echoed back unchanged.
  final List<int>? thoughtSignature;

  /// Custom metadata associated with this part.
  final Map<String, dynamic>? partMetadata;

  /// Media resolution for this part.
  final MediaResolution? mediaResolution;

  /// Video metadata associated with this part.
  final VideoMetadata? videoMetadata;

  /// Unrecognized non-reserved fields retained for forward compatibility.
  ///
  /// Reserved Part keys are rejected by [toJson] so they cannot overwrite a
  /// typed data or metadata field.
  final Map<String, dynamic> additionalProperties;

  /// Creates a text part.
  ///
  /// Note: This factory does not include `thought` or `thoughtSignature`.
  /// When echoing model responses back, use the already-parsed [TextPart]
  /// objects rather than reconstructing via this factory.
  ///
  /// Example:
  /// ```dart
  /// final part = Part.text('Hello, world!');
  /// ```
  factory Part.text(String text) = TextPart;

  /// Creates an inline data part from raw bytes.
  ///
  /// The bytes are base64-encoded automatically.
  ///
  /// Example:
  /// ```dart
  /// final imageBytes = await File('photo.png').readAsBytes();
  /// final part = Part.bytes(imageBytes, 'image/png');
  /// ```
  factory Part.bytes(List<int> bytes, String mimeType) =>
      InlineDataPart(Blob(mimeType: mimeType, data: base64Encode(bytes)));

  /// Creates an inline data part from base64-encoded data.
  ///
  /// Example:
  /// ```dart
  /// final part = Part.base64(imageBase64, 'image/png');
  /// ```
  factory Part.base64(String data, String mimeType) =>
      InlineDataPart(Blob(mimeType: mimeType, data: data));

  /// Creates a file reference part.
  ///
  /// Use for files uploaded via the Files API.
  ///
  /// Example:
  /// ```dart
  /// final part = Part.file('files/abc123', mimeType: 'image/jpeg');
  /// ```
  factory Part.file(String fileUri, {String? mimeType}) =>
      FileDataPart(FileData(fileUri: fileUri, mimeType: mimeType));

  /// Creates a function call part.
  ///
  /// Note: This factory does not include `thoughtSignature`. When echoing
  /// model responses back, use the already-parsed [FunctionCallPart] objects
  /// rather than reconstructing via this factory.
  ///
  /// Example:
  /// ```dart
  /// final part = Part.functionCall('get_weather', args: {'city': 'SF'});
  /// ```
  factory Part.functionCall(String name, {Map<String, dynamic>? args}) =>
      FunctionCallPart(FunctionCall(name: name, args: args));

  /// Creates a function response part.
  ///
  /// Example:
  /// ```dart
  /// final part = Part.functionResponse('get_weather', {'temp': 72});
  /// ```
  factory Part.functionResponse(
    String name,
    Map<String, dynamic> response, {
    String? id,
  }) => FunctionResponsePart(
    FunctionResponse(name: name, response: response, id: id),
  );

  /// Creates a tool call part.
  ///
  /// Example:
  /// ```dart
  /// final part = Part.toolCall(ToolType.googleSearchWeb, args: {'q': 'test'});
  /// ```
  factory Part.toolCall(
    ToolType toolType, {
    Map<String, dynamic>? args,
    String? id,
  }) => ToolCallPart(ToolCall(toolType: toolType, args: args, id: id));

  /// Creates a tool response part.
  ///
  /// Example:
  /// ```dart
  /// final part = Part.toolResponse(ToolType.googleSearchWeb, response: {'results': []});
  /// ```
  factory Part.toolResponse(
    ToolType toolType, {
    Map<String, dynamic>? response,
    String? id,
  }) => ToolResponsePart(
    ToolResponse(toolType: toolType, response: response, id: id),
  );

  /// Creates a [Part] from JSON.
  factory Part.fromJson(Map<String, dynamic> json) {
    final dataKeys = _partDataKeys
        .where(json.containsKey)
        .toList(growable: false);
    if (dataKeys.length > 1) {
      return UnknownPart(json);
    }

    final additionalProperties = <String, dynamic>{
      for (final entry in json.entries)
        if (!_partReservedKeys.contains(entry.key)) entry.key: entry.value,
    };
    if (dataKeys.isEmpty && additionalProperties.isNotEmpty) {
      return UnknownPart(json);
    }

    final common = _PartCommonValues.fromJson(
      json,
      additionalProperties: additionalProperties,
    );
    if (dataKeys.isEmpty) {
      return MetadataPart(
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
      );
    }

    return switch (dataKeys.single) {
      'text' => TextPart(
        json['text'] as String,
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'inlineData' => InlineDataPart(
        Blob.fromJson(json['inlineData'] as Map<String, dynamic>),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'fileData' => FileDataPart(
        FileData.fromJson(json['fileData'] as Map<String, dynamic>),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'functionCall' => FunctionCallPart(
        FunctionCall.fromJson(json['functionCall'] as Map<String, dynamic>),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'functionResponse' => FunctionResponsePart(
        FunctionResponse.fromJson(
          json['functionResponse'] as Map<String, dynamic>,
        ),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'executableCode' => ExecutableCodePart(
        ExecutableCode.fromJson(json['executableCode'] as Map<String, dynamic>),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'codeExecutionResult' => CodeExecutionResultPart(
        CodeExecutionResult.fromJson(
          json['codeExecutionResult'] as Map<String, dynamic>,
        ),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'toolCall' => ToolCallPart(
        ToolCall.fromJson(json['toolCall'] as Map<String, dynamic>),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      'toolResponse' => ToolResponsePart(
        ToolResponse.fromJson(json['toolResponse'] as Map<String, dynamic>),
        thought: common.thought,
        thoughtSignature: common.thoughtSignature,
        partMetadata: common.partMetadata,
        mediaResolution: common.mediaResolution,
        videoMetadata: common.videoMetadata,
        additionalProperties: common.additionalProperties,
      ),
      final key => throw StateError('Unhandled Part data key: $key'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  Map<String, dynamic> _commonFieldsToJson() {
    final collisions = additionalProperties.keys
        .where(_partReservedKeys.contains)
        .toList(growable: false);
    if (collisions.isNotEmpty) {
      throw ArgumentError.value(
        additionalProperties,
        'additionalProperties',
        'Contains reserved Part keys: ${collisions.join(', ')}',
      );
    }
    return {
      ...additionalProperties,
      if (thought != null) 'thought': thought,
      if (thoughtSignature != null)
        'thoughtSignature': base64Encode(thoughtSignature!),
      if (partMetadata != null) 'partMetadata': partMetadata,
      if (mediaResolution != null) 'mediaResolution': mediaResolution!.toJson(),
      if (videoMetadata != null) 'videoMetadata': videoMetadata!.toJson(),
    };
  }

  Map<String, dynamic> _dataToJson(String key, Object? value) => {
    key: value,
    ..._commonFieldsToJson(),
  };

  _PartCommonValues _copyCommon({
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) => _PartCommonValues(
    thought: thought == unsetCopyWithValue ? this.thought : thought as bool?,
    thoughtSignature: thoughtSignature == unsetCopyWithValue
        ? this.thoughtSignature
        : thoughtSignature as List<int>?,
    partMetadata: partMetadata == unsetCopyWithValue
        ? this.partMetadata
        : partMetadata as Map<String, dynamic>?,
    mediaResolution: mediaResolution == unsetCopyWithValue
        ? this.mediaResolution
        : mediaResolution as MediaResolution?,
    videoMetadata: videoMetadata == unsetCopyWithValue
        ? this.videoMetadata
        : videoMetadata as VideoMetadata?,
    additionalProperties: additionalProperties == unsetCopyWithValue
        ? this.additionalProperties
        : additionalProperties! as Map<String, dynamic>,
  );
}

const _partDataKeys = <String>{
  'text',
  'inlineData',
  'fileData',
  'functionCall',
  'functionResponse',
  'executableCode',
  'codeExecutionResult',
  'toolCall',
  'toolResponse',
};

const _partCommonKeys = <String>{
  'thought',
  'thoughtSignature',
  'partMetadata',
  'mediaResolution',
  'videoMetadata',
};

const _partReservedKeys = <String>{..._partDataKeys, ..._partCommonKeys};

class _PartCommonValues {
  const _PartCommonValues({
    this.thought,
    this.thoughtSignature,
    this.partMetadata,
    this.mediaResolution,
    this.videoMetadata,
    this.additionalProperties = const {},
  });

  factory _PartCommonValues.fromJson(
    Map<String, dynamic> json, {
    required Map<String, dynamic> additionalProperties,
  }) => _PartCommonValues(
    thought: json['thought'] as bool?,
    thoughtSignature: json['thoughtSignature'] == null
        ? null
        : base64Decode(json['thoughtSignature'] as String),
    partMetadata: json['partMetadata'] as Map<String, dynamic>?,
    mediaResolution: json['mediaResolution'] == null
        ? null
        : MediaResolution.fromJson(
            json['mediaResolution'] as Map<String, dynamic>,
          ),
    videoMetadata: json['videoMetadata'] == null
        ? null
        : VideoMetadata.fromJson(json['videoMetadata'] as Map<String, dynamic>),
    additionalProperties: additionalProperties,
  );

  final bool? thought;
  final List<int>? thoughtSignature;
  final Map<String, dynamic>? partMetadata;
  final MediaResolution? mediaResolution;
  final VideoMetadata? videoMetadata;
  final Map<String, dynamic> additionalProperties;
}

/// Text content.
class TextPart extends Part {
  /// Plain text content.
  final String text;

  /// Creates a [TextPart].
  const TextPart(
    this.text, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() => _dataToJson('text', text);

  /// Creates a copy with replaced values.
  TextPart copyWith({
    Object? text = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return TextPart(
      text == unsetCopyWithValue ? this.text : text! as String,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Inline binary data (base64).
class InlineDataPart extends Part {
  /// Inline binary data.
  final Blob inlineData;

  /// Creates an [InlineDataPart].
  const InlineDataPart(
    this.inlineData, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() =>
      _dataToJson('inlineData', inlineData.toJson());

  /// Creates a copy with replaced values.
  InlineDataPart copyWith({
    Object? inlineData = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return InlineDataPart(
      inlineData == unsetCopyWithValue ? this.inlineData : inlineData! as Blob,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Reference to uploaded file.
class FileDataPart extends Part {
  /// File reference.
  final FileData fileData;

  /// Creates a [FileDataPart].
  const FileDataPart(
    this.fileData, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() => _dataToJson('fileData', fileData.toJson());

  /// Creates a copy with replaced values.
  FileDataPart copyWith({
    Object? fileData = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return FileDataPart(
      fileData == unsetCopyWithValue ? this.fileData : fileData! as FileData,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Model's request to call a function.
class FunctionCallPart extends Part {
  /// Function call.
  final FunctionCall functionCall;

  /// Creates a [FunctionCallPart].
  const FunctionCallPart(
    this.functionCall, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() =>
      _dataToJson('functionCall', functionCall.toJson());

  /// Creates a copy with replaced values.
  FunctionCallPart copyWith({
    Object? functionCall = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return FunctionCallPart(
      functionCall == unsetCopyWithValue
          ? this.functionCall
          : functionCall! as FunctionCall,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Result from function execution.
class FunctionResponsePart extends Part {
  /// Function response.
  final FunctionResponse functionResponse;

  /// Creates a [FunctionResponsePart].
  const FunctionResponsePart(
    this.functionResponse, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() =>
      _dataToJson('functionResponse', functionResponse.toJson());

  /// Creates a copy with replaced values.
  FunctionResponsePart copyWith({
    Object? functionResponse = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return FunctionResponsePart(
      functionResponse == unsetCopyWithValue
          ? this.functionResponse
          : functionResponse! as FunctionResponse,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Code for model to execute.
class ExecutableCodePart extends Part {
  /// Executable code.
  final ExecutableCode executableCode;

  /// Creates an [ExecutableCodePart].
  const ExecutableCodePart(
    this.executableCode, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() =>
      _dataToJson('executableCode', executableCode.toJson());

  /// Creates a copy with replaced values.
  ExecutableCodePart copyWith({
    Object? executableCode = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return ExecutableCodePart(
      executableCode == unsetCopyWithValue
          ? this.executableCode
          : executableCode! as ExecutableCode,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Result from code execution.
class CodeExecutionResultPart extends Part {
  /// Code execution result.
  final CodeExecutionResult codeExecutionResult;

  /// Creates a [CodeExecutionResultPart].
  const CodeExecutionResultPart(
    this.codeExecutionResult, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() =>
      _dataToJson('codeExecutionResult', codeExecutionResult.toJson());

  /// Creates a copy with replaced values.
  CodeExecutionResultPart copyWith({
    Object? codeExecutionResult = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return CodeExecutionResultPart(
      codeExecutionResult == unsetCopyWithValue
          ? this.codeExecutionResult
          : codeExecutionResult! as CodeExecutionResult,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// A Part containing metadata without a data field.
class MetadataPart extends Part {
  /// Creates a [MetadataPart].
  const MetadataPart({
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
  });

  @override
  Map<String, dynamic> toJson() => _commonFieldsToJson();

  /// Creates a copy with replaced values.
  MetadataPart copyWith({
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
    );
    return MetadataPart(
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
    );
  }
}

/// An unrecognized or structurally ambiguous Part.
///
/// The original JSON is retained so future API variants can be echoed back
/// without data loss before this client adds a typed representation.
class UnknownPart extends Part {
  /// Creates an [UnknownPart] retaining [rawJson].
  UnknownPart(Map<String, dynamic> rawJson)
    : rawJson = Map.unmodifiable(rawJson);

  /// The original JSON representation.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(rawJson);
}

/// Video timing/sampling metadata.
@Deprecated('Use MetadataPart(videoMetadata: ...) instead.')
class VideoMetadataPart extends Part {
  /// Creates a [VideoMetadataPart].
  @Deprecated('Use MetadataPart(videoMetadata: ...) instead.')
  const VideoMetadataPart(VideoMetadata videoMetadata)
    : super(videoMetadata: videoMetadata);

  @override
  VideoMetadata get videoMetadata => super.videoMetadata!;

  @override
  Map<String, dynamic> toJson() => _commonFieldsToJson();

  /// Creates a copy with replaced values.
  VideoMetadataPart copyWith({Object? videoMetadata = unsetCopyWithValue}) {
    return VideoMetadataPart(
      videoMetadata == unsetCopyWithValue
          ? this.videoMetadata
          : videoMetadata! as VideoMetadata,
    );
  }
}

/// Reasoning step indicator.
@Deprecated('Use MetadataPart(thought: ...) instead.')
class ThoughtPart extends Part {
  /// Creates a [ThoughtPart].
  @Deprecated('Use MetadataPart(thought: ...) instead.')
  // The explicit parameters keep the deprecated constructor's non-null API.
  // ignore: use_super_parameters
  const ThoughtPart({required bool thought, List<int>? thoughtSignature})
    : super(thought: thought, thoughtSignature: thoughtSignature);

  @override
  bool get thought => super.thought!;

  @override
  Map<String, dynamic> toJson() => _commonFieldsToJson();

  /// Creates a copy with replaced values.
  ThoughtPart copyWith({
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
  }) {
    return ThoughtPart(
      thought: thought == unsetCopyWithValue ? this.thought : thought! as bool,
      thoughtSignature: thoughtSignature == unsetCopyWithValue
          ? this.thoughtSignature
          : thoughtSignature as List<int>?,
    );
  }
}

/// Cached thought key (base64).
@Deprecated('Use MetadataPart(thoughtSignature: ...) instead.')
class ThoughtSignaturePart extends Part {
  /// Creates a [ThoughtSignaturePart].
  @Deprecated('Use MetadataPart(thoughtSignature: ...) instead.')
  const ThoughtSignaturePart(List<int> thoughtSignature)
    : super(thoughtSignature: thoughtSignature);

  @override
  List<int> get thoughtSignature => super.thoughtSignature!;

  @override
  Map<String, dynamic> toJson() => _commonFieldsToJson();

  /// Creates a copy with replaced values.
  ThoughtSignaturePart copyWith({
    Object? thoughtSignature = unsetCopyWithValue,
  }) {
    return ThoughtSignaturePart(
      thoughtSignature == unsetCopyWithValue
          ? this.thoughtSignature
          : thoughtSignature! as List<int>,
    );
  }
}

/// Server-side tool call.
class ToolCallPart extends Part {
  /// Tool call.
  final ToolCall toolCall;

  /// Creates a [ToolCallPart].
  const ToolCallPart(
    this.toolCall, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() => _dataToJson('toolCall', toolCall.toJson());

  /// Creates a copy with replaced values.
  ToolCallPart copyWith({
    Object? toolCall = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return ToolCallPart(
      toolCall == unsetCopyWithValue ? this.toolCall : toolCall! as ToolCall,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Server-side tool response.
class ToolResponsePart extends Part {
  /// Tool response.
  final ToolResponse toolResponse;

  /// Creates a [ToolResponsePart].
  const ToolResponsePart(
    this.toolResponse, {
    super.thought,
    super.thoughtSignature,
    super.partMetadata,
    super.mediaResolution,
    super.videoMetadata,
    super.additionalProperties,
  });

  @override
  Map<String, dynamic> toJson() =>
      _dataToJson('toolResponse', toolResponse.toJson());

  /// Creates a copy with replaced values.
  ToolResponsePart copyWith({
    Object? toolResponse = unsetCopyWithValue,
    Object? thought = unsetCopyWithValue,
    Object? thoughtSignature = unsetCopyWithValue,
    Object? partMetadata = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    final common = _copyCommon(
      thought: thought,
      thoughtSignature: thoughtSignature,
      partMetadata: partMetadata,
      mediaResolution: mediaResolution,
      videoMetadata: videoMetadata,
      additionalProperties: additionalProperties,
    );
    return ToolResponsePart(
      toolResponse == unsetCopyWithValue
          ? this.toolResponse
          : toolResponse! as ToolResponse,
      thought: common.thought,
      thoughtSignature: common.thoughtSignature,
      partMetadata: common.partMetadata,
      mediaResolution: common.mediaResolution,
      videoMetadata: common.videoMetadata,
      additionalProperties: common.additionalProperties,
    );
  }
}

/// Custom metadata.
@Deprecated('Use MetadataPart(partMetadata: ...) instead.')
class PartMetadataPart extends Part {
  /// Creates a [PartMetadataPart].
  @Deprecated('Use MetadataPart(partMetadata: ...) instead.')
  const PartMetadataPart(Map<String, dynamic> partMetadata)
    : super(partMetadata: partMetadata);

  @override
  Map<String, dynamic> get partMetadata => super.partMetadata!;

  @override
  Map<String, dynamic> toJson() => _commonFieldsToJson();

  /// Creates a copy with replaced values.
  PartMetadataPart copyWith({Object? partMetadata = unsetCopyWithValue}) {
    return PartMetadataPart(
      partMetadata == unsetCopyWithValue
          ? this.partMetadata
          : partMetadata! as Map<String, dynamic>,
    );
  }
}
