import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

/// Immutable value semantics for the closed native response-input contracts.
@immutable
abstract class RealtimeResponseInputValue {
  /// Creates a native input value.
  const RealtimeResponseInputValue();

  /// Validates the native GA contract before transmission.
  void validate();

  /// Serializes only schema-declared writable fields.
  Map<String, dynamic> toJson();
  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is RealtimeResponseInputValue &&
      mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));
  @override
  String toString() => '$runtimeType([REDACTED])';
}

/// GA response.create input: references, messages, function calls or outputs.
///
/// Variants are [RealtimeResponseItemReference], [RealtimeResponseInputMessage],
/// [RealtimeResponseInputFunctionCall] and [RealtimeResponseInputFunctionCallOutput].
/// References are accepted only here, never as new conversation items. Beta
/// retains its separate broader conversation-item contract through raw send.
sealed class RealtimeResponseInputItem extends RealtimeResponseInputValue {
  const RealtimeResponseInputItem();

  /// Parses the four closed native GA input branches.
  factory RealtimeResponseInputItem.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'item_reference' => RealtimeResponseItemReference.fromJson(json),
        'message' => RealtimeResponseInputMessage.fromJson(json),
        'function_call' => RealtimeResponseInputFunctionCall.fromJson(json),
        'function_call_output' =>
          RealtimeResponseInputFunctionCallOutput.fromJson(json),
        _ => throw const FormatException(
          'RealtimeResponseInputItem.type: unsupported input',
        ),
      };

  /// Fixed item discriminator.
  String get type;
}

/// Reference to an existing item in the same Realtime session.
final class RealtimeResponseItemReference extends RealtimeResponseInputItem {
  /// Validates a nonreserved native identifier, without creating a new item.
  RealtimeResponseItemReference({required this.id}) {
    validate();
  }

  /// Existing identifier: 1–32 ASCII letters, numbers, underscores or hyphens.
  final String id;
  @override
  String get type => 'item_reference';

  /// Parses only the reference discriminator and required ID.
  factory RealtimeResponseItemReference.fromJson(Map<String, dynamic> json) {
    _requireInputKeys(json, {'type', 'id'}, 'RealtimeResponseItemReference');
    requireJsonType(json, 'item_reference', 'RealtimeResponseItemReference');
    return RealtimeResponseItemReference(
      id: requireJsonString(json['id'], 'RealtimeResponseItemReference.id'),
    );
  }
  @override
  void validate() => _validateInputId(id, 'RealtimeResponseItemReference.id');
  @override
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Copies the required existing item ID.
  RealtimeResponseItemReference copyWith({String? id}) =>
      RealtimeResponseItemReference(id: id ?? this.id);
}

/// A typed part in a new native response input message.
///
/// Variants are [RealtimeResponseInputText], [RealtimeResponseInputAudio],
/// [RealtimeResponseInputImage] and [RealtimeResponseInputOutputText]. The role
/// determines which parts can be used; these are not full conversation items.
sealed class RealtimeResponseInputContentPart
    extends RealtimeResponseInputValue {
  const RealtimeResponseInputContentPart();

  /// Parses the four closed part contracts, before role validation.
  factory RealtimeResponseInputContentPart.fromJson(
    Map<String, dynamic> json,
  ) => switch (json['type']) {
    'input_text' => RealtimeResponseInputText.fromJson(json),
    'input_audio' => RealtimeResponseInputAudio.fromJson(json),
    'input_image' => RealtimeResponseInputImage.fromJson(json),
    'output_text' => RealtimeResponseInputOutputText.fromJson(json),
    _ => throw const FormatException(
      'RealtimeResponseInputContentPart.type: unsupported part',
    ),
  };

  /// Fixed content discriminator.
  String get type;
}

/// Input text, including empty strings, limited to 256,000 code points.
final class RealtimeResponseInputText extends RealtimeResponseInputContentPart {
  /// Captures exact input text.
  RealtimeResponseInputText({required this.text}) {
    validate();
  }

  /// Exact input text.
  final String text;
  @override
  String get type => 'input_text';

  /// Parses required type/text without accepting extra writable fields.
  factory RealtimeResponseInputText.fromJson(Map<String, dynamic> json) {
    _requireInputKeys(json, {'type', 'text'}, 'RealtimeResponseInputText');
    requireJsonType(json, 'input_text', 'RealtimeResponseInputText');
    return RealtimeResponseInputText(
      text: requireJsonString(json['text'], 'RealtimeResponseInputText.text'),
    );
  }
  @override
  void validate() =>
      _validateInputLength(text, 'RealtimeResponseInputText.text', max: 256000);
  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Copies exact input text.
  RealtimeResponseInputText copyWith({String? text}) =>
      RealtimeResponseInputText(text: text ?? this.text);
}

/// Assistant text used as response input, with its distinct output_text tag.
final class RealtimeResponseInputOutputText
    extends RealtimeResponseInputContentPart {
  /// Captures exact assistant text.
  RealtimeResponseInputOutputText({required this.text}) {
    validate();
  }

  /// Exact assistant text, limited to 256,000 code points.
  final String text;
  @override
  String get type => 'output_text';

  /// Parses the inline assistant-only content shape.
  factory RealtimeResponseInputOutputText.fromJson(Map<String, dynamic> json) {
    _requireInputKeys(json, {
      'type',
      'text',
    }, 'RealtimeResponseInputOutputText');
    requireJsonType(json, 'output_text', 'RealtimeResponseInputOutputText');
    return RealtimeResponseInputOutputText(
      text: requireJsonString(
        json['text'],
        'RealtimeResponseInputOutputText.text',
      ),
    );
  }
  @override
  void validate() => _validateInputLength(
    text,
    'RealtimeResponseInputOutputText.text',
    max: 256000,
  );
  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Copies exact assistant text.
  RealtimeResponseInputOutputText copyWith({String? text}) =>
      RealtimeResponseInputOutputText(text: text ?? this.text);
}

/// Audio in the session input format, with optional nullable associated text.
final class RealtimeResponseInputAudio
    extends RealtimeResponseInputContentPart {
  /// Captures nonempty base64 audio text without inferring session encoding.
  RealtimeResponseInputAudio({
    required this.audio,
    this.transcript,
    bool hasTranscript = false,
  }) : hasTranscript = hasTranscript || transcript != null {
    validate();
  }

  /// Base64 audio bytes in the existing session's input format.
  final String audio;

  /// Optional associated text; null can be explicitly supplied.
  final String? transcript;

  /// Whether transcript is present, including null.
  final bool hasTranscript;
  @override
  String get type => 'input_audio';

  /// Parses the closed audio part, preserving transcript presence.
  factory RealtimeResponseInputAudio.fromJson(Map<String, dynamic> json) {
    _requireInputKeys(json, {
      'type',
      'audio',
      'transcript',
    }, 'RealtimeResponseInputAudio');
    requireJsonType(json, 'input_audio', 'RealtimeResponseInputAudio');
    return RealtimeResponseInputAudio(
      audio: requireJsonString(
        json['audio'],
        'RealtimeResponseInputAudio.audio',
      ),
      transcript: optionalJsonString(
        json,
        'transcript',
        'RealtimeResponseInputAudio',
        nullable: true,
      ),
      hasTranscript: json.containsKey('transcript'),
    );
  }
  @override
  void validate() =>
      _validateInputLength(audio, 'RealtimeResponseInputAudio.audio', min: 1);
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'audio': audio,
    if (hasTranscript) 'transcript': transcript,
  };

  /// Copies fields; null writes transcript null, clearTranscript omits it.
  RealtimeResponseInputAudio copyWith({
    String? audio,
    Object? transcript = unsetCopyWithValue,
    bool clearTranscript = false,
  }) => RealtimeResponseInputAudio(
    audio: audio ?? this.audio,
    transcript: clearTranscript
        ? null
        : _copyInputString(
            transcript,
            this.transcript,
            'RealtimeResponseInputAudio.transcript',
          ),
    hasTranscript:
        !clearTranscript &&
        (!identical(transcript, unsetCopyWithValue) || hasTranscript),
  );
}

/// An image data URL for native response input; use PNG or JPEG.
final class RealtimeResponseInputImage
    extends RealtimeResponseInputContentPart {
  /// Captures the exact data URL and optional nullable detail.
  RealtimeResponseInputImage({
    required this.imageUrl,
    this.detail,
    bool hasDetail = false,
  }) : hasDetail = hasDetail || detail != null {
    validate();
  }

  /// A data:image/...;base64,... URL, not a file ID or public HTTP image.
  final String imageUrl;

  /// Optional low/high/auto detail; omission or null uses the server default.
  final String? detail;

  /// Whether detail is present, including null.
  final bool hasDetail;
  @override
  String get type => 'input_image';

  /// Parses the closed image contract with no invented original detail value.
  factory RealtimeResponseInputImage.fromJson(Map<String, dynamic> json) {
    _requireInputKeys(json, {
      'type',
      'image_url',
      'detail',
    }, 'RealtimeResponseInputImage');
    requireJsonType(json, 'input_image', 'RealtimeResponseInputImage');
    return RealtimeResponseInputImage(
      imageUrl: requireJsonString(
        json['image_url'],
        'RealtimeResponseInputImage.image_url',
      ),
      detail: optionalJsonString(
        json,
        'detail',
        'RealtimeResponseInputImage',
        nullable: true,
      ),
      hasDetail: json.containsKey('detail'),
    );
  }
  @override
  void validate() {
    if (!RegExp(r'^data:image/[^;,]+;base64,.+').hasMatch(imageUrl) ||
        Uri.tryParse(imageUrl) == null) {
      throw const FormatException(
        'RealtimeResponseInputImage.image_url: expected an image base64 data URL',
      );
    }
    if (detail != null && !const {'low', 'high', 'auto'}.contains(detail)) {
      throw const FormatException(
        'RealtimeResponseInputImage.detail: unsupported value',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': imageUrl,
    if (hasDetail) 'detail': detail,
  };

  /// Copies fields; null writes detail null, clearDetail omits it.
  RealtimeResponseInputImage copyWith({
    String? imageUrl,
    Object? detail = unsetCopyWithValue,
    bool clearDetail = false,
  }) => RealtimeResponseInputImage(
    imageUrl: imageUrl ?? this.imageUrl,
    detail: clearDetail
        ? null
        : _copyInputString(
            detail,
            this.detail,
            'RealtimeResponseInputImage.detail',
          ),
    hasDetail:
        !clearDetail && (!identical(detail, unsetCopyWithValue) || hasDetail),
  );
}

/// A new role-specific native response input message.
///
/// System/developer require exactly one input_text part. User admits one or more
/// text/audio/image parts; assistant admits one or more output_text parts. IDs
/// and status preserve omission versus explicit null; no defaults are emitted.
final class RealtimeResponseInputMessage extends RealtimeResponseInputItem {
  /// Creates and validates a new message without accepting an item reference.
  RealtimeResponseInputMessage({
    required this.role,
    required List<RealtimeResponseInputContentPart> content,
    this.id,
    bool hasId = false,
    this.status,
    bool hasStatus = false,
  }) : content = List.unmodifiable(content),
       hasId = hasId || id != null,
       hasStatus = hasStatus || status != null {
    validate();
  }

  /// Required system/developer/user/assistant role.
  final String role;

  /// Immutable role-appropriate nonempty part sequence.
  final List<RealtimeResponseInputContentPart> content;

  /// Optional local ID; the reserved root identifier cannot be used.
  final String? id;

  /// Whether id is present, including null.
  final bool hasId;

  /// Optional completed/incomplete input status, nullable with server default.
  final String? status;

  /// Whether status is present, including null.
  final bool hasStatus;
  @override
  String get type => 'message';

  /// Parses the closed role-discriminated message contract.
  factory RealtimeResponseInputMessage.fromJson(Map<String, dynamic> json) {
    const context = 'RealtimeResponseInputMessage';
    _requireInputKeys(json, {
      'type',
      'role',
      'content',
      'id',
      'status',
    }, context);
    requireJsonType(json, 'message', context);
    final parts = json['content'];
    if (parts is! List) {
      throw const FormatException('$context.content: expected an array');
    }
    return RealtimeResponseInputMessage(
      role: requireJsonString(json['role'], '$context.role'),
      content: [
        for (final part in parts)
          RealtimeResponseInputContentPart.fromJson(
            requireJsonObject(part, '$context.content'),
          ),
      ],
      id: optionalJsonString(json, 'id', context, nullable: true),
      hasId: json.containsKey('id'),
      status: optionalJsonString(json, 'status', context, nullable: true),
      hasStatus: json.containsKey('status'),
    );
  }
  @override
  void validate() {
    if (id != null) {
      _validateInputId(id!, 'RealtimeResponseInputMessage.id');
    }
    _validateInputStatus(status);
    final allowed = switch (role) {
      'system' || 'developer' => const {'input_text'},
      'user' => const {'input_text', 'input_audio', 'input_image'},
      'assistant' => const {'output_text'},
      _ => throw const FormatException(
        'RealtimeResponseInputMessage.role: unsupported value',
      ),
    };
    if (content.isEmpty ||
        ((role == 'system' || role == 'developer') && content.length != 1)) {
      throw const FormatException(
        'RealtimeResponseInputMessage.content: invalid part count for role',
      );
    }
    for (final part in content) {
      if (!allowed.contains(part.type)) {
        throw const FormatException(
          'RealtimeResponseInputMessage.content: unsupported part for role',
        );
      }
      part.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'role': role,
    'content': [for (final part in content) part.toJson()],
    if (hasId) 'id': id,
    if (hasStatus) 'status': status,
  };

  /// Copies every field; nullable values and omission have separate controls.
  RealtimeResponseInputMessage copyWith({
    String? role,
    List<RealtimeResponseInputContentPart>? content,
    Object? id = unsetCopyWithValue,
    bool clearId = false,
    Object? status = unsetCopyWithValue,
    bool clearStatus = false,
  }) => RealtimeResponseInputMessage(
    role: role ?? this.role,
    content: content ?? this.content,
    id: clearId
        ? null
        : _copyInputString(id, this.id, 'RealtimeResponseInputMessage.id'),
    hasId: !clearId && (!identical(id, unsetCopyWithValue) || hasId),
    status: clearStatus
        ? null
        : _copyInputString(
            status,
            this.status,
            'RealtimeResponseInputMessage.status',
          ),
    hasStatus:
        !clearStatus && (!identical(status, unsetCopyWithValue) || hasStatus),
  );
}

/// A new function call supplied directly as response input.
final class RealtimeResponseInputFunctionCall
    extends RealtimeResponseInputItem {
  /// Captures exact argument text without parsing or normalizing JSON.
  RealtimeResponseInputFunctionCall({
    required this.callId,
    required this.name,
    required this.arguments,
    this.id,
    bool hasId = false,
    this.status,
    bool hasStatus = false,
  }) : hasId = hasId || id != null,
       hasStatus = hasStatus || status != null {
    validate();
  }

  /// Nonreserved function call identifier, using the native item ID format.
  final String callId;

  /// Function name, 1–64 ASCII letters, digits, underscores or hyphens.
  final String name;

  /// Exact argument string, at most 1,048,576 code points.
  final String arguments;

  /// Optional nullable item ID.
  final String? id;

  /// Whether [id] is present, including explicit null.
  final bool hasId;

  /// Optional nullable completed/incomplete status.
  final String? status;

  /// Whether [status] is present, including explicit null.
  final bool hasStatus;
  @override
  String get type => 'function_call';

  /// Parses the closed writable function-call shape.
  factory RealtimeResponseInputFunctionCall.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'RealtimeResponseInputFunctionCall';
    _requireInputKeys(json, {
      'type',
      'call_id',
      'name',
      'arguments',
      'id',
      'status',
    }, context);
    requireJsonType(json, 'function_call', context);
    return RealtimeResponseInputFunctionCall(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      name: requireJsonString(json['name'], '$context.name'),
      arguments: requireJsonString(json['arguments'], '$context.arguments'),
      id: optionalJsonString(json, 'id', context, nullable: true),
      hasId: json.containsKey('id'),
      status: optionalJsonString(json, 'status', context, nullable: true),
      hasStatus: json.containsKey('status'),
    );
  }
  @override
  void validate() {
    _validateInputId(callId, 'RealtimeResponseInputFunctionCall.callId');
    if (id != null) {
      _validateInputId(id!, 'RealtimeResponseInputFunctionCall.id');
    }
    _validateInputStatus(status);
    _validateInputLength(
      name,
      'RealtimeResponseInputFunctionCall.name',
      min: 1,
      max: 64,
    );
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(name)) {
      throw const FormatException(
        'RealtimeResponseInputFunctionCall.name: invalid characters',
      );
    }
    _validateInputLength(
      arguments,
      'RealtimeResponseInputFunctionCall.arguments',
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (hasId) 'id': id,
    if (hasStatus) 'status': status,
  };

  /// Copies values; clear flags omit optional fields instead of emitting null.
  RealtimeResponseInputFunctionCall copyWith({
    String? callId,
    String? name,
    String? arguments,
    Object? id = unsetCopyWithValue,
    bool clearId = false,
    Object? status = unsetCopyWithValue,
    bool clearStatus = false,
  }) => RealtimeResponseInputFunctionCall(
    callId: callId ?? this.callId,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    id: clearId
        ? null
        : _copyInputString(id, this.id, 'RealtimeResponseInputFunctionCall.id'),
    hasId: !clearId && (!identical(id, unsetCopyWithValue) || hasId),
    status: clearStatus
        ? null
        : _copyInputString(
            status,
            this.status,
            'RealtimeResponseInputFunctionCall.status',
          ),
    hasStatus:
        !clearStatus && (!identical(status, unsetCopyWithValue) || hasStatus),
  );
}

/// String output of a function call supplied directly as response input.
final class RealtimeResponseInputFunctionCallOutput
    extends RealtimeResponseInputItem {
  /// Captures exact output text, including empty strings.
  RealtimeResponseInputFunctionCallOutput({
    required this.callId,
    required this.output,
    this.id,
    bool hasId = false,
    this.status,
    bool hasStatus = false,
  }) : hasId = hasId || id != null,
       hasStatus = hasStatus || status != null {
    validate();
  }

  /// Nonreserved function call identifier.
  final String callId;

  /// Exact output string, at most 1,048,576 code points.
  final String output;

  /// Optional nullable item ID.
  final String? id;

  /// Whether [id] is present, including explicit null.
  final bool hasId;

  /// Optional nullable completed/incomplete status.
  final String? status;

  /// Whether [status] is present, including explicit null.
  final bool hasStatus;
  @override
  String get type => 'function_call_output';

  /// Parses the closed writable function-call-output shape.
  factory RealtimeResponseInputFunctionCallOutput.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'RealtimeResponseInputFunctionCallOutput';
    _requireInputKeys(json, {
      'type',
      'call_id',
      'output',
      'id',
      'status',
    }, context);
    requireJsonType(json, 'function_call_output', context);
    return RealtimeResponseInputFunctionCallOutput(
      callId: requireJsonString(json['call_id'], '$context.call_id'),
      output: requireJsonString(json['output'], '$context.output'),
      id: optionalJsonString(json, 'id', context, nullable: true),
      hasId: json.containsKey('id'),
      status: optionalJsonString(json, 'status', context, nullable: true),
      hasStatus: json.containsKey('status'),
    );
  }
  @override
  void validate() {
    _validateInputId(callId, 'RealtimeResponseInputFunctionCallOutput.callId');
    if (id != null) {
      _validateInputId(id!, 'RealtimeResponseInputFunctionCallOutput.id');
    }
    _validateInputStatus(status);
    _validateInputLength(
      output,
      'RealtimeResponseInputFunctionCallOutput.output',
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'output': output,
    if (hasId) 'id': id,
    if (hasStatus) 'status': status,
  };

  /// Copies values; clear flags omit optional fields instead of emitting null.
  RealtimeResponseInputFunctionCallOutput copyWith({
    String? callId,
    String? output,
    Object? id = unsetCopyWithValue,
    bool clearId = false,
    Object? status = unsetCopyWithValue,
    bool clearStatus = false,
  }) => RealtimeResponseInputFunctionCallOutput(
    callId: callId ?? this.callId,
    output: output ?? this.output,
    id: clearId
        ? null
        : _copyInputString(
            id,
            this.id,
            'RealtimeResponseInputFunctionCallOutput.id',
          ),
    hasId: !clearId && (!identical(id, unsetCopyWithValue) || hasId),
    status: clearStatus
        ? null
        : _copyInputString(
            status,
            this.status,
            'RealtimeResponseInputFunctionCallOutput.status',
          ),
    hasStatus:
        !clearStatus && (!identical(status, unsetCopyWithValue) || hasStatus),
  );
}

void _requireInputKeys(
  Map<String, dynamic> json,
  Set<String> allowed,
  String context,
) {
  if (json.keys.any((key) => !allowed.contains(key))) {
    throw FormatException('$context: undeclared writable field');
  }
}

void _validateInputId(String value, String context) {
  _validateInputLength(value, context, min: 1, max: 32);
  if (value == 'root' || !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
    throw FormatException('$context: invalid or reserved identifier');
  }
}

void _validateInputLength(String value, String context, {int? min, int? max}) {
  final length = value.runes.length;
  if ((min != null && length < min) || (max != null && length > max)) {
    throw FormatException('$context: invalid string length');
  }
}

void _validateInputStatus(String? value) {
  if (value != null && value != 'completed' && value != 'incomplete') {
    throw const FormatException(
      'RealtimeResponseInputItem.status: unsupported value',
    );
  }
}

String? _copyInputString(Object? value, String? previous, String context) {
  if (identical(value, unsetCopyWithValue)) {
    return previous;
  }
  return value == null ? null : requireJsonString(value, context);
}
