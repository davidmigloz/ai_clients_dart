part of 'agent_session_models.dart';

/// One page of private root-session history. Null boundary IDs remain present.
final class AgentSessionItemList extends AgentJsonModel {
  /// Creates a detached, validated history page.
  AgentSessionItemList({
    required List<AgentSessionTurnItem> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, _keys, 'AgentSessionItemList') {
    validate();
  }
  static const _keys = ['data', 'object', 'first_id', 'last_id', 'has_more'];

  /// Exact root-history items on this page; no action is automatically replayed.
  final List<AgentSessionTurnItem> data;

  /// First ID, or null for an empty page.
  final String? firstId;

  /// Exclusive next-page cursor, or null for an empty page.
  final String? lastId;

  /// Whether the service reports additional pages.
  final bool hasMore;

  /// Canonical page tag.
  String get object => 'list';

  /// Detached future received fields, omitted from default diagnostics.
  final Map<String, dynamic> rawJson;

  /// Parses required keys and nullable boundaries without discarding nulls.
  factory AgentSessionItemList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentSessionItemList.object');
    return AgentSessionItemList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionItemList.data',
        (v, c) => requireAgentList(v, c)
            .map((v) => AgentSessionTurnItem.fromJson(requireAgentObject(v, c)))
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentSessionItemList.firstId',
        requireAgentString,
        nullable: true,
      ),
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentSessionItemList.lastId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentSessionItemList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!_keys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(data.length, 'AgentSessionItemList.data', max: 2000);
    for (final item in data) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'data': data.map((x) => x.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  /// Copies values. Explicit null clears a boundary while omission retains it.
  AgentSessionItemList copyWith({
    List<AgentSessionTurnItem>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionItemList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(firstId, this.firstId, 'History firstId'),
    lastId: copyAgentValue<String>(lastId, this.lastId, 'History lastId'),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// One page of private root-session history. Null boundary IDs remain present.
final class AgentSessionTurnList extends AgentJsonModel {
  /// Creates a detached, validated history page.
  AgentSessionTurnList({
    required List<AgentSessionTurn> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, _keys, 'AgentSessionTurnList') {
    validate();
  }
  static const _keys = ['data', 'object', 'first_id', 'last_id', 'has_more'];

  /// Exact root-history items on this page; no action is automatically replayed.
  final List<AgentSessionTurn> data;

  /// First ID, or null for an empty page.
  final String? firstId;

  /// Exclusive next-page cursor, or null for an empty page.
  final String? lastId;

  /// Whether the service reports additional pages.
  final bool hasMore;

  /// Canonical page tag.
  String get object => 'list';

  /// Detached future received fields, omitted from default diagnostics.
  final Map<String, dynamic> rawJson;

  /// Parses required keys and nullable boundaries without discarding nulls.
  factory AgentSessionTurnList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentSessionTurnList.object');
    return AgentSessionTurnList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionTurnList.data',
        (v, c) => requireAgentList(v, c)
            .map((v) => AgentSessionTurn.fromJson(requireAgentObject(v, c)))
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentSessionTurnList.firstId',
        requireAgentString,
        nullable: true,
      ),
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentSessionTurnList.lastId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentSessionTurnList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!_keys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(data.length, 'AgentSessionTurnList.data', max: 2000);
    for (final item in data) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'data': data.map((x) => x.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  /// Copies values. Explicit null clears a boundary while omission retains it.
  AgentSessionTurnList copyWith({
    List<AgentSessionTurn>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(firstId, this.firstId, 'History firstId'),
    lastId: copyAgentValue<String>(lastId, this.lastId, 'History lastId'),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// One page of private root-session history. Null boundary IDs remain present.
final class AgentSessionTraceList extends AgentJsonModel {
  /// Creates a detached, validated history page.
  AgentSessionTraceList({
    required List<AgentSessionTurnTrace> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, _keys, 'AgentSessionTraceList') {
    validate();
  }
  static const _keys = ['data', 'object', 'first_id', 'last_id', 'has_more'];

  /// Exact root-history items on this page; no action is automatically replayed.
  final List<AgentSessionTurnTrace> data;

  /// First ID, or null for an empty page.
  final String? firstId;

  /// Exclusive next-page cursor, or null for an empty page.
  final String? lastId;

  /// Whether the service reports additional pages.
  final bool hasMore;

  /// Canonical page tag.
  String get object => 'list';

  /// Detached future received fields, omitted from default diagnostics.
  final Map<String, dynamic> rawJson;

  /// Parses required keys and nullable boundaries without discarding nulls.
  factory AgentSessionTraceList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentSessionTraceList.object');
    return AgentSessionTraceList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionTraceList.data',
        (v, c) => requireAgentList(v, c)
            .map(
              (v) => AgentSessionTurnTrace.fromJson(requireAgentObject(v, c)),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentSessionTraceList.firstId',
        requireAgentString,
        nullable: true,
      ),
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentSessionTraceList.lastId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentSessionTraceList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!_keys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(data.length, 'AgentSessionTraceList.data', max: 2000);
    for (final item in data) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'data': data.map((x) => x.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  /// Copies values. Explicit null clears a boundary while omission retains it.
  AgentSessionTraceList copyWith({
    List<AgentSessionTurnTrace>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTraceList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(firstId, this.firstId, 'History firstId'),
    lastId: copyAgentValue<String>(lastId, this.lastId, 'History lastId'),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Currently published OTLP JSON for one root turn, with private diagnostics.
///
/// The ID is a root-turn pagination anchor. Later trace updates are not awaited.
final class AgentSessionTurnTrace extends AgentJsonModel {
  /// Creates a finite, deeply immutable snapshot without interpreting OTLP data.
  AgentSessionTurnTrace({
    required this.id,
    required this.sessionId,
    required this.createdAt,
    required Map<String, dynamic> otlp,
    Map<String, dynamic> rawJson = const {},
  }) : otlp = snapshotAgentJson(otlp, 'AgentSessionTurnTrace.otlp'),
       rawJson = agentExtras(rawJson, _keys, 'AgentSessionTurnTrace') {
    validate();
  }
  static const _keys = ['id', 'object', 'session_id', 'created_at', 'otlp'];

  /// Root turn ID used as the exclusive pagination cursor.
  final String id;

  /// Owning session ID.
  final String sessionId;

  /// Root turn creation timestamp in Unix seconds.
  final int createdAt;

  /// Arbitrary OTLP ExportTraceServiceRequest; nested values are privately owned.
  final Map<String, dynamic> otlp;

  /// Canonical trace tag.
  String get object => 'agent.session.trace';

  /// Detached future received fields.
  final Map<String, dynamic> rawJson;

  /// Parses the complete required wire shape.
  factory AgentSessionTurnTrace.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.session.trace',
      'AgentSessionTurnTrace.object',
    );
    return AgentSessionTurnTrace(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionTurnTrace.id',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionTurnTrace.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentSessionTurnTrace.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      otlp: requiredAgentValue(
        json,
        'otlp',
        'AgentSessionTurnTrace.otlp',
        requireAgentObject,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!_keys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(createdAt, 'AgentSessionTurnTrace.createdAt');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'object': object,
    'session_id': sessionId,
    'created_at': createdAt,
    'otlp': otlp,
  };

  /// Copies fields while detaching mutable JSON supplied by the caller.
  AgentSessionTurnTrace copyWith({
    String? id,
    String? sessionId,
    int? createdAt,
    Map<String, dynamic>? otlp,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionTurnTrace(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    createdAt: createdAt ?? this.createdAt,
    otlp: otlp ?? this.otlp,
    rawJson: rawJson ?? this.rawJson,
  );
}
