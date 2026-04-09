import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow_type.dart';

/// A workflow with worker status information.
@immutable
class WorkflowWithWorkerStatus {
  /// The workflow identifier.
  final String id;

  /// The workflow name.
  final String name;

  /// The display name.
  final String displayName;

  /// The workflow type.
  final WorkflowType type;

  /// The customer identifier.
  final String customerId;

  /// The workspace identifier.
  final String workspaceId;

  /// Whether the workflow has active workers.
  final bool active;

  /// The workflow description.
  final String? description;

  /// Whether the workflow is archived.
  final bool archived;

  /// Whether available in chat assistant.
  final bool availableInChatAssistant;

  /// Whether this is a technical workflow.
  final bool isTechnical;

  /// The shared namespace.
  final String? sharedNamespace;

  /// Creates a [WorkflowWithWorkerStatus].
  const WorkflowWithWorkerStatus({
    required this.id,
    required this.name,
    required this.displayName,
    required this.type,
    required this.customerId,
    required this.workspaceId,
    required this.active,
    this.description,
    this.archived = false,
    this.availableInChatAssistant = false,
    this.isTechnical = false,
    this.sharedNamespace,
  });

  /// Creates a [WorkflowWithWorkerStatus] from JSON.
  factory WorkflowWithWorkerStatus.fromJson(Map<String, dynamic> json) =>
      WorkflowWithWorkerStatus(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        type: WorkflowType.fromJson(json['type'] as String?),
        customerId: json['customer_id'] as String? ?? '',
        workspaceId: json['workspace_id'] as String? ?? '',
        active: json['active'] as bool? ?? false,
        description: json['description'] as String?,
        archived: json['archived'] as bool? ?? false,
        availableInChatAssistant:
            json['available_in_chat_assistant'] as bool? ?? false,
        isTechnical: json['is_technical'] as bool? ?? false,
        sharedNamespace: json['shared_namespace'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'display_name': displayName,
    'type': type.toJson(),
    'customer_id': customerId,
    'workspace_id': workspaceId,
    'active': active,
    if (description != null) 'description': description,
    'archived': archived,
    'available_in_chat_assistant': availableInChatAssistant,
    'is_technical': isTechnical,
    if (sharedNamespace != null) 'shared_namespace': sharedNamespace,
  };

  /// Creates a copy with replaced values.
  WorkflowWithWorkerStatus copyWith({
    String? id,
    String? name,
    String? displayName,
    WorkflowType? type,
    String? customerId,
    String? workspaceId,
    bool? active,
    Object? description = unsetCopyWithValue,
    bool? archived,
    bool? availableInChatAssistant,
    bool? isTechnical,
    Object? sharedNamespace = unsetCopyWithValue,
  }) {
    return WorkflowWithWorkerStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      workspaceId: workspaceId ?? this.workspaceId,
      active: active ?? this.active,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      archived: archived ?? this.archived,
      availableInChatAssistant:
          availableInChatAssistant ?? this.availableInChatAssistant,
      isTechnical: isTechnical ?? this.isTechnical,
      sharedNamespace: sharedNamespace == unsetCopyWithValue
          ? this.sharedNamespace
          : sharedNamespace as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowWithWorkerStatus) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        name == other.name &&
        displayName == other.displayName &&
        type == other.type &&
        customerId == other.customerId &&
        workspaceId == other.workspaceId &&
        active == other.active &&
        description == other.description &&
        archived == other.archived &&
        availableInChatAssistant == other.availableInChatAssistant &&
        isTechnical == other.isTechnical &&
        sharedNamespace == other.sharedNamespace;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    displayName,
    type,
    customerId,
    workspaceId,
    active,
    description,
    archived,
    availableInChatAssistant,
    isTechnical,
    sharedNamespace,
  );

  @override
  String toString() =>
      'WorkflowWithWorkerStatus('
      'id: $id, '
      'name: $name, '
      'displayName: $displayName, '
      'type: $type, '
      'customerId: $customerId, '
      'workspaceId: $workspaceId, '
      'active: $active, '
      'description: $description, '
      'archived: $archived, '
      'availableInChatAssistant: $availableInChatAssistant, '
      'isTechnical: $isTechnical, '
      'sharedNamespace: $sharedNamespace'
      ')';
}
