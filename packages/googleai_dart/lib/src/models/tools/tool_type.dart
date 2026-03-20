/// The type of tool.
enum ToolType {
  /// File search tool.
  fileSearch,

  /// Google Maps tool.
  googleMaps,

  /// Google Search image tool.
  googleSearchImage,

  /// Google Search web tool.
  googleSearchWeb,

  /// Unspecified tool type.
  unspecified,

  /// URL context tool.
  urlContext,
}

/// Converts a string to a [ToolType] enum value.
ToolType toolTypeFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'FILE_SEARCH' => ToolType.fileSearch,
    'GOOGLE_MAPS' => ToolType.googleMaps,
    'GOOGLE_SEARCH_IMAGE' => ToolType.googleSearchImage,
    'GOOGLE_SEARCH_WEB' => ToolType.googleSearchWeb,
    'URL_CONTEXT' => ToolType.urlContext,
    _ => ToolType.unspecified,
  };
}

/// Converts a [ToolType] enum value to a string.
String toolTypeToString(ToolType type) {
  return switch (type) {
    ToolType.fileSearch => 'FILE_SEARCH',
    ToolType.googleMaps => 'GOOGLE_MAPS',
    ToolType.googleSearchImage => 'GOOGLE_SEARCH_IMAGE',
    ToolType.googleSearchWeb => 'GOOGLE_SEARCH_WEB',
    ToolType.urlContext => 'URL_CONTEXT',
    ToolType.unspecified => 'TOOL_TYPE_UNSPECIFIED',
  };
}
