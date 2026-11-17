/// Named OpenAI API endpoints supported by the pinned official SDKs.
///
/// Regional endpoint routing does not configure a project's residency settings
/// or guarantee regional processing for every model, tool or service. Consult
/// the official data controls guide for current eligibility and requirements.
/// Google Vertex locations are configured independently with `VertexProvider`.
enum OpenAIDataResidency {
  /// Default global endpoint, without a regional processing guarantee.
  global('https://api.openai.com/v1'),

  /// United States regional endpoint.
  us('https://us.api.openai.com/v1'),

  /// European regional endpoint.
  eu('https://eu.api.openai.com/v1'),

  /// United Arab Emirates endpoint; processing has model/service restrictions.
  ae('https://ae.api.openai.com/v1'),

  /// Australia regional endpoint.
  au('https://au.api.openai.com/v1'),

  /// India regional endpoint.
  india('https://in.api.openai.com/v1'),

  /// Japan regional endpoint.
  jp('https://jp.api.openai.com/v1');

  const OpenAIDataResidency(this.baseUrl);

  /// Complete OpenAI API root for this endpoint selection.
  final String baseUrl;
}
