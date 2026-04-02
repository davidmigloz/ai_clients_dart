/// Configuration constants for integration tests.
///
/// Centralizes model IDs and other test configuration to make it easy
/// to update when new models are released.
library;

/// The default generative model to use for content generation tests.
const defaultGenerativeModel = 'gemini-2.5-flash';

/// The default embedding model to use for embedding tests.
const defaultEmbeddingModel = 'gemini-embedding-2-preview';

/// The default model to use for Interactions API tests.
/// Note: This is a preview model - ID may change.
const defaultInteractionsModel = 'gemini-3-flash-preview';

/// The default model to use for Live API WebSocket streaming tests.
/// Note: This is a preview model - ID may change.
const defaultLiveModel = 'gemini-3.1-flash-live-preview';

/// The default model to use for TTS (Text-to-Speech) tests.
/// Note: This is a preview model - ID may change.
const defaultTTSModel = 'gemini-2.5-flash-preview-tts';

/// The default model to use for STT (Speech-to-Text) tests.
const defaultSTTModel = 'gemini-3-flash-preview';

/// The default Gemma model to use for open model tests.
const defaultGemmaModel = 'gemma-4-26b-a4b-it';
