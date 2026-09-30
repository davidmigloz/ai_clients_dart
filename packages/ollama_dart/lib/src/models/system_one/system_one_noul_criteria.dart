import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '_system_one_helpers.dart';

/// Optional descriptions for the false and true outcomes of a Noul question.
///
/// Omitted descriptions use the server defaults of `No` and `Yes`.
@immutable
class SystemOneNoulCriteria {
  /// Creates descriptions for either or both outcomes.
  const SystemOneNoulCriteria({this.falseDescription, this.trueDescription});

  /// Description of the false outcome; omitted when null.
  final String? falseDescription;

  /// Description of the true outcome; omitted when null.
  final String? trueDescription;

  /// Creates criteria from JSON, rejecting unknown outcomes and null values.
  factory SystemOneNoulCriteria.fromJson(Map<String, dynamic> json) {
    if (json.keys.any((key) => key != 'false' && key != 'true')) {
      throw const FormatException(
        'SystemOneNoulCriteria may contain only false and true descriptions',
      );
    }
    return SystemOneNoulCriteria(
      falseDescription: json.containsKey('false')
          ? systemOneString(json['false'], 'SystemOneNoulCriteria.false')
          : null,
      trueDescription: json.containsKey('true')
          ? systemOneString(json['true'], 'SystemOneNoulCriteria.true')
          : null,
    );
  }

  /// Converts to JSON, omitting unspecified outcome descriptions.
  Map<String, dynamic> toJson() => {
    if (falseDescription != null) 'false': falseDescription,
    if (trueDescription != null) 'true': trueDescription,
  };

  /// Creates a copy; passing null clears an outcome description.
  SystemOneNoulCriteria copyWith({
    Object? falseDescription = unsetCopyWithValue,
    Object? trueDescription = unsetCopyWithValue,
  }) => SystemOneNoulCriteria(
    falseDescription: falseDescription == unsetCopyWithValue
        ? this.falseDescription
        : falseDescription as String?,
    trueDescription: trueDescription == unsetCopyWithValue
        ? this.trueDescription
        : trueDescription as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneNoulCriteria &&
          falseDescription == other.falseDescription &&
          trueDescription == other.trueDescription;

  @override
  int get hashCode => Object.hash(falseDescription, trueDescription);

  @override
  String toString() =>
      'SystemOneNoulCriteria(falseDescription: $falseDescription, '
      'trueDescription: $trueDescription)';
}
