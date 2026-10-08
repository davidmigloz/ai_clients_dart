import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'audio_json_helpers.dart';

/// A multipart upload of an original voice consent recording.
///
/// [name] and [language] are open strings. The service validates the consent
/// phrase and project eligibility. This request preserves the recording bytes
/// and filename, and does not record, transcode, or enroll a voice.
@immutable
final class VoiceConsentCreateRequest {
  /// Creates an upload with an immutable snapshot of [recording].
  ///
  /// A supported [recordingContentType] is normalized to its base MIME type,
  /// removing browser recorder parameters such as `codecs=opus`. When omitted,
  /// the MIME type is inferred from a recognized filename extension. Other
  /// filenames require an explicit supported MIME type.
  VoiceConsentCreateRequest({
    required this.name,
    required Uint8List recording,
    required this.filename,
    required this.language,
    String? recordingContentType,
  }) : recording = _snapshotRecording(recording),
       recordingContentType = _normalizeRecordingContentType(
         recordingContentType,
       ) {
    validate();
  }

  /// Maximum recording size in bytes: 10 MiB.
  static const int maxRecordingBytes = 10 * 1024 * 1024;

  /// Label for this consent recording; no local grammar or length restriction.
  final String name;

  /// Immutable original audio bytes, including the exact provided view range.
  final Uint8List recording;

  /// Filename metadata for the recording part, preserved verbatim.
  final String filename;

  /// The consent phrase's open BCP 47 language tag.
  final String language;

  /// Optional normalized MIME metadata, separate from the API's form fields.
  ///
  /// Remains null when omitted. [effectiveRecordingContentType] provides the
  /// inferred value used for multipart upload.
  final String? recordingContentType;

  /// Supported base MIME type used for the recording part.
  String get effectiveRecordingContentType {
    if (recordingContentType != null) return recordingContentType!;
    final extensionStart = filename.lastIndexOf('.');
    final extension = extensionStart < 0
        ? null
        : filename.substring(extensionStart + 1).toLowerCase();
    final inferred = _recordingMimeExtensions[extension];
    if (inferred == null) {
      throw const FormatException(
        'VoiceConsentCreateRequest.recordingContentType: '
        'provide a supported audio MIME type for an unrecognized filename extension',
      );
    }
    return inferred;
  }

  /// Validates upload admission before authentication or multipart dispatch.
  void validate() {
    if (recording.length > maxRecordingBytes) {
      throw const FormatException(
        'VoiceConsentCreateRequest.recording: maximum size is 10 MiB',
      );
    }
    if (!_recordingMimeTypes.contains(effectiveRecordingContentType)) {
      throw const FormatException(
        'VoiceConsentCreateRequest.recordingContentType: '
        'unsupported audio MIME type',
      );
    }
  }

  /// Copies every upload field; explicit null clears supplied MIME metadata.
  VoiceConsentCreateRequest copyWith({
    String? name,
    Uint8List? recording,
    String? filename,
    String? language,
    Object? recordingContentType = unsetCopyWithValue,
  }) => VoiceConsentCreateRequest(
    name: name ?? this.name,
    recording: recording ?? this.recording,
    filename: filename ?? this.filename,
    language: language ?? this.language,
    recordingContentType: identical(recordingContentType, unsetCopyWithValue)
        ? this.recordingContentType
        : _nullableConsentString(
            recordingContentType,
            'VoiceConsentCreateRequest.recordingContentType',
          ),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceConsentCreateRequest &&
          name == other.name &&
          listsEqual(recording, other.recording) &&
          filename == other.filename &&
          language == other.language &&
          recordingContentType == other.recordingContentType;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    listHash(recording),
    filename,
    language,
    recordingContentType,
  );

  @override
  String toString() =>
      'VoiceConsentCreateRequest(name: [REDACTED], '
      'recording: ${recording.length} bytes, filename: [REDACTED], '
      'language: [REDACTED], '
      'recordingContentType: ${audioPresence(recordingContentType)})';
}

/// Closed writable metadata update for a voice consent recording.
@immutable
final class VoiceConsentUpdateRequest {
  /// Creates a rename update with its required open label.
  const VoiceConsentUpdateRequest({required this.name});

  /// Parses exactly the writable `name` field.
  ///
  /// Response metadata and future receive-only extras are rejected.
  factory VoiceConsentUpdateRequest.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(
      json,
      'VoiceConsentUpdateRequest',
      knownKeys: const {'name'},
    );
    requireClosedAudioJson(snapshot, const {
      'name',
    }, 'VoiceConsentUpdateRequest');
    return VoiceConsentUpdateRequest(
      name: requireJsonString(
        snapshot['name'],
        'VoiceConsentUpdateRequest.name',
      ),
    );
  }

  /// Updated label; no local grammar or length restriction.
  final String name;

  /// Serializes the required name into the closed JSON request body.
  Map<String, dynamic> toJson() => {'name': name};

  /// Copies the required name.
  VoiceConsentUpdateRequest copyWith({String? name}) =>
      VoiceConsentUpdateRequest(name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceConsentUpdateRequest && name == other.name;

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @override
  String toString() => 'VoiceConsentUpdateRequest(name: [REDACTED])';
}

/// Metadata for a voice consent recording.
///
/// The canonical response schema is closed. This receive-only model preserves
/// finite future JSON as a deeply immutable snapshot in [rawJson]. Known typed
/// fields remain authoritative, and future metadata is never writable request
/// content.
@immutable
final class VoiceConsent {
  /// Creates consent metadata with an immutable raw JSON snapshot.
  VoiceConsent({
    required this.id,
    required this.name,
    required this.language,
    required this.createdAt,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'VoiceConsent',
         knownKeys: _fields,
       ) {
    requireAudioInt(createdAt, 'VoiceConsent.created_at');
  }

  static const Set<String> _fields = {
    'object',
    'id',
    'name',
    'language',
    'created_at',
  };

  /// Parses every required canonical field with value-safe diagnostics.
  factory VoiceConsent.fromJson(Map<String, dynamic> json) =>
      VoiceConsent._fromJson(json, 'VoiceConsent');

  factory VoiceConsent._fromJson(Map<String, dynamic> json, String context) {
    final snapshot = snapshotAudioJson(json, context, knownKeys: _fields);
    _requireConsentObject(snapshot, 'audio.voice_consent', context);
    return VoiceConsent(
      id: requireJsonString(snapshot['id'], '$context.id'),
      name: requireJsonString(snapshot['name'], '$context.name'),
      language: requireJsonString(snapshot['language'], '$context.language'),
      createdAt: requireAudioInt(snapshot['created_at'], '$context.created_at'),
      rawJson: snapshot,
    );
  }

  /// Fixed canonical object discriminator.
  String get object => 'audio.voice_consent';

  /// Opaque consent recording identifier.
  final String id;

  /// Label provided when the recording was uploaded.
  final String name;

  /// Open BCP 47 language tag for the consent phrase.
  final String language;

  /// Unix timestamp in seconds when the recording was created.
  final int createdAt;

  /// Original deeply immutable received JSON, including future metadata.
  final Map<String, dynamic> rawJson;

  /// Serializes known typed values and immutable receive-only future metadata.
  Map<String, dynamic> toJson() => mergeAudioJson(rawJson, _fields, {
    'object': object,
    'id': id,
    'name': name,
    'language': language,
    'created_at': createdAt,
  });

  /// Copies all fields; an empty raw map clears received future metadata.
  VoiceConsent copyWith({
    String? id,
    String? name,
    String? language,
    int? createdAt,
    Map<String, dynamic>? rawJson,
  }) => VoiceConsent(
    id: id ?? this.id,
    name: name ?? this.name,
    language: language ?? this.language,
    createdAt: createdAt ?? this.createdAt,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceConsent && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'VoiceConsent(object: $object, id: [REDACTED], name: [REDACTED], '
      'language: [REDACTED], createdAt: [REDACTED], '
      'rawJson: ${rawJson.length} entries)';
}

/// One explicit page of voice consent recordings.
///
/// The canonical response schema is closed; this receive-only model preserves
/// immutable future metadata. Cursor omission, explicit null, and string values
/// remain distinct, without inferring cursors from [data].
@immutable
final class VoiceConsentList {
  /// Creates a page with owned data and JSON snapshots.
  ///
  /// Set [hasFirstId] or [hasLastId] to preserve an explicit null cursor. A
  /// nonnull cursor always marks its field present.
  VoiceConsentList({
    required List<VoiceConsent> data,
    required this.hasMore,
    this.firstId,
    this.lastId,
    bool hasFirstId = false,
    bool hasLastId = false,
    Map<String, dynamic> rawJson = const {},
  }) : data = List<VoiceConsent>.unmodifiable(data),
       hasFirstId = hasFirstId || firstId != null,
       hasLastId = hasLastId || lastId != null,
       rawJson = snapshotAudioJson(
         rawJson,
         'VoiceConsentList',
         knownKeys: _fields,
       );

  static const Set<String> _fields = {
    'object',
    'data',
    'has_more',
    'first_id',
    'last_id',
  };

  /// Parses required fields and exact optional nullable cursor presence.
  factory VoiceConsentList.fromJson(Map<String, dynamic> json) {
    _requireConsentObject(json, 'list', 'VoiceConsentList');
    // Parse each child first to keep known malformed child fields contextual.
    final data = _parseConsents(json['data']);
    final hasMore = _requireConsentBool(
      json['has_more'],
      'VoiceConsentList.has_more',
    );
    final firstId = optionalJsonString(
      json,
      'first_id',
      'VoiceConsentList',
      nullable: true,
    );
    final lastId = optionalJsonString(
      json,
      'last_id',
      'VoiceConsentList',
      nullable: true,
    );
    return VoiceConsentList(
      data: data,
      hasMore: hasMore,
      firstId: firstId,
      lastId: lastId,
      hasFirstId: json.containsKey('first_id'),
      hasLastId: json.containsKey('last_id'),
      rawJson: json,
    );
  }

  /// Fixed canonical object discriminator.
  String get object => 'list';

  /// Recordings in this page, with immutable list ownership.
  final List<VoiceConsent> data;

  /// Whether another page is available.
  final bool hasMore;

  /// Nullable first cursor when present; never inferred from the recordings.
  final String? firstId;

  /// Nullable last cursor when present; never inferred from the recordings.
  final String? lastId;

  /// Whether the `first_id` key is present, including explicit null.
  final bool hasFirstId;

  /// Whether the `last_id` key is present, including explicit null.
  final bool hasLastId;

  /// Original deeply immutable received JSON, including future metadata.
  final Map<String, dynamic> rawJson;

  /// Serializes known fields, exact cursor presence, and future metadata.
  Map<String, dynamic> toJson() => mergeAudioJson(rawJson, _fields, {
    'object': object,
    'data': data.map((consent) => consent.toJson()).toList(),
    'has_more': hasMore,
    if (hasFirstId) 'first_id': firstId,
    if (hasLastId) 'last_id': lastId,
  });

  /// Copies every field with independent cursor null and omission control.
  ///
  /// Explicit `firstId: null` or `lastId: null` emits null. Also set the matching
  /// presence flag to false to omit that cursor. Replacing [data] uses the new
  /// children's complete JSON, discarding stale child metadata from [rawJson].
  VoiceConsentList copyWith({
    List<VoiceConsent>? data,
    bool? hasMore,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasFirstId,
    bool? hasLastId,
    Map<String, dynamic>? rawJson,
  }) => VoiceConsentList(
    data: data ?? this.data,
    hasMore: hasMore ?? this.hasMore,
    firstId: identical(firstId, unsetCopyWithValue)
        ? this.firstId
        : _nullableConsentString(firstId, 'VoiceConsentList.first_id'),
    lastId: identical(lastId, unsetCopyWithValue)
        ? this.lastId
        : _nullableConsentString(lastId, 'VoiceConsentList.last_id'),
    hasFirstId:
        hasFirstId ??
        (!identical(firstId, unsetCopyWithValue) || this.hasFirstId),
    hasLastId:
        hasLastId ?? (!identical(lastId, unsetCopyWithValue) || this.hasLastId),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceConsentList && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'VoiceConsentList(object: $object, data: ${data.length} items, '
      'hasMore: $hasMore, firstId: ${audioPresence(firstId)}, '
      'lastId: ${audioPresence(lastId)}, hasFirstId: $hasFirstId, '
      'hasLastId: $hasLastId, rawJson: ${rawJson.length} entries)';
}

/// Result of an explicit voice consent deletion.
///
/// [deleted] is the service's boolean result, including false. The canonical
/// schema is closed; finite future receive-only metadata remains immutable.
@immutable
final class VoiceConsentDeleted {
  /// Creates a deletion result with an immutable received JSON snapshot.
  VoiceConsentDeleted({
    required this.id,
    required this.deleted,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'VoiceConsentDeleted',
         knownKeys: _fields,
       );

  static const Set<String> _fields = {'object', 'id', 'deleted'};

  /// Parses all required canonical fields without assuming successful deletion.
  factory VoiceConsentDeleted.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(
      json,
      'VoiceConsentDeleted',
      knownKeys: _fields,
    );
    _requireConsentObject(
      snapshot,
      'audio.voice_consent',
      'VoiceConsentDeleted',
    );
    return VoiceConsentDeleted(
      id: requireJsonString(snapshot['id'], 'VoiceConsentDeleted.id'),
      deleted: _requireConsentBool(
        snapshot['deleted'],
        'VoiceConsentDeleted.deleted',
      ),
      rawJson: snapshot,
    );
  }

  /// Fixed canonical object discriminator.
  String get object => 'audio.voice_consent';

  /// Opaque consent recording identifier.
  final String id;

  /// Whether deletion succeeded, preserving false exactly.
  final bool deleted;

  /// Original deeply immutable received JSON, including future metadata.
  final Map<String, dynamic> rawJson;

  /// Serializes typed fields and receive-only future metadata.
  Map<String, dynamic> toJson() => mergeAudioJson(rawJson, _fields, {
    'object': object,
    'id': id,
    'deleted': deleted,
  });

  /// Copies all fields; an empty raw map clears future metadata.
  VoiceConsentDeleted copyWith({
    String? id,
    bool? deleted,
    Map<String, dynamic>? rawJson,
  }) => VoiceConsentDeleted(
    id: id ?? this.id,
    deleted: deleted ?? this.deleted,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceConsentDeleted && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'VoiceConsentDeleted(object: $object, id: [REDACTED], '
      'deleted: $deleted, rawJson: ${rawJson.length} entries)';
}

Uint8List _snapshotRecording(Uint8List recording) {
  if (recording.length > VoiceConsentCreateRequest.maxRecordingBytes) {
    throw const FormatException(
      'VoiceConsentCreateRequest.recording: maximum size is 10 MiB',
    );
  }
  return Uint8List.fromList(recording).asUnmodifiableView();
}

String? _normalizeRecordingContentType(String? contentType) {
  if (contentType == null) return null;
  final String base;
  try {
    base = MediaType.parse(contentType).mimeType;
  } on FormatException {
    throw const FormatException(
      'VoiceConsentCreateRequest.recordingContentType: '
      'expected a valid supported audio MIME type',
    );
  }
  if (!_recordingMimeTypes.contains(base)) {
    throw const FormatException(
      'VoiceConsentCreateRequest.recordingContentType: '
      'unsupported audio MIME type',
    );
  }
  return base;
}

const _recordingMimeTypes = {
  'audio/mpeg',
  'audio/wav',
  'audio/x-wav',
  'audio/ogg',
  'audio/aac',
  'audio/flac',
  'audio/webm',
  'audio/mp4',
};

const _recordingMimeExtensions = {
  'mp3': 'audio/mpeg',
  'mpeg': 'audio/mpeg',
  'mpga': 'audio/mpeg',
  'wav': 'audio/wav',
  'ogg': 'audio/ogg',
  'oga': 'audio/ogg',
  'aac': 'audio/aac',
  'flac': 'audio/flac',
  'webm': 'audio/webm',
  'mp4': 'audio/mp4',
  'm4a': 'audio/mp4',
};

String? _nullableConsentString(Object? value, String context) =>
    value == null ? null : requireJsonString(value, context);

void _requireConsentObject(
  Map<String, dynamic> json,
  String expected,
  String context,
) {
  if (requireJsonString(json['object'], '$context.object') != expected) {
    throw FormatException('$context.object: unexpected discriminator');
  }
}

bool _requireConsentBool(Object? value, String context) {
  if (value is! bool) {
    throw FormatException('$context: expected a boolean');
  }
  return value;
}

List<VoiceConsent> _parseConsents(Object? value) {
  if (value is! List<dynamic>) {
    throw const FormatException('VoiceConsentList.data: expected an array');
  }
  return [
    for (var index = 0; index < value.length; index++)
      VoiceConsent._fromJson(
        requireJsonObject(value[index], 'VoiceConsentList.data[$index]'),
        'VoiceConsentList.data[$index]',
      ),
  ];
}
