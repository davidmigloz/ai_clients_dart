import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

/// Token-based task budget for managed-agents compaction.
///
/// Tracks total and remaining tokens so clients can implement compaction
/// client-side across multiple contexts in a session.
@immutable
class TokenTaskBudget {
  /// The budget type. Currently only 'tokens' is supported.
  final String type;

  /// Total token budget across all contexts in the session. Minimum 1024.
  final int total;

  /// Remaining tokens in the budget, used to track usage across contexts when
  /// implementing compaction client-side. `null` when unset; the server
  /// treats an absent value as equivalent to [total].
  final int? remaining;

  /// Creates a [TokenTaskBudget].
  const TokenTaskBudget({
    required this.total,
    this.remaining,
    this.type = 'tokens',
  });

  /// Creates a [TokenTaskBudget] from JSON.
  factory TokenTaskBudget.fromJson(Map<String, dynamic> json) {
    return TokenTaskBudget(
      type: json['type'] as String? ?? 'tokens',
      total: json['total'] as int,
      remaining: json['remaining'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'total': total,
    if (remaining != null) 'remaining': remaining,
  };

  /// Creates a copy with replaced values.
  TokenTaskBudget copyWith({
    String? type,
    int? total,
    Object? remaining = unsetCopyWithValue,
  }) {
    return TokenTaskBudget(
      type: type ?? this.type,
      total: total ?? this.total,
      remaining: remaining == unsetCopyWithValue
          ? this.remaining
          : remaining as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenTaskBudget &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          total == other.total &&
          remaining == other.remaining;

  @override
  int get hashCode => Object.hash(type, total, remaining);

  @override
  String toString() =>
      'TokenTaskBudget(type: $type, total: $total, remaining: $remaining)';
}
