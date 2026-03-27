# AI Clients Dart

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)](https://discord.gg/x4qbhqecVR)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Type-safe Dart clients for OpenAI, Anthropic, Google Gemini, Mistral, Ollama, and more — all sharing a consistent API shape. Built for Flutter apps, backends, CLIs, and server-side Dart across every platform.

<details>
<summary><b>Table of Contents</b></summary>

- [Quickstart](#quickstart)
- [Packages](#packages)
- [Why choose these clients?](#why-choose-these-clients)
- [Used By](#used-by)
- [For Coding Agents](#for-coding-agents)
- [Sponsor](#sponsor)
- [License](#license)

</details>

## Quickstart

The AI provider clients share a consistent shape — pick one and start with a few lines:

<details open>
<summary><b>OpenAI</b></summary>

```yaml
dependencies:
  openai_dart: ^3.0.0
```

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.4',
        input: ResponseInput.text('What is the capital of France?'),
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}
```

</details>

<details>
<summary><b>Anthropic</b></summary>

```yaml
dependencies:
  anthropic_sdk_dart: ^1.4.0
```

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 1024,
        messages: [InputMessage.user('What is the capital of France?')],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

</details>

<details>
<summary><b>Google Gemini</b></summary>

```yaml
dependencies:
  googleai_dart: ^4.0.0
```

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Explain why Dart works well for APIs.')],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

</details>

<details>
<summary><b>Ollama</b></summary>

```yaml
dependencies:
  ollama_dart: ^2.0.0
```

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final response = await client.chat.create(
      request: ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('Explain what Dart isolates do.')],
      ),
    );

    print(response.message?.content);
  } finally {
    client.close();
  }
}
```

</details>

## Packages

| Package | Description | Version | Downloads |
| --- | --- | --- | --- |
| [openai_dart](https://pub.dev/packages/openai_dart) | [OpenAI](https://platform.openai.com/docs/api-reference) — Responses, Chat Completions, images, audio, realtime | [![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart) | ![openai_dart monthly downloads](https://img.shields.io/pub/dm/openai_dart) |
| [anthropic_sdk_dart](https://pub.dev/packages/anthropic_sdk_dart) | [Anthropic](https://docs.anthropic.com/en/api) — Claude messages, streaming, tools, extended thinking | [![anthropic_sdk_dart](https://img.shields.io/pub/v/anthropic_sdk_dart.svg)](https://pub.dev/packages/anthropic_sdk_dart) | ![anthropic_sdk_dart monthly downloads](https://img.shields.io/pub/dm/anthropic_sdk_dart) |
| [googleai_dart](https://pub.dev/packages/googleai_dart) | [Google AI](https://ai.google.dev/) / [Vertex AI](https://cloud.google.com/vertex-ai) — Gemini generation, embeddings, Live API | [![googleai_dart](https://img.shields.io/pub/v/googleai_dart.svg)](https://pub.dev/packages/googleai_dart) | ![googleai_dart monthly downloads](https://img.shields.io/pub/dm/googleai_dart) |
| [mistralai_dart](https://pub.dev/packages/mistralai_dart) | [Mistral AI](https://docs.mistral.ai/api) — chat, embeddings, OCR, TTS, reasoning, agents | [![mistralai_dart](https://img.shields.io/pub/v/mistralai_dart.svg)](https://pub.dev/packages/mistralai_dart) | ![mistralai_dart monthly downloads](https://img.shields.io/pub/dm/mistralai_dart) |
| [ollama_dart](https://pub.dev/packages/ollama_dart) | [Ollama](https://ollama.com/) — local chat, streaming, embeddings, tool calling | [![ollama_dart](https://img.shields.io/pub/v/ollama_dart.svg)](https://pub.dev/packages/ollama_dart) | ![ollama_dart monthly downloads](https://img.shields.io/pub/dm/ollama_dart) |
| [open_responses](https://pub.dev/packages/open_responses) | [OpenResponses](https://www.openresponses.org/) — one typed interface, multiple providers | [![open_responses](https://img.shields.io/pub/v/open_responses.svg)](https://pub.dev/packages/open_responses) | ![open_responses monthly downloads](https://img.shields.io/pub/dm/open_responses) |
| [chromadb](https://pub.dev/packages/chromadb) | [ChromaDB](https://www.trychroma.com/) — vector search, collections, multi-tenant RAG | [![chromadb](https://img.shields.io/pub/v/chromadb.svg)](https://pub.dev/packages/chromadb) | ![chromadb monthly downloads](https://img.shields.io/pub/dm/chromadb) |
| [openai_realtime_dart](https://pub.dev/packages/openai_realtime_dart) | [OpenAI Realtime](https://platform.openai.com/docs/guides/realtime) — lower-level WebSocket sessions | [![openai_realtime_dart](https://img.shields.io/pub/v/openai_realtime_dart.svg)](https://pub.dev/packages/openai_realtime_dart) | ![openai_realtime_dart monthly downloads](https://img.shields.io/pub/dm/openai_realtime_dart) |
| [tavily_dart](https://pub.dev/packages/tavily_dart) | [Tavily](https://tavily.com/) — web search and research for agents and RAG | [![tavily_dart](https://img.shields.io/pub/v/tavily_dart.svg)](https://pub.dev/packages/tavily_dart) | ![tavily_dart monthly downloads](https://img.shields.io/pub/dm/tavily_dart) |

## Why choose these clients?

- **Pure Dart** — works everywhere: Flutter apps, backends, CLIs, and server-side Dart across iOS, Android, macOS, Windows, Linux, and Web.
- **Type-safe** — sealed classes, typed request/response models, and ergonomic helpers.
- **Consistent shape** — AI provider clients share `fromEnvironment()` for config, similar resource methods, and `close()` for cleanup.
- **Minimal dependencies** — just `http`, `logging`, `meta`, and where needed `web_socket`.
- **Strict semver** — follows [semver.org](https://semver.org/) so downstream packages can depend on stable, predictable version ranges.

## Used By

These open-source packages and apps use one or more clients from this repo. For more, see the [GitHub dependents graph](https://github.com/davidmigloz/ai_clients_dart/network/dependents).

### Packages

| Package | Downloads |
| --- | --- |
| [langchain_dart](https://github.com/davidmigloz/langchain_dart) | ![langchain monthly downloads](https://img.shields.io/pub/dm/langchain) |
| [dartantic](https://github.com/csells/dartantic) | ![dartantic monthly downloads](https://img.shields.io/pub/dm/dartantic_ai) |
| [genkit-dart](https://github.com/genkit-ai/genkit-dart) | ![genkit monthly downloads](https://img.shields.io/pub/dm/genkit) |

### Apps

| App | Stars |
| --- | --- |
| [Anx Reader](https://github.com/Anxcye/anx-reader) | ![Anx Reader stars](https://img.shields.io/github/stars/Anxcye/anx-reader) |
| [ApiDash](https://github.com/foss42/apidash) | ![ApiDash stars](https://img.shields.io/github/stars/foss42/apidash) |
| [Lotti](https://github.com/matthiasn/lotti) | ![Lotti stars](https://img.shields.io/github/stars/matthiasn/lotti) |

## For Coding Agents

Use [llms.txt](./llms.txt) for package hubs, [llms-ctx.txt](./llms-ctx.txt) for the non-optional concatenated context bundle, and [llms-ctx-full.txt](./llms-ctx-full.txt) for the full bundle including optional sources.

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

AI Clients Dart is licensed under the [MIT License](LICENSE).
