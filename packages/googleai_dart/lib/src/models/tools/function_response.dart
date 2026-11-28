import '../content/file_data.dart';
import '../content/media_metadata.dart';
import '../content/media_resolution.dart';
import '../content/media_wire_options.dart';
import '../copy_with_sentinel.dart';
import '../files/video_metadata.dart';

/// Scheduling options for function responses.
enum FunctionResponseScheduling {
  /// Unspecified scheduling.
  schedulingUnspecified,

  /// Only add the result to the conversation context, do not interrupt or
  /// trigger generation.
  silent,

  /// Add the result to the conversation context, and prompt to generate output
  /// without interrupting ongoing generation.
  whenIdle,

  /// Add the result to the conversation context, interrupt ongoing generation
  /// and prompt to generate output.
  interrupt;

  /// Creates a [FunctionResponseScheduling] from JSON.
  factory FunctionResponseScheduling.fromJson(String value) => switch (value) {
    'SCHEDULING_UNSPECIFIED' => schedulingUnspecified,
    'SILENT' => silent,
    'WHEN_IDLE' => whenIdle,
    'INTERRUPT' => interrupt,
    _ => throw FormatException('Unknown FunctionResponseScheduling: $value'),
  };

  /// Converts to JSON.
  String toJson() => switch (this) {
    schedulingUnspecified => 'SCHEDULING_UNSPECIFIED',
    silent => 'SILENT',
    whenIdle => 'WHEN_IDLE',
    interrupt => 'INTERRUPT',
  };
}

/// Raw media bytes for function response.
class FunctionResponseBlob {
  /// The IANA standard MIME type of the source data.
  final String? mimeType;

  /// Raw bytes for media formats (base64 encoded).
  final String? data;

  /// Display name on API surfaces that accept media labels.
  final String? displayName;

  /// Creates a [FunctionResponseBlob].
  const FunctionResponseBlob({this.mimeType, this.data, this.displayName});

  /// Creates a [FunctionResponseBlob] from JSON.
  factory FunctionResponseBlob.fromJson(Map<String, dynamic> json) =>
      FunctionResponseBlob(
        mimeType: json['mimeType'] as String?,
        data: json['data'] as String?,
        displayName: json['displayName'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (mimeType != null) 'mimeType': mimeType,
    if (data != null) 'data': data,
    if (displayName != null) 'displayName': displayName,
  };

  /// Creates a copy with replaced values.
  FunctionResponseBlob copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? data = unsetCopyWithValue,
    Object? displayName = unsetCopyWithValue,
  }) {
    return FunctionResponseBlob(
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as String?,
      data: data == unsetCopyWithValue ? this.data : data as String?,
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
    );
  }
}

/// An inline or URI-based media item in a function result.
class FunctionResponseInlinePart {
  /// Inline media bytes.
  final FunctionResponseBlob? inlineData;

  /// URI-based media. Supply a MIME type for function results.
  final FileData? fileData;

  /// Media resolution for input media.
  final MediaResolution? mediaResolution;

  /// Video interpretation approach on the Gemini Developer API.
  final MediaProcessing? mediaProcessing;

  /// Video clipping, sampling, and extraction options.
  final VideoMetadata? videoMetadata;

  /// Audio clipping options.
  final AudioMetadata? audioMetadata;

  /// Document page and extraction options.
  final DocumentMetadata? documentMetadata;

  /// Spreadsheet cell and extraction options.
  final SpreadsheetMetadata? spreadsheetMetadata;

  /// Creates a [FunctionResponseInlinePart].
  const FunctionResponseInlinePart({
    this.inlineData,
    this.fileData,
    this.mediaResolution,
    this.mediaProcessing,
    this.videoMetadata,
    this.audioMetadata,
    this.documentMetadata,
    this.spreadsheetMetadata,
  }) : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const FunctionResponseInlinePart._({
    this.inlineData,
    this.fileData,
    this.mediaResolution,
    this.mediaProcessing,
    this.videoMetadata,
    this.audioMetadata,
    this.documentMetadata,
    this.spreadsheetMetadata,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory FunctionResponseInlinePart.fromJson(Map<String, dynamic> json) {
    final wireExtensions = <String, dynamic>{};
    return FunctionResponseInlinePart._(
      inlineData: json['inlineData'] == null
          ? null
          : FunctionResponseBlob.fromJson(
              json['inlineData'] as Map<String, dynamic>,
            ),
      fileData: decodeMediaOption(
        json,
        'fileData',
        wireExtensions,
        (value) => FileData.fromJson(value as Map<String, dynamic>),
      ),
      mediaResolution: decodeMediaOption(
        json,
        'mediaResolution',
        wireExtensions,
        (value) => MediaResolution.fromJson(value as Map<String, dynamic>),
      ),
      mediaProcessing: decodeMediaOption(
        json,
        'mediaProcessing',
        wireExtensions,
        (value) => MediaProcessing.fromJson(value as String),
      ),
      videoMetadata: decodeMediaOption(
        json,
        'videoMetadata',
        wireExtensions,
        (value) => VideoMetadata.fromJson(value as Map<String, dynamic>),
      ),
      audioMetadata: decodeMediaOption(
        json,
        'audioMetadata',
        wireExtensions,
        (value) => AudioMetadata.fromJson(value as Map<String, dynamic>),
      ),
      documentMetadata: decodeMediaOption(
        json,
        'documentMetadata',
        wireExtensions,
        (value) => DocumentMetadata.fromJson(value as Map<String, dynamic>),
      ),
      spreadsheetMetadata: decodeMediaOption(
        json,
        'spreadsheetMetadata',
        wireExtensions,
        (value) => SpreadsheetMetadata.fromJson(value as Map<String, dynamic>),
      ),
      wireExtensions: wireExtensions,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    if (inlineData != null) 'inlineData': inlineData!.toJson(),
    if (fileData != null) 'fileData': fileData!.toJson(),
    if (mediaResolution != null) 'mediaResolution': mediaResolution!.toJson(),
    if (mediaProcessing != null) 'mediaProcessing': mediaProcessing!.toJson(),
    if (videoMetadata != null) 'videoMetadata': videoMetadata!.toJson(),
    if (audioMetadata != null) 'audioMetadata': audioMetadata!.toJson(),
    if (documentMetadata != null)
      'documentMetadata': documentMetadata!.toJson(),
    if (spreadsheetMetadata != null)
      'spreadsheetMetadata': spreadsheetMetadata!.toJson(),
  };

  /// Creates a copy with replaced values.
  FunctionResponseInlinePart copyWith({
    Object? inlineData = unsetCopyWithValue,
    Object? fileData = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? mediaProcessing = unsetCopyWithValue,
    Object? videoMetadata = unsetCopyWithValue,
    Object? audioMetadata = unsetCopyWithValue,
    Object? documentMetadata = unsetCopyWithValue,
    Object? spreadsheetMetadata = unsetCopyWithValue,
  }) => FunctionResponseInlinePart._(
    inlineData: inlineData == unsetCopyWithValue
        ? this.inlineData
        : inlineData as FunctionResponseBlob?,
    fileData: fileData == unsetCopyWithValue
        ? this.fileData
        : fileData as FileData?,
    mediaResolution: mediaResolution == unsetCopyWithValue
        ? this.mediaResolution
        : mediaResolution as MediaResolution?,
    mediaProcessing: mediaProcessing == unsetCopyWithValue
        ? this.mediaProcessing
        : mediaProcessing as MediaProcessing?,
    videoMetadata: videoMetadata == unsetCopyWithValue
        ? this.videoMetadata
        : videoMetadata as VideoMetadata?,
    audioMetadata: audioMetadata == unsetCopyWithValue
        ? this.audioMetadata
        : audioMetadata as AudioMetadata?,
    documentMetadata: documentMetadata == unsetCopyWithValue
        ? this.documentMetadata
        : documentMetadata as DocumentMetadata?,
    spreadsheetMetadata: spreadsheetMetadata == unsetCopyWithValue
        ? this.spreadsheetMetadata
        : spreadsheetMetadata as SpreadsheetMetadata?,
    wireExtensions: Map.of(_wireExtensions)
      ..removeWhere(
        (key, _) => switch (key) {
          'fileData' => fileData != unsetCopyWithValue,
          'mediaResolution' => mediaResolution != unsetCopyWithValue,
          'mediaProcessing' => mediaProcessing != unsetCopyWithValue,
          'videoMetadata' => videoMetadata != unsetCopyWithValue,
          'audioMetadata' => audioMetadata != unsetCopyWithValue,
          'documentMetadata' => documentMetadata != unsetCopyWithValue,
          'spreadsheetMetadata' => spreadsheetMetadata != unsetCopyWithValue,
          _ => false,
        },
      ),
  );
}

/// The result output from a function call.
class FunctionResponse {
  /// Optional ID of the function call this response is for.
  ///
  /// Used in Live API sessions to correlate responses with the original
  /// function call requests. Should match the [FunctionCall.id] of the
  /// call being responded to.
  final String? id;

  /// The name of the function that was called.
  final String name;

  /// The function response.
  final Map<String, dynamic> response;

  /// Ordered parts that constitute the function response.
  final List<FunctionResponseInlinePart>? parts;

  /// Signals that the function call will produce more results.
  ///
  /// Vertex AI Live expects a single complete response for each call.
  final bool? willContinue;

  /// Specifies how the response should be scheduled in the conversation.
  final FunctionResponseScheduling? scheduling;

  /// Creates a [FunctionResponse].
  const FunctionResponse({
    this.id,
    required this.name,
    required this.response,
    this.parts,
    this.willContinue,
    this.scheduling,
  });

  /// Creates a [FunctionResponse] from JSON.
  factory FunctionResponse.fromJson(Map<String, dynamic> json) =>
      FunctionResponse(
        id: json['id'] as String?,
        name: json['name'] as String,
        response: json['response'] as Map<String, dynamic>,
        parts: (json['parts'] as List?)
            ?.map(
              (e) => FunctionResponseInlinePart.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
        willContinue: json['willContinue'] as bool?,
        scheduling: json['scheduling'] != null
            ? FunctionResponseScheduling.fromJson(json['scheduling'] as String)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'response': response,
    if (parts != null) 'parts': parts!.map((e) => e.toJson()).toList(),
    if (willContinue != null) 'willContinue': willContinue,
    if (scheduling != null) 'scheduling': scheduling!.toJson(),
  };

  /// Creates a copy with replaced values.
  FunctionResponse copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? response = unsetCopyWithValue,
    Object? parts = unsetCopyWithValue,
    Object? willContinue = unsetCopyWithValue,
    Object? scheduling = unsetCopyWithValue,
  }) {
    return FunctionResponse(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      name: name == unsetCopyWithValue ? this.name : name! as String,
      response: response == unsetCopyWithValue
          ? this.response
          : response! as Map<String, dynamic>,
      parts: parts == unsetCopyWithValue
          ? this.parts
          : parts as List<FunctionResponseInlinePart>?,
      willContinue: willContinue == unsetCopyWithValue
          ? this.willContinue
          : willContinue as bool?,
      scheduling: scheduling == unsetCopyWithValue
          ? this.scheduling
          : scheduling as FunctionResponseScheduling?,
    );
  }
}
