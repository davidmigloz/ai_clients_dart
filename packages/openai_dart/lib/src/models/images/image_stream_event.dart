import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'image_common.dart';
import 'image_response.dart';

/// A Server-Sent Event from a streaming image generation request.
///
/// GPT image models (e.g. `gpt-image-2`) emit one or more
/// [ImageGenPartialImageEvent]s followed by a terminal
/// [ImageGenCompletedEvent] when `stream: true` is set on
/// [ImagesResource.generateStream].
///
/// Unknown event types are surfaced as [ImageGenUnknownEvent] with the raw
/// JSON preserved. Typed fields ([ImageSize], [ImageQuality],
/// [ImageBackground], [ImageOutputFormat]) fall back to their `.unknown`
/// variant when the server emits a value outside the current spec — for
/// example, partial-image events sometimes carry transient sizes like
/// `1254x1254`.
@immutable
sealed class ImageGenStreamEvent {
  const ImageGenStreamEvent();

  /// Creates a [ImageGenStreamEvent] from JSON, dispatching on `type`.
  factory ImageGenStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'image_generation.partial_image' => ImageGenPartialImageEvent.fromJson(
        json,
      ),
      'image_generation.completed' => ImageGenCompletedEvent.fromJson(json),
      _ => ImageGenUnknownEvent.fromJson(json),
    };
  }

  /// The discriminator value.
  String get type;

  /// Serializes the event.
  Map<String, dynamic> toJson();
}

/// Partial image chunk emitted during streaming generation.
@immutable
class ImageGenPartialImageEvent extends ImageGenStreamEvent {
  /// Creates an [ImageGenPartialImageEvent].
  const ImageGenPartialImageEvent({
    required this.b64Json,
    required this.createdAt,
    required this.size,
    required this.quality,
    required this.background,
    required this.outputFormat,
    required this.partialImageIndex,
  });

  /// Creates an [ImageGenPartialImageEvent] from JSON.
  factory ImageGenPartialImageEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'image_generation.partial_image') {
      throw FormatException(
        'Expected type "image_generation.partial_image", got "${json['type']}"',
      );
    }
    return ImageGenPartialImageEvent(
      b64Json: json['b64_json'] as String,
      createdAt: json['created_at'] as int,
      size: ImageSize.fromJson(json['size'] as String),
      quality: ImageQuality.fromJson(json['quality'] as String),
      background: ImageBackground.fromJson(json['background'] as String),
      outputFormat: ImageOutputFormat.fromJson(json['output_format'] as String),
      partialImageIndex: json['partial_image_index'] as int,
    );
  }

  /// Base64-encoded partial image data.
  final String b64Json;

  /// Unix timestamp when the event was created.
  final int createdAt;

  /// Image size. May be [ImageSize.unknown] for out-of-spec values.
  final ImageSize size;

  /// Image quality. May be [ImageQuality.unknown] for out-of-spec values.
  final ImageQuality quality;

  /// Background. May be [ImageBackground.unknown] for out-of-spec values.
  final ImageBackground background;

  /// Output format. May be [ImageOutputFormat.unknown] for out-of-spec values.
  final ImageOutputFormat outputFormat;

  /// 0-based index of this partial image.
  final int partialImageIndex;

  @override
  String get type => 'image_generation.partial_image';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'b64_json': b64Json,
    'created_at': createdAt,
    'size': size.toJson(),
    'quality': quality.toJson(),
    'background': background.toJson(),
    'output_format': outputFormat.toJson(),
    'partial_image_index': partialImageIndex,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenPartialImageEvent &&
          runtimeType == other.runtimeType &&
          b64Json == other.b64Json &&
          createdAt == other.createdAt &&
          size == other.size &&
          quality == other.quality &&
          background == other.background &&
          outputFormat == other.outputFormat &&
          partialImageIndex == other.partialImageIndex;

  @override
  int get hashCode => Object.hash(
    b64Json,
    createdAt,
    size,
    quality,
    background,
    outputFormat,
    partialImageIndex,
  );

  @override
  String toString() =>
      'ImageGenPartialImageEvent(index: $partialImageIndex, '
      'b64: ${b64Json.length} chars, size: $size)';
}

/// Terminal event for streaming image generation.
@immutable
class ImageGenCompletedEvent extends ImageGenStreamEvent {
  /// Creates an [ImageGenCompletedEvent].
  const ImageGenCompletedEvent({
    required this.b64Json,
    required this.createdAt,
    required this.size,
    required this.quality,
    required this.background,
    required this.outputFormat,
    required this.usage,
  });

  /// Creates an [ImageGenCompletedEvent] from JSON.
  factory ImageGenCompletedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'image_generation.completed') {
      throw FormatException(
        'Expected type "image_generation.completed", got "${json['type']}"',
      );
    }
    return ImageGenCompletedEvent(
      b64Json: json['b64_json'] as String,
      createdAt: json['created_at'] as int,
      size: ImageSize.fromJson(json['size'] as String),
      quality: ImageQuality.fromJson(json['quality'] as String),
      background: ImageBackground.fromJson(json['background'] as String),
      outputFormat: ImageOutputFormat.fromJson(json['output_format'] as String),
      usage: ImagesUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  /// Base64-encoded final image data.
  final String b64Json;

  /// Unix timestamp when the event was created.
  final int createdAt;

  /// Final image size. May be [ImageSize.unknown] for out-of-spec values.
  final ImageSize size;

  /// Final image quality.
  final ImageQuality quality;

  /// Final background.
  final ImageBackground background;

  /// Final output format.
  final ImageOutputFormat outputFormat;

  /// Token-based usage for the full generation.
  final ImagesUsage usage;

  @override
  String get type => 'image_generation.completed';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'b64_json': b64Json,
    'created_at': createdAt,
    'size': size.toJson(),
    'quality': quality.toJson(),
    'background': background.toJson(),
    'output_format': outputFormat.toJson(),
    'usage': usage.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenCompletedEvent &&
          runtimeType == other.runtimeType &&
          b64Json == other.b64Json &&
          createdAt == other.createdAt &&
          size == other.size &&
          quality == other.quality &&
          background == other.background &&
          outputFormat == other.outputFormat &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(
    b64Json,
    createdAt,
    size,
    quality,
    background,
    outputFormat,
    usage,
  );

  @override
  String toString() =>
      'ImageGenCompletedEvent(b64: ${b64Json.length} chars, '
      'size: $size, usage: $usage)';
}

/// Forward-compatibility fallback for unrecognized image-generation stream
/// events. Preserves the raw JSON so `copyWith`-like updates and
/// round-trip re-serialization do not drop forward-compatible fields.
@immutable
class ImageGenUnknownEvent extends ImageGenStreamEvent {
  /// Creates an [ImageGenUnknownEvent].
  const ImageGenUnknownEvent({required this.rawType, required this.rawJson});

  /// Creates an [ImageGenUnknownEvent] from JSON.
  factory ImageGenUnknownEvent.fromJson(Map<String, dynamic> json) {
    return ImageGenUnknownEvent(
      rawType: json['type'] as String? ?? '',
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  /// The unknown `type` value from the server.
  final String rawType;

  /// The original JSON payload (preserved verbatim).
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawType;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenUnknownEvent &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'ImageGenUnknownEvent(type: $rawType)';
}

/// A Server-Sent Event from a streaming image edit request.
///
/// See [ImageGenStreamEvent] for the forward-compatibility contract on the
/// typed fields.
@immutable
sealed class ImageEditStreamEvent {
  const ImageEditStreamEvent();

  /// Creates an [ImageEditStreamEvent] from JSON, dispatching on `type`.
  factory ImageEditStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'image_edit.partial_image' => ImageEditPartialImageEvent.fromJson(json),
      'image_edit.completed' => ImageEditCompletedEvent.fromJson(json),
      _ => ImageEditUnknownEvent.fromJson(json),
    };
  }

  /// The discriminator value.
  String get type;

  /// Serializes the event.
  Map<String, dynamic> toJson();
}

/// Partial image chunk emitted during streaming edit.
@immutable
class ImageEditPartialImageEvent extends ImageEditStreamEvent {
  /// Creates an [ImageEditPartialImageEvent].
  const ImageEditPartialImageEvent({
    required this.b64Json,
    required this.createdAt,
    required this.size,
    required this.quality,
    required this.background,
    required this.outputFormat,
    required this.partialImageIndex,
  });

  /// Creates an [ImageEditPartialImageEvent] from JSON.
  factory ImageEditPartialImageEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'image_edit.partial_image') {
      throw FormatException(
        'Expected type "image_edit.partial_image", got "${json['type']}"',
      );
    }
    return ImageEditPartialImageEvent(
      b64Json: json['b64_json'] as String,
      createdAt: json['created_at'] as int,
      size: ImageSize.fromJson(json['size'] as String),
      quality: ImageQuality.fromJson(json['quality'] as String),
      background: ImageBackground.fromJson(json['background'] as String),
      outputFormat: ImageOutputFormat.fromJson(json['output_format'] as String),
      partialImageIndex: json['partial_image_index'] as int,
    );
  }

  /// Base64-encoded partial image data.
  final String b64Json;

  /// Unix timestamp when the event was created.
  final int createdAt;

  /// Image size. May be [ImageSize.unknown] for out-of-spec values.
  final ImageSize size;

  /// Image quality.
  final ImageQuality quality;

  /// Background.
  final ImageBackground background;

  /// Output format.
  final ImageOutputFormat outputFormat;

  /// 0-based index of this partial image.
  final int partialImageIndex;

  @override
  String get type => 'image_edit.partial_image';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'b64_json': b64Json,
    'created_at': createdAt,
    'size': size.toJson(),
    'quality': quality.toJson(),
    'background': background.toJson(),
    'output_format': outputFormat.toJson(),
    'partial_image_index': partialImageIndex,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageEditPartialImageEvent &&
          runtimeType == other.runtimeType &&
          b64Json == other.b64Json &&
          createdAt == other.createdAt &&
          size == other.size &&
          quality == other.quality &&
          background == other.background &&
          outputFormat == other.outputFormat &&
          partialImageIndex == other.partialImageIndex;

  @override
  int get hashCode => Object.hash(
    b64Json,
    createdAt,
    size,
    quality,
    background,
    outputFormat,
    partialImageIndex,
  );

  @override
  String toString() =>
      'ImageEditPartialImageEvent(index: $partialImageIndex, '
      'b64: ${b64Json.length} chars, size: $size)';
}

/// Terminal event for streaming image edit.
@immutable
class ImageEditCompletedEvent extends ImageEditStreamEvent {
  /// Creates an [ImageEditCompletedEvent].
  const ImageEditCompletedEvent({
    required this.b64Json,
    required this.createdAt,
    required this.size,
    required this.quality,
    required this.background,
    required this.outputFormat,
    required this.usage,
  });

  /// Creates an [ImageEditCompletedEvent] from JSON.
  factory ImageEditCompletedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'image_edit.completed') {
      throw FormatException(
        'Expected type "image_edit.completed", got "${json['type']}"',
      );
    }
    return ImageEditCompletedEvent(
      b64Json: json['b64_json'] as String,
      createdAt: json['created_at'] as int,
      size: ImageSize.fromJson(json['size'] as String),
      quality: ImageQuality.fromJson(json['quality'] as String),
      background: ImageBackground.fromJson(json['background'] as String),
      outputFormat: ImageOutputFormat.fromJson(json['output_format'] as String),
      usage: ImagesUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  /// Base64-encoded final image data.
  final String b64Json;

  /// Unix timestamp when the event was created.
  final int createdAt;

  /// Final image size.
  final ImageSize size;

  /// Final image quality.
  final ImageQuality quality;

  /// Final background.
  final ImageBackground background;

  /// Final output format.
  final ImageOutputFormat outputFormat;

  /// Token-based usage for the full edit.
  final ImagesUsage usage;

  @override
  String get type => 'image_edit.completed';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'b64_json': b64Json,
    'created_at': createdAt,
    'size': size.toJson(),
    'quality': quality.toJson(),
    'background': background.toJson(),
    'output_format': outputFormat.toJson(),
    'usage': usage.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageEditCompletedEvent &&
          runtimeType == other.runtimeType &&
          b64Json == other.b64Json &&
          createdAt == other.createdAt &&
          size == other.size &&
          quality == other.quality &&
          background == other.background &&
          outputFormat == other.outputFormat &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(
    b64Json,
    createdAt,
    size,
    quality,
    background,
    outputFormat,
    usage,
  );

  @override
  String toString() =>
      'ImageEditCompletedEvent(b64: ${b64Json.length} chars, '
      'size: $size, usage: $usage)';
}

/// Forward-compatibility fallback for unrecognized image-edit stream events.
@immutable
class ImageEditUnknownEvent extends ImageEditStreamEvent {
  /// Creates an [ImageEditUnknownEvent].
  const ImageEditUnknownEvent({required this.rawType, required this.rawJson});

  /// Creates an [ImageEditUnknownEvent] from JSON.
  factory ImageEditUnknownEvent.fromJson(Map<String, dynamic> json) {
    return ImageEditUnknownEvent(
      rawType: json['type'] as String? ?? '',
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  /// The unknown `type` value from the server.
  final String rawType;

  /// The original JSON payload (preserved verbatim).
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawType;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageEditUnknownEvent &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'ImageEditUnknownEvent(type: $rawType)';
}
