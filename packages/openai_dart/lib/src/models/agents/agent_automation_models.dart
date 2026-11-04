/// Saved Agent automation schedules and immutable delivery records.
library;

import '../common/copy_with_sentinel.dart';
import 'agent_config.dart';
import 'agent_enums.dart';
import 'agent_environment_models.dart';
import 'agent_json_helpers.dart';
import 'agent_session_models.dart';
import 'agent_settings.dart';

/// Exact schedule status: [AgentAutomationOnceStatus],
/// [AgentAutomationPeriodicStatus], or [AgentAutomationFutureStatus].
sealed class AgentAutomationStatus extends AgentJsonModel {
  const AgentAutomationStatus();

  /// The exact received status string.
  String get value;

  /// Whether the value belongs to its known schedule's frozen status set.
  bool get isKnown;
  @override
  String toJson() => value;
}

/// Exact received OnceAutomationStatusResource value; future strings remain readable.
final class AgentAutomationOnceStatus extends AgentAutomationStatus {
  const AgentAutomationOnceStatus._(this.value);

  /// The `active` status.
  static const AgentAutomationOnceStatus active = AgentAutomationOnceStatus._(
    'active',
  );

  /// The `paused` status.
  static const AgentAutomationOnceStatus paused = AgentAutomationOnceStatus._(
    'paused',
  );

  /// The `completed` status.
  static const AgentAutomationOnceStatus completed =
      AgentAutomationOnceStatus._('completed');

  /// Exact received wire value.
  @override
  final String value;

  /// Parses known or future strings without normalization.
  factory AgentAutomationOnceStatus.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentAutomationOnceStatus');
    return switch (value) {
      'active' => active,
      'paused' => paused,
      'completed' => completed,
      _ => AgentAutomationOnceStatus._(value),
    };
  }

  /// Whether the status is in the frozen known set.
  @override
  bool get isKnown => const ['active', 'paused', 'completed'].contains(value);

  /// Copies the exact received status.
  AgentAutomationOnceStatus copyWith({String? value}) =>
      AgentAutomationOnceStatus.fromJson(value ?? this.value);
  @override
  String toJson() => value;
}

/// Exact received PeriodicAutomationStatusResource value; future strings remain readable.
final class AgentAutomationPeriodicStatus extends AgentAutomationStatus {
  const AgentAutomationPeriodicStatus._(this.value);

  /// The `active` status.
  static const AgentAutomationPeriodicStatus active =
      AgentAutomationPeriodicStatus._('active');

  /// The `paused` status.
  static const AgentAutomationPeriodicStatus paused =
      AgentAutomationPeriodicStatus._('paused');

  /// Exact received wire value.
  @override
  final String value;

  /// Parses known or future strings without normalization.
  factory AgentAutomationPeriodicStatus.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentAutomationPeriodicStatus');
    return switch (value) {
      'active' => active,
      'paused' => paused,
      _ => AgentAutomationPeriodicStatus._(value),
    };
  }

  /// Whether the status is in the frozen known set.
  @override
  bool get isKnown => const ['active', 'paused'].contains(value);

  /// Copies the exact received status.
  AgentAutomationPeriodicStatus copyWith({String? value}) =>
      AgentAutomationPeriodicStatus.fromJson(value ?? this.value);
  @override
  String toJson() => value;
}

/// Exact received AutomationInvocationStatusResource value; future strings remain readable.
final class AgentAutomationInvocationStatus extends AgentJsonModel {
  const AgentAutomationInvocationStatus._(this.value);

  /// The `queued` status.
  static const AgentAutomationInvocationStatus queued =
      AgentAutomationInvocationStatus._('queued');

  /// The `completed` status.
  static const AgentAutomationInvocationStatus completed =
      AgentAutomationInvocationStatus._('completed');

  /// The `failed` status.
  static const AgentAutomationInvocationStatus failed =
      AgentAutomationInvocationStatus._('failed');

  /// The `skipped` status.
  static const AgentAutomationInvocationStatus skipped =
      AgentAutomationInvocationStatus._('skipped');

  /// Exact received wire value.
  final String value;

  /// Parses known or future strings without normalization.
  factory AgentAutomationInvocationStatus.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentAutomationInvocationStatus');
    return switch (value) {
      'queued' => queued,
      'completed' => completed,
      'failed' => failed,
      'skipped' => skipped,
      _ => AgentAutomationInvocationStatus._(value),
    };
  }

  /// Whether the status is in the frozen known set.
  bool get isKnown =>
      const ['queued', 'completed', 'failed', 'skipped'].contains(value);

  /// Copies the exact received status.
  AgentAutomationInvocationStatus copyWith({String? value}) =>
      AgentAutomationInvocationStatus.fromJson(value ?? this.value);
  @override
  String toJson() => value;
}

/// A status of an unknown future schedule kind, without inferred known semantics.
final class AgentAutomationFutureStatus extends AgentAutomationStatus {
  const AgentAutomationFutureStatus._(this.value);

  /// Preserves the exact status while leaving its semantics unknown.
  factory AgentAutomationFutureStatus.fromJson(Object? json) =>
      AgentAutomationFutureStatus._(
        requireAgentString(json, 'AgentAutomationFutureStatus'),
      );
  @override
  final String value;
  @override
  bool get isKnown => false;

  /// Copies the exact future status.
  AgentAutomationFutureStatus copyWith({String? value}) =>
      AgentAutomationFutureStatus.fromJson(value ?? this.value);
}

/// Received schedule: [AgentAutomationOnce], [AgentAutomationPeriodic], or
/// [UnknownAgentAutomation] for a future kind.
sealed class AgentAutomation extends AgentJsonModel {
  const AgentAutomation();

  /// Dispatches known variants strictly and preserves future discriminators.
  factory AgentAutomation.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(json['type'], 'AgentAutomation.type')) {
      'periodic' => AgentAutomationPeriodic.fromJson(json),
      'once' => AgentAutomationOnce.fromJson(json),
      _ => UnknownAgentAutomation.fromJson(json),
    };
  }

  /// Exact received type discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// The received id field.
  String get id;

  /// The received object field.
  String get object;

  /// The received createdAt field.
  int get createdAt;

  /// The received name field.
  String get name;

  /// The received target field.
  AgentAutomationTargetResource get target;

  /// The received metadata field.
  Map<String, String> get metadata;

  /// The received createdBy field.
  AgentAutomationCreator get createdBy;

  /// The received status field.
  AgentAutomationStatus get status;
}

/// Detached future AgentAutomation variant; not a writable request.
final class UnknownAgentAutomation extends AgentAutomation {
  const UnknownAgentAutomation._(this.rawJson);

  /// Rejects known tags so malformed known payloads cannot escape validation.
  factory UnknownAgentAutomation.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(json['type'], 'UnknownAgentAutomation.type');
    if (const ['periodic', 'once'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentAutomation: expected a future discriminator',
      );
    }
    return UnknownAgentAutomation._(
      snapshotAgentJson(json, 'UnknownAgentAutomation'),
    );
  }

  /// Immutable received JSON, including future fields.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces the future snapshot while retaining its unknown discriminator.
  UnknownAgentAutomation copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentAutomation.fromJson(rawJson ?? this.rawJson);

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  String get id =>
      requireAgentString(rawJson['id'], 'UnknownAgentAutomation.id');

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  String get object =>
      requireAgentString(rawJson['object'], 'UnknownAgentAutomation.object');

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  int get createdAt => requireAgentInt(
    rawJson['created_at'],
    'UnknownAgentAutomation.createdAt',
  );

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  String get name =>
      requireAgentString(rawJson['name'], 'UnknownAgentAutomation.name');

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  AgentAutomationTargetResource get target =>
      AgentAutomationTargetResource.fromJson(
        requireAgentObject(rawJson['target'], 'UnknownAgentAutomation.target'),
      );

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  Map<String, String> get metadata => Map<String, String>.unmodifiable(
    requireAgentStringMap(
      rawJson['metadata'],
      'UnknownAgentAutomation.metadata',
    ),
  );

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  AgentAutomationCreator get createdBy => AgentAutomationCreator.fromJson(
    requireAgentObject(
      rawJson['created_by'],
      'UnknownAgentAutomation.createdBy',
    ),
  );

  /// Accessing an absent future common field fails rather than inventing facts.
  @override
  AgentAutomationStatus get status =>
      AgentAutomationFutureStatus.fromJson(rawJson['status']);
}

/// Saved target: [AgentAutomationExistingSessionTargetResource],
/// [AgentAutomationNewSessionTargetResource], or
/// [UnknownAgentAutomationTargetResource] for a future kind.
sealed class AgentAutomationTargetResource extends AgentJsonModel {
  const AgentAutomationTargetResource();

  /// Dispatches known variants strictly and preserves future discriminators.
  factory AgentAutomationTargetResource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentAutomationTargetResource.type',
    )) {
      'new_session' => AgentAutomationNewSessionTargetResource.fromJson(json),
      'existing_session' =>
        AgentAutomationExistingSessionTargetResource.fromJson(json),
      _ => UnknownAgentAutomationTargetResource.fromJson(json),
    };
  }

  /// Exact received type discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();
}

/// Detached future AgentAutomationTargetResource variant; not a writable request.
final class UnknownAgentAutomationTargetResource
    extends AgentAutomationTargetResource {
  const UnknownAgentAutomationTargetResource._(this.rawJson);

  /// Rejects known tags so malformed known payloads cannot escape validation.
  factory UnknownAgentAutomationTargetResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentAutomationTargetResource.type',
    );
    if (const ['new_session', 'existing_session'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentAutomationTargetResource: expected a future discriminator',
      );
    }
    return UnknownAgentAutomationTargetResource._(
      snapshotAgentJson(json, 'UnknownAgentAutomationTargetResource'),
    );
  }

  /// Immutable received JSON, including future fields.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces the future snapshot while retaining its unknown discriminator.
  UnknownAgentAutomationTargetResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentAutomationTargetResource.fromJson(rawJson ?? this.rawJson);
}

/// Saved environment selection: [AgentAutomationNoneEnvironmentResource],
/// [AgentAutomationHostedEnvironmentResource],
/// [AgentAutomationSelfHostedEnvironmentResource], or
/// [UnknownAgentAutomationEnvironmentResource] for a future kind.
sealed class AgentAutomationEnvironmentResource extends AgentJsonModel {
  const AgentAutomationEnvironmentResource();

  /// Dispatches known variants strictly and preserves future discriminators.
  factory AgentAutomationEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentAutomationEnvironmentResource.type',
    )) {
      'none' => AgentAutomationNoneEnvironmentResource.fromJson(json),
      'openai_hosted' => AgentAutomationHostedEnvironmentResource.fromJson(
        json,
      ),
      'self_hosted' => AgentAutomationSelfHostedEnvironmentResource.fromJson(
        json,
      ),
      _ => UnknownAgentAutomationEnvironmentResource.fromJson(json),
    };
  }

  /// Exact received type discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();
}

/// Detached future AgentAutomationEnvironmentResource variant; not a writable request.
final class UnknownAgentAutomationEnvironmentResource
    extends AgentAutomationEnvironmentResource {
  const UnknownAgentAutomationEnvironmentResource._(this.rawJson);

  /// Rejects known tags so malformed known payloads cannot escape validation.
  factory UnknownAgentAutomationEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentAutomationEnvironmentResource.type',
    );
    if (const ['none', 'openai_hosted', 'self_hosted'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentAutomationEnvironmentResource: expected a future discriminator',
      );
    }
    return UnknownAgentAutomationEnvironmentResource._(
      snapshotAgentJson(json, 'UnknownAgentAutomationEnvironmentResource'),
    );
  }

  /// Immutable received JSON, including future fields.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces the future snapshot while retaining its unknown discriminator.
  UnknownAgentAutomationEnvironmentResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentAutomationEnvironmentResource.fromJson(
    rawJson ?? this.rawJson,
  );
}

/// Service provenance: [AgentAutomationDeveloperCreator],
/// [AgentAutomationAgentCreator], or [UnknownAgentAutomationCreator].
sealed class AgentAutomationCreator extends AgentJsonModel {
  const AgentAutomationCreator();

  /// Dispatches known variants strictly and preserves future discriminators.
  factory AgentAutomationCreator.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentAutomationCreator.type',
    )) {
      'developer' => AgentAutomationDeveloperCreator.fromJson(json),
      'agent' => AgentAutomationAgentCreator.fromJson(json),
      _ => UnknownAgentAutomationCreator.fromJson(json),
    };
  }

  /// Exact received type discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();
}

/// Detached future AgentAutomationCreator variant; not a writable request.
final class UnknownAgentAutomationCreator extends AgentAutomationCreator {
  const UnknownAgentAutomationCreator._(this.rawJson);

  /// Rejects known tags so malformed known payloads cannot escape validation.
  factory UnknownAgentAutomationCreator.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentAutomationCreator.type',
    );
    if (const ['developer', 'agent'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentAutomationCreator: expected a future discriminator',
      );
    }
    return UnknownAgentAutomationCreator._(
      snapshotAgentJson(json, 'UnknownAgentAutomationCreator'),
    );
  }

  /// Immutable received JSON, including future fields.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces the future snapshot while retaining its unknown discriminator.
  UnknownAgentAutomationCreator copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentAutomationCreator.fromJson(rawJson ?? this.rawJson);
}

/// Delivery source: [AgentAutomationManualInvocationSource],
/// [AgentAutomationScheduledInvocationSource], or
/// [UnknownAgentAutomationInvocationSource] for a future kind.
sealed class AgentAutomationInvocationSource extends AgentJsonModel {
  const AgentAutomationInvocationSource();

  /// Dispatches known variants strictly and preserves future discriminators.
  factory AgentAutomationInvocationSource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentAutomationInvocationSource.type',
    )) {
      'manual' => AgentAutomationManualInvocationSource.fromJson(json),
      'automation' => AgentAutomationScheduledInvocationSource.fromJson(json),
      _ => UnknownAgentAutomationInvocationSource.fromJson(json),
    };
  }

  /// Exact received type discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();
}

/// Detached future AgentAutomationInvocationSource variant; not a writable request.
final class UnknownAgentAutomationInvocationSource
    extends AgentAutomationInvocationSource {
  const UnknownAgentAutomationInvocationSource._(this.rawJson);

  /// Rejects known tags so malformed known payloads cannot escape validation.
  factory UnknownAgentAutomationInvocationSource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentAutomationInvocationSource.type',
    );
    if (const ['manual', 'automation'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentAutomationInvocationSource: expected a future discriminator',
      );
    }
    return UnknownAgentAutomationInvocationSource._(
      snapshotAgentJson(json, 'UnknownAgentAutomationInvocationSource'),
    );
  }

  /// Immutable received JSON, including future fields.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces the future snapshot while retaining its unknown discriminator.
  UnknownAgentAutomationInvocationSource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      UnknownAgentAutomationInvocationSource.fromJson(rawJson ?? this.rawJson);
}

/// Service-recorded developer creation provenance.
final class AgentAutomationDeveloperCreator extends AgentAutomationCreator {
  /// Creates an owned resource snapshot.
  AgentAutomationDeveloperCreator({Map<String, dynamic> rawJson = const {}})
    : rawJson = agentExtras(rawJson, const [
        'type',
      ], 'AgentAutomationDeveloperCreator') {
    validate();
  }

  /// Fixed `type` discriminator.
  @override
  String get type => 'developer';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationDeveloperCreator.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'developer',
      'AgentAutomationDeveloperCreator',
    );
    return AgentAutomationDeveloperCreator(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationDeveloperCreator copyWith({Map<String, dynamic>? rawJson}) =>
      AgentAutomationDeveloperCreator(rawJson: rawJson ?? this.rawJson);
}

/// Service-recorded agent creation provenance, independent of invocation source.
final class AgentAutomationAgentCreator extends AgentAutomationCreator {
  /// Creates an owned resource snapshot.
  AgentAutomationAgentCreator({
    required this.sessionId,
    required this.toolCallId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'type',
         'session_id',
         'tool_call_id',
       ], 'AgentAutomationAgentCreator') {
    validate();
  }

  /// The creator session, also the target of this agent-created automation.
  final String sessionId;

  /// The service-recorded tool call that created the automation.
  final String toolCallId;

  /// Fixed `type` discriminator.
  @override
  String get type => 'agent';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationAgentCreator.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'agent', 'AgentAutomationAgentCreator');
    return AgentAutomationAgentCreator(
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentAutomationAgentCreator.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      toolCallId: requiredAgentValue(
        json,
        'tool_call_id',
        'AgentAutomationAgentCreator.toolCallId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type', 'session_id', 'tool_call_id'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      sessionId,
      'AgentAutomationAgentCreator.sessionId',
      min: 0,
    );
    validateAgentLength(
      toolCallId,
      'AgentAutomationAgentCreator.toolCallId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'session_id': sessionId,
    'tool_call_id': toolCallId,
    'type': type,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationAgentCreator copyWith({
    String? sessionId,
    String? toolCallId,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationAgentCreator(
    sessionId: sessionId ?? this.sessionId,
    toolCallId: toolCallId ?? this.toolCallId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A saved selection with no execution environment.
final class AgentAutomationNoneEnvironmentResource
    extends AgentAutomationEnvironmentResource {
  /// Creates an owned resource snapshot.
  AgentAutomationNoneEnvironmentResource({
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'type',
       ], 'AgentAutomationNoneEnvironmentResource') {
    validate();
  }

  /// Fixed `type` discriminator.
  @override
  String get type => 'none';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationNoneEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'none',
      'AgentAutomationNoneEnvironmentResource',
    );
    return AgentAutomationNoneEnvironmentResource(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationNoneEnvironmentResource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      AgentAutomationNoneEnvironmentResource(rawJson: rawJson ?? this.rawJson);
}

/// Saved hosted environment selection with confidential setup values omitted.
/// Every override key is required but nullable; null retains creation/template defaults.
final class AgentAutomationHostedEnvironmentResource
    extends AgentAutomationEnvironmentResource {
  /// Creates an owned resource snapshot.
  AgentAutomationHostedEnvironmentResource({
    required this.environmentId,
    required this.environmentTemplateId,
    required this.containerSize,
    required this.packages,
    required this.network,
    required this.desktop,
    required List<String>? capabilityDirectories,
    required List<AgentHostedTemplateSkill>? skills,
    required List<AgentSessionHostedPluginResource>? plugins,
    required List<AgentHostedTemplateFile>? files,
    Map<String, dynamic> rawJson = const {},
  }) : capabilityDirectories = capabilityDirectories == null
           ? null
           : List.unmodifiable(capabilityDirectories),
       skills = skills == null ? null : List.unmodifiable(skills),
       plugins = plugins == null ? null : List.unmodifiable(plugins),
       files = files == null ? null : List.unmodifiable(files),
       rawJson = agentExtras(rawJson, const [
         'type',
         'environment_id',
         'environment_template_id',
         'container_size',
         'packages',
         'network',
         'desktop',
         'capability_directories',
         'skills',
         'plugins',
         'files',
       ], 'AgentAutomationHostedEnvironmentResource') {
    validate();
  }

  /// Existing environment reference, or null to provision a new environment.
  final String? environmentId;

  /// Template reference, or null when no template is selected.
  final String? environmentTemplateId;

  /// Container size override, or null for the creation default.
  final AgentSessionContainerSizeResource? containerSize;

  /// Package overrides, or null to inherit the template or creation defaults.
  final AgentSessionEnvironmentPackagesResource? packages;

  /// Network overrides, or null to inherit the template or creation defaults.
  final AgentSessionNetworkPolicyResource? network;

  /// Desktop override, or null to inherit the template or creation default.
  final AgentSessionDesktopResource? desktop;

  /// Directory overrides, or null to inherit the template or creation defaults.
  final List<String>? capabilityDirectories;

  /// Skill override metadata without archive contents, or null to inherit.
  final List<AgentHostedTemplateSkill>? skills;

  /// Plugin override metadata without archive contents, or null to inherit.
  final List<AgentSessionHostedPluginResource>? plugins;

  /// File override metadata without confidential contents, or null to inherit.
  final List<AgentHostedTemplateFile>? files;

  /// Fixed `type` discriminator.
  @override
  String get type => 'openai_hosted';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationHostedEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'openai_hosted',
      'AgentAutomationHostedEnvironmentResource',
    );
    return AgentAutomationHostedEnvironmentResource(
      environmentId: requiredAgentValue(
        json,
        'environment_id',
        'AgentAutomationHostedEnvironmentResource.environmentId',
        requireAgentString,
        nullable: true,
      ),
      environmentTemplateId: requiredAgentValue(
        json,
        'environment_template_id',
        'AgentAutomationHostedEnvironmentResource.environmentTemplateId',
        requireAgentString,
        nullable: true,
      ),
      containerSize: requiredAgentValue(
        json,
        'container_size',
        'AgentAutomationHostedEnvironmentResource.containerSize',
        (value, context) => AgentSessionContainerSizeResource.fromJson(value),
        nullable: true,
      ),
      packages: requiredAgentValue(
        json,
        'packages',
        'AgentAutomationHostedEnvironmentResource.packages',
        (value, context) => AgentSessionEnvironmentPackagesResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      network: requiredAgentValue(
        json,
        'network',
        'AgentAutomationHostedEnvironmentResource.network',
        (value, context) => AgentSessionNetworkPolicyResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      desktop: requiredAgentValue(
        json,
        'desktop',
        'AgentAutomationHostedEnvironmentResource.desktop',
        (value, context) => AgentSessionDesktopResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      capabilityDirectories: requiredAgentValue(
        json,
        'capability_directories',
        'AgentAutomationHostedEnvironmentResource.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((item) => requireAgentString(item, context)).toList(),
        nullable: true,
      ),
      skills: requiredAgentValue(
        json,
        'skills',
        'AgentAutomationHostedEnvironmentResource.skills',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) => AgentHostedTemplateSkill.fromJson(
                requireAgentObject(item, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      plugins: requiredAgentValue(
        json,
        'plugins',
        'AgentAutomationHostedEnvironmentResource.plugins',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) => AgentSessionHostedPluginResource.fromJson(
                requireAgentObject(item, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      files: requiredAgentValue(
        json,
        'files',
        'AgentAutomationHostedEnvironmentResource.files',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) => AgentHostedTemplateFile.fromJson(
                requireAgentObject(item, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'type',
            'environment_id',
            'environment_template_id',
            'container_size',
            'packages',
            'network',
            'desktop',
            'capability_directories',
            'skills',
            'plugins',
            'files',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (environmentId != null) {
      validateAgentLength(
        environmentId!,
        'AgentAutomationHostedEnvironmentResource.environmentId',
        min: 0,
      );
    }
    if (environmentTemplateId != null) {
      validateAgentLength(
        environmentTemplateId!,
        'AgentAutomationHostedEnvironmentResource.environmentTemplateId',
        min: 0,
      );
    }
    if (containerSize != null) {
      containerSize!.validate();
    }
    if (packages != null) {
      packages!.validate();
    }
    if (network != null) {
      network!.validate();
    }
    if (desktop != null) {
      desktop!.validate();
    }
    if (capabilityDirectories != null) {
      validateAgentCount(
        capabilityDirectories!.length,
        'AgentAutomationHostedEnvironmentResource.capabilityDirectories',
        min: 0,
        max: 2000,
      );
      for (final item in capabilityDirectories!) {
        validateAgentLength(
          item,
          'AgentAutomationHostedEnvironmentResource.capabilityDirectories',
          min: 0,
        );
      }
    }
    if (skills != null) {
      validateAgentCount(
        skills!.length,
        'AgentAutomationHostedEnvironmentResource.skills',
        min: 0,
        max: 2000,
      );
      for (final item in skills!) {
        item.validate();
      }
    }
    if (plugins != null) {
      validateAgentCount(
        plugins!.length,
        'AgentAutomationHostedEnvironmentResource.plugins',
        min: 0,
        max: 2000,
      );
      for (final item in plugins!) {
        item.validate();
      }
    }
    if (files != null) {
      validateAgentCount(
        files!.length,
        'AgentAutomationHostedEnvironmentResource.files',
        min: 0,
        max: 2000,
      );
      for (final item in files!) {
        item.validate();
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment_id': environmentId,
    'environment_template_id': environmentTemplateId,
    'container_size': containerSize?.toJson(),
    'packages': packages?.toJson(),
    'network': network?.toJson(),
    'desktop': desktop?.toJson(),
    'capability_directories': capabilityDirectories
        ?.map((item) => item)
        .toList(),
    'skills': skills?.map((item) => item.toJson()).toList(),
    'plugins': plugins?.map((item) => item.toJson()).toList(),
    'files': files?.map((item) => item.toJson()).toList(),
    'type': type,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationHostedEnvironmentResource copyWith({
    Object? environmentId = unsetCopyWithValue,
    Object? environmentTemplateId = unsetCopyWithValue,
    Object? containerSize = unsetCopyWithValue,
    Object? packages = unsetCopyWithValue,
    Object? network = unsetCopyWithValue,
    Object? desktop = unsetCopyWithValue,
    Object? capabilityDirectories = unsetCopyWithValue,
    Object? skills = unsetCopyWithValue,
    Object? plugins = unsetCopyWithValue,
    Object? files = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationHostedEnvironmentResource(
    environmentId: copyAgentValue<String>(
      environmentId,
      this.environmentId,
      'AgentAutomationHostedEnvironmentResource.environmentId',
    ),
    environmentTemplateId: copyAgentValue<String>(
      environmentTemplateId,
      this.environmentTemplateId,
      'AgentAutomationHostedEnvironmentResource.environmentTemplateId',
    ),
    containerSize: copyAgentValue<AgentSessionContainerSizeResource>(
      containerSize,
      this.containerSize,
      'AgentAutomationHostedEnvironmentResource.containerSize',
    ),
    packages: copyAgentValue<AgentSessionEnvironmentPackagesResource>(
      packages,
      this.packages,
      'AgentAutomationHostedEnvironmentResource.packages',
    ),
    network: copyAgentValue<AgentSessionNetworkPolicyResource>(
      network,
      this.network,
      'AgentAutomationHostedEnvironmentResource.network',
    ),
    desktop: copyAgentValue<AgentSessionDesktopResource>(
      desktop,
      this.desktop,
      'AgentAutomationHostedEnvironmentResource.desktop',
    ),
    capabilityDirectories: _copyAutomationList<String>(
      capabilityDirectories,
      this.capabilityDirectories,
      'AgentAutomationHostedEnvironmentResource.capabilityDirectories',
    ),
    skills: _copyAutomationList<AgentHostedTemplateSkill>(
      skills,
      this.skills,
      'AgentAutomationHostedEnvironmentResource.skills',
    ),
    plugins: _copyAutomationList<AgentSessionHostedPluginResource>(
      plugins,
      this.plugins,
      'AgentAutomationHostedEnvironmentResource.plugins',
    ),
    files: _copyAutomationList<AgentHostedTemplateFile>(
      files,
      this.files,
      'AgentAutomationHostedEnvironmentResource.files',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Saved self-hosted selection, without an active session connection or remote URL.
final class AgentAutomationSelfHostedEnvironmentResource
    extends AgentAutomationEnvironmentResource {
  /// Creates an owned resource snapshot.
  AgentAutomationSelfHostedEnvironmentResource({
    required this.environmentId,
    required this.workspaceDirectory,
    required List<String> capabilityDirectories,
    Map<String, dynamic> rawJson = const {},
  }) : capabilityDirectories = List.unmodifiable(capabilityDirectories),
       rawJson = agentExtras(rawJson, const [
         'type',
         'environment_id',
         'workspace_directory',
         'capability_directories',
       ], 'AgentAutomationSelfHostedEnvironmentResource') {
    validate();
  }

  /// Existing registration, or null to create a session-owned environment.
  final String? environmentId;

  /// The saved absolute project directory in the environment.
  final String workspaceDirectory;

  /// Directories that expose capabilities to the agent.
  final List<String> capabilityDirectories;

  /// Fixed `type` discriminator.
  @override
  String get type => 'self_hosted';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationSelfHostedEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'self_hosted',
      'AgentAutomationSelfHostedEnvironmentResource',
    );
    return AgentAutomationSelfHostedEnvironmentResource(
      environmentId: requiredAgentValue(
        json,
        'environment_id',
        'AgentAutomationSelfHostedEnvironmentResource.environmentId',
        requireAgentString,
        nullable: true,
      ),
      workspaceDirectory: requiredAgentValue(
        json,
        'workspace_directory',
        'AgentAutomationSelfHostedEnvironmentResource.workspaceDirectory',
        requireAgentString,
        nullable: false,
      )!,
      capabilityDirectories: requiredAgentValue(
        json,
        'capability_directories',
        'AgentAutomationSelfHostedEnvironmentResource.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((item) => requireAgentString(item, context)).toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'type',
            'environment_id',
            'workspace_directory',
            'capability_directories',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (environmentId != null) {
      validateAgentLength(
        environmentId!,
        'AgentAutomationSelfHostedEnvironmentResource.environmentId',
        min: 0,
      );
    }
    validateAgentLength(
      workspaceDirectory,
      'AgentAutomationSelfHostedEnvironmentResource.workspaceDirectory',
      min: 0,
    );
    validateAgentCount(
      capabilityDirectories.length,
      'AgentAutomationSelfHostedEnvironmentResource.capabilityDirectories',
      min: 0,
      max: 2000,
    );
    for (final item in capabilityDirectories) {
      validateAgentLength(
        item,
        'AgentAutomationSelfHostedEnvironmentResource.capabilityDirectories',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment_id': environmentId,
    'workspace_directory': workspaceDirectory,
    'capability_directories': capabilityDirectories
        .map((item) => item)
        .toList(),
    'type': type,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationSelfHostedEnvironmentResource copyWith({
    Object? environmentId = unsetCopyWithValue,
    String? workspaceDirectory,
    List<String>? capabilityDirectories,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationSelfHostedEnvironmentResource(
    environmentId: copyAgentValue<String>(
      environmentId,
      this.environmentId,
      'AgentAutomationSelfHostedEnvironmentResource.environmentId',
    ),
    workspaceDirectory: workspaceDirectory ?? this.workspaceDirectory,
    capabilityDirectories: capabilityDirectories ?? this.capabilityDirectories,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Inline agent configuration without a generated session-local identity or name.
final class AgentAutomationAgentConfig extends AgentJsonModel {
  /// Creates an owned resource snapshot.
  AgentAutomationAgentConfig({
    required this.model,
    required this.reasoning,
    required this.text,
    required this.serviceTier,
    required this.instructions,
    required List<AgentSessionToolResource> tools,
    required this.multiAgent,
    this.compaction,
    this.experimental,
    Map<String, dynamic> rawJson = const {},
  }) : tools = List.unmodifiable(tools),
       rawJson = agentExtras(rawJson, const [
         'model',
         'reasoning',
         'text',
         'service_tier',
         'instructions',
         'tools',
         'multi_agent',
         'compaction',
         'experimental',
       ], 'AgentAutomationAgentConfig') {
    validate();
  }

  /// The requested model name, preserved exactly.
  final String model;

  /// The configured reasoning policy.
  final AgentReasoning reasoning;

  /// The configured output format and verbosity.
  final AgentText text;

  /// The configured service-tier policy.
  final AgentServiceTierResource serviceTier;

  /// Configured instructions, or null when none were supplied.
  final String? instructions;

  /// Configured tools, excluding confidential credentials.
  final List<AgentSessionToolResource> tools;

  /// The policy for creating and coordinating subagents.
  final AgentMultiAgent multiAgent;

  /// Effective context compaction settings, if supplied by the service.
  final AgentCompaction? compaction;

  /// Effective experimental settings, if supplied by the service.
  final AgentExperimental? experimental;

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationAgentConfig.fromJson(Map<String, dynamic> json) {
    return AgentAutomationAgentConfig(
      model: requiredAgentValue(
        json,
        'model',
        'AgentAutomationAgentConfig.model',
        requireAgentString,
        nullable: false,
      )!,
      reasoning: requiredAgentValue(
        json,
        'reasoning',
        'AgentAutomationAgentConfig.reasoning',
        (value, context) =>
            AgentReasoning.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      text: requiredAgentValue(
        json,
        'text',
        'AgentAutomationAgentConfig.text',
        (value, context) =>
            AgentText.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      serviceTier: requiredAgentValue(
        json,
        'service_tier',
        'AgentAutomationAgentConfig.serviceTier',
        (value, context) => AgentServiceTierResource.fromJson(value),
        nullable: false,
      )!,
      instructions: requiredAgentValue(
        json,
        'instructions',
        'AgentAutomationAgentConfig.instructions',
        requireAgentString,
        nullable: true,
      ),
      tools: requiredAgentValue(
        json,
        'tools',
        'AgentAutomationAgentConfig.tools',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) => AgentSessionToolResource.fromJson(
                requireAgentObject(item, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      multiAgent: requiredAgentValue(
        json,
        'multi_agent',
        'AgentAutomationAgentConfig.multiAgent',
        (value, context) =>
            AgentMultiAgent.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      compaction: optionalAgentValue(
        json,
        'compaction',
        'AgentAutomationAgentConfig.compaction',
        (value, context) =>
            AgentCompaction.fromJson(requireAgentObject(value, context)),
        nullable: false,
      ),
      experimental: optionalAgentValue(
        json,
        'experimental',
        'AgentAutomationAgentConfig.experimental',
        (value, context) =>
            AgentExperimental.fromJson(requireAgentObject(value, context)),
        nullable: false,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'model',
            'reasoning',
            'text',
            'service_tier',
            'instructions',
            'tools',
            'multi_agent',
            'compaction',
            'experimental',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(model, 'AgentAutomationAgentConfig.model', min: 0);
    reasoning.validate();
    text.validate();
    serviceTier.validate();
    if (instructions != null) {
      validateAgentLength(
        instructions!,
        'AgentAutomationAgentConfig.instructions',
        min: 0,
      );
    }
    validateAgentCount(
      tools.length,
      'AgentAutomationAgentConfig.tools',
      min: 0,
      max: 2000,
    );
    for (final item in tools) {
      item.validate();
    }
    multiAgent.validate();
    if (compaction != null) {
      compaction!.validate();
    }
    if (experimental != null) {
      experimental!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'model': model,
    'reasoning': reasoning.toJson(),
    'text': text.toJson(),
    'service_tier': serviceTier.toJson(),
    'instructions': instructions,
    'tools': tools.map((item) => item.toJson()).toList(),
    'multi_agent': multiAgent.toJson(),
    if (compaction != null) 'compaction': compaction!.toJson(),
    if (experimental != null) 'experimental': experimental!.toJson(),
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationAgentConfig copyWith({
    String? model,
    AgentReasoning? reasoning,
    AgentText? text,
    AgentServiceTierResource? serviceTier,
    Object? instructions = unsetCopyWithValue,
    List<AgentSessionToolResource>? tools,
    AgentMultiAgent? multiAgent,
    Object? compaction = unsetCopyWithValue,
    Object? experimental = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationAgentConfig(
    model: model ?? this.model,
    reasoning: reasoning ?? this.reasoning,
    text: text ?? this.text,
    serviceTier: serviceTier ?? this.serviceTier,
    instructions: copyAgentValue<String>(
      instructions,
      this.instructions,
      'AgentAutomationAgentConfig.instructions',
    ),
    tools: tools ?? this.tools,
    multiAgent: multiAgent ?? this.multiAgent,
    compaction: copyAgentValue<AgentCompaction>(
      compaction,
      this.compaction,
      'AgentAutomationAgentConfig.compaction',
    ),
    experimental: copyAgentValue<AgentExperimental>(
      experimental,
      this.experimental,
      'AgentAutomationAgentConfig.experimental',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A stored user message, distinct from request messages and Responses items.
final class AgentAutomationInputMessage extends AgentJsonModel {
  /// Creates an owned resource snapshot.
  AgentAutomationInputMessage({
    required List<AgentSessionInputContentResource> content,
    Map<String, dynamic> rawJson = const {},
  }) : content = List.unmodifiable(content),
       rawJson = agentExtras(rawJson, const [
         'type',
         'role',
         'content',
       ], 'AgentAutomationInputMessage') {
    validate();
  }

  /// Stored user content, containing at most 2000 parts.
  final List<AgentSessionInputContentResource> content;

  /// Fixed `type` discriminator.
  String get type => 'message';

  /// Fixed `role` discriminator.
  String get role => 'user';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationInputMessage.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'message', 'AgentAutomationInputMessage');
    requireAgentTag(json, 'role', 'user', 'AgentAutomationInputMessage');
    return AgentAutomationInputMessage(
      content: requiredAgentValue(
        json,
        'content',
        'AgentAutomationInputMessage.content',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) => AgentSessionInputContentResource.fromJson(
                requireAgentObject(item, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type', 'role', 'content'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      content.length,
      'AgentAutomationInputMessage.content',
      min: 0,
      max: 2000,
    );
    for (final item in content) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'content': content.map((item) => item.toJson()).toList(),
    'type': type,
    'role': role,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationInputMessage copyWith({
    List<AgentSessionInputContentResource>? content,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationInputMessage(
    content: content ?? this.content,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Stored notification instructions delivered to an existing session.
final class AgentAutomationExistingSessionTargetResource
    extends AgentAutomationTargetResource {
  /// Creates an owned resource snapshot.
  AgentAutomationExistingSessionTargetResource({
    required this.sessionId,
    required this.instructions,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'type',
         'session_id',
         'instructions',
       ], 'AgentAutomationExistingSessionTargetResource') {
    validate();
  }

  /// The existing session receiving each invocation.
  final String sessionId;

  /// Saved notification instructions delivered to the existing session.
  final String instructions;

  /// Fixed `type` discriminator.
  @override
  String get type => 'existing_session';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationExistingSessionTargetResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'existing_session',
      'AgentAutomationExistingSessionTargetResource',
    );
    return AgentAutomationExistingSessionTargetResource(
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentAutomationExistingSessionTargetResource.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      instructions: requiredAgentValue(
        json,
        'instructions',
        'AgentAutomationExistingSessionTargetResource.instructions',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type', 'session_id', 'instructions'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      sessionId,
      'AgentAutomationExistingSessionTargetResource.sessionId',
      min: 0,
    );
    validateAgentLength(
      instructions,
      'AgentAutomationExistingSessionTargetResource.instructions',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'session_id': sessionId,
    'instructions': instructions,
    'type': type,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationExistingSessionTargetResource copyWith({
    String? sessionId,
    String? instructions,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationExistingSessionTargetResource(
    sessionId: sessionId ?? this.sessionId,
    instructions: instructions ?? this.instructions,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Stored settings used to create a new session for each invocation.
final class AgentAutomationNewSessionTargetResource
    extends AgentAutomationTargetResource {
  /// Creates an owned resource snapshot.
  AgentAutomationNewSessionTargetResource({
    required this.agentId,
    required this.agent,
    required this.environment,
    required List<AgentAutomationInputMessage> input,
    required List<String> vaultIds,
    required Map<String, String> metadata,
    Map<String, dynamic> rawJson = const {},
  }) : input = List.unmodifiable(input),
       vaultIds = List.unmodifiable(vaultIds),
       metadata = Map<String, String>.unmodifiable(metadata),
       rawJson = agentExtras(rawJson, const [
         'type',
         'agent_id',
         'agent',
         'environment',
         'input',
         'vault_ids',
         'metadata',
       ], 'AgentAutomationNewSessionTargetResource') {
    validate();
  }

  /// The saved agent reference, or null when inline configuration is stored.
  final String? agentId;

  /// Inline configuration, or null when a saved agent reference is stored.
  final AgentAutomationAgentConfig? agent;

  /// Saved environment selection used when each new session is created.
  final AgentAutomationEnvironmentResource environment;

  /// Initial stored user messages delivered to every new session.
  final List<AgentAutomationInputMessage> input;

  /// Vault references made available to every new session.
  final List<String> vaultIds;

  /// Metadata attached to every newly created session.
  final Map<String, String> metadata;

  /// Fixed `type` discriminator.
  @override
  String get type => 'new_session';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationNewSessionTargetResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'new_session',
      'AgentAutomationNewSessionTargetResource',
    );
    return AgentAutomationNewSessionTargetResource(
      agentId: requiredAgentValue(
        json,
        'agent_id',
        'AgentAutomationNewSessionTargetResource.agentId',
        requireAgentString,
        nullable: true,
      ),
      agent: requiredAgentValue(
        json,
        'agent',
        'AgentAutomationNewSessionTargetResource.agent',
        (value, context) => AgentAutomationAgentConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      environment: requiredAgentValue(
        json,
        'environment',
        'AgentAutomationNewSessionTargetResource.environment',
        (value, context) => AgentAutomationEnvironmentResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      input: requiredAgentValue(
        json,
        'input',
        'AgentAutomationNewSessionTargetResource.input',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) => AgentAutomationInputMessage.fromJson(
                requireAgentObject(item, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      vaultIds: requiredAgentValue(
        json,
        'vault_ids',
        'AgentAutomationNewSessionTargetResource.vaultIds',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((item) => requireAgentString(item, context)).toList(),
        nullable: false,
      )!,
      metadata: requiredAgentValue(
        json,
        'metadata',
        'AgentAutomationNewSessionTargetResource.metadata',
        requireAgentStringMap,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'type',
            'agent_id',
            'agent',
            'environment',
            'input',
            'vault_ids',
            'metadata',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (agentId != null) {
      validateAgentLength(
        agentId!,
        'AgentAutomationNewSessionTargetResource.agentId',
        min: 0,
      );
    }
    if (agent != null) {
      agent!.validate();
    }
    environment.validate();
    validateAgentCount(
      input.length,
      'AgentAutomationNewSessionTargetResource.input',
      min: 0,
      max: 2000,
    );
    for (final item in input) {
      item.validate();
    }
    validateAgentCount(
      vaultIds.length,
      'AgentAutomationNewSessionTargetResource.vaultIds',
      min: 0,
      max: 2000,
    );
    for (final item in vaultIds) {
      validateAgentLength(
        item,
        'AgentAutomationNewSessionTargetResource.vaultIds',
        min: 0,
      );
    }
    for (final entry in metadata.entries) {
      validateAgentLength(
        entry.key,
        'AgentAutomationNewSessionTargetResource.metadata',
        min: 0,
      );
      validateAgentLength(
        entry.value,
        'AgentAutomationNewSessionTargetResource.metadata',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'agent_id': agentId,
    'agent': agent?.toJson(),
    'environment': environment.toJson(),
    'input': input.map((item) => item.toJson()).toList(),
    'vault_ids': vaultIds.map((item) => item).toList(),
    'metadata': metadata,
    'type': type,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationNewSessionTargetResource copyWith({
    Object? agentId = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    AgentAutomationEnvironmentResource? environment,
    List<AgentAutomationInputMessage>? input,
    List<String>? vaultIds,
    Map<String, String>? metadata,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationNewSessionTargetResource(
    agentId: copyAgentValue<String>(
      agentId,
      this.agentId,
      'AgentAutomationNewSessionTargetResource.agentId',
    ),
    agent: copyAgentValue<AgentAutomationAgentConfig>(
      agent,
      this.agent,
      'AgentAutomationNewSessionTargetResource.agent',
    ),
    environment: environment ?? this.environment,
    input: input ?? this.input,
    vaultIds: vaultIds ?? this.vaultIds,
    metadata: metadata ?? this.metadata,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A one-time schedule. Schedule completion does not mean agent work completed.
final class AgentAutomationOnce extends AgentAutomation {
  /// Creates an owned resource snapshot.
  AgentAutomationOnce({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.target,
    required Map<String, String> metadata,
    required this.createdBy,
    required this.runAt,
    required this.status,
    Map<String, dynamic> rawJson = const {},
  }) : metadata = Map<String, String>.unmodifiable(metadata),
       rawJson = agentExtras(rawJson, const [
         'type',
         'id',
         'object',
         'created_at',
         'name',
         'target',
         'metadata',
         'created_by',
         'run_at',
         'status',
       ], 'AgentAutomationOnce') {
    validate();
  }

  /// The received `id` field.
  @override
  final String id;

  /// The received `created_at` field.
  @override
  final int createdAt;

  /// The received `name` field.
  @override
  final String name;

  /// The received `target` field.
  @override
  final AgentAutomationTargetResource target;

  /// The received `metadata` field.
  @override
  final Map<String, String> metadata;

  /// The received `created_by` field.
  @override
  final AgentAutomationCreator createdBy;

  /// The received `run_at` field.
  final int runAt;

  /// The received `status` field.
  @override
  final AgentAutomationOnceStatus status;

  /// Fixed `type` discriminator.
  @override
  String get type => 'once';

  /// Fixed `object` discriminator.
  @override
  String get object => 'agent.automation';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationOnce.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'once', 'AgentAutomationOnce');
    requireAgentTag(json, 'object', 'agent.automation', 'AgentAutomationOnce');
    return AgentAutomationOnce(
      id: requiredAgentValue(
        json,
        'id',
        'AgentAutomationOnce.id',
        requireAgentString,
        nullable: false,
      )!,
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentAutomationOnce.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentAutomationOnce.name',
        requireAgentString,
        nullable: false,
      )!,
      target: requiredAgentValue(
        json,
        'target',
        'AgentAutomationOnce.target',
        (value, context) => AgentAutomationTargetResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      metadata: requiredAgentValue(
        json,
        'metadata',
        'AgentAutomationOnce.metadata',
        requireAgentStringMap,
        nullable: false,
      )!,
      createdBy: requiredAgentValue(
        json,
        'created_by',
        'AgentAutomationOnce.createdBy',
        (value, context) =>
            AgentAutomationCreator.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      runAt: requiredAgentValue(
        json,
        'run_at',
        'AgentAutomationOnce.runAt',
        requireAgentInt,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentAutomationOnce.status',
        (value, context) => AgentAutomationOnceStatus.fromJson(value),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'type',
            'id',
            'object',
            'created_at',
            'name',
            'target',
            'metadata',
            'created_by',
            'run_at',
            'status',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'AgentAutomationOnce.id', min: 0);
    validateAgentInt(createdAt, 'AgentAutomationOnce.createdAt');
    validateAgentLength(name, 'AgentAutomationOnce.name', min: 0);
    target.validate();
    for (final entry in metadata.entries) {
      validateAgentLength(entry.key, 'AgentAutomationOnce.metadata', min: 0);
      validateAgentLength(entry.value, 'AgentAutomationOnce.metadata', min: 0);
    }
    createdBy.validate();
    validateAgentInt(runAt, 'AgentAutomationOnce.runAt');
    status.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'created_at': createdAt,
    'name': name,
    'target': target.toJson(),
    'metadata': metadata,
    'created_by': createdBy.toJson(),
    'run_at': runAt,
    'status': status.toJson(),
    'type': type,
    'object': object,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationOnce copyWith({
    String? id,
    int? createdAt,
    String? name,
    AgentAutomationTargetResource? target,
    Map<String, String>? metadata,
    AgentAutomationCreator? createdBy,
    int? runAt,
    AgentAutomationOnceStatus? status,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationOnce(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    target: target ?? this.target,
    metadata: metadata ?? this.metadata,
    createdBy: createdBy ?? this.createdBy,
    runAt: runAt ?? this.runAt,
    status: status ?? this.status,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A recurring cron schedule, independent of any individual delivery or session.
final class AgentAutomationPeriodic extends AgentAutomation {
  /// Creates an owned resource snapshot.
  AgentAutomationPeriodic({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.target,
    required Map<String, String> metadata,
    required this.createdBy,
    required this.expression,
    required this.timezone,
    required this.status,
    Map<String, dynamic> rawJson = const {},
  }) : metadata = Map<String, String>.unmodifiable(metadata),
       rawJson = agentExtras(rawJson, const [
         'type',
         'id',
         'object',
         'created_at',
         'name',
         'target',
         'metadata',
         'created_by',
         'expression',
         'timezone',
         'status',
       ], 'AgentAutomationPeriodic') {
    validate();
  }

  /// The received `id` field.
  @override
  final String id;

  /// The received `created_at` field.
  @override
  final int createdAt;

  /// The received `name` field.
  @override
  final String name;

  /// The received `target` field.
  @override
  final AgentAutomationTargetResource target;

  /// The received `metadata` field.
  @override
  final Map<String, String> metadata;

  /// The received `created_by` field.
  @override
  final AgentAutomationCreator createdBy;

  /// The received `expression` field.
  final String expression;

  /// The received `timezone` field.
  final String timezone;

  /// The received `status` field.
  @override
  final AgentAutomationPeriodicStatus status;

  /// Fixed `type` discriminator.
  @override
  String get type => 'periodic';

  /// Fixed `object` discriminator.
  @override
  String get object => 'agent.automation';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationPeriodic.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'periodic', 'AgentAutomationPeriodic');
    requireAgentTag(
      json,
      'object',
      'agent.automation',
      'AgentAutomationPeriodic',
    );
    return AgentAutomationPeriodic(
      id: requiredAgentValue(
        json,
        'id',
        'AgentAutomationPeriodic.id',
        requireAgentString,
        nullable: false,
      )!,
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentAutomationPeriodic.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentAutomationPeriodic.name',
        requireAgentString,
        nullable: false,
      )!,
      target: requiredAgentValue(
        json,
        'target',
        'AgentAutomationPeriodic.target',
        (value, context) => AgentAutomationTargetResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      metadata: requiredAgentValue(
        json,
        'metadata',
        'AgentAutomationPeriodic.metadata',
        requireAgentStringMap,
        nullable: false,
      )!,
      createdBy: requiredAgentValue(
        json,
        'created_by',
        'AgentAutomationPeriodic.createdBy',
        (value, context) =>
            AgentAutomationCreator.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      expression: requiredAgentValue(
        json,
        'expression',
        'AgentAutomationPeriodic.expression',
        requireAgentString,
        nullable: false,
      )!,
      timezone: requiredAgentValue(
        json,
        'timezone',
        'AgentAutomationPeriodic.timezone',
        requireAgentString,
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentAutomationPeriodic.status',
        (value, context) => AgentAutomationPeriodicStatus.fromJson(value),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'type',
            'id',
            'object',
            'created_at',
            'name',
            'target',
            'metadata',
            'created_by',
            'expression',
            'timezone',
            'status',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'AgentAutomationPeriodic.id', min: 0);
    validateAgentInt(createdAt, 'AgentAutomationPeriodic.createdAt');
    validateAgentLength(name, 'AgentAutomationPeriodic.name', min: 0);
    target.validate();
    for (final entry in metadata.entries) {
      validateAgentLength(
        entry.key,
        'AgentAutomationPeriodic.metadata',
        min: 0,
      );
      validateAgentLength(
        entry.value,
        'AgentAutomationPeriodic.metadata',
        min: 0,
      );
    }
    createdBy.validate();
    validateAgentLength(
      expression,
      'AgentAutomationPeriodic.expression',
      min: 0,
    );
    validateAgentLength(timezone, 'AgentAutomationPeriodic.timezone', min: 0);
    status.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'created_at': createdAt,
    'name': name,
    'target': target.toJson(),
    'metadata': metadata,
    'created_by': createdBy.toJson(),
    'expression': expression,
    'timezone': timezone,
    'status': status.toJson(),
    'type': type,
    'object': object,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationPeriodic copyWith({
    String? id,
    int? createdAt,
    String? name,
    AgentAutomationTargetResource? target,
    Map<String, String>? metadata,
    AgentAutomationCreator? createdBy,
    String? expression,
    String? timezone,
    AgentAutomationPeriodicStatus? status,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationPeriodic(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    target: target ?? this.target,
    metadata: metadata ?? this.metadata,
    createdBy: createdBy ?? this.createdBy,
    expression: expression ?? this.expression,
    timezone: timezone ?? this.timezone,
    status: status ?? this.status,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A permanent delivery error reported by the service.
final class AgentAutomationInvocationError extends AgentJsonModel {
  /// Creates an owned resource snapshot.
  AgentAutomationInvocationError({
    required this.code,
    required this.message,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'code',
         'message',
       ], 'AgentAutomationInvocationError') {
    validate();
  }

  /// The machine-readable delivery error code.
  final String code;

  /// The service explanation of the permanent delivery failure.
  final String message;

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationInvocationError.fromJson(Map<String, dynamic> json) {
    return AgentAutomationInvocationError(
      code: requiredAgentValue(
        json,
        'code',
        'AgentAutomationInvocationError.code',
        requireAgentString,
        nullable: false,
      )!,
      message: requiredAgentValue(
        json,
        'message',
        'AgentAutomationInvocationError.message',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['code', 'message'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(code, 'AgentAutomationInvocationError.code', min: 0);
    validateAgentLength(
      message,
      'AgentAutomationInvocationError.message',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'code': code,
    'message': message,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationInvocationError copyWith({
    String? code,
    String? message,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationInvocationError(
    code: code ?? this.code,
    message: message ?? this.message,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An explicitly requested manual delivery, independent of the saved schedule.
final class AgentAutomationManualInvocationSource
    extends AgentAutomationInvocationSource {
  /// Creates an owned resource snapshot.
  AgentAutomationManualInvocationSource({
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'type',
       ], 'AgentAutomationManualInvocationSource') {
    validate();
  }

  /// Fixed `type` discriminator.
  @override
  String get type => 'manual';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationManualInvocationSource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'manual',
      'AgentAutomationManualInvocationSource',
    );
    return AgentAutomationManualInvocationSource(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationManualInvocationSource copyWith({
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationManualInvocationSource(rawJson: rawJson ?? this.rawJson);
}

/// A scheduled delivery with the immutable automation snapshot for that occurrence.
final class AgentAutomationScheduledInvocationSource
    extends AgentAutomationInvocationSource {
  /// Creates an owned resource snapshot.
  AgentAutomationScheduledInvocationSource({
    required this.automation,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'type',
         'automation',
       ], 'AgentAutomationScheduledInvocationSource') {
    validate();
  }

  /// The safe automation snapshot recorded for this scheduled occurrence.
  final AgentAutomation automation;

  /// Fixed `type` discriminator.
  @override
  String get type => 'automation';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationScheduledInvocationSource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'automation',
      'AgentAutomationScheduledInvocationSource',
    );
    return AgentAutomationScheduledInvocationSource(
      automation: requiredAgentValue(
        json,
        'automation',
        'AgentAutomationScheduledInvocationSource.automation',
        (value, context) =>
            AgentAutomation.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type', 'automation'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    automation.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'automation': automation.toJson(),
    'type': type,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationScheduledInvocationSource copyWith({
    AgentAutomation? automation,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationScheduledInvocationSource(
    automation: automation ?? this.automation,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// One delivery attempt. Delivery completion is independent of agent work completion.
final class AgentAutomationInvocation extends AgentJsonModel {
  /// Creates an owned resource snapshot.
  AgentAutomationInvocation({
    required this.id,
    required this.automationId,
    required this.createdAt,
    required this.source,
    required this.scheduledAt,
    required this.sessionId,
    required this.status,
    required this.skipReason,
    required this.error,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'object',
         'automation_id',
         'created_at',
         'source',
         'scheduled_at',
         'session_id',
         'status',
         'skip_reason',
         'error',
       ], 'AgentAutomationInvocation') {
    validate();
  }

  /// The received `id` field.
  final String id;

  /// The received `automation_id` field.
  final String automationId;

  /// The received `created_at` field.
  final int createdAt;

  /// The received `source` field.
  final AgentAutomationInvocationSource source;

  /// The received `scheduled_at` field.
  final int? scheduledAt;

  /// The received `session_id` field.
  final String? sessionId;

  /// The received `status` field.
  final AgentAutomationInvocationStatus status;

  /// The received `skip_reason` field.
  final String? skipReason;

  /// The received `error` field.
  final AgentAutomationInvocationError? error;

  /// Fixed `object` discriminator.
  String get object => 'agent.automation.invocation';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationInvocation.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.automation.invocation',
      'AgentAutomationInvocation',
    );
    return AgentAutomationInvocation(
      id: requiredAgentValue(
        json,
        'id',
        'AgentAutomationInvocation.id',
        requireAgentString,
        nullable: false,
      )!,
      automationId: requiredAgentValue(
        json,
        'automation_id',
        'AgentAutomationInvocation.automationId',
        requireAgentString,
        nullable: false,
      )!,
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentAutomationInvocation.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      source: requiredAgentValue(
        json,
        'source',
        'AgentAutomationInvocation.source',
        (value, context) => AgentAutomationInvocationSource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      scheduledAt: requiredAgentValue(
        json,
        'scheduled_at',
        'AgentAutomationInvocation.scheduledAt',
        requireAgentInt,
        nullable: true,
      ),
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentAutomationInvocation.sessionId',
        requireAgentString,
        nullable: true,
      ),
      status: requiredAgentValue(
        json,
        'status',
        'AgentAutomationInvocation.status',
        (value, context) => AgentAutomationInvocationStatus.fromJson(value),
        nullable: false,
      )!,
      skipReason: requiredAgentValue(
        json,
        'skip_reason',
        'AgentAutomationInvocation.skipReason',
        requireAgentString,
        nullable: true,
      ),
      error: requiredAgentValue(
        json,
        'error',
        'AgentAutomationInvocation.error',
        (value, context) => AgentAutomationInvocationError.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'object',
            'automation_id',
            'created_at',
            'source',
            'scheduled_at',
            'session_id',
            'status',
            'skip_reason',
            'error',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'AgentAutomationInvocation.id', min: 0);
    validateAgentLength(
      automationId,
      'AgentAutomationInvocation.automationId',
      min: 0,
    );
    validateAgentInt(createdAt, 'AgentAutomationInvocation.createdAt');
    source.validate();
    if (scheduledAt != null) {
      validateAgentInt(scheduledAt!, 'AgentAutomationInvocation.scheduledAt');
    }
    if (sessionId != null) {
      validateAgentLength(
        sessionId!,
        'AgentAutomationInvocation.sessionId',
        min: 0,
      );
    }
    status.validate();
    if (skipReason != null) {
      validateAgentLength(
        skipReason!,
        'AgentAutomationInvocation.skipReason',
        min: 0,
      );
    }
    if (error != null) {
      error!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'automation_id': automationId,
    'created_at': createdAt,
    'source': source.toJson(),
    'scheduled_at': scheduledAt,
    'session_id': sessionId,
    'status': status.toJson(),
    'skip_reason': skipReason,
    'error': error?.toJson(),
    'object': object,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationInvocation copyWith({
    String? id,
    String? automationId,
    int? createdAt,
    AgentAutomationInvocationSource? source,
    Object? scheduledAt = unsetCopyWithValue,
    Object? sessionId = unsetCopyWithValue,
    AgentAutomationInvocationStatus? status,
    Object? skipReason = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationInvocation(
    id: id ?? this.id,
    automationId: automationId ?? this.automationId,
    createdAt: createdAt ?? this.createdAt,
    source: source ?? this.source,
    scheduledAt: copyAgentValue<int>(
      scheduledAt,
      this.scheduledAt,
      'AgentAutomationInvocation.scheduledAt',
    ),
    sessionId: copyAgentValue<String>(
      sessionId,
      this.sessionId,
      'AgentAutomationInvocation.sessionId',
    ),
    status: status ?? this.status,
    skipReason: copyAgentValue<String>(
      skipReason,
      this.skipReason,
      'AgentAutomationInvocation.skipReason',
    ),
    error: copyAgentValue<AgentAutomationInvocationError>(
      error,
      this.error,
      'AgentAutomationInvocation.error',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The actual automation deletion result reported by the service.
final class DeletedAgentAutomation extends AgentJsonModel {
  /// Creates an owned resource snapshot.
  DeletedAgentAutomation({
    required this.id,
    required this.deleted,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'object',
         'deleted',
       ], 'DeletedAgentAutomation') {
    validate();
  }

  /// The opaque resource ID.
  final String id;

  /// Whether the service reports that the automation was deleted.
  final bool deleted;

  /// Fixed `object` discriminator.
  String get object => 'agent.automation.deleted';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory DeletedAgentAutomation.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.automation.deleted',
      'DeletedAgentAutomation',
    );
    return DeletedAgentAutomation(
      id: requiredAgentValue(
        json,
        'id',
        'DeletedAgentAutomation.id',
        requireAgentString,
        nullable: false,
      )!,
      deleted: requiredAgentValue(
        json,
        'deleted',
        'DeletedAgentAutomation.deleted',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['id', 'object', 'deleted'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'DeletedAgentAutomation.id', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'deleted': deleted,
    'object': object,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  DeletedAgentAutomation copyWith({
    String? id,
    bool? deleted,
    Map<String, dynamic>? rawJson,
  }) => DeletedAgentAutomation(
    id: id ?? this.id,
    deleted: deleted ?? this.deleted,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// One cursor page of saved automations, retaining actual server cursor facts.
final class AgentAutomationList extends AgentJsonModel {
  /// Creates an owned resource snapshot.
  AgentAutomationList({
    required List<AgentAutomation> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, const [
         'object',
         'data',
         'first_id',
         'last_id',
         'has_more',
       ], 'AgentAutomationList') {
    validate();
  }

  /// Resources in this page, in the requested order.
  final List<AgentAutomation> data;

  /// The first resource ID, or null for an empty page.
  final String? firstId;

  /// The next-page cursor, or null for an empty page. Keep filters and order unchanged.
  final String? lastId;

  /// Whether the service reports another page is available.
  final bool hasMore;

  /// Fixed `object` discriminator.
  String get object => 'list';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentAutomationList');
    return AgentAutomationList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentAutomationList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) =>
                  AgentAutomation.fromJson(requireAgentObject(item, context)),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentAutomationList.firstId',
        requireAgentString,
        nullable: true,
      ),
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentAutomationList.lastId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentAutomationList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'object',
            'data',
            'first_id',
            'last_id',
            'has_more',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      data.length,
      'AgentAutomationList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'AgentAutomationList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'AgentAutomationList.lastId', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'data': data.map((item) => item.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
    'object': object,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationList copyWith({
    List<AgentAutomation>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'AgentAutomationList.firstId',
    ),
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'AgentAutomationList.lastId',
    ),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// One cursor page of delivery records, retaining actual server cursor facts.
final class AgentAutomationInvocationList extends AgentJsonModel {
  /// Creates an owned resource snapshot.
  AgentAutomationInvocationList({
    required List<AgentAutomationInvocation> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, const [
         'object',
         'data',
         'first_id',
         'last_id',
         'has_more',
       ], 'AgentAutomationInvocationList') {
    validate();
  }

  /// Resources in this page, in the requested order.
  final List<AgentAutomationInvocation> data;

  /// The first resource ID, or null for an empty page.
  final String? firstId;

  /// The next-page cursor, or null for an empty page. Keep filters and order unchanged.
  final String? lastId;

  /// Whether the service reports another page is available.
  final bool hasMore;

  /// Fixed `object` discriminator.
  String get object => 'list';

  /// Detached finite future metadata; declared fields cannot be shadowed.
  final Map<String, dynamic> rawJson;

  /// Parses required/nullability rules without coercion or private values.
  factory AgentAutomationInvocationList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentAutomationInvocationList');
    return AgentAutomationInvocationList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentAutomationInvocationList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (item) => AgentAutomationInvocation.fromJson(
                requireAgentObject(item, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentAutomationInvocationList.firstId',
        requireAgentString,
        nullable: true,
      ),
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentAutomationInvocationList.lastId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentAutomationInvocationList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'object',
            'data',
            'first_id',
            'last_id',
            'has_more',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      data.length,
      'AgentAutomationInvocationList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(
        firstId!,
        'AgentAutomationInvocationList.firstId',
        min: 0,
      );
    }
    if (lastId != null) {
      validateAgentLength(
        lastId!,
        'AgentAutomationInvocationList.lastId',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'data': data.map((item) => item.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
    'object': object,
  };

  /// Copies supplied fields while preserving all other snapshot values.
  AgentAutomationInvocationList copyWith({
    List<AgentAutomationInvocation>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => AgentAutomationInvocationList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'AgentAutomationInvocationList.firstId',
    ),
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'AgentAutomationInvocationList.lastId',
    ),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );
}

List<T>? _copyAutomationList<T>(
  Object? value,
  List<T>? current,
  String context,
) {
  if (identical(value, unsetCopyWithValue)) return current;
  if (value == null) return null;
  return requireAgentList(value, context).map((item) {
    if (item is! T) {
      throw FormatException('$context: expected the declared item type');
    }
    return item;
  }).toList();
}
