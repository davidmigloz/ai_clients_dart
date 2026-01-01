/// Configuration constants for integration tests.
///
/// Centralizes model IDs and other test configuration to make it easy
/// to update when new models are released.
library;

/// The default chat model to use for chat completion tests.
const defaultChatModel = 'mistral-small-latest';

/// The default embedding model to use for embedding tests.
const defaultEmbeddingModel = 'mistral-embed';

/// The default vision model to use for multimodal tests.
const defaultVisionModel = 'mistral-small-latest';

/// The default FIM model to use for code completion tests.
const defaultFimModel = 'codestral-latest';

/// The default moderation model to use for moderation tests.
const defaultModerationModel = 'mistral-moderation-latest';

/// The environment variable name for the Mistral API key.
const apiKeyEnvVar = 'MISTRAL_API_KEY';
