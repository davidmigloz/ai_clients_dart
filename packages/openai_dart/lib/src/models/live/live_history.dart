import 'package:meta/meta.dart';

import 'live_json_helpers.dart';

/// Canonical closed values for LiveInitialMessageStatus.
enum LiveInitialMessageStatus {
  /// The `incomplete` wire value.
  incomplete('incomplete'),

  /// The `completed` wire value.
  completed('completed');

  const LiveInitialMessageStatus(this.value);

  /// The exact API wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a closed wire value without echoing private input.
  static LiveInitialMessageStatus fromJson(String value) {
    for (final item in LiveInitialMessageStatus.values) {
      if (item.value == value) return item;
    }
    throw const FormatException(
      'LiveInitialMessageStatus: expected a supported value',
    );
  }
}

/// Text supplied in a developer or user message when starting a Live session.
@immutable
class LiveInitialInputTextContentPartParam extends LiveJsonModel {
  /// Creates LiveInitialInputTextContentPartParam.
  LiveInitialInputTextContentPartParam({
    required this.text,
    this.hasType = false,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialInputTextContentPartParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'text', 'type'};

  /// The message text to include in the Live session’s initial conversation history.
  final String text;

  /// The text content type. Always `input_text`.
  String get type => 'input_text';

  /// Whether the optional fixed type field is present.
  final bool hasType;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialInputTextContentPartParam with contextual validation.
  factory LiveInitialInputTextContentPartParam.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(
      json,
      'input_text',
      'LiveInitialInputTextContentPartParam',
      key: 'type',
      required: false,
    );
    return LiveInitialInputTextContentPartParam(
      text: requireLiveString(
        json['text'],
        'LiveInitialInputTextContentPartParam.text',
      ),
      hasType: json.containsKey('type'),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'text': text,
    if (hasType) 'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialInputTextContentPartParam copyWith({
    String? text,
    bool? hasType,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialInputTextContentPartParam(
    text: text ?? this.text,
    hasType: hasType ?? this.hasType,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialInputTextContentPartParam('
      'text: ${livePresence(text)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Assistant text supplied as conversation history when starting a Live session.
@immutable
class LiveInitialTextContentPartParam extends LiveInitialAssistantContentPart {
  /// Creates LiveInitialTextContentPartParam.
  LiveInitialTextContentPartParam({
    required this.text,
    this.hasType = false,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialTextContentPartParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'text', 'type'};

  /// The message text to include in the Live session’s initial conversation history.
  @override
  final String text;

  /// The text content type. Always `text`.
  @override
  String get type => 'text';

  /// Whether the optional fixed type field is present.
  final bool hasType;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialTextContentPartParam with contextual validation.
  factory LiveInitialTextContentPartParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'text',
      'LiveInitialTextContentPartParam',
      key: 'type',
      required: false,
    );
    return LiveInitialTextContentPartParam(
      text: requireLiveString(
        json['text'],
        'LiveInitialTextContentPartParam.text',
      ),
      hasType: json.containsKey('type'),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'text': text,
    if (hasType) 'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialTextContentPartParam copyWith({
    String? text,
    bool? hasType,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialTextContentPartParam(
    text: text ?? this.text,
    hasType: hasType ?? this.hasType,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialTextContentPartParam('
      'text: ${livePresence(text)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// Assistant output text supplied as conversation history when starting a Live session.
@immutable
class LiveInitialOutputTextContentPartParam
    extends LiveInitialAssistantContentPart {
  /// Creates LiveInitialOutputTextContentPartParam.
  LiveInitialOutputTextContentPartParam({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialOutputTextContentPartParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'text', 'type'};

  /// The message text to include in the Live session’s initial conversation history.
  @override
  final String text;

  /// The text content type. Always `output_text`.
  @override
  String get type => 'output_text';

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialOutputTextContentPartParam with contextual validation.
  factory LiveInitialOutputTextContentPartParam.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(
      json,
      'output_text',
      'LiveInitialOutputTextContentPartParam',
      key: 'type',
      required: true,
    );
    return LiveInitialOutputTextContentPartParam(
      text: requireLiveString(
        json['text'],
        'LiveInitialOutputTextContentPartParam.text',
      ),
      rawJson: json,
    );
  }

  @override
  void validate() {}

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'text': text, 'type': type});

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialOutputTextContentPartParam copyWith({
    String? text,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialOutputTextContentPartParam(
    text: text ?? this.text,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialOutputTextContentPartParam('
      'text: ${livePresence(text)}, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// A developer message included in the initial text history of a Live session.
@immutable
class LiveInitialDeveloperMessageItemParam extends LiveInitialItem {
  /// Creates LiveInitialDeveloperMessageItemParam.
  LiveInitialDeveloperMessageItemParam({
    required List<LiveInitialInputTextContentPartParam> content,
    this.id,
    bool hasId = false,
    this.status,
    bool hasStatus = false,
    this.hasType = false,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       hasId = hasId || id != null,
       hasStatus = hasStatus || status != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialDeveloperMessageItemParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'content', 'id', 'role', 'status', 'type'};

  /// The message content. Supply exactly one text part for the initial Live conversation history.
  final List<LiveInitialInputTextContentPartParam> content;

  /// An optional identifier for the supplied history message. Live uses the message’s role and text to initialize the conversation.
  final String? id;

  /// Distinguishes omission from explicit null for id.
  final bool hasId;

  /// The author of this history message. Always `developer`.
  @override
  String get role => 'developer';

  /// The supplied message’s status. Live uses its text as history and does not resume an incomplete message.
  final LiveInitialMessageStatus? status;

  /// Distinguishes omission from explicit null for status.
  final bool hasStatus;

  /// The history item type. Always `message`.
  String get type => 'message';

  /// Whether the optional fixed type field is present.
  final bool hasType;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialDeveloperMessageItemParam with contextual validation.
  factory LiveInitialDeveloperMessageItemParam.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(
      json,
      'developer',
      'LiveInitialDeveloperMessageItemParam',
      key: 'role',
      required: true,
    );
    requireLiveType(
      json,
      'message',
      'LiveInitialDeveloperMessageItemParam',
      key: 'type',
      required: false,
    );
    return LiveInitialDeveloperMessageItemParam(
      content:
          requireLiveList(
                json['content'],
                'LiveInitialDeveloperMessageItemParam.content',
              )
              .map(
                (item) => LiveInitialInputTextContentPartParam.fromJson(
                  requireLiveObject(
                    item,
                    'LiveInitialDeveloperMessageItemParam.content',
                  ),
                ),
              )
              .toList(),
      id: optionalLiveValue(
        json,
        'id',
        'LiveInitialDeveloperMessageItemParam',
        requireLiveString,
        nullable: true,
      ),
      hasId: json.containsKey('id'),
      status: optionalLiveValue(
        json,
        'status',
        'LiveInitialDeveloperMessageItemParam',
        (value, context) => LiveInitialMessageStatus.fromJson(
          requireLiveString(value, context),
        ),
        nullable: true,
      ),
      hasStatus: json.containsKey('status'),
      hasType: json.containsKey('type'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    {
      if (content.isEmpty || content.length > 1) {
        throw const FormatException(
          'LiveInitialDeveloperMessageItemParam.content: invalid item count',
        );
      }
    }
    for (final item in content) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'content': content.map((item) => item.toJson()).toList(),
    if (hasId) 'id': id,
    'role': role,
    if (hasStatus) 'status': status?.toJson(),
    if (hasType) 'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialDeveloperMessageItemParam copyWith({
    List<LiveInitialInputTextContentPartParam>? content,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    bool? hasType,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialDeveloperMessageItemParam(
    content: content ?? this.content,
    id: clearId
        ? null
        : copyLiveValue<String>(
            id,
            this.id,
            'LiveInitialDeveloperMessageItemParam.id',
          ),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    status: clearStatus
        ? null
        : copyLiveValue<LiveInitialMessageStatus>(
            status,
            this.status,
            'LiveInitialDeveloperMessageItemParam.status',
          ),
    hasStatus: !clearStatus && (!identical(status, liveUnset) || hasStatus),
    hasType: hasType ?? this.hasType,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialDeveloperMessageItemParam('
      'content: ${livePresence(content)}, '
      'id: ${livePresence(id)}, '
      'hasId: $hasId, '
      'role: $role, '
      'status: ${livePresence(status)}, '
      'hasStatus: $hasStatus, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// A user message included in the initial text history of a Live session.
@immutable
class LiveInitialUserMessageItemParam extends LiveInitialItem {
  /// Creates LiveInitialUserMessageItemParam.
  LiveInitialUserMessageItemParam({
    required List<LiveInitialInputTextContentPartParam> content,
    this.id,
    bool hasId = false,
    this.status,
    bool hasStatus = false,
    this.hasType = false,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       hasId = hasId || id != null,
       hasStatus = hasStatus || status != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialUserMessageItemParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'content', 'id', 'role', 'status', 'type'};

  /// The message content. Supply exactly one text part for the initial Live conversation history.
  final List<LiveInitialInputTextContentPartParam> content;

  /// An optional identifier for the supplied history message. Live uses the message’s role and text to initialize the conversation.
  final String? id;

  /// Distinguishes omission from explicit null for id.
  final bool hasId;

  /// The author of this history message. Always `user`.
  @override
  String get role => 'user';

  /// The supplied message’s status. Live uses its text as history and does not resume an incomplete message.
  final LiveInitialMessageStatus? status;

  /// Distinguishes omission from explicit null for status.
  final bool hasStatus;

  /// The history item type. Always `message`.
  String get type => 'message';

  /// Whether the optional fixed type field is present.
  final bool hasType;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialUserMessageItemParam with contextual validation.
  factory LiveInitialUserMessageItemParam.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'user',
      'LiveInitialUserMessageItemParam',
      key: 'role',
      required: true,
    );
    requireLiveType(
      json,
      'message',
      'LiveInitialUserMessageItemParam',
      key: 'type',
      required: false,
    );
    return LiveInitialUserMessageItemParam(
      content:
          requireLiveList(
                json['content'],
                'LiveInitialUserMessageItemParam.content',
              )
              .map(
                (item) => LiveInitialInputTextContentPartParam.fromJson(
                  requireLiveObject(
                    item,
                    'LiveInitialUserMessageItemParam.content',
                  ),
                ),
              )
              .toList(),
      id: optionalLiveValue(
        json,
        'id',
        'LiveInitialUserMessageItemParam',
        requireLiveString,
        nullable: true,
      ),
      hasId: json.containsKey('id'),
      status: optionalLiveValue(
        json,
        'status',
        'LiveInitialUserMessageItemParam',
        (value, context) => LiveInitialMessageStatus.fromJson(
          requireLiveString(value, context),
        ),
        nullable: true,
      ),
      hasStatus: json.containsKey('status'),
      hasType: json.containsKey('type'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    {
      if (content.isEmpty || content.length > 1) {
        throw const FormatException(
          'LiveInitialUserMessageItemParam.content: invalid item count',
        );
      }
    }
    for (final item in content) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'content': content.map((item) => item.toJson()).toList(),
    if (hasId) 'id': id,
    'role': role,
    if (hasStatus) 'status': status?.toJson(),
    if (hasType) 'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialUserMessageItemParam copyWith({
    List<LiveInitialInputTextContentPartParam>? content,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    bool? hasType,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialUserMessageItemParam(
    content: content ?? this.content,
    id: clearId
        ? null
        : copyLiveValue<String>(
            id,
            this.id,
            'LiveInitialUserMessageItemParam.id',
          ),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    status: clearStatus
        ? null
        : copyLiveValue<LiveInitialMessageStatus>(
            status,
            this.status,
            'LiveInitialUserMessageItemParam.status',
          ),
    hasStatus: !clearStatus && (!identical(status, liveUnset) || hasStatus),
    hasType: hasType ?? this.hasType,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialUserMessageItemParam('
      'content: ${livePresence(content)}, '
      'id: ${livePresence(id)}, '
      'hasId: $hasId, '
      'role: $role, '
      'status: ${livePresence(status)}, '
      'hasStatus: $hasStatus, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// An assistant message included in the initial text history of a Live session.
@immutable
class LiveInitialAssistantMessageItemParam extends LiveInitialItem {
  /// Creates LiveInitialAssistantMessageItemParam.
  LiveInitialAssistantMessageItemParam({
    required List<LiveInitialAssistantContentPart> content,
    this.id,
    bool hasId = false,
    this.status,
    bool hasStatus = false,
    this.hasType = false,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       hasId = hasId || id != null,
       hasStatus = hasStatus || status != null,
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveInitialAssistantMessageItemParam',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  static const _knownKeys = {'content', 'id', 'role', 'status', 'type'};

  /// The message content. Supply exactly one text part for the initial Live conversation history.
  final List<LiveInitialAssistantContentPart> content;

  /// An optional identifier for the supplied history message. Live uses the message’s role and text to initialize the conversation.
  final String? id;

  /// Distinguishes omission from explicit null for id.
  final bool hasId;

  /// The author of this history message. Always `assistant`.
  @override
  String get role => 'assistant';

  /// The supplied message’s status. Live uses its text as history and does not resume an incomplete message.
  final LiveInitialMessageStatus? status;

  /// Distinguishes omission from explicit null for status.
  final bool hasStatus;

  /// The history item type. Always `message`.
  String get type => 'message';

  /// Whether the optional fixed type field is present.
  final bool hasType;

  /// Immutable finite JSON; typed fields control known wire members.
  final Map<String, dynamic> rawJson;

  /// Parses LiveInitialAssistantMessageItemParam with contextual validation.
  factory LiveInitialAssistantMessageItemParam.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(
      json,
      'assistant',
      'LiveInitialAssistantMessageItemParam',
      key: 'role',
      required: true,
    );
    requireLiveType(
      json,
      'message',
      'LiveInitialAssistantMessageItemParam',
      key: 'type',
      required: false,
    );
    return LiveInitialAssistantMessageItemParam(
      content:
          requireLiveList(
                json['content'],
                'LiveInitialAssistantMessageItemParam.content',
              )
              .map(
                (item) => LiveInitialAssistantContentPart.fromJson(
                  requireLiveObject(
                    item,
                    'LiveInitialAssistantMessageItemParam.content',
                  ),
                ),
              )
              .toList(),
      id: optionalLiveValue(
        json,
        'id',
        'LiveInitialAssistantMessageItemParam',
        requireLiveString,
        nullable: true,
      ),
      hasId: json.containsKey('id'),
      status: optionalLiveValue(
        json,
        'status',
        'LiveInitialAssistantMessageItemParam',
        (value, context) => LiveInitialMessageStatus.fromJson(
          requireLiveString(value, context),
        ),
        nullable: true,
      ),
      hasStatus: json.containsKey('status'),
      hasType: json.containsKey('type'),
      rawJson: json,
    );
  }

  @override
  void validate() {
    {
      if (content.isEmpty || content.length > 1) {
        throw const FormatException(
          'LiveInitialAssistantMessageItemParam.content: invalid item count',
        );
      }
    }
    for (final item in content) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'content': content.map((item) => item.toJson()).toList(),
    if (hasId) 'id': id,
    'role': role,
    if (hasStatus) 'status': status?.toJson(),
    if (hasType) 'type': type,
  });

  /// Copies fields; explicit null clears optional values.
  /// For nullable fields, clear flags remove the key rather than emit null.
  LiveInitialAssistantMessageItemParam copyWith({
    List<LiveInitialAssistantContentPart>? content,
    Object? id = liveUnset,
    bool clearId = false,
    Object? status = liveUnset,
    bool clearStatus = false,
    bool? hasType,
    Map<String, dynamic>? rawJson,
  }) => LiveInitialAssistantMessageItemParam(
    content: content ?? this.content,
    id: clearId
        ? null
        : copyLiveValue<String>(
            id,
            this.id,
            'LiveInitialAssistantMessageItemParam.id',
          ),
    hasId: !clearId && (!identical(id, liveUnset) || hasId),
    status: clearStatus
        ? null
        : copyLiveValue<LiveInitialMessageStatus>(
            status,
            this.status,
            'LiveInitialAssistantMessageItemParam.status',
          ),
    hasStatus: !clearStatus && (!identical(status, liveUnset) || hasStatus),
    hasType: hasType ?? this.hasType,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  String toString() =>
      'LiveInitialAssistantMessageItemParam('
      'content: ${livePresence(content)}, '
      'id: ${livePresence(id)}, '
      'hasId: $hasId, '
      'role: $role, '
      'status: ${livePresence(status)}, '
      'hasStatus: $hasStatus, '
      'type: $type, '
      'rawJson: [REDACTED])';
}

/// A text-only startup history message with a required role discriminator.
sealed class LiveInitialItem extends LiveJsonModel {
  /// Creates a startup message.
  const LiveInitialItem();

  /// The canonical history role.
  String get role;

  /// Parses developer, user or assistant history only.
  static LiveInitialItem fromJson(Map<String, dynamic> json) =>
      switch (json['role']) {
        'developer' => LiveInitialDeveloperMessageItemParam.fromJson(json),
        'user' => LiveInitialUserMessageItemParam.fromJson(json),
        'assistant' => LiveInitialAssistantMessageItemParam.fromJson(json),
        _ => throw const FormatException(
          'LiveInitialItem.role: unsupported history role',
        ),
      };
}

/// One assistant text part, with `text` as the canonical omitted-type default.
sealed class LiveInitialAssistantContentPart extends LiveJsonModel {
  /// Creates an assistant text value.
  const LiveInitialAssistantContentPart();

  /// The canonical content type.
  String get type;

  /// The original text.
  String get text;

  /// Parses only the assistant text and output_text branches.
  static LiveInitialAssistantContentPart fromJson(Map<String, dynamic> json) =>
      switch (json.containsKey('type') ? json['type'] : 'text') {
        'text' => LiveInitialTextContentPartParam.fromJson(json),
        'output_text' => LiveInitialOutputTextContentPartParam.fromJson(json),
        _ => throw const FormatException(
          'LiveInitialAssistantContentPart.type: unsupported text part',
        ),
      };
}
