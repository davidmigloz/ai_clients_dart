import '../copy_with_sentinel.dart';
import 'thinking_summaries.dart';

/// Base class for agent configurations.
///
/// Subtypes:
/// - [DynamicAgentConfig] (type `dynamic`)
/// - [DeepResearchAgentConfig] (type `deep-research`)
/// - [AntigravityAgentConfig] (type `antigravity`)
/// - [CodeMenderAgentConfig] (type `code-mender`)
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
      'antigravity' => AntigravityAgentConfig.fromJson(json),
      'code-mender' => CodeMenderAgentConfig.fromJson(json),
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
  Map<String, dynamic> toJson() => {'type': type, ...?additionalProperties};

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

  /// Enables the BigQuery tool for the Deep Research agent.
  final bool? enableBigqueryTool;

  /// Whether to include visualizations in the response.
  final DeepResearchVisualization? visualization;

  /// Creates a [DeepResearchAgentConfig] instance.
  const DeepResearchAgentConfig({
    this.thinkingSummaries,
    this.collaborativePlanning,
    this.enableBigqueryTool,
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
        enableBigqueryTool: json['enable_bigquery_tool'] as bool?,
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
    if (enableBigqueryTool != null) 'enable_bigquery_tool': enableBigqueryTool,
    if (visualization != null)
      'visualization': deepResearchVisualizationToString(visualization!),
  };

  /// Creates a copy with replaced values.
  DeepResearchAgentConfig copyWith({
    Object? thinkingSummaries = unsetCopyWithValue,
    Object? collaborativePlanning = unsetCopyWithValue,
    Object? enableBigqueryTool = unsetCopyWithValue,
    Object? visualization = unsetCopyWithValue,
  }) {
    return DeepResearchAgentConfig(
      thinkingSummaries: thinkingSummaries == unsetCopyWithValue
          ? this.thinkingSummaries
          : thinkingSummaries as InteractionThinkingSummaries?,
      collaborativePlanning: collaborativePlanning == unsetCopyWithValue
          ? this.collaborativePlanning
          : collaborativePlanning as bool?,
      enableBigqueryTool: enableBigqueryTool == unsetCopyWithValue
          ? this.enableBigqueryTool
          : enableBigqueryTool as bool?,
      visualization: visualization == unsetCopyWithValue
          ? this.visualization
          : visualization as DeepResearchVisualization?,
    );
  }
}

/// Configuration for the Antigravity agent runtime.
///
/// Provides server-side control over the agent's execution environment and
/// tool configuration.
class AntigravityAgentConfig extends AgentConfig {
  @override
  String get type => 'antigravity';

  /// Max total tokens for the agent run.
  ///
  /// An int64 value represented as a string, matching the wire format.
  final String? maxTotalTokens;

  /// The model to use for agent reasoning.
  final String? model;

  /// Creates an [AntigravityAgentConfig] instance.
  const AntigravityAgentConfig({this.maxTotalTokens, this.model});

  /// Creates an [AntigravityAgentConfig] from JSON.
  factory AntigravityAgentConfig.fromJson(Map<String, dynamic> json) =>
      AntigravityAgentConfig(
        maxTotalTokens: json['max_total_tokens'] as String?,
        model: json['model'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (maxTotalTokens != null) 'max_total_tokens': maxTotalTokens,
    if (model != null) 'model': model,
  };

  /// Creates a copy with replaced values.
  AntigravityAgentConfig copyWith({
    Object? maxTotalTokens = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
  }) {
    return AntigravityAgentConfig(
      maxTotalTokens: maxTotalTokens == unsetCopyWithValue
          ? this.maxTotalTokens
          : maxTotalTokens as String?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
    );
  }
}

/// The mode of a [FindRequest] session.
enum FindRequestMode {
  /// Fast scan using only the initial classifier.
  scan,

  /// Performs classification followed by detailed investigation.
  verify,
}

/// Converts a string to [FindRequestMode].
///
/// Returns `null` for `null` input or unrecognized values (forward-compatible:
/// a new server-side enum value will surface as `null` rather than silently
/// collapsing into an existing member).
FindRequestMode? findRequestModeFromString(String? value) {
  return switch (value) {
    'scan' => FindRequestMode.scan,
    'verify' => FindRequestMode.verify,
    _ => null,
  };
}

/// Converts [FindRequestMode] to a string.
String findRequestModeToString(FindRequestMode value) {
  return switch (value) {
    FindRequestMode.scan => 'scan',
    FindRequestMode.verify => 'verify',
  };
}

/// Content of a single file in the codebase.
class FileContent {
  /// The UTF-8 encoded text content of the file.
  final String? content;

  /// The relative path of the file from the project root.
  final String? path;

  /// Creates a [FileContent] instance.
  const FileContent({this.content, this.path});

  /// Creates a [FileContent] from JSON.
  factory FileContent.fromJson(Map<String, dynamic> json) => FileContent(
    content: json['content'] as String?,
    path: json['path'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (content != null) 'content': content,
    if (path != null) 'path': path,
  };

  /// Creates a copy with replaced values.
  FileContent copyWith({
    Object? content = unsetCopyWithValue,
    Object? path = unsetCopyWithValue,
  }) {
    return FileContent(
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      path: path == unsetCopyWithValue ? this.path : path as String?,
    );
  }
}

/// The configuration of CodeMender sessions.
class SessionConfig {
  /// The maximum number of interaction rounds the agent is allowed to
  /// perform before reaching a timeout.
  final int? maxRounds;

  /// Creates a [SessionConfig] instance.
  const SessionConfig({this.maxRounds});

  /// Creates a [SessionConfig] from JSON.
  factory SessionConfig.fromJson(Map<String, dynamic> json) =>
      SessionConfig(maxRounds: json['max_rounds'] as int?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (maxRounds != null) 'max_rounds': maxRounds,
  };

  /// Creates a copy with replaced values.
  SessionConfig copyWith({Object? maxRounds = unsetCopyWithValue}) {
    return SessionConfig(
      maxRounds: maxRounds == unsetCopyWithValue
          ? this.maxRounds
          : maxRounds as int?,
    );
  }
}

/// Request parameters specific to FIND sessions, used for discovering
/// vulnerabilities in a codebase.
class FindRequest {
  /// Additional context or custom instructions provided by the user to
  /// guide the vulnerability analysis.
  final String? description;

  /// The identifier of a specific finding to verify.
  ///
  /// This is primarily used in VERIFY mode to focus the agent's
  /// execution-based validation on a single vulnerability.
  final String? findingId;

  /// The mode of the find session.
  final FindRequestMode? mode;

  /// A list of source files to provide as context for the scan.
  final List<FileContent>? sourceFiles;

  /// Creates a [FindRequest] instance.
  const FindRequest({
    this.description,
    this.findingId,
    this.mode,
    this.sourceFiles,
  });

  /// Creates a [FindRequest] from JSON.
  factory FindRequest.fromJson(Map<String, dynamic> json) => FindRequest(
    description: json['description'] as String?,
    findingId: json['finding_id'] as String?,
    mode: json['mode'] != null
        ? findRequestModeFromString(json['mode'] as String?)
        : null,
    sourceFiles: (json['source_files'] as List<dynamic>?)
        ?.map((e) => FileContent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (description != null) 'description': description,
    if (findingId != null) 'finding_id': findingId,
    if (mode != null) 'mode': findRequestModeToString(mode!),
    if (sourceFiles != null)
      'source_files': sourceFiles!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  FindRequest copyWith({
    Object? description = unsetCopyWithValue,
    Object? findingId = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
    Object? sourceFiles = unsetCopyWithValue,
  }) {
    return FindRequest(
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      findingId: findingId == unsetCopyWithValue
          ? this.findingId
          : findingId as String?,
      mode: mode == unsetCopyWithValue ? this.mode : mode as FindRequestMode?,
      sourceFiles: sourceFiles == unsetCopyWithValue
          ? this.sourceFiles
          : sourceFiles as List<FileContent>?,
    );
  }
}

/// Request parameters specific to FIX sessions, used for generating and
/// validating security patches.
class FixRequest {
  /// Additional context or custom instructions provided by the user to
  /// guide the patch generation process.
  final String? description;

  /// The identifier of the specific security finding to be remediated.
  ///
  /// This ID maps to a previously discovered vulnerability.
  final String? findingId;

  /// A list of source files providing context for the remediation.
  ///
  /// These files are typically the ones containing the identified
  /// vulnerability.
  final List<FileContent>? sourceFiles;

  /// Creates a [FixRequest] instance.
  const FixRequest({this.description, this.findingId, this.sourceFiles});

  /// Creates a [FixRequest] from JSON.
  factory FixRequest.fromJson(Map<String, dynamic> json) => FixRequest(
    description: json['description'] as String?,
    findingId: json['finding_id'] as String?,
    sourceFiles: (json['source_files'] as List<dynamic>?)
        ?.map((e) => FileContent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (description != null) 'description': description,
    if (findingId != null) 'finding_id': findingId,
    if (sourceFiles != null)
      'source_files': sourceFiles!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  FixRequest copyWith({
    Object? description = unsetCopyWithValue,
    Object? findingId = unsetCopyWithValue,
    Object? sourceFiles = unsetCopyWithValue,
  }) {
    return FixRequest(
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      findingId: findingId == unsetCopyWithValue
          ? this.findingId
          : findingId as String?,
      sourceFiles: sourceFiles == unsetCopyWithValue
          ? this.sourceFiles
          : sourceFiles as List<FileContent>?,
    );
  }
}

/// Configuration for the CodeMender agent.
class CodeMenderAgentConfig extends AgentConfig {
  @override
  String get type => 'code-mender';

  /// Parameters for finding vulnerabilities.
  final FindRequest? findRequest;

  /// Parameters for fixing vulnerabilities.
  final FixRequest? fixRequest;

  /// The name of the model to use for the CodeMender agent.
  ///
  /// One CodeMender session will only use one model.
  final String? model;

  /// Optional session-specific configurations to override default agent
  /// behavior.
  final SessionConfig? sessionConfig;

  /// Parameter for grouping multiple interactions that belong to the same
  /// CodeMender session.
  final String? sessionId;

  /// Creates a [CodeMenderAgentConfig] instance.
  const CodeMenderAgentConfig({
    this.findRequest,
    this.fixRequest,
    this.model,
    this.sessionConfig,
    this.sessionId,
  });

  /// Creates a [CodeMenderAgentConfig] from JSON.
  factory CodeMenderAgentConfig.fromJson(Map<String, dynamic> json) =>
      CodeMenderAgentConfig(
        findRequest: json['find_request'] != null
            ? FindRequest.fromJson(json['find_request'] as Map<String, dynamic>)
            : null,
        fixRequest: json['fix_request'] != null
            ? FixRequest.fromJson(json['fix_request'] as Map<String, dynamic>)
            : null,
        model: json['model'] as String?,
        sessionConfig: json['session_config'] != null
            ? SessionConfig.fromJson(
                json['session_config'] as Map<String, dynamic>,
              )
            : null,
        sessionId: json['session_id'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (findRequest != null) 'find_request': findRequest!.toJson(),
    if (fixRequest != null) 'fix_request': fixRequest!.toJson(),
    if (model != null) 'model': model,
    if (sessionConfig != null) 'session_config': sessionConfig!.toJson(),
    if (sessionId != null) 'session_id': sessionId,
  };

  /// Creates a copy with replaced values.
  CodeMenderAgentConfig copyWith({
    Object? findRequest = unsetCopyWithValue,
    Object? fixRequest = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? sessionConfig = unsetCopyWithValue,
    Object? sessionId = unsetCopyWithValue,
  }) {
    return CodeMenderAgentConfig(
      findRequest: findRequest == unsetCopyWithValue
          ? this.findRequest
          : findRequest as FindRequest?,
      fixRequest: fixRequest == unsetCopyWithValue
          ? this.fixRequest
          : fixRequest as FixRequest?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      sessionConfig: sessionConfig == unsetCopyWithValue
          ? this.sessionConfig
          : sessionConfig as SessionConfig?,
      sessionId: sessionId == unsetCopyWithValue
          ? this.sessionId
          : sessionId as String?,
    );
  }
}
