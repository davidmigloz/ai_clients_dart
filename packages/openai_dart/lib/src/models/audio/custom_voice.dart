import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'audio_json_helpers.dart';
import 'audio_upload_helpers.dart';

/// A multipart request to create a custom voice from an explicit consent/sample.
///
/// [name] has 1–256 Unicode code points. The service validates project/person
/// eligibility, consent and the audio's speech content. This request snapshots
/// original bytes without recording, transcription or quality inspection.
@immutable
final class CustomVoiceCreateRequest {
  /// Creates a single `audio_sample` upload, preserving omitted [type].
  ///
  /// A supported [audioSampleContentType] is normalized to its base MIME type,
  /// removing valid browser parameters. When omitted, a recognized filename
  /// extension supplies the MIME type. Other filenames need explicit metadata.
  CustomVoiceCreateRequest({
    required this.name,
    required Uint8List audioSample,
    required this.filename,
    required this.consent,
    String? audioSampleContentType,
    this.type,
  }) : audioSample = snapshotAudioUploadBytes(
         audioSample,
         'CustomVoiceCreateRequest.audioSample',
       ),
       audioSampleContentType = normalizeAudioUploadContentType(
         audioSampleContentType,
         'CustomVoiceCreateRequest.audioSampleContentType',
       ) {
    validate();
  }

  /// Maximum sample file size in bytes: 10 MiB.
  static const int maxAudioSampleBytes = audioUploadMaxBytes;

  /// Custom voice name, containing 1–256 Unicode code points.
  final String name;

  /// Immutable original sample bytes, including the exact provided view range.
  final Uint8List audioSample;

  /// Filename metadata for the sample part, preserved verbatim.
  final String filename;

  /// Opaque identifier of the caller-selected consent recording.
  final String consent;

  /// Optional normalized MIME metadata, separate from the API's form fields.
  ///
  /// Remains null when omitted; [effectiveAudioSampleContentType] supplies the
  /// inferred value used for multipart upload.
  final String? audioSampleContentType;

  /// Optional creation method, restricted to `audio_sample` when supplied.
  ///
  /// Null omits the form field and preserves the service's `audio_sample`
  /// default. It does not send an explicit null or select another branch.
  final String? type;

  /// Supported base MIME type used for the sample part.
  String get effectiveAudioSampleContentType => resolveAudioUploadContentType(
    filename,
    audioSampleContentType,
    'CustomVoiceCreateRequest.audioSampleContentType',
  );

  /// Validates writable admission before authentication or multipart dispatch.
  void validate() {
    final length = name.runes.length;
    if (length < 1 || length > 256) {
      throw const FormatException(
        'CustomVoiceCreateRequest.name: expected 1–256 Unicode code points',
      );
    }
    if (type != null && type != 'audio_sample') {
      throw const FormatException(
        'CustomVoiceCreateRequest.type: unsupported creation method',
      );
    }
    validateAudioUpload(
      audioSample,
      filename: filename,
      contentType: audioSampleContentType,
      bytesContext: 'CustomVoiceCreateRequest.audioSample',
      contentTypeContext: 'CustomVoiceCreateRequest.audioSampleContentType',
    );
  }

  /// Copies every field; explicit null clears MIME metadata or optional [type].
  CustomVoiceCreateRequest copyWith({
    String? name,
    Uint8List? audioSample,
    String? filename,
    String? consent,
    Object? audioSampleContentType = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
  }) => CustomVoiceCreateRequest(
    name: name ?? this.name,
    audioSample: audioSample ?? this.audioSample,
    filename: filename ?? this.filename,
    consent: consent ?? this.consent,
    audioSampleContentType:
        identical(audioSampleContentType, unsetCopyWithValue)
        ? this.audioSampleContentType
        : _nullableCustomVoiceString(
            audioSampleContentType,
            'CustomVoiceCreateRequest.audioSampleContentType',
          ),
    type: identical(type, unsetCopyWithValue)
        ? this.type
        : _nullableCustomVoiceString(type, 'CustomVoiceCreateRequest.type'),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomVoiceCreateRequest &&
          name == other.name &&
          listsEqual(audioSample, other.audioSample) &&
          filename == other.filename &&
          consent == other.consent &&
          audioSampleContentType == other.audioSampleContentType &&
          type == other.type;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    listHash(audioSample),
    filename,
    consent,
    audioSampleContentType,
    type,
  );

  @override
  String toString() =>
      'CustomVoiceCreateRequest(name: [REDACTED], '
      'audioSample: ${audioSample.length} bytes, filename: [REDACTED], '
      'consent: [REDACTED], '
      'audioSampleContentType: ${audioPresence(audioSampleContentType)}, '
      'type: $type)';
}

/// Metadata for a custom voice created from a consent and audio sample.
///
/// The canonical schema is closed, with fixed `audio.voice` object and
/// `audio_sample` creation type. Unknown values in these known fields are
/// rejected. Finite future receive-only metadata remains available in the
/// deeply immutable [rawJson] snapshot; typed fields are authoritative.
@immutable
final class CustomVoice {
  /// Creates metadata with an immutable received JSON snapshot.
  CustomVoice({
    required this.id,
    required this.name,
    required this.createdAt,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(rawJson, 'CustomVoice', knownKeys: _fields) {
    requireAudioInt(createdAt, 'CustomVoice.created_at');
  }

  static const Set<String> _fields = {
    'object',
    'id',
    'name',
    'type',
    'created_at',
  };

  /// Parses every required canonical field without coercing future types.
  factory CustomVoice.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(json, 'CustomVoice', knownKeys: _fields);
    _requireCustomVoiceFixed(snapshot, 'object', 'audio.voice');
    _requireCustomVoiceFixed(snapshot, 'type', 'audio_sample');
    return CustomVoice(
      id: requireJsonString(snapshot['id'], 'CustomVoice.id'),
      name: requireJsonString(snapshot['name'], 'CustomVoice.name'),
      createdAt: requireAudioInt(
        snapshot['created_at'],
        'CustomVoice.created_at',
      ),
      rawJson: snapshot,
    );
  }

  /// Fixed canonical object discriminator.
  String get object => 'audio.voice';

  /// Fixed canonical creation type.
  String get type => 'audio_sample';

  /// Opaque identifier for a caller-selected custom voice reference.
  final String id;

  /// Name returned by the service, without request-only length restrictions.
  final String name;

  /// Unix timestamp in seconds when the voice was created.
  final int createdAt;

  /// Original deeply immutable received JSON, including future metadata.
  final Map<String, dynamic> rawJson;

  /// Serializes typed values and immutable receive-only future metadata.
  Map<String, dynamic> toJson() => mergeAudioJson(rawJson, _fields, {
    'object': object,
    'id': id,
    'name': name,
    'type': type,
    'created_at': createdAt,
  });

  /// Copies every field; an empty raw map clears received future metadata.
  CustomVoice copyWith({
    String? id,
    String? name,
    int? createdAt,
    Map<String, dynamic>? rawJson,
  }) => CustomVoice(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomVoice && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'CustomVoice(object: $object, id: [REDACTED], name: [REDACTED], '
      'type: $type, createdAt: [REDACTED], rawJson: ${rawJson.length} entries)';
}

String? _nullableCustomVoiceString(Object? value, String context) =>
    value == null ? null : requireJsonString(value, context);

void _requireCustomVoiceFixed(
  Map<String, dynamic> json,
  String key,
  String expected,
) {
  if (requireJsonString(json[key], 'CustomVoice.$key') != expected) {
    throw FormatException('CustomVoice.$key: unexpected discriminator');
  }
}
