# AI Clients Dart

Pure Dart client libraries for popular AI provider APIs, vector databases, and search services. They are designed for Flutter apps, backends, CLIs, and other Dart runtimes across iOS, Android, macOS, Windows, Linux, and Web.

> [!TIP]
> Coding agents: use [llms.txt](./llms.txt) for package hubs, [llms-ctx.txt](./llms-ctx.txt) for the non-optional concatenated context bundle, and [llms-ctx-full.txt](./llms-ctx-full.txt) for the full bundle including optional sources.

## Which package should I use?

- `openai_dart` for the full [OpenAI API](https://platform.openai.com/docs/api-reference) in Dart, including Responses, Chat Completions, audio, images, videos, custom tools, evals, and realtime WebSocket/WebRTC workflows.
- `anthropic_sdk_dart` for the [Anthropic API](https://docs.anthropic.com/en/api), including Claude messages, streaming, tool calling, extended thinking, files, skills, and batch workflows.
- `googleai_dart` for Gemini on [Google AI](https://ai.google.dev/) and [Vertex AI](https://cloud.google.com/vertex-ai), including generation, embeddings, grounding tools, files, and Live API WebSocket sessions.
- `mistralai_dart` for the [Mistral AI API](https://docs.mistral.ai/api), including chat, embeddings, OCR, TTS, voice management, reasoning effort, audio transcription, fine-tuning, and beta agent workflows.
- `ollama_dart` for local and self-hosted [Ollama](https://ollama.com/) deployments, including chat, streaming, embeddings, tool calling, and model lifecycle operations.
- `open_responses` when you want a Dart client for the [OpenResponses](https://www.openresponses.org/) specification, which brings one typed responses interface to multiple supported providers.
- `chromadb` for [ChromaDB](https://trychroma.com/) collections, vector search, multi-tenant storage, and RAG pipelines.
- `openai_realtime_dart` for a smaller, lower-level [OpenAI Realtime API](https://platform.openai.com/docs/guides/realtime) client focused on direct WebSocket sessions.
- `tavily_dart` for [Tavily](https://tavily.com/) web search and research APIs in agent and RAG workflows.

## Key Features

- Type-safe request and response models with sealed classes and ergonomic helpers.
- Pure Dart implementations that work in Flutter apps, backends, CLIs, and other non-Flutter runtimes.
- Minimal first-party dependencies (`http`, `logging`, `meta`, and, where needed, `web_socket`).
- Documentation optimized for coding agents through `llms.txt`, `llms-ctx.txt`, and `llms-ctx-full.txt`.
- Streaming support, tool calling, retries, interceptors, and multimodal APIs across multiple providers.
- Consistent package structure with examples, tests, and platform-aware client configuration.

## Packages

| Package | Version | Downloads |
| --- | --- | --- |
| [anthropic_sdk_dart](https://pub.dev/packages/anthropic_sdk_dart) | [![anthropic_sdk_dart](https://img.shields.io/pub/v/anthropic_sdk_dart.svg)](https://pub.dev/packages/anthropic_sdk_dart) | ![anthropic_sdk_dart monthly downloads](https://img.shields.io/pub/dm/anthropic_sdk_dart) |
| [chromadb](https://pub.dev/packages/chromadb) | [![chromadb](https://img.shields.io/pub/v/chromadb.svg)](https://pub.dev/packages/chromadb) | ![chromadb monthly downloads](https://img.shields.io/pub/dm/chromadb) |
| [googleai_dart](https://pub.dev/packages/googleai_dart) | [![googleai_dart](https://img.shields.io/pub/v/googleai_dart.svg)](https://pub.dev/packages/googleai_dart) | ![googleai_dart monthly downloads](https://img.shields.io/pub/dm/googleai_dart) |
| [mistralai_dart](https://pub.dev/packages/mistralai_dart) | [![mistralai_dart](https://img.shields.io/pub/v/mistralai_dart.svg)](https://pub.dev/packages/mistralai_dart) | ![mistralai_dart monthly downloads](https://img.shields.io/pub/dm/mistralai_dart) |
| [ollama_dart](https://pub.dev/packages/ollama_dart) | [![ollama_dart](https://img.shields.io/pub/v/ollama_dart.svg)](https://pub.dev/packages/ollama_dart) | ![ollama_dart monthly downloads](https://img.shields.io/pub/dm/ollama_dart) |
| [open_responses](https://pub.dev/packages/open_responses) | [![open_responses](https://img.shields.io/pub/v/open_responses.svg)](https://pub.dev/packages/open_responses) | ![open_responses monthly downloads](https://img.shields.io/pub/dm/open_responses) |
| [openai_dart](https://pub.dev/packages/openai_dart) | [![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart) | ![openai_dart monthly downloads](https://img.shields.io/pub/dm/openai_dart) |
| [openai_realtime_dart](https://pub.dev/packages/openai_realtime_dart) | [![openai_realtime_dart](https://img.shields.io/pub/v/openai_realtime_dart.svg)](https://pub.dev/packages/openai_realtime_dart) | ![openai_realtime_dart monthly downloads](https://img.shields.io/pub/dm/openai_realtime_dart) |
| [tavily_dart](https://pub.dev/packages/tavily_dart) | [![tavily_dart](https://img.shields.io/pub/v/tavily_dart.svg)](https://pub.dev/packages/tavily_dart) | ![tavily_dart monthly downloads](https://img.shields.io/pub/dm/tavily_dart) |

## Used By

These open-source packages and apps use one or more clients from this repo. For more, see the [GitHub dependents graph](https://github.com/davidmigloz/ai_clients_dart/network/dependents).

### Packages

- [langchain_dart](https://github.com/davidmigloz/langchain_dart) ![langchain monthly downloads](https://img.shields.io/pub/dm/langchain)
- [dartantic](https://github.com/csells/dartantic) ![dartantic monthly downloads](https://img.shields.io/pub/dm/dartantic_ai)
- [genkit-dart](https://github.com/genkit-ai/genkit-dart) ![genkit monthly downloads](https://img.shields.io/pub/dm/genkit)

### Apps

- [Anx Reader](https://github.com/Anxcye/anx-reader) ![Anx Reader stars](https://img.shields.io/github/stars/Anxcye/anx-reader)
- [ApiDash](https://github.com/foss42/apidash) ![ApiDash stars](https://img.shields.io/github/stars/foss42/apidash)
- [Lotti](https://github.com/matthiasn/lotti) ![Lotti stars](https://img.shields.io/github/stars/matthiasn/lotti)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

AI Clients Dart is licensed under the [MIT License](LICENSE).
