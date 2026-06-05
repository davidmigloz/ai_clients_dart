part of '../../tools/built_in_tools.dart';

/// Computer use tool for GUI automation (Beta).
///
/// Allows Claude to interact with a computer display.
/// This is a beta feature.
@immutable
class ComputerUseTool extends BuiltInTool {
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

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Optional input examples.
  final List<Map<String, dynamic>>? inputExamples;

  /// Whether to enable a zoomed-in screenshot action.
  ///
  /// Only supported by the `computer_20251124` tool version; ignored during
  /// serialization for older versions.
  final bool? enableZoom;

  /// Creates a [ComputerUseTool].
  const ComputerUseTool({
    this.type = 'computer_20251124',
    required this.displayWidthPx,
    required this.displayHeightPx,
    this.displayNumber,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    this.inputExamples,
    this.enableZoom,
  });

  /// Creates a [ComputerUseTool] with version 2024-10-22.
  factory ComputerUseTool.v20241022({
    required int displayWidthPx,
    required int displayHeightPx,
    int? displayNumber,
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
    List<Map<String, dynamic>>? inputExamples,
  }) {
    return ComputerUseTool(
      type: 'computer_20241022',
      displayWidthPx: displayWidthPx,
      displayHeightPx: displayHeightPx,
      displayNumber: displayNumber,
      cacheControl: cacheControl,
      allowedCallers: allowedCallers,
      deferLoading: deferLoading,
      strict: strict,
      inputExamples: inputExamples,
    );
  }

  /// Creates a [ComputerUseTool] with version 2025-01-24.
  factory ComputerUseTool.v20250124({
    required int displayWidthPx,
    required int displayHeightPx,
    int? displayNumber,
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
    List<Map<String, dynamic>>? inputExamples,
  }) {
    return ComputerUseTool(
      type: 'computer_20250124',
      displayWidthPx: displayWidthPx,
      displayHeightPx: displayHeightPx,
      displayNumber: displayNumber,
      cacheControl: cacheControl,
      allowedCallers: allowedCallers,
      deferLoading: deferLoading,
      strict: strict,
      inputExamples: inputExamples,
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
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
      inputExamples: (json['input_examples'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      enableZoom: json['enable_zoom'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'computer',
    'display_width_px': displayWidthPx,
    'display_height_px': displayHeightPx,
    if (displayNumber != null) 'display_number': displayNumber,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (inputExamples != null) 'input_examples': inputExamples,
    // enable_zoom is only valid for the 2025-11-24 tool version.
    if (enableZoom != null && type == 'computer_20251124')
      'enable_zoom': enableZoom,
  };

  /// Creates a copy with replaced values.
  ComputerUseTool copyWith({
    String? type,
    int? displayWidthPx,
    int? displayHeightPx,
    Object? displayNumber = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? inputExamples = unsetCopyWithValue,
    Object? enableZoom = unsetCopyWithValue,
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
      allowedCallers: allowedCallers == unsetCopyWithValue
          ? this.allowedCallers
          : allowedCallers as List<String>?,
      deferLoading: deferLoading == unsetCopyWithValue
          ? this.deferLoading
          : deferLoading as bool?,
      strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
      inputExamples: inputExamples == unsetCopyWithValue
          ? this.inputExamples
          : inputExamples as List<Map<String, dynamic>>?,
      enableZoom: enableZoom == unsetCopyWithValue
          ? this.enableZoom
          : enableZoom as bool?,
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
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          listOfMapsEqual(inputExamples, other.inputExamples) &&
          enableZoom == other.enableZoom;

  @override
  int get hashCode => Object.hash(
    type,
    displayWidthPx,
    displayHeightPx,
    displayNumber,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
    listOfMapsHash(inputExamples),
    enableZoom,
  );

  @override
  String toString() =>
      'ComputerUseTool(type: $type, displayWidthPx: $displayWidthPx, '
      'displayHeightPx: $displayHeightPx, displayNumber: $displayNumber, '
      'cacheControl: $cacheControl, allowedCallers: $allowedCallers, '
      'deferLoading: $deferLoading, strict: $strict, '
      'inputExamples: $inputExamples, enableZoom: $enableZoom)';
}
