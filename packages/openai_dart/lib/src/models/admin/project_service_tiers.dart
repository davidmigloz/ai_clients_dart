import 'admin_json.dart';

/// The default processing tier for requests that omit a tier or use auto.
final class ProjectDefaultServiceTier extends AdminJsonValue {
  const ProjectDefaultServiceTier._(this.value);

  /// Standard processing.
  static const standard = ProjectDefaultServiceTier._('standard');

  /// Fast processing.
  static const fast = ProjectDefaultServiceTier._('fast');

  /// Scale processing.
  static const scale = ProjectDefaultServiceTier._('scale');

  /// Exact wire value.
  final String value;

  /// Parses a known or future value returned by the service.
  factory ProjectDefaultServiceTier.fromJson(Object? json) {
    final value = adminString(json, 'ProjectDefaultServiceTier');
    return switch (value) {
      'standard' => standard,
      'fast' => fast,
      'scale' => scale,
      _ => ProjectDefaultServiceTier._(value),
    };
  }

  @override
  void validate() {
    if (value != 'standard' && value != 'fast' && value != 'scale') {
      throw const FormatException(
        'ProjectDefaultServiceTier: unsupported request value',
      );
    }
  }

  @override
  String toJson() => value;
}

/// An additional service tier that can be enabled for a project.
final class ProjectOptionalServiceTier extends AdminJsonValue {
  const ProjectOptionalServiceTier._(this.value);

  /// Flex processing.
  static const flex = ProjectOptionalServiceTier._('flex');

  /// Fast processing.
  static const fast = ProjectOptionalServiceTier._('fast');

  /// Ultrafast processing.
  static const ultrafast = ProjectOptionalServiceTier._('ultrafast');

  /// Exact wire value.
  final String value;

  /// Parses a known or future value returned by the service.
  factory ProjectOptionalServiceTier.fromJson(Object? json) {
    final value = adminString(json, 'ProjectOptionalServiceTier');
    return switch (value) {
      'flex' => flex,
      'fast' => fast,
      'ultrafast' => ultrafast,
      _ => ProjectOptionalServiceTier._(value),
    };
  }

  @override
  void validate() {
    if (value != 'flex' && value != 'fast' && value != 'ultrafast') {
      throw const FormatException(
        'ProjectOptionalServiceTier: unsupported request value',
      );
    }
  }

  @override
  String toJson() => value;
}

/// Additional service tiers enabled for a project.
///
/// Organization policy and project eligibility still apply.
sealed class ProjectEnabledServiceTiers extends AdminJsonValue {
  const ProjectEnabledServiceTiers();

  /// Enables all tiers, including tiers introduced later.
  const factory ProjectEnabledServiceTiers.all() = AllProjectServiceTiers;

  /// Enables only the selected tiers. An empty list allows Standard only.
  factory ProjectEnabledServiceTiers.selected(
    Iterable<ProjectOptionalServiceTier> tiers,
  ) = SelectedProjectServiceTiers;

  /// Parses the fixed string or list wire form.
  factory ProjectEnabledServiceTiers.fromJson(Object? json) {
    if (json == 'all') return const ProjectEnabledServiceTiers.all();
    return ProjectEnabledServiceTiers.selected(
      adminList(
        json,
        'ProjectEnabledServiceTiers',
      ).map(ProjectOptionalServiceTier.fromJson),
    );
  }
}

/// All additional service tiers.
final class AllProjectServiceTiers extends ProjectEnabledServiceTiers {
  /// Enables all service tiers.
  const AllProjectServiceTiers();

  @override
  String toJson() => 'all';
}

/// An explicit immutable list of additional service tiers.
final class SelectedProjectServiceTiers extends ProjectEnabledServiceTiers {
  /// Captures a detached list of enabled tiers.
  SelectedProjectServiceTiers(Iterable<ProjectOptionalServiceTier> tiers)
    : tiers = List.unmodifiable(tiers);

  /// The selected tiers. An empty list allows Standard only.
  final List<ProjectOptionalServiceTier> tiers;

  @override
  void validate() {
    for (final tier in tiers) {
      tier.validate();
    }
  }

  @override
  List<String> toJson() => [for (final tier in tiers) tier.toJson()];
}

/// The effective service-tier settings for a project.
final class ProjectServiceTierSettings extends AdminJsonValue {
  /// Creates effective settings from the returned values.
  const ProjectServiceTierSettings({
    required this.defaultTier,
    required this.enabledTiers,
  });

  /// Fixed API object discriminator.
  String get object => 'project.service_tier_settings';

  /// The default tier for omitted or automatic request processing.
  final ProjectDefaultServiceTier defaultTier;

  /// Which additional tiers the project has enabled.
  final ProjectEnabledServiceTiers enabledTiers;

  /// Parses the effective settings, including unknown tier values.
  factory ProjectServiceTierSettings.fromJson(Map<String, dynamic> json) {
    adminTag(
      json,
      'object',
      'project.service_tier_settings',
      'ProjectServiceTierSettings',
    );
    return ProjectServiceTierSettings(
      defaultTier: ProjectDefaultServiceTier.fromJson(json['default']),
      enabledTiers: ProjectEnabledServiceTiers.fromJson(json['enabled_tiers']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'object': object,
    'default': defaultTier.toJson(),
    'enabled_tiers': enabledTiers.toJson(),
  };

  /// Copies effective settings.
  ProjectServiceTierSettings copyWith({
    ProjectDefaultServiceTier? defaultTier,
    ProjectEnabledServiceTiers? enabledTiers,
  }) => ProjectServiceTierSettings(
    defaultTier: defaultTier ?? this.defaultTier,
    enabledTiers: enabledTiers ?? this.enabledTiers,
  );
}

/// A partial update to a project's processing tiers.
final class UpdateProjectServiceTierSettingsRequest extends AdminJsonValue {
  /// Creates a patch. Supply at least one field.
  UpdateProjectServiceTierSettingsRequest({
    this.defaultTier,
    this.enabledTiers,
  }) {
    validate();
  }

  /// Replacement default tier. Omission retains the current value.
  final ProjectDefaultServiceTier? defaultTier;

  /// Replacement enabled tiers. Omission retains the current value.
  final ProjectEnabledServiceTiers? enabledTiers;

  /// Parses supplied non-null fields.
  factory UpdateProjectServiceTierSettingsRequest.fromJson(
    Map<String, dynamic> json,
  ) => UpdateProjectServiceTierSettingsRequest(
    defaultTier: json.containsKey('default')
        ? ProjectDefaultServiceTier.fromJson(json['default'])
        : null,
    enabledTiers: json.containsKey('enabled_tiers')
        ? ProjectEnabledServiceTiers.fromJson(json['enabled_tiers'])
        : null,
  );

  @override
  void validate() {
    if (defaultTier == null && enabledTiers == null) {
      throw const FormatException(
        'Project service tier update requires at least one field',
      );
    }
    defaultTier?.validate();
    enabledTiers?.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    if (defaultTier != null) 'default': defaultTier!.toJson(),
    if (enabledTiers != null) 'enabled_tiers': enabledTiers!.toJson(),
  };

  /// Copies the update. Explicit null omits that field from the patch.
  UpdateProjectServiceTierSettingsRequest copyWith({
    Object? defaultTier = unsetCopyWithValue,
    Object? enabledTiers = unsetCopyWithValue,
  }) => UpdateProjectServiceTierSettingsRequest(
    defaultTier: adminCopy<ProjectDefaultServiceTier>(
      defaultTier,
      this.defaultTier,
      'UpdateProjectServiceTierSettingsRequest.defaultTier',
    ),
    enabledTiers: adminCopy<ProjectEnabledServiceTiers>(
      enabledTiers,
      this.enabledTiers,
      'UpdateProjectServiceTierSettingsRequest.enabledTiers',
    ),
  );
}
