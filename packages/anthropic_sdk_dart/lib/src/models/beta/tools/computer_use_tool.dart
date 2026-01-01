import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../metadata/cache_control.dart';

/// Computer use tool for GUI automation.
///
/// Allows Claude to interact with a computer display.
@immutable
class ComputerUseTool {
  /// The tool type version.
  final String type;

  /// Display width in pixels.
  final int displayWidthPx;

  /// Display height in pixels.
  final int displayHeightPx;

  /// Display number (for multi-monitor setups).
  final int? displayNumber;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [ComputerUseTool].
  const ComputerUseTool({
    this.type = 'computer_20251124',
    required this.displayWidthPx,
    required this.displayHeightPx,
    this.displayNumber,
    this.cacheControl,
  });

  /// Creates a [ComputerUseTool] with version 2024-10-22.
  factory ComputerUseTool.v20241022({
    required int displayWidthPx,
    required int displayHeightPx,
    int? displayNumber,
    CacheControlEphemeral? cacheControl,
  }) {
    return ComputerUseTool(
      type: 'computer_20241022',
      displayWidthPx: displayWidthPx,
      displayHeightPx: displayHeightPx,
      displayNumber: displayNumber,
      cacheControl: cacheControl,
    );
  }

  /// Creates a [ComputerUseTool] with version 2025-01-24.
  factory ComputerUseTool.v20250124({
    required int displayWidthPx,
    required int displayHeightPx,
    int? displayNumber,
    CacheControlEphemeral? cacheControl,
  }) {
    return ComputerUseTool(
      type: 'computer_20250124',
      displayWidthPx: displayWidthPx,
      displayHeightPx: displayHeightPx,
      displayNumber: displayNumber,
      cacheControl: cacheControl,
    );
  }

  /// Creates a [ComputerUseTool] from JSON.
  factory ComputerUseTool.fromJson(Map<String, dynamic> json) {
    return ComputerUseTool(
      type: json['type'] as String,
      displayWidthPx: json['display_width_px'] as int,
      displayHeightPx: json['display_height_px'] as int,
      displayNumber: json['display_number'] as int?,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'computer',
    'display_width_px': displayWidthPx,
    'display_height_px': displayHeightPx,
    if (displayNumber != null) 'display_number': displayNumber,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  ComputerUseTool copyWith({
    String? type,
    int? displayWidthPx,
    int? displayHeightPx,
    Object? displayNumber = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return ComputerUseTool(
      type: type ?? this.type,
      displayWidthPx: displayWidthPx ?? this.displayWidthPx,
      displayHeightPx: displayHeightPx ?? this.displayHeightPx,
      displayNumber: displayNumber == unsetCopyWithValue
          ? this.displayNumber
          : displayNumber as int?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerUseTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          displayWidthPx == other.displayWidthPx &&
          displayHeightPx == other.displayHeightPx &&
          displayNumber == other.displayNumber &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(
    type,
    displayWidthPx,
    displayHeightPx,
    displayNumber,
    cacheControl,
  );

  @override
  String toString() =>
      'ComputerUseTool(type: $type, displayWidthPx: $displayWidthPx, '
      'displayHeightPx: $displayHeightPx, displayNumber: $displayNumber, '
      'cacheControl: $cacheControl)';
}
