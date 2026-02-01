import 'package:meta/meta.dart';

/// A ChatKit thread.
///
/// Represents a conversation thread in the ChatKit API.
///
/// ## Example
///
/// ```dart
/// final threads = await client.chatkit.threads.list();
/// for (final thread in threads.data) {
///   print('${thread.title ?? thread.id}: ${thread.status.type}');
/// }
/// ```
@immutable
class ChatkitThread {
  /// Creates a [ChatkitThread].
  const ChatkitThread({
    required this.id,
    required this.object,
    required this.createdAt,
    this.title,
    required this.status,
    required this.user,
  });

  /// Creates a [ChatkitThread] from JSON.
  factory ChatkitThread.fromJson(Map<String, dynamic> json) {
    return ChatkitThread(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'chatkit.thread',
      createdAt: json['created_at'] as int,
      title: json['title'] as String?,
      status: ChatkitThreadStatus.fromJson(
        json['status'] as Map<String, dynamic>,
      ),
      user: json['user'] as String,
    );
  }

  /// Identifier of the thread.
  final String id;

  /// Type discriminator that is always `chatkit.thread`.
  final String object;

  /// Unix timestamp (in seconds) for when the thread was created.
  final int createdAt;

  /// Optional human-readable title for the thread.
  final String? title;

  /// Current status for the thread.
  final ChatkitThreadStatus status;

  /// Free-form string that identifies the end user who owns the thread.
  final String user;

  /// The creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'title': title,
    'status': status.toJson(),
    'user': user,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatkitThread &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ChatkitThread(id: $id, title: $title)';
}

/// A list of ChatKit threads.
@immutable
class ChatkitThreadList {
  /// Creates a [ChatkitThreadList].
  const ChatkitThreadList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [ChatkitThreadList] from JSON.
  factory ChatkitThreadList.fromJson(Map<String, dynamic> json) {
    return ChatkitThreadList(
      object: json['object'] as String? ?? 'list',
      data: (json['data'] as List<dynamic>)
          .map((e) => ChatkitThread.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type, which is always `list`.
  final String object;

  /// The list of threads.
  final List<ChatkitThread> data;

  /// The ID of the first thread in the list.
  final String? firstId;

  /// The ID of the last thread in the list.
  final String? lastId;

  /// Whether there are more threads available.
  final bool hasMore;

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of threads.
  int get length => data.length;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((t) => t.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatkitThreadList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          data.length == other.data.length;

  @override
  int get hashCode => Object.hash(object, data.length);

  @override
  String toString() => 'ChatkitThreadList(${data.length} threads)';
}

/// The response from deleting a ChatKit thread.
@immutable
class DeleteChatkitThreadResponse {
  /// Creates a [DeleteChatkitThreadResponse].
  const DeleteChatkitThreadResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteChatkitThreadResponse] from JSON.
  factory DeleteChatkitThreadResponse.fromJson(Map<String, dynamic> json) {
    return DeleteChatkitThreadResponse(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'chatkit.thread.deleted',
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted thread.
  final String id;

  /// The object type.
  final String object;

  /// Whether the thread was successfully deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteChatkitThreadResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(id, deleted);

  @override
  String toString() =>
      'DeleteChatkitThreadResponse(id: $id, deleted: $deleted)';
}

/// Thread status.
@immutable
class ChatkitThreadStatus {
  /// Creates a [ChatkitThreadStatus].
  const ChatkitThreadStatus({required this.type, this.reason});

  /// Creates a [ChatkitThreadStatus] from JSON.
  factory ChatkitThreadStatus.fromJson(Map<String, dynamic> json) {
    return ChatkitThreadStatus(
      type: json['type'] as String,
      reason: json['reason'] as String?,
    );
  }

  /// Creates an active status.
  factory ChatkitThreadStatus.active() =>
      const ChatkitThreadStatus(type: 'active');

  /// Creates a locked status.
  factory ChatkitThreadStatus.locked({String? reason}) =>
      ChatkitThreadStatus(type: 'locked', reason: reason);

  /// Creates a closed status.
  factory ChatkitThreadStatus.closed({String? reason}) =>
      ChatkitThreadStatus(type: 'closed', reason: reason);

  /// The status type (active, locked, or closed).
  final String type;

  /// Optional reason for locked or closed status.
  final String? reason;

  /// Whether the thread is active.
  bool get isActive => type == 'active';

  /// Whether the thread is locked.
  bool get isLocked => type == 'locked';

  /// Whether the thread is closed.
  bool get isClosed => type == 'closed';

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (reason != null) 'reason': reason,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatkitThreadStatus &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ChatkitThreadStatus(type: $type)';
}
