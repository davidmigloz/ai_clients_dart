part of 'agent_session_models.dart';

/// Desktop configuration for an OpenAI-hosted environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionDesktopConfig extends AgentJsonModel {
  /// Creates a validated [AgentSessionDesktopConfig].
  AgentSessionDesktopConfig({required this.enabled}) {
    validate();
  }

  /// Whether to provision the desktop and its browser proxy.
  final bool enabled;

  /// Parses [AgentSessionDesktopConfig] with contextual, payload-free errors.
  factory AgentSessionDesktopConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'enabled',
    ], 'AgentSessionDesktopConfig');
    return AgentSessionDesktopConfig(
      enabled: requiredAgentValue(
        json,
        'enabled',
        'AgentSessionDesktopConfig.enabled',
        requireAgentBool,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'enabled': enabled};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionDesktopConfig copyWith({bool? enabled}) =>
      AgentSessionDesktopConfig(enabled: enabled ?? this.enabled);
}

/// The effective desktop configuration for an OpenAI-hosted environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionDesktopResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionDesktopResource].
  AgentSessionDesktopResource({
    required this.enabled,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'enabled',
       ], 'AgentSessionDesktopResource') {
    validate();
  }

  /// Whether the environment provisions a desktop and browser proxy.
  final bool enabled;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionDesktopResource] with contextual, payload-free errors.
  factory AgentSessionDesktopResource.fromJson(Map<String, dynamic> json) {
    return AgentSessionDesktopResource(
      enabled: requiredAgentValue(
        json,
        'enabled',
        'AgentSessionDesktopResource.enabled',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['enabled'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'enabled': enabled};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionDesktopResource copyWith({
    bool? enabled,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionDesktopResource(
    enabled: enabled ?? this.enabled,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Packages to install in an OpenAI-hosted environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionEnvironmentPackagesConfig extends AgentJsonModel {
  /// Creates a validated [AgentSessionEnvironmentPackagesConfig].
  AgentSessionEnvironmentPackagesConfig({
    List<String>? npm,
    bool clearNpm = false,
    List<String>? python,
    bool clearPython = false,
    List<String>? system,
    bool clearSystem = false,
  }) : clearNpm = clearNpm,
       npm = ownAgentValue<List<String>>(
         clearNpm ? null : npm,
         List.unmodifiable,
       ),
       clearPython = clearPython,
       python = ownAgentValue<List<String>>(
         clearPython ? null : python,
         List.unmodifiable,
       ),
       clearSystem = clearSystem,
       system = ownAgentValue<List<String>>(
         clearSystem ? null : system,
         List.unmodifiable,
       ) {
    validate();
  }

  /// npm packages to install globally. Defaults to an empty list.
  final List<String>? npm;

  /// Sends `npm: null`, rather than omitting it.
  final bool clearNpm;

  /// Python packages to install. Defaults to an empty list.
  final List<String>? python;

  /// Sends `python: null`, rather than omitting it.
  final bool clearPython;

  /// System packages to install. Defaults to an empty list.
  final List<String>? system;

  /// Sends `system: null`, rather than omitting it.
  final bool clearSystem;

  /// Parses [AgentSessionEnvironmentPackagesConfig] with contextual, payload-free errors.
  factory AgentSessionEnvironmentPackagesConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'npm',
      'python',
      'system',
    ], 'AgentSessionEnvironmentPackagesConfig');
    return AgentSessionEnvironmentPackagesConfig(
      npm: optionalAgentValue(
        json,
        'npm',
        'AgentSessionEnvironmentPackagesConfig.npm',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearNpm: json.containsKey('npm') && json['npm'] == null,
      python: optionalAgentValue(
        json,
        'python',
        'AgentSessionEnvironmentPackagesConfig.python',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearPython: json.containsKey('python') && json['python'] == null,
      system: optionalAgentValue(
        json,
        'system',
        'AgentSessionEnvironmentPackagesConfig.system',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearSystem: json.containsKey('system') && json['system'] == null,
    );
  }
  @override
  void validate() {
    if (npm != null) {
      validateAgentCount(
        npm!.length,
        'AgentSessionEnvironmentPackagesConfig.npm',
        min: 0,
        max: 16384,
      );
      for (final item in npm!) {
        validateAgentLength(
          item,
          'AgentSessionEnvironmentPackagesConfig.npm',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (python != null) {
      validateAgentCount(
        python!.length,
        'AgentSessionEnvironmentPackagesConfig.python',
        min: 0,
        max: 16384,
      );
      for (final item in python!) {
        validateAgentLength(
          item,
          'AgentSessionEnvironmentPackagesConfig.python',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (system != null) {
      validateAgentCount(
        system!.length,
        'AgentSessionEnvironmentPackagesConfig.system',
        min: 0,
        max: 16384,
      );
      for (final item in system!) {
        validateAgentLength(
          item,
          'AgentSessionEnvironmentPackagesConfig.system',
          min: 0,
          max: 1048576,
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearNpm)
      'npm': null
    else if (npm != null)
      'npm': npm!.map((value) => value).toList(),
    if (clearPython)
      'python': null
    else if (python != null)
      'python': python!.map((value) => value).toList(),
    if (clearSystem)
      'system': null
    else if (system != null)
      'system': system!.map((value) => value).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentPackagesConfig copyWith({
    Object? npm = unsetCopyWithValue,
    bool? clearNpm,
    Object? python = unsetCopyWithValue,
    bool? clearPython,
    Object? system = unsetCopyWithValue,
    bool? clearSystem,
  }) => AgentSessionEnvironmentPackagesConfig(
    npm: copyAgentValue<List<String>>(
      npm,
      this.npm,
      'AgentSessionEnvironmentPackagesConfig.npm',
    ),
    clearNpm:
        clearNpm ??
        (identical(npm, unsetCopyWithValue) ? this.clearNpm : npm == null),
    python: copyAgentValue<List<String>>(
      python,
      this.python,
      'AgentSessionEnvironmentPackagesConfig.python',
    ),
    clearPython:
        clearPython ??
        (identical(python, unsetCopyWithValue)
            ? this.clearPython
            : python == null),
    system: copyAgentValue<List<String>>(
      system,
      this.system,
      'AgentSessionEnvironmentPackagesConfig.system',
    ),
    clearSystem:
        clearSystem ??
        (identical(system, unsetCopyWithValue)
            ? this.clearSystem
            : system == null),
  );
}

/// Packages installed in an OpenAI-hosted environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionEnvironmentPackagesResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionEnvironmentPackagesResource].
  AgentSessionEnvironmentPackagesResource({
    required List<String> npm,
    required List<String> python,
    required List<String> system,
    Map<String, dynamic> rawJson = const {},
  }) : npm = List.unmodifiable(npm),
       python = List.unmodifiable(python),
       system = List.unmodifiable(system),
       rawJson = agentExtras(rawJson, const [
         'npm',
         'python',
         'system',
       ], 'AgentSessionEnvironmentPackagesResource') {
    validate();
  }

  /// npm packages installed globally in the environment.
  final List<String> npm;

  /// Python packages installed in the environment.
  final List<String> python;

  /// System packages installed in the environment.
  final List<String> system;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionEnvironmentPackagesResource] with contextual, payload-free errors.
  factory AgentSessionEnvironmentPackagesResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionEnvironmentPackagesResource(
      npm: requiredAgentValue(
        json,
        'npm',
        'AgentSessionEnvironmentPackagesResource.npm',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      python: requiredAgentValue(
        json,
        'python',
        'AgentSessionEnvironmentPackagesResource.python',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      system: requiredAgentValue(
        json,
        'system',
        'AgentSessionEnvironmentPackagesResource.system',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['npm', 'python', 'system'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      npm.length,
      'AgentSessionEnvironmentPackagesResource.npm',
      min: 0,
      max: 16384,
    );
    for (final item in npm) {
      validateAgentLength(
        item,
        'AgentSessionEnvironmentPackagesResource.npm',
        min: 0,
        max: 1048576,
      );
    }
    validateAgentCount(
      python.length,
      'AgentSessionEnvironmentPackagesResource.python',
      min: 0,
      max: 16384,
    );
    for (final item in python) {
      validateAgentLength(
        item,
        'AgentSessionEnvironmentPackagesResource.python',
        min: 0,
        max: 1048576,
      );
    }
    validateAgentCount(
      system.length,
      'AgentSessionEnvironmentPackagesResource.system',
      min: 0,
      max: 16384,
    );
    for (final item in system) {
      validateAgentLength(
        item,
        'AgentSessionEnvironmentPackagesResource.system',
        min: 0,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'npm': npm.map((value) => value).toList(),
    'python': python.map((value) => value).toList(),
    'system': system.map((value) => value).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionEnvironmentPackagesResource copyWith({
    List<String>? npm,
    List<String>? python,
    List<String>? system,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentPackagesResource(
    npm: npm ?? this.npm,
    python: python ?? this.python,
    system: system ?? this.system,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The execution environment and optional reusable template for a session.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionEnvironment extends AgentJsonModel {
  const AgentSessionEnvironment();

  /// Parses a known contract or detached future received value.
  factory AgentSessionEnvironment.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionEnvironment.type',
    )) {
      'none' => AgentSessionNoneEnvironment.fromJson(json),
      'openai_hosted' => AgentSessionHostedEnvironment.fromJson(json),
      'self_hosted' => AgentSessionSelfHostedEnvironment.fromJson(json),
      _ => UnknownAgentSessionEnvironment.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `none` contract.
  factory AgentSessionEnvironment.none() = AgentSessionNoneEnvironment;

  /// Builds the `openai_hosted` contract.
  factory AgentSessionEnvironment.openaiHosted({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories,
    AgentSessionContainerSizeConfig? containerSize,
    AgentSessionDesktopConfig? desktop,
    bool clearDesktop,
    Map<String, String>? env,
    bool clearEnv,
    String? environmentId,
    String? environmentTemplateId,
    List<AgentSessionHostedEnvironmentFileConfig>? files,
    bool clearFiles,
    AgentSessionNetworkPolicyConfig? network,
    bool clearNetwork,
    AgentSessionEnvironmentPackagesConfig? packages,
    bool clearPackages,
    List<AgentSessionHostedPluginConfig>? plugins,
    bool clearPlugins,
    List<AgentSessionSetupCommandConfig>? setupCommands,
    bool clearSetupCommands,
    List<AgentSessionHostedSkillConfig>? skills,
    bool clearSkills,
  }) = AgentSessionHostedEnvironment;

  /// Builds the `self_hosted` contract.
  factory AgentSessionEnvironment.selfHosted({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories,
    required String workspaceDirectory,
  }) = AgentSessionSelfHostedEnvironment;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionEnvironment extends AgentSessionEnvironment {
  const UnknownAgentSessionEnvironment._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionEnvironment.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionEnvironment.type',
    );
    if (const ['none', 'openai_hosted', 'self_hosted'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionEnvironment: expected a future discriminator',
      );
    }
    return UnknownAgentSessionEnvironment._(
      snapshotAgentJson(json, 'UnknownAgentSessionEnvironment'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionEnvironment copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionEnvironment.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionEnvironment: future input is not writable',
  );
}

/// Runs the agent without an execution environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionNoneEnvironment extends AgentSessionEnvironment {
  /// Creates a validated [AgentSessionNoneEnvironment].
  AgentSessionNoneEnvironment() {
    validate();
  }

  /// The type of the object. Always `none`.
  @override
  String get type => 'none';

  /// Parses [AgentSessionNoneEnvironment] with contextual, payload-free errors.
  factory AgentSessionNoneEnvironment.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const ['type'], 'AgentSessionNoneEnvironment');
    requireAgentTag(json, 'type', 'none', 'AgentSessionNoneEnvironment');
    return AgentSessionNoneEnvironment();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionNoneEnvironment copyWith() => AgentSessionNoneEnvironment();
}

/// An existing OpenAI-hosted environment or new inline/template-based hosted configuration.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionHostedEnvironment extends AgentSessionEnvironment {
  /// Creates a validated [AgentSessionHostedEnvironment].
  AgentSessionHostedEnvironment({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories = false,
    this.containerSize,
    AgentSessionDesktopConfig? desktop,
    bool clearDesktop = false,
    Map<String, String>? env,
    bool clearEnv = false,
    this.environmentId,
    this.environmentTemplateId,
    List<AgentSessionHostedEnvironmentFileConfig>? files,
    bool clearFiles = false,
    AgentSessionNetworkPolicyConfig? network,
    bool clearNetwork = false,
    AgentSessionEnvironmentPackagesConfig? packages,
    bool clearPackages = false,
    List<AgentSessionHostedPluginConfig>? plugins,
    bool clearPlugins = false,
    List<AgentSessionSetupCommandConfig>? setupCommands,
    bool clearSetupCommands = false,
    List<AgentSessionHostedSkillConfig>? skills,
    bool clearSkills = false,
  }) : clearCapabilityDirectories = clearCapabilityDirectories,
       capabilityDirectories = ownAgentValue<List<String>>(
         clearCapabilityDirectories ? null : capabilityDirectories,
         List.unmodifiable,
       ),
       clearDesktop = clearDesktop,
       desktop = clearDesktop ? null : desktop,
       clearEnv = clearEnv,
       env = ownAgentValue<Map<String, String>>(
         clearEnv ? null : env,
         Map<String, String>.unmodifiable,
       ),
       clearFiles = clearFiles,
       files = ownAgentValue<List<AgentSessionHostedEnvironmentFileConfig>>(
         clearFiles ? null : files,
         List.unmodifiable,
       ),
       clearNetwork = clearNetwork,
       network = clearNetwork ? null : network,
       clearPackages = clearPackages,
       packages = clearPackages ? null : packages,
       clearPlugins = clearPlugins,
       plugins = ownAgentValue<List<AgentSessionHostedPluginConfig>>(
         clearPlugins ? null : plugins,
         List.unmodifiable,
       ),
       clearSetupCommands = clearSetupCommands,
       setupCommands = ownAgentValue<List<AgentSessionSetupCommandConfig>>(
         clearSetupCommands ? null : setupCommands,
         List.unmodifiable,
       ),
       clearSkills = clearSkills,
       skills = ownAgentValue<List<AgentSessionHostedSkillConfig>>(
         clearSkills ? null : skills,
         List.unmodifiable,
       ) {
    validate();
  }

  /// Directories that contain capabilities exposed to the agent. Defaults to an empty list.
  final List<String>? capabilityDirectories;

  /// Sends `capability_directories: null`, rather than omitting it.
  final bool clearCapabilityDirectories;

  /// The hosted container size. Omission selects the medium tier.
  final AgentSessionContainerSizeConfig? containerSize;

  /// Desktop provisioning. Omission or null inherits the template setting, or defaults to disabled.
  final AgentSessionDesktopConfig? desktop;

  /// Sends `desktop: null`, rather than omitting it.
  final bool clearDesktop;

  /// Environment variables made available to the agent.
  final Map<String, String>? env;

  /// Sends `env: null`, rather than omitting it.
  final bool clearEnv;

  /// An existing prewarmed environment. Cannot be combined with a template or inline configuration.
  final String? environmentId;

  /// A reusable hosted template applied before inline session configuration. Omitted fields inherit the template; network overrides cannot broaden its policy.
  final String? environmentTemplateId;

  /// Files available before the agent starts. Defaults to an empty list.
  final List<AgentSessionHostedEnvironmentFileConfig>? files;

  /// Sends `files: null`, rather than omitting it.
  final bool clearFiles;

  /// Network access policy for the environment. If omitted, the API version determines whether network access is enabled or disabled.
  final AgentSessionNetworkPolicyConfig? network;

  /// Sends `network: null`, rather than omitting it.
  final bool clearNetwork;

  /// Packages to install in the environment. Defaults to empty package lists.
  final AgentSessionEnvironmentPackagesConfig? packages;

  /// Sends `packages: null`, rather than omitting it.
  final bool clearPackages;

  /// Plugins provided as inline ZIP archives. Defaults to an empty list.
  final List<AgentSessionHostedPluginConfig>? plugins;

  /// Sends `plugins: null`, rather than omitting it.
  final bool clearPlugins;

  /// Ordered, confidential setup commands. Command bodies are never returned.
  final List<AgentSessionSetupCommandConfig>? setupCommands;

  /// Sends `setup_commands: null`, rather than omitting it.
  final bool clearSetupCommands;

  /// Skills referenced by ID or provided as inline ZIP archives. Defaults to an empty list.
  final List<AgentSessionHostedSkillConfig>? skills;

  /// Sends `skills: null`, rather than omitting it.
  final bool clearSkills;

  /// The type of the object. Always `openai_hosted`.
  @override
  String get type => 'openai_hosted';

  /// Parses [AgentSessionHostedEnvironment] with contextual, payload-free errors.
  factory AgentSessionHostedEnvironment.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'capability_directories',
      'container_size',
      'desktop',
      'env',
      'environment_id',
      'environment_template_id',
      'files',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
      'type',
    ], 'AgentSessionHostedEnvironment');
    requireAgentTag(
      json,
      'type',
      'openai_hosted',
      'AgentSessionHostedEnvironment',
    );
    return AgentSessionHostedEnvironment(
      capabilityDirectories: optionalAgentValue(
        json,
        'capability_directories',
        'AgentSessionHostedEnvironment.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearCapabilityDirectories:
          json.containsKey('capability_directories') &&
          json['capability_directories'] == null,
      containerSize: optionalAgentValue(
        json,
        'container_size',
        'AgentSessionHostedEnvironment.containerSize',
        (value, context) => AgentSessionContainerSizeConfig.fromJson(value),
        nullable: false,
      ),
      desktop: optionalAgentValue(
        json,
        'desktop',
        'AgentSessionHostedEnvironment.desktop',
        (value, context) => AgentSessionDesktopConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearDesktop: json.containsKey('desktop') && json['desktop'] == null,
      env: optionalAgentValue(
        json,
        'env',
        'AgentSessionHostedEnvironment.env',
        requireAgentStringMap,
        nullable: true,
      ),
      clearEnv: json.containsKey('env') && json['env'] == null,
      environmentId: optionalAgentValue(
        json,
        'environment_id',
        'AgentSessionHostedEnvironment.environmentId',
        requireAgentString,
        nullable: false,
      ),
      environmentTemplateId: optionalAgentValue(
        json,
        'environment_template_id',
        'AgentSessionHostedEnvironment.environmentTemplateId',
        requireAgentString,
        nullable: false,
      ),
      files: optionalAgentValue(
        json,
        'files',
        'AgentSessionHostedEnvironment.files',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionHostedEnvironmentFileConfig.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      clearFiles: json.containsKey('files') && json['files'] == null,
      network: optionalAgentValue(
        json,
        'network',
        'AgentSessionHostedEnvironment.network',
        (value, context) => AgentSessionNetworkPolicyConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearNetwork: json.containsKey('network') && json['network'] == null,
      packages: optionalAgentValue(
        json,
        'packages',
        'AgentSessionHostedEnvironment.packages',
        (value, context) => AgentSessionEnvironmentPackagesConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearPackages: json.containsKey('packages') && json['packages'] == null,
      plugins: optionalAgentValue(
        json,
        'plugins',
        'AgentSessionHostedEnvironment.plugins',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionHostedPluginConfig.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      clearPlugins: json.containsKey('plugins') && json['plugins'] == null,
      setupCommands: optionalAgentValue(
        json,
        'setup_commands',
        'AgentSessionHostedEnvironment.setupCommands',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionSetupCommandConfig.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      clearSetupCommands:
          json.containsKey('setup_commands') && json['setup_commands'] == null,
      skills: optionalAgentValue(
        json,
        'skills',
        'AgentSessionHostedEnvironment.skills',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionHostedSkillConfig.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: true,
      ),
      clearSkills: json.containsKey('skills') && json['skills'] == null,
    );
  }
  @override
  void validate() {
    if (environmentId != null &&
        toJson().keys.any((key) => key != 'type' && key != 'environment_id')) {
      throw const FormatException(
        'Hosted environment ID excludes all inline and template fields',
      );
    }
    if (capabilityDirectories != null) {
      validateAgentCount(
        capabilityDirectories!.length,
        'AgentSessionHostedEnvironment.capabilityDirectories',
        min: 0,
        max: 16384,
      );
      for (final item in capabilityDirectories!) {
        validateAgentLength(
          item,
          'AgentSessionHostedEnvironment.capabilityDirectories',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (containerSize != null) {
      validateAgentEnum(containerSize!.value, [
        'small',
        'medium',
        'large',
      ], 'AgentSessionHostedEnvironment.containerSize');
    }
    if (desktop != null) {
      desktop!.validate();
    }
    if (env != null) {
      validateAgentCount(
        env!.length,
        'AgentSessionHostedEnvironment.env',
        min: 0,
        max: 1024,
      );
      for (final key in env!.keys) {
        validateAgentLength(
          key,
          'AgentSessionHostedEnvironment.env',
          min: 1,
          max: 256,
        );
      }
      for (final item in env!.values) {
        validateAgentLength(
          item,
          'AgentSessionHostedEnvironment.env',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (environmentId != null) {
      validateAgentLength(
        environmentId!,
        'AgentSessionHostedEnvironment.environmentId',
        min: 9,
        max: 256,
      );
    }
    if (environmentTemplateId != null) {
      validateAgentLength(
        environmentTemplateId!,
        'AgentSessionHostedEnvironment.environmentTemplateId',
        min: 0,
        max: 64,
      );
    }
    if (files != null) {
      validateAgentCount(
        files!.length,
        'AgentSessionHostedEnvironment.files',
        min: 0,
        max: 50,
      );
      for (final item in files!) {
        item.validate();
      }
    }
    if (network != null) {
      network!.validate();
    }
    if (packages != null) {
      packages!.validate();
    }
    if (plugins != null) {
      validateAgentCount(
        plugins!.length,
        'AgentSessionHostedEnvironment.plugins',
        min: 0,
        max: 32,
      );
      for (final item in plugins!) {
        item.validate();
      }
    }
    if (setupCommands != null) {
      validateAgentCount(
        setupCommands!.length,
        'AgentSessionHostedEnvironment.setupCommands',
        min: 0,
        max: 16,
      );
      for (final item in setupCommands!) {
        item.validate();
      }
    }
    if (skills != null) {
      validateAgentCount(
        skills!.length,
        'AgentSessionHostedEnvironment.skills',
        min: 0,
        max: 200,
      );
      for (final item in skills!) {
        item.validate();
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearCapabilityDirectories)
      'capability_directories': null
    else if (capabilityDirectories != null)
      'capability_directories': capabilityDirectories!
          .map((value) => value)
          .toList(),
    if (containerSize != null) 'container_size': containerSize!.toJson(),
    if (clearDesktop)
      'desktop': null
    else if (desktop != null)
      'desktop': desktop!.toJson(),
    if (clearEnv) 'env': null else 'env': ?env,
    'environment_id': ?environmentId,
    'environment_template_id': ?environmentTemplateId,
    if (clearFiles)
      'files': null
    else if (files != null)
      'files': files!.map((value) => value.toJson()).toList(),
    if (clearNetwork)
      'network': null
    else if (network != null)
      'network': network!.toJson(),
    if (clearPackages)
      'packages': null
    else if (packages != null)
      'packages': packages!.toJson(),
    if (clearPlugins)
      'plugins': null
    else if (plugins != null)
      'plugins': plugins!.map((value) => value.toJson()).toList(),
    if (clearSetupCommands)
      'setup_commands': null
    else if (setupCommands != null)
      'setup_commands': setupCommands!.map((value) => value.toJson()).toList(),
    if (clearSkills)
      'skills': null
    else if (skills != null)
      'skills': skills!.map((value) => value.toJson()).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedEnvironment copyWith({
    Object? capabilityDirectories = unsetCopyWithValue,
    bool? clearCapabilityDirectories,
    Object? containerSize = unsetCopyWithValue,
    Object? desktop = unsetCopyWithValue,
    bool? clearDesktop,
    Object? env = unsetCopyWithValue,
    bool? clearEnv,
    Object? environmentId = unsetCopyWithValue,
    Object? environmentTemplateId = unsetCopyWithValue,
    Object? files = unsetCopyWithValue,
    bool? clearFiles,
    Object? network = unsetCopyWithValue,
    bool? clearNetwork,
    Object? packages = unsetCopyWithValue,
    bool? clearPackages,
    Object? plugins = unsetCopyWithValue,
    bool? clearPlugins,
    Object? setupCommands = unsetCopyWithValue,
    bool? clearSetupCommands,
    Object? skills = unsetCopyWithValue,
    bool? clearSkills,
  }) => AgentSessionHostedEnvironment(
    capabilityDirectories: copyAgentValue<List<String>>(
      capabilityDirectories,
      this.capabilityDirectories,
      'AgentSessionHostedEnvironment.capabilityDirectories',
    ),
    clearCapabilityDirectories:
        clearCapabilityDirectories ??
        (identical(capabilityDirectories, unsetCopyWithValue)
            ? this.clearCapabilityDirectories
            : capabilityDirectories == null),
    containerSize: copyAgentValue<AgentSessionContainerSizeConfig>(
      containerSize,
      this.containerSize,
      'AgentSessionHostedEnvironment.containerSize',
    ),
    desktop: copyAgentValue<AgentSessionDesktopConfig>(
      desktop,
      this.desktop,
      'AgentSessionHostedEnvironment.desktop',
    ),
    clearDesktop:
        clearDesktop ??
        (identical(desktop, unsetCopyWithValue)
            ? this.clearDesktop
            : desktop == null),
    env: copyAgentValue<Map<String, String>>(
      env,
      this.env,
      'AgentSessionHostedEnvironment.env',
    ),
    clearEnv:
        clearEnv ??
        (identical(env, unsetCopyWithValue) ? this.clearEnv : env == null),
    environmentId: copyAgentValue<String>(
      environmentId,
      this.environmentId,
      'AgentSessionHostedEnvironment.environmentId',
    ),
    environmentTemplateId: copyAgentValue<String>(
      environmentTemplateId,
      this.environmentTemplateId,
      'AgentSessionHostedEnvironment.environmentTemplateId',
    ),
    files: copyAgentValue<List<AgentSessionHostedEnvironmentFileConfig>>(
      files,
      this.files,
      'AgentSessionHostedEnvironment.files',
    ),
    clearFiles:
        clearFiles ??
        (identical(files, unsetCopyWithValue)
            ? this.clearFiles
            : files == null),
    network: copyAgentValue<AgentSessionNetworkPolicyConfig>(
      network,
      this.network,
      'AgentSessionHostedEnvironment.network',
    ),
    clearNetwork:
        clearNetwork ??
        (identical(network, unsetCopyWithValue)
            ? this.clearNetwork
            : network == null),
    packages: copyAgentValue<AgentSessionEnvironmentPackagesConfig>(
      packages,
      this.packages,
      'AgentSessionHostedEnvironment.packages',
    ),
    clearPackages:
        clearPackages ??
        (identical(packages, unsetCopyWithValue)
            ? this.clearPackages
            : packages == null),
    plugins: copyAgentValue<List<AgentSessionHostedPluginConfig>>(
      plugins,
      this.plugins,
      'AgentSessionHostedEnvironment.plugins',
    ),
    clearPlugins:
        clearPlugins ??
        (identical(plugins, unsetCopyWithValue)
            ? this.clearPlugins
            : plugins == null),
    setupCommands: copyAgentValue<List<AgentSessionSetupCommandConfig>>(
      setupCommands,
      this.setupCommands,
      'AgentSessionHostedEnvironment.setupCommands',
    ),
    clearSetupCommands:
        clearSetupCommands ??
        (identical(setupCommands, unsetCopyWithValue)
            ? this.clearSetupCommands
            : setupCommands == null),
    skills: copyAgentValue<List<AgentSessionHostedSkillConfig>>(
      skills,
      this.skills,
      'AgentSessionHostedEnvironment.skills',
    ),
    clearSkills:
        clearSkills ??
        (identical(skills, unsetCopyWithValue)
            ? this.clearSkills
            : skills == null),
  );
}

/// An application-hosted environment configured inline.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionSelfHostedEnvironment extends AgentSessionEnvironment {
  /// Creates a validated [AgentSessionSelfHostedEnvironment].
  AgentSessionSelfHostedEnvironment({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories = false,
    required this.workspaceDirectory,
  }) : clearCapabilityDirectories = clearCapabilityDirectories,
       capabilityDirectories = ownAgentValue<List<String>>(
         clearCapabilityDirectories ? null : capabilityDirectories,
         List.unmodifiable,
       ) {
    validate();
  }

  /// Directories that contain capabilities exposed to the agent. Defaults to an empty list.
  final List<String>? capabilityDirectories;

  /// Sends `capability_directories: null`, rather than omitting it.
  final bool clearCapabilityDirectories;

  /// The type of the object. Always `self_hosted`.
  @override
  String get type => 'self_hosted';

  /// Absolute project directory inside the self-hosted environment.
  final String workspaceDirectory;

  /// Parses [AgentSessionSelfHostedEnvironment] with contextual, payload-free errors.
  factory AgentSessionSelfHostedEnvironment.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'capability_directories',
      'type',
      'workspace_directory',
    ], 'AgentSessionSelfHostedEnvironment');
    requireAgentTag(
      json,
      'type',
      'self_hosted',
      'AgentSessionSelfHostedEnvironment',
    );
    return AgentSessionSelfHostedEnvironment(
      capabilityDirectories: optionalAgentValue(
        json,
        'capability_directories',
        'AgentSessionSelfHostedEnvironment.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearCapabilityDirectories:
          json.containsKey('capability_directories') &&
          json['capability_directories'] == null,
      workspaceDirectory: requiredAgentValue(
        json,
        'workspace_directory',
        'AgentSessionSelfHostedEnvironment.workspaceDirectory',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateAgentSessionAbsolutePath(
      workspaceDirectory,
      'Self-hosted workspaceDirectory',
    );
    if (capabilityDirectories != null) {
      validateAgentCount(
        capabilityDirectories!.length,
        'AgentSessionSelfHostedEnvironment.capabilityDirectories',
        min: 0,
        max: 16384,
      );
      for (final item in capabilityDirectories!) {
        validateAgentLength(
          item,
          'AgentSessionSelfHostedEnvironment.capabilityDirectories',
          min: 0,
          max: 1048576,
        );
      }
    }
    validateAgentLength(
      workspaceDirectory,
      'AgentSessionSelfHostedEnvironment.workspaceDirectory',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearCapabilityDirectories)
      'capability_directories': null
    else if (capabilityDirectories != null)
      'capability_directories': capabilityDirectories!
          .map((value) => value)
          .toList(),
    'type': type,
    'workspace_directory': workspaceDirectory,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSelfHostedEnvironment copyWith({
    Object? capabilityDirectories = unsetCopyWithValue,
    bool? clearCapabilityDirectories,
    String? workspaceDirectory,
  }) => AgentSessionSelfHostedEnvironment(
    capabilityDirectories: copyAgentValue<List<String>>(
      capabilityDirectories,
      this.capabilityDirectories,
      'AgentSessionSelfHostedEnvironment.capabilityDirectories',
    ),
    clearCapabilityDirectories:
        clearCapabilityDirectories ??
        (identical(capabilityDirectories, unsetCopyWithValue)
            ? this.clearCapabilityDirectories
            : capabilityDirectories == null),
    workspaceDirectory: workspaceDirectory ?? this.workspaceDirectory,
  );
}

/// The execution environment for a session.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionEnvironmentResource extends AgentJsonModel {
  const AgentSessionEnvironmentResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionEnvironmentResource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionEnvironmentResource.type',
    )) {
      'none' => AgentSessionNoneEnvironmentResource.fromJson(json),
      'openai_hosted' => AgentSessionHostedEnvironmentResource.fromJson(json),
      'self_hosted' => AgentSessionSelfHostedEnvironmentResource.fromJson(json),
      _ => UnknownAgentSessionEnvironmentResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `none` contract.
  factory AgentSessionEnvironmentResource.none({Map<String, dynamic> rawJson}) =
      AgentSessionNoneEnvironmentResource;

  /// Builds the `openai_hosted` contract.
  factory AgentSessionEnvironmentResource.openaiHosted({
    required List<String> capabilityDirectories,
    AgentSessionContainerSizeResource? containerSize,
    bool clearContainerSize,
    required AgentSessionDesktopResource desktop,
    required List<AgentSessionHostedEnvironmentFileResource> files,
    required String id,
    required AgentSessionNetworkPolicyResource network,
    required AgentSessionEnvironmentPackagesResource packages,
    required List<AgentSessionHostedPluginResource> plugins,
    required List<AgentSessionHostedSkillResource> skills,
    Map<String, dynamic> rawJson,
  }) = AgentSessionHostedEnvironmentResource;

  /// Builds the `self_hosted` contract.
  factory AgentSessionEnvironmentResource.selfHosted({
    required List<String> capabilityDirectories,
    required String id,
    required String remoteUrl,
    required String workspaceDirectory,
    Map<String, dynamic> rawJson,
  }) = AgentSessionSelfHostedEnvironmentResource;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionEnvironmentResource
    extends AgentSessionEnvironmentResource {
  const UnknownAgentSessionEnvironmentResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionEnvironmentResource.type',
    );
    if (const ['none', 'openai_hosted', 'self_hosted'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionEnvironmentResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionEnvironmentResource._(
      snapshotAgentJson(json, 'UnknownAgentSessionEnvironmentResource'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionEnvironmentResource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      UnknownAgentSessionEnvironmentResource.fromJson(rawJson ?? this.rawJson);
}

/// The session talks to CCA without selecting or provisioning an execution environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionNoneEnvironmentResource
    extends AgentSessionEnvironmentResource {
  /// Creates a validated [AgentSessionNoneEnvironmentResource].
  AgentSessionNoneEnvironmentResource({Map<String, dynamic> rawJson = const {}})
    : rawJson = agentExtras(rawJson, const [
        'type',
      ], 'AgentSessionNoneEnvironmentResource') {
    validate();
  }

  /// The type of the object. Always `none`.
  @override
  String get type => 'none';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionNoneEnvironmentResource] with contextual, payload-free errors.
  factory AgentSessionNoneEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'none',
      'AgentSessionNoneEnvironmentResource',
    );
    return AgentSessionNoneEnvironmentResource(
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

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionNoneEnvironmentResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => AgentSessionNoneEnvironmentResource(rawJson: rawJson ?? this.rawJson);
}

/// An environment hosted by OpenAI.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionHostedEnvironmentResource
    extends AgentSessionEnvironmentResource {
  /// Creates a validated [AgentSessionHostedEnvironmentResource].
  AgentSessionHostedEnvironmentResource({
    required List<String> capabilityDirectories,
    AgentSessionContainerSizeResource? containerSize,
    bool clearContainerSize = false,
    required this.desktop,
    required List<AgentSessionHostedEnvironmentFileResource> files,
    required this.id,
    required this.network,
    required this.packages,
    required List<AgentSessionHostedPluginResource> plugins,
    required List<AgentSessionHostedSkillResource> skills,
    Map<String, dynamic> rawJson = const {},
  }) : capabilityDirectories = List.unmodifiable(capabilityDirectories),
       clearContainerSize = clearContainerSize,
       containerSize = clearContainerSize ? null : containerSize,
       files = List.unmodifiable(files),
       plugins = List.unmodifiable(plugins),
       skills = List.unmodifiable(skills),
       rawJson = agentExtras(rawJson, const [
         'capability_directories',
         'container_size',
         'desktop',
         'files',
         'id',
         'network',
         'packages',
         'plugins',
         'skills',
         'type',
       ], 'AgentSessionHostedEnvironmentResource') {
    validate();
  }

  /// Directories that contain capabilities exposed to the agent.
  final List<String> capabilityDirectories;

  /// The effective CPU and memory tier, or null when unknown or outside the public tiers.
  final AgentSessionContainerSizeResource? containerSize;

  /// Sends `container_size: null`, rather than omitting it.
  final bool clearContainerSize;

  /// The effective desktop configuration.
  final AgentSessionDesktopResource desktop;

  /// Files available in the environment, excluding their contents.
  final List<AgentSessionHostedEnvironmentFileResource> files;

  /// The public ID of the environment.
  final String id;

  /// The effective network access policy for the environment.
  final AgentSessionNetworkPolicyResource network;

  /// Packages installed in the environment.
  final AgentSessionEnvironmentPackagesResource packages;

  /// Plugins installed in the environment, excluding their archive contents.
  final List<AgentSessionHostedPluginResource> plugins;

  /// Skills installed in the environment, excluding their archive contents.
  final List<AgentSessionHostedSkillResource> skills;

  /// The type of the object. Always `openai_hosted`.
  @override
  String get type => 'openai_hosted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionHostedEnvironmentResource] with contextual, payload-free errors.
  factory AgentSessionHostedEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'openai_hosted',
      'AgentSessionHostedEnvironmentResource',
    );
    return AgentSessionHostedEnvironmentResource(
      capabilityDirectories: requiredAgentValue(
        json,
        'capability_directories',
        'AgentSessionHostedEnvironmentResource.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      containerSize: optionalAgentValue(
        json,
        'container_size',
        'AgentSessionHostedEnvironmentResource.containerSize',
        (value, context) => AgentSessionContainerSizeResource.fromJson(value),
        nullable: true,
      ),
      clearContainerSize:
          json.containsKey('container_size') && json['container_size'] == null,
      desktop: requiredAgentValue(
        json,
        'desktop',
        'AgentSessionHostedEnvironmentResource.desktop',
        (value, context) => AgentSessionDesktopResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      files: requiredAgentValue(
        json,
        'files',
        'AgentSessionHostedEnvironmentResource.files',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionHostedEnvironmentFileResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionHostedEnvironmentResource.id',
        requireAgentString,
        nullable: false,
      )!,
      network: requiredAgentValue(
        json,
        'network',
        'AgentSessionHostedEnvironmentResource.network',
        (value, context) => AgentSessionNetworkPolicyResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      packages: requiredAgentValue(
        json,
        'packages',
        'AgentSessionHostedEnvironmentResource.packages',
        (value, context) => AgentSessionEnvironmentPackagesResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      plugins: requiredAgentValue(
        json,
        'plugins',
        'AgentSessionHostedEnvironmentResource.plugins',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionHostedPluginResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      skills: requiredAgentValue(
        json,
        'skills',
        'AgentSessionHostedEnvironmentResource.skills',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionHostedSkillResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'capability_directories',
            'container_size',
            'desktop',
            'files',
            'id',
            'network',
            'packages',
            'plugins',
            'skills',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      capabilityDirectories.length,
      'AgentSessionHostedEnvironmentResource.capabilityDirectories',
      min: 0,
      max: 2000,
    );
    for (final item in capabilityDirectories) {
      validateAgentLength(
        item,
        'AgentSessionHostedEnvironmentResource.capabilityDirectories',
        min: 0,
      );
    }
    desktop.validate();
    validateAgentCount(
      files.length,
      'AgentSessionHostedEnvironmentResource.files',
      min: 0,
      max: 50,
    );
    for (final item in files) {
      item.validate();
    }
    validateAgentLength(id, 'AgentSessionHostedEnvironmentResource.id', min: 0);
    network.validate();
    packages.validate();
    validateAgentCount(
      plugins.length,
      'AgentSessionHostedEnvironmentResource.plugins',
      min: 0,
      max: 2000,
    );
    for (final item in plugins) {
      item.validate();
    }
    validateAgentCount(
      skills.length,
      'AgentSessionHostedEnvironmentResource.skills',
      min: 0,
      max: 2000,
    );
    for (final item in skills) {
      item.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'capability_directories': capabilityDirectories
        .map((value) => value)
        .toList(),
    if (clearContainerSize)
      'container_size': null
    else if (containerSize != null)
      'container_size': containerSize!.toJson(),
    'desktop': desktop.toJson(),
    'files': files.map((value) => value.toJson()).toList(),
    'id': id,
    'network': network.toJson(),
    'packages': packages.toJson(),
    'plugins': plugins.map((value) => value.toJson()).toList(),
    'skills': skills.map((value) => value.toJson()).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedEnvironmentResource copyWith({
    List<String>? capabilityDirectories,
    Object? containerSize = unsetCopyWithValue,
    bool? clearContainerSize,
    AgentSessionDesktopResource? desktop,
    List<AgentSessionHostedEnvironmentFileResource>? files,
    String? id,
    AgentSessionNetworkPolicyResource? network,
    AgentSessionEnvironmentPackagesResource? packages,
    List<AgentSessionHostedPluginResource>? plugins,
    List<AgentSessionHostedSkillResource>? skills,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionHostedEnvironmentResource(
    capabilityDirectories: capabilityDirectories ?? this.capabilityDirectories,
    containerSize: copyAgentValue<AgentSessionContainerSizeResource>(
      containerSize,
      this.containerSize,
      'AgentSessionHostedEnvironmentResource.containerSize',
    ),
    clearContainerSize:
        clearContainerSize ??
        (identical(containerSize, unsetCopyWithValue)
            ? this.clearContainerSize
            : containerSize == null),
    desktop: desktop ?? this.desktop,
    files: files ?? this.files,
    id: id ?? this.id,
    network: network ?? this.network,
    packages: packages ?? this.packages,
    plugins: plugins ?? this.plugins,
    skills: skills ?? this.skills,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An environment hosted by the application.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSelfHostedEnvironmentResource
    extends AgentSessionEnvironmentResource {
  /// Creates a validated [AgentSessionSelfHostedEnvironmentResource].
  AgentSessionSelfHostedEnvironmentResource({
    required List<String> capabilityDirectories,
    required this.id,
    required this.remoteUrl,
    required this.workspaceDirectory,
    Map<String, dynamic> rawJson = const {},
  }) : capabilityDirectories = List.unmodifiable(capabilityDirectories),
       rawJson = agentExtras(rawJson, const [
         'capability_directories',
         'id',
         'remote_url',
         'type',
         'workspace_directory',
       ], 'AgentSessionSelfHostedEnvironmentResource') {
    validate();
  }

  /// Directories that contain capabilities exposed to the agent.
  final List<String> capabilityDirectories;

  /// The public ID of the environment.
  final String id;

  /// Pass this URL unchanged to `codex exec-server --remote` when connecting this environment.
  final String remoteUrl;

  /// The type of the object. Always `self_hosted`.
  @override
  String get type => 'self_hosted';

  /// The absolute project directory inside the environment. Defaults to `/workspace`.
  final String workspaceDirectory;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSelfHostedEnvironmentResource] with contextual, payload-free errors.
  factory AgentSessionSelfHostedEnvironmentResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'self_hosted',
      'AgentSessionSelfHostedEnvironmentResource',
    );
    return AgentSessionSelfHostedEnvironmentResource(
      capabilityDirectories: requiredAgentValue(
        json,
        'capability_directories',
        'AgentSessionSelfHostedEnvironmentResource.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionSelfHostedEnvironmentResource.id',
        requireAgentString,
        nullable: false,
      )!,
      remoteUrl: requiredAgentValue(
        json,
        'remote_url',
        'AgentSessionSelfHostedEnvironmentResource.remoteUrl',
        requireAgentString,
        nullable: false,
      )!,
      workspaceDirectory: requiredAgentValue(
        json,
        'workspace_directory',
        'AgentSessionSelfHostedEnvironmentResource.workspaceDirectory',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'capability_directories',
            'id',
            'remote_url',
            'type',
            'workspace_directory',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      capabilityDirectories.length,
      'AgentSessionSelfHostedEnvironmentResource.capabilityDirectories',
      min: 0,
      max: 2000,
    );
    for (final item in capabilityDirectories) {
      validateAgentLength(
        item,
        'AgentSessionSelfHostedEnvironmentResource.capabilityDirectories',
        min: 0,
      );
    }
    validateAgentLength(
      id,
      'AgentSessionSelfHostedEnvironmentResource.id',
      min: 0,
    );
    validateAgentLength(
      remoteUrl,
      'AgentSessionSelfHostedEnvironmentResource.remoteUrl',
      min: 0,
    );
    validateAgentLength(
      workspaceDirectory,
      'AgentSessionSelfHostedEnvironmentResource.workspaceDirectory',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'capability_directories': capabilityDirectories
        .map((value) => value)
        .toList(),
    'id': id,
    'remote_url': remoteUrl,
    'type': type,
    'workspace_directory': workspaceDirectory,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSelfHostedEnvironmentResource copyWith({
    List<String>? capabilityDirectories,
    String? id,
    String? remoteUrl,
    String? workspaceDirectory,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSelfHostedEnvironmentResource(
    capabilityDirectories: capabilityDirectories ?? this.capabilityDirectories,
    id: id ?? this.id,
    remoteUrl: remoteUrl ?? this.remoteUrl,
    workspaceDirectory: workspaceDirectory ?? this.workspaceDirectory,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A file materialized in an OpenAI-hosted execution environment.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionHostedEnvironmentFileConfig extends AgentJsonModel {
  const AgentSessionHostedEnvironmentFileConfig();

  /// Parses a known contract or detached future received value.
  factory AgentSessionHostedEnvironmentFileConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionHostedEnvironmentFileConfig.type',
    )) {
      'file_id' => AgentSessionHostedEnvironmentFileConfigFileId.fromJson(json),
      'inline' => AgentSessionHostedEnvironmentFileConfigInline.fromJson(json),
      _ => UnknownAgentSessionHostedEnvironmentFileConfig.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `file_id` contract.
  factory AgentSessionHostedEnvironmentFileConfig.fileId({
    required String fileId,
    required String path,
  }) = AgentSessionHostedEnvironmentFileConfigFileId;

  /// Builds the `inline` contract.
  factory AgentSessionHostedEnvironmentFileConfig.inline({
    required String data,
    required String path,
  }) = AgentSessionHostedEnvironmentFileConfigInline;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionHostedEnvironmentFileConfig
    extends AgentSessionHostedEnvironmentFileConfig {
  const UnknownAgentSessionHostedEnvironmentFileConfig._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionHostedEnvironmentFileConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionHostedEnvironmentFileConfig.type',
    );
    if (const ['file_id', 'inline'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionHostedEnvironmentFileConfig: expected a future discriminator',
      );
    }
    return UnknownAgentSessionHostedEnvironmentFileConfig._(
      snapshotAgentJson(json, 'UnknownAgentSessionHostedEnvironmentFileConfig'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionHostedEnvironmentFileConfig copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionHostedEnvironmentFileConfig.fromJson(
    rawJson ?? this.rawJson,
  );
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionHostedEnvironmentFileConfig: future input is not writable',
  );
}

/// A file previously uploaded through the OpenAI Files API.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionHostedEnvironmentFileConfigFileId
    extends AgentSessionHostedEnvironmentFileConfig {
  /// Creates a validated [AgentSessionHostedEnvironmentFileConfigFileId].
  AgentSessionHostedEnvironmentFileConfigFileId({
    required this.fileId,
    required this.path,
  }) {
    validate();
  }

  /// The ID of the uploaded file.
  final String fileId;

  /// The absolute destination path inside `/workspace`.
  final String path;

  /// The type of the object. Always `file_id`.
  @override
  String get type => 'file_id';

  /// Parses [AgentSessionHostedEnvironmentFileConfigFileId] with contextual, payload-free errors.
  factory AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'file_id',
      'path',
      'type',
    ], 'AgentSessionHostedEnvironmentFileConfigFileId');
    requireAgentTag(
      json,
      'type',
      'file_id',
      'AgentSessionHostedEnvironmentFileConfigFileId',
    );
    return AgentSessionHostedEnvironmentFileConfigFileId(
      fileId: requiredAgentValue(
        json,
        'file_id',
        'AgentSessionHostedEnvironmentFileConfigFileId.fileId',
        requireAgentString,
        nullable: false,
      )!,
      path: requiredAgentValue(
        json,
        'path',
        'AgentSessionHostedEnvironmentFileConfigFileId.path',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateAgentSessionWorkspacePath(path);
    validateAgentLength(
      fileId,
      'AgentSessionHostedEnvironmentFileConfigFileId.fileId',
      min: 1,
      max: 256,
    );
    validateAgentLength(
      path,
      'AgentSessionHostedEnvironmentFileConfigFileId.path',
      min: 1,
      max: 4096,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'file_id': fileId,
    'path': path,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedEnvironmentFileConfigFileId copyWith({
    String? fileId,
    String? path,
  }) => AgentSessionHostedEnvironmentFileConfigFileId(
    fileId: fileId ?? this.fileId,
    path: path ?? this.path,
  );
}

/// A file supplied directly as standard-base64 data.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionHostedEnvironmentFileConfigInline
    extends AgentSessionHostedEnvironmentFileConfig {
  /// Creates a validated [AgentSessionHostedEnvironmentFileConfigInline].
  AgentSessionHostedEnvironmentFileConfigInline({
    required this.data,
    required this.path,
  }) {
    validate();
  }

  /// The standard-base64-encoded file contents.
  final String data;

  /// The absolute destination path inside `/workspace`.
  final String path;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Parses [AgentSessionHostedEnvironmentFileConfigInline] with contextual, payload-free errors.
  factory AgentSessionHostedEnvironmentFileConfigInline.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'data',
      'path',
      'type',
    ], 'AgentSessionHostedEnvironmentFileConfigInline');
    requireAgentTag(
      json,
      'type',
      'inline',
      'AgentSessionHostedEnvironmentFileConfigInline',
    );
    return AgentSessionHostedEnvironmentFileConfigInline(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionHostedEnvironmentFileConfigInline.data',
        requireAgentString,
        nullable: false,
      )!,
      path: requiredAgentValue(
        json,
        'path',
        'AgentSessionHostedEnvironmentFileConfigInline.path',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateAgentSessionWorkspacePath(path);
    _validateAgentSessionBase64(data, 'Inline file');
    validateAgentLength(
      data,
      'AgentSessionHostedEnvironmentFileConfigInline.data',
      min: 0,
      max: 6990508,
    );
    validateAgentLength(
      path,
      'AgentSessionHostedEnvironmentFileConfigInline.path',
      min: 1,
      max: 4096,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'data': data, 'path': path, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedEnvironmentFileConfigInline copyWith({
    String? data,
    String? path,
  }) => AgentSessionHostedEnvironmentFileConfigInline(
    data: data ?? this.data,
    path: path ?? this.path,
  );
}

/// Metadata for a file materialized in an OpenAI-hosted execution environment.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionHostedEnvironmentFileResource extends AgentJsonModel {
  const AgentSessionHostedEnvironmentFileResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionHostedEnvironmentFileResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionHostedEnvironmentFileResource.type',
    )) {
      'file_id' => AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        json,
      ),
      'inline' => AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        json,
      ),
      _ => UnknownAgentSessionHostedEnvironmentFileResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `file_id` contract.
  factory AgentSessionHostedEnvironmentFileResource.fileId({
    required String fileId,
    required String id,
    required String path,
    required int sizeBytes,
    Map<String, dynamic> rawJson,
  }) = AgentSessionHostedEnvironmentFileResourceFileId;

  /// Builds the `inline` contract.
  factory AgentSessionHostedEnvironmentFileResource.inline({
    required String id,
    required String path,
    required int sizeBytes,
    Map<String, dynamic> rawJson,
  }) = AgentSessionHostedEnvironmentFileResourceInline;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionHostedEnvironmentFileResource
    extends AgentSessionHostedEnvironmentFileResource {
  const UnknownAgentSessionHostedEnvironmentFileResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionHostedEnvironmentFileResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionHostedEnvironmentFileResource.type',
    );
    if (const ['file_id', 'inline'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionHostedEnvironmentFileResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionHostedEnvironmentFileResource._(
      snapshotAgentJson(
        json,
        'UnknownAgentSessionHostedEnvironmentFileResource',
      ),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionHostedEnvironmentFileResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionHostedEnvironmentFileResource.fromJson(
    rawJson ?? this.rawJson,
  );
}

/// A file copied from the OpenAI Files API.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionHostedEnvironmentFileResourceFileId
    extends AgentSessionHostedEnvironmentFileResource {
  /// Creates a validated [AgentSessionHostedEnvironmentFileResourceFileId].
  AgentSessionHostedEnvironmentFileResourceFileId({
    required this.fileId,
    required this.id,
    required this.path,
    required this.sizeBytes,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'file_id',
         'id',
         'path',
         'size_bytes',
         'type',
       ], 'AgentSessionHostedEnvironmentFileResourceFileId') {
    validate();
  }

  /// The ID of the uploaded file.
  final String fileId;

  /// The session-scoped ID of the file in the execution environment.
  final String id;

  /// The file's absolute path inside the environment.
  final String path;

  /// The decoded file size in bytes.
  final int sizeBytes;

  /// The type of the object. Always `file_id`.
  @override
  String get type => 'file_id';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionHostedEnvironmentFileResourceFileId] with contextual, payload-free errors.
  factory AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'file_id',
      'AgentSessionHostedEnvironmentFileResourceFileId',
    );
    return AgentSessionHostedEnvironmentFileResourceFileId(
      fileId: requiredAgentValue(
        json,
        'file_id',
        'AgentSessionHostedEnvironmentFileResourceFileId.fileId',
        requireAgentString,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionHostedEnvironmentFileResourceFileId.id',
        requireAgentString,
        nullable: false,
      )!,
      path: requiredAgentValue(
        json,
        'path',
        'AgentSessionHostedEnvironmentFileResourceFileId.path',
        requireAgentString,
        nullable: false,
      )!,
      sizeBytes: requiredAgentValue(
        json,
        'size_bytes',
        'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'file_id',
            'id',
            'path',
            'size_bytes',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      fileId,
      'AgentSessionHostedEnvironmentFileResourceFileId.fileId',
      min: 0,
    );
    validateAgentLength(
      id,
      'AgentSessionHostedEnvironmentFileResourceFileId.id',
      min: 0,
    );
    validateAgentLength(
      path,
      'AgentSessionHostedEnvironmentFileResourceFileId.path',
      min: 0,
    );
    validateAgentInt(
      sizeBytes,
      'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'file_id': fileId,
    'id': id,
    'path': path,
    'size_bytes': sizeBytes,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedEnvironmentFileResourceFileId copyWith({
    String? fileId,
    String? id,
    String? path,
    int? sizeBytes,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionHostedEnvironmentFileResourceFileId(
    fileId: fileId ?? this.fileId,
    id: id ?? this.id,
    path: path ?? this.path,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A file supplied inline when the session was created.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionHostedEnvironmentFileResourceInline
    extends AgentSessionHostedEnvironmentFileResource {
  /// Creates a validated [AgentSessionHostedEnvironmentFileResourceInline].
  AgentSessionHostedEnvironmentFileResourceInline({
    required this.id,
    required this.path,
    required this.sizeBytes,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'path',
         'size_bytes',
         'type',
       ], 'AgentSessionHostedEnvironmentFileResourceInline') {
    validate();
  }

  /// The session-scoped ID of the file in the execution environment.
  final String id;

  /// The file's absolute path inside the environment.
  final String path;

  /// The decoded file size in bytes.
  final int sizeBytes;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionHostedEnvironmentFileResourceInline] with contextual, payload-free errors.
  factory AgentSessionHostedEnvironmentFileResourceInline.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'inline',
      'AgentSessionHostedEnvironmentFileResourceInline',
    );
    return AgentSessionHostedEnvironmentFileResourceInline(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionHostedEnvironmentFileResourceInline.id',
        requireAgentString,
        nullable: false,
      )!,
      path: requiredAgentValue(
        json,
        'path',
        'AgentSessionHostedEnvironmentFileResourceInline.path',
        requireAgentString,
        nullable: false,
      )!,
      sizeBytes: requiredAgentValue(
        json,
        'size_bytes',
        'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['id', 'path', 'size_bytes', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      id,
      'AgentSessionHostedEnvironmentFileResourceInline.id',
      min: 0,
    );
    validateAgentLength(
      path,
      'AgentSessionHostedEnvironmentFileResourceInline.path',
      min: 0,
    );
    validateAgentInt(
      sizeBytes,
      'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'path': path,
    'size_bytes': sizeBytes,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedEnvironmentFileResourceInline copyWith({
    String? id,
    String? path,
    int? sizeBytes,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionHostedEnvironmentFileResourceInline(
    id: id ?? this.id,
    path: path ?? this.path,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A plugin installed in an OpenAI-hosted environment.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionHostedPluginConfig extends AgentJsonModel {
  const AgentSessionHostedPluginConfig();

  /// Parses a known contract or detached future received value.
  factory AgentSessionHostedPluginConfig.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionHostedPluginConfig.type',
    )) {
      'inline' => AgentSessionHostedPluginConfigInline.fromJson(json),
      _ => UnknownAgentSessionHostedPluginConfig.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `inline` contract.
  factory AgentSessionHostedPluginConfig.inline({
    required String description,
    required String name,
    required AgentSessionInlineCapabilitySourceConfig source,
  }) = AgentSessionHostedPluginConfigInline;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionHostedPluginConfig
    extends AgentSessionHostedPluginConfig {
  const UnknownAgentSessionHostedPluginConfig._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionHostedPluginConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionHostedPluginConfig.type',
    );
    if (const ['inline'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionHostedPluginConfig: expected a future discriminator',
      );
    }
    return UnknownAgentSessionHostedPluginConfig._(
      snapshotAgentJson(json, 'UnknownAgentSessionHostedPluginConfig'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionHostedPluginConfig copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionHostedPluginConfig.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionHostedPluginConfig: future input is not writable',
  );
}

/// Supplies a plugin ZIP directly in the session request.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionHostedPluginConfigInline
    extends AgentSessionHostedPluginConfig {
  /// Creates a validated [AgentSessionHostedPluginConfigInline].
  AgentSessionHostedPluginConfigInline({
    required this.description,
    required this.name,
    required this.source,
  }) {
    validate();
  }

  /// The plugin description declared in `.codex-plugin/plugin.json`.
  final String description;

  /// The plugin name declared in `.codex-plugin/plugin.json`.
  final String name;

  /// The inline ZIP archive.
  final AgentSessionInlineCapabilitySourceConfig source;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Parses [AgentSessionHostedPluginConfigInline] with contextual, payload-free errors.
  factory AgentSessionHostedPluginConfigInline.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'description',
      'name',
      'source',
      'type',
    ], 'AgentSessionHostedPluginConfigInline');
    requireAgentTag(
      json,
      'type',
      'inline',
      'AgentSessionHostedPluginConfigInline',
    );
    return AgentSessionHostedPluginConfigInline(
      description: requiredAgentValue(
        json,
        'description',
        'AgentSessionHostedPluginConfigInline.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionHostedPluginConfigInline.name',
        requireAgentString,
        nullable: false,
      )!,
      source: requiredAgentValue(
        json,
        'source',
        'AgentSessionHostedPluginConfigInline.source',
        (value, context) => AgentSessionInlineCapabilitySourceConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentSessionHostedPluginConfigInline.description',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      name,
      'AgentSessionHostedPluginConfigInline.name',
      min: 1,
      max: 64,
    );
    source.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    'description': description,
    'name': name,
    'source': source.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedPluginConfigInline copyWith({
    String? description,
    String? name,
    AgentSessionInlineCapabilitySourceConfig? source,
  }) => AgentSessionHostedPluginConfigInline(
    description: description ?? this.description,
    name: name ?? this.name,
    source: source ?? this.source,
  );
}

/// A plugin installed in an OpenAI-hosted environment.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionHostedPluginResource extends AgentJsonModel {
  const AgentSessionHostedPluginResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionHostedPluginResource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionHostedPluginResource.type',
    )) {
      'inline' => AgentSessionHostedPluginResourceInline.fromJson(json),
      _ => UnknownAgentSessionHostedPluginResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `inline` contract.
  factory AgentSessionHostedPluginResource.inline({
    required String description,
    required String name,
    Map<String, dynamic> rawJson,
  }) = AgentSessionHostedPluginResourceInline;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionHostedPluginResource
    extends AgentSessionHostedPluginResource {
  const UnknownAgentSessionHostedPluginResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionHostedPluginResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionHostedPluginResource.type',
    );
    if (const ['inline'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionHostedPluginResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionHostedPluginResource._(
      snapshotAgentJson(json, 'UnknownAgentSessionHostedPluginResource'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionHostedPluginResource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      UnknownAgentSessionHostedPluginResource.fromJson(rawJson ?? this.rawJson);
}

/// A plugin installed from an inline ZIP archive.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionHostedPluginResourceInline
    extends AgentSessionHostedPluginResource {
  /// Creates a validated [AgentSessionHostedPluginResourceInline].
  AgentSessionHostedPluginResourceInline({
    required this.description,
    required this.name,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'description',
         'name',
         'type',
       ], 'AgentSessionHostedPluginResourceInline') {
    validate();
  }

  /// The installed plugin description.
  final String description;

  /// The installed plugin name.
  final String name;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionHostedPluginResourceInline] with contextual, payload-free errors.
  factory AgentSessionHostedPluginResourceInline.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'inline',
      'AgentSessionHostedPluginResourceInline',
    );
    return AgentSessionHostedPluginResourceInline(
      description: requiredAgentValue(
        json,
        'description',
        'AgentSessionHostedPluginResourceInline.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionHostedPluginResourceInline.name',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['description', 'name', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentSessionHostedPluginResourceInline.description',
      min: 0,
    );
    validateAgentLength(
      name,
      'AgentSessionHostedPluginResourceInline.name',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'description': description,
    'name': name,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedPluginResourceInline copyWith({
    String? description,
    String? name,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionHostedPluginResourceInline(
    description: description ?? this.description,
    name: name ?? this.name,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A skill installed in an OpenAI-hosted environment.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionHostedSkillConfig extends AgentJsonModel {
  const AgentSessionHostedSkillConfig();

  /// Parses a known contract or detached future received value.
  factory AgentSessionHostedSkillConfig.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionHostedSkillConfig.type',
    )) {
      'inline' => AgentSessionHostedSkillConfigInline.fromJson(json),
      'skill_reference' => AgentSessionHostedSkillConfigSkillReference.fromJson(
        json,
      ),
      _ => UnknownAgentSessionHostedSkillConfig.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `inline` contract.
  factory AgentSessionHostedSkillConfig.inline({
    required String description,
    required String name,
    required AgentSessionInlineCapabilitySourceConfig source,
  }) = AgentSessionHostedSkillConfigInline;

  /// Builds the `skill_reference` contract.
  factory AgentSessionHostedSkillConfig.skillReference({
    required String skillId,
    String? version,
    bool clearVersion,
  }) = AgentSessionHostedSkillConfigSkillReference;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionHostedSkillConfig
    extends AgentSessionHostedSkillConfig {
  const UnknownAgentSessionHostedSkillConfig._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionHostedSkillConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionHostedSkillConfig.type',
    );
    if (const ['inline', 'skill_reference'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionHostedSkillConfig: expected a future discriminator',
      );
    }
    return UnknownAgentSessionHostedSkillConfig._(
      snapshotAgentJson(json, 'UnknownAgentSessionHostedSkillConfig'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionHostedSkillConfig copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionHostedSkillConfig.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionHostedSkillConfig: future input is not writable',
  );
}

/// Supplies a skill ZIP directly in the session request.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionHostedSkillConfigInline
    extends AgentSessionHostedSkillConfig {
  /// Creates a validated [AgentSessionHostedSkillConfigInline].
  AgentSessionHostedSkillConfigInline({
    required this.description,
    required this.name,
    required this.source,
  }) {
    validate();
  }

  /// The skill description declared in `SKILL.md`.
  final String description;

  /// The skill name declared in `SKILL.md`.
  final String name;

  /// The inline ZIP archive.
  final AgentSessionInlineCapabilitySourceConfig source;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Parses [AgentSessionHostedSkillConfigInline] with contextual, payload-free errors.
  factory AgentSessionHostedSkillConfigInline.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'description',
      'name',
      'source',
      'type',
    ], 'AgentSessionHostedSkillConfigInline');
    requireAgentTag(
      json,
      'type',
      'inline',
      'AgentSessionHostedSkillConfigInline',
    );
    return AgentSessionHostedSkillConfigInline(
      description: requiredAgentValue(
        json,
        'description',
        'AgentSessionHostedSkillConfigInline.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionHostedSkillConfigInline.name',
        requireAgentString,
        nullable: false,
      )!,
      source: requiredAgentValue(
        json,
        'source',
        'AgentSessionHostedSkillConfigInline.source',
        (value, context) => AgentSessionInlineCapabilitySourceConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentSessionHostedSkillConfigInline.description',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      name,
      'AgentSessionHostedSkillConfigInline.name',
      min: 1,
      max: 64,
    );
    source.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    'description': description,
    'name': name,
    'source': source.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedSkillConfigInline copyWith({
    String? description,
    String? name,
    AgentSessionInlineCapabilitySourceConfig? source,
  }) => AgentSessionHostedSkillConfigInline(
    description: description ?? this.description,
    name: name ?? this.name,
    source: source ?? this.source,
  );
}

/// References a skill uploaded through the Skills API.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionHostedSkillConfigSkillReference
    extends AgentSessionHostedSkillConfig {
  /// Creates a validated [AgentSessionHostedSkillConfigSkillReference].
  AgentSessionHostedSkillConfigSkillReference({
    required this.skillId,
    String? version,
    bool clearVersion = false,
  }) : clearVersion = clearVersion,
       version = clearVersion ? null : version {
    validate();
  }

  /// The ID of the skill created through `/v1/skills`.
  final String skillId;

  /// The type of the object. Always `skill_reference`.
  @override
  String get type => 'skill_reference';

  /// The skill version, a positive integer or `latest`; omission selects the default.
  final String? version;

  /// Sends `version: null`, rather than omitting it.
  final bool clearVersion;

  /// Parses [AgentSessionHostedSkillConfigSkillReference] with contextual, payload-free errors.
  factory AgentSessionHostedSkillConfigSkillReference.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'skill_id',
      'type',
      'version',
    ], 'AgentSessionHostedSkillConfigSkillReference');
    requireAgentTag(
      json,
      'type',
      'skill_reference',
      'AgentSessionHostedSkillConfigSkillReference',
    );
    return AgentSessionHostedSkillConfigSkillReference(
      skillId: requiredAgentValue(
        json,
        'skill_id',
        'AgentSessionHostedSkillConfigSkillReference.skillId',
        requireAgentString,
        nullable: false,
      )!,
      version: optionalAgentValue(
        json,
        'version',
        'AgentSessionHostedSkillConfigSkillReference.version',
        requireAgentString,
        nullable: true,
      ),
      clearVersion: json.containsKey('version') && json['version'] == null,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      skillId,
      'AgentSessionHostedSkillConfigSkillReference.skillId',
      min: 1,
      max: 64,
    );
    if (version != null) {
      validateAgentLength(
        version!,
        'AgentSessionHostedSkillConfigSkillReference.version',
        min: 0,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'skill_id': skillId,
    'type': type,
    if (clearVersion) 'version': null else 'version': ?version,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedSkillConfigSkillReference copyWith({
    String? skillId,
    Object? version = unsetCopyWithValue,
    bool? clearVersion,
  }) => AgentSessionHostedSkillConfigSkillReference(
    skillId: skillId ?? this.skillId,
    version: copyAgentValue<String>(
      version,
      this.version,
      'AgentSessionHostedSkillConfigSkillReference.version',
    ),
    clearVersion:
        clearVersion ??
        (identical(version, unsetCopyWithValue)
            ? this.clearVersion
            : version == null),
  );
}

/// A skill installed in an OpenAI-hosted environment.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionHostedSkillResource extends AgentJsonModel {
  const AgentSessionHostedSkillResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionHostedSkillResource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionHostedSkillResource.type',
    )) {
      'inline' => AgentSessionHostedSkillResourceInline.fromJson(json),
      'skill_reference' =>
        AgentSessionHostedSkillResourceSkillReference.fromJson(json),
      _ => UnknownAgentSessionHostedSkillResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `inline` contract.
  factory AgentSessionHostedSkillResource.inline({
    required String description,
    required String name,
    Map<String, dynamic> rawJson,
  }) = AgentSessionHostedSkillResourceInline;

  /// Builds the `skill_reference` contract.
  factory AgentSessionHostedSkillResource.skillReference({
    required String description,
    required String name,
    required String skillId,
    required String version,
    Map<String, dynamic> rawJson,
  }) = AgentSessionHostedSkillResourceSkillReference;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionHostedSkillResource
    extends AgentSessionHostedSkillResource {
  const UnknownAgentSessionHostedSkillResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionHostedSkillResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionHostedSkillResource.type',
    );
    if (const ['inline', 'skill_reference'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionHostedSkillResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionHostedSkillResource._(
      snapshotAgentJson(json, 'UnknownAgentSessionHostedSkillResource'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionHostedSkillResource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      UnknownAgentSessionHostedSkillResource.fromJson(rawJson ?? this.rawJson);
}

/// A skill installed from an inline ZIP archive.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionHostedSkillResourceInline
    extends AgentSessionHostedSkillResource {
  /// Creates a validated [AgentSessionHostedSkillResourceInline].
  AgentSessionHostedSkillResourceInline({
    required this.description,
    required this.name,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'description',
         'name',
         'type',
       ], 'AgentSessionHostedSkillResourceInline') {
    validate();
  }

  /// The installed skill description.
  final String description;

  /// The installed skill name.
  final String name;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionHostedSkillResourceInline] with contextual, payload-free errors.
  factory AgentSessionHostedSkillResourceInline.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'inline',
      'AgentSessionHostedSkillResourceInline',
    );
    return AgentSessionHostedSkillResourceInline(
      description: requiredAgentValue(
        json,
        'description',
        'AgentSessionHostedSkillResourceInline.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionHostedSkillResourceInline.name',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['description', 'name', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentSessionHostedSkillResourceInline.description',
      min: 0,
    );
    validateAgentLength(
      name,
      'AgentSessionHostedSkillResourceInline.name',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'description': description,
    'name': name,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedSkillResourceInline copyWith({
    String? description,
    String? name,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionHostedSkillResourceInline(
    description: description ?? this.description,
    name: name ?? this.name,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A skill installed from the Skills API.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionHostedSkillResourceSkillReference
    extends AgentSessionHostedSkillResource {
  /// Creates a validated [AgentSessionHostedSkillResourceSkillReference].
  AgentSessionHostedSkillResourceSkillReference({
    required this.description,
    required this.name,
    required this.skillId,
    required this.version,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'description',
         'name',
         'skill_id',
         'type',
         'version',
       ], 'AgentSessionHostedSkillResourceSkillReference') {
    validate();
  }

  /// The installed skill description.
  final String description;

  /// The installed skill name.
  final String name;

  /// The referenced skill ID.
  final String skillId;

  /// The type of the object. Always `skill_reference`.
  @override
  String get type => 'skill_reference';

  /// The concrete skill version installed for this session.
  final String version;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionHostedSkillResourceSkillReference] with contextual, payload-free errors.
  factory AgentSessionHostedSkillResourceSkillReference.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'skill_reference',
      'AgentSessionHostedSkillResourceSkillReference',
    );
    return AgentSessionHostedSkillResourceSkillReference(
      description: requiredAgentValue(
        json,
        'description',
        'AgentSessionHostedSkillResourceSkillReference.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionHostedSkillResourceSkillReference.name',
        requireAgentString,
        nullable: false,
      )!,
      skillId: requiredAgentValue(
        json,
        'skill_id',
        'AgentSessionHostedSkillResourceSkillReference.skillId',
        requireAgentString,
        nullable: false,
      )!,
      version: requiredAgentValue(
        json,
        'version',
        'AgentSessionHostedSkillResourceSkillReference.version',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'description',
            'name',
            'skill_id',
            'type',
            'version',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentSessionHostedSkillResourceSkillReference.description',
      min: 0,
    );
    validateAgentLength(
      name,
      'AgentSessionHostedSkillResourceSkillReference.name',
      min: 0,
    );
    validateAgentLength(
      skillId,
      'AgentSessionHostedSkillResourceSkillReference.skillId',
      min: 0,
    );
    validateAgentLength(
      version,
      'AgentSessionHostedSkillResourceSkillReference.version',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'description': description,
    'name': name,
    'skill_id': skillId,
    'type': type,
    'version': version,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionHostedSkillResourceSkillReference copyWith({
    String? description,
    String? name,
    String? skillId,
    String? version,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionHostedSkillResourceSkillReference(
    description: description ?? this.description,
    name: name ?? this.name,
    skillId: skillId ?? this.skillId,
    version: version ?? this.version,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The encoded ZIP archive for an inline skill or plugin.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionInlineCapabilitySourceConfig extends AgentJsonModel {
  const AgentSessionInlineCapabilitySourceConfig();

  /// Parses a known contract or detached future received value.
  factory AgentSessionInlineCapabilitySourceConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionInlineCapabilitySourceConfig.type',
    )) {
      'base64' => AgentSessionInlineCapabilitySourceConfigBase64.fromJson(json),
      _ => UnknownAgentSessionInlineCapabilitySourceConfig.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `base64` contract.
  factory AgentSessionInlineCapabilitySourceConfig.base64({
    required String data,
  }) = AgentSessionInlineCapabilitySourceConfigBase64;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionInlineCapabilitySourceConfig
    extends AgentSessionInlineCapabilitySourceConfig {
  const UnknownAgentSessionInlineCapabilitySourceConfig._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionInlineCapabilitySourceConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionInlineCapabilitySourceConfig.type',
    );
    if (const ['base64'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionInlineCapabilitySourceConfig: expected a future discriminator',
      );
    }
    return UnknownAgentSessionInlineCapabilitySourceConfig._(
      snapshotAgentJson(
        json,
        'UnknownAgentSessionInlineCapabilitySourceConfig',
      ),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionInlineCapabilitySourceConfig copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionInlineCapabilitySourceConfig.fromJson(
    rawJson ?? this.rawJson,
  );
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionInlineCapabilitySourceConfig: future input is not writable',
  );
}

/// Provides ZIP bytes encoded with standard base64.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionInlineCapabilitySourceConfigBase64
    extends AgentSessionInlineCapabilitySourceConfig {
  /// Creates a validated [AgentSessionInlineCapabilitySourceConfigBase64].
  AgentSessionInlineCapabilitySourceConfigBase64({required this.data}) {
    validate();
  }

  /// Standard-base64 encoded ZIP archive bytes.
  final String data;

  /// The archive media type, always `application/zip`.
  String get mediaType => 'application/zip';

  /// The type of the object. Always `base64`.
  @override
  String get type => 'base64';

  /// Parses [AgentSessionInlineCapabilitySourceConfigBase64] with contextual, payload-free errors.
  factory AgentSessionInlineCapabilitySourceConfigBase64.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'data',
      'media_type',
      'type',
    ], 'AgentSessionInlineCapabilitySourceConfigBase64');
    requireAgentTag(
      json,
      'media_type',
      'application/zip',
      'AgentSessionInlineCapabilitySourceConfigBase64',
    );
    requireAgentTag(
      json,
      'type',
      'base64',
      'AgentSessionInlineCapabilitySourceConfigBase64',
    );
    return AgentSessionInlineCapabilitySourceConfigBase64(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionInlineCapabilitySourceConfigBase64.data',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateAgentSessionBase64(data, 'Capability archive');
    validateAgentLength(
      data,
      'AgentSessionInlineCapabilitySourceConfigBase64.data',
      min: 1,
      max: 70254592,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'data': data,
    'media_type': mediaType,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionInlineCapabilitySourceConfigBase64 copyWith({String? data}) =>
      AgentSessionInlineCapabilitySourceConfigBase64(data: data ?? this.data);
}

/// Network access for an OpenAI-hosted environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionNetworkPolicyConfig extends AgentJsonModel {
  /// Creates a validated [AgentSessionNetworkPolicyConfig].
  AgentSessionNetworkPolicyConfig({
    required this.access,
    List<String>? allowedDomains,
    bool clearAllowedDomains = false,
    List<String>? blockedDomains,
    bool clearBlockedDomains = false,
  }) : clearAllowedDomains = clearAllowedDomains,
       allowedDomains = ownAgentValue<List<String>>(
         clearAllowedDomains ? null : allowedDomains,
         List.unmodifiable,
       ),
       clearBlockedDomains = clearBlockedDomains,
       blockedDomains = ownAgentValue<List<String>>(
         clearBlockedDomains ? null : blockedDomains,
         List.unmodifiable,
       ) {
    validate();
  }

  /// The environment's network access mode.
  final AgentSessionNetworkAccessConfig access;

  /// Domains the environment may access when network access is restricted.
  final List<String>? allowedDomains;

  /// Sends `allowed_domains: null`, rather than omitting it.
  final bool clearAllowedDomains;

  /// Domains blocked for both executor and browser when access is restricted. A nonempty list requires `access: restricted` and cannot be combined with nonempty `allowed_domains`. Wildcard domains are not supported.
  final List<String>? blockedDomains;

  /// Sends `blocked_domains: null`, rather than omitting it.
  final bool clearBlockedDomains;

  /// Parses [AgentSessionNetworkPolicyConfig] with contextual, payload-free errors.
  factory AgentSessionNetworkPolicyConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'access',
      'allowed_domains',
      'blocked_domains',
    ], 'AgentSessionNetworkPolicyConfig');
    return AgentSessionNetworkPolicyConfig(
      access: requiredAgentValue(
        json,
        'access',
        'AgentSessionNetworkPolicyConfig.access',
        (value, context) => AgentSessionNetworkAccessConfig.fromJson(value),
        nullable: false,
      )!,
      allowedDomains: optionalAgentValue(
        json,
        'allowed_domains',
        'AgentSessionNetworkPolicyConfig.allowedDomains',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearAllowedDomains:
          json.containsKey('allowed_domains') &&
          json['allowed_domains'] == null,
      blockedDomains: optionalAgentValue(
        json,
        'blocked_domains',
        'AgentSessionNetworkPolicyConfig.blockedDomains',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearBlockedDomains:
          json.containsKey('blocked_domains') &&
          json['blocked_domains'] == null,
    );
  }
  @override
  void validate() {
    _validateAgentSessionNetwork(access.value, allowedDomains, blockedDomains);
    validateAgentEnum(access.value, [
      'enabled',
      'disabled',
      'restricted',
    ], 'AgentSessionNetworkPolicyConfig.access');
    if (allowedDomains != null) {
      validateAgentCount(
        allowedDomains!.length,
        'AgentSessionNetworkPolicyConfig.allowedDomains',
        min: 0,
        max: 16384,
      );
      for (final item in allowedDomains!) {
        validateAgentLength(
          item,
          'AgentSessionNetworkPolicyConfig.allowedDomains',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (blockedDomains != null) {
      validateAgentCount(
        blockedDomains!.length,
        'AgentSessionNetworkPolicyConfig.blockedDomains',
        min: 0,
        max: 100,
      );
      for (final item in blockedDomains!) {
        validateAgentLength(
          item,
          'AgentSessionNetworkPolicyConfig.blockedDomains',
          min: 0,
          max: 1048576,
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'access': access.toJson(),
    if (clearAllowedDomains)
      'allowed_domains': null
    else if (allowedDomains != null)
      'allowed_domains': allowedDomains!.map((value) => value).toList(),
    if (clearBlockedDomains)
      'blocked_domains': null
    else if (blockedDomains != null)
      'blocked_domains': blockedDomains!.map((value) => value).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionNetworkPolicyConfig copyWith({
    AgentSessionNetworkAccessConfig? access,
    Object? allowedDomains = unsetCopyWithValue,
    bool? clearAllowedDomains,
    Object? blockedDomains = unsetCopyWithValue,
    bool? clearBlockedDomains,
  }) => AgentSessionNetworkPolicyConfig(
    access: access ?? this.access,
    allowedDomains: copyAgentValue<List<String>>(
      allowedDomains,
      this.allowedDomains,
      'AgentSessionNetworkPolicyConfig.allowedDomains',
    ),
    clearAllowedDomains:
        clearAllowedDomains ??
        (identical(allowedDomains, unsetCopyWithValue)
            ? this.clearAllowedDomains
            : allowedDomains == null),
    blockedDomains: copyAgentValue<List<String>>(
      blockedDomains,
      this.blockedDomains,
      'AgentSessionNetworkPolicyConfig.blockedDomains',
    ),
    clearBlockedDomains:
        clearBlockedDomains ??
        (identical(blockedDomains, unsetCopyWithValue)
            ? this.clearBlockedDomains
            : blockedDomains == null),
  );
}

/// Network access for an OpenAI-hosted environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionNetworkPolicyResource extends AgentJsonModel {
  /// Creates a validated [AgentSessionNetworkPolicyResource].
  AgentSessionNetworkPolicyResource({
    required this.access,
    required List<String> allowedDomains,
    Map<String, dynamic> rawJson = const {},
  }) : allowedDomains = List.unmodifiable(allowedDomains),
       rawJson = agentExtras(rawJson, const [
         'access',
         'allowed_domains',
       ], 'AgentSessionNetworkPolicyResource') {
    validate();
  }

  /// The environment's network access mode.
  final AgentSessionNetworkAccessResource access;

  /// Domains the environment may access when network access is restricted.
  final List<String> allowedDomains;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionNetworkPolicyResource] with contextual, payload-free errors.
  factory AgentSessionNetworkPolicyResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionNetworkPolicyResource(
      access: requiredAgentValue(
        json,
        'access',
        'AgentSessionNetworkPolicyResource.access',
        (value, context) => AgentSessionNetworkAccessResource.fromJson(value),
        nullable: false,
      )!,
      allowedDomains: requiredAgentValue(
        json,
        'allowed_domains',
        'AgentSessionNetworkPolicyResource.allowedDomains',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['access', 'allowed_domains'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      allowedDomains.length,
      'AgentSessionNetworkPolicyResource.allowedDomains',
      min: 0,
      max: 2000,
    );
    for (final item in allowedDomains) {
      validateAgentLength(
        item,
        'AgentSessionNetworkPolicyResource.allowedDomains',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'access': access.toJson(),
    'allowed_domains': allowedDomains.map((value) => value).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionNetworkPolicyResource copyWith({
    AgentSessionNetworkAccessResource? access,
    List<String>? allowedDomains,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionNetworkPolicyResource(
    access: access ?? this.access,
    allowedDomains: allowedDomains ?? this.allowedDomains,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A confidential setup command executed before the hosted agent starts.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionSetupCommandConfig extends AgentJsonModel {
  /// Creates a validated [AgentSessionSetupCommandConfig].
  AgentSessionSetupCommandConfig({
    required this.command,
    String? cwd,
    bool clearCwd = false,
  }) : clearCwd = clearCwd,
       cwd = clearCwd ? null : cwd {
    validate();
  }

  /// The shell command to execute.
  final String command;

  /// The absolute working directory. Defaults to `/workspace`.
  final String? cwd;

  /// Sends `cwd: null`, rather than omitting it.
  final bool clearCwd;

  /// Parses [AgentSessionSetupCommandConfig] with contextual, payload-free errors.
  factory AgentSessionSetupCommandConfig.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'command',
      'cwd',
    ], 'AgentSessionSetupCommandConfig');
    return AgentSessionSetupCommandConfig(
      command: requiredAgentValue(
        json,
        'command',
        'AgentSessionSetupCommandConfig.command',
        requireAgentString,
        nullable: false,
      )!,
      cwd: optionalAgentValue(
        json,
        'cwd',
        'AgentSessionSetupCommandConfig.cwd',
        requireAgentString,
        nullable: true,
      ),
      clearCwd: json.containsKey('cwd') && json['cwd'] == null,
    );
  }
  @override
  void validate() {
    if (cwd != null) _validateAgentSessionAbsolutePath(cwd!, 'Setup cwd');
    validateAgentLength(
      command,
      'AgentSessionSetupCommandConfig.command',
      min: 0,
      max: 65536,
    );
    if (cwd != null) {
      validateAgentLength(
        cwd!,
        'AgentSessionSetupCommandConfig.cwd',
        min: 0,
        max: 4096,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'command': command,
    if (clearCwd) 'cwd': null else 'cwd': ?cwd,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSetupCommandConfig copyWith({
    String? command,
    Object? cwd = unsetCopyWithValue,
    bool? clearCwd,
  }) => AgentSessionSetupCommandConfig(
    command: command ?? this.command,
    cwd: copyAgentValue<String>(
      cwd,
      this.cwd,
      'AgentSessionSetupCommandConfig.cwd',
    ),
    clearCwd:
        clearCwd ??
        (identical(cwd, unsetCopyWithValue) ? this.clearCwd : cwd == null),
  );
}
