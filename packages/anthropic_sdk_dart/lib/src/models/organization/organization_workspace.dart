import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// Inference locations allowed by a workspace.
@immutable
final class AllowedInferenceGeos {
  /// All supported inference locations are allowed.
  static const unrestricted = AllowedInferenceGeos._(null);

  const AllowedInferenceGeos._(this.values);

  /// A specific list of allowed inference locations.
  AllowedInferenceGeos.only(List<String> values)
    : this._(List.unmodifiable(values));

  /// The specified locations, or null for unrestricted.
  final List<String>? values;

  /// Parses the wire union of a string constant or a list of geos.
  factory AllowedInferenceGeos.fromJson(Object? json) => switch (json) {
    'unrestricted' => unrestricted,
    final List<Object?> values => AllowedInferenceGeos.only(
      values.cast<String>(),
    ),
    _ => throw const FormatException('Invalid allowed_inference_geos'),
  };

  /// Converts to the workspace API's wire union.
  Object toJson() => values ?? 'unrestricted';

  @override
  bool operator ==(Object other) =>
      other is AllowedInferenceGeos && listsEqual(values, other.values);

  @override
  int get hashCode => listHash(values);

  @override
  String toString() => toJson().toString();
}

/// Storage and default inference locations for a workspace.
@immutable
final class WorkspaceDataResidency {
  /// Creates a residency value returned by the API.
  const WorkspaceDataResidency({
    required this.allowedInferenceGeos,
    required this.defaultInferenceGeo,
    required this.workspaceGeo,
  });

  /// Parses the configured residency fields.
  factory WorkspaceDataResidency.fromJson(Map<String, dynamic> json) =>
      WorkspaceDataResidency(
        allowedInferenceGeos: AllowedInferenceGeos.fromJson(
          json['allowed_inference_geos'],
        ),
        defaultInferenceGeo: requiredOrganizationField<String>(
          json,
          'default_inference_geo',
          'WorkspaceDataResidency',
        ),
        workspaceGeo: requiredOrganizationField<String>(
          json,
          'workspace_geo',
          'WorkspaceDataResidency',
        ),
      );

  /// The geos that can be selected for inference.
  final AllowedInferenceGeos allowedInferenceGeos;

  /// The inference geo used when a request omits it.
  final String defaultInferenceGeo;

  /// The immutable storage geo.
  final String workspaceGeo;

  /// Converts the response fields to JSON.
  Map<String, dynamic> toJson() => {
    'allowed_inference_geos': allowedInferenceGeos.toJson(),
    'default_inference_geo': defaultInferenceGeo,
    'workspace_geo': workspaceGeo,
  };

  @override
  bool operator ==(Object other) =>
      other is WorkspaceDataResidency &&
      allowedInferenceGeos == other.allowedInferenceGeos &&
      defaultInferenceGeo == other.defaultInferenceGeo &&
      workspaceGeo == other.workspaceGeo;

  @override
  int get hashCode =>
      Object.hash(allowedInferenceGeos, defaultInferenceGeo, workspaceGeo);
}

/// A workspace returned by the Admin API.
@immutable
final class OrganizationWorkspace {
  const OrganizationWorkspace._({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.archivedAt,
    required this.compartmentId,
    required this.displayColor,
    required this.dataResidency,
    required this.externalKeyId,
    required this.userProfileId,
    required this.tags,
  });

  /// Parses current workspace metadata.
  factory OrganizationWorkspace.fromJson(Map<String, dynamic> json) {
    checkOrganizationType(json, 'workspace');
    const model = 'OrganizationWorkspace';
    final archived = requiredOrganizationField<String?>(
      json,
      'archived_at',
      model,
    );
    return OrganizationWorkspace._(
      id: requiredOrganizationField<String>(json, 'id', model),
      name: requiredOrganizationField<String>(json, 'name', model),
      createdAt: DateTime.parse(
        requiredOrganizationField<String>(json, 'created_at', model),
      ),
      archivedAt: archived == null ? null : DateTime.parse(archived),
      compartmentId: requiredOrganizationField<String>(
        json,
        'compartment_id',
        model,
      ),
      displayColor: requiredOrganizationField<String>(
        json,
        'display_color',
        model,
      ),
      dataResidency: WorkspaceDataResidency.fromJson(
        requiredOrganizationField<Map<String, dynamic>>(
          json,
          'data_residency',
          model,
        ),
      ),
      externalKeyId: requiredOrganizationField<String?>(
        json,
        'external_key_id',
        model,
      ),
      userProfileId: json['user_profile_id'] as String?,
      tags: Map<String, String>.unmodifiable(
        requiredOrganizationField<Map<String, dynamic>>(json, 'tags', model),
      ),
    );
  }

  /// The workspace ID.
  final String id;

  /// The display name.
  final String name;

  /// When the workspace was created.
  final DateTime createdAt;

  /// When the workspace was archived, if archived.
  final DateTime? archivedAt;

  /// The cloud compartment ID.
  final String compartmentId;

  /// The color shown in the Console.
  final String displayColor;

  /// The workspace storage and inference geos.
  final WorkspaceDataResidency dataResidency;

  /// The external encryption key, if configured.
  final String? externalKeyId;

  /// The linked user profile ID, if configured.
  final String? userProfileId;

  /// The workspace's tags.
  final Map<String, String> tags;

  /// Converts this workspace to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'workspace',
    'name': name,
    'created_at': createdAt.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'compartment_id': compartmentId,
    'display_color': displayColor,
    'data_residency': dataResidency.toJson(),
    'external_key_id': externalKeyId,
    'user_profile_id': userProfileId,
    'tags': tags,
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationWorkspace && mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() => 'OrganizationWorkspace(id: $id, name: $name)';
}
