import 'package:meta/meta.dart';

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

  /// Creates a [ThinkingTypes].
  const ThinkingTypes({required this.adaptive, required this.enabled});

  /// Creates a [ThinkingTypes] from JSON.
  factory ThinkingTypes.fromJson(Map<String, dynamic> json) {
    return ThinkingTypes(
      adaptive: CapabilitySupport.fromJson(
        json['adaptive'] as Map<String, dynamic>,
      ),
      enabled: CapabilitySupport.fromJson(
        json['enabled'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'adaptive': adaptive.toJson(),
    'enabled': enabled.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkingTypes &&
          runtimeType == other.runtimeType &&
          adaptive == other.adaptive &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(adaptive, enabled);

  @override
  String toString() => 'ThinkingTypes(adaptive: $adaptive, enabled: $enabled)';
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

  /// Whether this capability is supported by the model.
  final bool supported;

  /// Creates an [EffortCapability].
  const EffortCapability({
    required this.high,
    required this.low,
    required this.max,
    required this.medium,
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
      supported: json['supported'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'high': high.toJson(),
    'low': low.toJson(),
    'max': max.toJson(),
    'medium': medium.toJson(),
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
          supported == other.supported;

  @override
  int get hashCode => Object.hash(high, low, max, medium, supported);

  @override
  String toString() =>
      'EffortCapability(high: $high, low: $low, max: $max, '
      'medium: $medium, supported: $supported)';
}

/// Model capability information.
@immutable
class ModelCapabilities {
  /// Whether the model supports the Batch API.
  final CapabilitySupport batch;

  /// Whether the model supports citation generation.
  final CapabilitySupport citations;

  /// Whether the model supports code execution tools.
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
  };

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
          thinking == other.thinking;

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
  );

  @override
  String toString() =>
      'ModelCapabilities(batch: $batch, citations: $citations, '
      'codeExecution: $codeExecution, '
      'contextManagement: $contextManagement, effort: $effort, '
      'imageInput: $imageInput, pdfInput: $pdfInput, '
      'structuredOutputs: $structuredOutputs, thinking: $thinking)';
}
