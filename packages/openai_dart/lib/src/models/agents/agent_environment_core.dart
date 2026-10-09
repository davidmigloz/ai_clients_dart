part of 'agent_environment_models.dart';

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentEnvironmentList extends AgentJsonModel {
  /// Creates a validated [AgentEnvironmentList].
  AgentEnvironmentList({
    required List<AgentEnvironment> data,
    required this.firstId,
    required this.hasMore,
    required this.lastId,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = _environmentReceivedExtras(rawJson, const [
         'data',
         'first_id',
         'has_more',
         'last_id',
         'object',
       ], 'AgentEnvironmentList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<AgentEnvironment> data;

  /// The ID of the first resource in `data`, or `null` if the page is empty.
  final String? firstId;

  /// Whether there are more resources to retrieve after this page.
  final bool hasMore;

  /// The ID of the last resource in `data`, or `null` if the page is empty. Pass this as `after` with the same order and filters.
  final String? lastId;

  /// The object type, which is always `list`.
  String get object => 'list';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentEnvironmentList] with contextual, payload-free errors.
  factory AgentEnvironmentList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentEnvironmentList');
    _rejectEnvironmentReadback(json, 'AgentEnvironmentList');
    return AgentEnvironmentList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentEnvironmentList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) =>
                  AgentEnvironment.fromJson(requireAgentObject(value, context)),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentEnvironmentList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentEnvironmentList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentEnvironmentList.lastId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'data',
            'first_id',
            'has_more',
            'last_id',
            'object',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    _rejectEnvironmentReadback(toJson(), 'AgentEnvironmentList');
    validateAgentCount(
      data.length,
      'AgentEnvironmentList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'AgentEnvironmentList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'AgentEnvironmentList.lastId', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'data': data.map((value) => value.toJson()).toList(),
    'first_id': firstId,
    'has_more': hasMore,
    'last_id': lastId,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentEnvironmentList copyWith({
    List<AgentEnvironment>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentEnvironmentList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'AgentEnvironmentList.firstId',
    ),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'AgentEnvironmentList.lastId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Parameters for creating an execution environment before its sessions.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateAgentEnvironmentRequest extends AgentJsonModel {
  /// Creates a validated [CreateAgentEnvironmentRequest].
  CreateAgentEnvironmentRequest({
    required this.environment,
    List<String>? vaultIds,
    bool clearVaultIds = false,
  }) : clearVaultIds = clearVaultIds,
       vaultIds = ownAgentValue<List<String>>(
         clearVaultIds ? null : vaultIds,
         List.unmodifiable,
       ) {
    validate();
  }

  /// The required hosting type and its configuration.
  final AgentPrewarmEnvironment environment;

  /// The IDs of up to 10 vaults made available to an OpenAI-hosted environment.
  final List<String>? vaultIds;

  /// Sends `vault_ids: null`, rather than omitting it.
  final bool clearVaultIds;

  /// Parses [CreateAgentEnvironmentRequest] with contextual, payload-free errors.
  factory CreateAgentEnvironmentRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'environment',
      'vault_ids',
    ], 'CreateAgentEnvironmentRequest');
    return CreateAgentEnvironmentRequest(
      environment: requiredAgentValue(
        json,
        'environment',
        'CreateAgentEnvironmentRequest.environment',
        (value, context) => AgentPrewarmEnvironment.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      vaultIds: optionalAgentValue(
        json,
        'vault_ids',
        'CreateAgentEnvironmentRequest.vaultIds',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearVaultIds: json.containsKey('vault_ids') && json['vault_ids'] == null,
    );
  }
  @override
  void validate() {
    environment.validate();
    if (vaultIds != null) {
      validateAgentCount(
        vaultIds!.length,
        'CreateAgentEnvironmentRequest.vaultIds',
        min: 0,
        max: 10,
      );
      for (final item in vaultIds!) {
        validateAgentLength(
          item,
          'CreateAgentEnvironmentRequest.vaultIds',
          min: 0,
          max: 1048576,
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'environment': environment.toJson(),
    if (clearVaultIds)
      'vault_ids': null
    else if (vaultIds != null)
      'vault_ids': vaultIds!.map((value) => value).toList(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateAgentEnvironmentRequest copyWith({
    AgentPrewarmEnvironment? environment,
    Object? vaultIds = unsetCopyWithValue,
    bool? clearVaultIds,
  }) => CreateAgentEnvironmentRequest(
    environment: environment ?? this.environment,
    vaultIds: copyAgentValue<List<String>>(
      vaultIds,
      this.vaultIds,
      'CreateAgentEnvironmentRequest.vaultIds',
    ),
    clearVaultIds:
        clearVaultIds ??
        (identical(vaultIds, unsetCopyWithValue)
            ? this.clearVaultIds
            : vaultIds == null),
  );
}

/// Configuration for a new prewarmed OpenAI-hosted environment.
///
/// Variants: [AgentPrewarmHostedEnvironment] and [UnknownAgentPrewarmEnvironment].
sealed class AgentPrewarmEnvironment extends AgentJsonModel {
  const AgentPrewarmEnvironment();

  /// Parses known variants strictly and retains future received variants.
  factory AgentPrewarmEnvironment.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'AgentPrewarmEnvironment.type',
      )) {
        'openai_hosted' => AgentPrewarmHostedEnvironment.fromJson(json),
        _ => UnknownAgentPrewarmEnvironment.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `openai_hosted` variant.
  factory AgentPrewarmEnvironment.openaiHosted({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories,
    AgentSessionDesktopConfig? desktop,
    bool clearDesktop,
    Map<String, String>? env,
    bool clearEnv,
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
  }) = AgentPrewarmHostedEnvironment;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentPrewarmEnvironment extends AgentPrewarmEnvironment {
  const UnknownAgentPrewarmEnvironment._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentPrewarmEnvironment.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentPrewarmEnvironment.type',
    );
    if (const ['openai_hosted'].contains(type)) {
      throw const FormatException(
        'UnknownAgentPrewarmEnvironment: expected a future type',
      );
    }
    return UnknownAgentPrewarmEnvironment._(
      snapshotAgentJson(json, 'UnknownAgentPrewarmEnvironment'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentPrewarmEnvironment copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentPrewarmEnvironment.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownAgentPrewarmEnvironment: future environment configurations are not writable',
  );
}

/// Provision an OpenAI-hosted environment from inline configuration or a template.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentPrewarmHostedEnvironment extends AgentPrewarmEnvironment {
  /// Creates a validated [AgentPrewarmHostedEnvironment].
  AgentPrewarmHostedEnvironment({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories = false,
    AgentSessionDesktopConfig? desktop,
    bool clearDesktop = false,
    Map<String, String>? env,
    bool clearEnv = false,
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

  /// Desktop provisioning. Omission or null inherits the template setting, or defaults to disabled.
  final AgentSessionDesktopConfig? desktop;

  /// Sends `desktop: null`, rather than omitting it.
  final bool clearDesktop;

  /// Environment variables made available to the agent.
  final Map<String, String>? env;

  /// Sends `env: null`, rather than omitting it.
  final bool clearEnv;

  /// A reusable hosted template applied before inline configuration. Omitted fields inherit the template; network overrides cannot broaden its policy.
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

  /// Parses [AgentPrewarmHostedEnvironment] with contextual, payload-free errors.
  factory AgentPrewarmHostedEnvironment.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'capability_directories',
      'desktop',
      'env',
      'environment_template_id',
      'files',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
      'type',
    ], 'AgentPrewarmHostedEnvironment');
    requireAgentTag(
      json,
      'type',
      'openai_hosted',
      'AgentPrewarmHostedEnvironment',
    );
    return AgentPrewarmHostedEnvironment(
      capabilityDirectories: optionalAgentValue(
        json,
        'capability_directories',
        'AgentPrewarmHostedEnvironment.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearCapabilityDirectories:
          json.containsKey('capability_directories') &&
          json['capability_directories'] == null,
      desktop: optionalAgentValue(
        json,
        'desktop',
        'AgentPrewarmHostedEnvironment.desktop',
        (value, context) => AgentSessionDesktopConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearDesktop: json.containsKey('desktop') && json['desktop'] == null,
      env: optionalAgentValue(
        json,
        'env',
        'AgentPrewarmHostedEnvironment.env',
        requireAgentStringMap,
        nullable: true,
      ),
      clearEnv: json.containsKey('env') && json['env'] == null,
      environmentTemplateId: optionalAgentValue(
        json,
        'environment_template_id',
        'AgentPrewarmHostedEnvironment.environmentTemplateId',
        requireAgentString,
        nullable: false,
      ),
      files: optionalAgentValue(
        json,
        'files',
        'AgentPrewarmHostedEnvironment.files',
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
        'AgentPrewarmHostedEnvironment.network',
        (value, context) => AgentSessionNetworkPolicyConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearNetwork: json.containsKey('network') && json['network'] == null,
      packages: optionalAgentValue(
        json,
        'packages',
        'AgentPrewarmHostedEnvironment.packages',
        (value, context) => AgentSessionEnvironmentPackagesConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearPackages: json.containsKey('packages') && json['packages'] == null,
      plugins: optionalAgentValue(
        json,
        'plugins',
        'AgentPrewarmHostedEnvironment.plugins',
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
        'AgentPrewarmHostedEnvironment.setupCommands',
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
        'AgentPrewarmHostedEnvironment.skills',
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
    validateAgentHostedFileBudget(files);
    if (capabilityDirectories != null) {
      for (final path in capabilityDirectories!) {
        if (!path.startsWith('/') || path.contains('\u0000')) {
          throw const FormatException(
            'Capability directory: expected an absolute path',
          );
        }
      }
    }
    if (capabilityDirectories != null) {
      validateAgentCount(
        capabilityDirectories!.length,
        'AgentPrewarmHostedEnvironment.capabilityDirectories',
        min: 0,
        max: 16384,
      );
      for (final item in capabilityDirectories!) {
        validateAgentLength(
          item,
          'AgentPrewarmHostedEnvironment.capabilityDirectories',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (desktop != null) {
      desktop!.validate();
    }
    if (env != null) {
      validateAgentCount(
        env!.length,
        'AgentPrewarmHostedEnvironment.env',
        min: 0,
        max: 1024,
      );
      for (final key in env!.keys) {
        validateAgentLength(
          key,
          'AgentPrewarmHostedEnvironment.env',
          min: 1,
          max: 256,
        );
      }
      for (final item in env!.values) {
        validateAgentLength(
          item,
          'AgentPrewarmHostedEnvironment.env',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (environmentTemplateId != null) {
      validateAgentLength(
        environmentTemplateId!,
        'AgentPrewarmHostedEnvironment.environmentTemplateId',
        min: 0,
        max: 64,
      );
    }
    if (files != null) {
      validateAgentCount(
        files!.length,
        'AgentPrewarmHostedEnvironment.files',
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
        'AgentPrewarmHostedEnvironment.plugins',
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
        'AgentPrewarmHostedEnvironment.setupCommands',
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
        'AgentPrewarmHostedEnvironment.skills',
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
    if (clearDesktop)
      'desktop': null
    else if (desktop != null)
      'desktop': desktop!.toJson(),
    if (clearEnv) 'env': null else 'env': ?env,
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
  AgentPrewarmHostedEnvironment copyWith({
    Object? capabilityDirectories = unsetCopyWithValue,
    bool? clearCapabilityDirectories,
    Object? desktop = unsetCopyWithValue,
    bool? clearDesktop,
    Object? env = unsetCopyWithValue,
    bool? clearEnv,
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
  }) => AgentPrewarmHostedEnvironment(
    capabilityDirectories: copyAgentValue<List<String>>(
      capabilityDirectories,
      this.capabilityDirectories,
      'AgentPrewarmHostedEnvironment.capabilityDirectories',
    ),
    clearCapabilityDirectories:
        clearCapabilityDirectories ??
        (identical(capabilityDirectories, unsetCopyWithValue)
            ? this.clearCapabilityDirectories
            : capabilityDirectories == null),
    desktop: copyAgentValue<AgentSessionDesktopConfig>(
      desktop,
      this.desktop,
      'AgentPrewarmHostedEnvironment.desktop',
    ),
    clearDesktop:
        clearDesktop ??
        (identical(desktop, unsetCopyWithValue)
            ? this.clearDesktop
            : desktop == null),
    env: copyAgentValue<Map<String, String>>(
      env,
      this.env,
      'AgentPrewarmHostedEnvironment.env',
    ),
    clearEnv:
        clearEnv ??
        (identical(env, unsetCopyWithValue) ? this.clearEnv : env == null),
    environmentTemplateId: copyAgentValue<String>(
      environmentTemplateId,
      this.environmentTemplateId,
      'AgentPrewarmHostedEnvironment.environmentTemplateId',
    ),
    files: copyAgentValue<List<AgentSessionHostedEnvironmentFileConfig>>(
      files,
      this.files,
      'AgentPrewarmHostedEnvironment.files',
    ),
    clearFiles:
        clearFiles ??
        (identical(files, unsetCopyWithValue)
            ? this.clearFiles
            : files == null),
    network: copyAgentValue<AgentSessionNetworkPolicyConfig>(
      network,
      this.network,
      'AgentPrewarmHostedEnvironment.network',
    ),
    clearNetwork:
        clearNetwork ??
        (identical(network, unsetCopyWithValue)
            ? this.clearNetwork
            : network == null),
    packages: copyAgentValue<AgentSessionEnvironmentPackagesConfig>(
      packages,
      this.packages,
      'AgentPrewarmHostedEnvironment.packages',
    ),
    clearPackages:
        clearPackages ??
        (identical(packages, unsetCopyWithValue)
            ? this.clearPackages
            : packages == null),
    plugins: copyAgentValue<List<AgentSessionHostedPluginConfig>>(
      plugins,
      this.plugins,
      'AgentPrewarmHostedEnvironment.plugins',
    ),
    clearPlugins:
        clearPlugins ??
        (identical(plugins, unsetCopyWithValue)
            ? this.clearPlugins
            : plugins == null),
    setupCommands: copyAgentValue<List<AgentSessionSetupCommandConfig>>(
      setupCommands,
      this.setupCommands,
      'AgentPrewarmHostedEnvironment.setupCommands',
    ),
    clearSetupCommands:
        clearSetupCommands ??
        (identical(setupCommands, unsetCopyWithValue)
            ? this.clearSetupCommands
            : setupCommands == null),
    skills: copyAgentValue<List<AgentSessionHostedSkillConfig>>(
      skills,
      this.skills,
      'AgentPrewarmHostedEnvironment.skills',
    ),
    clearSkills:
        clearSkills ??
        (identical(skills, unsetCopyWithValue)
            ? this.clearSkills
            : skills == null),
  );
}

/// The public lifecycle status of an execution environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentEnvironmentStatus extends AgentJsonModel {
  const AgentEnvironmentStatus._(this.value);

  /// The `pending` wire value.
  static const AgentEnvironmentStatus pending = AgentEnvironmentStatus._(
    'pending',
  );

  /// The `ready` wire value.
  static const AgentEnvironmentStatus ready = AgentEnvironmentStatus._('ready');

  /// The `connected` wire value.
  static const AgentEnvironmentStatus connected = AgentEnvironmentStatus._(
    'connected',
  );

  /// The `disconnected` wire value.
  static const AgentEnvironmentStatus disconnected = AgentEnvironmentStatus._(
    'disconnected',
  );

  /// The `suspended` wire value.
  static const AgentEnvironmentStatus suspended = AgentEnvironmentStatus._(
    'suspended',
  );

  /// The `expired` wire value.
  static const AgentEnvironmentStatus expired = AgentEnvironmentStatus._(
    'expired',
  );

  /// The `failed` wire value.
  static const AgentEnvironmentStatus failed = AgentEnvironmentStatus._(
    'failed',
  );

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentEnvironmentStatus.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentEnvironmentStatus');
    return switch (value) {
      'pending' => pending,
      'ready' => ready,
      'connected' => connected,
      'disconnected' => disconnected,
      'suspended' => suspended,
      'expired' => expired,
      'failed' => failed,
      _ => AgentEnvironmentStatus._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const [
    'pending',
    'ready',
    'connected',
    'disconnected',
    'suspended',
    'expired',
    'failed',
  ].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future received string.
  AgentEnvironmentStatus copyWith({String? value}) =>
      AgentEnvironmentStatus.fromJson(value ?? this.value);
}

/// The hosting type of an execution environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentEnvironmentType extends AgentJsonModel {
  const AgentEnvironmentType._(this.value);

  /// The `openai_hosted` wire value.
  static const AgentEnvironmentType openaiHosted = AgentEnvironmentType._(
    'openai_hosted',
  );

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentEnvironmentType.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentEnvironmentType');
    return switch (value) {
      'openai_hosted' => openaiHosted,
      _ => AgentEnvironmentType._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['openai_hosted'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future received string.
  AgentEnvironmentType copyWith({String? value}) =>
      AgentEnvironmentType.fromJson(value ?? this.value);
}

/// The kind of execution environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentEnvironmentTypeResource extends AgentJsonModel {
  const AgentEnvironmentTypeResource._(this.value);

  /// The `openai_hosted` wire value.
  static const AgentEnvironmentTypeResource openaiHosted =
      AgentEnvironmentTypeResource._('openai_hosted');

  /// The `self_hosted` wire value.
  static const AgentEnvironmentTypeResource selfHosted =
      AgentEnvironmentTypeResource._('self_hosted');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentEnvironmentTypeResource.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentEnvironmentTypeResource');
    return switch (value) {
      'openai_hosted' => openaiHosted,
      'self_hosted' => selfHosted,
      _ => AgentEnvironmentTypeResource._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['openai_hosted', 'self_hosted'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future received string.
  AgentEnvironmentTypeResource copyWith({String? value}) =>
      AgentEnvironmentTypeResource.fromJson(value ?? this.value);
}

/// Safe metadata for a first-class execution environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentEnvironment extends AgentJsonModel {
  /// Creates a validated [AgentEnvironment].
  AgentEnvironment({
    required List<AgentSessionHostedEnvironmentFileResource> files,
    required this.id,
    required List<AgentSessionHostedPluginResource> plugins,
    required List<AgentSessionHostedSkillResource> skills,
    required this.status,
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : files = List.unmodifiable(files),
       plugins = List.unmodifiable(plugins),
       skills = List.unmodifiable(skills),
       rawJson = _environmentReceivedExtras(rawJson, const [
         'files',
         'id',
         'object',
         'plugins',
         'skills',
         'status',
         'type',
       ], 'AgentEnvironment') {
    validate();
  }

  /// Files installed in the environment, without their contents.
  final List<AgentSessionHostedEnvironmentFileResource> files;

  /// The ID of the environment.
  final String id;

  /// The object type. Always `agent.environment`.
  String get object => 'agent.environment';

  /// Plugins installed in the environment, without their archive contents.
  final List<AgentSessionHostedPluginResource> plugins;

  /// Skills installed in the environment, without their archive contents.
  final List<AgentSessionHostedSkillResource> skills;

  /// The current environment connection status.
  final AgentEnvironmentStatus status;

  /// Whether the environment is hosted by OpenAI or by the application.
  final AgentEnvironmentTypeResource type;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentEnvironment] with contextual, payload-free errors.
  factory AgentEnvironment.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'agent.environment', 'AgentEnvironment');
    _rejectEnvironmentReadback(json, 'AgentEnvironment');
    return AgentEnvironment(
      files: requiredAgentValue(
        json,
        'files',
        'AgentEnvironment.files',
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
        'AgentEnvironment.id',
        requireAgentString,
        nullable: false,
      )!,
      plugins: requiredAgentValue(
        json,
        'plugins',
        'AgentEnvironment.plugins',
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
        'AgentEnvironment.skills',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionHostedSkillResource.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      status: requiredAgentValue(
        json,
        'status',
        'AgentEnvironment.status',
        (value, context) => AgentEnvironmentStatus.fromJson(value),
        nullable: false,
      )!,
      type: requiredAgentValue(
        json,
        'type',
        'AgentEnvironment.type',
        (value, context) => AgentEnvironmentTypeResource.fromJson(value),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'files',
            'id',
            'object',
            'plugins',
            'skills',
            'status',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    _rejectEnvironmentReadback(toJson(), 'AgentEnvironment');
    validateAgentCount(
      files.length,
      'AgentEnvironment.files',
      min: 0,
      max: 2000,
    );
    for (final item in files) {
      item.validate();
    }
    validateAgentLength(id, 'AgentEnvironment.id', min: 0);
    validateAgentCount(
      plugins.length,
      'AgentEnvironment.plugins',
      min: 0,
      max: 2000,
    );
    for (final item in plugins) {
      item.validate();
    }
    validateAgentCount(
      skills.length,
      'AgentEnvironment.skills',
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
    'files': files.map((value) => value.toJson()).toList(),
    'id': id,
    'object': object,
    'plugins': plugins.map((value) => value.toJson()).toList(),
    'skills': skills.map((value) => value.toJson()).toList(),
    'status': status.toJson(),
    'type': type.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentEnvironment copyWith({
    List<AgentSessionHostedEnvironmentFileResource>? files,
    String? id,
    List<AgentSessionHostedPluginResource>? plugins,
    List<AgentSessionHostedSkillResource>? skills,
    AgentEnvironmentStatus? status,
    AgentEnvironmentTypeResource? type,
    Map<String, dynamic>? rawJson,
  }) => AgentEnvironment(
    files: files ?? this.files,
    id: id ?? this.id,
    plugins: plugins ?? this.plugins,
    skills: skills ?? this.skills,
    status: status ?? this.status,
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
}
