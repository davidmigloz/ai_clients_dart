import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Which payload data a telemetry destination receives in spans.
enum TelemetryContentMode {
  /// Export metadata without prompts, responses, or tool content.
  metadataOnly('metadata_only'),

  /// Include eligible prompts, responses, and tool content.
  content('content');

  const TelemetryContentMode(this.value);

  /// Wire value used by the Admin API.
  final String value;
}

/// Desired telemetry delivery state for a destination update.
enum TelemetryDestinationState {
  /// Deliver spans.
  enabled,

  /// Pause deliveries.
  disabled,
}

/// The scope of a telemetry destination's workspace selection.
enum TelemetryWorkspaceMode {
  /// Deliver spans from every eligible workspace.
  all,

  /// Deliver spans only from workspaces on the list.
  include,

  /// Deliver spans from eligible workspaces outside the list.
  exclude,
}

/// Request configuration for a destination's workspace selection.
@immutable
final class TelemetryWorkspaceSelection {
  const TelemetryWorkspaceSelection._(this.mode, this.workspaceIds);

  /// Include all eligible workspaces without a list.
  const TelemetryWorkspaceSelection.all()
    : this._(TelemetryWorkspaceMode.all, null);

  /// Include only workspaces on the list. On update, omit the list to retain it
  /// when the scope mode is unchanged, or pass an empty list to clear it.
  TelemetryWorkspaceSelection.include({List<String>? workspaceIds})
    : this._(
        TelemetryWorkspaceMode.include,
        workspaceIds == null ? null : List.unmodifiable(workspaceIds),
      );

  /// Include eligible workspaces except the ones on the list.
  TelemetryWorkspaceSelection.exclude({List<String>? workspaceIds})
    : this._(
        TelemetryWorkspaceMode.exclude,
        workspaceIds == null ? null : List.unmodifiable(workspaceIds),
      );

  /// Workspace selection mode.
  final TelemetryWorkspaceMode mode;

  /// Workspace IDs to use. Null leaves the list omitted on the wire.
  final List<String>? workspaceIds;

  /// Converts the selection to the tagged request shape.
  Map<String, dynamic> toJson() => {
    'type': mode.name,
    'workspace_ids': ?workspaceIds,
  };
}

/// Configures trace delivery on creation or changes individual trace settings.
@immutable
final class TelemetryTracesConfig {
  /// Omitting a setting keeps the stored value on update. Pass null to clear
  /// [endpointUrl] or [maxContentBytes], or reset [contentMode] to metadata only.
  const TelemetryTracesConfig({
    this.enabled,
    this._endpointUrl = unsetCopyWithValue,
    this._contentMode = unsetCopyWithValue,
    this._maxContentBytes = unsetCopyWithValue,
  });

  /// Whether the destination receives trace data.
  final bool? enabled;
  final Object? _endpointUrl;
  final Object? _contentMode;
  final Object? _maxContentBytes;

  /// Converts the configuration to JSON while retaining explicit clears.
  Map<String, dynamic> toJson() => {
    'enabled': ?enabled,
    if (_endpointUrl != unsetCopyWithValue)
      'endpoint_url': _endpointUrl as String?,
    if (_contentMode != unsetCopyWithValue)
      'content_mode': (_contentMode as TelemetryContentMode?)?.value,
    if (_maxContentBytes != unsetCopyWithValue)
      'max_content_bytes': _maxContentBytes as int?,
  };
}

@immutable
abstract base class _TelemetryRecord {
  _TelemetryRecord(Map<String, dynamic> json)
    : _json = deepUnmodifiableMap(json);

  final Map<String, dynamic> _json;

  /// Serializes the provider's response fields, including explicit nulls.
  Map<String, dynamic> toJson() => Map.of(_json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TelemetryRecord &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_json, other._json);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(_json));
}

/// Organization OpenTelemetry exporter configuration and delivery health.
final class TelemetryDestination extends _TelemetryRecord {
  /// Parses a destination. The provider returns header names only.
  TelemetryDestination.fromJson(Map<String, dynamic> json)
    : id = requiredOrganizationField<String>(json, 'id', _model),
      displayName = requiredOrganizationField<String?>(
        json,
        'display_name',
        _model,
      ),
      endpointUrl = requiredOrganizationField<String>(
        json,
        'endpoint_url',
        _model,
      ),
      headerNames = _headerNames(json),
      traces = TelemetryDestinationTraces.fromJson(
        requiredOrganizationField<Map<String, dynamic>>(json, 'traces', _model),
      ),
      state = TelemetryDeliveryState.fromJson(
        requiredOrganizationField<Map<String, dynamic>>(json, 'state', _model),
      ),
      workspaces = TelemetryDestinationWorkspaces.fromJson(
        requiredOrganizationField<Map<String, dynamic>>(
          json,
          'workspaces',
          _model,
        ),
      ),
      deliveryHealth = TelemetryDeliveryHealth.fromJson(
        requiredOrganizationField<Map<String, dynamic>>(
          json,
          'delivery_health',
          _model,
        ),
      ),
      createdAt = _timestamp(json, 'created_at', _model),
      updatedAt = _timestamp(json, 'updated_at', _model),
      super(Map.of(json)..remove('headers')) {
    checkOrganizationType(json, type);
  }

  static const _model = 'TelemetryDestination';

  /// Resource discriminator.
  String get type => 'telemetry_destination';

  /// Destination identifier.
  final String id;

  /// Optional display name.
  final String? displayName;

  /// OTLP/HTTP base URL.
  final String endpointUrl;

  /// Registered outbound header names. Their values are write-only.
  final List<String> headerNames;

  /// Current traces configuration.
  final TelemetryDestinationTraces traces;

  /// Current delivery state.
  final TelemetryDeliveryState state;

  /// Current workspace selection mode.
  final TelemetryDestinationWorkspaces workspaces;

  /// Recent delivery outcomes reported by the API.
  final TelemetryDeliveryHealth deliveryHealth;

  /// When the destination was registered.
  final DateTime createdAt;

  /// When the configuration last changed.
  final DateTime updatedAt;

  @override
  String toString() => 'TelemetryDestination(id: $id, state: ${state.type})';
}

/// Stored traces configuration for a telemetry destination.
final class TelemetryDestinationTraces extends _TelemetryRecord {
  /// Parses returned trace settings, preserving open content-mode values.
  TelemetryDestinationTraces.fromJson(super.json)
    : enabled = requiredOrganizationField<bool>(json, 'enabled', _model),
      endpointUrl = requiredOrganizationField<String?>(
        json,
        'endpoint_url',
        _model,
      ),
      contentMode = requiredOrganizationField<String>(
        json,
        'content_mode',
        _model,
      ),
      maxContentBytes = requiredOrganizationField<int?>(
        json,
        'max_content_bytes',
        _model,
      );

  static const _model = 'TelemetryDestinationTraces';

  /// Whether trace export is enabled.
  final bool enabled;

  /// Full traces URL override, when configured.
  final String? endpointUrl;

  /// Content mode in the provider's spelling.
  final String contentMode;

  /// Configured content truncation limit in bytes, when present.
  final int? maxContentBytes;
}

/// Current delivery state and the reason a destination was disabled.
final class TelemetryDeliveryState extends _TelemetryRecord {
  /// Parses delivery state, preserving future values.
  TelemetryDeliveryState.fromJson(super.json)
    : type = requiredOrganizationField<String>(json, 'type', _model),
      disabledReason = _disabledReason(json);

  static const _model = 'TelemetryDeliveryState';

  /// State in the provider's spelling, usually `enabled` or `disabled`.
  final String type;

  /// Disabled reason in the provider's spelling, when present.
  final String? disabledReason;

  static String? _disabledReason(Map<String, dynamic> json) {
    if (json['type'] == 'disabled') {
      final reason = requiredOrganizationField<Map<String, dynamic>>(
        json,
        'reason',
        _model,
      );
      return requiredOrganizationField<String>(
        reason,
        'type',
        'TelemetryDisabledReason',
      );
    }
    return switch (json['reason']) {
      {'type': final String value} => value,
      _ => null,
    };
  }
}

/// Workspace selection stored by the service. Retrieve the list separately.
final class TelemetryDestinationWorkspaces extends _TelemetryRecord {
  /// Parses a stored workspace scope.
  TelemetryDestinationWorkspaces.fromJson(super.json)
    : type = requiredOrganizationField<String>(
        json,
        'type',
        'TelemetryDestinationWorkspaces',
      );

  /// Workspace selection mode in the provider's spelling.
  final String type;
}

/// The service's recent delivery outcomes for a telemetry destination.
final class TelemetryDeliveryHealth extends _TelemetryRecord {
  /// Parses the reported outcomes.
  TelemetryDeliveryHealth.fromJson(super.json)
    : lastSuccessAt = _nullableTimestamp(json, 'last_success_at', _model),
      lastError = requiredOrganizationField<String?>(
        json,
        'last_error',
        _model,
      ),
      lastErrorAt = _nullableTimestamp(json, 'last_error_at', _model);

  static const _model = 'TelemetryDeliveryHealth';

  /// Most recent successful delivery, if any.
  final DateTime? lastSuccessAt;

  /// Most recent delivery error, if any.
  final String? lastError;

  /// When the most recent delivery error occurred, if any.
  final DateTime? lastErrorAt;
}

/// The reported outcome of a test span sent to a telemetry destination.
final class TelemetryDestinationTest extends _TelemetryRecord {
  /// Parses the result. Collector failures are represented in the result body.
  TelemetryDestinationTest.fromJson(Map<String, dynamic> json)
    : result = TelemetryDestinationTestResult.fromJson(
        requiredOrganizationField<Map<String, dynamic>>(
          json,
          'result',
          'TelemetryDestinationTest',
        ),
      ),
      super(json) {
    checkOrganizationType(json, type);
  }

  /// Resource discriminator.
  String get type => 'telemetry_destination_test';

  /// Test span delivery outcome.
  final TelemetryDestinationTestResult result;
}

/// Success or failure returned by a telemetry test span.
final class TelemetryDestinationTestResult extends _TelemetryRecord {
  /// Parses the tagged result, including future result types.
  TelemetryDestinationTestResult.fromJson(super.json)
    : type = requiredOrganizationField<String>(json, 'type', _model),
      error = json['type'] == 'failure'
          ? requiredOrganizationField<String>(json, 'error', _model)
          : switch (json['error']) {
              final String value => value,
              _ => null,
            };

  static const _model = 'TelemetryDestinationTestResult';

  /// Outcome in the provider's spelling.
  final String type;

  /// Whether the collector accepted the span.
  bool get succeeded => type == 'success';

  /// Delivery failure detail, when provided.
  final String? error;
}

/// Confirmation that a telemetry destination was deleted.
final class DeletedTelemetryDestination extends _TelemetryRecord {
  /// Parses the confirmation.
  DeletedTelemetryDestination.fromJson(Map<String, dynamic> json)
    : id = requiredOrganizationField<String>(
        json,
        'id',
        'DeletedTelemetryDestination',
      ),
      super(json) {
    checkOrganizationType(json, type);
  }

  /// Resource discriminator.
  String get type => 'telemetry_destination_deleted';

  /// Deleted destination ID.
  final String id;
}

/// A workspace entry in a telemetry destination's workspace list.
final class TelemetryDestinationWorkspace extends _TelemetryRecord {
  /// Parses a list entry.
  TelemetryDestinationWorkspace.fromJson(Map<String, dynamic> json)
    : destinationId = requiredOrganizationField<String>(
        json,
        'telemetry_destination_id',
        _model,
      ),
      workspaceId = requiredOrganizationField<String>(
        json,
        'workspace_id',
        _model,
      ),
      createdAt = _timestamp(json, 'created_at', _model),
      super(json) {
    checkOrganizationType(json, type);
  }

  static const _model = 'TelemetryDestinationWorkspace';

  /// Resource discriminator.
  String get type => 'telemetry_destination_workspace';

  /// Destination that owns this list entry.
  final String destinationId;

  /// Workspace on the list.
  final String workspaceId;

  /// When the workspace was added.
  final DateTime createdAt;
}

/// Confirmation that a workspace entry was removed.
final class DeletedTelemetryDestinationWorkspace extends _TelemetryRecord {
  /// Parses the confirmation.
  DeletedTelemetryDestinationWorkspace.fromJson(Map<String, dynamic> json)
    : destinationId = requiredOrganizationField<String>(
        json,
        'telemetry_destination_id',
        _model,
      ),
      workspaceId = requiredOrganizationField<String>(
        json,
        'workspace_id',
        _model,
      ),
      super(json) {
    checkOrganizationType(json, type);
  }

  static const _model = 'DeletedTelemetryDestinationWorkspace';

  /// Resource discriminator.
  String get type => 'telemetry_destination_workspace_deleted';

  /// Destination whose workspace list changed.
  final String destinationId;

  /// Workspace removed from the list.
  final String workspaceId;
}

DateTime _timestamp(Map<String, dynamic> json, String key, String model) =>
    DateTime.parse(requiredOrganizationField<String>(json, key, model));

DateTime? _nullableTimestamp(
  Map<String, dynamic> json,
  String key,
  String model,
) {
  final value = requiredOrganizationField<String?>(json, key, model);
  return value == null ? null : DateTime.parse(value);
}

List<String> _headerNames(Map<String, dynamic> json) {
  final names = requiredOrganizationField<List<Object?>>(
    json,
    'header_names',
    'TelemetryDestination',
  );
  if (names.any((name) => name is! String)) {
    throw const FormatException(
      'Expected strings in TelemetryDestination.header_names',
    );
  }
  return List.unmodifiable(names.cast<String>());
}
