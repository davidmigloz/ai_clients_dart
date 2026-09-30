import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/model_options.dart';

/// Request to show model details.
@immutable
class ShowRequest {
  /// Model name to show.
  final String model;

  /// If true, includes large verbose fields in the response.
  final bool? verbose;

  /// System prompt override used when generating the returned Modelfile.
  final String? system;

  /// Parameter overrides used when generating the returned Modelfile.
  final ModelOptions? options;

  /// Creates a [ShowRequest].
  const ShowRequest({
    required this.model,
    this.verbose,
    this.system,
    this.options,
  });

  /// Creates a [ShowRequest] from JSON.
  factory ShowRequest.fromJson(Map<String, dynamic> json) => ShowRequest(
    system: json['system'] as String?,
    options: json['options'] != null
        ? ModelOptions.fromJson(json['options'] as Map<String, dynamic>)
        : null,
    model: json['model'] as String,
    verbose: json['verbose'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (system != null) 'system': system,
    if (options != null) 'options': options!.toJson(),
    'model': model,
    if (verbose != null) 'verbose': verbose,
  };

  /// Creates a copy with replaced values.
  ShowRequest copyWith({
    Object? system = unsetCopyWithValue,
    Object? options = unsetCopyWithValue,
    String? model,
    Object? verbose = unsetCopyWithValue,
  }) {
    return ShowRequest(
      system: identical(system, unsetCopyWithValue)
          ? this.system
          : system as String?,
      options: identical(options, unsetCopyWithValue)
          ? this.options
          : options as ModelOptions?,
      model: model ?? this.model,
      verbose: verbose == unsetCopyWithValue ? this.verbose : verbose as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          verbose == other.verbose &&
          system == other.system &&
          options == other.options;

  @override
  int get hashCode => Object.hashAll([model, verbose, system, options]);

  @override
  String toString() =>
      'ShowRequest('
      'model: $model, '
      'verbose: $verbose, '
      'system: $system, '
      'options: $options)';
}
