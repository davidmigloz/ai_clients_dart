import '../copy_with_sentinel.dart';
import 'thinking_summaries.dart';

/// Base class for agent configurations.
///
/// Subtypes:
/// - [DynamicAgentConfig] (type `dynamic`)
/// - [DeepResearchAgentConfig] (type `deep-research`)
sealed class AgentConfig {
  /// The type of agent configuration.
  String get type;

  const AgentConfig();

  /// Creates an [AgentConfig] from JSON.
  factory AgentConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'dynamic' => DynamicAgentConfig.fromJson(json),
      'deep-research' => DeepResearchAgentConfig.fromJson(json),
      _ => DynamicAgentConfig.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Configuration for dynamic agents.
class DynamicAgentConfig extends AgentConfig {
  @override
  String get type => 'dynamic';

  /// Additional properties for the dynamic agent.
  final Map<String, dynamic>? additionalProperties;

  /// Creates a [DynamicAgentConfig] instance.
  const DynamicAgentConfig({this.additionalProperties});

  /// Creates a [DynamicAgentConfig] from JSON.
  factory DynamicAgentConfig.fromJson(Map<String, dynamic> json) {
    final props = Map<String, dynamic>.from(json)..remove('type');
    return DynamicAgentConfig(
      additionalProperties: props.isNotEmpty ? props : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (additionalProperties != null) ...additionalProperties!,
  };

  /// Creates a copy with replaced values.
  DynamicAgentConfig copyWith({
    Object? additionalProperties = unsetCopyWithValue,
  }) {
    return DynamicAgentConfig(
      additionalProperties: additionalProperties == unsetCopyWithValue
          ? this.additionalProperties
          : additionalProperties as Map<String, dynamic>?,
    );
  }
}

/// Whether to include visualizations in the Deep Research response.
enum DeepResearchVisualization {
  /// Do not include visualizations.
  off,

  /// Automatically include visualizations.
  auto,
}

/// Converts string to [DeepResearchVisualization] enum.
///
/// Returns `null` for `null` input or unrecognized values (forward-compatible:
/// a new server-side enum value will surface as `null` rather than silently
/// collapsing into an existing member).
DeepResearchVisualization? deepResearchVisualizationFromString(String? value) {
  return switch (value) {
    'off' => DeepResearchVisualization.off,
    'auto' => DeepResearchVisualization.auto,
    _ => null,
  };
}

/// Converts [DeepResearchVisualization] enum to string.
String deepResearchVisualizationToString(DeepResearchVisualization value) {
  return switch (value) {
    DeepResearchVisualization.off => 'off',
    DeepResearchVisualization.auto => 'auto',
  };
}

/// Configuration for the Deep Research agent.
class DeepResearchAgentConfig extends AgentConfig {
  @override
  String get type => 'deep-research';

  /// Whether to include thought summaries in the response.
  final InteractionThinkingSummaries? thinkingSummaries;

  /// Enables human-in-the-loop planning for the Deep Research agent.
  ///
  /// If set to true, the Deep Research agent will provide a research plan in
  /// its response. The agent will then proceed only if the user confirms the
  /// plan in the next turn.
  final bool? collaborativePlanning;

  /// Whether to include visualizations in the response.
  final DeepResearchVisualization? visualization;

  /// Creates a [DeepResearchAgentConfig] instance.
  const DeepResearchAgentConfig({
    this.thinkingSummaries,
    this.collaborativePlanning,
    this.visualization,
  });

  /// Creates a [DeepResearchAgentConfig] from JSON.
  factory DeepResearchAgentConfig.fromJson(Map<String, dynamic> json) =>
      DeepResearchAgentConfig(
        thinkingSummaries: json['thinking_summaries'] != null
            ? interactionThinkingSummariesFromString(
                json['thinking_summaries'] as String?,
              )
            : null,
        collaborativePlanning: json['collaborative_planning'] as bool?,
        visualization: json['visualization'] != null
            ? deepResearchVisualizationFromString(
                json['visualization'] as String?,
              )
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (thinkingSummaries != null)
      'thinking_summaries': interactionThinkingSummariesToString(
        thinkingSummaries!,
      ),
    if (collaborativePlanning != null)
      'collaborative_planning': collaborativePlanning,
    if (visualization != null)
      'visualization': deepResearchVisualizationToString(visualization!),
  };

  /// Creates a copy with replaced values.
  DeepResearchAgentConfig copyWith({
    Object? thinkingSummaries = unsetCopyWithValue,
    Object? collaborativePlanning = unsetCopyWithValue,
    Object? visualization = unsetCopyWithValue,
  }) {
    return DeepResearchAgentConfig(
      thinkingSummaries: thinkingSummaries == unsetCopyWithValue
          ? this.thinkingSummaries
          : thinkingSummaries as InteractionThinkingSummaries?,
      collaborativePlanning: collaborativePlanning == unsetCopyWithValue
          ? this.collaborativePlanning
          : collaborativePlanning as bool?,
      visualization: visualization == unsetCopyWithValue
          ? this.visualization
          : visualization as DeepResearchVisualization?,
    );
  }
}
