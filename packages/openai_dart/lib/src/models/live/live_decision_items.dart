import '../decisions/decision_input.dart';
import 'live_json_helpers.dart';

/// Native Live Decision evidence: text, image, JSON, output text or refusal.
///
/// Variants are [LiveDecisionInputTextParam], [LiveDecisionInputImageParam],
/// [LiveDecisionInputJsonParam], [LiveDecisionOutputTextParam] and
/// [LiveDecisionRefusalParam]. Each enclosing message/question restricts which
/// parts it admits. Native Live limits are independent of standalone Decisions.
sealed class LiveDecisionContentPart extends LiveJsonModel {
  const LiveDecisionContentPart();

  /// Parses one known native part without standalone Decisions restrictions.
  factory LiveDecisionContentPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'input_text' => LiveDecisionInputTextParam.fromJson(json),
        'input_image' => LiveDecisionInputImageParam.fromJson(json),
        'input_json' => LiveDecisionInputJsonParam.fromJson(json),
        'output_text' => LiveDecisionOutputTextParam.fromJson(json),
        'refusal' => LiveDecisionRefusalParam.fromJson(json),
        _ => throw const FormatException(
          'LiveDecisionContentPart.type: unsupported native part',
        ),
      };

  /// Fixed native part discriminator.
  String get type;

  /// Original immutable finite metadata, subordinate to typed fields.
  Map<String, dynamic> get rawJson;

  @override
  Map<String, dynamic> toJson();
}

/// Text evidence in a native Live Decision input or question.
final class LiveDecisionInputTextParam extends LiveDecisionContentPart {
  /// Preserves text exactly, including empty text.
  LiveDecisionInputTextParam({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionInputTextParam',
         knownKeys: _keys,
       ) {
    validate();
  }
  static const _keys = {'type', 'text'};

  /// Text containing at most 10,485,760 Unicode code points.
  final String text;
  @override
  final Map<String, dynamic> rawJson;
  @override
  String get type => 'input_text';

  /// Parses the required type and text.
  factory LiveDecisionInputTextParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'input_text', 'LiveDecisionInputTextParam');
    return LiveDecisionInputTextParam(
      text: requireLiveString(json['text'], 'LiveDecisionInputTextParam.text'),
      rawJson: json,
    );
  }
  @override
  void validate() => validateLiveLength(
    text,
    'LiveDecisionInputTextParam.text',
    max: 10485760,
  );
  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _keys, {'type': type, 'text': text});

  /// Copies text and future metadata.
  LiveDecisionInputTextParam copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionInputTextParam(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Native Live image evidence, preserving omitted versus null detail.
final class LiveDecisionInputImageParam extends LiveDecisionContentPart {
  /// Captures a data URL or public HTTP(S) URL without normalizing it.
  LiveDecisionInputImageParam({
    required this.imageUrl,
    this.detail,
    bool hasDetail = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasDetail = hasDetail || detail != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionInputImageParam',
         knownKeys: _keys,
       ) {
    validate();
  }
  static const _keys = {'type', 'image_url', 'detail'};

  /// Exact URL, at most 20,971,520 Unicode code points.
  final String imageUrl;

  /// Optional low/high/auto/original detail; null may be explicit.
  final String? detail;

  /// Whether detail was supplied, including explicit null.
  final bool hasDetail;
  @override
  final Map<String, dynamic> rawJson;
  @override
  String get type => 'input_image';

  /// Parses native image fields without standalone image or cache policy.
  factory LiveDecisionInputImageParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'input_image', 'LiveDecisionInputImageParam');
    return LiveDecisionInputImageParam(
      imageUrl: requireLiveString(
        json['image_url'],
        'LiveDecisionInputImageParam.image_url',
      ),
      detail: optionalLiveValue(
        json,
        'detail',
        'LiveDecisionInputImageParam',
        requireLiveString,
        nullable: true,
      ),
      hasDetail: json.containsKey('detail'),
      rawJson: json,
    );
  }
  @override
  void validate() {
    validateLiveLength(
      imageUrl,
      'LiveDecisionInputImageParam.imageUrl',
      max: 20971520,
    );
    if (!RegExp(r'^(data:|https?://)').hasMatch(imageUrl)) {
      throw const FormatException(
        'LiveDecisionInputImageParam.imageUrl: expected a data or HTTP(S) URL',
      );
    }
    if (detail != null &&
        !const {'low', 'high', 'auto', 'original'}.contains(detail)) {
      throw const FormatException(
        'LiveDecisionInputImageParam.detail: unsupported value',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'type': type,
    'image_url': imageUrl,
    if (hasDetail) 'detail': detail,
  });

  /// Copies fields; null sets detail to null, while clearDetail omits it.
  LiveDecisionInputImageParam copyWith({
    String? imageUrl,
    Object? detail = liveUnset,
    bool clearDetail = false,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionInputImageParam(
    imageUrl: imageUrl ?? this.imageUrl,
    detail: clearDetail
        ? null
        : copyLiveValue<String>(
            detail,
            this.detail,
            'LiveDecisionInputImageParam.detail',
          ),
    hasDetail: !clearDetail && (!identical(detail, liveUnset) || hasDetail),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Structured native Live evidence, with no standalone Decisions JSON quota.
final class LiveDecisionInputJsonParam extends LiveDecisionContentPart {
  /// Snapshots a finite JSON object or array of objects.
  LiveDecisionInputJsonParam({
    required Object data,
    Map<String, dynamic> rawJson = const {},
  }) : data = _snapshotDecisionData(data),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionInputJsonParam',
         knownKeys: _keys,
       );
  static const _keys = {'type', 'data'};

  /// Immutable original object or object array, including nested null values.
  final Object data;
  @override
  final Map<String, dynamic> rawJson;
  @override
  String get type => 'input_json';

  /// Parses an object or object array without standalone depth/byte limits.
  factory LiveDecisionInputJsonParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'input_json', 'LiveDecisionInputJsonParam');
    return LiveDecisionInputJsonParam(
      data: _snapshotDecisionData(json['data']),
      rawJson: json,
    );
  }
  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _keys, {'type': type, 'data': data});

  /// Copies and snapshots replacement data; null is not a valid top-level value.
  LiveDecisionInputJsonParam copyWith({
    Object? data = liveUnset,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionInputJsonParam(
    data: identical(data, liveUnset) ? this.data : _snapshotDecisionData(data),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Assistant output text used as native Live Decision evidence.
final class LiveDecisionOutputTextParam extends LiveDecisionContentPart {
  /// Captures assistant text exactly.
  LiveDecisionOutputTextParam({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionOutputTextParam',
         knownKeys: _keys,
       ) {
    validate();
  }
  static const _keys = {'type', 'text'};

  /// Text containing at most 10,485,760 Unicode code points.
  final String text;
  @override
  final Map<String, dynamic> rawJson;
  @override
  String get type => 'output_text';

  /// Parses the fixed type and required text.
  factory LiveDecisionOutputTextParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'output_text', 'LiveDecisionOutputTextParam');
    return LiveDecisionOutputTextParam(
      text: requireLiveString(json['text'], 'LiveDecisionOutputTextParam.text'),
      rawJson: json,
    );
  }
  @override
  void validate() => validateLiveLength(
    text,
    'LiveDecisionOutputTextParam.text',
    max: 10485760,
  );
  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _keys, {'type': type, 'text': text});

  /// Copies text and future metadata.
  LiveDecisionOutputTextParam copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionOutputTextParam(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Assistant refusal text used as native Live Decision evidence.
final class LiveDecisionRefusalParam extends LiveDecisionContentPart {
  /// Captures refusal text exactly.
  LiveDecisionRefusalParam({
    required this.refusal,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionRefusalParam',
         knownKeys: _keys,
       ) {
    validate();
  }
  static const _keys = {'type', 'refusal'};

  /// Refusal containing at most 10,485,760 Unicode code points.
  final String refusal;
  @override
  final Map<String, dynamic> rawJson;
  @override
  String get type => 'refusal';

  /// Parses the fixed type and required refusal.
  factory LiveDecisionRefusalParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'refusal', 'LiveDecisionRefusalParam');
    return LiveDecisionRefusalParam(
      refusal: requireLiveString(
        json['refusal'],
        'LiveDecisionRefusalParam.refusal',
      ),
      rawJson: json,
    );
  }
  @override
  void validate() => validateLiveLength(
    refusal,
    'LiveDecisionRefusalParam.refusal',
    max: 10485760,
  );
  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _keys, {'type': type, 'refusal': refusal});

  /// Copies refusal and future metadata.
  LiveDecisionRefusalParam copyWith({
    String? refusal,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionRefusalParam(
    refusal: refusal ?? this.refusal,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// String or typed parts in native Live Decision messages and tool outputs.
/// Variants are [LiveDecisionTextContent] and [LiveDecisionPartsContent].
sealed class LiveDecisionContent extends LiveJsonModel {
  const LiveDecisionContent();

  /// Captures text without converting it to a part array.
  const factory LiveDecisionContent.text(String text) = LiveDecisionTextContent;

  /// Copies an ordered array; role-specific validation happens in its item.
  factory LiveDecisionContent.parts(List<LiveDecisionContentPart> parts) =
      LiveDecisionPartsContent;

  /// Reads a native string or array, preserving that representation.
  factory LiveDecisionContent.fromJson(Object? json) {
    if (json is String) return LiveDecisionTextContent(json);
    return LiveDecisionPartsContent([
      for (final value in requireLiveList(json, 'LiveDecisionContent.parts'))
        LiveDecisionContentPart.fromJson(
          requireLiveObject(value, 'LiveDecisionContent.part'),
        ),
    ]);
  }
}

/// Literal text, including empty text, retained as a native string.
final class LiveDecisionTextContent extends LiveDecisionContent {
  /// Creates native text; enclosing admission validates its length.
  const LiveDecisionTextContent(this.text);

  /// Exact text.
  final String text;
  @override
  void validate() =>
      validateLiveLength(text, 'LiveDecisionTextContent.text', max: 10485760);
  @override
  String toJson() => text;

  /// Copies text.
  LiveDecisionTextContent copyWith({String? text}) =>
      LiveDecisionTextContent(text ?? this.text);
}

/// Ordered native parts; empty arrays remain valid for message/tool content.
final class LiveDecisionPartsContent extends LiveDecisionContent {
  /// Snapshots parts without introducing a standalone part-count limit.
  LiveDecisionPartsContent(List<LiveDecisionContentPart> parts)
    : parts = List.unmodifiable(parts) {
    validate();
  }

  /// Immutable ordered native parts.
  final List<LiveDecisionContentPart> parts;
  @override
  void validate() {
    for (final part in parts) {
      part.validate();
    }
  }

  @override
  List<Map<String, dynamic>> toJson() => [
    for (final part in parts) part.toJson(),
  ];

  /// Copies and snapshots replacement parts.
  LiveDecisionPartsContent copyWith({List<LiveDecisionContentPart>? parts}) =>
      LiveDecisionPartsContent(parts ?? this.parts);
}

/// A native Decision message, function/custom call, or tool output.
///
/// Variants are [LiveDecisionMessageParam], [LiveDecisionFunctionCallParam],
/// [LiveDecisionCustomToolCallParam], [LiveDecisionFunctionCallOutputParam] and
/// [LiveDecisionCustomToolCallOutputParam]. Message roles constrain content.
sealed class LiveDecisionInputItemParam extends LiveJsonModel {
  const LiveDecisionInputItemParam();

  /// Adapts supported standalone evidence without using it as a native parser.
  factory LiveDecisionInputItemParam.fromDecisionInputItem(
    DecisionInputItem item,
  ) => LiveDecisionInputItemParam.fromJson(item.toJson());

  /// Parses native optional message types, local IDs and nullable metadata.
  factory LiveDecisionInputItemParam.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        null || 'message' => LiveDecisionMessageParam.fromJson(json),
        'function_call' => LiveDecisionFunctionCallParam.fromJson(json),
        'custom_tool_call' => LiveDecisionCustomToolCallParam.fromJson(json),
        'function_call_output' => LiveDecisionFunctionCallOutputParam.fromJson(
          json,
        ),
        'custom_tool_call_output' =>
          LiveDecisionCustomToolCallOutputParam.fromJson(json),
        _ => throw const FormatException(
          'LiveDecisionInputItemParam.type: unsupported item',
        ),
      };

  /// The logical item type; message type can remain omitted on the wire.
  String get type;

  /// Optional local item ID.
  String? get id;

  /// Whether id is present, including explicit null.
  bool get hasId;

  /// Immutable finite metadata, subordinate to typed fields.
  Map<String, dynamic> get rawJson;
  @override
  Map<String, dynamic> toJson();
}

/// One role-specific native Decision message.
///
/// User parts admit text/images/JSON, developer/system only input text, and
/// assistant parts only output text/refusals. Message type omission is retained.
final class LiveDecisionMessageParam extends LiveDecisionInputItemParam {
  /// Captures a role-specific message, preserving optional/null ID and phase.
  LiveDecisionMessageParam({
    required this.role,
    required this.content,
    this.id,
    bool hasId = false,
    this.phase,
    bool hasPhase = false,
    this.includeType = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasId = hasId || id != null,
       hasPhase = hasPhase || phase != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionMessageParam',
         knownKeys: {
           'id',
           'type',
           'role',
           'content',
           if (role == 'assistant') 'phase',
         },
       ) {
    validate();
  }

  /// Creates user evidence, whose parts may contain text, images and JSON.
  factory LiveDecisionMessageParam.user({
    required LiveDecisionContent content,
    String? id,
    bool hasId = false,
    bool includeType = false,
    Map<String, dynamic> rawJson = const {},
  }) => LiveDecisionMessageParam(
    role: 'user',
    content: content,
    id: id,
    hasId: hasId,
    includeType: includeType,
    rawJson: rawJson,
  );

  /// Creates developer evidence, whose parts admit only input text.
  factory LiveDecisionMessageParam.developer({
    required LiveDecisionContent content,
    String? id,
    bool hasId = false,
    bool includeType = false,
    Map<String, dynamic> rawJson = const {},
  }) => LiveDecisionMessageParam(
    role: 'developer',
    content: content,
    id: id,
    hasId: hasId,
    includeType: includeType,
    rawJson: rawJson,
  );

  /// Creates system evidence, whose parts admit only input text.
  factory LiveDecisionMessageParam.system({
    required LiveDecisionContent content,
    String? id,
    bool hasId = false,
    bool includeType = false,
    Map<String, dynamic> rawJson = const {},
  }) => LiveDecisionMessageParam(
    role: 'system',
    content: content,
    id: id,
    hasId: hasId,
    includeType: includeType,
    rawJson: rawJson,
  );

  /// Creates assistant output/refusal evidence with an optional nullable phase.
  factory LiveDecisionMessageParam.assistant({
    required LiveDecisionContent content,
    String? id,
    bool hasId = false,
    String? phase,
    bool hasPhase = false,
    bool includeType = false,
    Map<String, dynamic> rawJson = const {},
  }) => LiveDecisionMessageParam(
    role: 'assistant',
    content: content,
    id: id,
    hasId: hasId,
    phase: phase,
    hasPhase: hasPhase,
    includeType: includeType,
    rawJson: rawJson,
  );
  Set<String> get _keys => {
    'id',
    'type',
    'role',
    'content',
    if (role == 'assistant') 'phase',
  };

  /// Required user/developer/system/assistant role.
  final String role;

  /// Required string or ordered parts.
  final LiveDecisionContent content;
  @override
  final String? id;
  @override
  final bool hasId;

  /// Optional assistant phase; null may be explicit.
  final String? phase;

  /// Whether assistant phase was supplied, including null.
  final bool hasPhase;

  /// Whether the optional message discriminator is written.
  final bool includeType;
  @override
  final Map<String, dynamic> rawJson;
  @override
  String get type => 'message';

  /// Parses a role-specific native message, rejecting malformed known fields.
  factory LiveDecisionMessageParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'message',
      'LiveDecisionMessageParam',
      required: false,
    );
    final role = requireLiveString(
      json['role'],
      'LiveDecisionMessageParam.role',
    );
    return LiveDecisionMessageParam(
      role: role,
      content: LiveDecisionContent.fromJson(json['content']),
      id: optionalLiveValue(
        json,
        'id',
        'LiveDecisionMessageParam',
        requireLiveString,
        nullable: true,
      ),
      hasId: json.containsKey('id'),
      phase: role == 'assistant'
          ? optionalLiveValue(
              json,
              'phase',
              'LiveDecisionMessageParam',
              requireLiveString,
              nullable: true,
            )
          : null,
      hasPhase: role == 'assistant' && json.containsKey('phase'),
      includeType: json.containsKey('type'),
      rawJson: json,
    );
  }
  @override
  void validate() {
    final allowed = switch (role) {
      'user' => const {'input_text', 'input_image', 'input_json'},
      'developer' || 'system' => const {'input_text'},
      'assistant' => const {'output_text', 'refusal'},
      _ => throw const FormatException(
        'LiveDecisionMessageParam.role: unsupported value',
      ),
    };
    if (role != 'assistant' && hasPhase) {
      throw const FormatException(
        'LiveDecisionMessageParam.phase: only assistant messages admit phase',
      );
    }
    if (phase != null &&
        !const {'commentary', 'final_answer'}.contains(phase)) {
      throw const FormatException(
        'LiveDecisionMessageParam.phase: unsupported value',
      );
    }
    _validateDecisionContent(
      content,
      allowed,
      'LiveDecisionMessageParam.content',
    );
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'role': role,
    'content': content.toJson(),
    if (includeType) 'type': type,
    if (hasId) 'id': id,
    if (hasPhase) 'phase': phase,
  });

  /// Copies fields; null writes nullable metadata, clear flags omit it.
  LiveDecisionMessageParam copyWith({
    String? role,
    LiveDecisionContent? content,
    Object? id = liveUnset,
    bool clearId = false,
    Object? phase = liveUnset,
    bool clearPhase = false,
    bool? includeType,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionMessageParam(
    role: role ?? this.role,
    content: content ?? this.content,
    id: clearId
        ? null
        : copyLiveValue<String>(id, this.id, 'LiveDecisionMessageParam.id'),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    phase: clearPhase
        ? null
        : copyLiveValue<String>(
            phase,
            this.phase,
            'LiveDecisionMessageParam.phase',
          ),
    hasPhase: !clearPhase && (!identical(phase, liveUnset) || hasPhase),
    includeType: includeType ?? this.includeType,
    rawJson: clearPhase
        ? {
            for (final entry in (rawJson ?? this.rawJson).entries)
              if (entry.key != 'phase') entry.key: entry.value,
          }
        : rawJson ?? this.rawJson,
  );
}

abstract class _LiveDecisionToolCallParam extends LiveDecisionInputItemParam {
  _LiveDecisionToolCallParam({
    required this.type,
    required this.callId,
    required this.name,
    required this.payload,
    this.id,
    bool hasId = false,
    this.namespace,
    bool hasNamespace = false,
    this.status,
    bool hasStatus = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasId = hasId || id != null,
       hasNamespace = hasNamespace || namespace != null,
       hasStatus = hasStatus || status != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionToolCallParam',
         knownKeys: {
           'type',
           'call_id',
           'name',
           'id',
           'namespace',
           'status',
           if (type == 'function_call') 'arguments' else 'input',
         },
       ) {
    validate();
  }
  Set<String> get _keys => {
    'type',
    'call_id',
    'name',
    'id',
    'namespace',
    'status',
    if (type == 'function_call') 'arguments' else 'input',
  };
  @override
  final String type;

  /// Required original call identifier, containing 1–64 code points.
  final String callId;

  /// Required tool name, using the function/custom naming contract.
  final String name;
  final String payload;
  @override
  final String? id;
  @override
  final bool hasId;

  /// Optional nullable tool namespace.
  final String? namespace;

  /// Whether namespace was supplied, including null.
  final bool hasNamespace;

  /// Optional nullable in_progress/completed/incomplete status.
  final String? status;

  /// Whether status was supplied, including null.
  final bool hasStatus;
  @override
  final Map<String, dynamic> rawJson;
  @override
  void validate() {
    validateLiveLength(
      callId,
      'LiveDecisionToolCallParam.callId',
      min: 1,
      max: 64,
    );
    _validateDecisionName(
      name,
      'LiveDecisionToolCallParam.name',
      function: type == 'function_call',
    );
    if (namespace != null) {
      _validateDecisionName(namespace!, 'LiveDecisionToolCallParam.namespace');
    }
    _validateDecisionStatus(status);
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'type': type,
    'call_id': callId,
    'name': name,
    if (type == 'function_call') 'arguments': payload else 'input': payload,
    if (hasId) 'id': id,
    if (hasNamespace) 'namespace': namespace,
    if (hasStatus) 'status': status,
  });
}

/// Native Live Decision function_call history with independent local item metadata.
final class LiveDecisionFunctionCallParam extends _LiveDecisionToolCallParam {
  /// Captures call data without standalone Decisions payload-size restrictions.
  LiveDecisionFunctionCallParam({
    required super.callId,
    required super.name,
    required String arguments,
    super.id,
    super.hasId,
    super.namespace,
    super.hasNamespace,
    super.status,
    super.hasStatus,
    super.rawJson,
  }) : super(type: 'function_call', payload: arguments);

  /// Exact original arguments; it is not parsed, normalized or executed.
  String get arguments => payload;

  /// Parses all required and nullable native fields.
  factory LiveDecisionFunctionCallParam.fromJson(Map<String, dynamic> json) {
    const context = 'LiveDecisionFunctionCallParam';
    requireLiveType(json, 'function_call', context);
    return LiveDecisionFunctionCallParam(
      callId: requireLiveString(json['call_id'], '$context.call_id'),
      name: requireLiveString(json['name'], '$context.name'),
      arguments: requireLiveString(json['arguments'], '$context.arguments'),
      id: _optionalDecisionString(json, 'id', context),
      hasId: json.containsKey('id'),
      namespace: _optionalDecisionString(json, 'namespace', context),
      hasNamespace: json.containsKey('namespace'),
      status: _optionalDecisionString(json, 'status', context),
      hasStatus: json.containsKey('status'),
      rawJson: json,
    );
  }

  /// Copies every field; null writes nullable metadata, clear flags omit it.
  LiveDecisionFunctionCallParam copyWith({
    String? callId,
    String? name,
    String? arguments,
    Object? id = liveUnset,
    bool clearId = false,
    Object? namespace = liveUnset,
    bool clearNamespace = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionFunctionCallParam(
    callId: callId ?? this.callId,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    id: clearId
        ? null
        : copyLiveValue<String>(
            id,
            this.id,
            'LiveDecisionFunctionCallParam.id',
          ),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    namespace: clearNamespace
        ? null
        : copyLiveValue<String>(
            namespace,
            this.namespace,
            'LiveDecisionFunctionCallParam.namespace',
          ),
    hasNamespace:
        !clearNamespace && (!identical(namespace, liveUnset) || hasNamespace),
    status: clearStatus
        ? null
        : copyLiveValue<String>(
            status,
            this.status,
            'LiveDecisionFunctionCallParam.status',
          ),
    hasStatus: !clearStatus && (!identical(status, liveUnset) || hasStatus),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Native Live Decision custom_tool_call history with independent local item metadata.
final class LiveDecisionCustomToolCallParam extends _LiveDecisionToolCallParam {
  /// Captures call data without standalone Decisions payload-size restrictions.
  LiveDecisionCustomToolCallParam({
    required super.callId,
    required super.name,
    required String input,
    super.id,
    super.hasId,
    super.namespace,
    super.hasNamespace,
    super.status,
    super.hasStatus,
    super.rawJson,
  }) : super(type: 'custom_tool_call', payload: input);

  /// Exact original input; it is not parsed, normalized or executed.
  String get input => payload;

  /// Parses all required and nullable native fields.
  factory LiveDecisionCustomToolCallParam.fromJson(Map<String, dynamic> json) {
    const context = 'LiveDecisionCustomToolCallParam';
    requireLiveType(json, 'custom_tool_call', context);
    return LiveDecisionCustomToolCallParam(
      callId: requireLiveString(json['call_id'], '$context.call_id'),
      name: requireLiveString(json['name'], '$context.name'),
      input: requireLiveString(json['input'], '$context.input'),
      id: _optionalDecisionString(json, 'id', context),
      hasId: json.containsKey('id'),
      namespace: _optionalDecisionString(json, 'namespace', context),
      hasNamespace: json.containsKey('namespace'),
      status: _optionalDecisionString(json, 'status', context),
      hasStatus: json.containsKey('status'),
      rawJson: json,
    );
  }

  /// Copies every field; null writes nullable metadata, clear flags omit it.
  LiveDecisionCustomToolCallParam copyWith({
    String? callId,
    String? name,
    String? input,
    Object? id = liveUnset,
    bool clearId = false,
    Object? namespace = liveUnset,
    bool clearNamespace = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionCustomToolCallParam(
    callId: callId ?? this.callId,
    name: name ?? this.name,
    input: input ?? this.input,
    id: clearId
        ? null
        : copyLiveValue<String>(
            id,
            this.id,
            'LiveDecisionCustomToolCallParam.id',
          ),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    namespace: clearNamespace
        ? null
        : copyLiveValue<String>(
            namespace,
            this.namespace,
            'LiveDecisionCustomToolCallParam.namespace',
          ),
    hasNamespace:
        !clearNamespace && (!identical(namespace, liveUnset) || hasNamespace),
    status: clearStatus
        ? null
        : copyLiveValue<String>(
            status,
            this.status,
            'LiveDecisionCustomToolCallParam.status',
          ),
    hasStatus: !clearStatus && (!identical(status, liveUnset) || hasStatus),
    rawJson: rawJson ?? this.rawJson,
  );
}

abstract class _LiveDecisionToolOutputParam extends LiveDecisionInputItemParam {
  _LiveDecisionToolOutputParam({
    required this.type,
    required this.callId,
    required this.output,
    this.id,
    bool hasId = false,
    this.status,
    bool hasStatus = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasId = hasId || id != null,
       hasStatus = hasStatus || status != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveDecisionToolOutputParam',
         knownKeys: _keys,
       ) {
    validate();
  }
  static const _keys = {'type', 'call_id', 'output', 'id', 'status'};
  @override
  final String type;

  /// Required original call identifier, containing 1–64 code points.
  final String callId;

  /// String or text/image output parts; JSON parts are not admitted here.
  final LiveDecisionContent output;
  @override
  final String? id;
  @override
  final bool hasId;

  /// Optional nullable in_progress/completed/incomplete status.
  final String? status;

  /// Whether status was supplied, including null.
  final bool hasStatus;
  @override
  final Map<String, dynamic> rawJson;
  @override
  void validate() {
    validateLiveLength(
      callId,
      'LiveDecisionToolOutputParam.callId',
      min: 1,
      max: 64,
    );
    _validateDecisionStatus(status);
    _validateDecisionContent(output, const {
      'input_text',
      'input_image',
    }, 'LiveDecisionToolOutputParam.output');
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _keys, {
    'type': type,
    'call_id': callId,
    'output': output.toJson(),
    if (hasId) 'id': id,
    if (hasStatus) 'status': status,
  });
}

/// Native Live Decision function_call_output evidence, preserving delivery metadata.
final class LiveDecisionFunctionCallOutputParam
    extends _LiveDecisionToolOutputParam {
  /// Captures tool output without running or reconstructing the tool call.
  LiveDecisionFunctionCallOutputParam({
    required super.callId,
    required super.output,
    super.id,
    super.hasId,
    super.status,
    super.hasStatus,
    super.rawJson,
  }) : super(type: 'function_call_output');

  /// Parses required output and optional nullable metadata.
  factory LiveDecisionFunctionCallOutputParam.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'LiveDecisionFunctionCallOutputParam';
    requireLiveType(json, 'function_call_output', context);
    return LiveDecisionFunctionCallOutputParam(
      callId: requireLiveString(json['call_id'], '$context.call_id'),
      output: LiveDecisionContent.fromJson(json['output']),
      id: _optionalDecisionString(json, 'id', context),
      hasId: json.containsKey('id'),
      status: _optionalDecisionString(json, 'status', context),
      hasStatus: json.containsKey('status'),
      rawJson: json,
    );
  }

  /// Copies every field; null writes nullable metadata, clear flags omit it.
  LiveDecisionFunctionCallOutputParam copyWith({
    String? callId,
    LiveDecisionContent? output,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionFunctionCallOutputParam(
    callId: callId ?? this.callId,
    output: output ?? this.output,
    id: clearId
        ? null
        : copyLiveValue<String>(
            id,
            this.id,
            'LiveDecisionFunctionCallOutputParam.id',
          ),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    status: clearStatus
        ? null
        : copyLiveValue<String>(
            status,
            this.status,
            'LiveDecisionFunctionCallOutputParam.status',
          ),
    hasStatus: !clearStatus && (!identical(status, liveUnset) || hasStatus),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Native Live Decision custom_tool_call_output evidence, preserving delivery metadata.
final class LiveDecisionCustomToolCallOutputParam
    extends _LiveDecisionToolOutputParam {
  /// Captures tool output without running or reconstructing the tool call.
  LiveDecisionCustomToolCallOutputParam({
    required super.callId,
    required super.output,
    super.id,
    super.hasId,
    super.status,
    super.hasStatus,
    super.rawJson,
  }) : super(type: 'custom_tool_call_output');

  /// Parses required output and optional nullable metadata.
  factory LiveDecisionCustomToolCallOutputParam.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'LiveDecisionCustomToolCallOutputParam';
    requireLiveType(json, 'custom_tool_call_output', context);
    return LiveDecisionCustomToolCallOutputParam(
      callId: requireLiveString(json['call_id'], '$context.call_id'),
      output: LiveDecisionContent.fromJson(json['output']),
      id: _optionalDecisionString(json, 'id', context),
      hasId: json.containsKey('id'),
      status: _optionalDecisionString(json, 'status', context),
      hasStatus: json.containsKey('status'),
      rawJson: json,
    );
  }

  /// Copies every field; null writes nullable metadata, clear flags omit it.
  LiveDecisionCustomToolCallOutputParam copyWith({
    String? callId,
    LiveDecisionContent? output,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    Map<String, dynamic>? rawJson,
  }) => LiveDecisionCustomToolCallOutputParam(
    callId: callId ?? this.callId,
    output: output ?? this.output,
    id: clearId
        ? null
        : copyLiveValue<String>(
            id,
            this.id,
            'LiveDecisionCustomToolCallOutputParam.id',
          ),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    status: clearStatus
        ? null
        : copyLiveValue<String>(
            status,
            this.status,
            'LiveDecisionCustomToolCallOutputParam.status',
          ),
    hasStatus: !clearStatus && (!identical(status, liveUnset) || hasStatus),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A confirmed stored native item, sharing its typed input representation.
///
/// All stored variants require a nonnull string ID. The schema adds no length
/// bound to that ID; empty or future opaque identifiers are preserved.
final class LiveDecisionStoredInputItemParam extends LiveJsonModel {
  /// Requires an explicitly present nonnull ID on the typed item.
  LiveDecisionStoredInputItemParam({required this.item}) {
    validate();
  }

  /// Underlying role-specific message or function/custom-tool history.
  final LiveDecisionInputItemParam item;

  /// The required canonical stored item ID.
  String get id => item.id!;

  /// Logical item type; optional message type omission is retained.
  String get type => item.type;

  /// Preserved immutable finite source metadata.
  Map<String, dynamic> get rawJson => item.rawJson;

  /// Parses the same native variants with the stricter stored-ID contract.
  factory LiveDecisionStoredInputItemParam.fromJson(
    Map<String, dynamic> json,
  ) => LiveDecisionStoredInputItemParam(
    item: LiveDecisionInputItemParam.fromJson(json),
  );
  @override
  void validate() {
    item.validate();
    if (!item.hasId || item.id == null) {
      throw const FormatException(
        'LiveDecisionStoredInputItemParam.id: expected a required string',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => item.toJson();

  /// Copies the item or its ID; the stored-ID requirement remains enforced.
  LiveDecisionStoredInputItemParam copyWith({
    LiveDecisionInputItemParam? item,
    String? id,
  }) {
    final replacement = item ?? this.item;
    return LiveDecisionStoredInputItemParam(
      item: id == null
          ? replacement
          : LiveDecisionInputItemParam.fromJson({
              ...replacement.toJson(),
              'id': id,
            }),
    );
  }
}

Object _snapshotDecisionData(Object? data) {
  if (data is! Map && data is! List) {
    throw const FormatException(
      'LiveDecisionInputJsonParam.data: expected an object or object array',
    );
  }
  if (data is List && data.any((value) => value is! Map)) {
    throw const FormatException(
      'LiveDecisionInputJsonParam.data: expected an object array',
    );
  }
  return snapshotLiveJson(
        {'data': data},
        'LiveDecisionInputJsonParam',
        knownKeys: {'data'},
      )['data']
      as Object;
}

String? _optionalDecisionString(
  Map<String, dynamic> json,
  String key,
  String context,
) => optionalLiveValue(json, key, context, requireLiveString, nullable: true);

void _validateDecisionName(
  String value,
  String context, {
  bool function = false,
}) {
  validateLiveLength(value, context, min: 1, max: function ? 128 : 64);
  if (!RegExp(
    function ? r'^[a-zA-Z0-9_.-]+$' : r'^[a-zA-Z0-9_-]+$',
  ).hasMatch(value)) {
    throw FormatException('$context: invalid name');
  }
}

void _validateDecisionStatus(String? status) {
  if (status != null &&
      !const {'in_progress', 'completed', 'incomplete'}.contains(status)) {
    throw const FormatException(
      'LiveDecisionInputItemParam.status: unsupported value',
    );
  }
}

void _validateDecisionContent(
  LiveDecisionContent content,
  Set<String> allowed,
  String context,
) {
  content.validate();
  if (content is LiveDecisionPartsContent) {
    for (final part in content.parts) {
      if (!allowed.contains(part.type)) {
        throw FormatException('$context: unsupported part for this role');
      }
    }
  }
}
