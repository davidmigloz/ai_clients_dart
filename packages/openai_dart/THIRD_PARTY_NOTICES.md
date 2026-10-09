# Third-party notices

The Live transcript helpers in `lib/src/helpers/live/` and their SDK-derived golden
fixtures adapt OpenAI's Live transcript implementation. Copyright 2026 OpenAI.
The upstream implementation is licensed under the Apache License, Version 2.0;
its [complete license](licenses/openai-sdk-apache-2.0.txt) is included unchanged.
The package's MIT license does not replace this upstream notice.

Sources: [OpenAI Node SDK helpers](https://github.com/openai/openai-node/tree/5e70623d6df4596bf39bcb9d2c93d8e8a50b856f/src/lib/live)
and [OpenAI Python SDK helpers](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/live).
The Dart adaptations introduce immutable value types, explicit-time grouping,
Dart timer and broadcast-tap ownership, Unicode boundary handling, and a separate
caller-clock playback projection. The SDK-derived fixtures retain source behavior
while exercising it through public Dart APIs. No upstream NOTICE file accompanies
the pinned Node SDK; the copyright and exact LICENSE are preserved here.
