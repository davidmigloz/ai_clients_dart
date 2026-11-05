import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/model_options.dart';

/// Request to show model details.
@immutable
class ShowRequest {
  /// Whether to inspect every variant. Use `models.showManifests` to parse that response.
  final bool? allManifests;

  /// Runner variant to inspect from a model manifest list.
  final String? runner;

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
    this.allManifests,
    this.runner,
    required this.model,
    this.verbose,
    this.system,
    this.options,
  });

  /// Creates a [ShowRequest] from JSON.
  factory ShowRequest.fromJson(Map<String, dynamic> json) => ShowRequest(
    allManifests: json['all_manifests'] as bool?,
    runner: json['runner'] as String?,
    system: json['system'] as String?,
    options: json['options'] != null
        ? ModelOptions.fromJson(json['options'] as Map<String, dynamic>)
        : null,
    model: json['model'] as String,
    verbose: json['verbose'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (allManifests != null) 'all_manifests': allManifests,
    if (runner != null) 'runner': runner,
    if (system != null) 'system': system,
    if (options != null) 'options': options!.toJson(),
    'model': model,
    if (verbose != null) 'verbose': verbose,
  };

  /// Creates a copy with replaced values.
  ShowRequest copyWith({
    Object? allManifests = unsetCopyWithValue,
    Object? runner = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? options = unsetCopyWithValue,
    String? model,
    Object? verbose = unsetCopyWithValue,
  }) {
    return ShowRequest(
      allManifests: identical(allManifests, unsetCopyWithValue)
          ? this.allManifests
          : allManifests as bool?,
      runner: identical(runner, unsetCopyWithValue)
          ? this.runner
          : runner as String?,
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
          allManifests == other.allManifests &&
          runner == other.runner &&
          model == other.model &&
          verbose == other.verbose &&
          system == other.system &&
          options == other.options;

  @override
  int get hashCode =>
      Object.hashAll([allManifests, runner, model, verbose, system, options]);

  @override
  String toString() =>
      'ShowRequest('
      'allManifests: $allManifests, '
      'runner: $runner, '
      'model: $model, '
      'verbose: $verbose, '
      'system: $system, '
      'options: $options)';
}
