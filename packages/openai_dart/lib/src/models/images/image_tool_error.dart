import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'image_json_helpers.dart';

@immutable
abstract class _ImageValue {
  const _ImageValue();
  Object toJson();
  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is _ImageValue &&
      mapsDeepEqual({'value': toJson()}, {'value': other.toJson()});
  @override
  int get hashCode =>
      Object.hash(runtimeType, mapDeepHashCode({'value': toJson()}));
  @override
  String toString() => '$runtimeType([REDACTED])';
}

/// Exact received image-call status, including future strings.
final class ImageGenerationCallStatus extends _ImageValue {
  const ImageGenerationCallStatus._(this.value);

  /// Call accepted and in progress.
  static const inProgress = ImageGenerationCallStatus._('in_progress');

  /// Image generation is ongoing.
  static const generating = ImageGenerationCallStatus._('generating');

  /// Image generation completed.
  static const completed = ImageGenerationCallStatus._('completed');

  /// Image generation failed; inspect the error when present.
  static const failed = ImageGenerationCallStatus._('failed');

  /// Exact wire value, never normalized to a different status.
  final String value;

  /// Whether this status is understood by the frozen API contract.
  bool get isKnown => const [
    'in_progress',
    'generating',
    'completed',
    'failed',
  ].contains(value);

  /// Reads a known or future status without coercing non-strings.
  factory ImageGenerationCallStatus.fromJson(Object? value) =>
      ImageGenerationCallStatus._(
        requireJsonString(value, 'ImageGenerationCallStatus'),
      );

  /// Copies the exact received value.
  ImageGenerationCallStatus copyWith({String? value}) =>
      ImageGenerationCallStatus.fromJson(value ?? this.value);
  @override
  String toJson() => value;
}

/// Moderation stage; exact future stage strings remain available.
final class ImageModerationStage extends _ImageValue {
  const ImageModerationStage._(this.value);

  /// Input moderation blocked generation.
  static const input = ImageModerationStage._('input');

  /// Output moderation blocked generation.
  static const output = ImageModerationStage._('output');

  /// The service could not identify the stage.
  static const unknown = ImageModerationStage._('unknown');

  /// Exact received wire value.
  final String value;

  /// Whether the received stage is known.
  bool get isKnown => const ['input', 'output', 'unknown'].contains(value);

  /// Reads known or future values without normalization.
  factory ImageModerationStage.fromJson(Object? value) =>
      ImageModerationStage._(requireJsonString(value, 'ImageModerationStage'));

  /// Copies the exact received stage.
  ImageModerationStage copyWith({String? value}) =>
      ImageModerationStage.fromJson(value ?? this.value);
  @override
  String toJson() => value;
}

/// Public moderation details shared by GA and beta image-generation calls.
final class ImageGenerationModerationDetails extends _ImageValue {
  /// Owns category strings and finite future metadata.
  ImageGenerationModerationDetails({
    required this.moderationStage,
    required List<String> categories,
    Map<String, dynamic> rawJson = const {},
  }) : categories = List<String>.unmodifiable(categories),
       rawJson = _extras(rawJson, const [
         'moderation_stage',
         'categories',
       ], 'ImageGenerationModerationDetails');

  /// Stage at which moderation blocked the call.
  final ImageModerationStage moderationStage;

  /// Exact public categories; new categories may be added by the service.
  final List<String> categories;

  /// Immutable received extras, separate from known fields.
  final Map<String, dynamic> rawJson;

  /// Parses both required fields without inventing category defaults.
  factory ImageGenerationModerationDetails.fromJson(Map<String, dynamic> json) {
    final values = json['categories'];
    if (values is! List) {
      throw const FormatException(
        'ImageGenerationModerationDetails.categories: expected an array',
      );
    }
    return ImageGenerationModerationDetails(
      moderationStage: ImageModerationStage.fromJson(json['moderation_stage']),
      categories: [
        for (final value in values)
          requireJsonString(
            value,
            'ImageGenerationModerationDetails.categories',
          ),
      ],
      rawJson: {
        for (final e in json.entries)
          if (e.key != 'moderation_stage' && e.key != 'categories')
            e.key: e.value,
      },
    );
  }

  /// Copies the owned details.
  ImageGenerationModerationDetails copyWith({
    ImageModerationStage? moderationStage,
    List<String>? categories,
    Map<String, dynamic>? rawJson,
  }) => ImageGenerationModerationDetails(
    moderationStage: moderationStage ?? this.moderationStage,
    categories: categories ?? this.categories,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'moderation_stage': moderationStage.toJson(),
    'categories': categories,
  };
}

/// Image-tool failure details shared by the GA and beta Responses protocols.
final class ImageGenerationCallError extends _ImageValue {
  /// Requires the nullable code/param fields; no error default is synthesized.
  ImageGenerationCallError({
    required this.code,
    required this.type,
    required this.message,
    required this.param,
    this.moderationDetails,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _extras(rawJson, const [
         'code',
         'type',
         'message',
         'param',
         'moderation_details',
       ], 'ImageGenerationCallError');

  /// Machine-readable code, or null when the service supplies none.
  final String? code;

  /// Exact service error type.
  final String type;

  /// Public error explanation; omitted from automatic diagnostic strings.
  final String message;

  /// Related request parameter, or null when the service supplies none.
  final String? param;

  /// Optional nonnull public moderation details, when available.
  final ImageGenerationModerationDetails? moderationDetails;

  /// Immutable finite received extras.
  final Map<String, dynamic> rawJson;

  /// Parses required nullable presence and optional nonnullable details.
  factory ImageGenerationCallError.fromJson(Map<String, dynamic> json) {
    for (final key in const ['code', 'param']) {
      if (!json.containsKey(key)) {
        throw FormatException(
          'ImageGenerationCallError.$key: missing required field',
        );
      }
    }
    return ImageGenerationCallError(
      code: optionalJsonString(
        json,
        'code',
        'ImageGenerationCallError',
        nullable: true,
      ),
      type: requireJsonString(json['type'], 'ImageGenerationCallError.type'),
      message: requireJsonString(
        json['message'],
        'ImageGenerationCallError.message',
      ),
      param: optionalJsonString(
        json,
        'param',
        'ImageGenerationCallError',
        nullable: true,
      ),
      moderationDetails: json.containsKey('moderation_details')
          ? ImageGenerationModerationDetails.fromJson(
              requireJsonObject(
                json['moderation_details'],
                'ImageGenerationCallError.moderationDetails',
              ),
            )
          : null,
      rawJson: {
        for (final e in json.entries)
          if (!const [
            'code',
            'type',
            'message',
            'param',
            'moderation_details',
          ].contains(e.key))
            e.key: e.value,
      },
    );
  }

  /// Copies all fields; explicit null clears nullable fields.
  ImageGenerationCallError copyWith({
    Object? code = unsetCopyWithValue,
    String? type,
    String? message,
    Object? param = unsetCopyWithValue,
    Object? moderationDetails = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ImageGenerationCallError(
    code: copyImageValue<String>(
      code,
      this.code,
      'ImageGenerationCallError.code',
    ),
    type: type ?? this.type,
    message: message ?? this.message,
    param: copyImageValue<String>(
      param,
      this.param,
      'ImageGenerationCallError.param',
    ),
    moderationDetails: copyImageValue<ImageGenerationModerationDetails>(
      moderationDetails,
      this.moderationDetails,
      'ImageGenerationCallError.moderationDetails',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'code': code,
    'type': type,
    'message': message,
    'param': param,
    if (moderationDetails != null)
      'moderation_details': moderationDetails!.toJson(),
  };
}

Map<String, dynamic> _extras(
  Map<String, dynamic> value,
  List<String> known,
  String context,
) {
  if (value.keys.any(known.contains)) {
    throw FormatException('$context: extras cannot contain known fields');
  }
  return freezeFiniteJsonObject(value, context);
}
