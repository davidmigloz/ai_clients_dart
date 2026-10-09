part of 'agent_environment_models.dart';

/// Parameters for creating a reusable, project-scoped OpenAI-hosted environment template.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateAgentEnvironmentTemplateRequest extends AgentJsonModel {
  /// Creates a validated [CreateAgentEnvironmentTemplateRequest].
  CreateAgentEnvironmentTemplateRequest({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories = false,
    AgentSessionDesktopConfig? desktop,
    bool clearDesktop = false,
    Map<String, String>? env,
    bool clearEnv = false,
    List<AgentSessionHostedEnvironmentFileConfig>? files,
    bool clearFiles = false,
    String? name,
    bool clearName = false,
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
       clearName = clearName,
       name = clearName ? null : name,
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

  /// Files available before the agent starts. Defaults to an empty list.
  final List<AgentSessionHostedEnvironmentFileConfig>? files;

  /// Sends `files: null`, rather than omitting it.
  final bool clearFiles;

  /// An optional human-readable display name for the template.
  final String? name;

  /// Sends `name: null`, rather than omitting it.
  final bool clearName;

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

  /// Parses [CreateAgentEnvironmentTemplateRequest] with contextual, payload-free errors.
  factory CreateAgentEnvironmentTemplateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'capability_directories',
      'desktop',
      'env',
      'files',
      'name',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
    ], 'CreateAgentEnvironmentTemplateRequest');
    return CreateAgentEnvironmentTemplateRequest(
      capabilityDirectories: optionalAgentValue(
        json,
        'capability_directories',
        'CreateAgentEnvironmentTemplateRequest.capabilityDirectories',
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
        'CreateAgentEnvironmentTemplateRequest.desktop',
        (value, context) => AgentSessionDesktopConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearDesktop: json.containsKey('desktop') && json['desktop'] == null,
      env: optionalAgentValue(
        json,
        'env',
        'CreateAgentEnvironmentTemplateRequest.env',
        requireAgentStringMap,
        nullable: true,
      ),
      clearEnv: json.containsKey('env') && json['env'] == null,
      files: optionalAgentValue(
        json,
        'files',
        'CreateAgentEnvironmentTemplateRequest.files',
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
      name: optionalAgentValue(
        json,
        'name',
        'CreateAgentEnvironmentTemplateRequest.name',
        requireAgentString,
        nullable: true,
      ),
      clearName: json.containsKey('name') && json['name'] == null,
      network: optionalAgentValue(
        json,
        'network',
        'CreateAgentEnvironmentTemplateRequest.network',
        (value, context) => AgentSessionNetworkPolicyConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearNetwork: json.containsKey('network') && json['network'] == null,
      packages: optionalAgentValue(
        json,
        'packages',
        'CreateAgentEnvironmentTemplateRequest.packages',
        (value, context) => AgentSessionEnvironmentPackagesConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearPackages: json.containsKey('packages') && json['packages'] == null,
      plugins: optionalAgentValue(
        json,
        'plugins',
        'CreateAgentEnvironmentTemplateRequest.plugins',
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
        'CreateAgentEnvironmentTemplateRequest.setupCommands',
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
        'CreateAgentEnvironmentTemplateRequest.skills',
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
        'CreateAgentEnvironmentTemplateRequest.capabilityDirectories',
        min: 0,
        max: 16384,
      );
      for (final item in capabilityDirectories!) {
        validateAgentLength(
          item,
          'CreateAgentEnvironmentTemplateRequest.capabilityDirectories',
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
        'CreateAgentEnvironmentTemplateRequest.env',
        min: 0,
        max: 1024,
      );
      for (final key in env!.keys) {
        validateAgentLength(
          key,
          'CreateAgentEnvironmentTemplateRequest.env',
          min: 1,
          max: 256,
        );
      }
      for (final item in env!.values) {
        validateAgentLength(
          item,
          'CreateAgentEnvironmentTemplateRequest.env',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (files != null) {
      validateAgentCount(
        files!.length,
        'CreateAgentEnvironmentTemplateRequest.files',
        min: 0,
        max: 50,
      );
      for (final item in files!) {
        item.validate();
      }
    }
    if (name != null) {
      validateAgentLength(
        name!,
        'CreateAgentEnvironmentTemplateRequest.name',
        min: 1,
        max: 256,
      );
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
        'CreateAgentEnvironmentTemplateRequest.plugins',
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
        'CreateAgentEnvironmentTemplateRequest.setupCommands',
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
        'CreateAgentEnvironmentTemplateRequest.skills',
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
    if (clearFiles)
      'files': null
    else if (files != null)
      'files': files!.map((value) => value.toJson()).toList(),
    if (clearName) 'name': null else 'name': ?name,
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
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateAgentEnvironmentTemplateRequest copyWith({
    Object? capabilityDirectories = unsetCopyWithValue,
    bool? clearCapabilityDirectories,
    Object? desktop = unsetCopyWithValue,
    bool? clearDesktop,
    Object? env = unsetCopyWithValue,
    bool? clearEnv,
    Object? files = unsetCopyWithValue,
    bool? clearFiles,
    Object? name = unsetCopyWithValue,
    bool? clearName,
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
  }) => CreateAgentEnvironmentTemplateRequest(
    capabilityDirectories: copyAgentValue<List<String>>(
      capabilityDirectories,
      this.capabilityDirectories,
      'CreateAgentEnvironmentTemplateRequest.capabilityDirectories',
    ),
    clearCapabilityDirectories:
        clearCapabilityDirectories ??
        (identical(capabilityDirectories, unsetCopyWithValue)
            ? this.clearCapabilityDirectories
            : capabilityDirectories == null),
    desktop: copyAgentValue<AgentSessionDesktopConfig>(
      desktop,
      this.desktop,
      'CreateAgentEnvironmentTemplateRequest.desktop',
    ),
    clearDesktop:
        clearDesktop ??
        (identical(desktop, unsetCopyWithValue)
            ? this.clearDesktop
            : desktop == null),
    env: copyAgentValue<Map<String, String>>(
      env,
      this.env,
      'CreateAgentEnvironmentTemplateRequest.env',
    ),
    clearEnv:
        clearEnv ??
        (identical(env, unsetCopyWithValue) ? this.clearEnv : env == null),
    files: copyAgentValue<List<AgentSessionHostedEnvironmentFileConfig>>(
      files,
      this.files,
      'CreateAgentEnvironmentTemplateRequest.files',
    ),
    clearFiles:
        clearFiles ??
        (identical(files, unsetCopyWithValue)
            ? this.clearFiles
            : files == null),
    name: copyAgentValue<String>(
      name,
      this.name,
      'CreateAgentEnvironmentTemplateRequest.name',
    ),
    clearName:
        clearName ??
        (identical(name, unsetCopyWithValue) ? this.clearName : name == null),
    network: copyAgentValue<AgentSessionNetworkPolicyConfig>(
      network,
      this.network,
      'CreateAgentEnvironmentTemplateRequest.network',
    ),
    clearNetwork:
        clearNetwork ??
        (identical(network, unsetCopyWithValue)
            ? this.clearNetwork
            : network == null),
    packages: copyAgentValue<AgentSessionEnvironmentPackagesConfig>(
      packages,
      this.packages,
      'CreateAgentEnvironmentTemplateRequest.packages',
    ),
    clearPackages:
        clearPackages ??
        (identical(packages, unsetCopyWithValue)
            ? this.clearPackages
            : packages == null),
    plugins: copyAgentValue<List<AgentSessionHostedPluginConfig>>(
      plugins,
      this.plugins,
      'CreateAgentEnvironmentTemplateRequest.plugins',
    ),
    clearPlugins:
        clearPlugins ??
        (identical(plugins, unsetCopyWithValue)
            ? this.clearPlugins
            : plugins == null),
    setupCommands: copyAgentValue<List<AgentSessionSetupCommandConfig>>(
      setupCommands,
      this.setupCommands,
      'CreateAgentEnvironmentTemplateRequest.setupCommands',
    ),
    clearSetupCommands:
        clearSetupCommands ??
        (identical(setupCommands, unsetCopyWithValue)
            ? this.clearSetupCommands
            : setupCommands == null),
    skills: copyAgentValue<List<AgentSessionHostedSkillConfig>>(
      skills,
      this.skills,
      'CreateAgentEnvironmentTemplateRequest.skills',
    ),
    clearSkills:
        clearSkills ??
        (identical(skills, unsetCopyWithValue)
            ? this.clearSkills
            : skills == null),
  );
}

/// A deleted reusable environment template.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class DeletedAgentEnvironmentTemplate extends AgentJsonModel {
  /// Creates a validated [DeletedAgentEnvironmentTemplate].
  DeletedAgentEnvironmentTemplate({
    required this.deleted,
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _environmentReceivedExtras(rawJson, const [
         'deleted',
         'id',
         'object',
       ], 'DeletedAgentEnvironmentTemplate') {
    validate();
  }

  /// Whether the environment template was deleted. Always `true`.
  final bool deleted;

  /// The ID of the deleted environment template.
  final String id;

  /// The object type. Always `agent.environment.template.deleted`.
  String get object => 'agent.environment.template.deleted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [DeletedAgentEnvironmentTemplate] with contextual, payload-free errors.
  factory DeletedAgentEnvironmentTemplate.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.environment.template.deleted',
      'DeletedAgentEnvironmentTemplate',
    );
    _rejectEnvironmentReadback(json, 'DeletedAgentEnvironmentTemplate');
    return DeletedAgentEnvironmentTemplate(
      deleted: requiredAgentValue(
        json,
        'deleted',
        'DeletedAgentEnvironmentTemplate.deleted',
        requireAgentBool,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'DeletedAgentEnvironmentTemplate.id',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['deleted', 'id', 'object'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    _rejectEnvironmentReadback(toJson(), 'DeletedAgentEnvironmentTemplate');
    validateAgentLength(id, 'DeletedAgentEnvironmentTemplate.id', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'deleted': deleted,
    'id': id,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  DeletedAgentEnvironmentTemplate copyWith({
    bool? deleted,
    String? id,
    Map<String, dynamic>? rawJson,
  }) => DeletedAgentEnvironmentTemplate(
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentEnvironmentTemplateList extends AgentJsonModel {
  /// Creates a validated [AgentEnvironmentTemplateList].
  AgentEnvironmentTemplateList({
    required List<AgentEnvironmentTemplate> data,
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
       ], 'AgentEnvironmentTemplateList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<AgentEnvironmentTemplate> data;

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

  /// Parses [AgentEnvironmentTemplateList] with contextual, payload-free errors.
  factory AgentEnvironmentTemplateList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentEnvironmentTemplateList');
    _rejectEnvironmentReadback(json, 'AgentEnvironmentTemplateList');
    return AgentEnvironmentTemplateList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentEnvironmentTemplateList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentEnvironmentTemplate.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentEnvironmentTemplateList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentEnvironmentTemplateList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentEnvironmentTemplateList.lastId',
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
    _rejectEnvironmentReadback(toJson(), 'AgentEnvironmentTemplateList');
    validateAgentCount(
      data.length,
      'AgentEnvironmentTemplateList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(
        firstId!,
        'AgentEnvironmentTemplateList.firstId',
        min: 0,
      );
    }
    if (lastId != null) {
      validateAgentLength(
        lastId!,
        'AgentEnvironmentTemplateList.lastId',
        min: 0,
      );
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
  AgentEnvironmentTemplateList copyWith({
    List<AgentEnvironmentTemplate>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentEnvironmentTemplateList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'AgentEnvironmentTemplateList.firstId',
    ),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'AgentEnvironmentTemplateList.lastId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Reusable configuration that provisions a fresh OpenAI-hosted environment for each session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentEnvironmentTemplate extends AgentJsonModel {
  /// Creates a validated [AgentEnvironmentTemplate].
  AgentEnvironmentTemplate({
    required List<String> capabilityDirectories,
    required this.createdAt,
    required this.desktop,
    required List<AgentHostedTemplateFile> files,
    required this.id,
    required this.name,
    required this.network,
    required this.packages,
    required List<AgentSessionHostedPluginResource> plugins,
    required List<AgentHostedTemplateSkill> skills,
    required this.updatedAt,
    Map<String, dynamic> rawJson = const {},
  }) : capabilityDirectories = List.unmodifiable(capabilityDirectories),
       files = List.unmodifiable(files),
       plugins = List.unmodifiable(plugins),
       skills = List.unmodifiable(skills),
       rawJson = _environmentReceivedExtras(rawJson, const [
         'capability_directories',
         'created_at',
         'desktop',
         'files',
         'id',
         'name',
         'network',
         'object',
         'packages',
         'plugins',
         'skills',
         'updated_at',
       ], 'AgentEnvironmentTemplate') {
    validate();
  }

  /// Directories that expose capabilities to the agent.
  final List<String> capabilityDirectories;

  /// The Unix timestamp, in seconds, when the template was created.
  final int createdAt;

  /// Desktop configuration for each OpenAI-hosted environment.
  final AgentSessionDesktopResource desktop;

  /// Safe file metadata, excluding contents and session-scoped file IDs.
  final List<AgentHostedTemplateFile> files;

  /// The ID of the reusable environment template.
  final String id;

  /// An optional human-readable display name for the template.
  final String? name;

  /// Runtime network access for each OpenAI-hosted environment.
  final AgentSessionNetworkPolicyResource network;

  /// The object type. Always `agent.environment.template`.
  String get object => 'agent.environment.template';

  /// Packages installed in each fresh OpenAI-hosted environment.
  final AgentSessionEnvironmentPackagesResource packages;

  /// Safe plugin metadata, excluding inline archive contents.
  final List<AgentSessionHostedPluginResource> plugins;

  /// Safe skill metadata, preserving unresolved version selectors.
  final List<AgentHostedTemplateSkill> skills;

  /// The Unix timestamp, in seconds, when the template was last updated.
  final int updatedAt;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentEnvironmentTemplate] with contextual, payload-free errors.
  factory AgentEnvironmentTemplate.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.environment.template',
      'AgentEnvironmentTemplate',
    );
    _rejectEnvironmentReadback(json, 'AgentEnvironmentTemplate');
    return AgentEnvironmentTemplate(
      capabilityDirectories: requiredAgentValue(
        json,
        'capability_directories',
        'AgentEnvironmentTemplate.capabilityDirectories',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentEnvironmentTemplate.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      desktop: requiredAgentValue(
        json,
        'desktop',
        'AgentEnvironmentTemplate.desktop',
        (value, context) => AgentSessionDesktopResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      files: requiredAgentValue(
        json,
        'files',
        'AgentEnvironmentTemplate.files',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentHostedTemplateFile.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentEnvironmentTemplate.id',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentEnvironmentTemplate.name',
        requireAgentString,
        nullable: true,
      ),
      network: requiredAgentValue(
        json,
        'network',
        'AgentEnvironmentTemplate.network',
        (value, context) => AgentSessionNetworkPolicyResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      packages: requiredAgentValue(
        json,
        'packages',
        'AgentEnvironmentTemplate.packages',
        (value, context) => AgentSessionEnvironmentPackagesResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      plugins: requiredAgentValue(
        json,
        'plugins',
        'AgentEnvironmentTemplate.plugins',
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
        'AgentEnvironmentTemplate.skills',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentHostedTemplateSkill.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      updatedAt: requiredAgentValue(
        json,
        'updated_at',
        'AgentEnvironmentTemplate.updatedAt',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'capability_directories',
            'created_at',
            'desktop',
            'files',
            'id',
            'name',
            'network',
            'object',
            'packages',
            'plugins',
            'skills',
            'updated_at',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    _rejectEnvironmentReadback(toJson(), 'AgentEnvironmentTemplate');
    validateAgentCount(
      capabilityDirectories.length,
      'AgentEnvironmentTemplate.capabilityDirectories',
      min: 0,
      max: 2000,
    );
    for (final item in capabilityDirectories) {
      validateAgentLength(
        item,
        'AgentEnvironmentTemplate.capabilityDirectories',
        min: 0,
      );
    }
    validateAgentInt(createdAt, 'AgentEnvironmentTemplate.createdAt');
    desktop.validate();
    validateAgentCount(
      files.length,
      'AgentEnvironmentTemplate.files',
      min: 0,
      max: 50,
    );
    for (final item in files) {
      item.validate();
    }
    validateAgentLength(id, 'AgentEnvironmentTemplate.id', min: 0);
    if (name != null) {
      validateAgentLength(name!, 'AgentEnvironmentTemplate.name', min: 0);
    }
    network.validate();
    packages.validate();
    validateAgentCount(
      plugins.length,
      'AgentEnvironmentTemplate.plugins',
      min: 0,
      max: 32,
    );
    for (final item in plugins) {
      item.validate();
    }
    validateAgentCount(
      skills.length,
      'AgentEnvironmentTemplate.skills',
      min: 0,
      max: 200,
    );
    for (final item in skills) {
      item.validate();
    }
    validateAgentInt(updatedAt, 'AgentEnvironmentTemplate.updatedAt');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'capability_directories': capabilityDirectories
        .map((value) => value)
        .toList(),
    'created_at': createdAt,
    'desktop': desktop.toJson(),
    'files': files.map((value) => value.toJson()).toList(),
    'id': id,
    'name': name,
    'network': network.toJson(),
    'object': object,
    'packages': packages.toJson(),
    'plugins': plugins.map((value) => value.toJson()).toList(),
    'skills': skills.map((value) => value.toJson()).toList(),
    'updated_at': updatedAt,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentEnvironmentTemplate copyWith({
    List<String>? capabilityDirectories,
    int? createdAt,
    AgentSessionDesktopResource? desktop,
    List<AgentHostedTemplateFile>? files,
    String? id,
    Object? name = unsetCopyWithValue,
    AgentSessionNetworkPolicyResource? network,
    AgentSessionEnvironmentPackagesResource? packages,
    List<AgentSessionHostedPluginResource>? plugins,
    List<AgentHostedTemplateSkill>? skills,
    int? updatedAt,
    Map<String, dynamic>? rawJson,
  }) => AgentEnvironmentTemplate(
    capabilityDirectories: capabilityDirectories ?? this.capabilityDirectories,
    createdAt: createdAt ?? this.createdAt,
    desktop: desktop ?? this.desktop,
    files: files ?? this.files,
    id: id ?? this.id,
    name: copyAgentValue<String>(
      name,
      this.name,
      'AgentEnvironmentTemplate.name',
    ),
    network: network ?? this.network,
    packages: packages ?? this.packages,
    plugins: plugins ?? this.plugins,
    skills: skills ?? this.skills,
    updatedAt: updatedAt ?? this.updatedAt,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Safe metadata for a file configured by an environment template.
///
/// Variants: [AgentHostedTemplateFileFileId], [AgentHostedTemplateFileInline] and [UnknownAgentHostedTemplateFile].
sealed class AgentHostedTemplateFile extends AgentJsonModel {
  const AgentHostedTemplateFile();

  /// Parses known variants strictly and retains future received variants.
  factory AgentHostedTemplateFile.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'AgentHostedTemplateFile.type',
      )) {
        'file_id' => AgentHostedTemplateFileFileId.fromJson(json),
        'inline' => AgentHostedTemplateFileInline.fromJson(json),
        _ => UnknownAgentHostedTemplateFile.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `file_id` variant.
  factory AgentHostedTemplateFile.fileId({
    required String fileId,
    required String path,
    Map<String, dynamic> rawJson,
  }) = AgentHostedTemplateFileFileId;

  /// Creates the `inline` variant.
  factory AgentHostedTemplateFile.inline({
    required String path,
    required int sizeBytes,
    Map<String, dynamic> rawJson,
  }) = AgentHostedTemplateFileInline;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentHostedTemplateFile extends AgentHostedTemplateFile {
  const UnknownAgentHostedTemplateFile._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentHostedTemplateFile.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentHostedTemplateFile.type',
    );
    if (const ['file_id', 'inline'].contains(type)) {
      throw const FormatException(
        'UnknownAgentHostedTemplateFile: expected a future type',
      );
    }
    _rejectEnvironmentReadback(json, 'UnknownAgentHostedTemplateFile');
    return UnknownAgentHostedTemplateFile._(
      snapshotAgentJson(json, 'UnknownAgentHostedTemplateFile'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentHostedTemplateFile copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentHostedTemplateFile.fromJson(rawJson ?? this.rawJson);
}

/// A project-scoped Files API reference resolved separately for each session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentHostedTemplateFileFileId extends AgentHostedTemplateFile {
  /// Creates a validated [AgentHostedTemplateFileFileId].
  AgentHostedTemplateFileFileId({
    required this.fileId,
    required this.path,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _environmentReceivedExtras(rawJson, const [
         'file_id',
         'path',
         'type',
       ], 'AgentHostedTemplateFileFileId') {
    validate();
  }

  /// The ID of the uploaded file.
  final String fileId;

  /// The file's absolute path inside the environment.
  final String path;

  /// The type of the object. Always `file_id`.
  @override
  String get type => 'file_id';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentHostedTemplateFileFileId] with contextual, payload-free errors.
  factory AgentHostedTemplateFileFileId.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'file_id', 'AgentHostedTemplateFileFileId');
    _rejectEnvironmentReadback(json, 'AgentHostedTemplateFileFileId');
    return AgentHostedTemplateFileFileId(
      fileId: requiredAgentValue(
        json,
        'file_id',
        'AgentHostedTemplateFileFileId.fileId',
        requireAgentString,
        nullable: false,
      )!,
      path: requiredAgentValue(
        json,
        'path',
        'AgentHostedTemplateFileFileId.path',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['file_id', 'path', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    _rejectEnvironmentReadback(toJson(), 'AgentHostedTemplateFileFileId');
    validateAgentLength(fileId, 'AgentHostedTemplateFileFileId.fileId', min: 0);
    validateAgentLength(path, 'AgentHostedTemplateFileFileId.path', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'file_id': fileId,
    'path': path,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentHostedTemplateFileFileId copyWith({
    String? fileId,
    String? path,
    Map<String, dynamic>? rawJson,
  }) => AgentHostedTemplateFileFileId(
    fileId: fileId ?? this.fileId,
    path: path ?? this.path,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Metadata for confidential inline file contents.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentHostedTemplateFileInline extends AgentHostedTemplateFile {
  /// Creates a validated [AgentHostedTemplateFileInline].
  AgentHostedTemplateFileInline({
    required this.path,
    required this.sizeBytes,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _environmentReceivedExtras(rawJson, const [
         'path',
         'size_bytes',
         'type',
       ], 'AgentHostedTemplateFileInline') {
    validate();
  }

  /// The file's absolute path inside the environment.
  final String path;

  /// The decoded size of the inline file in bytes.
  final int sizeBytes;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentHostedTemplateFileInline] with contextual, payload-free errors.
  factory AgentHostedTemplateFileInline.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'inline', 'AgentHostedTemplateFileInline');
    _rejectEnvironmentReadback(json, 'AgentHostedTemplateFileInline');
    return AgentHostedTemplateFileInline(
      path: requiredAgentValue(
        json,
        'path',
        'AgentHostedTemplateFileInline.path',
        requireAgentString,
        nullable: false,
      )!,
      sizeBytes: requiredAgentValue(
        json,
        'size_bytes',
        'AgentHostedTemplateFileInline.sizeBytes',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['path', 'size_bytes', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    _rejectEnvironmentReadback(toJson(), 'AgentHostedTemplateFileInline');
    validateAgentLength(path, 'AgentHostedTemplateFileInline.path', min: 0);
    validateAgentInt(
      sizeBytes,
      'AgentHostedTemplateFileInline.sizeBytes',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'path': path,
    'size_bytes': sizeBytes,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentHostedTemplateFileInline copyWith({
    String? path,
    int? sizeBytes,
    Map<String, dynamic>? rawJson,
  }) => AgentHostedTemplateFileInline(
    path: path ?? this.path,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Safe metadata for a skill configured by an environment template.
///
/// Variants: [AgentHostedTemplateSkillInline], [AgentHostedTemplateSkillSkillReference] and [UnknownAgentHostedTemplateSkill].
sealed class AgentHostedTemplateSkill extends AgentJsonModel {
  const AgentHostedTemplateSkill();

  /// Parses known variants strictly and retains future received variants.
  factory AgentHostedTemplateSkill.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'AgentHostedTemplateSkill.type',
      )) {
        'inline' => AgentHostedTemplateSkillInline.fromJson(json),
        'skill_reference' => AgentHostedTemplateSkillSkillReference.fromJson(
          json,
        ),
        _ => UnknownAgentHostedTemplateSkill.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `inline` variant.
  factory AgentHostedTemplateSkill.inline({
    required String description,
    required String name,
    Map<String, dynamic> rawJson,
  }) = AgentHostedTemplateSkillInline;

  /// Creates the `skill_reference` variant.
  factory AgentHostedTemplateSkill.skillReference({
    required String skillId,
    required String? version,
    Map<String, dynamic> rawJson,
  }) = AgentHostedTemplateSkillSkillReference;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentHostedTemplateSkill extends AgentHostedTemplateSkill {
  const UnknownAgentHostedTemplateSkill._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentHostedTemplateSkill.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentHostedTemplateSkill.type',
    );
    if (const ['inline', 'skill_reference'].contains(type)) {
      throw const FormatException(
        'UnknownAgentHostedTemplateSkill: expected a future type',
      );
    }
    _rejectEnvironmentReadback(json, 'UnknownAgentHostedTemplateSkill');
    return UnknownAgentHostedTemplateSkill._(
      snapshotAgentJson(json, 'UnknownAgentHostedTemplateSkill'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentHostedTemplateSkill copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentHostedTemplateSkill.fromJson(rawJson ?? this.rawJson);
}

/// Safe metadata for an inline skill archive.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentHostedTemplateSkillInline extends AgentHostedTemplateSkill {
  /// Creates a validated [AgentHostedTemplateSkillInline].
  AgentHostedTemplateSkillInline({
    required this.description,
    required this.name,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _environmentReceivedExtras(rawJson, const [
         'description',
         'name',
         'type',
       ], 'AgentHostedTemplateSkillInline') {
    validate();
  }

  /// The skill description declared in `SKILL.md`.
  final String description;

  /// The skill name declared in `SKILL.md`.
  final String name;

  /// The type of the object. Always `inline`.
  @override
  String get type => 'inline';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentHostedTemplateSkillInline] with contextual, payload-free errors.
  factory AgentHostedTemplateSkillInline.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'inline', 'AgentHostedTemplateSkillInline');
    _rejectEnvironmentReadback(json, 'AgentHostedTemplateSkillInline');
    return AgentHostedTemplateSkillInline(
      description: requiredAgentValue(
        json,
        'description',
        'AgentHostedTemplateSkillInline.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentHostedTemplateSkillInline.name',
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
    _rejectEnvironmentReadback(toJson(), 'AgentHostedTemplateSkillInline');
    validateAgentLength(
      description,
      'AgentHostedTemplateSkillInline.description',
      min: 0,
    );
    validateAgentLength(name, 'AgentHostedTemplateSkillInline.name', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'description': description,
    'name': name,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentHostedTemplateSkillInline copyWith({
    String? description,
    String? name,
    Map<String, dynamic>? rawJson,
  }) => AgentHostedTemplateSkillInline(
    description: description ?? this.description,
    name: name ?? this.name,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A skill resolved afresh from the Skills API whenever a session starts.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentHostedTemplateSkillSkillReference
    extends AgentHostedTemplateSkill {
  /// Creates a validated [AgentHostedTemplateSkillSkillReference].
  AgentHostedTemplateSkillSkillReference({
    required this.skillId,
    required this.version,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _environmentReceivedExtras(rawJson, const [
         'skill_id',
         'type',
         'version',
       ], 'AgentHostedTemplateSkillSkillReference') {
    validate();
  }

  /// The referenced skill ID.
  final String skillId;

  /// The type of the object. Always `skill_reference`.
  @override
  String get type => 'skill_reference';

  /// The requested version selector, including `latest`.
  final String? version;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentHostedTemplateSkillSkillReference] with contextual, payload-free errors.
  factory AgentHostedTemplateSkillSkillReference.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'skill_reference',
      'AgentHostedTemplateSkillSkillReference',
    );
    _rejectEnvironmentReadback(json, 'AgentHostedTemplateSkillSkillReference');
    return AgentHostedTemplateSkillSkillReference(
      skillId: requiredAgentValue(
        json,
        'skill_id',
        'AgentHostedTemplateSkillSkillReference.skillId',
        requireAgentString,
        nullable: false,
      )!,
      version: requiredAgentValue(
        json,
        'version',
        'AgentHostedTemplateSkillSkillReference.version',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['skill_id', 'type', 'version'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      skillId,
      'AgentHostedTemplateSkillSkillReference.skillId',
      min: 0,
    );
    if (version != null) {
      validateAgentLength(
        version!,
        'AgentHostedTemplateSkillSkillReference.version',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'skill_id': skillId,
    'type': type,
    'version': version,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentHostedTemplateSkillSkillReference copyWith({
    String? skillId,
    Object? version = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentHostedTemplateSkillSkillReference(
    skillId: skillId ?? this.skillId,
    version: copyAgentValue<String>(
      version,
      this.version,
      'AgentHostedTemplateSkillSkillReference.version',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Fields to replace on an existing reusable OpenAI-hosted environment template.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class UpdateAgentEnvironmentTemplateRequest extends AgentJsonModel {
  /// Creates a validated [UpdateAgentEnvironmentTemplateRequest].
  UpdateAgentEnvironmentTemplateRequest({
    List<String>? capabilityDirectories,
    bool clearCapabilityDirectories = false,
    AgentSessionDesktopConfig? desktop,
    bool clearDesktop = false,
    Map<String, String>? env,
    bool clearEnv = false,
    List<AgentSessionHostedEnvironmentFileConfig>? files,
    bool clearFiles = false,
    String? name,
    bool clearName = false,
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
       clearName = clearName,
       name = clearName ? null : name,
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

  /// Directories that expose capabilities to the agent.
  final List<String>? capabilityDirectories;

  /// Sends `capability_directories: null`, rather than omitting it.
  final bool clearCapabilityDirectories;

  /// Replacement desktop configuration, or null to disable the desktop.
  final AgentSessionDesktopConfig? desktop;

  /// Sends `desktop: null`, rather than omitting it.
  final bool clearDesktop;

  /// Replacement confidential environment values.
  final Map<String, String>? env;

  /// Sends `env: null`, rather than omitting it.
  final bool clearEnv;

  /// Replacement file configuration materialized for each new session.
  final List<AgentSessionHostedEnvironmentFileConfig>? files;

  /// Sends `files: null`, rather than omitting it.
  final bool clearFiles;

  /// A replacement human-readable display name, or `null` to clear the name.
  final String? name;

  /// Sends `name: null`, rather than omitting it.
  final bool clearName;

  /// Network access available after setup completes. Omit to preserve the current policy, or pass `null` to reset to the default policy.
  final AgentSessionNetworkPolicyConfig? network;

  /// Sends `network: null`, rather than omitting it.
  final bool clearNetwork;

  /// Packages installed before the runtime network policy applies.
  final AgentSessionEnvironmentPackagesConfig? packages;

  /// Sends `packages: null`, rather than omitting it.
  final bool clearPackages;

  /// Replacement plugin configuration installed for each new session.
  final List<AgentSessionHostedPluginConfig>? plugins;

  /// Sends `plugins: null`, rather than omitting it.
  final bool clearPlugins;

  /// Replacement confidential setup commands, never included in returned resources.
  final List<AgentSessionSetupCommandConfig>? setupCommands;

  /// Sends `setup_commands: null`, rather than omitting it.
  final bool clearSetupCommands;

  /// Replacement skill configuration installed for each new session.
  final List<AgentSessionHostedSkillConfig>? skills;

  /// Sends `skills: null`, rather than omitting it.
  final bool clearSkills;

  /// Parses [UpdateAgentEnvironmentTemplateRequest] with contextual, payload-free errors.
  factory UpdateAgentEnvironmentTemplateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'capability_directories',
      'desktop',
      'env',
      'files',
      'name',
      'network',
      'packages',
      'plugins',
      'setup_commands',
      'skills',
    ], 'UpdateAgentEnvironmentTemplateRequest');
    return UpdateAgentEnvironmentTemplateRequest(
      capabilityDirectories: optionalAgentValue(
        json,
        'capability_directories',
        'UpdateAgentEnvironmentTemplateRequest.capabilityDirectories',
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
        'UpdateAgentEnvironmentTemplateRequest.desktop',
        (value, context) => AgentSessionDesktopConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearDesktop: json.containsKey('desktop') && json['desktop'] == null,
      env: optionalAgentValue(
        json,
        'env',
        'UpdateAgentEnvironmentTemplateRequest.env',
        requireAgentStringMap,
        nullable: true,
      ),
      clearEnv: json.containsKey('env') && json['env'] == null,
      files: optionalAgentValue(
        json,
        'files',
        'UpdateAgentEnvironmentTemplateRequest.files',
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
      name: optionalAgentValue(
        json,
        'name',
        'UpdateAgentEnvironmentTemplateRequest.name',
        requireAgentString,
        nullable: true,
      ),
      clearName: json.containsKey('name') && json['name'] == null,
      network: optionalAgentValue(
        json,
        'network',
        'UpdateAgentEnvironmentTemplateRequest.network',
        (value, context) => AgentSessionNetworkPolicyConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearNetwork: json.containsKey('network') && json['network'] == null,
      packages: optionalAgentValue(
        json,
        'packages',
        'UpdateAgentEnvironmentTemplateRequest.packages',
        (value, context) => AgentSessionEnvironmentPackagesConfig.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      clearPackages: json.containsKey('packages') && json['packages'] == null,
      plugins: optionalAgentValue(
        json,
        'plugins',
        'UpdateAgentEnvironmentTemplateRequest.plugins',
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
        'UpdateAgentEnvironmentTemplateRequest.setupCommands',
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
        'UpdateAgentEnvironmentTemplateRequest.skills',
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
        'UpdateAgentEnvironmentTemplateRequest.capabilityDirectories',
        min: 0,
        max: 16384,
      );
      for (final item in capabilityDirectories!) {
        validateAgentLength(
          item,
          'UpdateAgentEnvironmentTemplateRequest.capabilityDirectories',
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
        'UpdateAgentEnvironmentTemplateRequest.env',
        min: 0,
        max: 1024,
      );
      for (final key in env!.keys) {
        validateAgentLength(
          key,
          'UpdateAgentEnvironmentTemplateRequest.env',
          min: 1,
          max: 256,
        );
      }
      for (final item in env!.values) {
        validateAgentLength(
          item,
          'UpdateAgentEnvironmentTemplateRequest.env',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (files != null) {
      validateAgentCount(
        files!.length,
        'UpdateAgentEnvironmentTemplateRequest.files',
        min: 0,
        max: 50,
      );
      for (final item in files!) {
        item.validate();
      }
    }
    if (name != null) {
      validateAgentLength(
        name!,
        'UpdateAgentEnvironmentTemplateRequest.name',
        min: 1,
        max: 256,
      );
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
        'UpdateAgentEnvironmentTemplateRequest.plugins',
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
        'UpdateAgentEnvironmentTemplateRequest.setupCommands',
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
        'UpdateAgentEnvironmentTemplateRequest.skills',
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
    if (clearFiles)
      'files': null
    else if (files != null)
      'files': files!.map((value) => value.toJson()).toList(),
    if (clearName) 'name': null else 'name': ?name,
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
  };

  /// Copies values; omitted arguments retain their values and null presence.
  UpdateAgentEnvironmentTemplateRequest copyWith({
    Object? capabilityDirectories = unsetCopyWithValue,
    bool? clearCapabilityDirectories,
    Object? desktop = unsetCopyWithValue,
    bool? clearDesktop,
    Object? env = unsetCopyWithValue,
    bool? clearEnv,
    Object? files = unsetCopyWithValue,
    bool? clearFiles,
    Object? name = unsetCopyWithValue,
    bool? clearName,
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
  }) => UpdateAgentEnvironmentTemplateRequest(
    capabilityDirectories: copyAgentValue<List<String>>(
      capabilityDirectories,
      this.capabilityDirectories,
      'UpdateAgentEnvironmentTemplateRequest.capabilityDirectories',
    ),
    clearCapabilityDirectories:
        clearCapabilityDirectories ??
        (identical(capabilityDirectories, unsetCopyWithValue)
            ? this.clearCapabilityDirectories
            : capabilityDirectories == null),
    desktop: copyAgentValue<AgentSessionDesktopConfig>(
      desktop,
      this.desktop,
      'UpdateAgentEnvironmentTemplateRequest.desktop',
    ),
    clearDesktop:
        clearDesktop ??
        (identical(desktop, unsetCopyWithValue)
            ? this.clearDesktop
            : desktop == null),
    env: copyAgentValue<Map<String, String>>(
      env,
      this.env,
      'UpdateAgentEnvironmentTemplateRequest.env',
    ),
    clearEnv:
        clearEnv ??
        (identical(env, unsetCopyWithValue) ? this.clearEnv : env == null),
    files: copyAgentValue<List<AgentSessionHostedEnvironmentFileConfig>>(
      files,
      this.files,
      'UpdateAgentEnvironmentTemplateRequest.files',
    ),
    clearFiles:
        clearFiles ??
        (identical(files, unsetCopyWithValue)
            ? this.clearFiles
            : files == null),
    name: copyAgentValue<String>(
      name,
      this.name,
      'UpdateAgentEnvironmentTemplateRequest.name',
    ),
    clearName:
        clearName ??
        (identical(name, unsetCopyWithValue) ? this.clearName : name == null),
    network: copyAgentValue<AgentSessionNetworkPolicyConfig>(
      network,
      this.network,
      'UpdateAgentEnvironmentTemplateRequest.network',
    ),
    clearNetwork:
        clearNetwork ??
        (identical(network, unsetCopyWithValue)
            ? this.clearNetwork
            : network == null),
    packages: copyAgentValue<AgentSessionEnvironmentPackagesConfig>(
      packages,
      this.packages,
      'UpdateAgentEnvironmentTemplateRequest.packages',
    ),
    clearPackages:
        clearPackages ??
        (identical(packages, unsetCopyWithValue)
            ? this.clearPackages
            : packages == null),
    plugins: copyAgentValue<List<AgentSessionHostedPluginConfig>>(
      plugins,
      this.plugins,
      'UpdateAgentEnvironmentTemplateRequest.plugins',
    ),
    clearPlugins:
        clearPlugins ??
        (identical(plugins, unsetCopyWithValue)
            ? this.clearPlugins
            : plugins == null),
    setupCommands: copyAgentValue<List<AgentSessionSetupCommandConfig>>(
      setupCommands,
      this.setupCommands,
      'UpdateAgentEnvironmentTemplateRequest.setupCommands',
    ),
    clearSetupCommands:
        clearSetupCommands ??
        (identical(setupCommands, unsetCopyWithValue)
            ? this.clearSetupCommands
            : setupCommands == null),
    skills: copyAgentValue<List<AgentSessionHostedSkillConfig>>(
      skills,
      this.skills,
      'UpdateAgentEnvironmentTemplateRequest.skills',
    ),
    clearSkills:
        clearSkills ??
        (identical(skills, unsetCopyWithValue)
            ? this.clearSkills
            : skills == null),
  );
}
