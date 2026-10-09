import 'agent_json_helpers.dart';

/// The order in which paginated resources are returned.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentListOrder extends AgentJsonModel {
  const AgentListOrder._(this.value);

  /// The `asc` wire value.
  static const AgentListOrder asc = AgentListOrder._('asc');

  /// The `desc` wire value.
  static const AgentListOrder desc = AgentListOrder._('desc');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentListOrder.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentListOrder');
    return switch (value) {
      'asc' => asc,
      'desc' => desc,
      _ => AgentListOrder._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['asc', 'desc'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentListOrder copyWith({String? value}) =>
      AgentListOrder.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// Where outbound MCP HTTP connections originate.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentMcpConnectionOriginParam extends AgentJsonModel {
  const AgentMcpConnectionOriginParam._(this.value);

  /// The `service` wire value.
  static const AgentMcpConnectionOriginParam service =
      AgentMcpConnectionOriginParam._('service');

  /// The `environment` wire value.
  static const AgentMcpConnectionOriginParam environment =
      AgentMcpConnectionOriginParam._('environment');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentMcpConnectionOriginParam.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentMcpConnectionOriginParam');
    return switch (value) {
      'service' => service,
      'environment' => environment,
      _ => AgentMcpConnectionOriginParam._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['service', 'environment'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentMcpConnectionOriginParam copyWith({String? value}) =>
      AgentMcpConnectionOriginParam.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// Where outbound MCP HTTP connections originate.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentMcpConnectionOriginResource extends AgentJsonModel {
  const AgentMcpConnectionOriginResource._(this.value);

  /// The `service` wire value.
  static const AgentMcpConnectionOriginResource service =
      AgentMcpConnectionOriginResource._('service');

  /// The `environment` wire value.
  static const AgentMcpConnectionOriginResource environment =
      AgentMcpConnectionOriginResource._('environment');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentMcpConnectionOriginResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentMcpConnectionOriginResource');
    return switch (value) {
      'service' => service,
      'environment' => environment,
      _ => AgentMcpConnectionOriginResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['service', 'environment'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentMcpConnectionOriginResource copyWith({String? value}) =>
      AgentMcpConnectionOriginResource.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The amount of reasoning effort the model should use.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentReasoningEffortParam extends AgentJsonModel {
  const AgentReasoningEffortParam._(this.value);

  /// The `none` wire value.
  static const AgentReasoningEffortParam none = AgentReasoningEffortParam._(
    'none',
  );

  /// The `minimal` wire value.
  static const AgentReasoningEffortParam minimal = AgentReasoningEffortParam._(
    'minimal',
  );

  /// The `low` wire value.
  static const AgentReasoningEffortParam low = AgentReasoningEffortParam._(
    'low',
  );

  /// The `medium` wire value.
  static const AgentReasoningEffortParam medium = AgentReasoningEffortParam._(
    'medium',
  );

  /// The `high` wire value.
  static const AgentReasoningEffortParam high = AgentReasoningEffortParam._(
    'high',
  );

  /// The `xhigh` wire value.
  static const AgentReasoningEffortParam xhigh = AgentReasoningEffortParam._(
    'xhigh',
  );

  /// The `max` wire value.
  static const AgentReasoningEffortParam max = AgentReasoningEffortParam._(
    'max',
  );

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentReasoningEffortParam.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentReasoningEffortParam');
    return switch (value) {
      'none' => none,
      'minimal' => minimal,
      'low' => low,
      'medium' => medium,
      'high' => high,
      'xhigh' => xhigh,
      'max' => max,
      _ => AgentReasoningEffortParam._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'none',
    'minimal',
    'low',
    'medium',
    'high',
    'xhigh',
    'max',
  ].contains(value);

  /// Copies the exact string, including a future received value.
  AgentReasoningEffortParam copyWith({String? value}) =>
      AgentReasoningEffortParam.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The amount of reasoning effort used by an agent.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentReasoningEffortResource extends AgentJsonModel {
  const AgentReasoningEffortResource._(this.value);

  /// The `none` wire value.
  static const AgentReasoningEffortResource none =
      AgentReasoningEffortResource._('none');

  /// The `minimal` wire value.
  static const AgentReasoningEffortResource minimal =
      AgentReasoningEffortResource._('minimal');

  /// The `low` wire value.
  static const AgentReasoningEffortResource low =
      AgentReasoningEffortResource._('low');

  /// The `medium` wire value.
  static const AgentReasoningEffortResource medium =
      AgentReasoningEffortResource._('medium');

  /// The `high` wire value.
  static const AgentReasoningEffortResource high =
      AgentReasoningEffortResource._('high');

  /// The `xhigh` wire value.
  static const AgentReasoningEffortResource xhigh =
      AgentReasoningEffortResource._('xhigh');

  /// The `max` wire value.
  static const AgentReasoningEffortResource max =
      AgentReasoningEffortResource._('max');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentReasoningEffortResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentReasoningEffortResource');
    return switch (value) {
      'none' => none,
      'minimal' => minimal,
      'low' => low,
      'medium' => medium,
      'high' => high,
      'xhigh' => xhigh,
      'max' => max,
      _ => AgentReasoningEffortResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'none',
    'minimal',
    'low',
    'medium',
    'high',
    'xhigh',
    'max',
  ].contains(value);

  /// Copies the exact string, including a future received value.
  AgentReasoningEffortResource copyWith({String? value}) =>
      AgentReasoningEffortResource.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The reasoning summary format requested from the model.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentReasoningSummaryParam extends AgentJsonModel {
  const AgentReasoningSummaryParam._(this.value);

  /// The `concise` wire value.
  static const AgentReasoningSummaryParam concise =
      AgentReasoningSummaryParam._('concise');

  /// The `detailed` wire value.
  static const AgentReasoningSummaryParam detailed =
      AgentReasoningSummaryParam._('detailed');

  /// The `auto` wire value.
  static const AgentReasoningSummaryParam auto = AgentReasoningSummaryParam._(
    'auto',
  );

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentReasoningSummaryParam.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentReasoningSummaryParam');
    return switch (value) {
      'concise' => concise,
      'detailed' => detailed,
      'auto' => auto,
      _ => AgentReasoningSummaryParam._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['concise', 'detailed', 'auto'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentReasoningSummaryParam copyWith({String? value}) =>
      AgentReasoningSummaryParam.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The reasoning summary format requested from an agent.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentReasoningSummaryResource extends AgentJsonModel {
  const AgentReasoningSummaryResource._(this.value);

  /// The `concise` wire value.
  static const AgentReasoningSummaryResource concise =
      AgentReasoningSummaryResource._('concise');

  /// The `detailed` wire value.
  static const AgentReasoningSummaryResource detailed =
      AgentReasoningSummaryResource._('detailed');

  /// The `auto` wire value.
  static const AgentReasoningSummaryResource auto =
      AgentReasoningSummaryResource._('auto');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentReasoningSummaryResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentReasoningSummaryResource');
    return switch (value) {
      'concise' => concise,
      'detailed' => detailed,
      'auto' => auto,
      _ => AgentReasoningSummaryResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['concise', 'detailed', 'auto'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentReasoningSummaryResource copyWith({String? value}) =>
      AgentReasoningSummaryResource.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The service tier used for model requests.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentServiceTierParam extends AgentJsonModel {
  const AgentServiceTierParam._(this.value);

  /// The `auto` wire value.
  static const AgentServiceTierParam auto = AgentServiceTierParam._('auto');

  /// The `default` wire value.
  static const AgentServiceTierParam defaultValue = AgentServiceTierParam._(
    'default',
  );

  /// The `flex` wire value.
  static const AgentServiceTierParam flex = AgentServiceTierParam._('flex');

  /// The `priority` wire value.
  static const AgentServiceTierParam priority = AgentServiceTierParam._(
    'priority',
  );

  /// The `fast` wire value.
  static const AgentServiceTierParam fast = AgentServiceTierParam._('fast');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentServiceTierParam.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentServiceTierParam');
    return switch (value) {
      'auto' => auto,
      'default' => defaultValue,
      'flex' => flex,
      'priority' => priority,
      'fast' => fast,
      _ => AgentServiceTierParam._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown =>
      const ['auto', 'default', 'flex', 'priority', 'fast'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentServiceTierParam copyWith({String? value}) =>
      AgentServiceTierParam.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The service-tier policy configured for an agent.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentServiceTierResource extends AgentJsonModel {
  const AgentServiceTierResource._(this.value);

  /// The `auto` wire value.
  static const AgentServiceTierResource auto = AgentServiceTierResource._(
    'auto',
  );

  /// The `default` wire value.
  static const AgentServiceTierResource defaultValue =
      AgentServiceTierResource._('default');

  /// The `flex` wire value.
  static const AgentServiceTierResource flex = AgentServiceTierResource._(
    'flex',
  );

  /// The `priority` wire value.
  static const AgentServiceTierResource priority = AgentServiceTierResource._(
    'priority',
  );

  /// The `fast` wire value.
  static const AgentServiceTierResource fast = AgentServiceTierResource._(
    'fast',
  );

  /// The `ultrafast` wire value.
  static const AgentServiceTierResource ultrafast = AgentServiceTierResource._(
    'ultrafast',
  );

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentServiceTierResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentServiceTierResource');
    return switch (value) {
      'auto' => auto,
      'default' => defaultValue,
      'flex' => flex,
      'priority' => priority,
      'fast' => fast,
      'ultrafast' => ultrafast,
      _ => AgentServiceTierResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'auto',
    'default',
    'flex',
    'priority',
    'fast',
    'ultrafast',
  ].contains(value);

  /// Copies the exact string, including a future received value.
  AgentServiceTierResource copyWith({String? value}) =>
      AgentServiceTierResource.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The amount of text the model should produce.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentVerbosityParam extends AgentJsonModel {
  const AgentVerbosityParam._(this.value);

  /// The `low` wire value.
  static const AgentVerbosityParam low = AgentVerbosityParam._('low');

  /// The `medium` wire value.
  static const AgentVerbosityParam medium = AgentVerbosityParam._('medium');

  /// The `high` wire value.
  static const AgentVerbosityParam high = AgentVerbosityParam._('high');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentVerbosityParam.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentVerbosityParam');
    return switch (value) {
      'low' => low,
      'medium' => medium,
      'high' => high,
      _ => AgentVerbosityParam._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['low', 'medium', 'high'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentVerbosityParam copyWith({String? value}) =>
      AgentVerbosityParam.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The amount of text produced by an agent.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentVerbosityResource extends AgentJsonModel {
  const AgentVerbosityResource._(this.value);

  /// The `low` wire value.
  static const AgentVerbosityResource low = AgentVerbosityResource._('low');

  /// The `medium` wire value.
  static const AgentVerbosityResource medium = AgentVerbosityResource._(
    'medium',
  );

  /// The `high` wire value.
  static const AgentVerbosityResource high = AgentVerbosityResource._('high');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentVerbosityResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentVerbosityResource');
    return switch (value) {
      'low' => low,
      'medium' => medium,
      'high' => high,
      _ => AgentVerbosityResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['low', 'medium', 'high'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentVerbosityResource copyWith({String? value}) =>
      AgentVerbosityResource.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The amount of web search context made available to the model.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentWebSearchContextSizeParam extends AgentJsonModel {
  const AgentWebSearchContextSizeParam._(this.value);

  /// The `low` wire value.
  static const AgentWebSearchContextSizeParam low =
      AgentWebSearchContextSizeParam._('low');

  /// The `medium` wire value.
  static const AgentWebSearchContextSizeParam medium =
      AgentWebSearchContextSizeParam._('medium');

  /// The `high` wire value.
  static const AgentWebSearchContextSizeParam high =
      AgentWebSearchContextSizeParam._('high');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentWebSearchContextSizeParam.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentWebSearchContextSizeParam');
    return switch (value) {
      'low' => low,
      'medium' => medium,
      'high' => high,
      _ => AgentWebSearchContextSizeParam._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['low', 'medium', 'high'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentWebSearchContextSizeParam copyWith({String? value}) =>
      AgentWebSearchContextSizeParam.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The amount of web search context made available to the model.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentWebSearchContextSizeResource extends AgentJsonModel {
  const AgentWebSearchContextSizeResource._(this.value);

  /// The `low` wire value.
  static const AgentWebSearchContextSizeResource low =
      AgentWebSearchContextSizeResource._('low');

  /// The `medium` wire value.
  static const AgentWebSearchContextSizeResource medium =
      AgentWebSearchContextSizeResource._('medium');

  /// The `high` wire value.
  static const AgentWebSearchContextSizeResource high =
      AgentWebSearchContextSizeResource._('high');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentWebSearchContextSizeResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentWebSearchContextSizeResource');
    return switch (value) {
      'low' => low,
      'medium' => medium,
      'high' => high,
      _ => AgentWebSearchContextSizeResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['low', 'medium', 'high'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentWebSearchContextSizeResource copyWith({String? value}) =>
      AgentWebSearchContextSizeResource.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The source used for web search results.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentWebSearchModeParam extends AgentJsonModel {
  const AgentWebSearchModeParam._(this.value);

  /// The `disabled` wire value.
  static const AgentWebSearchModeParam disabled = AgentWebSearchModeParam._(
    'disabled',
  );

  /// The `cached` wire value.
  static const AgentWebSearchModeParam cached = AgentWebSearchModeParam._(
    'cached',
  );

  /// The `live` wire value.
  static const AgentWebSearchModeParam live = AgentWebSearchModeParam._('live');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentWebSearchModeParam.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentWebSearchModeParam');
    return switch (value) {
      'disabled' => disabled,
      'cached' => cached,
      'live' => live,
      _ => AgentWebSearchModeParam._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['disabled', 'cached', 'live'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentWebSearchModeParam copyWith({String? value}) =>
      AgentWebSearchModeParam.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}

/// The source used for web search results.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentWebSearchModeResource extends AgentJsonModel {
  const AgentWebSearchModeResource._(this.value);

  /// The `disabled` wire value.
  static const AgentWebSearchModeResource disabled =
      AgentWebSearchModeResource._('disabled');

  /// The `cached` wire value.
  static const AgentWebSearchModeResource cached = AgentWebSearchModeResource._(
    'cached',
  );

  /// The `live` wire value.
  static const AgentWebSearchModeResource live = AgentWebSearchModeResource._(
    'live',
  );

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentWebSearchModeResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentWebSearchModeResource');
    return switch (value) {
      'disabled' => disabled,
      'cached' => cached,
      'live' => live,
      _ => AgentWebSearchModeResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['disabled', 'cached', 'live'].contains(value);

  /// Copies the exact string, including a future received value.
  AgentWebSearchModeResource copyWith({String? value}) =>
      AgentWebSearchModeResource.fromJson(value ?? this.value);

  @override
  String toJson() => value;
}
