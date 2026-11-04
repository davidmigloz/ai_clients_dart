import '../common/copy_with_sentinel.dart';
import 'agent_json_helpers.dart';

/// Writable context compaction settings shared by Agents and session overrides.
///
/// Omitted or null `async` selects background compaction. No client default is
/// inserted. A supplied settings object replaces the current compaction object;
/// omitting the enclosing update field keeps the current settings.
final class AgentCompactionConfig extends AgentJsonModel {
  /// Creates settings; [clearAsync] sends explicit null rather than omission.
  const AgentCompactionConfig({bool? async, bool clearAsync = false})
    : async = clearAsync ? null : async,
      clearAsync = clearAsync;

  /// Whether compaction runs in the background; false selects blocking mode.
  final bool? async;

  /// Sends `async:null`; background compaction may increase token usage.
  final bool clearAsync;

  /// Parses the closed writable settings without coercing booleans.
  factory AgentCompactionConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const ['async'], 'AgentCompactionConfig');
    return AgentCompactionConfig(
      async: optionalAgentValue(
        json,
        'async',
        'AgentCompactionConfig.async',
        requireAgentBool,
        nullable: true,
      ),
      clearAsync: json.containsKey('async') && json['async'] == null,
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    if (clearAsync) 'async': null else if (async != null) 'async': async,
  };

  /// Copies settings; explicit null sends null and a false clear flag omits it.
  AgentCompactionConfig copyWith({
    Object? async = unsetCopyWithValue,
    bool? clearAsync,
  }) => AgentCompactionConfig(
    async: copyAgentValue<bool>(
      async,
      this.async,
      'AgentCompactionConfig.async',
    ),
    clearAsync:
        clearAsync ??
        (identical(async, unsetCopyWithValue)
            ? this.clearAsync
            : async == null),
  );
}

/// Effective context compaction settings returned by the service.
final class AgentCompaction extends AgentJsonModel {
  /// Owns finite future metadata while requiring the resolved boolean.
  AgentCompaction({
    required this.async,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const ['async'], 'AgentCompaction');

  /// Whether context compaction runs in the background.
  final bool async;

  /// Detached immutable received extras, subordinate to declared fields.
  final Map<String, dynamic> rawJson;

  /// Parses the required resolved boolean and preserves finite future metadata.
  factory AgentCompaction.fromJson(Map<String, dynamic> json) =>
      AgentCompaction(
        async: requiredAgentValue(
          json,
          'async',
          'AgentCompaction.async',
          requireAgentBool,
          nullable: false,
        )!,
        rawJson: {
          for (final entry in json.entries)
            if (entry.key != 'async') entry.key: entry.value,
        },
      );
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'async': async};

  /// Copies the effective value and optional received extras.
  AgentCompaction copyWith({bool? async, Map<String, dynamic>? rawJson}) =>
      AgentCompaction(
        async: async ?? this.async,
        rawJson: rawJson ?? this.rawJson,
      );
}

/// Experimental features selected when creating a saved Agent.
///
/// The service defaults time awareness to false. Omission leaves that default
/// server-owned; explicit JSON null is not a valid setting.
final class AgentExperimentalConfig extends AgentJsonModel {
  /// Creates optional settings without inserting defaults.
  const AgentExperimentalConfig({this.timeAwareness});

  /// Whether the model receives periodic current-time reminders.
  final bool? timeAwareness;

  /// Parses the closed writable creation settings.
  factory AgentExperimentalConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'time_awareness',
    ], 'AgentExperimentalConfig');
    return AgentExperimentalConfig(
      timeAwareness: optionalAgentValue(
        json,
        'time_awareness',
        'AgentExperimentalConfig.timeAwareness',
        requireAgentBool,
        nullable: false,
      ),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    if (timeAwareness != null) 'time_awareness': timeAwareness,
  };

  /// Copies the setting; [clearTimeAwareness] omits it instead of sending null.
  AgentExperimentalConfig copyWith({
    Object? timeAwareness = unsetCopyWithValue,
    bool clearTimeAwareness = false,
  }) => AgentExperimentalConfig(
    timeAwareness: _copyTimeAwareness(
      timeAwareness,
      this.timeAwareness,
      clearTimeAwareness,
      'AgentExperimentalConfig.timeAwareness',
    ),
  );
}

/// Experimental settings merged by key into an Agent or session configuration.
///
/// An omitted setting keeps its current value. Empty settings do not reset the
/// configuration, and null is not a supported time-awareness value.
final class AgentExperimentalOverridesConfig extends AgentJsonModel {
  /// Creates only the settings that should change.
  const AgentExperimentalOverridesConfig({this.timeAwareness});

  /// Whether the model receives periodic current-time reminders.
  final bool? timeAwareness;

  /// Parses the closed writable override object.
  factory AgentExperimentalOverridesConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'time_awareness',
    ], 'AgentExperimentalOverridesConfig');
    return AgentExperimentalOverridesConfig(
      timeAwareness: optionalAgentValue(
        json,
        'time_awareness',
        'AgentExperimentalOverridesConfig.timeAwareness',
        requireAgentBool,
        nullable: false,
      ),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    if (timeAwareness != null) 'time_awareness': timeAwareness,
  };

  /// Copies settings; clearing omits the key and does not reset server state.
  AgentExperimentalOverridesConfig copyWith({
    Object? timeAwareness = unsetCopyWithValue,
    bool clearTimeAwareness = false,
  }) => AgentExperimentalOverridesConfig(
    timeAwareness: _copyTimeAwareness(
      timeAwareness,
      this.timeAwareness,
      clearTimeAwareness,
      'AgentExperimentalOverridesConfig.timeAwareness',
    ),
  );
}

/// Effective experimental settings returned by the service.
final class AgentExperimental extends AgentJsonModel {
  /// Owns finite future metadata and requires the resolved setting.
  AgentExperimental({
    required this.timeAwareness,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'time_awareness',
       ], 'AgentExperimental');

  /// Whether the model receives periodic current-time reminders.
  final bool timeAwareness;

  /// Detached immutable received extras, subordinate to declared fields.
  final Map<String, dynamic> rawJson;

  /// Parses a resolved resource, preserving finite future metadata.
  factory AgentExperimental.fromJson(Map<String, dynamic> json) =>
      AgentExperimental(
        timeAwareness: requiredAgentValue(
          json,
          'time_awareness',
          'AgentExperimental.timeAwareness',
          requireAgentBool,
          nullable: false,
        )!,
        rawJson: {
          for (final entry in json.entries)
            if (entry.key != 'time_awareness') entry.key: entry.value,
        },
      );
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'time_awareness': timeAwareness,
  };

  /// Copies the resolved value and optional future metadata.
  AgentExperimental copyWith({
    bool? timeAwareness,
    Map<String, dynamic>? rawJson,
  }) => AgentExperimental(
    timeAwareness: timeAwareness ?? this.timeAwareness,
    rawJson: rawJson ?? this.rawJson,
  );
}

bool? _copyTimeAwareness(
  Object? value,
  bool? current,
  bool clear,
  String context,
) {
  if (clear) return null;
  if (identical(value, unsetCopyWithValue)) return current;
  return requireAgentBool(value, context);
}
