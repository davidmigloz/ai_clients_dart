import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to update a workflow.
@immutable
class WorkflowUpdateRequest {
  /// The new display name.
  final String? displayName;

  /// The new description.
  final String? description;

  /// Whether to make available in chat assistant.
  final bool? availableInChatAssistant;

  /// Creates a [WorkflowUpdateRequest].
  const WorkflowUpdateRequest({
    this.displayName,
    this.description,
    this.availableInChatAssistant,
  });

  /// Creates a [WorkflowUpdateRequest] from JSON.
  factory WorkflowUpdateRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowUpdateRequest(
        displayName: json['display_name'] as String?,
        description: json['description'] as String?,
        availableInChatAssistant: json['available_in_chat_assistant'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (displayName != null) 'display_name': displayName,
    if (description != null) 'description': description,
    if (availableInChatAssistant != null)
      'available_in_chat_assistant': availableInChatAssistant,
  };

  /// Creates a copy with replaced values.
  WorkflowUpdateRequest copyWith({
    Object? displayName = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? availableInChatAssistant = unsetCopyWithValue,
  }) {
    return WorkflowUpdateRequest(
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      availableInChatAssistant: availableInChatAssistant == unsetCopyWithValue
          ? this.availableInChatAssistant
          : availableInChatAssistant as bool?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowUpdateRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return displayName == other.displayName &&
        description == other.description &&
        availableInChatAssistant == other.availableInChatAssistant;
  }

  @override
  int get hashCode =>
      Object.hash(displayName, description, availableInChatAssistant);

  @override
  String toString() =>
      'WorkflowUpdateRequest(displayName: $displayName, description: $description, availableInChatAssistant: $availableInChatAssistant)';
}
