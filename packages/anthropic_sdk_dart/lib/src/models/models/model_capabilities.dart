import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Indicates whether a capability is supported.
@immutable
class CapabilitySupport {
  /// Whether this capability is supported by the model.
  final bool supported;

  /// Creates a [CapabilitySupport].
  const CapabilitySupport({required this.supported});

  /// Creates a [CapabilitySupport] from JSON.
  factory CapabilitySupport.fromJson(Map<String, dynamic> json) {
    return CapabilitySupport(supported: json['supported'] as bool);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'supported': supported};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CapabilitySupport &&
          runtimeType == other.runtimeType &&
          supported == other.supported;

  @override
  int get hashCode => supported.hashCode;

  @override
  String toString() => 'CapabilitySupport(supported: $supported)';
}

/// Supported thinking type configurations.
@immutable
class ThinkingTypes {
  /// Whether the model supports thinking with type 'adaptive' (auto).
  final CapabilitySupport adaptive;

  /// Whether the model supports thinking with type 'enabled'.
  final CapabilitySupport enabled;

  /// Whether the model accepts thinking with type 'between_tools'.
  ///
  /// May be null on responses that predate this capability.
  final CapabilitySupport? betweenTools;

  /// Whether the model accepts thinking with type 'disabled'.
  ///
  /// May be null on responses that predate this capability.
  final CapabilitySupport? disabled;

  /// Creates a [ThinkingTypes].
  const ThinkingTypes({
    required this.adaptive,
    required this.enabled,
    this.betweenTools,
    this.disabled,
  });

  /// Creates a [ThinkingTypes] from JSON.
  factory ThinkingTypes.fromJson(Map<String, dynamic> json) {
    return ThinkingTypes(
      adaptive: CapabilitySupport.fromJson(
        json['adaptive'] as Map<String, dynamic>,
      ),
      enabled: CapabilitySupport.fromJson(
        json['enabled'] as Map<String, dynamic>,
      ),
      betweenTools: json['between_tools'] != null
          ? CapabilitySupport.fromJson(
              json['between_tools'] as Map<String, dynamic>,
            )
          : null,
      disabled: json['disabled'] != null
          ? CapabilitySupport.fromJson(json['disabled'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'adaptive': adaptive.toJson(),
    'enabled': enabled.toJson(),
    if (betweenTools != null) 'between_tools': betweenTools!.toJson(),
    if (disabled != null) 'disabled': disabled!.toJson(),
  };

  /// Creates a copy with replaced values.
  ThinkingTypes copyWith({
    CapabilitySupport? adaptive,
    CapabilitySupport? enabled,
    Object? betweenTools = unsetCopyWithValue,
    Object? disabled = unsetCopyWithValue,
  }) => ThinkingTypes(
    adaptive: adaptive ?? this.adaptive,
    enabled: enabled ?? this.enabled,
    betweenTools: betweenTools == unsetCopyWithValue
        ? this.betweenTools
        : betweenTools as CapabilitySupport?,
    disabled: disabled == unsetCopyWithValue
        ? this.disabled
        : disabled as CapabilitySupport?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingTypes &&
          runtimeType == other.runtimeType &&
          adaptive == other.adaptive &&
          enabled == other.enabled &&
          betweenTools == other.betweenTools &&
          disabled == other.disabled;

  @override
  int get hashCode => Object.hash(adaptive, enabled, betweenTools, disabled);

  @override
  String toString() =>
      'ThinkingTypes(adaptive: $adaptive, enabled: $enabled, '
      'betweenTools: $betweenTools, disabled: $disabled)';
}

/// Thinking capability details.
@immutable
class ThinkingCapability {
  /// Whether this capability is supported by the model.
  final bool supported;

  /// Supported thinking type configurations.
  final ThinkingTypes types;

  /// Creates a [ThinkingCapability].
  const ThinkingCapability({required this.supported, required this.types});

  /// Creates a [ThinkingCapability] from JSON.
  factory ThinkingCapability.fromJson(Map<String, dynamic> json) {
    return ThinkingCapability(
      supported: json['supported'] as bool,
      types: ThinkingTypes.fromJson(json['types'] as Map<String, dynamic>),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'supported': supported,
    'types': types.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingCapability &&
          runtimeType == other.runtimeType &&
          supported == other.supported &&
          types == other.types;

  @override
  int get hashCode => Object.hash(supported, types);

  @override
  String toString() =>
      'ThinkingCapability(supported: $supported, types: $types)';
}

/// Context management capability details.
@immutable
class ContextManagementCapability {
  /// Whether the clear_thinking_20251015 strategy is supported.
  final CapabilitySupport? clearThinking20251015;

  /// Whether the clear_tool_uses_20250919 strategy is supported.
  final CapabilitySupport? clearToolUses20250919;

  /// Whether the compact_20260112 strategy is supported.
  final CapabilitySupport? compact20260112;

  /// Whether this capability is supported by the model.
  final bool supported;

  /// Creates a [ContextManagementCapability].
  const ContextManagementCapability({
    required this.clearThinking20251015,
    required this.clearToolUses20250919,
    required this.compact20260112,
    required this.supported,
  });

  /// Creates a [ContextManagementCapability] from JSON.
  factory ContextManagementCapability.fromJson(Map<String, dynamic> json) {
    return ContextManagementCapability(
      clearThinking20251015: json['clear_thinking_20251015'] != null
          ? CapabilitySupport.fromJson(
              json['clear_thinking_20251015'] as Map<String, dynamic>,
            )
          : null,
      clearToolUses20250919: json['clear_tool_uses_20250919'] != null
          ? CapabilitySupport.fromJson(
              json['clear_tool_uses_20250919'] as Map<String, dynamic>,
            )
          : null,
      compact20260112: json['compact_20260112'] != null
          ? CapabilitySupport.fromJson(
              json['compact_20260112'] as Map<String, dynamic>,
            )
          : null,
      supported: json['supported'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (clearThinking20251015 != null)
      'clear_thinking_20251015': clearThinking20251015!.toJson(),
    if (clearToolUses20250919 != null)
      'clear_tool_uses_20250919': clearToolUses20250919!.toJson(),
    if (compact20260112 != null) 'compact_20260112': compact20260112!.toJson(),
    'supported': supported,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextManagementCapability &&
          runtimeType == other.runtimeType &&
          clearThinking20251015 == other.clearThinking20251015 &&
          clearToolUses20250919 == other.clearToolUses20250919 &&
          compact20260112 == other.compact20260112 &&
          supported == other.supported;

  @override
  int get hashCode => Object.hash(
    clearThinking20251015,
    clearToolUses20250919,
    compact20260112,
    supported,
  );

  @override
  String toString() =>
      'ContextManagementCapability(clearThinking20251015: $clearThinking20251015, '
      'clearToolUses20250919: $clearToolUses20250919, '
      'compact20260112: $compact20260112, supported: $supported)';
}

/// Effort (reasoning_effort) capability details.
@immutable
class EffortCapability {
  /// Whether the model supports high effort level.
  final CapabilitySupport high;

  /// Whether the model supports low effort level.
  final CapabilitySupport low;

  /// Whether the model supports max effort level.
  final CapabilitySupport max;

  /// Whether the model supports medium effort level.
  final CapabilitySupport medium;

  /// Whether the model supports xhigh effort level.
  ///
  /// `null` when the model does not expose xhigh support. The `xhigh` key is
  /// always present in serialized JSON (matching the upstream Python/TS SDKs).
  final CapabilitySupport? xhigh;

  /// Whether this capability is supported by the model.
  final bool supported;

  /// Creates an [EffortCapability].
  const EffortCapability({
    required this.high,
    required this.low,
    required this.max,
    required this.medium,
    this.xhigh,
    required this.supported,
  });

  /// Creates an [EffortCapability] from JSON.
  factory EffortCapability.fromJson(Map<String, dynamic> json) {
    return EffortCapability(
      high: CapabilitySupport.fromJson(json['high'] as Map<String, dynamic>),
      low: CapabilitySupport.fromJson(json['low'] as Map<String, dynamic>),
      max: CapabilitySupport.fromJson(json['max'] as Map<String, dynamic>),
      medium: CapabilitySupport.fromJson(
        json['medium'] as Map<String, dynamic>,
      ),
      xhigh: json['xhigh'] != null
          ? CapabilitySupport.fromJson(json['xhigh'] as Map<String, dynamic>)
          : null,
      supported: json['supported'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'high': high.toJson(),
    'low': low.toJson(),
    'max': max.toJson(),
    'medium': medium.toJson(),
    'xhigh': xhigh?.toJson(),
    'supported': supported,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EffortCapability &&
          runtimeType == other.runtimeType &&
          high == other.high &&
          low == other.low &&
          max == other.max &&
          medium == other.medium &&
          xhigh == other.xhigh &&
          supported == other.supported;

  @override
  int get hashCode => Object.hash(high, low, max, medium, xhigh, supported);

  @override
  String toString() =>
      'EffortCapability(high: $high, low: $low, max: $max, '
      'medium: $medium, xhigh: $xhigh, supported: $supported)';
}

/// Availability of individual server tools.
@immutable
class ServerToolsCapability {
  /// Whether the model supports at least one of these server tools.
  final bool supported;

  /// Whether the model supports a version of the code execution server tool.
  final CapabilitySupport codeExecution;

  /// Whether the model supports a version of the web search server tool.
  final CapabilitySupport webSearch;

  /// Creates a [ServerToolsCapability].
  const ServerToolsCapability({
    required this.supported,
    required this.codeExecution,
    required this.webSearch,
  });

  /// Creates a [ServerToolsCapability] from JSON.
  factory ServerToolsCapability.fromJson(Map<String, dynamic> json) {
    if (json case {
      'supported': final bool supported,
      'code_execution': final Map<String, dynamic> codeExecution,
      'web_search': final Map<String, dynamic> webSearch,
    }) {
      return ServerToolsCapability(
        supported: supported,
        codeExecution: CapabilitySupport.fromJson(codeExecution),
        webSearch: CapabilitySupport.fromJson(webSearch),
      );
    }
    throw const FormatException(
      'ServerToolsCapability requires supported, code_execution, and web_search',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'supported': supported,
    'code_execution': codeExecution.toJson(),
    'web_search': webSearch.toJson(),
  };

  /// Creates a copy with replaced values.
  ServerToolsCapability copyWith({
    bool? supported,
    CapabilitySupport? codeExecution,
    CapabilitySupport? webSearch,
  }) => ServerToolsCapability(
    supported: supported ?? this.supported,
    codeExecution: codeExecution ?? this.codeExecution,
    webSearch: webSearch ?? this.webSearch,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerToolsCapability &&
          runtimeType == other.runtimeType &&
          supported == other.supported &&
          codeExecution == other.codeExecution &&
          webSearch == other.webSearch;

  @override
  int get hashCode => Object.hash(supported, codeExecution, webSearch);

  @override
  String toString() =>
      'ServerToolsCapability(supported: $supported, '
      'codeExecution: $codeExecution, webSearch: $webSearch)';
}

/// On-demand compaction capability details (beta).
@immutable
class CompactionCapability {
  /// Whether the model accepts the top-level `compaction` parameter.
  final bool supported;

  /// Whether the model supports compaction with type 'summarize'.
  final CapabilitySupport summarize;

  /// Creates a [CompactionCapability].
  const CompactionCapability({
    required this.supported,
    required this.summarize,
  });

  /// Creates a [CompactionCapability] from JSON.
  factory CompactionCapability.fromJson(Map<String, dynamic> json) {
    if (json case {
      'supported': final bool supported,
      'summarize': final Map<String, dynamic> summarize,
    }) {
      return CompactionCapability(
        supported: supported,
        summarize: CapabilitySupport.fromJson(summarize),
      );
    }
    throw const FormatException(
      'CompactionCapability requires supported and summarize',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'supported': supported,
    'summarize': summarize.toJson(),
  };

  /// Creates a copy with replaced values.
  CompactionCapability copyWith({
    bool? supported,
    CapabilitySupport? summarize,
  }) => CompactionCapability(
    supported: supported ?? this.supported,
    summarize: summarize ?? this.summarize,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionCapability &&
          runtimeType == other.runtimeType &&
          supported == other.supported &&
          summarize == other.summarize;

  @override
  int get hashCode => Object.hash(supported, summarize);

  @override
  String toString() =>
      'CompactionCapability(supported: $supported, summarize: $summarize)';
}

/// Model capability information.
@immutable
class ModelCapabilities {
  /// Whether the model supports the Batch API.
  final CapabilitySupport batch;

  /// Whether the model supports citation generation.
  final CapabilitySupport citations;

  /// Whether code running in the code execution tool can call other tools.
  ///
  /// See [serverTools] for support for the code execution tool itself.
  final CapabilitySupport codeExecution;

  /// Context management support and available strategies.
  final ContextManagementCapability contextManagement;

  /// Effort (reasoning_effort) support and available levels.
  final EffortCapability effort;

  /// Whether the model accepts image content blocks.
  final CapabilitySupport imageInput;

  /// Whether the model accepts PDF content blocks.
  final CapabilitySupport pdfInput;

  /// Whether the model supports structured output / JSON mode /
  /// strict tool schemas.
  final CapabilitySupport structuredOutputs;

  /// Thinking capability and supported type configurations.
  final ThinkingCapability thinking;

  /// Model support for web search and code execution server tools.
  ///
  /// May be null on responses that predate this capability.
  final ServerToolsCapability? serverTools;

  /// Model support for on-demand compaction.
  ///
  /// May be null unless requested with the `compact-2026-09-04` beta header.
  final CompactionCapability? compaction;

  /// Creates a [ModelCapabilities].
  const ModelCapabilities({
    required this.batch,
    required this.citations,
    required this.codeExecution,
    required this.contextManagement,
    required this.effort,
    required this.imageInput,
    required this.pdfInput,
    required this.structuredOutputs,
    required this.thinking,
    this.serverTools,
    this.compaction,
  });

  /// Creates a [ModelCapabilities] from JSON.
  factory ModelCapabilities.fromJson(Map<String, dynamic> json) {
    return ModelCapabilities(
      batch: CapabilitySupport.fromJson(json['batch'] as Map<String, dynamic>),
      citations: CapabilitySupport.fromJson(
        json['citations'] as Map<String, dynamic>,
      ),
      codeExecution: CapabilitySupport.fromJson(
        json['code_execution'] as Map<String, dynamic>,
      ),
      contextManagement: ContextManagementCapability.fromJson(
        json['context_management'] as Map<String, dynamic>,
      ),
      effort: EffortCapability.fromJson(json['effort'] as Map<String, dynamic>),
      imageInput: CapabilitySupport.fromJson(
        json['image_input'] as Map<String, dynamic>,
      ),
      pdfInput: CapabilitySupport.fromJson(
        json['pdf_input'] as Map<String, dynamic>,
      ),
      structuredOutputs: CapabilitySupport.fromJson(
        json['structured_outputs'] as Map<String, dynamic>,
      ),
      thinking: ThinkingCapability.fromJson(
        json['thinking'] as Map<String, dynamic>,
      ),
      serverTools: json['server_tools'] != null
          ? ServerToolsCapability.fromJson(
              json['server_tools'] as Map<String, dynamic>,
            )
          : null,
      compaction: json['compaction'] != null
          ? CompactionCapability.fromJson(
              json['compaction'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'batch': batch.toJson(),
    'citations': citations.toJson(),
    'code_execution': codeExecution.toJson(),
    'context_management': contextManagement.toJson(),
    'effort': effort.toJson(),
    'image_input': imageInput.toJson(),
    'pdf_input': pdfInput.toJson(),
    'structured_outputs': structuredOutputs.toJson(),
    'thinking': thinking.toJson(),
    if (serverTools != null) 'server_tools': serverTools!.toJson(),
    if (compaction != null) 'compaction': compaction!.toJson(),
  };

  /// Creates a copy with replaced values.
  ModelCapabilities copyWith({
    CapabilitySupport? batch,
    CapabilitySupport? citations,
    CapabilitySupport? codeExecution,
    ContextManagementCapability? contextManagement,
    EffortCapability? effort,
    CapabilitySupport? imageInput,
    CapabilitySupport? pdfInput,
    CapabilitySupport? structuredOutputs,
    ThinkingCapability? thinking,
    Object? serverTools = unsetCopyWithValue,
    Object? compaction = unsetCopyWithValue,
  }) => ModelCapabilities(
    batch: batch ?? this.batch,
    citations: citations ?? this.citations,
    codeExecution: codeExecution ?? this.codeExecution,
    contextManagement: contextManagement ?? this.contextManagement,
    effort: effort ?? this.effort,
    imageInput: imageInput ?? this.imageInput,
    pdfInput: pdfInput ?? this.pdfInput,
    structuredOutputs: structuredOutputs ?? this.structuredOutputs,
    thinking: thinking ?? this.thinking,
    serverTools: serverTools == unsetCopyWithValue
        ? this.serverTools
        : serverTools as ServerToolsCapability?,
    compaction: compaction == unsetCopyWithValue
        ? this.compaction
        : compaction as CompactionCapability?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelCapabilities &&
          runtimeType == other.runtimeType &&
          batch == other.batch &&
          citations == other.citations &&
          codeExecution == other.codeExecution &&
          contextManagement == other.contextManagement &&
          effort == other.effort &&
          imageInput == other.imageInput &&
          pdfInput == other.pdfInput &&
          structuredOutputs == other.structuredOutputs &&
          thinking == other.thinking &&
          serverTools == other.serverTools &&
          compaction == other.compaction;

  @override
  int get hashCode => Object.hash(
    batch,
    citations,
    codeExecution,
    contextManagement,
    effort,
    imageInput,
    pdfInput,
    structuredOutputs,
    thinking,
    serverTools,
    compaction,
  );

  @override
  String toString() =>
      'ModelCapabilities(batch: $batch, citations: $citations, '
      'codeExecution: $codeExecution, '
      'contextManagement: $contextManagement, effort: $effort, '
      'imageInput: $imageInput, pdfInput: $pdfInput, '
      'structuredOutputs: $structuredOutputs, thinking: $thinking, '
      'serverTools: $serverTools, compaction: $compaction)';
}
