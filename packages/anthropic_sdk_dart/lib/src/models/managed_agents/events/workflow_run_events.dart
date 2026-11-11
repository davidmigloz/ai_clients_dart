part of 'session_event.dart';

/// Event kinds emitted for a dynamic workflow run.
enum WorkflowRunEventKind {
  /// A plan was accepted and a run was created.
  created('workflow_run.created'),

  /// A phase began.
  phaseStarted('workflow_run.phase_started'),

  /// A phase finished.
  phaseEnded('workflow_run.phase_ended'),

  /// A run is executing.
  running('workflow_run.status_running'),

  /// A run is idle.
  idle('workflow_run.status_idle'),

  /// A run reached a terminal result.
  ended('workflow_run.status_ended'),

  /// An error occurred while starting or running the workflow.
  error('workflow_run.error');

  const WorkflowRunEventKind(this.value);

  /// Provider event type.
  final String value;

  static WorkflowRunEventKind? _fromWire(String? type) {
    for (final kind in values) {
      if (kind.value == type) return kind;
    }
    return null;
  }
}

/// A phase declared by a workflow plan.
@immutable
final class WorkflowRunPhase {
  /// Phase ID.
  final String id;

  /// Phase name.
  final String name;

  /// Optional description written by the plan.
  final String? description;

  /// Creates a workflow phase.
  const WorkflowRunPhase({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Parses a phase from JSON.
  factory WorkflowRunPhase.fromJson(Map<String, dynamic> json) =>
      WorkflowRunPhase(
        id: _requiredWorkflowField<String>(json, 'id'),
        name: _requiredWorkflowField<String>(json, 'name'),
        description: _requiredNullableWorkflowString(json, 'description'),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowRunPhase &&
          id == other.id &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => Object.hash(id, name, description);

  @override
  String toString() => 'WorkflowRunPhase(id: $id, name: $name)';
}

/// An error reported by the workflow service.
@immutable
final class WorkflowRunError {
  final Map<String, dynamic> _raw;

  /// The original error type, including future error types.
  final String type;

  /// Human-readable provider error.
  final String message;

  WorkflowRunError._(this.type, this.message, Map<String, dynamic> json)
    : _raw = deepUnmodifiableMap(json);

  /// Parses a workflow error.
  factory WorkflowRunError.fromJson(Map<String, dynamic> json) =>
      WorkflowRunError._(
        _requiredWorkflowField<String>(json, 'type'),
        _requiredWorkflowField<String>(json, 'message'),
        json,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowRunError && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() => 'WorkflowRunError(type: $type)';
}

/// Terminal workflow result. Typical values are completed, stopped, and error.
@immutable
final class WorkflowRunResult {
  final Map<String, dynamic> _raw;

  /// The original result type, including future values.
  final String type;

  /// Failure details for an error result.
  final WorkflowRunError? error;

  WorkflowRunResult._(this.type, this.error, Map<String, dynamic> json)
    : _raw = deepUnmodifiableMap(json);

  /// Parses a workflow result.
  factory WorkflowRunResult.fromJson(Map<String, dynamic> json) {
    final type = _requiredWorkflowField<String>(json, 'type');
    return WorkflowRunResult._(
      type,
      type == 'error'
          ? WorkflowRunError.fromJson(
              _requiredWorkflowField<Map<String, dynamic>>(json, 'error'),
            )
          : null,
      json,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowRunResult && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() => 'WorkflowRunResult(type: $type, error: $error)';
}

/// An event from a Managed Agents dynamic workflow run.
@immutable
final class WorkflowRunEvent extends SessionEvent {
  final Map<String, dynamic> _raw;

  /// Event kind.
  final WorkflowRunEventKind kind;

  /// Original event type.
  String get type => kind.value;

  /// Event ID.
  final String id;

  /// When the event was processed.
  final BetaTimestamp processedAt;

  /// Workflow run ID. May be null when a run could not start.
  final String? workflowRunId;

  /// Name of a created workflow.
  final String? name;

  /// Optional description of a created workflow.
  final String? description;

  /// Phases declared by a created workflow.
  final List<WorkflowRunPhase>? phases;

  /// Phase affected by a start or end event.
  final String? workflowRunPhaseId;

  /// ID of the phase-start event paired with a phase-end event.
  final String? phaseStartedId;

  /// Result when the run ended.
  final WorkflowRunResult? result;

  /// Error when the workflow reports an error.
  final WorkflowRunError? error;

  WorkflowRunEvent._({
    required Map<String, dynamic> json,
    required this.kind,
    required this.id,
    required this.processedAt,
    required this.workflowRunId,
    this.name,
    this.description,
    this.phases,
    this.workflowRunPhaseId,
    this.phaseStartedId,
    this.result,
    this.error,
  }) : _raw = deepUnmodifiableMap(Map.of(json)..remove('_event'));

  /// Parses a known workflow event. Use [SessionEvent.fromJson] for unknown
  /// event types.
  factory WorkflowRunEvent.fromJson(Map<String, dynamic> json) {
    final kind = WorkflowRunEventKind._fromWire(json['type'] as String?);
    if (kind == null) {
      throw const FormatException('Unknown workflow event type');
    }
    return WorkflowRunEvent._fromKind(json, kind);
  }

  factory WorkflowRunEvent._fromKind(
    Map<String, dynamic> json,
    WorkflowRunEventKind kind,
  ) {
    final created = kind == WorkflowRunEventKind.created;
    final isPhase =
        kind == WorkflowRunEventKind.phaseStarted ||
        kind == WorkflowRunEventKind.phaseEnded;
    return WorkflowRunEvent._(
      json: json,
      kind: kind,
      id: _requiredWorkflowField<String>(json, 'id'),
      processedAt: DateTime.parse(
        _requiredWorkflowField<String>(json, 'processed_at'),
      ),
      workflowRunId: kind == WorkflowRunEventKind.error
          ? _requiredNullableWorkflowString(json, 'workflow_run_id')
          : _requiredWorkflowField<String>(json, 'workflow_run_id'),
      name: created ? _requiredWorkflowField<String>(json, 'name') : null,
      description: created
          ? _requiredNullableWorkflowString(json, 'description')
          : null,
      phases: created
          ? List.unmodifiable(
              _requiredWorkflowField<List<Object?>>(
                json,
                'phases',
              ).cast<Map<String, dynamic>>().map(WorkflowRunPhase.fromJson),
            )
          : null,
      workflowRunPhaseId: isPhase
          ? _requiredWorkflowField<String>(json, 'workflow_run_phase_id')
          : null,
      phaseStartedId: kind == WorkflowRunEventKind.phaseEnded
          ? _requiredWorkflowField<String>(json, 'phase_started_id')
          : null,
      result: kind == WorkflowRunEventKind.ended
          ? WorkflowRunResult.fromJson(
              _requiredWorkflowField<Map<String, dynamic>>(json, 'result'),
            )
          : null,
      error: kind == WorkflowRunEventKind.error
          ? WorkflowRunError.fromJson(
              _requiredWorkflowField<Map<String, dynamic>>(json, 'error'),
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowRunEvent && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() =>
      'WorkflowRunEvent(type: $type, workflowRunId: $workflowRunId)';
}

T _requiredWorkflowField<T>(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is T) return value;
  throw FormatException('Workflow payload requires "$field"');
}

String? _requiredNullableWorkflowString(
  Map<String, dynamic> json,
  String field,
) {
  final value = json[field];
  if (value is String || value == null && json.containsKey(field)) {
    return value as String?;
  }
  throw FormatException('Workflow payload requires string or null "$field"');
}
