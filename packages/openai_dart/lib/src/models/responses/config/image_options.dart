import 'package:meta/meta.dart';

import '../../common/json_helpers.dart';

/// Selects the image context optimization policy for a Responses request.
enum ImageContextCompression {
  /// Let the service choose based on the model, transport, and input.
  auto,

  /// Require image context compression.
  enabled,

  /// Turn image context compression off.
  disabled;

  /// Parses a request policy.
  factory ImageContextCompression.fromJson(String json) => values.firstWhere(
    (value) => value.name == json,
    orElse: () => throw const FormatException('Unknown image context policy'),
  );

  /// Converts to the API value.
  String toJson() => name;
}

/// The effective image context optimization policy used by the service.
enum ResolvedImageContextCompression {
  /// Image context compression was enabled.
  enabled,

  /// Image context compression was disabled.
  disabled;

  /// Parses the effective policy.
  factory ResolvedImageContextCompression.fromJson(String json) =>
      values.firstWhere(
        (value) => value.name == json,
        orElse: () => throw const FormatException(
          'Unknown resolved image context policy',
        ),
      );

  /// Converts to the API value.
  String toJson() => name;
}

/// Request-level image context settings for Responses create and compact.
@immutable
class ImageOptions {
  /// Creates image context options. Omitting the policy uses automatic mode.
  const ImageOptions({this.contextCompression});

  /// Controls how input images are represented in model context.
  final ImageContextCompression? contextCompression;

  /// Parses image settings.
  factory ImageOptions.fromJson(Map<String, dynamic> json) {
    if (json.keys.any((key) => key != 'context_compression')) {
      throw const FormatException('ImageOptions: unexpected field');
    }
    final policy = optionalJsonString(
      json,
      'context_compression',
      'ImageOptions',
      nullable: false,
    );
    return ImageOptions(
      contextCompression: policy == null
          ? null
          : ImageContextCompression.fromJson(policy),
    );
  }

  /// Converts to JSON without inserting a default.
  Map<String, dynamic> toJson() => {
    if (contextCompression != null)
      'context_compression': contextCompression!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is ImageOptions &&
      runtimeType == other.runtimeType &&
      contextCompression == other.contextCompression;

  @override
  int get hashCode => contextCompression.hashCode;
}

/// Image options resolved by the service for a Response or compaction.
@immutable
class ResolvedImageOptions {
  /// Creates resolved image context options.
  const ResolvedImageOptions({required this.contextCompression});

  /// The effective compression policy.
  final ResolvedImageContextCompression contextCompression;

  /// Parses resolved image context options.
  factory ResolvedImageOptions.fromJson(Map<String, dynamic> json) =>
      ResolvedImageOptions(
        contextCompression: ResolvedImageContextCompression.fromJson(
          requireJsonString(
            json['context_compression'],
            'ResolvedImageOptions.context_compression',
          ),
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'context_compression': contextCompression.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is ResolvedImageOptions &&
      runtimeType == other.runtimeType &&
      contextCompression == other.contextCompression;

  @override
  int get hashCode => contextCompression.hashCode;
}
