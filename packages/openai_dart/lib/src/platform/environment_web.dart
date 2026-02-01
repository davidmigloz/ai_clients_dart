/// Web implementation that throws [UnsupportedError].
///
/// Web browsers do not have access to environment variables.
/// Use explicit configuration instead of `fromEnvironment()` factories on web.
String? getEnvironmentVariable(String key) {
  throw UnsupportedError(
    'Environment variables are not available in web browsers. '
    'Use explicit configuration instead of fromEnvironment() factories. '
    'For example: OpenAIClient(config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey)))',
  );
}
