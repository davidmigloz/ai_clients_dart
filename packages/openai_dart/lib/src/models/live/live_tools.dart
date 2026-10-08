import 'live_delegation.dart';
import 'live_json_helpers.dart';

/// Canonical Live tool input branches, independent of Responses tool models.
///
/// Open schemas preserve finite, deeply immutable [rawJson] extras. A branch
/// declaring only `type` deliberately exposes no invented configuration fields.
sealed class LiveTool extends LiveJsonModel {
  /// Creates a Live tool value.
  const LiveTool();

  /// Canonical tool discriminator.
  String get type;

  /// Immutable snapshot of declared and future JSON fields.
  Map<String, dynamic> get rawJson;

  @override
  Map<String, dynamic> toJson();

  /// Creates the canonical `function` branch.
  factory LiveTool.function({
    Object? description = liveUnset,
    required String name,
    Object? parameters = liveUnset,
    Object? strict = liveUnset,
    Map<String, dynamic> rawJson = const {},
  }) => LiveFunctionTool(
    description: description,
    name: name,
    parameters: parameters,
    strict: strict,
    rawJson: rawJson,
  );

  /// Creates the canonical `web_search` branch.
  factory LiveTool.webSearch({Map<String, dynamic> rawJson = const {}}) =>
      LiveWebSearchTool(rawJson: rawJson);

  /// Creates the canonical `file_search` branch.
  factory LiveTool.fileSearch({Map<String, dynamic> rawJson = const {}}) =>
      LiveFileSearchTool(rawJson: rawJson);

  /// Creates the canonical `code_interpreter` branch.
  factory LiveTool.codeInterpreter({Map<String, dynamic> rawJson = const {}}) =>
      LiveCodeInterpreterTool(rawJson: rawJson);

  /// Creates the canonical `shell` branch.
  factory LiveTool.shell({
    Object? environment = liveUnset,
    Map<String, dynamic> rawJson = const {},
  }) => LiveHostedShellTool(environment: environment, rawJson: rawJson);

  /// Creates the canonical `image_generation` branch.
  factory LiveTool.imageGeneration({Map<String, dynamic> rawJson = const {}}) =>
      LiveImageGenerationTool(rawJson: rawJson);

  /// Creates the canonical `mcp` branch.
  factory LiveTool.mcp({Map<String, dynamic> rawJson = const {}}) =>
      LiveMCPTool(rawJson: rawJson);

  /// Creates the canonical `custom` branch.
  factory LiveTool.custom({Map<String, dynamic> rawJson = const {}}) =>
      LiveCustomTool(rawJson: rawJson);

  /// Creates the canonical `namespace` branch.
  factory LiveTool.namespace({Map<String, dynamic> rawJson = const {}}) =>
      LiveNamespaceTool(rawJson: rawJson);

  /// Creates the canonical `tool_search` branch.
  factory LiveTool.toolSearch({Map<String, dynamic> rawJson = const {}}) =>
      LiveToolSearchTool(rawJson: rawJson);

  /// Creates the canonical `programmatic_tool_calling` branch.
  factory LiveTool.programmatic({Map<String, dynamic> rawJson = const {}}) =>
      LiveProgrammaticTool(rawJson: rawJson);

  /// Creates the canonical `computer` branch.
  factory LiveTool.computer({Map<String, dynamic> rawJson = const {}}) =>
      LiveComputerTool(rawJson: rawJson);

  /// Creates the canonical `apply_patch` branch.
  factory LiveTool.applyPatch({Map<String, dynamic> rawJson = const {}}) =>
      LiveApplyPatchTool(rawJson: rawJson);

  /// Parses only the canonical known writable branches.
  factory LiveTool.fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(json['type'], 'LiveTool.type');
    return switch (type) {
      'function' => LiveFunctionTool.fromJson(json),
      'web_search' => LiveWebSearchTool.fromJson(json),
      'file_search' => LiveFileSearchTool.fromJson(json),
      'code_interpreter' => LiveCodeInterpreterTool.fromJson(json),
      'shell' => LiveHostedShellTool.fromJson(json),
      'image_generation' => LiveImageGenerationTool.fromJson(json),
      'mcp' => LiveMCPTool.fromJson(json),
      'custom' => LiveCustomTool.fromJson(json),
      'namespace' => LiveNamespaceTool.fromJson(json),
      'tool_search' => LiveToolSearchTool.fromJson(json),
      'programmatic_tool_calling' => LiveProgrammaticTool.fromJson(json),
      'computer' => LiveComputerTool.fromJson(json),
      'apply_patch' => LiveApplyPatchTool.fromJson(json),
      _ => throw const FormatException('LiveTool.type: unsupported branch'),
    };
  }
}

/// Canonical discriminated LiveShellEnvironment union.
sealed class LiveShellEnvironment extends LiveJsonModel {
  /// Creates a union value.
  const LiveShellEnvironment();

  /// Canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Parses only the canonical known writable branches.
  factory LiveShellEnvironment.fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(json['type'], 'LiveShellEnvironment.type');
    return switch (type) {
      'container_auto' => LiveHostedShellContainerAuto.fromJson(json),
      'container_reference' => LiveContainerReference.fromJson(json),
      'local' => LiveLocalEnvironment.fromJson(json),
      _ => throw const FormatException(
        'LiveShellEnvironment.type: unsupported branch',
      ),
    };
  }
}

/// Canonical discriminated LiveContainerNetworkPolicy union.
sealed class LiveContainerNetworkPolicy extends LiveJsonModel {
  /// Creates a union value.
  const LiveContainerNetworkPolicy();

  /// Canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Parses only the canonical known writable branches.
  factory LiveContainerNetworkPolicy.fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(
      json['type'],
      'LiveContainerNetworkPolicy.type',
    );
    return switch (type) {
      'disabled' => LiveContainerNetworkPolicyDisabled.fromJson(json),
      'allowlist' => LiveHostedShellNetworkPolicyAllowlist.fromJson(json),
      _ => throw const FormatException(
        'LiveContainerNetworkPolicy.type: unsupported branch',
      ),
    };
  }
}

/// Canonical discriminated LiveHostedSkill union.
sealed class LiveHostedSkill extends LiveJsonModel {
  /// Creates a union value.
  const LiveHostedSkill();

  /// Canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Parses only the canonical known writable branches.
  factory LiveHostedSkill.fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(json['type'], 'LiveHostedSkill.type');
    return switch (type) {
      'skill_reference' => LiveSkillReference.fromJson(json),
      'inline' => LiveInlineSkill.fromJson(json),
      _ => throw const FormatException(
        'LiveHostedSkill.type: unsupported branch',
      ),
    };
  }
}

/// The exact scalar, specific-tool, or allowed-tools Live choice union.
sealed class LiveToolChoice extends LiveJsonModel {
  /// Creates a Live tool choice.
  const LiveToolChoice();

  /// Selects the canonical scalar tool-choice policy.
  const factory LiveToolChoice.mode(LiveToolChoiceEnum value) =
      LiveToolChoiceMode;

  /// Parses the canonical scalar or known object branch.
  factory LiveToolChoice.fromJson(Object? json) {
    if (json is String) {
      return LiveToolChoiceMode(LiveToolChoiceEnum.fromJson(json));
    }
    final object = requireLiveObject(json, 'LiveToolChoice');
    if (object['type'] == 'allowed_tools') {
      return LiveAllowedToolsChoice.fromJson(object);
    }
    return LiveSpecificToolChoice.fromJson(object);
  }
}

/// A canonical scalar tool-choice policy.
final class LiveToolChoiceMode extends LiveToolChoice {
  /// Creates a scalar choice.
  const LiveToolChoiceMode(this.value);

  /// The scalar policy.
  final LiveToolChoiceEnum value;

  /// Copies the scalar policy.
  LiveToolChoiceMode copyWith({LiveToolChoiceEnum? value}) =>
      LiveToolChoiceMode(value ?? this.value);

  @override
  String toJson() => value.toJson();
}

/// The twelve canonical specific tool-choice object branches.
///
/// This union also supplies entries for [LiveAllowedToolsChoice.tools]. Scalars
/// and recursive allowed-tools branches cannot occur in that array.
sealed class LiveSpecificToolChoice extends LiveToolChoice {
  /// Creates a specific choice.
  const LiveSpecificToolChoice();

  /// Canonical specific-choice discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Parses only the canonical known writable branches.
  factory LiveSpecificToolChoice.fromJson(Map<String, dynamic> json) {
    final type = requireLiveString(json['type'], 'LiveSpecificToolChoice.type');
    return switch (type) {
      'function' => LiveFunctionToolChoice.fromJson(json),
      'mcp' => LiveMCPToolChoice.fromJson(json),
      'file_search' => LiveSpecificFileSearch.fromJson(json),
      'web_search' => LiveSpecificWebSearch.fromJson(json),
      'web_search_preview' => LiveSpecificWebSearchPreview.fromJson(json),
      'image_generation' => LiveSpecificImageGen.fromJson(json),
      'computer' => LiveSpecificComputer.fromJson(json),
      'code_interpreter' => LiveSpecificCodeInterpreter.fromJson(json),
      'programmatic_tool_calling' =>
        LiveSpecificProgrammaticToolCalling.fromJson(json),
      'shell' => LiveSpecificFunctionShell.fromJson(json),
      'custom' => LiveSpecificCustomTool.fromJson(json),
      'apply_patch' => LiveSpecificApplyPatch.fromJson(json),
      _ => throw const FormatException(
        'LiveSpecificToolChoice.type: unsupported branch',
      ),
    };
  }
}

/// Canonical values of `LiveContainerMemoryLimit`.
enum LiveContainerMemoryLimit {
  /// The `1g` wire value.
  g1('1g'),

  /// The `4g` wire value.
  g4('4g'),

  /// The `16g` wire value.
  g16('16g'),

  /// The `64g` wire value.
  g64('64g');

  const LiveContainerMemoryLimit(this.value);

  /// Canonical wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a known value without reflecting private input.
  static LiveContainerMemoryLimit fromJson(Object? json) => switch (json) {
    '1g' => g1,
    '4g' => g4,
    '16g' => g16,
    '64g' => g64,
    _ => throw const FormatException(
      'LiveContainerMemoryLimit: unsupported value',
    ),
  };
}

/// Canonical values of `LiveToolChoiceValueEnum`.
enum LiveToolChoiceValueEnum {
  /// The `none` wire value.
  none('none'),

  /// The `auto` wire value.
  auto('auto'),

  /// The `required` wire value.
  required('required');

  const LiveToolChoiceValueEnum(this.value);

  /// Canonical wire value.
  final String value;

  /// Serializes the canonical wire value.
  String toJson() => value;

  /// Parses a known value without reflecting private input.
  static LiveToolChoiceValueEnum fromJson(Object? json) => switch (json) {
    'none' => none,
    'auto' => auto,
    'required' => required,
    _ => throw const FormatException(
      'LiveToolChoiceValueEnum: unsupported value',
    ),
  };
}

/// Canonical `LiveFunctionToolInputParam` object with finite immutable open extras.
final class LiveFunctionTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveFunctionTool({
    Object? description = liveUnset,

    required this.name,

    Object? parameters = liveUnset,

    Object? strict = liveUnset,

    Map<String, dynamic> rawJson = const {},
  }) : description = _liveNullable<String>(
         description,
         'LiveFunctionTool.description',
         requireLiveString,
       ),
       parameters = _liveNullable<Map<String, dynamic>>(
         parameters,
         'LiveFunctionTool.parameters',
         _liveParameters,
       ),
       strict = _liveNullable<bool>(
         strict,
         'LiveFunctionTool.strict',
         requireLiveBool,
       ),
       hasDescription = !identical(description, liveUnset),
       hasParameters = !identical(parameters, liveUnset),
       hasStrict = !identical(strict, liveUnset),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveFunctionTool',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveFunctionTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'function', 'LiveFunctionTool');

    return LiveFunctionTool(
      description: json.containsKey('description')
          ? optionalLiveValue<String>(
              json,
              'description',
              'LiveFunctionTool',
              requireLiveString,
              nullable: true,
            )
          : liveUnset,

      name: requireLiveString(json['name'], 'LiveFunctionTool.name'),

      parameters: json.containsKey('parameters')
          ? optionalLiveValue<Map<String, dynamic>>(
              json,
              'parameters',
              'LiveFunctionTool',
              _liveParameters,
              nullable: true,
            )
          : liveUnset,

      strict: json.containsKey('strict')
          ? optionalLiveValue<bool>(
              json,
              'strict',
              'LiveFunctionTool',
              requireLiveBool,
              nullable: true,
            )
          : liveUnset,

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {
    'description',
    'name',
    'parameters',
    'strict',
    'type',
  };

  /// Canonical fixed `type` value.
  @override
  String get type => 'function';

  /// Canonical `description` field (omission, null and value remain distinct).
  final String? description;

  /// Whether `description` is present, including an explicit null.
  final bool hasDescription;

  /// Canonical `name` field.
  final String name;

  /// Canonical `parameters` field (omission, null and value remain distinct).
  final Map<String, dynamic>? parameters;

  /// Whether `parameters` is present, including an explicit null.
  final bool hasParameters;

  /// Canonical `strict` field (omission, null and value remain distinct).
  final bool? strict;

  /// Whether `strict` is present, including an explicit null.
  final bool hasStrict;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    if (description != null) {}

    if (parameters != null) {}

    if (strict != null) {}
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveFunctionTool copyWith({
    Object? description = liveUnset,

    bool? hasDescription,

    String? name,

    Object? parameters = liveUnset,

    bool? hasParameters,

    Object? strict = liveUnset,

    bool? hasStrict,

    Map<String, dynamic>? rawJson,
  }) => LiveFunctionTool(
    description: _copyLiveNullable(
      description,
      this.description,
      this.hasDescription,
      hasDescription,
    ),

    name: name ?? this.name,

    parameters: _copyLiveNullable(
      parameters,
      this.parameters,
      this.hasParameters,
      hasParameters,
    ),

    strict: _copyLiveNullable(strict, this.strict, this.hasStrict, hasStrict),

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasDescription) 'description': description,

    'name': name,

    if (hasParameters) 'parameters': parameters,

    if (hasStrict) 'strict': strict,

    'type': type,
  });
}

/// Canonical `LiveWebSearchToolInputParam` object with finite immutable open extras.
final class LiveWebSearchTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveWebSearchTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveWebSearchTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveWebSearchTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'web_search', 'LiveWebSearchTool');

    return LiveWebSearchTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'web_search';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveWebSearchTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveWebSearchTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveFileSearchToolInputParam` object with finite immutable open extras.
final class LiveFileSearchTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveFileSearchTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveFileSearchTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveFileSearchTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'file_search', 'LiveFileSearchTool');

    return LiveFileSearchTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'file_search';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveFileSearchTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveFileSearchTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveCodeInterpreterToolInputParam` object with finite immutable open extras.
final class LiveCodeInterpreterTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveCodeInterpreterTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveCodeInterpreterTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveCodeInterpreterTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'code_interpreter', 'LiveCodeInterpreterTool');

    return LiveCodeInterpreterTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'code_interpreter';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveCodeInterpreterTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveCodeInterpreterTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveHostedShellToolInputParam` object with finite immutable open extras.
final class LiveHostedShellTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveHostedShellTool({
    Object? environment = liveUnset,

    Map<String, dynamic> rawJson = const {},
  }) : environment = _liveNullable<LiveShellEnvironment>(
         environment,
         'LiveHostedShellTool.environment',
         _liveTyped<LiveShellEnvironment>,
       ),
       hasEnvironment = !identical(environment, liveUnset),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveHostedShellTool',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveHostedShellTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'shell', 'LiveHostedShellTool');

    return LiveHostedShellTool(
      environment: json.containsKey('environment')
          ? optionalLiveValue<LiveShellEnvironment>(
              json,
              'environment',
              'LiveHostedShellTool',
              (value, context) =>
                  _readLiveModel(value, context, LiveShellEnvironment.fromJson),
              nullable: true,
            )
          : liveUnset,

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'environment', 'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'shell';

  /// Canonical `environment` field (omission, null and value remain distinct).
  final LiveShellEnvironment? environment;

  /// Whether `environment` is present, including an explicit null.
  final bool hasEnvironment;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    if (environment != null) {
      environment!.validate();
    }
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveHostedShellTool copyWith({
    Object? environment = liveUnset,

    bool? hasEnvironment,

    Map<String, dynamic>? rawJson,
  }) => LiveHostedShellTool(
    environment: _copyLiveNullable(
      environment,
      this.environment,
      this.hasEnvironment,
      hasEnvironment,
    ),

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasEnvironment) 'environment': environment?.toJson(),

    'type': type,
  });
}

/// Canonical `LiveImageGenerationToolInputParam` object with finite immutable open extras.
final class LiveImageGenerationTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveImageGenerationTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveImageGenerationTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveImageGenerationTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'image_generation', 'LiveImageGenerationTool');

    return LiveImageGenerationTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'image_generation';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveImageGenerationTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveImageGenerationTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveMCPToolInputParam` object with finite immutable open extras.
final class LiveMCPTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveMCPTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveMCPTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveMCPTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'mcp', 'LiveMCPTool');

    return LiveMCPTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'mcp';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveMCPTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveMCPTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveCustomToolInputParam` object with finite immutable open extras.
final class LiveCustomTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveCustomTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveCustomTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveCustomTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'custom', 'LiveCustomTool');

    return LiveCustomTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'custom';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveCustomTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveCustomTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveNamespaceToolInputParam` object with finite immutable open extras.
final class LiveNamespaceTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveNamespaceTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveNamespaceTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveNamespaceTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'namespace', 'LiveNamespaceTool');

    return LiveNamespaceTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'namespace';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveNamespaceTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveNamespaceTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveToolSearchToolInputParam` object with finite immutable open extras.
final class LiveToolSearchTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveToolSearchTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveToolSearchTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveToolSearchTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'tool_search', 'LiveToolSearchTool');

    return LiveToolSearchTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'tool_search';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveToolSearchTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveToolSearchTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveProgrammaticToolInputParam` object with finite immutable open extras.
final class LiveProgrammaticTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveProgrammaticTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveProgrammaticTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveProgrammaticTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'programmatic_tool_calling', 'LiveProgrammaticTool');

    return LiveProgrammaticTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'programmatic_tool_calling';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveProgrammaticTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveProgrammaticTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveComputerToolInputParam` object with finite immutable open extras.
final class LiveComputerTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveComputerTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveComputerTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveComputerTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'computer', 'LiveComputerTool');

    return LiveComputerTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'computer';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveComputerTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveComputerTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveApplyPatchToolInputParam` object with finite immutable open extras.
final class LiveApplyPatchTool extends LiveTool {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveApplyPatchTool({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveApplyPatchTool',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveApplyPatchTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'apply_patch', 'LiveApplyPatchTool');

    return LiveApplyPatchTool(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'apply_patch';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  @override
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveApplyPatchTool copyWith({Map<String, dynamic>? rawJson}) =>
      LiveApplyPatchTool(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveHostedShellContainerAutoParam` object with finite immutable open extras.
final class LiveHostedShellContainerAuto extends LiveShellEnvironment {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveHostedShellContainerAuto({
    Object? fileIds = liveUnset,

    Object? memoryLimit = liveUnset,

    Object? networkPolicy = liveUnset,

    Object? skills = liveUnset,

    Map<String, dynamic> rawJson = const {},
  }) : fileIds = _liveNullable<List<String>>(
         fileIds,
         'LiveHostedShellContainerAuto.fileIds',
         _liveStrings,
       ),
       memoryLimit = _liveNullable<LiveContainerMemoryLimit>(
         memoryLimit,
         'LiveHostedShellContainerAuto.memoryLimit',
         _liveTyped<LiveContainerMemoryLimit>,
       ),
       networkPolicy = _liveNullable<LiveContainerNetworkPolicy>(
         networkPolicy,
         'LiveHostedShellContainerAuto.networkPolicy',
         _liveTyped<LiveContainerNetworkPolicy>,
       ),
       skills = _liveNullable<List<LiveHostedSkill>>(
         skills,
         'LiveHostedShellContainerAuto.skills',
         _liveTypedList<LiveHostedSkill>,
       ),
       hasFileIds = !identical(fileIds, liveUnset),
       hasMemoryLimit = !identical(memoryLimit, liveUnset),
       hasNetworkPolicy = !identical(networkPolicy, liveUnset),
       hasSkills = !identical(skills, liveUnset),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveHostedShellContainerAuto',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveHostedShellContainerAuto.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'container_auto', 'LiveHostedShellContainerAuto');

    return LiveHostedShellContainerAuto(
      fileIds: json.containsKey('file_ids')
          ? optionalLiveValue<List<String>>(
              json,
              'file_ids',
              'LiveHostedShellContainerAuto',
              _liveStrings,
              nullable: true,
            )
          : liveUnset,

      memoryLimit: json.containsKey('memory_limit')
          ? optionalLiveValue<LiveContainerMemoryLimit>(
              json,
              'memory_limit',
              'LiveHostedShellContainerAuto',
              (value, context) => _readLiveEnum(
                value,
                context,
                LiveContainerMemoryLimit.fromJson,
              ),
              nullable: true,
            )
          : liveUnset,

      networkPolicy: json.containsKey('network_policy')
          ? optionalLiveValue<LiveContainerNetworkPolicy>(
              json,
              'network_policy',
              'LiveHostedShellContainerAuto',
              (value, context) => _readLiveModel(
                value,
                context,
                LiveContainerNetworkPolicy.fromJson,
              ),
              nullable: true,
            )
          : liveUnset,

      skills: json.containsKey('skills')
          ? optionalLiveValue<List<LiveHostedSkill>>(
              json,
              'skills',
              'LiveHostedShellContainerAuto',
              (value, context) =>
                  _readLiveModels(value, context, LiveHostedSkill.fromJson),
              nullable: true,
            )
          : liveUnset,

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {
    'file_ids',
    'memory_limit',
    'network_policy',
    'skills',
    'type',
  };

  /// Canonical fixed `type` value.
  @override
  String get type => 'container_auto';

  /// Canonical `file_ids` field (omission, null and value remain distinct).
  final List<String>? fileIds;

  /// Whether `file_ids` is present, including an explicit null.
  final bool hasFileIds;

  /// Canonical `memory_limit` field (omission, null and value remain distinct).
  final LiveContainerMemoryLimit? memoryLimit;

  /// Whether `memory_limit` is present, including an explicit null.
  final bool hasMemoryLimit;

  /// Canonical `network_policy` field (omission, null and value remain distinct).
  final LiveContainerNetworkPolicy? networkPolicy;

  /// Whether `network_policy` is present, including an explicit null.
  final bool hasNetworkPolicy;

  /// Canonical `skills` field (omission, null and value remain distinct).
  final List<LiveHostedSkill>? skills;

  /// Whether `skills` is present, including an explicit null.
  final bool hasSkills;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    if (fileIds != null) {
      _validateLiveListLength(
        fileIds!,
        'LiveHostedShellContainerAuto.fileIds',
        max: 50,
      );
    }

    if (memoryLimit != null) {}

    if (networkPolicy != null) {
      networkPolicy!.validate();
    }

    if (skills != null) {
      _validateLiveListLength(
        skills!,
        'LiveHostedShellContainerAuto.skills',
        max: 200,
      );

      for (final value in skills!) {
        value.validate();
      }
    }
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveHostedShellContainerAuto copyWith({
    Object? fileIds = liveUnset,

    bool? hasFileIds,

    Object? memoryLimit = liveUnset,

    bool? hasMemoryLimit,

    Object? networkPolicy = liveUnset,

    bool? hasNetworkPolicy,

    Object? skills = liveUnset,

    bool? hasSkills,

    Map<String, dynamic>? rawJson,
  }) => LiveHostedShellContainerAuto(
    fileIds: _copyLiveNullable(
      fileIds,
      this.fileIds,
      this.hasFileIds,
      hasFileIds,
    ),

    memoryLimit: _copyLiveNullable(
      memoryLimit,
      this.memoryLimit,
      this.hasMemoryLimit,
      hasMemoryLimit,
    ),

    networkPolicy: _copyLiveNullable(
      networkPolicy,
      this.networkPolicy,
      this.hasNetworkPolicy,
      hasNetworkPolicy,
    ),

    skills: _copyLiveNullable(skills, this.skills, this.hasSkills, hasSkills),

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasFileIds) 'file_ids': fileIds,

    if (hasMemoryLimit) 'memory_limit': memoryLimit?.toJson(),

    if (hasNetworkPolicy) 'network_policy': networkPolicy?.toJson(),

    if (hasSkills) 'skills': skills?.map((value) => value.toJson()).toList(),

    'type': type,
  });
}

/// Canonical `LiveContainerReferenceParam` object with finite immutable open extras.
final class LiveContainerReference extends LiveShellEnvironment {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveContainerReference({
    required this.containerId,

    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveContainerReference',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveContainerReference.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'container_reference', 'LiveContainerReference');

    return LiveContainerReference(
      containerId: requireLiveString(
        json['container_id'],
        'LiveContainerReference.container_id',
      ),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'container_id', 'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'container_reference';

  /// Canonical `container_id` field.
  final String containerId;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveContainerReference copyWith({
    String? containerId,

    Map<String, dynamic>? rawJson,
  }) => LiveContainerReference(
    containerId: containerId ?? this.containerId,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'container_id': containerId,

    'type': type,
  });
}

/// Canonical `LiveLocalEnvironmentParam` object with finite immutable open extras.
final class LiveLocalEnvironment extends LiveShellEnvironment {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveLocalEnvironment({
    Object? skills = liveUnset,

    Map<String, dynamic> rawJson = const {},
  }) : skills = _liveNullable<List<LiveLocalSkill>>(
         skills,
         'LiveLocalEnvironment.skills',
         _liveTypedList<LiveLocalSkill>,
       ),
       hasSkills = !identical(skills, liveUnset),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveLocalEnvironment',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveLocalEnvironment.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'local', 'LiveLocalEnvironment');

    return LiveLocalEnvironment(
      skills: json.containsKey('skills')
          ? optionalLiveValue<List<LiveLocalSkill>>(
              json,
              'skills',
              'LiveLocalEnvironment',
              (value, context) =>
                  _readLiveModels(value, context, LiveLocalSkill.fromJson),
              nullable: true,
            )
          : liveUnset,

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'skills', 'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'local';

  /// Canonical `skills` field (omission, null and value remain distinct).
  final List<LiveLocalSkill>? skills;

  /// Whether `skills` is present, including an explicit null.
  final bool hasSkills;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    if (skills != null) {
      _validateLiveListLength(skills!, 'LiveLocalEnvironment.skills', max: 200);

      for (final value in skills!) {
        value.validate();
      }
    }
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveLocalEnvironment copyWith({
    Object? skills = liveUnset,

    bool? hasSkills,

    Map<String, dynamic>? rawJson,
  }) => LiveLocalEnvironment(
    skills: _copyLiveNullable(skills, this.skills, this.hasSkills, hasSkills),

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasSkills) 'skills': skills?.map((value) => value.toJson()).toList(),

    'type': type,
  });
}

/// Canonical `LiveContainerNetworkPolicyDisabledParam` object with finite immutable open extras.
final class LiveContainerNetworkPolicyDisabled
    extends LiveContainerNetworkPolicy {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveContainerNetworkPolicyDisabled({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveContainerNetworkPolicyDisabled',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveContainerNetworkPolicyDisabled.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(json, 'disabled', 'LiveContainerNetworkPolicyDisabled');

    return LiveContainerNetworkPolicyDisabled(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'disabled';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveContainerNetworkPolicyDisabled copyWith({
    Map<String, dynamic>? rawJson,
  }) => LiveContainerNetworkPolicyDisabled(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveHostedShellNetworkPolicyAllowlistParam` object with finite immutable open extras.
final class LiveHostedShellNetworkPolicyAllowlist
    extends LiveContainerNetworkPolicy {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveHostedShellNetworkPolicyAllowlist({
    required List<String> allowedDomains,

    Map<String, dynamic> rawJson = const {},
  }) : allowedDomains = _liveTypedList<String>(
         allowedDomains,
         'LiveHostedShellNetworkPolicyAllowlist.allowedDomains',
       ),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveHostedShellNetworkPolicyAllowlist',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveHostedShellNetworkPolicyAllowlist.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(json, 'allowlist', 'LiveHostedShellNetworkPolicyAllowlist');

    return LiveHostedShellNetworkPolicyAllowlist(
      allowedDomains: _liveStrings(
        json['allowed_domains'],
        'LiveHostedShellNetworkPolicyAllowlist.allowed_domains',
      ),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'allowed_domains', 'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'allowlist';

  /// Canonical `allowed_domains` field.
  final List<String> allowedDomains;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    _validateLiveListLength(
      allowedDomains,
      'LiveHostedShellNetworkPolicyAllowlist.allowedDomains',
      min: 1,
    );
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveHostedShellNetworkPolicyAllowlist copyWith({
    List<String>? allowedDomains,

    Map<String, dynamic>? rawJson,
  }) => LiveHostedShellNetworkPolicyAllowlist(
    allowedDomains: allowedDomains ?? this.allowedDomains,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'allowed_domains': allowedDomains,

    'type': type,
  });
}

/// Canonical `LiveSkillReferenceParam` object with finite immutable open extras.
final class LiveSkillReference extends LiveHostedSkill {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSkillReference({
    required this.skillId,

    Object? version = liveUnset,

    Map<String, dynamic> rawJson = const {},
  }) : version = _liveNullable<String>(
         version,
         'LiveSkillReference.version',
         requireLiveString,
       ),
       hasVersion = !identical(version, liveUnset),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveSkillReference',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSkillReference.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'skill_reference', 'LiveSkillReference');

    return LiveSkillReference(
      skillId: requireLiveString(
        json['skill_id'],
        'LiveSkillReference.skill_id',
      ),

      version: json.containsKey('version')
          ? optionalLiveValue<String>(
              json,
              'version',
              'LiveSkillReference',
              requireLiveString,
              nullable: true,
            )
          : liveUnset,

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'skill_id', 'type', 'version'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'skill_reference';

  /// Canonical `skill_id` field.
  final String skillId;

  /// Canonical `version` field (omission, null and value remain distinct).
  final String? version;

  /// Whether `version` is present, including an explicit null.
  final bool hasVersion;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    validateLiveLength(skillId, 'LiveSkillReference.skillId', min: 1, max: 64);

    if (version != null) {}
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSkillReference copyWith({
    String? skillId,

    Object? version = liveUnset,

    bool? hasVersion,

    Map<String, dynamic>? rawJson,
  }) => LiveSkillReference(
    skillId: skillId ?? this.skillId,

    version: _copyLiveNullable(
      version,
      this.version,
      this.hasVersion,
      hasVersion,
    ),

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'skill_id': skillId,

    'type': type,

    if (hasVersion) 'version': version,
  });
}

/// Canonical `LiveInlineSkillParam` object with finite immutable open extras.
final class LiveInlineSkill extends LiveHostedSkill {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveInlineSkill({
    required this.description,

    required this.name,

    required this.source,

    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInlineSkill',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveInlineSkill.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'inline', 'LiveInlineSkill');

    return LiveInlineSkill(
      description: requireLiveString(
        json['description'],
        'LiveInlineSkill.description',
      ),

      name: requireLiveString(json['name'], 'LiveInlineSkill.name'),

      source: _readLiveModel(
        json['source'],
        'LiveInlineSkill.source',
        LiveInlineSkillSource.fromJson,
      ),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {
    'description',
    'name',
    'source',
    'type',
  };

  /// Canonical fixed `type` value.
  @override
  String get type => 'inline';

  /// Canonical `description` field.
  final String description;

  /// Canonical `name` field.
  final String name;

  /// Canonical `source` field.
  final LiveInlineSkillSource source;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    source.validate();
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveInlineSkill copyWith({
    String? description,

    String? name,

    LiveInlineSkillSource? source,

    Map<String, dynamic>? rawJson,
  }) => LiveInlineSkill(
    description: description ?? this.description,

    name: name ?? this.name,

    source: source ?? this.source,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'description': description,

    'name': name,

    'source': source.toJson(),

    'type': type,
  });
}

/// Canonical `LiveInlineSkillSourceParam` object with finite immutable open extras.
final class LiveInlineSkillSource extends LiveJsonModel {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveInlineSkillSource({
    required this.data,

    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveInlineSkillSource',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveInlineSkillSource.fromJson(Map<String, dynamic> json) {
    requireLiveType(
      json,
      'application/zip',
      'LiveInlineSkillSource',
      key: 'media_type',
    );

    requireLiveType(json, 'base64', 'LiveInlineSkillSource');

    return LiveInlineSkillSource(
      data: requireLiveString(json['data'], 'LiveInlineSkillSource.data'),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'data', 'media_type', 'type'};

  /// Canonical fixed `media_type` value.
  String get mediaType => 'application/zip';

  /// Canonical fixed `type` value.
  String get type => 'base64';

  /// Canonical `data` field.
  final String data;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    validateLiveLength(
      data,
      'LiveInlineSkillSource.data',
      min: 1,
      max: 70254592,
    );
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveInlineSkillSource copyWith({
    String? data,

    Map<String, dynamic>? rawJson,
  }) => LiveInlineSkillSource(
    data: data ?? this.data,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'data': data,

    'media_type': mediaType,

    'type': type,
  });
}

/// Canonical `LiveLocalSkillParam` object with finite immutable open extras.
final class LiveLocalSkill extends LiveJsonModel {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveLocalSkill({
    required this.description,

    required this.name,

    required this.path,

    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveLocalSkill',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveLocalSkill.fromJson(Map<String, dynamic> json) {
    return LiveLocalSkill(
      description: requireLiveString(
        json['description'],
        'LiveLocalSkill.description',
      ),

      name: requireLiveString(json['name'], 'LiveLocalSkill.name'),

      path: requireLiveString(json['path'], 'LiveLocalSkill.path'),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'description', 'name', 'path'};

  /// Canonical `description` field.
  final String description;

  /// Canonical `name` field.
  final String name;

  /// Canonical `path` field.
  final String path;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveLocalSkill copyWith({
    String? description,

    String? name,

    String? path,

    Map<String, dynamic>? rawJson,
  }) => LiveLocalSkill(
    description: description ?? this.description,

    name: name ?? this.name,

    path: path ?? this.path,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    'description': description,

    'name': name,

    'path': path,
  });
}

/// Canonical `LiveFunctionToolChoiceParam` object with finite immutable open extras.
final class LiveFunctionToolChoice extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveFunctionToolChoice({
    required this.name,

    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveFunctionToolChoice',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveFunctionToolChoice.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'function', 'LiveFunctionToolChoice');

    return LiveFunctionToolChoice(
      name: requireLiveString(json['name'], 'LiveFunctionToolChoice.name'),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'name', 'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'function';

  /// Canonical `name` field.
  final String name;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveFunctionToolChoice copyWith({
    String? name,

    Map<String, dynamic>? rawJson,
  }) => LiveFunctionToolChoice(
    name: name ?? this.name,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'name': name, 'type': type});
}

/// Canonical `LiveMCPToolChoiceParam` object with finite immutable open extras.
final class LiveMCPToolChoice extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveMCPToolChoice({
    Object? name = liveUnset,

    required this.serverLabel,

    Map<String, dynamic> rawJson = const {},
  }) : name = _liveNullable<String>(
         name,
         'LiveMCPToolChoice.name',
         requireLiveString,
       ),
       hasName = !identical(name, liveUnset),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveMCPToolChoice',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveMCPToolChoice.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'mcp', 'LiveMCPToolChoice');

    return LiveMCPToolChoice(
      name: json.containsKey('name')
          ? optionalLiveValue<String>(
              json,
              'name',
              'LiveMCPToolChoice',
              requireLiveString,
              nullable: true,
            )
          : liveUnset,

      serverLabel: requireLiveString(
        json['server_label'],
        'LiveMCPToolChoice.server_label',
      ),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'name', 'server_label', 'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'mcp';

  /// Canonical `name` field (omission, null and value remain distinct).
  final String? name;

  /// Whether `name` is present, including an explicit null.
  final bool hasName;

  /// Canonical `server_label` field.
  final String serverLabel;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    if (name != null) {}
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveMCPToolChoice copyWith({
    Object? name = liveUnset,

    bool? hasName,

    String? serverLabel,

    Map<String, dynamic>? rawJson,
  }) => LiveMCPToolChoice(
    name: _copyLiveNullable(name, this.name, this.hasName, hasName),

    serverLabel: serverLabel ?? this.serverLabel,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasName) 'name': name,

    'server_label': serverLabel,

    'type': type,
  });
}

/// Canonical `LiveSpecificCustomToolParam` object with finite immutable open extras.
final class LiveSpecificCustomTool extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificCustomTool({
    required this.name,

    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotLiveJson(
         rawJson,
         'LiveSpecificCustomTool',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificCustomTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'custom', 'LiveSpecificCustomTool');

    return LiveSpecificCustomTool(
      name: requireLiveString(json['name'], 'LiveSpecificCustomTool.name'),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'name', 'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'custom';

  /// Canonical `name` field.
  final String name;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificCustomTool copyWith({
    String? name,

    Map<String, dynamic>? rawJson,
  }) => LiveSpecificCustomTool(
    name: name ?? this.name,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'name': name, 'type': type});
}

/// Canonical `LiveAllowedToolsChoiceParam` object with finite immutable open extras.
final class LiveAllowedToolsChoice extends LiveToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveAllowedToolsChoice({
    Object? mode = liveUnset,

    required List<LiveSpecificToolChoice> tools,

    Map<String, dynamic> rawJson = const {},
  }) : mode = _liveNullable<LiveToolChoiceValueEnum>(
         mode,
         'LiveAllowedToolsChoice.mode',
         _liveTyped<LiveToolChoiceValueEnum>,
       ),
       tools = _liveTypedList<LiveSpecificToolChoice>(
         tools,
         'LiveAllowedToolsChoice.tools',
       ),
       hasMode = !identical(mode, liveUnset),
       rawJson = snapshotLiveJson(
         rawJson,
         'LiveAllowedToolsChoice',
         knownKeys: _knownKeys,
       ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveAllowedToolsChoice.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'allowed_tools', 'LiveAllowedToolsChoice');

    return LiveAllowedToolsChoice(
      mode: json.containsKey('mode')
          ? optionalLiveValue<LiveToolChoiceValueEnum>(
              json,
              'mode',
              'LiveAllowedToolsChoice',
              (value, context) => _readLiveEnum(
                value,
                context,
                LiveToolChoiceValueEnum.fromJson,
              ),
              nullable: true,
            )
          : liveUnset,

      tools: _readLiveModels(
        json['tools'],
        'LiveAllowedToolsChoice.tools',
        LiveSpecificToolChoice.fromJson,
      ),

      rawJson: json,
    );
  }

  static const Set<String> _knownKeys = {'mode', 'tools', 'type'};

  /// Canonical fixed `type` value.
  String get type => 'allowed_tools';

  /// Canonical `mode` field (omission, null and value remain distinct).
  final LiveToolChoiceValueEnum? mode;

  /// Whether `mode` is present, including an explicit null.
  final bool hasMode;

  /// Canonical `tools` field.
  final List<LiveSpecificToolChoice> tools;

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {
    if (mode != null) {}

    _validateLiveListLength(
      tools,
      'LiveAllowedToolsChoice.tools',
      min: 1,
      max: 128,
    );

    for (final value in tools) {
      value.validate();
    }
  }

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveAllowedToolsChoice copyWith({
    Object? mode = liveUnset,

    bool? hasMode,

    List<LiveSpecificToolChoice>? tools,

    Map<String, dynamic>? rawJson,
  }) => LiveAllowedToolsChoice(
    mode: _copyLiveNullable(mode, this.mode, this.hasMode, hasMode),

    tools: tools ?? this.tools,

    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> toJson() => mergeLiveJson(rawJson, _knownKeys, {
    if (hasMode) 'mode': mode?.toJson(),

    'tools': tools.map((value) => value.toJson()).toList(),

    'type': type,
  });
}

/// Canonical `LiveSpecificApplyPatchParam` object with finite immutable open extras.
final class LiveSpecificApplyPatch extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificApplyPatch({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificApplyPatch',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificApplyPatch.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'apply_patch', 'LiveSpecificApplyPatch');

    return LiveSpecificApplyPatch(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'apply_patch';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificApplyPatch copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificApplyPatch(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificCodeInterpreterParam` object with finite immutable open extras.
final class LiveSpecificCodeInterpreter extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificCodeInterpreter({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificCodeInterpreter',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificCodeInterpreter.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'code_interpreter', 'LiveSpecificCodeInterpreter');

    return LiveSpecificCodeInterpreter(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'code_interpreter';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificCodeInterpreter copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificCodeInterpreter(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificComputerParam` object with finite immutable open extras.
final class LiveSpecificComputer extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificComputer({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificComputer',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificComputer.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'computer', 'LiveSpecificComputer');

    return LiveSpecificComputer(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'computer';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificComputer copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificComputer(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificFileSearchParam` object with finite immutable open extras.
final class LiveSpecificFileSearch extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificFileSearch({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificFileSearch',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificFileSearch.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'file_search', 'LiveSpecificFileSearch');

    return LiveSpecificFileSearch(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'file_search';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificFileSearch copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificFileSearch(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificFunctionShellParam` object with finite immutable open extras.
final class LiveSpecificFunctionShell extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificFunctionShell({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificFunctionShell',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificFunctionShell.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'shell', 'LiveSpecificFunctionShell');

    return LiveSpecificFunctionShell(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'shell';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificFunctionShell copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificFunctionShell(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificImageGenParam` object with finite immutable open extras.
final class LiveSpecificImageGen extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificImageGen({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificImageGen',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificImageGen.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'image_generation', 'LiveSpecificImageGen');

    return LiveSpecificImageGen(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'image_generation';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificImageGen copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificImageGen(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificProgrammaticToolCallingParam` object with finite immutable open extras.
final class LiveSpecificProgrammaticToolCalling extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificProgrammaticToolCalling({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificProgrammaticToolCalling',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificProgrammaticToolCalling.fromJson(
    Map<String, dynamic> json,
  ) {
    requireLiveType(
      json,
      'programmatic_tool_calling',
      'LiveSpecificProgrammaticToolCalling',
    );

    return LiveSpecificProgrammaticToolCalling(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'programmatic_tool_calling';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificProgrammaticToolCalling copyWith({
    Map<String, dynamic>? rawJson,
  }) => LiveSpecificProgrammaticToolCalling(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificWebSearchParam` object with finite immutable open extras.
final class LiveSpecificWebSearch extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificWebSearch({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificWebSearch',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificWebSearch.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'web_search', 'LiveSpecificWebSearch');

    return LiveSpecificWebSearch(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'web_search';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificWebSearch copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificWebSearch(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

/// Canonical `LiveSpecificWebSearchPreviewParam` object with finite immutable open extras.
final class LiveSpecificWebSearchPreview extends LiveSpecificToolChoice {
  /// Creates the canonical object; typed fields override stale known raw keys.
  LiveSpecificWebSearchPreview({Map<String, dynamic> rawJson = const {}})
    : rawJson = snapshotLiveJson(
        rawJson,
        'LiveSpecificWebSearchPreview',
        knownKeys: _knownKeys,
      ) {
    validate();
  }

  /// Parses strict declared fields while retaining finite future fields.
  factory LiveSpecificWebSearchPreview.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'web_search_preview', 'LiveSpecificWebSearchPreview');

    return LiveSpecificWebSearchPreview(rawJson: json);
  }

  static const Set<String> _knownKeys = {'type'};

  /// Canonical fixed `type` value.
  @override
  String get type => 'web_search_preview';

  /// Deeply immutable complete source JSON; typed fields govern serialization.
  final Map<String, dynamic> rawJson;

  @override
  void validate() {}

  /// Copies fields; null clears nullable fields and `hasField: false` omits them.
  LiveSpecificWebSearchPreview copyWith({Map<String, dynamic>? rawJson}) =>
      LiveSpecificWebSearchPreview(rawJson: rawJson ?? this.rawJson);

  @override
  Map<String, dynamic> toJson() =>
      mergeLiveJson(rawJson, _knownKeys, {'type': type});
}

T? _liveNullable<T>(
  Object? value,
  String context,
  T Function(Object?, String) parser,
) => identical(value, liveUnset) || value == null
    ? null
    : parser(value, context);

T _liveTyped<T>(Object? value, String context) {
  if (value is! T) {
    throw FormatException('$context: expected the canonical typed value');
  }
  return value;
}

List<T> _liveTypedList<T>(Object? value, String context) {
  final array = requireLiveList(value, context);
  return List<T>.unmodifiable([
    for (var index = 0; index < array.length; index++)
      _liveTyped<T>(array[index], '$context[$index]'),
  ]);
}

List<String> _liveStrings(Object? value, String context) {
  final array = requireLiveList(value, context);
  return List<String>.unmodifiable([
    for (var index = 0; index < array.length; index++)
      requireLiveString(array[index], '$context[$index]'),
  ]);
}

Map<String, dynamic> _liveParameters(Object? value, String context) =>
    snapshotLiveJson(requireLiveObject(value, context), context);

T _readLiveModel<T>(
  Object? value,
  String context,
  T Function(Map<String, dynamic>) parser,
) {
  final object = requireLiveObject(value, context);
  try {
    return parser(object);
  } on FormatException catch (error) {
    throw FormatException('$context: ${error.message}');
  }
}

List<T> _readLiveModels<T>(
  Object? value,
  String context,
  T Function(Map<String, dynamic>) parser,
) {
  final array = requireLiveList(value, context);
  return List<T>.unmodifiable([
    for (var index = 0; index < array.length; index++)
      _readLiveModel(array[index], '$context[$index]', parser),
  ]);
}

void _validateLiveListLength(
  List<Object?> values,
  String context, {
  int? min,
  int? max,
}) {
  if ((min != null && values.length < min) ||
      (max != null && values.length > max)) {
    throw FormatException('$context: invalid array length');
  }
}

Object? _copyLiveNullable(
  Object? update,
  Object? current,
  bool present,
  bool? has,
) {
  if (has == false) return liveUnset;
  if (!identical(update, liveUnset)) return update;
  return has == true || present ? current : liveUnset;
}

T _readLiveEnum<T>(Object? value, String context, T Function(Object?) parser) {
  try {
    return parser(value);
  } on FormatException catch (error) {
    throw FormatException('$context: ${error.message}');
  }
}
