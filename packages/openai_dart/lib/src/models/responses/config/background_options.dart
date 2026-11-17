import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

/// A completion window for a background response.
enum BackgroundCompletionWindow {
  /// Use ordinary background processing.
  soonest('soonest'),

  /// Use the discounted two-hour window.
  twoHours('2h'),

  /// Use the discounted eight-hour window.
  eightHours('8h');

  const BackgroundCompletionWindow(this.value);

  /// The API value.
  final String value;

  /// Parses an API value.
  factory BackgroundCompletionWindow.fromJson(String value) => switch (value) {
    'soonest' => soonest,
    '2h' => twoHours,
    '8h' => eightHours,
    _ => throw const FormatException('Invalid background completion window'),
  };

  /// Returns the API value.
  String toJson() => value;
}

/// Scheduling options for HTTP Responses creation.
///
/// Discounted windows require a nonstreaming background request and Standard
/// processing. Choose `ServiceTier.defaultTier` to request Standard explicitly.
@immutable
class BackgroundOptions {
  /// The completion window. Omit it to use [BackgroundCompletionWindow.soonest].
  final BackgroundCompletionWindow? completionWindow;

  /// An opaque application identifier used to prioritize related requests.
  ///
  /// Conversation history is controlled by `previousResponseId`.
  final String? continuationId;

  /// Creates HTTP background scheduling options.
  const BackgroundOptions({this.completionWindow, this.continuationId});

  /// Parses the request options. Optional fields are non-null when supplied.
  factory BackgroundOptions.fromJson(Map<String, dynamic> json) {
    final window = json['completion_window'];
    final continuationId = json['continuation_id'];
    if (json.containsKey('completion_window') && window is! String) {
      throw const FormatException(
        'background_options.completion_window must be a string',
      );
    }
    if (json.containsKey('continuation_id') && continuationId is! String) {
      throw const FormatException(
        'background_options.continuation_id must be a string',
      );
    }
    return BackgroundOptions(
      completionWindow: window is String
          ? BackgroundCompletionWindow.fromJson(window)
          : null,
      continuationId: continuationId as String?,
    );
  }

  /// Serializes the options, omitting unset fields.
  Map<String, dynamic> toJson() => {
    if (completionWindow != null)
      'completion_window': completionWindow!.toJson(),
    if (continuationId != null) 'continuation_id': continuationId,
  };

  /// Copies the options. Pass null to clear a field.
  BackgroundOptions copyWith({
    Object? completionWindow = unsetCopyWithValue,
    Object? continuationId = unsetCopyWithValue,
  }) => BackgroundOptions(
    completionWindow: identical(completionWindow, unsetCopyWithValue)
        ? this.completionWindow
        : completionWindow as BackgroundCompletionWindow?,
    continuationId: identical(continuationId, unsetCopyWithValue)
        ? this.continuationId
        : continuationId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackgroundOptions &&
          runtimeType == other.runtimeType &&
          completionWindow == other.completionWindow &&
          continuationId == other.continuationId;

  @override
  int get hashCode => Object.hash(completionWindow, continuationId);

  @override
  String toString() =>
      'BackgroundOptions(completionWindow: $completionWindow, '
      'continuationId: ${continuationId == null ? 'null' : 'present'})';
}
