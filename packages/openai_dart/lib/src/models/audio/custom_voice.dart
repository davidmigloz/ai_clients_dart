import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'audio_json_helpers.dart';
import 'audio_upload_helpers.dart';

/// A custom voice creation request.
///
/// [CustomVoiceCreateRequest] uploads a sample with an existing consent.
/// [PromptVoiceCreateRequest] describes a voice without uploading audio.
/// The sample branch requires multipart encoding; the prompt branch supports
/// JSON and multipart encoding.
sealed class VoiceCreateRequest {
  /// Creates a voice creation request.
  const VoiceCreateRequest();

  /// Validates writable admission before authentication or dispatch.
  void validate();
}

/// A multipart request to create a custom voice from an explicit consent/sample.
///
/// [name] has 1–256 Unicode code points. The service validates project/person
/// eligibility, consent and the audio's speech content. This request snapshots
/// original bytes without recording, transcription or quality inspection.
@immutable
final class CustomVoiceCreateRequest extends VoiceCreateRequest {
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
  @override
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

/// A request to create a saved Live voice from an explicit text description.
///
/// Prompt voices work only in Live. Creation does not require a consent or audio
/// recording, and the response contains metadata without preview audio.
@immutable
final class PromptVoiceCreateRequest extends VoiceCreateRequest {
  /// Creates and validates a prompt request, preserving omitted optional fields.
  PromptVoiceCreateRequest({
    required this.name,
    required this.prompt,
    this.scriptHint,
    this.model,
  }) {
    validate();
  }

  static const Set<String> _fields = {
    'type',
    'name',
    'prompt',
    'script_hint',
    'model',
  };

  /// Parses the closed JSON prompt branch with its required discriminator.
  factory PromptVoiceCreateRequest.fromJson(Map<String, dynamic> json) {
    const context = 'PromptVoiceCreateRequest';
    final snapshot = snapshotAudioJson(json, context, knownKeys: _fields);
    requireClosedAudioJson(snapshot, _fields, context);
    if (requireJsonString(snapshot['type'], '$context.type') != 'prompt') {
      throw const FormatException('$context.type: unexpected discriminator');
    }
    return PromptVoiceCreateRequest(
      name: requireJsonString(snapshot['name'], '$context.name'),
      prompt: requireJsonString(snapshot['prompt'], '$context.prompt'),
      scriptHint: snapshot.containsKey('script_hint')
          ? requireJsonString(snapshot['script_hint'], '$context.script_hint')
          : null,
      model: snapshot.containsKey('model')
          ? requireJsonString(snapshot['model'], '$context.model')
          : null,
    );
  }

  /// Fixed creation discriminator, always sent for this branch.
  String get type => 'prompt';

  /// Name containing 1–256 Unicode code points; whitespace is preserved.
  final String name;

  /// Voice description containing 1–2000 code points and nonblank text.
  final String prompt;

  /// Optional representative speech with 1–2000 code points and nonblank text.
  ///
  /// Omission asks the service to generate a script from [prompt]. The service
  /// also rejects scripts that are too short; its minimum is not specified.
  final String? scriptHint;

  /// Open voice-creation model name, such as `auto` or `2026-10-08`.
  ///
  /// Omission preserves the service's `auto` default. Future names are accepted.
  final String? model;

  @override
  void validate() {
    _validateVoiceText(name, 'PromptVoiceCreateRequest.name', maxLength: 256);
    _validateVoiceText(
      prompt,
      'PromptVoiceCreateRequest.prompt',
      maxLength: 2000,
      nonblank: true,
    );
    if (scriptHint case final hint?) {
      _validateVoiceText(
        hint,
        'PromptVoiceCreateRequest.scriptHint',
        maxLength: 2000,
        nonblank: true,
      );
    }
  }

  /// Serializes only the declared JSON fields without inserting defaults.
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'prompt': prompt,
    'script_hint': ?scriptHint,
    'model': ?model,
  };

  /// Copies every field; explicit null clears an optional script or model.
  PromptVoiceCreateRequest copyWith({
    String? name,
    String? prompt,
    Object? scriptHint = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
  }) => PromptVoiceCreateRequest(
    name: name ?? this.name,
    prompt: prompt ?? this.prompt,
    scriptHint: identical(scriptHint, unsetCopyWithValue)
        ? this.scriptHint
        : _nullableCustomVoiceString(
            scriptHint,
            'PromptVoiceCreateRequest.scriptHint',
          ),
    model: identical(model, unsetCopyWithValue)
        ? this.model
        : _nullableCustomVoiceString(model, 'PromptVoiceCreateRequest.model'),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptVoiceCreateRequest &&
          name == other.name &&
          prompt == other.prompt &&
          scriptHint == other.scriptHint &&
          model == other.model;

  @override
  int get hashCode => Object.hash(runtimeType, name, prompt, scriptHint, model);

  @override
  String toString() =>
      'PromptVoiceCreateRequest(type: $type, name: [REDACTED], '
      'prompt: [REDACTED], scriptHint: ${audioPresence(scriptHint)}, '
      'model: ${audioPresence(model)})';
}

/// Metadata for a voice created from a prompt or an explicit audio sample.
///
/// The canonical schema is closed, with fixed `audio.voice` object and a
/// `prompt` or `audio_sample` creation type. Unknown known-field values are
/// rejected. Finite future receive-only metadata remains available in the
/// deeply immutable [rawJson] snapshot; typed fields are authoritative.
@immutable
final class CustomVoice {
  /// Creates metadata with an immutable received JSON snapshot.
  CustomVoice({
    required this.id,
    required this.name,
    required this.createdAt,
    this.type = 'audio_sample',
    this.prompt,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(rawJson, 'CustomVoice', knownKeys: _fields) {
    requireAudioInt(createdAt, 'CustomVoice.created_at');
    if (type != 'audio_sample' && type != 'prompt') {
      throw const FormatException('CustomVoice.type: unexpected discriminator');
    }
  }

  static const Set<String> _fields = {
    'object',
    'id',
    'name',
    'type',
    'prompt',
    'created_at',
  };

  /// Parses every required canonical field without coercing future types.
  factory CustomVoice.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(json, 'CustomVoice', knownKeys: _fields);
    _requireCustomVoiceFixed(snapshot, 'object', 'audio.voice');
    return CustomVoice(
      id: requireJsonString(snapshot['id'], 'CustomVoice.id'),
      name: requireJsonString(snapshot['name'], 'CustomVoice.name'),
      createdAt: requireAudioInt(
        snapshot['created_at'],
        'CustomVoice.created_at',
      ),
      type: requireJsonString(snapshot['type'], 'CustomVoice.type'),
      prompt: snapshot.containsKey('prompt')
          ? requireJsonString(snapshot['prompt'], 'CustomVoice.prompt')
          : null,
      rawJson: snapshot,
    );
  }

  /// Fixed canonical object discriminator.
  String get object => 'audio.voice';

  /// Creation method, either `audio_sample` or `prompt`.
  final String type;

  /// Original voice description when stored, otherwise omitted.
  ///
  /// Older prompt voices may omit this metadata. Null in Dart omits the field;
  /// explicit JSON null is not part of the canonical response contract.
  final String? prompt;

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
    'prompt': ?prompt,
    'created_at': createdAt,
  });

  /// Copies every field; an empty raw map clears received future metadata.
  CustomVoice copyWith({
    String? id,
    String? name,
    int? createdAt,
    String? type,
    Object? prompt = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => CustomVoice(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    type: type ?? this.type,
    prompt: identical(prompt, unsetCopyWithValue)
        ? this.prompt
        : _nullableCustomVoiceString(prompt, 'CustomVoice.prompt'),
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
      'type: $type, prompt: ${audioPresence(prompt)}, '
      'createdAt: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Result of explicitly deleting a saved custom voice.
///
/// Deleting a voice does not delete its consent recording. [deleted] preserves
/// the returned boolean, including false. Future received metadata is retained
/// as immutable finite JSON and never overrides the typed canonical fields.
@immutable
final class CustomVoiceDeleted {
  /// Creates an immutable deletion response without synthesizing success.
  CustomVoiceDeleted({
    required this.id,
    required this.deleted,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'CustomVoiceDeleted',
         knownKeys: _fields,
       );

  static const Set<String> _fields = {'id', 'object', 'deleted'};

  /// Parses every required canonical field, including its fixed object type.
  factory CustomVoiceDeleted.fromJson(Map<String, dynamic> json) {
    const context = 'CustomVoiceDeleted';
    final snapshot = snapshotAudioJson(json, context, knownKeys: _fields);
    if (requireJsonString(snapshot['object'], '$context.object') !=
        'audio.voice.deleted') {
      throw const FormatException('$context.object: unexpected discriminator');
    }
    final deleted = snapshot['deleted'];
    if (deleted is! bool) {
      throw const FormatException('$context.deleted: expected a boolean');
    }
    return CustomVoiceDeleted(
      id: requireJsonString(snapshot['id'], '$context.id'),
      deleted: deleted,
      rawJson: snapshot,
    );
  }

  /// Opaque identifier of the deleted voice.
  final String id;

  /// Fixed deletion object discriminator.
  String get object => 'audio.voice.deleted';

  /// Whether the service reports that the voice was deleted.
  final bool deleted;

  /// Original deeply immutable JSON, including future receive-only metadata.
  final Map<String, dynamic> rawJson;

  /// Serializes typed canonical fields and preserved future metadata.
  Map<String, dynamic> toJson() => mergeAudioJson(rawJson, _fields, {
    'id': id,
    'object': object,
    'deleted': deleted,
  });

  /// Copies every field; an empty map clears future received metadata.
  CustomVoiceDeleted copyWith({
    String? id,
    bool? deleted,
    Map<String, dynamic>? rawJson,
  }) => CustomVoiceDeleted(
    id: id ?? this.id,
    deleted: deleted ?? this.deleted,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomVoiceDeleted && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'CustomVoiceDeleted(id: [REDACTED], object: $object, deleted: $deleted, '
      'rawJson: ${rawJson.length} entries)';
}

void _validateVoiceText(
  String value,
  String context, {
  required int maxLength,
  bool nonblank = false,
}) {
  final length = value.runes.length;
  if (length < 1 || length > maxLength) {
    throw FormatException(
      '$context: expected 1–$maxLength Unicode code points',
    );
  }
  if (nonblank && value.trim().isEmpty) {
    throw FormatException('$context: expected nonblank text');
  }
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
