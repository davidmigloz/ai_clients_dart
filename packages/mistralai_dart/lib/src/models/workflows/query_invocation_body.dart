import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Body for invoking a workflow query.
@immutable
class QueryInvocationBody {
  /// The query name.
  final String name;

  /// The query input.
  final Object? input;

  /// Creates a [QueryInvocationBody].
  const QueryInvocationBody({required this.name, this.input});

  /// Creates a [QueryInvocationBody] from JSON.
  factory QueryInvocationBody.fromJson(Map<String, dynamic> json) =>
      QueryInvocationBody(
        name: json['name'] as String? ?? '',
        input: json['input'],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (input != null) 'input': input,
  };

  /// Creates a copy with replaced values.
  QueryInvocationBody copyWith({
    String? name,
    Object? input = unsetCopyWithValue,
  }) {
    return QueryInvocationBody(
      name: name ?? this.name,
      input: input == unsetCopyWithValue ? this.input : input,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QueryInvocationBody) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name && valuesDeepEqual(input, other.input);
  }

  @override
  int get hashCode => Object.hash(name, valueDeepHashCode(input));

  @override
  String toString() => 'QueryInvocationBody(name: $name, input: $input)';
}
