part of 'steps.dart';

/// Result of a URL context call.
class UrlContextResultStep extends InteractionStep {
  @override
  String get type => 'url_context_result';

  /// ID matching the corresponding [UrlContextCallStep.id].
  final String callId;

  /// The results of the URL context fetch.
  final List<UrlContextResultItem> result;

  /// Whether the URL context resulted in an error.
  final bool? isError;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [UrlContextResultStep] instance.
  const UrlContextResultStep({
    required this.callId,
    required this.result,
    this.isError,
    this.signature,
  });

  /// Creates a [UrlContextResultStep] from JSON.
  factory UrlContextResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'url_context_result') {
      throw FormatException(
        'Expected type "url_context_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'UrlContextResultStep: missing required "call_id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `result` is populated later via `step.delta`; default to empty when
    // absent.
    final resultJson = json['result'];
    final result = resultJson is List
        ? resultJson
              .map(
                (e) => UrlContextResultItem.fromJson(e as Map<String, dynamic>),
              )
              .toList()
        : <UrlContextResultItem>[];
    return UrlContextResultStep(
      callId: callId,
      result: result,
      isError: json['is_error'] as bool?,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.map((e) => e.toJson()).toList(),
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  UrlContextResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return UrlContextResultStep(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as List<UrlContextResultItem>,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// Status of a URL retrieval.
enum UrlContextResultStatus {
  /// The URL was retrieved successfully.
  success,

  /// An error occurred while retrieving the URL.
  error,

  /// The URL is paywalled.
  paywall,

  /// The URL is unsafe.
  unsafe,
}

/// Converts a JSON string to a [UrlContextResultStatus], or `null` if
/// unrecognized (forward-compatible).
UrlContextResultStatus? urlContextResultStatusFromString(String? value) {
  return switch (value) {
    'success' => UrlContextResultStatus.success,
    'error' => UrlContextResultStatus.error,
    'paywall' => UrlContextResultStatus.paywall,
    'unsafe' => UrlContextResultStatus.unsafe,
    _ => null,
  };
}

/// Converts a [UrlContextResultStatus] to its JSON string.
String urlContextResultStatusToString(UrlContextResultStatus value) {
  return switch (value) {
    UrlContextResultStatus.success => 'success',
    UrlContextResultStatus.error => 'error',
    UrlContextResultStatus.paywall => 'paywall',
    UrlContextResultStatus.unsafe => 'unsafe',
  };
}

/// A single result from a URL context fetch.
class UrlContextResultItem {
  /// The URL that was fetched.
  final String? url;

  /// The status of the URL retrieval.
  final UrlContextResultStatus? status;

  /// Creates a [UrlContextResultItem] instance.
  const UrlContextResultItem({this.url, this.status});

  /// Creates a [UrlContextResultItem] from JSON.
  factory UrlContextResultItem.fromJson(Map<String, dynamic> json) =>
      UrlContextResultItem(
        url: json['url'] as String?,
        status: urlContextResultStatusFromString(json['status'] as String?),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (url != null) 'url': url,
    if (status != null) 'status': urlContextResultStatusToString(status!),
  };

  /// Creates a copy with replaced values.
  UrlContextResultItem copyWith({
    Object? url = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) {
    return UrlContextResultItem(
      url: url == unsetCopyWithValue ? this.url : url as String?,
      status: status == unsetCopyWithValue
          ? this.status
          : status as UrlContextResultStatus?,
    );
  }
}
