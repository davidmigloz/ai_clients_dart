import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// One open browser tab reported in a `browser_state` block's `tabs`
/// inventory.
///
/// [tabId] is the caller-assigned identifier for the tab; [title] and [url]
/// describe the page the tab is currently showing and may be empty strings (a
/// blank tab legitimately has both empty). [active] marks the tab that is
/// active after the call; whenever the tab inventory is non-empty, exactly
/// one entry is marked.
@immutable
class BrowserStateTabEntry {
  /// The caller-assigned identifier for this tab, unique within the
  /// inventory.
  final String tabId;

  /// The title of the page the tab is showing. May be empty.
  final String title;

  /// The URL of the page the tab is showing. May be empty.
  final String url;

  /// Whether this tab is the active tab after this call.
  ///
  /// Whenever the tab inventory is non-empty, exactly one entry is marked
  /// `active: true`. Defaults to `false` when absent from the wire payload.
  final bool active;

  /// Creates a [BrowserStateTabEntry].
  const BrowserStateTabEntry({
    required this.tabId,
    required this.title,
    required this.url,
    this.active = false,
  });

  /// Creates a [BrowserStateTabEntry] from JSON.
  factory BrowserStateTabEntry.fromJson(Map<String, dynamic> json) {
    final tabId = json['tab_id'] as String?;
    if (tabId == null) {
      throw const FormatException(
        'BrowserStateTabEntry: missing required "tab_id"',
      );
    }
    final title = json['title'] as String?;
    if (title == null) {
      throw const FormatException(
        'BrowserStateTabEntry: missing required "title"',
      );
    }
    final url = json['url'] as String?;
    if (url == null) {
      throw const FormatException(
        'BrowserStateTabEntry: missing required "url"',
      );
    }
    return BrowserStateTabEntry(
      tabId: tabId,
      title: title,
      url: url,
      active: json['active'] as bool? ?? false,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'tab_id': tabId,
    'title': title,
    'url': url,
    'active': active,
  };

  /// Creates a copy with replaced values.
  BrowserStateTabEntry copyWith({
    String? tabId,
    String? title,
    String? url,
    bool? active,
  }) {
    return BrowserStateTabEntry(
      tabId: tabId ?? this.tabId,
      title: title ?? this.title,
      url: url ?? this.url,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserStateTabEntry &&
          runtimeType == other.runtimeType &&
          tabId == other.tabId &&
          title == other.title &&
          url == other.url &&
          active == other.active;

  @override
  int get hashCode => Object.hash(tabId, title, url, active);

  @override
  String toString() =>
      'BrowserStateTabEntry(tabId: $tabId, title: $title, url: $url, '
      'active: $active)';
}

/// A state change reported alongside a `browser_state` block — tabs opened
/// and download state changes produced by a browser toolset member call.
///
/// Dispatches on the `type` discriminator; unrecognized values fall back to
/// [UnknownBrowserStateChange].
///
/// Subtypes:
/// - [BrowserStateChangeTabOpened] (`tab_opened`)
/// - [BrowserStateChangeDownloadStarted] (`download_started`)
/// - [BrowserStateChangeDownloadCompleted] (`download_completed`)
/// - [BrowserStateChangeDownloadFailed] (`download_failed`)
/// - [UnknownBrowserStateChange] (forward-compatible fallback)
sealed class BrowserStateChange {
  const BrowserStateChange();

  /// Creates a [BrowserStateChange] from JSON.
  factory BrowserStateChange.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'tab_opened' => BrowserStateChangeTabOpened.fromJson(json),
      'download_started' => BrowserStateChangeDownloadStarted.fromJson(json),
      'download_completed' => BrowserStateChangeDownloadCompleted.fromJson(
        json,
      ),
      'download_failed' => BrowserStateChangeDownloadFailed.fromJson(json),
      _ => UnknownBrowserStateChange(raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A tab a browser toolset member call opened that remains open at its end —
/// the creation delta of the tab inventory, not an event log.
///
/// Carries only the [tabId]; the tab's title and URL live on its `tabs`
/// entry, which must include the same [tabId]. A tab opened during a failed
/// call gets no deferred `tab_opened`; it simply appears in the next result's
/// tab inventory.
@immutable
class BrowserStateChangeTabOpened extends BrowserStateChange {
  /// The `tab_id` of the opened tab, present in `tabs`.
  final String tabId;

  /// Creates a [BrowserStateChangeTabOpened].
  const BrowserStateChangeTabOpened({required this.tabId});

  /// Creates a [BrowserStateChangeTabOpened] from JSON.
  factory BrowserStateChangeTabOpened.fromJson(Map<String, dynamic> json) {
    final tabId = json['tab_id'] as String?;
    if (tabId == null) {
      throw const FormatException(
        'BrowserStateChangeTabOpened: missing required "tab_id"',
      );
    }
    return BrowserStateChangeTabOpened(tabId: tabId);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'tab_opened', 'tab_id': tabId};

  /// Creates a copy with replaced values.
  BrowserStateChangeTabOpened copyWith({String? tabId}) {
    return BrowserStateChangeTabOpened(tabId: tabId ?? this.tabId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserStateChangeTabOpened &&
          runtimeType == other.runtimeType &&
          tabId == other.tabId;

  @override
  int get hashCode => tabId.hashCode;

  @override
  String toString() => 'BrowserStateChangeTabOpened(tabId: $tabId)';
}

/// A file download that started during a browser toolset member call.
@immutable
class BrowserStateChangeDownloadStarted extends BrowserStateChange {
  /// The caller-assigned identifier for this download, stable across the
  /// state changes reporting it.
  final String downloadId;

  /// The final post-redirect URL the download was served from.
  final String url;

  /// Creates a [BrowserStateChangeDownloadStarted].
  const BrowserStateChangeDownloadStarted({
    required this.downloadId,
    required this.url,
  });

  /// Creates a [BrowserStateChangeDownloadStarted] from JSON.
  factory BrowserStateChangeDownloadStarted.fromJson(
    Map<String, dynamic> json,
  ) {
    final downloadId = json['download_id'] as String?;
    if (downloadId == null) {
      throw const FormatException(
        'BrowserStateChangeDownloadStarted: missing required "download_id"',
      );
    }
    final url = json['url'] as String?;
    if (url == null) {
      throw const FormatException(
        'BrowserStateChangeDownloadStarted: missing required "url"',
      );
    }
    return BrowserStateChangeDownloadStarted(downloadId: downloadId, url: url);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'download_started',
    'download_id': downloadId,
    'url': url,
  };

  /// Creates a copy with replaced values.
  BrowserStateChangeDownloadStarted copyWith({
    String? downloadId,
    String? url,
  }) {
    return BrowserStateChangeDownloadStarted(
      downloadId: downloadId ?? this.downloadId,
      url: url ?? this.url,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserStateChangeDownloadStarted &&
          runtimeType == other.runtimeType &&
          downloadId == other.downloadId &&
          url == other.url;

  @override
  int get hashCode => Object.hash(downloadId, url);

  @override
  String toString() =>
      'BrowserStateChangeDownloadStarted(downloadId: $downloadId, '
      'url: $url)';
}

/// A file download that finished during a browser toolset member call.
///
/// Reported with the same [downloadId] as its `download_started` — or
/// without a prior `download_started`, when the download finished during the
/// call that started it (at most one state change per [downloadId] per
/// result).
@immutable
class BrowserStateChangeDownloadCompleted extends BrowserStateChange {
  /// The caller-assigned identifier for this download, stable across the
  /// state changes reporting it.
  final String downloadId;

  /// The final post-redirect URL the download was served from.
  final String url;

  /// Where the executor saved the file, on the executor's filesystem.
  ///
  /// Only included when another tool in the same environment can read the
  /// file at that path.
  final String? path;

  /// The completed download's size, in bytes.
  final int? sizeBytes;

  /// Creates a [BrowserStateChangeDownloadCompleted].
  const BrowserStateChangeDownloadCompleted({
    required this.downloadId,
    required this.url,
    this.path,
    this.sizeBytes,
  });

  /// Creates a [BrowserStateChangeDownloadCompleted] from JSON.
  factory BrowserStateChangeDownloadCompleted.fromJson(
    Map<String, dynamic> json,
  ) {
    final downloadId = json['download_id'] as String?;
    if (downloadId == null) {
      throw const FormatException(
        'BrowserStateChangeDownloadCompleted: missing required "download_id"',
      );
    }
    final url = json['url'] as String?;
    if (url == null) {
      throw const FormatException(
        'BrowserStateChangeDownloadCompleted: missing required "url"',
      );
    }
    return BrowserStateChangeDownloadCompleted(
      downloadId: downloadId,
      url: url,
      path: json['path'] as String?,
      sizeBytes: json['size_bytes'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'download_completed',
    'download_id': downloadId,
    'url': url,
    if (path != null) 'path': path,
    if (sizeBytes != null) 'size_bytes': sizeBytes,
  };

  /// Creates a copy with replaced values.
  BrowserStateChangeDownloadCompleted copyWith({
    String? downloadId,
    String? url,
    Object? path = unsetCopyWithValue,
    Object? sizeBytes = unsetCopyWithValue,
  }) {
    return BrowserStateChangeDownloadCompleted(
      downloadId: downloadId ?? this.downloadId,
      url: url ?? this.url,
      path: path == unsetCopyWithValue ? this.path : path as String?,
      sizeBytes: sizeBytes == unsetCopyWithValue
          ? this.sizeBytes
          : sizeBytes as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserStateChangeDownloadCompleted &&
          runtimeType == other.runtimeType &&
          downloadId == other.downloadId &&
          url == other.url &&
          path == other.path &&
          sizeBytes == other.sizeBytes;

  @override
  int get hashCode => Object.hash(downloadId, url, path, sizeBytes);

  @override
  String toString() =>
      'BrowserStateChangeDownloadCompleted(downloadId: $downloadId, '
      'url: $url, path: $path, sizeBytes: $sizeBytes)';
}

/// A file download that failed — or was cancelled — during a browser toolset
/// member call.
@immutable
class BrowserStateChangeDownloadFailed extends BrowserStateChange {
  /// The caller-assigned identifier for this download, stable across the
  /// state changes reporting it.
  final String downloadId;

  /// The final post-redirect URL the download was served from.
  final String url;

  /// The failure or cancellation detail, when known.
  final String? error;

  /// Creates a [BrowserStateChangeDownloadFailed].
  const BrowserStateChangeDownloadFailed({
    required this.downloadId,
    required this.url,
    this.error,
  });

  /// Creates a [BrowserStateChangeDownloadFailed] from JSON.
  factory BrowserStateChangeDownloadFailed.fromJson(Map<String, dynamic> json) {
    final downloadId = json['download_id'] as String?;
    if (downloadId == null) {
      throw const FormatException(
        'BrowserStateChangeDownloadFailed: missing required "download_id"',
      );
    }
    final url = json['url'] as String?;
    if (url == null) {
      throw const FormatException(
        'BrowserStateChangeDownloadFailed: missing required "url"',
      );
    }
    return BrowserStateChangeDownloadFailed(
      downloadId: downloadId,
      url: url,
      error: json['error'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'download_failed',
    'download_id': downloadId,
    'url': url,
    if (error != null) 'error': error,
  };

  /// Creates a copy with replaced values.
  BrowserStateChangeDownloadFailed copyWith({
    String? downloadId,
    String? url,
    Object? error = unsetCopyWithValue,
  }) {
    return BrowserStateChangeDownloadFailed(
      downloadId: downloadId ?? this.downloadId,
      url: url ?? this.url,
      error: error == unsetCopyWithValue ? this.error : error as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserStateChangeDownloadFailed &&
          runtimeType == other.runtimeType &&
          downloadId == other.downloadId &&
          url == other.url &&
          error == other.error;

  @override
  int get hashCode => Object.hash(downloadId, url, error);

  @override
  String toString() =>
      'BrowserStateChangeDownloadFailed(downloadId: $downloadId, '
      'url: $url, error: $error)';
}

/// Forward-compatible fallback for unrecognized [BrowserStateChange] types.
@immutable
class UnknownBrowserStateChange extends BrowserStateChange {
  /// The raw JSON for this unknown state change.
  final Map<String, dynamic> raw;

  /// Creates an [UnknownBrowserStateChange].
  const UnknownBrowserStateChange({required this.raw});

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownBrowserStateChange &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);

  @override
  String toString() => 'UnknownBrowserStateChange(raw: ${raw.length} entries)';
}
