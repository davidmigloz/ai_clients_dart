import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Reason a prompt-cache lookup missed (Beta).
///
/// Returned within [Diagnostics] to explain why the cached prefix could not be
/// reused. Dispatches on the `type` discriminator.
///
/// Variants:
/// - [CacheMissModelChanged] — `model_changed` (the model differs from the
///   cached request).
/// - [CacheMissSystemChanged] — `system_changed` (the system prompt differs).
/// - [CacheMissToolsChanged] — `tools_changed` (the tool definitions differ).
/// - [CacheMissMessagesChanged] — `messages_changed` (the messages differ).
/// - [CacheMissPreviousMessageNotFound] — `previous_message_not_found` (the
///   referenced previous message could not be located).
/// - [CacheMissUnavailable] — `unavailable` (diagnostics are unavailable).
/// - [UnknownCacheMissReason] — unrecognized reason type, for forward
///   compatibility.
sealed class CacheMissReason {
  const CacheMissReason();

  /// Creates a [CacheMissModelChanged] reason.
  const factory CacheMissReason.modelChanged({
    required int cacheMissedInputTokens,
  }) = CacheMissModelChanged;

  /// Creates a [CacheMissSystemChanged] reason.
  const factory CacheMissReason.systemChanged({
    required int cacheMissedInputTokens,
  }) = CacheMissSystemChanged;

  /// Creates a [CacheMissToolsChanged] reason.
  const factory CacheMissReason.toolsChanged({
    required int cacheMissedInputTokens,
  }) = CacheMissToolsChanged;

  /// Creates a [CacheMissMessagesChanged] reason.
  const factory CacheMissReason.messagesChanged({
    required int cacheMissedInputTokens,
  }) = CacheMissMessagesChanged;

  /// Creates a [CacheMissPreviousMessageNotFound] reason.
  const factory CacheMissReason.previousMessageNotFound() =
      CacheMissPreviousMessageNotFound;

  /// Creates a [CacheMissUnavailable] reason.
  const factory CacheMissReason.unavailable() = CacheMissUnavailable;

  /// Creates a [CacheMissReason] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownCacheMissReason].
  factory CacheMissReason.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'model_changed' => CacheMissModelChanged.fromJson(json),
      'system_changed' => CacheMissSystemChanged.fromJson(json),
      'tools_changed' => CacheMissToolsChanged.fromJson(json),
      'messages_changed' => CacheMissMessagesChanged.fromJson(json),
      'previous_message_not_found' => CacheMissPreviousMessageNotFound.fromJson(
        json,
      ),
      'unavailable' => CacheMissUnavailable.fromJson(json),
      _ => UnknownCacheMissReason(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Cache miss because the model changed.
@immutable
class CacheMissModelChanged extends CacheMissReason {
  /// Number of input tokens that missed the cache.
  final int cacheMissedInputTokens;

  /// Creates a [CacheMissModelChanged].
  const CacheMissModelChanged({required this.cacheMissedInputTokens});

  /// Creates a [CacheMissModelChanged] from JSON.
  factory CacheMissModelChanged.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'model_changed') {
      throw FormatException(
        'Invalid CacheMissModelChanged type: expected "model_changed", '
        'got "$type"',
      );
    }
    return CacheMissModelChanged(
      cacheMissedInputTokens: json['cache_missed_input_tokens'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'model_changed',
    'cache_missed_input_tokens': cacheMissedInputTokens,
  };

  /// Creates a copy with replaced values.
  CacheMissModelChanged copyWith({int? cacheMissedInputTokens}) =>
      CacheMissModelChanged(
        cacheMissedInputTokens:
            cacheMissedInputTokens ?? this.cacheMissedInputTokens,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMissModelChanged &&
          runtimeType == other.runtimeType &&
          cacheMissedInputTokens == other.cacheMissedInputTokens;

  @override
  int get hashCode => cacheMissedInputTokens.hashCode;

  @override
  String toString() =>
      'CacheMissModelChanged(cacheMissedInputTokens: $cacheMissedInputTokens)';
}

/// Cache miss because the system prompt changed.
@immutable
class CacheMissSystemChanged extends CacheMissReason {
  /// Number of input tokens that missed the cache.
  final int cacheMissedInputTokens;

  /// Creates a [CacheMissSystemChanged].
  const CacheMissSystemChanged({required this.cacheMissedInputTokens});

  /// Creates a [CacheMissSystemChanged] from JSON.
  factory CacheMissSystemChanged.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'system_changed') {
      throw FormatException(
        'Invalid CacheMissSystemChanged type: expected "system_changed", '
        'got "$type"',
      );
    }
    return CacheMissSystemChanged(
      cacheMissedInputTokens: json['cache_missed_input_tokens'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'system_changed',
    'cache_missed_input_tokens': cacheMissedInputTokens,
  };

  /// Creates a copy with replaced values.
  CacheMissSystemChanged copyWith({int? cacheMissedInputTokens}) =>
      CacheMissSystemChanged(
        cacheMissedInputTokens:
            cacheMissedInputTokens ?? this.cacheMissedInputTokens,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMissSystemChanged &&
          runtimeType == other.runtimeType &&
          cacheMissedInputTokens == other.cacheMissedInputTokens;

  @override
  int get hashCode => cacheMissedInputTokens.hashCode;

  @override
  String toString() =>
      'CacheMissSystemChanged(cacheMissedInputTokens: $cacheMissedInputTokens)';
}

/// Cache miss because the tool definitions changed.
@immutable
class CacheMissToolsChanged extends CacheMissReason {
  /// Number of input tokens that missed the cache.
  final int cacheMissedInputTokens;

  /// Creates a [CacheMissToolsChanged].
  const CacheMissToolsChanged({required this.cacheMissedInputTokens});

  /// Creates a [CacheMissToolsChanged] from JSON.
  factory CacheMissToolsChanged.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'tools_changed') {
      throw FormatException(
        'Invalid CacheMissToolsChanged type: expected "tools_changed", '
        'got "$type"',
      );
    }
    return CacheMissToolsChanged(
      cacheMissedInputTokens: json['cache_missed_input_tokens'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tools_changed',
    'cache_missed_input_tokens': cacheMissedInputTokens,
  };

  /// Creates a copy with replaced values.
  CacheMissToolsChanged copyWith({int? cacheMissedInputTokens}) =>
      CacheMissToolsChanged(
        cacheMissedInputTokens:
            cacheMissedInputTokens ?? this.cacheMissedInputTokens,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMissToolsChanged &&
          runtimeType == other.runtimeType &&
          cacheMissedInputTokens == other.cacheMissedInputTokens;

  @override
  int get hashCode => cacheMissedInputTokens.hashCode;

  @override
  String toString() =>
      'CacheMissToolsChanged(cacheMissedInputTokens: $cacheMissedInputTokens)';
}

/// Cache miss because the messages changed.
@immutable
class CacheMissMessagesChanged extends CacheMissReason {
  /// Number of input tokens that missed the cache.
  final int cacheMissedInputTokens;

  /// Creates a [CacheMissMessagesChanged].
  const CacheMissMessagesChanged({required this.cacheMissedInputTokens});

  /// Creates a [CacheMissMessagesChanged] from JSON.
  factory CacheMissMessagesChanged.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'messages_changed') {
      throw FormatException(
        'Invalid CacheMissMessagesChanged type: expected "messages_changed", '
        'got "$type"',
      );
    }
    return CacheMissMessagesChanged(
      cacheMissedInputTokens: json['cache_missed_input_tokens'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'messages_changed',
    'cache_missed_input_tokens': cacheMissedInputTokens,
  };

  /// Creates a copy with replaced values.
  CacheMissMessagesChanged copyWith({int? cacheMissedInputTokens}) =>
      CacheMissMessagesChanged(
        cacheMissedInputTokens:
            cacheMissedInputTokens ?? this.cacheMissedInputTokens,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMissMessagesChanged &&
          runtimeType == other.runtimeType &&
          cacheMissedInputTokens == other.cacheMissedInputTokens;

  @override
  int get hashCode => cacheMissedInputTokens.hashCode;

  @override
  String toString() =>
      'CacheMissMessagesChanged('
      'cacheMissedInputTokens: $cacheMissedInputTokens)';
}

/// Cache miss because the referenced previous message was not found.
@immutable
class CacheMissPreviousMessageNotFound extends CacheMissReason {
  /// Creates a [CacheMissPreviousMessageNotFound].
  const CacheMissPreviousMessageNotFound();

  /// Creates a [CacheMissPreviousMessageNotFound] from JSON.
  factory CacheMissPreviousMessageNotFound.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'previous_message_not_found') {
      throw FormatException(
        'Invalid CacheMissPreviousMessageNotFound type: expected '
        '"previous_message_not_found", got "$type"',
      );
    }
    return const CacheMissPreviousMessageNotFound();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'previous_message_not_found'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMissPreviousMessageNotFound &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CacheMissPreviousMessageNotFound()';
}

/// Cache miss because diagnostics are unavailable.
@immutable
class CacheMissUnavailable extends CacheMissReason {
  /// Creates a [CacheMissUnavailable].
  const CacheMissUnavailable();

  /// Creates a [CacheMissUnavailable] from JSON.
  factory CacheMissUnavailable.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'unavailable') {
      throw FormatException(
        'Invalid CacheMissUnavailable type: expected "unavailable", '
        'got "$type"',
      );
    }
    return const CacheMissUnavailable();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'unavailable'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMissUnavailable && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CacheMissUnavailable()';
}

/// Unrecognized cache miss reason — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownCacheMissReason extends CacheMissReason {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownCacheMissReason].
  const UnknownCacheMissReason({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownCacheMissReason &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownCacheMissReason(rawJson: $rawJson)';
}
