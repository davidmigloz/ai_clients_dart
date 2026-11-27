import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

import '../common/equality_helpers.dart';

import '../webhooks/webhook.dart';

/// An event rule linked to a registered webhook.
@immutable
class Trigger {
  /// Creates a [Trigger].
  const Trigger({
    required this.action,
    required this.creatorId,
    required this.customerId,
    required this.eventSource,
    required this.filters,
    required this.handler,
    required this.id,
    required this.organizationId,
    required this.ownerType,
    required this.title,
    required this.workspaceId,
  });

  /// The action field.
  final TriggerAction action;

  /// The creator_id field.
  final String creatorId;

  /// The customer_id field.
  final String customerId;

  /// The event_source field.
  final Webhook eventSource;

  /// The filters field.
  final String? filters;

  /// The handler field.
  final TriggerHandler handler;

  /// The id field.
  final String id;

  /// The organization_id field.
  final String organizationId;

  /// The owner_type field.
  final TriggerOwnerType ownerType;

  /// The title field.
  final String title;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [Trigger] from JSON.
  factory Trigger.fromJson(Map<String, dynamic> json) {
    if (json['action'] == null) {
      throw const FormatException('Trigger: missing action');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('Trigger: missing creator_id');
    }
    if (json['customer_id'] == null) {
      throw const FormatException('Trigger: missing customer_id');
    }
    if (json['event_source'] == null) {
      throw const FormatException('Trigger: missing event_source');
    }
    if (!json.containsKey('filters')) {
      throw const FormatException('Trigger: missing filters');
    }
    if (json['handler'] == null) {
      throw const FormatException('Trigger: missing handler');
    }
    if (json['id'] == null) {
      throw const FormatException('Trigger: missing id');
    }
    if (json['organization_id'] == null) {
      throw const FormatException('Trigger: missing organization_id');
    }
    if (json['owner_type'] == null) {
      throw const FormatException('Trigger: missing owner_type');
    }
    if (json['title'] == null) {
      throw const FormatException('Trigger: missing title');
    }
    if (json['workspace_id'] == null) {
      throw const FormatException('Trigger: missing workspace_id');
    }
    return Trigger(
      action: TriggerAction.fromJson(json['action'] as Map<String, dynamic>),
      creatorId: json['creator_id'] as String,
      customerId: json['customer_id'] as String,
      eventSource: Webhook.fromJson(
        json['event_source'] as Map<String, dynamic>,
      ),
      filters: json['filters'] == null ? null : json['filters'] as String,
      handler: TriggerHandler.fromJson(json['handler'] as String),
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      ownerType: TriggerOwnerType.fromJson(json['owner_type'] as String),
      title: json['title'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'action': action.toJson(),
    'creator_id': creatorId,
    'customer_id': customerId,
    'event_source': eventSource.toJson(),
    'filters': filters,
    'handler': handler.toJson(),
    'id': id,
    'organization_id': organizationId,
    'owner_type': ownerType.toJson(),
    'title': title,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  Trigger copyWith({
    TriggerAction? action,
    String? creatorId,
    String? customerId,
    Webhook? eventSource,
    Object? filters = unsetCopyWithValue,
    TriggerHandler? handler,
    String? id,
    String? organizationId,
    TriggerOwnerType? ownerType,
    String? title,
    String? workspaceId,
  }) => Trigger(
    action: action ?? this.action,
    creatorId: creatorId ?? this.creatorId,
    customerId: customerId ?? this.customerId,
    eventSource: eventSource ?? this.eventSource,
    filters: filters == unsetCopyWithValue ? this.filters : filters as String?,
    handler: handler ?? this.handler,
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    ownerType: ownerType ?? this.ownerType,
    title: title ?? this.title,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trigger &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          creatorId == other.creatorId &&
          customerId == other.customerId &&
          eventSource == other.eventSource &&
          filters == other.filters &&
          handler == other.handler &&
          id == other.id &&
          organizationId == other.organizationId &&
          ownerType == other.ownerType &&
          title == other.title &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    action,
    creatorId,
    customerId,
    eventSource,
    filters,
    handler,
    id,
    organizationId,
    ownerType,
    title,
    workspaceId,
  ]);

  @override
  String toString() =>
      'Trigger('
      'action: $action, '
      'creatorId: $creatorId, '
      'customerId: $customerId, '
      'eventSource: $eventSource, '
      'filters: $filters, '
      'handler: $handler, '
      'id: $id, '
      'organizationId: $organizationId, '
      'ownerType: $ownerType, '
      'title: $title, '
      'workspaceId: $workspaceId)';
}

/// The primitive to start, build, or deploy when a trigger matches.
@immutable
class TriggerAction {
  /// Creates a [TriggerAction].
  const TriggerAction({required this.primitiveId, required this.type});

  /// The primitive_id field.
  final String primitiveId;

  /// The type field.
  final TriggerActionType type;

  /// Parses a [TriggerAction] from JSON.
  factory TriggerAction.fromJson(Map<String, dynamic> json) {
    if (json['primitive_id'] == null) {
      throw const FormatException('TriggerAction: missing primitive_id');
    }
    if (json['type'] == null) {
      throw const FormatException('TriggerAction: missing type');
    }
    return TriggerAction(
      primitiveId: json['primitive_id'] as String,
      type: TriggerActionType.fromJson(json['type'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'primitive_id': primitiveId,
    'type': type.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  TriggerAction copyWith({String? primitiveId, TriggerActionType? type}) =>
      TriggerAction(
        primitiveId: primitiveId ?? this.primitiveId,
        type: type ?? this.type,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriggerAction &&
          runtimeType == other.runtimeType &&
          primitiveId == other.primitiveId &&
          type == other.type;

  @override
  int get hashCode => Object.hashAll([primitiveId, type]);

  @override
  String toString() =>
      'TriggerAction('
      'primitiveId: $primitiveId, '
      'type: $type)';
}

/// Registers a trigger and attaches it to a webhook event source.
@immutable
class CreateTriggerRequest {
  /// Creates a [CreateTriggerRequest].
  const CreateTriggerRequest({
    required this.action,
    required this.eventSourceId,
    this.filters,
    required this.handler,
    required this.ownerType,
    required this.title,
  });

  /// Action to execute when the trigger fires
  final TriggerAction action;

  /// ID of the event source that fires this trigger
  final String eventSourceId;

  /// jmespath expression to filter events, e.g. event_type == 'push' && repository.name == 'dashboard'
  final String? filters;

  /// workflows, agents, or spaces
  final TriggerHandler handler;

  /// The owner_type field.
  final TriggerOwnerType ownerType;

  /// Human-readable title of the trigger
  final String title;

  /// Parses a [CreateTriggerRequest] from JSON.
  factory CreateTriggerRequest.fromJson(Map<String, dynamic> json) {
    if (json['action'] == null) {
      throw const FormatException('CreateTriggerRequest: missing action');
    }
    if (json['event_source_id'] == null) {
      throw const FormatException(
        'CreateTriggerRequest: missing event_source_id',
      );
    }
    if (json['handler'] == null) {
      throw const FormatException('CreateTriggerRequest: missing handler');
    }
    if (json['owner_type'] == null) {
      throw const FormatException('CreateTriggerRequest: missing owner_type');
    }
    if (json['title'] == null) {
      throw const FormatException('CreateTriggerRequest: missing title');
    }
    return CreateTriggerRequest(
      action: TriggerAction.fromJson(json['action'] as Map<String, dynamic>),
      eventSourceId: json['event_source_id'] as String,
      filters: json['filters'] == null ? null : json['filters'] as String,
      handler: TriggerHandler.fromJson(json['handler'] as String),
      ownerType: TriggerOwnerType.fromJson(json['owner_type'] as String),
      title: json['title'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'action': action.toJson(),
    'event_source_id': eventSourceId,
    'filters': ?filters,
    'handler': handler.toJson(),
    'owner_type': ownerType.toJson(),
    'title': title,
  };

  /// Creates a copy with the given fields replaced.
  CreateTriggerRequest copyWith({
    TriggerAction? action,
    String? eventSourceId,
    Object? filters = unsetCopyWithValue,
    TriggerHandler? handler,
    TriggerOwnerType? ownerType,
    String? title,
  }) => CreateTriggerRequest(
    action: action ?? this.action,
    eventSourceId: eventSourceId ?? this.eventSourceId,
    filters: filters == unsetCopyWithValue ? this.filters : filters as String?,
    handler: handler ?? this.handler,
    ownerType: ownerType ?? this.ownerType,
    title: title ?? this.title,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateTriggerRequest &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          eventSourceId == other.eventSourceId &&
          filters == other.filters &&
          handler == other.handler &&
          ownerType == other.ownerType &&
          title == other.title;

  @override
  int get hashCode => Object.hashAll([
    action,
    eventSourceId,
    filters,
    handler,
    ownerType,
    title,
  ]);

  @override
  String toString() =>
      'CreateTriggerRequest('
      'action: $action, '
      'eventSourceId: $eventSourceId, '
      'filters: $filters, '
      'handler: $handler, '
      'ownerType: $ownerType, '
      'title: $title)';
}

/// The service that executes a trigger's action.
enum TriggerHandler {
  /// Represents workflows.
  workflows('workflows'),

  /// Represents agents.
  agents('agents'),

  /// Represents spaces.
  spaces('spaces'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const TriggerHandler(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static TriggerHandler fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The workflow, app, or agent action to perform.
enum TriggerActionType {
  /// Represents start_workflow.
  startWorkflow('start_workflow'),

  /// Represents build_app.
  buildApp('build_app'),

  /// Represents deploy_app.
  deployApp('deploy_app'),

  /// Represents start_agent_session.
  startAgentSession('start_agent_session'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const TriggerActionType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static TriggerActionType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Recent deliveries and execution state for a trigger.
@immutable
class TriggerEventList {
  /// Creates a [TriggerEventList].
  const TriggerEventList({required this.data});

  /// The data field.
  final List<TriggerEvent> data;

  /// Parses a [TriggerEventList] from JSON.
  factory TriggerEventList.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('TriggerEventList: missing data');
    }
    return TriggerEventList(
      data: (json['data'] as List)
          .map((item) => TriggerEvent.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  TriggerEventList copyWith({List<TriggerEvent>? data}) =>
      TriggerEventList(data: data ?? this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriggerEventList &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(data)]);

  @override
  String toString() =>
      'TriggerEventList('
      'data: ${data.length})';
}

/// A recorded attempt to handle a webhook delivery.
@immutable
class TriggerEvent {
  /// Creates a [TriggerEvent].
  const TriggerEvent({
    required this.detail,
    required this.eventId,
    required this.receivedAt,
    required this.sourceId,
    required this.status,
    required this.submittedAt,
    required this.triggerId,
    required this.triggeredAt,
    required this.url,
  });

  /// The detail field.
  final String? detail;

  /// The event_id field.
  final String eventId;

  /// The received_at field.
  final String receivedAt;

  /// The source_id field.
  final String sourceId;

  /// The status field.
  final TriggerStatus status;

  /// The submitted_at field.
  final String? submittedAt;

  /// The trigger_id field.
  final String triggerId;

  /// The triggered_at field.
  final String? triggeredAt;

  /// The url field.
  final String? url;

  /// Parses a [TriggerEvent] from JSON.
  factory TriggerEvent.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('detail')) {
      throw const FormatException('TriggerEvent: missing detail');
    }
    if (json['event_id'] == null) {
      throw const FormatException('TriggerEvent: missing event_id');
    }
    if (json['received_at'] == null) {
      throw const FormatException('TriggerEvent: missing received_at');
    }
    if (json['source_id'] == null) {
      throw const FormatException('TriggerEvent: missing source_id');
    }
    if (json['status'] == null) {
      throw const FormatException('TriggerEvent: missing status');
    }
    if (!json.containsKey('submitted_at')) {
      throw const FormatException('TriggerEvent: missing submitted_at');
    }
    if (json['trigger_id'] == null) {
      throw const FormatException('TriggerEvent: missing trigger_id');
    }
    if (!json.containsKey('triggered_at')) {
      throw const FormatException('TriggerEvent: missing triggered_at');
    }
    if (!json.containsKey('url')) {
      throw const FormatException('TriggerEvent: missing url');
    }
    return TriggerEvent(
      detail: json['detail'] == null ? null : json['detail'] as String,
      eventId: json['event_id'] as String,
      receivedAt: json['received_at'] as String,
      sourceId: json['source_id'] as String,
      status: TriggerStatus.fromJson(json['status'] as String),
      submittedAt: json['submitted_at'] == null
          ? null
          : json['submitted_at'] as String,
      triggerId: json['trigger_id'] as String,
      triggeredAt: json['triggered_at'] == null
          ? null
          : json['triggered_at'] as String,
      url: json['url'] == null ? null : json['url'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'detail': detail,
    'event_id': eventId,
    'received_at': receivedAt,
    'source_id': sourceId,
    'status': status.toJson(),
    'submitted_at': submittedAt,
    'trigger_id': triggerId,
    'triggered_at': triggeredAt,
    'url': url,
  };

  /// Creates a copy with the given fields replaced.
  TriggerEvent copyWith({
    Object? detail = unsetCopyWithValue,
    String? eventId,
    String? receivedAt,
    String? sourceId,
    TriggerStatus? status,
    Object? submittedAt = unsetCopyWithValue,
    String? triggerId,
    Object? triggeredAt = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
  }) => TriggerEvent(
    detail: detail == unsetCopyWithValue ? this.detail : detail as String?,
    eventId: eventId ?? this.eventId,
    receivedAt: receivedAt ?? this.receivedAt,
    sourceId: sourceId ?? this.sourceId,
    status: status ?? this.status,
    submittedAt: submittedAt == unsetCopyWithValue
        ? this.submittedAt
        : submittedAt as String?,
    triggerId: triggerId ?? this.triggerId,
    triggeredAt: triggeredAt == unsetCopyWithValue
        ? this.triggeredAt
        : triggeredAt as String?,
    url: url == unsetCopyWithValue ? this.url : url as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriggerEvent &&
          runtimeType == other.runtimeType &&
          detail == other.detail &&
          eventId == other.eventId &&
          receivedAt == other.receivedAt &&
          sourceId == other.sourceId &&
          status == other.status &&
          submittedAt == other.submittedAt &&
          triggerId == other.triggerId &&
          triggeredAt == other.triggeredAt &&
          url == other.url;

  @override
  int get hashCode => Object.hashAll([
    detail,
    eventId,
    receivedAt,
    sourceId,
    status,
    submittedAt,
    triggerId,
    triggeredAt,
    url,
  ]);

  @override
  String toString() =>
      'TriggerEvent('
      'detail: $detail, '
      'eventId: $eventId, '
      'receivedAt: $receivedAt, '
      'sourceId: $sourceId, '
      'status: $status, '
      'submittedAt: $submittedAt, '
      'triggerId: $triggerId, '
      'triggeredAt: $triggeredAt, '
      'url: $url)';
}

/// Processing status for an event that matched a trigger.
enum TriggerStatus {
  /// Represents SUBMITTED.
  submitted('SUBMITTED'),

  /// Represents SUBMISSION_FAILED.
  submissionFailed('SUBMISSION_FAILED'),

  /// Represents TRIGGERED.
  triggered('TRIGGERED'),

  /// Represents TRIGGER_FAILED.
  triggerFailed('TRIGGER_FAILED'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const TriggerStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static TriggerStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}
