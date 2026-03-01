import 'dart:io' show Platform;

/// IO implementation that reads environment variables from [Platform.environment].
String? getEnvironmentVariable(String key) => Platform.environment[key];
