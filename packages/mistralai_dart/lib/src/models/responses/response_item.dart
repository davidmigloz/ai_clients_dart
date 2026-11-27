import 'package:meta/meta.dart';

import '../../utils/additional_json_fields.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'response_content.dart';

/// A ResponseCaller variant.
///
/// [ResponseDirectCaller], [ResponseProgramCaller], or [UnknownResponseCaller].
@immutable
sealed class ResponseCaller {
  const ResponseCaller();

  /// Parses an API payload.
  factory ResponseCaller.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'direct' => ResponseDirectCaller.fromJson(json),
        'program' => ResponseProgramCaller.fromJson(json),
        _ => UnknownResponseCaller(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseCaller value.
@immutable
final class UnknownResponseCaller extends ResponseCaller {
  /// Creates a fallback from the original payload.
  UnknownResponseCaller(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseCaller && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The ResponsesEasyInputMessage wire payload.
@immutable
class ResponseInputMessage extends ResponseItem {
  /// Creates a [ResponseInputMessage].
  const ResponseInputMessage({
    required this.content,
    this.phase,
    required this.role,
    this.status,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'message';

  /// The content field.
  final ResponseMessageContent content;

  /// The phase field.
  final String? phase;

  /// The role field.
  final String role;

  /// The status field.
  final String? status;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseInputMessage] from JSON.
  factory ResponseInputMessage.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'message') {
      throw FormatException('ResponseInputMessage: unexpected type $value');
    }
    if (json['content'] == null) {
      throw const FormatException('ResponseInputMessage: missing content');
    }
    if (json['role'] == null) {
      throw const FormatException('ResponseInputMessage: missing role');
    }
    return ResponseInputMessage(
      content: ResponseMessageContent.fromJson(json['content'] as Object),
      phase: json['phase'] == null ? null : json['phase'] as String,
      role: json['role'] as String,
      status: json['status'] == null ? null : json['status'] as String,
      extra: additionalJsonFields(json, const {
        'content',
        'phase',
        'role',
        'status',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'content': content.toJson(),
    'phase': ?phase,
    'role': role,
    'status': ?status,
  };

  /// Creates a copy with the given fields replaced.
  ResponseInputMessage copyWith({
    ResponseMessageContent? content,
    Object? phase = unsetCopyWithValue,
    String? role,
    Object? status = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseInputMessage(
    content: content ?? this.content,
    phase: phase == unsetCopyWithValue ? this.phase : phase as String?,
    role: role ?? this.role,
    status: status == unsetCopyWithValue ? this.status : status as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInputMessage &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          phase == other.phase &&
          role == other.role &&
          status == other.status &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([content, phase, role, status, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseInputMessage('
      'content: $content, '
      'phase: $phase, '
      'role: $role, '
      'status: $status, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputMessage wire payload.
@immutable
class ResponseOutputMessage extends ResponseOutputItem {
  /// Creates a [ResponseOutputMessage].
  const ResponseOutputMessage({
    required this.content,
    required this.id,
    this.phase,
    required this.status,
    this.extra,
  });

  /// The fixed role discriminator.
  String get role => 'assistant';

  /// The fixed type discriminator.
  String get type => 'message';

  /// The content field.
  final List<ResponseOutputPart> content;

  /// The id field.
  final String id;

  /// The phase field.
  final String? phase;

  /// The status field.
  final String status;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputMessage] from JSON.
  factory ResponseOutputMessage.fromJson(Map<String, dynamic> json) {
    if (json['role'] case final value? when value != 'assistant') {
      throw FormatException('ResponseOutputMessage: unexpected role $value');
    }
    if (json['type'] case final value? when value != 'message') {
      throw FormatException('ResponseOutputMessage: unexpected type $value');
    }
    if (json['content'] == null) {
      throw const FormatException('ResponseOutputMessage: missing content');
    }
    if (json['id'] == null) {
      throw const FormatException('ResponseOutputMessage: missing id');
    }
    if (json['status'] == null) {
      throw const FormatException('ResponseOutputMessage: missing status');
    }
    return ResponseOutputMessage(
      content: (json['content'] as List)
          .map(
            (item) =>
                ResponseOutputPart.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      id: json['id'] as String,
      phase: json['phase'] == null ? null : json['phase'] as String,
      status: json['status'] as String,
      extra: additionalJsonFields(json, const {
        'content',
        'id',
        'phase',
        'status',
        'role',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'role': role,
    'type': type,
    'content': content.map((item) => item.toJson()).toList(),
    'id': id,
    'phase': ?phase,
    'status': status,
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputMessage copyWith({
    List<ResponseOutputPart>? content,
    String? id,
    Object? phase = unsetCopyWithValue,
    String? status,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputMessage(
    content: content ?? this.content,
    id: id ?? this.id,
    phase: phase == unsetCopyWithValue ? this.phase : phase as String?,
    status: status ?? this.status,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputMessage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(content, other.content) &&
          id == other.id &&
          phase == other.phase &&
          status == other.status &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(content),
    id,
    phase,
    status,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseOutputMessage('
      'content: ${content.length}, '
      'id: $id, '
      'phase: $phase, '
      'status: $status, '
      'extra: ${extra?.length})';
}

/// The ResponsesFunctionToolCall wire payload.
@immutable
class ResponseFunctionCall extends ResponseOutputItem {
  /// Creates a [ResponseFunctionCall].
  const ResponseFunctionCall({
    required this.arguments,
    this.isAsync,
    required this.callId,
    this.caller,
    this.id,
    required this.name,
    this.namespace,
    this.status,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'function_call';

  /// The arguments field.
  final String arguments;

  /// The async field.
  final bool? isAsync;

  /// The call_id field.
  final String callId;

  /// The caller field.
  final ResponseCaller? caller;

  /// The id field.
  final String? id;

  /// The name field.
  final String name;

  /// The namespace field.
  final String? namespace;

  /// The status field.
  final String? status;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFunctionCall] from JSON.
  factory ResponseFunctionCall.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'function_call') {
      throw FormatException('ResponseFunctionCall: unexpected type $value');
    }
    if (json['arguments'] == null) {
      throw const FormatException('ResponseFunctionCall: missing arguments');
    }
    if (json['call_id'] == null) {
      throw const FormatException('ResponseFunctionCall: missing call_id');
    }
    if (json['name'] == null) {
      throw const FormatException('ResponseFunctionCall: missing name');
    }
    return ResponseFunctionCall(
      arguments: json['arguments'] as String,
      isAsync: json['async'] == null ? null : json['async'] as bool,
      callId: json['call_id'] as String,
      caller: json['caller'] == null
          ? null
          : ResponseCaller.fromJson(json['caller'] as Map<String, dynamic>),
      id: json['id'] == null ? null : json['id'] as String,
      name: json['name'] as String,
      namespace: json['namespace'] == null ? null : json['namespace'] as String,
      status: json['status'] == null ? null : json['status'] as String,
      extra: additionalJsonFields(json, const {
        'arguments',
        'async',
        'call_id',
        'caller',
        'id',
        'name',
        'namespace',
        'status',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'arguments': arguments,
    'async': ?isAsync,
    'call_id': callId,
    if (caller != null) 'caller': caller!.toJson(),
    'id': ?id,
    'name': name,
    'namespace': ?namespace,
    'status': ?status,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFunctionCall copyWith({
    String? arguments,
    Object? isAsync = unsetCopyWithValue,
    String? callId,
    Object? caller = unsetCopyWithValue,
    Object? id = unsetCopyWithValue,
    String? name,
    Object? namespace = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFunctionCall(
    arguments: arguments ?? this.arguments,
    isAsync: isAsync == unsetCopyWithValue ? this.isAsync : isAsync as bool?,
    callId: callId ?? this.callId,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ResponseCaller?,
    id: id == unsetCopyWithValue ? this.id : id as String?,
    name: name ?? this.name,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    status: status == unsetCopyWithValue ? this.status : status as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionCall &&
          runtimeType == other.runtimeType &&
          arguments == other.arguments &&
          isAsync == other.isAsync &&
          callId == other.callId &&
          caller == other.caller &&
          id == other.id &&
          name == other.name &&
          namespace == other.namespace &&
          status == other.status &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    arguments,
    isAsync,
    callId,
    caller,
    id,
    name,
    namespace,
    status,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseFunctionCall('
      'arguments: $arguments, '
      'isAsync: $isAsync, '
      'callId: $callId, '
      'caller: $caller, '
      'id: $id, '
      'name: $name, '
      'namespace: $namespace, '
      'status: $status, '
      'extra: ${extra?.length})';
}

/// The ResponsesFunctionCallOutput wire payload.
@immutable
class ResponseFunctionCallOutput extends ResponseItem {
  /// Creates a [ResponseFunctionCallOutput].
  const ResponseFunctionCallOutput({
    required this.callId,
    this.caller,
    this.id,
    this.name,
    this.namespace,
    required this.output,
    this.status,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'function_call_output';

  /// The call_id field.
  final String callId;

  /// The caller field.
  final ResponseCaller? caller;

  /// The id field.
  final String? id;

  /// The name field.
  final String? name;

  /// The namespace field.
  final String? namespace;

  /// The output field.
  final ResponseFunctionOutput output;

  /// The status field.
  final String? status;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFunctionCallOutput] from JSON.
  factory ResponseFunctionCallOutput.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'function_call_output') {
      throw FormatException(
        'ResponseFunctionCallOutput: unexpected type $value',
      );
    }
    if (json['call_id'] == null) {
      throw const FormatException(
        'ResponseFunctionCallOutput: missing call_id',
      );
    }
    if (json['output'] == null) {
      throw const FormatException('ResponseFunctionCallOutput: missing output');
    }
    return ResponseFunctionCallOutput(
      callId: json['call_id'] as String,
      caller: json['caller'] == null
          ? null
          : ResponseCaller.fromJson(json['caller'] as Map<String, dynamic>),
      id: json['id'] == null ? null : json['id'] as String,
      name: json['name'] == null ? null : json['name'] as String,
      namespace: json['namespace'] == null ? null : json['namespace'] as String,
      output: ResponseFunctionOutput.fromJson(json['output'] as Object),
      status: json['status'] == null ? null : json['status'] as String,
      extra: additionalJsonFields(json, const {
        'call_id',
        'caller',
        'id',
        'name',
        'namespace',
        'output',
        'status',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'call_id': callId,
    if (caller != null) 'caller': caller!.toJson(),
    'id': ?id,
    'name': ?name,
    'namespace': ?namespace,
    'output': output.toJson(),
    'status': ?status,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFunctionCallOutput copyWith({
    String? callId,
    Object? caller = unsetCopyWithValue,
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? namespace = unsetCopyWithValue,
    ResponseFunctionOutput? output,
    Object? status = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFunctionCallOutput(
    callId: callId ?? this.callId,
    caller: caller == unsetCopyWithValue
        ? this.caller
        : caller as ResponseCaller?,
    id: id == unsetCopyWithValue ? this.id : id as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    namespace: namespace == unsetCopyWithValue
        ? this.namespace
        : namespace as String?,
    output: output ?? this.output,
    status: status == unsetCopyWithValue ? this.status : status as String?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionCallOutput &&
          runtimeType == other.runtimeType &&
          callId == other.callId &&
          caller == other.caller &&
          id == other.id &&
          name == other.name &&
          namespace == other.namespace &&
          output == other.output &&
          status == other.status &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    callId,
    caller,
    id,
    name,
    namespace,
    output,
    status,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseFunctionCallOutput('
      'callId: $callId, '
      'caller: $caller, '
      'id: $id, '
      'name: $name, '
      'namespace: $namespace, '
      'output: $output, '
      'status: $status, '
      'extra: ${extra?.length})';
}

/// The ResponsesReasoningItem wire payload.
@immutable
class ResponseReasoningItem extends ResponseOutputItem {
  /// Creates a [ResponseReasoningItem].
  const ResponseReasoningItem({
    this.content,
    this.encryptedContent,
    required this.id,
    this.status,
    required this.summary,
    this.extra,
  });

  /// The fixed type discriminator.
  String get type => 'reasoning';

  /// The content field.
  final List<ResponseReasoningText>? content;

  /// The encrypted_content field.
  final String? encryptedContent;

  /// The id field.
  final String id;

  /// The status field.
  final String? status;

  /// The summary field.
  final List<ResponseReasoningSummary> summary;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseReasoningItem] from JSON.
  factory ResponseReasoningItem.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'reasoning') {
      throw FormatException('ResponseReasoningItem: unexpected type $value');
    }
    if (json['id'] == null) {
      throw const FormatException('ResponseReasoningItem: missing id');
    }
    if (json['summary'] == null) {
      throw const FormatException('ResponseReasoningItem: missing summary');
    }
    return ResponseReasoningItem(
      content: json['content'] == null
          ? null
          : (json['content'] as List)
                .map(
                  (item) => ResponseReasoningText.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      encryptedContent: json['encrypted_content'] == null
          ? null
          : json['encrypted_content'] as String,
      id: json['id'] as String,
      status: json['status'] == null ? null : json['status'] as String,
      summary: (json['summary'] as List)
          .map(
            (item) => ResponseReasoningSummary.fromJson(
              item! as Map<String, dynamic>,
            ),
          )
          .toList(),
      extra: additionalJsonFields(json, const {
        'content',
        'encrypted_content',
        'id',
        'status',
        'summary',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    if (content != null)
      'content': content!.map((item) => item.toJson()).toList(),
    'encrypted_content': ?encryptedContent,
    'id': id,
    'status': ?status,
    'summary': summary.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ResponseReasoningItem copyWith({
    Object? content = unsetCopyWithValue,
    Object? encryptedContent = unsetCopyWithValue,
    String? id,
    Object? status = unsetCopyWithValue,
    List<ResponseReasoningSummary>? summary,
    Object? extra = unsetCopyWithValue,
  }) => ResponseReasoningItem(
    content: content == unsetCopyWithValue
        ? this.content
        : (content as List?)?.cast<ResponseReasoningText>(),
    encryptedContent: encryptedContent == unsetCopyWithValue
        ? this.encryptedContent
        : encryptedContent as String?,
    id: id ?? this.id,
    status: status == unsetCopyWithValue ? this.status : status as String?,
    summary: summary ?? this.summary,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseReasoningItem &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(content, other.content) &&
          encryptedContent == other.encryptedContent &&
          id == other.id &&
          status == other.status &&
          valuesDeepEqual(summary, other.summary) &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(content),
    encryptedContent,
    id,
    status,
    valueDeepHashCode(summary),
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseReasoningItem('
      'content: ${content?.length}, '
      'encryptedContent: $encryptedContent, '
      'id: $id, '
      'status: $status, '
      'summary: ${summary.length}, '
      'extra: ${extra?.length})';
}

/// The ResponsesCallerDirect wire payload.
@immutable
class ResponseDirectCaller extends ResponseCaller {
  /// Creates a [ResponseDirectCaller].
  const ResponseDirectCaller({this.extra});

  /// The fixed type discriminator.
  String get type => 'direct';

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseDirectCaller] from JSON.
  factory ResponseDirectCaller.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'direct') {
      throw FormatException('ResponseDirectCaller: unexpected type $value');
    }
    return ResponseDirectCaller(
      extra: additionalJsonFields(json, const {'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {...?extra, 'type': type};

  /// Creates a copy with the given fields replaced.
  ResponseDirectCaller copyWith({Object? extra = unsetCopyWithValue}) =>
      ResponseDirectCaller(
        extra: extra == unsetCopyWithValue
            ? this.extra
            : (extra as Map?)?.cast<String, dynamic>(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseDirectCaller &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseDirectCaller('
      'extra: ${extra?.length})';
}

/// The ResponsesCallerProgram wire payload.
@immutable
class ResponseProgramCaller extends ResponseCaller {
  /// Creates a [ResponseProgramCaller].
  const ResponseProgramCaller({required this.callerId, this.extra});

  /// The fixed type discriminator.
  String get type => 'program';

  /// The caller_id field.
  final String callerId;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseProgramCaller] from JSON.
  factory ResponseProgramCaller.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'program') {
      throw FormatException('ResponseProgramCaller: unexpected type $value');
    }
    if (json['caller_id'] == null) {
      throw const FormatException('ResponseProgramCaller: missing caller_id');
    }
    return ResponseProgramCaller(
      callerId: json['caller_id'] as String,
      extra: additionalJsonFields(json, const {'caller_id', 'type'}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'caller_id': callerId,
  };

  /// Creates a copy with the given fields replaced.
  ResponseProgramCaller copyWith({
    String? callerId,
    Object? extra = unsetCopyWithValue,
  }) => ResponseProgramCaller(
    callerId: callerId ?? this.callerId,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseProgramCaller &&
          runtimeType == other.runtimeType &&
          callerId == other.callerId &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([callerId, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseProgramCaller('
      'callerId: $callerId, '
      'extra: ${extra?.length})';
}

/// A message, tool result, or prior model output in Responses input.
///
/// Variants are [ResponseInputMessage], [ResponseFunctionCallOutput] and
/// [ResponseOutputItem]. Unknown variants preserve their JSON.
@immutable
sealed class ResponseItem {
  const ResponseItem();

  /// Parses a Responses input item.
  factory ResponseItem.fromJson(Map<String, dynamic> json) => switch (json) {
    {'type': 'function_call_output'} => ResponseFunctionCallOutput.fromJson(
      json,
    ),
    {'type': 'function_call' || 'reasoning'} => ResponseOutputItem.fromJson(
      json,
    ),
    {
      'type': 'message',
      'id': String _,
      'role': 'assistant',
      'status': String _,
      'content': final List<Object?> content,
    }
        when !content.any(_isInputPart) =>
      ResponseOutputMessage.fromJson(json),
    {'role': final String _}
        when json['type'] == null || json['type'] == 'message' =>
      ResponseInputMessage.fromJson(json),
    _ => UnknownResponseOutputItem(json),
  };

  static bool _isInputPart(Object? part) =>
      part is Map &&
      switch (part['type']) {
        'input_text' || 'input_image' || 'input_file' => true,
        _ => false,
      };

  /// Serializes this history item.
  Map<String, dynamic> toJson();
}

/// Model output that can be replayed as part of a stateless request.
///
/// Known variants are [ResponseOutputMessage], [ResponseFunctionCall] and
/// [ResponseReasoningItem]. [UnknownResponseOutputItem] preserves new types.
@immutable
sealed class ResponseOutputItem extends ResponseItem {
  const ResponseOutputItem();

  /// Parses a Responses output item.
  factory ResponseOutputItem.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'message' => ResponseOutputMessage.fromJson(json),
        'function_call' => ResponseFunctionCall.fromJson(json),
        'reasoning' => ResponseReasoningItem.fromJson(json),
        _ => UnknownResponseOutputItem(json),
      };
}

/// A future or unrecognized Responses item.
@immutable
final class UnknownResponseOutputItem extends ResponseOutputItem {
  /// Preserves the original payload.
  UnknownResponseOutputItem(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original wire payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseOutputItem && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// Plain input or a list of history items for a stateless response.
///
/// The wire variants are [ResponseInputText] and [ResponseInputItems].
@immutable
sealed class ResponseInput {
  const ResponseInput();

  /// Creates a text prompt.
  const factory ResponseInput.text(String text) = ResponseInputText;

  /// Creates input containing history, output and function results.
  const factory ResponseInput.items(List<ResponseItem> items) =
      ResponseInputItems;

  /// Parses a Responses input.
  factory ResponseInput.fromJson(Object json) => switch (json) {
    final String text => ResponseInputText(text),
    final List<Object?> items => ResponseInputItems(
      items
          .map((item) => ResponseItem.fromJson(item! as Map<String, dynamic>))
          .toList(),
    ),
    _ => throw const FormatException(
      'Expected Responses input text or history items',
    ),
  };

  /// Serializes the input value.
  Object toJson();
}

/// A short text prompt.
@immutable
final class ResponseInputText extends ResponseInput {
  /// Creates a text prompt.
  const ResponseInputText(this.text);

  /// The prompt text.
  final String text;

  @override
  String toJson() => text;

  @override
  bool operator ==(Object other) =>
      other is ResponseInputText && text == other.text;

  @override
  int get hashCode => text.hashCode;
}

/// An ordered list of messages, tool results and model output.
@immutable
final class ResponseInputItems extends ResponseInput {
  /// Creates a history input.
  const ResponseInputItems(this.items);

  /// The items supplied for this request.
  final List<ResponseItem> items;

  @override
  List<Map<String, dynamic>> toJson() =>
      items.map((item) => item.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      other is ResponseInputItems && listsEqual(items, other.items);

  @override
  int get hashCode => listHash(items);
}
