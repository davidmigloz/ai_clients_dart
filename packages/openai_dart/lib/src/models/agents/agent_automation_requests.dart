import '../common/copy_with_sentinel.dart';
import 'agent_json_helpers.dart';
import 'agent_session_models.dart';

/// Creates a saved schedule without invoking it immediately.
///
/// Variants are [CreateAgentAutomationOnceRequest],
/// [CreateAgentAutomationPeriodicRequest] and
/// [UnknownCreateAgentAutomationRequest]. Future shapes remain readable but are
/// not writable until supported by this client.
sealed class CreateAgentAutomationRequest extends AgentJsonModel {
  const CreateAgentAutomationRequest();

  /// Creates a one-time schedule. Service validation requires a future runAt.
  factory CreateAgentAutomationRequest.once({
    required String name,
    required AgentAutomationTarget target,
    required int runAt,
    Map<String, String>? metadata,
  }) = CreateAgentAutomationOnceRequest;

  /// Creates a periodic schedule using five-field cron and an IANA timezone.
  factory CreateAgentAutomationRequest.periodic({
    required String name,
    required AgentAutomationTarget target,
    required String expression,
    required String timezone,
    Map<String, String>? metadata,
  }) = CreateAgentAutomationPeriodicRequest;

  /// Parses a strict known request or an opaque future discriminator.
  factory CreateAgentAutomationRequest.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'CreateAgentAutomationRequest.type',
      )) {
        'once' => CreateAgentAutomationOnceRequest.fromJson(json),
        'periodic' => CreateAgentAutomationPeriodicRequest.fromJson(json),
        _ => UnknownCreateAgentAutomationRequest.fromJson(json),
      };

  /// The schedule discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();
}

/// A future creation shape, preserved without authorizing a request.
final class UnknownCreateAgentAutomationRequest
    extends CreateAgentAutomationRequest {
  const UnknownCreateAgentAutomationRequest._(this.rawJson);

  /// Requires an unknown discriminator and snapshots private finite JSON.
  factory UnknownCreateAgentAutomationRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = requireAgentString(
      json['type'],
      'UnknownCreateAgentAutomationRequest.type',
    );
    if (const ['once', 'periodic'].contains(type)) {
      throw const FormatException(
        'UnknownCreateAgentAutomationRequest: expected a future type',
      );
    }
    return UnknownCreateAgentAutomationRequest._(
      snapshotAgentJson(json, 'UnknownCreateAgentAutomationRequest'),
    );
  }

  /// Immutable source data; never printed automatically.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies the opaque future shape.
  UnknownCreateAgentAutomationRequest copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownCreateAgentAutomationRequest.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownCreateAgentAutomationRequest: future schedules are not writable',
  );
}

/// A one-time saved schedule. Completion refers to scheduling, not Agent work.
final class CreateAgentAutomationOnceRequest
    extends CreateAgentAutomationRequest {
  /// Captures a future Unix timestamp in seconds without a local clock policy.
  CreateAgentAutomationOnceRequest({
    required this.name,
    required this.target,
    required this.runAt,
    Map<String, String>? metadata,
  }) : metadata = metadata == null
           ? null
           : Map<String, String>.unmodifiable(metadata) {
    validate();
  }

  /// Display name, from 1 through 256 Unicode code points.
  final String name;

  /// Session selection or configuration for each invocation.
  final AgentAutomationTarget target;

  /// Intended future Unix timestamp, in seconds; verified by the service.
  final int runAt;

  /// Optional metadata; absence differs from an explicitly empty map.
  final Map<String, String>? metadata;
  @override
  String get type => 'once';

  /// Parses the closed creation object without inserting metadata defaults.
  factory CreateAgentAutomationOnceRequest.fromJson(Map<String, dynamic> json) {
    const context = 'CreateAgentAutomationOnceRequest';
    requireClosedAgentJson(json, const [
      'type',
      'name',
      'target',
      'run_at',
      'metadata',
    ], context);
    requireAgentTag(json, 'type', 'once', context);
    return CreateAgentAutomationOnceRequest(
      name: requireAgentString(json['name'], '$context.name'),
      target: AgentAutomationTarget.fromJson(
        requireAgentObject(json['target'], '$context.target'),
      ),
      runAt: requireAgentInt(json['run_at'], '$context.runAt'),
      metadata: optionalAgentValue(
        json,
        'metadata',
        '$context.metadata',
        requireAgentStringMap,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {
    validateAgentLength(
      name,
      'CreateAgentAutomationOnceRequest.name',
      min: 1,
      max: 256,
    );
    target.validate();
    validateAgentInt(runAt, 'CreateAgentAutomationOnceRequest.runAt');
    _validateAutomationMetadata(
      metadata,
      'CreateAgentAutomationOnceRequest.metadata',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'target': target.toJson(),
    'run_at': runAt,
    if (metadata != null) 'metadata': metadata,
  };

  /// Copies fields; metadata:null omits that optional nonnullable wire field.
  CreateAgentAutomationOnceRequest copyWith({
    String? name,
    AgentAutomationTarget? target,
    int? runAt,
    Object? metadata = unsetCopyWithValue,
  }) => CreateAgentAutomationOnceRequest(
    name: name ?? this.name,
    target: target ?? this.target,
    runAt: runAt ?? this.runAt,
    metadata: _copyAutomationMetadata(
      metadata,
      this.metadata,
      'CreateAgentAutomationOnceRequest.metadata',
    ),
  );
}

/// A periodic saved schedule; creation itself does not invoke the Agent.
final class CreateAgentAutomationPeriodicRequest
    extends CreateAgentAutomationRequest {
  /// Captures cron/timezone strings; the service resolves schedule validity.
  CreateAgentAutomationPeriodicRequest({
    required this.name,
    required this.target,
    required this.expression,
    required this.timezone,
    Map<String, String>? metadata,
  }) : metadata = metadata == null
           ? null
           : Map<String, String>.unmodifiable(metadata) {
    validate();
  }

  /// Display name, from 1 through 256 Unicode code points.
  final String name;

  /// Session selection or configuration for each invocation.
  final AgentAutomationTarget target;

  /// Standard five-field cron expression, 1–256 code points.
  final String expression;

  /// IANA timezone identifier, 1–128 code points.
  final String timezone;

  /// Optional metadata; no client default is inserted.
  final Map<String, String>? metadata;
  @override
  String get type => 'periodic';

  /// Parses only schema-declared writable fields.
  factory CreateAgentAutomationPeriodicRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'CreateAgentAutomationPeriodicRequest';
    requireClosedAgentJson(json, const [
      'type',
      'name',
      'target',
      'expression',
      'timezone',
      'metadata',
    ], context);
    requireAgentTag(json, 'type', 'periodic', context);
    return CreateAgentAutomationPeriodicRequest(
      name: requireAgentString(json['name'], '$context.name'),
      target: AgentAutomationTarget.fromJson(
        requireAgentObject(json['target'], '$context.target'),
      ),
      expression: requireAgentString(json['expression'], '$context.expression'),
      timezone: requireAgentString(json['timezone'], '$context.timezone'),
      metadata: optionalAgentValue(
        json,
        'metadata',
        '$context.metadata',
        requireAgentStringMap,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {
    validateAgentLength(
      name,
      'CreateAgentAutomationPeriodicRequest.name',
      min: 1,
      max: 256,
    );
    target.validate();
    validateAgentLength(
      expression,
      'CreateAgentAutomationPeriodicRequest.expression',
      min: 1,
      max: 256,
    );
    validateAgentLength(
      timezone,
      'CreateAgentAutomationPeriodicRequest.timezone',
      min: 1,
      max: 128,
    );
    _validateAutomationMetadata(
      metadata,
      'CreateAgentAutomationPeriodicRequest.metadata',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'target': target.toJson(),
    'expression': expression,
    'timezone': timezone,
    if (metadata != null) 'metadata': metadata,
  };

  /// Copies exact strings; metadata:null omits its optional nonnullable field.
  CreateAgentAutomationPeriodicRequest copyWith({
    String? name,
    AgentAutomationTarget? target,
    String? expression,
    String? timezone,
    Object? metadata = unsetCopyWithValue,
  }) => CreateAgentAutomationPeriodicRequest(
    name: name ?? this.name,
    target: target ?? this.target,
    expression: expression ?? this.expression,
    timezone: timezone ?? this.timezone,
    metadata: _copyAutomationMetadata(
      metadata,
      this.metadata,
      'CreateAgentAutomationPeriodicRequest.metadata',
    ),
  );
}

/// Supplied automation fields replace their complete saved values.
///
/// Omit any field to keep it. An empty metadata map clears metadata. Timing
/// fields must match the stored schedule; runAt can change only before a one-time
/// scheduled invocation exists. The service retains target type and creator
/// session when validating target replacement. This object does not invoke work.
final class UpdateAgentAutomationRequest extends AgentJsonModel {
  /// Captures only supplied, nonnullable wire fields.
  UpdateAgentAutomationRequest({
    this.name,
    this.target,
    Map<String, String>? metadata,
    this.expression,
    this.timezone,
    this.runAt,
  }) : metadata = metadata == null
           ? null
           : Map<String, String>.unmodifiable(metadata) {
    validate();
  }

  /// Optional replacement name, 1–256 code points.
  final String? name;

  /// Optional complete target replacement, retaining its stored type.
  final AgentAutomationTarget? target;

  /// Optional complete metadata replacement; {} clears, omission retains it.
  final Map<String, String>? metadata;

  /// Optional periodic cron expression, 1–256 code points.
  final String? expression;

  /// Optional periodic IANA timezone, 1–128 code points.
  final String? timezone;

  /// Optional one-time future Unix timestamp in seconds.
  final int? runAt;

  /// Parses the closed update object; explicit nulls are invalid on the wire.
  factory UpdateAgentAutomationRequest.fromJson(Map<String, dynamic> json) {
    const context = 'UpdateAgentAutomationRequest';
    requireClosedAgentJson(json, const [
      'name',
      'target',
      'metadata',
      'expression',
      'timezone',
      'run_at',
    ], context);
    return UpdateAgentAutomationRequest(
      name: optionalAgentValue(
        json,
        'name',
        '$context.name',
        requireAgentString,
        nullable: false,
      ),
      target: optionalAgentValue(
        json,
        'target',
        '$context.target',
        (value, context) =>
            AgentAutomationTarget.fromJson(requireAgentObject(value, context)),
        nullable: false,
      ),
      metadata: optionalAgentValue(
        json,
        'metadata',
        '$context.metadata',
        requireAgentStringMap,
        nullable: false,
      ),
      expression: optionalAgentValue(
        json,
        'expression',
        '$context.expression',
        requireAgentString,
        nullable: false,
      ),
      timezone: optionalAgentValue(
        json,
        'timezone',
        '$context.timezone',
        requireAgentString,
        nullable: false,
      ),
      runAt: optionalAgentValue(
        json,
        'run_at',
        '$context.runAt',
        requireAgentInt,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {
    if (name != null) {
      validateAgentLength(
        name!,
        'UpdateAgentAutomationRequest.name',
        min: 1,
        max: 256,
      );
    }
    target?.validate();
    _validateAutomationMetadata(
      metadata,
      'UpdateAgentAutomationRequest.metadata',
    );
    if (expression != null) {
      validateAgentLength(
        expression!,
        'UpdateAgentAutomationRequest.expression',
        min: 1,
        max: 256,
      );
    }
    if (timezone != null) {
      validateAgentLength(
        timezone!,
        'UpdateAgentAutomationRequest.timezone',
        min: 1,
        max: 128,
      );
    }
    if (runAt != null) {
      validateAgentInt(runAt!, 'UpdateAgentAutomationRequest.runAt');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (target != null) 'target': target!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (expression != null) 'expression': expression,
    if (timezone != null) 'timezone': timezone,
    if (runAt != null) 'run_at': runAt,
  };

  /// Copies fields; null removes a local field rather than sending wire null.
  UpdateAgentAutomationRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? target = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? expression = unsetCopyWithValue,
    Object? timezone = unsetCopyWithValue,
    Object? runAt = unsetCopyWithValue,
  }) => UpdateAgentAutomationRequest(
    name: copyAgentValue<String>(
      name,
      this.name,
      'UpdateAgentAutomationRequest.name',
    ),
    target: copyAgentValue<AgentAutomationTarget>(
      target,
      this.target,
      'UpdateAgentAutomationRequest.target',
    ),
    metadata: _copyAutomationMetadata(
      metadata,
      this.metadata,
      'UpdateAgentAutomationRequest.metadata',
    ),
    expression: copyAgentValue<String>(
      expression,
      this.expression,
      'UpdateAgentAutomationRequest.expression',
    ),
    timezone: copyAgentValue<String>(
      timezone,
      this.timezone,
      'UpdateAgentAutomationRequest.timezone',
    ),
    runAt: copyAgentValue<int>(
      runAt,
      this.runAt,
      'UpdateAgentAutomationRequest.runAt',
    ),
  );
}

/// A writable automation target, separate from saved resource snapshots.
///
/// Variants are [AgentAutomationExistingSessionTarget],
/// [AgentAutomationNewSessionTarget] and [UnknownAgentAutomationTarget].
sealed class AgentAutomationTarget extends AgentJsonModel {
  const AgentAutomationTarget();

  /// Delivers instructions to an existing session on each invocation.
  factory AgentAutomationTarget.existingSession({
    required String sessionId,
    required String instructions,
  }) = AgentAutomationExistingSessionTarget;

  /// Creates one session per invocation, with exactly one agent selection.
  factory AgentAutomationTarget.newSession({
    AgentSessionAgentConfig? agent,
    String? agentId,
    required AgentSessionEnvironment environment,
    required List<AgentSessionInputMessage> input,
    List<String>? vaultIds,
    bool clearVaultIds,
    Map<String, String>? metadata,
    bool clearMetadata,
  }) = AgentAutomationNewSessionTarget;

  /// Parses a known strict target or an opaque future discriminator.
  factory AgentAutomationTarget.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(json['type'], 'AgentAutomationTarget.type')) {
        'existing_session' => AgentAutomationExistingSessionTarget.fromJson(
          json,
        ),
        'new_session' => AgentAutomationNewSessionTarget.fromJson(json),
        _ => UnknownAgentAutomationTarget.fromJson(json),
      };

  /// Fixed target discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();
}

/// Future target JSON retained for inspection without writable authority.
final class UnknownAgentAutomationTarget extends AgentAutomationTarget {
  const UnknownAgentAutomationTarget._(this.rawJson);

  /// Rejects known discriminator misuse and owns finite private JSON.
  factory UnknownAgentAutomationTarget.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentAutomationTarget.type',
    );
    if (const ['existing_session', 'new_session'].contains(type)) {
      throw const FormatException(
        'UnknownAgentAutomationTarget: expected a future type',
      );
    }
    return UnknownAgentAutomationTarget._(
      snapshotAgentJson(json, 'UnknownAgentAutomationTarget'),
    );
  }

  /// Immutable received future JSON.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies an opaque future target.
  UnknownAgentAutomationTarget copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentAutomationTarget.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentAutomationTarget: future targets are not writable',
  );
}

/// Delivers an automation notification to an existing session.
final class AgentAutomationExistingSessionTarget extends AgentAutomationTarget {
  /// Captures exact session identifier and instructions, including empty strings.
  AgentAutomationExistingSessionTarget({
    required this.sessionId,
    required this.instructions,
  }) {
    validate();
  }

  /// Existing session identifier, 0–1,048,576 code points.
  final String sessionId;

  /// Instructions for each invocation, 0–1,048,576 code points.
  final String instructions;
  @override
  String get type => 'existing_session';

  /// Parses only native writable fields.
  factory AgentAutomationExistingSessionTarget.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'AgentAutomationExistingSessionTarget';
    requireClosedAgentJson(json, const [
      'type',
      'session_id',
      'instructions',
    ], context);
    requireAgentTag(json, 'type', 'existing_session', context);
    return AgentAutomationExistingSessionTarget(
      sessionId: requireAgentString(json['session_id'], '$context.sessionId'),
      instructions: requireAgentString(
        json['instructions'],
        '$context.instructions',
      ),
    );
  }
  @override
  void validate() {
    validateAgentLength(
      sessionId,
      'AgentAutomationExistingSessionTarget.sessionId',
      max: 1048576,
    );
    validateAgentLength(
      instructions,
      'AgentAutomationExistingSessionTarget.instructions',
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'session_id': sessionId,
    'instructions': instructions,
  };

  /// Copies exact identifier and instructions.
  AgentAutomationExistingSessionTarget copyWith({
    String? sessionId,
    String? instructions,
  }) => AgentAutomationExistingSessionTarget(
    sessionId: sessionId ?? this.sessionId,
    instructions: instructions ?? this.instructions,
  );
}

/// Configures one new session per invocation without creating it immediately.
final class AgentAutomationNewSessionTarget extends AgentAutomationTarget {
  /// Selects exactly one agent or agentId and owns the canonical message array.
  /// The service validates whether the initial input is usable.
  AgentAutomationNewSessionTarget({
    this.agent,
    this.agentId,
    required this.environment,
    required List<AgentSessionInputMessage> input,
    List<String>? vaultIds,
    bool clearVaultIds = false,
    Map<String, String>? metadata,
    bool clearMetadata = false,
  }) : input = List<AgentSessionInputMessage>.unmodifiable(input),
       vaultIds = clearVaultIds || vaultIds == null
           ? null
           : List<String>.unmodifiable(vaultIds),
       clearVaultIds = clearVaultIds,
       metadata = clearMetadata || metadata == null
           ? null
           : Map<String, String>.unmodifiable(metadata),
       clearMetadata = clearMetadata {
    validate();
  }

  /// Inline session-agent settings, mutually exclusive with [agentId].
  final AgentSessionAgentConfig? agent;

  /// Saved agent identifier, 0–64 code points; mutually exclusive with [agent].
  final String? agentId;

  /// Environment selection/configuration for each future session.
  final AgentSessionEnvironment environment;

  /// Immutable message array, with canonical wire bounds of 0–16,384.
  /// The service may require usable nonempty content when creating sessions.
  final List<AgentSessionInputMessage> input;

  /// Optional nullable vault IDs, including an explicitly empty list.
  final List<String>? vaultIds;

  /// Emits vault_ids:null rather than omitting the field.
  final bool clearVaultIds;

  /// Optional nullable metadata for each new session.
  final Map<String, String>? metadata;

  /// Emits metadata:null rather than omitting the field.
  final bool clearMetadata;
  @override
  String get type => 'new_session';

  /// Parses native settings, keeping nullable fields' wire presence.
  factory AgentAutomationNewSessionTarget.fromJson(Map<String, dynamic> json) {
    const context = 'AgentAutomationNewSessionTarget';
    requireClosedAgentJson(json, const [
      'type',
      'agent',
      'agent_id',
      'environment',
      'input',
      'vault_ids',
      'metadata',
    ], context);
    requireAgentTag(json, 'type', 'new_session', context);
    return AgentAutomationNewSessionTarget(
      agent: optionalAgentValue(
        json,
        'agent',
        '$context.agent',
        (value, context) => AgentSessionAgentConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      ),
      agentId: optionalAgentValue(
        json,
        'agent_id',
        '$context.agentId',
        requireAgentString,
        nullable: false,
      ),
      environment: AgentSessionEnvironment.fromJson(
        requireAgentObject(json['environment'], '$context.environment'),
      ),
      input: requireAgentList(json['input'], '$context.input')
          .map(
            (value) => AgentSessionInputMessage.fromJson(
              requireAgentObject(value, '$context.input'),
            ),
          )
          .toList(),
      vaultIds: optionalAgentValue(
        json,
        'vault_ids',
        '$context.vaultIds',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearVaultIds: json.containsKey('vault_ids') && json['vault_ids'] == null,
      metadata: optionalAgentValue(
        json,
        'metadata',
        '$context.metadata',
        requireAgentStringMap,
        nullable: true,
      ),
      clearMetadata: json.containsKey('metadata') && json['metadata'] == null,
    );
  }
  @override
  void validate() {
    if ((agent == null) == (agentId == null)) {
      throw const FormatException(
        'AgentAutomationNewSessionTarget: provide exactly one agent selection',
      );
    }
    agent?.validate();
    if (agentId != null) {
      validateAgentLength(
        agentId!,
        'AgentAutomationNewSessionTarget.agentId',
        max: 64,
      );
    }
    environment.validate();
    validateAgentCount(
      input.length,
      'AgentAutomationNewSessionTarget.input',
      max: 16384,
    );
    for (final message in input) {
      message.validate();
    }
    if (vaultIds != null) {
      validateAgentCount(
        vaultIds!.length,
        'AgentAutomationNewSessionTarget.vaultIds',
        max: 16384,
      );
      for (final id in vaultIds!) {
        validateAgentLength(
          id,
          'AgentAutomationNewSessionTarget.vaultIds',
          max: 1048576,
        );
      }
    }
    _validateAutomationMetadata(
      metadata,
      'AgentAutomationNewSessionTarget.metadata',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (agent != null) 'agent': agent!.toJson(),
    if (agentId != null) 'agent_id': agentId,
    'environment': environment.toJson(),
    'input': input.map((message) => message.toJson()).toList(),
    if (clearVaultIds)
      'vault_ids': null
    else if (vaultIds != null)
      'vault_ids': vaultIds,
    if (clearMetadata)
      'metadata': null
    else if (metadata != null)
      'metadata': metadata,
  };

  /// Copies settings; nullable collection nulls emit null, clear flags may omit.
  /// To switch agent representation, remove the previous one in the same call.
  AgentAutomationNewSessionTarget copyWith({
    Object? agent = unsetCopyWithValue,
    Object? agentId = unsetCopyWithValue,
    AgentSessionEnvironment? environment,
    List<AgentSessionInputMessage>? input,
    Object? vaultIds = unsetCopyWithValue,
    bool? clearVaultIds,
    Object? metadata = unsetCopyWithValue,
    bool? clearMetadata,
  }) => AgentAutomationNewSessionTarget(
    agent: copyAgentValue<AgentSessionAgentConfig>(
      agent,
      this.agent,
      'AgentAutomationNewSessionTarget.agent',
    ),
    agentId: copyAgentValue<String>(
      agentId,
      this.agentId,
      'AgentAutomationNewSessionTarget.agentId',
    ),
    environment: environment ?? this.environment,
    input: input ?? this.input,
    vaultIds: _copyAutomationVaultIds(vaultIds, this.vaultIds),
    clearVaultIds:
        clearVaultIds ??
        (identical(vaultIds, unsetCopyWithValue)
            ? this.clearVaultIds
            : vaultIds == null),
    metadata: _copyAutomationMetadata(
      metadata,
      this.metadata,
      'AgentAutomationNewSessionTarget.metadata',
    ),
    clearMetadata:
        clearMetadata ??
        (identical(metadata, unsetCopyWithValue)
            ? this.clearMetadata
            : metadata == null),
  );
}

void _validateAutomationMetadata(Map<String, String>? value, String context) {
  if (value == null) return;
  validateAgentCount(value.length, context, max: 16);
  for (final key in value.keys) {
    validateAgentLength(key, context, min: 1, max: 64);
  }
  for (final item in value.values) {
    validateAgentLength(item, context, max: 512);
  }
}

Map<String, String>? _copyAutomationMetadata(
  Object? value,
  Map<String, String>? current,
  String context,
) {
  if (identical(value, unsetCopyWithValue)) return current;
  return value == null ? null : requireAgentStringMap(value, context);
}

List<String>? _copyAutomationVaultIds(Object? value, List<String>? current) {
  if (identical(value, unsetCopyWithValue)) return current;
  return value == null
      ? null
      : requireAgentList(value, 'AgentAutomationNewSessionTarget.vaultIds')
            .map(
              (item) => requireAgentString(
                item,
                'AgentAutomationNewSessionTarget.vaultIds',
              ),
            )
            .toList();
}
