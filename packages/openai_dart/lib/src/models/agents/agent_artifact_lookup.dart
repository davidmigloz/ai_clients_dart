import '../common/copy_with_sentinel.dart';
import 'agent_file_models.dart';
import 'agent_json_helpers.dart';

const _artifactKeys = [
  'created_at',
  'environment_id',
  'id',
  'object',
  'path',
  'session_id',
  'size_bytes',
  'turn_id',
];

/// Helper-only artifact metadata view tolerant of legacy absent/null row IDs.
///
/// Canonical [AgentSessionArtifact] remains strict. This view changes only
/// identifier presence so a helper can follow the page's actual `last_id`.
/// Every other known field remains required and validated, with owned extras.
/// A matching legacy row without an ID is never assigned an invented ID.
final class AgentArtifactLookupCandidate extends AgentJsonModel {
  const AgentArtifactLookupCandidate._(this.rawJson);

  /// Validates and detaches a helper-compatible received row.
  factory AgentArtifactLookupCandidate.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.session.artifact',
      'Artifact lookup candidate',
    );
    for (final key in ['created_at', 'size_bytes']) {
      validateAgentInt(
        requiredAgentValue(
          json,
          key,
          'Artifact lookup candidate.$key',
          requireAgentInt,
          nullable: false,
        )!,
        'Artifact lookup candidate.$key',
        min: key == 'size_bytes' ? 0 : null,
      );
    }
    for (final key in ['environment_id', 'path', 'session_id', 'turn_id']) {
      requiredAgentValue(
        json,
        key,
        'Artifact lookup candidate.$key',
        requireAgentString,
        nullable: false,
      );
    }
    if (json.containsKey('id') && json['id'] != null) {
      requireAgentString(json['id'], 'Artifact lookup candidate.id');
    }
    return AgentArtifactLookupCandidate._(
      snapshotAgentJson(json, 'Artifact lookup candidate'),
    );
  }

  /// Deeply owned received metadata, including legacy ID presence and extras.
  final Map<String, dynamic> rawJson;

  /// Whether the legacy identifier key was present, even if explicitly null.
  bool get hasId => rawJson.containsKey('id');

  /// Canonical or legacy identifier; null/absence cannot identify content.
  String? get id => rawJson['id'] as String?;

  /// Exact publication timestamp.
  int get createdAt => rawJson['created_at'] as int;

  /// Exact publishing environment identifier.
  String get environmentId => rawJson['environment_id'] as String;

  /// Exact hosted path, never a local output destination.
  String get path => rawJson['path'] as String;

  /// Owning session identifier.
  String get sessionId => rawJson['session_id'] as String;

  /// Immutable byte length.
  int get sizeBytes => rawJson['size_bytes'] as int;

  /// Publishing completed-turn identifier.
  String get turnId => rawJson['turn_id'] as String;

  /// Fixed canonical artifact tag.
  String get object => 'agent.session.artifact';

  /// Produces a strict artifact only when a usable identifier was observed.
  AgentSessionArtifact requireArtifact() {
    if (id == null || id!.isEmpty) {
      throw const FormatException(
        'Matching artifact has no usable observed identifier.',
      );
    }
    return AgentSessionArtifact.fromJson(toJson());
  }

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Typed updates are authoritative over replacement extras. Explicit null
  /// preserves a nullable legacy ID; [omitId] removes that key instead.
  AgentArtifactLookupCandidate copyWith({
    Object? id = unsetCopyWithValue,
    bool omitId = false,
    int? createdAt,
    String? environmentId,
    String? path,
    String? sessionId,
    int? sizeBytes,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) {
    final nextId = copyAgentValue<String>(
      id,
      this.id,
      'Artifact lookup candidate.id',
    );
    return AgentArtifactLookupCandidate.fromJson({
      ...agentExtras(
        {
          for (final entry in (rawJson ?? this.rawJson).entries)
            if (!_artifactKeys.contains(entry.key)) entry.key: entry.value,
        },
        _artifactKeys,
        'Artifact lookup candidate',
      ),
      if (!omitId && (!identical(id, unsetCopyWithValue) || hasId))
        'id': nextId,
      'created_at': createdAt ?? this.createdAt,
      'environment_id': environmentId ?? this.environmentId,
      'object': object,
      'path': path ?? this.path,
      'session_id': sessionId ?? this.sessionId,
      'size_bytes': sizeBytes ?? this.sizeBytes,
      'turn_id': turnId ?? this.turnId,
    });
  }
}

/// One existing artifact-list response for helper traversal, with legacy IDs.
///
/// This is not the mutable live-file `page`/`next` envelope. Its actual opaque
/// [lastId] is authoritative even when a row has no identifier. Canonical raw
/// [AgentSessionArtifactList] parsing remains unchanged.
final class AgentArtifactLookupPage extends AgentJsonModel {
  /// Creates an owned helper page; envelope fields retain canonical requiredness.
  AgentArtifactLookupPage({
    required List<AgentArtifactLookupCandidate> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, const [
         'data',
         'first_id',
         'last_id',
         'has_more',
         'object',
       ], 'Artifact lookup page') {
    validateAgentCount(
      this.data.length,
      'Artifact lookup page.data',
      min: 0,
      max: 2000,
    );
  }

  /// Validates all known fields and preserves received extras.
  factory AgentArtifactLookupPage.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'Artifact lookup page');
    return AgentArtifactLookupPage(
      data: requiredAgentValue(
        json,
        'data',
        'Artifact lookup page.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (row) => AgentArtifactLookupCandidate.fromJson(
                requireAgentObject(row, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'Artifact lookup page.first_id',
        requireAgentString,
        nullable: true,
      ),
      lastId: requiredAgentValue(
        json,
        'last_id',
        'Artifact lookup page.last_id',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'Artifact lookup page.has_more',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'data',
            'first_id',
            'last_id',
            'has_more',
            'object',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }

  /// Owned rows in received order, including nullable legacy identifiers.
  final List<AgentArtifactLookupCandidate> data;

  /// First-ID metadata, retained without inferring it from a row.
  final String? firstId;

  /// Actual opaque cursor; never reconstructed from an ID or hosted path.
  final String? lastId;

  /// Whether another page follows.
  final bool hasMore;

  /// Deeply owned received extras.
  final Map<String, dynamic> rawJson;

  /// Fixed artifact-list tag.
  String get object => 'list';
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'data': data.map((row) => row.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  /// Copies all page metadata, preserving explicit null cursor values.
  AgentArtifactLookupPage copyWith({
    List<AgentArtifactLookupCandidate>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => AgentArtifactLookupPage(
    data: data ?? this.data,
    firstId: copyAgentValue(
      firstId,
      this.firstId,
      'Artifact lookup page.first_id',
    ),
    lastId: copyAgentValue(lastId, this.lastId, 'Artifact lookup page.last_id'),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}
